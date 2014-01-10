----------------------------------------------------------------------------------------------------
-- @type Event
--
-- A class for events, which are communicated to, and handled by, event handlers
-- Holds the data of the Event.
----------------------------------------------------------------------------------------------------
local Event = class()

Event.ENTER_FRAME   = "enterFrame"
Event.ENTER         = "enter"
Event.EXIT          = "exit"
Event.WILL_ENTER    = "willEnter"
Event.DID_EXIT      = "didExit"
Event.UPDATE        = "update"
Event.TOUCH_EVENT   = "touch"
Event.TOUCH_DOWN    = "touchDown"
Event.TOUCH_UP      = "touchUp"
Event.TOUCH_MOVE    = "touchMove"
Event.TOUCH_CANCEL  = "touchCancel"
Event.KEY_DOWN      = "keyDown"
Event.KEY_UP        = "keyUp"
Event.RESIZE        = "resize"

---
-- Event's constructor.
-- @param eventType (option)The type of event.
function Event:init(eventType)
    self.type = eventType
    self.stopFlag = false
end

---
-- INTERNAL USE ONLY -- Sets the event listener via EventDispatcher.
-- @param callback callback function
-- @param source source object.
function Event:setListener(callback, source)
    self.callback = callback
    self.source = source
end

---
-- Stop the propagation of the event.
function Event:stop()
    self.stopFlag = true
end

return Event