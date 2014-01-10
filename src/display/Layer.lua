--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local App = require("display.App")
local Event = require("event.Event")
local EventDispatcher = require("event.EventDispatcher")

local TouchHandler = class()

local Layer = class(EventDispatcher)
Layer.__index = MOAILayer.getInterfaceTable()
Layer.__moai_class = MOAILayer


---
-- 
-- 
function Layer:init(viewport)
    EventDispatcher.init(self)

    self:setViewport(viewport or App.viewport)
    self.touchEnabled = false
    self.touchHandler = nil
end


---
-- Enables this layer for touch events.
-- @param value enabled
function Layer:setTouchEnabled(value)
    if self.touchEnabled == value then
        return
    end
    self.touchEnabled = value
    if value  then
        self.touchHandler = self.touchHandler or TouchHandler(self)
    end
end



TouchHandler.TOUCH_EVENT = Event()

---
-- The constructor.
-- @param layer Layer object
function TouchHandler:init(layer)
    self.touchLayer = assert(layer)
    self.touchProps = {}

    layer:addEventListener(Event.TOUCH_DOWN, self.onTouch, self)
    layer:addEventListener(Event.TOUCH_UP, self.onTouch, self)
    layer:addEventListener(Event.TOUCH_MOVE, self.onTouch, self)
    layer:addEventListener(Event.TOUCH_CANCEL, self.onTouch, self)
end

---
-- Event handler when you touch a layer.
-- @param e Event object
function TouchHandler:onTouch(e)
    if not self.touchLayer.touchEnabled then
        return
    end

    -- targeted prop
    local prop = self.touchProps[e.idx]
    
    if e.type == Event.TOUCH_DOWN then
        -- get new prop as target
        prop = self:getTouchableProp(e)
        self.touchProps[e.idx] = prop

    elseif e.type == Event.TOUCH_UP then
        self.touchProps[e.idx] = nil

    elseif e.type == Event.TOUCH_CANCEL then
        self.touchProps[e.idx] = nil

    end

    -- touch event
    local e2 = table.merge(self.TOUCH_EVENT, e)

    -- dispatch event
    if prop then
        e2.prop = prop
        self:dispatchTouchEvent(e2, prop)
        e:stop()
    end
    
    -- reset properties to free resources used in cached event
    e2.data = nil
    e2.prop = nil
    e2.target = nil
    e2:setListener(nil, nil)
end

---
-- Return the touchable Prop.
-- @param e Event object
function TouchHandler:getTouchableProp(e)
    local layer = self.touchLayer
    local partition = layer:getPartition()
    local sortMode = layer:getSortMode()
    local props = {partition:propListForPoint(e.wx, e.wy, 0, sortMode)}
    for i = #props, 1, -1 do
        local prop = props[i]
        if not prop.ignoreTouch and prop:getAttr(MOAIProp.ATTR_VISIBLE) > 0 then
            return prop
        end
    end
end

---
-- Fire touch handler events on a given object.
-- @param e Event object
-- @param o Display object
function TouchHandler:dispatchTouchEvent(e, o)
    local layer = self.touchLayer
    while o do
        if o.dispatchEvent then
            o:dispatchEvent(e)
        elseif o.eventDispatcher then
            o.eventDispatcher:dispatchEvent(e)
        end
        if e.stopFlag then
            break
        end
        o = o.parent
    end
end

---
-- Remove the handler from the layer, and release resources.
function TouchHandler:dispose()
    local layer = self.touchLayer

    layer:removeEventListener(Event.TOUCH_DOWN, self.onTouch, self)
    layer:removeEventListener(Event.TOUCH_UP, self.onTouch, self)
    layer:removeEventListener(Event.TOUCH_MOVE, self.onTouch, self)
    layer:removeEventListener(Event.TOUCH_CANCEL, self.onTouch, self)
end


return Layer