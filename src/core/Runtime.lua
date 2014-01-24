----------------------------------------------------------------------------------------------------
-- @type Runtime
--
-- This is a utility class which starts immediately upon library load
-- and acts as the single handler for ENTER_FRAME events (which occur
-- whenever Moai yields control to the Lua subsystem on each frame).
-- Also registers itself as listener for events from MOAIAppIOS and MOAISim. 
----------------------------------------------------------------------------------------------------
local Event = require("core.Event")
local EventDispatcher = require("core.EventDispatcher")

Runtime = EventDispatcher()

-- initialize
function Runtime:initialize()
    Executors.callLoop(self.onEnterFrame)
    MOAIGfxDevice.setListener(MOAIGfxDevice.EVENT_RESIZE, self.onResize)

    if MOAIAppIOS then
        MOAIAppIOS.setListener(MOAIAppIOS.SESSION_START, self.onSessionStart)
        MOAIAppIOS.setListener(MOAIAppIOS.APP_OPENED_FROM_URL, self.onOpenedFromUrl)
        MOAIAppIOS.setListener(MOAIAppIOS.SESSION_END, self.onSessionEnd)
    elseif MOAIAppAndroid then
        MOAIAppAndroid.setListener(MOAIAppAndroid.SESSION_START, self.onSessionStart)
        MOAIAppAndroid.setListener(MOAIAppAndroid.APP_OPENED_FROM_URL, self.onOpenedFromUrl)
        MOAIAppAndroid.setListener(MOAIAppAndroid.SESSION_END, self.onSessionEnd)
    end

    MOAISim.setListener(MOAISim.EVENT_PAUSE, self.onPause)
    MOAISim.setListener(MOAISim.EVENT_RESUME, self.onResume)
end

-- enter frame
function Runtime.onEnterFrame()
    Runtime:dispatchEvent(Event.ENTER_FRAME)
end

-- view resize
function Runtime.onResize(width, height)
    local e = Event(Event.RESIZE)
    e.width = width
    e.height = height
    Runtime:dispatchEvent(e)
end

function Runtime.onPause()
    Runtime:dispatchEvent(Event.PAUSE)
end

function Runtime.onResume()
    Runtime:dispatchEvent(Event.RESUME)
end

function Runtime.onSessionStart(resumed)
    local e = Event(Event.SESSION_START)
    e.resumed = resumed
    Runtime:dispatchEvent(e)
end

function Runtime.onSessionEnd()
    Runtime:dispatchEvent(Event.SESSION_END)
end

function Runtime.onOpenedFromUrl(url)
    local e = Event(Event.OPENED_FROM_URL)
    e.url = url
    Runtime:dispatchEvent(e)    
end

return Runtime