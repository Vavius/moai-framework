--------------------------------------------------------------------------------
--
--
--
---------------------------------------------------------------------------------

local App               = require("core.App")
local Group             = require("core.Group")
local Event             = require("core.Event")
local EventDispatcher   = require("core.EventDispatcher")


local Scene = class(Group, EventDispatcher)

Scene.TOUCH_EVENT = Event()

---
-- The constructor.
function Scene:init(params)
    EventDispatcher.init(self)
    Group.init(self, nil, App.screenWidth, App.screenHeight)

    self.layers = {}
    self.isScene = true
    self.opened = false
    self.started = false
    self.sceneUpdateEnabled = false
    self.sceneTouchEnabled = false

    self:addEventListener(Event.TOUCH_DOWN, self.onTouch, self)
    self:addEventListener(Event.TOUCH_UP, self.onTouch, self)
    self:addEventListener(Event.TOUCH_MOVE, self.onTouch, self)
    self:addEventListener(Event.TOUCH_CANCEL, self.onTouch, self)
end

---
-- Open the scene.
-- Scenes add themselves to the SceneMgr when opened.
-- @param params Scene event parameters.(event.data)
function Scene:open(params)
    if self.opened then
        return
    end
    
    self:dispatchEvent(Event.WILL_ENTER, params)
    self.opened = true
end

function Scene:addLayer(layer)
    if table.insertIfAbsent(self.layers, layer) then
        layer:setParent(self)

        return true
    end
    return false
end

---
-- Close the scene, removing it from the SceneMgr.
-- @param params Scene event parameters.(event.data)
function Scene:close(params)
    if not self.opened then
        return
    end

    self:stop()
    self.opened = false
    self:dispatchEvent(Event.DID_EXIT, params)
end

---
-- Start the scene.
-- Start event is issued.
-- @param params Scene event parameters.(event.data)
function Scene:start(params)
    if self.started or not self.opened then
        return
    end
    self:dispatchEvent(Event.ENTER, params)
    self.started = true
    self.paused = false
    self.sceneUpdateEnabled = true
    self.sceneTouchEnabled = true
end

---
-- Stop the scene.
-- Stop event is issued.
-- @param params Scene event parameters.(event.data)
function Scene:stop(params)
    if not self.started then
        return
    end
    self:dispatchEvent(Event.EXIT, params)
    self.started = false
    self.sceneUpdateEnabled = false
    self.sceneTouchEnabled = false
end

---
-- Handle touch events sent by the EventMgr.
-- @param e Event
function Scene:onTouch(e)
    local e2 = table.merge(Scene.TOUCH_EVENT, e)
    for i = #self.layers, 1, -1 do
        local layer = self.layers[i]
        if layer.touchEnabled and layer:getVisible() then
            e2.wx, e2.wy = layer:wndToWorld(e.x, e.y, 0)
            layer:dispatchEvent(e2)
        end
        if e2.stopFlag then
            e:stop()
            break
        end
    end
end


return Scene