--------------------------------------------------------------------------------
-- 
-- 
-- 
--------------------------------------------------------------------------------

local Event = require("event.Event")
local EventDispatcher = require("event.EventDispatcher")

local pointerSensor = MOAIInputMgr.device.pointer
local mouseLeftSensor = MOAIInputMgr.device.mouseLeft
local touchSensor = MOAIInputMgr.device.touch
local keyboardSensor = MOAIInputMgr.device.keyboard

local InputMgr = EventDispatcher()

-- Touch Events
InputMgr.TOUCH_EVENT = Event()

-- Keyboard
InputMgr.KEYBOARD_EVENT = Event()

-- Touch Event Kinds
InputMgr.TOUCH_EVENT_KINDS = {
    [MOAITouchSensor.TOUCH_DOWN]    = Event.TOUCH_DOWN,
    [MOAITouchSensor.TOUCH_UP]      = Event.TOUCH_UP,
    [MOAITouchSensor.TOUCH_MOVE]    = Event.TOUCH_MOVE,
    [MOAITouchSensor.TOUCH_CANCEL]  = Event.TOUCH_CANCEL,
}

-- pointer data
InputMgr.pointer = {x = 0, y = 0, down = false}


function InputMgr:initialize()
    self.focus = {}

    -- Touch Handler
    local onTouch = function(eventType, idx, x, y, tapCount)
        local event = InputMgr.TOUCH_EVENT
        event.type = InputMgr.TOUCH_EVENT_KINDS[eventType]
        event.idx = idx
        event.x = x
        event.y = y
        event.tapCount = tapCount

        self:dispatchEvent(event)
    end

    -- Pointer Handler
    local onPointer = function(x, y)
        self.pointer.x = x
        self.pointer.y = y

        if self.pointer.down then
            onTouch(MOAITouchSensor.TOUCH_MOVE, 1, x, y, 1)
        end
    end

    -- Click Handler
    local onClick = function(down)
        self.pointer.down = down
        local eventType = down and MOAITouchSensor.TOUCH_DOWN or MOAITouchSensor.TOUCH_UP

        onTouch(eventType, 1, self.pointer.x, self.pointer.y, 1)
    end

    -- Keyboard Handler
    local onKeyboard = function(key, down)
        local event = InputMgr.KEYBOARD_EVENT
        event.type = down and Event.KEY_DOWN or Event.KEY_UP
        event.key = key
        event.down = down

        self:dispatchEvent(event)
    end

    -- mouse or touch input
    if pointerSensor then
        pointerSensor:setCallback(onPointer)
        mouseLeftSensor:setCallback(onClick)
    else
        touchSensor:setCallback(onTouch)
    end

    -- keyboard input
    if keyboardSensor then
        keyboardSensor:setCallback(onKeyboard)
    end
end


---
-- If the user has pressed a key returns true.
-- @param key Key code
-- @return true is a key is down.
function InputMgr:keyIsDown(key)
    if keyboardSensor then
        return keyboardSensor:keyIsDown(key)
    end
end

---
-- Set specific object as focus object. Only listeners on this object will receive events. 
-- @param object TouchDispatcher
-- @param touchEvent event object 
-- @param swallow (option) bool. Send cancel touch event to all other listeners
function InputMgr:setFocus(object, touchEvent, swallow)
    if swallow then
        self.ignore = object
        
        local event = table.dup(touchEvent)
        event.type = Event.TOUCH_CANCEL

        self:dispatchEvent(event)
        self.ignore = nil
    end

    self.focus[touchEvent.idx or 1] = object
end

---
-- Override dispatch event to allow focus managing. 
-- @param event Event object or Event type name. 
-- @param data Data that is set in the event. 
function InputMgr:dispatchEvent(event, data)
    local focus = self.focus[event.idx]
    local ignore = self.ignore

    local eventName = type(event) == "string" and event
    if eventName then
        event = EventDispatcher.EVENT_CACHE[eventName] or Event(eventName)
        EventDispatcher.EVENT_CACHE[eventName] = nil
    end

    assert(event.type)

    event.stopFlag = false
    event.target = self.eventTarget or self
    if data ~= nil then
        event.data = data
    end

    local listeners = self.eventListenersMap[event.type] or {}

    for key, obj in ipairs(listeners) do
        if (not focus or obj == focus) and obj ~= ignore and obj.type == event.type then
            event:setListener(obj.callback, obj.source)
            obj:call(event)
            if event.stopFlag == true then
                break
            end
        end
    end

    if eventName then
        EventDispatcher.EVENT_CACHE[eventName] = event
    end

    -- reset properties to free resources used in cached events
    event.data = nil
    event.target = nil
    event:setListener(nil, nil)
end


return InputMgr