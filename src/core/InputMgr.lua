--------------------------------------------------------------------------------
-- 
-- 
-- 
--------------------------------------------------------------------------------

local Event = require("core.Event")
local EventDispatcher = require("core.EventDispatcher")

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
-- Dispatch touch cancel event to all listeners. 
-- @param object Event touch begin or move event that should be cancelled
function InputMgr:dispatchCancelEvent(touchEvent)
    local event = Event()
    table.merge(event, touchEvent)
    event.type = Event.TOUCH_CANCEL
    
    self:dispatchEvent(event)
end

return InputMgr