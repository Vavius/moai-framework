----------------------------------------------------------------------------------------------------
-- @type Runtime
--
-- This is a utility class which starts immediately upon library load
-- and acts as the single handler for ENTER_FRAME events (which occur
-- whenever Moai yields control to the Lua subsystem on each frame).
----------------------------------------------------------------------------------------------------
local Event = require("event.Event")
local EventDispatcher = require("event.EventDispatcher")

Runtime = EventDispatcher()

-- initialize
function Runtime:initialize()
    Executors.callLoop(self.onEnterFrame)
    MOAIGfxDevice.setListener(MOAIGfxDevice.EVENT_RESIZE, self.onResize)
end

-- enter frame
function Runtime.onEnterFrame()
    Runtime:dispatchEvent(Event.ENTER_FRAME)
end

-- view resize
function Runtime.onResize(width, height)
    -- M.updateDisplaySize(width, height)
    
    local e = Event(Event.RESIZE)
    e.width = width
    e.height = height
    Runtime:dispatchEvent(e)
end

return Runtime