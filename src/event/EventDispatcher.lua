----------------------------------------------------------------------------------------------------
-- @type EventDispatcher
--
-- This class is responsible for event notifications.
----------------------------------------------------------------------------------------------------
local Event = require("event.Event")
local EventListener = require("event.EventListener")

local EventDispatcher = class()

EventDispatcher.EVENT_CACHE = {}

--------------------------------------------------------------------------------
-- The constructor.
-- @param eventType (option)The type of event.
--------------------------------------------------------------------------------
function EventDispatcher:init()
    self.eventListenersMap = {}
end

---
-- Adds an event listener.
-- will now catch the events that are sent in the dispatchEvent.
-- @param eventType Target event type.
-- @param callback The callback function.
-- @param source (option)The first argument passed to the callback function.
-- @param priority (option)Notification order.
function EventDispatcher:addEventListener(eventType, callback, source, priority)
    assert(eventType)
    assert(callback)

    if self:hasEventListener(eventType, callback, source) then
        return false
    end
    if not self.eventListenersMap[eventType] then
        self.eventListenersMap[eventType] = {}
    end

    local listeners = self.eventListenersMap[eventType]
    local listener = EventListener(eventType, callback, source, priority)

    for i, v in ipairs(listeners) do
        if listener.priority < v.priority then
            table.insert(listeners, i, listener)
            return true
        end
    end

    table.insert(listeners, listener)
    return true
end

---
-- Removes an event listener.
-- @param eventType Type of event to be deleted
-- @param callback Callback function of event to be deleted
-- @param source (option)Source of event to be deleted
-- @return True if it can be removed
function EventDispatcher:removeEventListener(eventType, callback, source)
    assert(eventType)
    assert(callback)

    local listeners = self.eventListenersMap[eventType] or {}

    for i, listener in ipairs(listeners) do
        if listener.type == eventType and listener.callback == callback and listener.source == source then
            table.remove(listeners, i)
            return true
        end
    end
    return false
end

---
-- Returns true if you have an event listener.
-- @param eventType
-- @param callback
-- @param source
-- @return Returns true if you have an event listener matching the criteria.
function EventDispatcher:hasEventListener(eventType, callback, source)
    assert(eventType)

    local listeners = self.eventListenersMap[eventType]
    if not listeners or #listeners == 0 then
        return false
    end

    if callback == nil and source == nil then
        return true
    end

    for i, listener in ipairs(listeners) do
        if listener.callback == callback and listener.source == source then
            return true
        end
    end
    return false
end

---
-- Dispatches the event.
-- @param event Event object or Event type name.
-- @param data Data that is set in the event.
function EventDispatcher:dispatchEvent(event, data)
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
        if obj.type == event.type then
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

---
-- Remove all event listeners.
function EventDispatcher:clearEventListeners()
    self.eventListenersMap = {}
end

return EventDispatcher