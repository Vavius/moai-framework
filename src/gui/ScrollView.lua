--------------------------------------------------------------------------------
-- 
-- 
-- 
--------------------------------------------------------------------------------

local Layer = require("core.Layer")
local Group = require("core.Group")
local Event = require("core.Event")
local Executors = require("core.Executors")
local UIEvent = require("gui.UIEvent")
local UIObjectBase = require("gui.UIObjectBase")

--------------------------------------------------------------------------------
-- forward declarations
--------------------------------------------------------------------------------
local CircularArray
local Coverflow

local ScrollView = class(UIObjectBase, Group)


-- Dialog {
--     pos = {},
--     background = Sprite(),
--     children = {
--         Button {
--             close,

--         }
--         ScrollView {

--         }
--     },

-- }

---
-- Example usage
-- 
-- scrollView = ScrollView {
--      size = {400, 300}, 
--      visibleRect = {x1, y1, x2, y2}, -- clip rect for scissor rect, which is propagated to children
--      items = { child1, child2 }, 
--      contentSize = {400, 600},   -- size of the scroll container, defines scroll bounds
--      autoSize = true,            -- adjust container size when items are added or deleted
--      damping = 0.95,
--      maxVelocity = 20,
--      minVelocity = 4,
--      rubberEffectDamping = 0.9,
--      rubberEffect = false,
--      
-- }
-- 
-- scrollView:addItem() -- add item to scroll container
-- scrollView:removeItem()
-- scrollView:scrollTo(x, y, time, ease)


--------------------------------------------------------------------------------
-- Physics 
--------------------------------------------------------------------------------
local CIRCULAR_ARRAY_DEFAULT_CAPACITY = 4
local SCROLL_PARAMS = {
    damping = 0.95,
    maxVelocity = 20,
    minVelocity = 4,
    rubberEffectDamping = 0.9,
    xScrollEnabled = true,
    yScrollEnabled = true,
    rubberEffect = true,
    touchDistanceToSlide = 30,
    autoSize = true,
    clipping = false,
}

--------------------------------------------------------------------------------
-- private 
--------------------------------------------------------------------------------
-- class for managing circular array to accumulate user touch updates and compute average velocity
CircularArray = class()

function CircularArray:init(cap)
    self._innerTable = { }
    self._cap = cap or CIRCULAR_ARRAY_DEFAULT_CAPACITY
    self._lastIndex = 1
end

function CircularArray:startTracking()
    self:stopTracking()
    self._updateThread = Executors.callLoop(function()
        for k, v in pairs(self._innerTable) do
            v.elapsedFrames = v.elapsedFrames + 1
            if v.elapsedFrames > self._cap then
                self._innerTable[k] = nil
            end
        end
    end)
end

function CircularArray:stopTracking()
    if self._updateThread then
        self._updateThread:stop()
        self._updateThread = nil
    end
end

function CircularArray:add(val)
    local index = self._lastIndex
    self._innerTable[index] = {
        value = val,
        elapsedFrames = 0,
    }
    self._lastIndex = 1 + (index + 1) % self._cap
end

function CircularArray:clear()
    self._innerTable = { }
    self._lastIndex = 1
end

function CircularArray:average()
    local total = 0
    local count = 0
    
    for k, v in pairs(self._innerTable) do
        total = total + v.value
        count = count + 1
    end

    if count > 0 then
        return total / count
    else
        return 0
    end
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
local ScrollView = class(UIObjectBase, Group)


ScrollView.propertyOrder = {
    items = 2,
    layer = 3,
    useSeparateLayer = 4,
}


function ScrollView:init(params)
    Group.init(self)
        
    self.container = Group()
    self:addChild(self.container)

    UIObjectBase.init(self, params)

    self._velocityAccumulator = CircularArray()
    self._xScrollPosition = 0
    self._yScrollPosition = 0

    for k, v in SCROLL_PARAMS do
        if not self[k] then self[k] = v end
    end

    self.layer:addEventListener(Event.TOUCH_DOWN, self.onTouchDown, self)
    self.layer:addEventListener(Event.TOUCH_UP, self.onTouchUp, self)
    self.layer:addEventListener(Event.TOUCH_MOVE, self.onTouchMove, self)
    self.layer:addEventListener(Event.TOUCH_CANCEL, self.onTouchCancel, self)
end


function ScrollView:setContentSize(width, height)
    -- self._contentWidth = 
end

---
-- Looks in inner container first
function ScrollView:getChildByName(name)
    for i, child in ipairs(self.container) do
        if child.name == name then
            return child.name
        end
    end

    return Group.getChildByName(name)
end


function ScrollView:addItem(item)
    local result = self.container:addChild(item)
    self:recomputeContentSize()
    return result
end


function ScrollView:removeItem(item)
    local result = self.container:removeChild(item)
    self:recomputeContentSize()
    return result
end


function ScrollView:setItems(...)
    items = {...}

    for i, item in ipairs(items) do
        self.container:addChild(child)
    end
end


function ScrollView:recomputeContentSize(force)
    if not force and not self.autoSize then
        return
    end


end


function ScrollView:scrollTo(x, y, time, ease)
    x = x or 0
    y = y or 0
    time = time or 0.5
    ease = ease or MOAIEaseType.EASE_OUT


end

---
-- Initializes scroll view to use separate layer with moving camera
-- Provides better performance. Use when you're adding more than 300 props to scroll view
-- 
-- @return layer scroll view layer, that should be added to scene
function ScrollView:setUseSeparateLayer()
    if self._moveCamera then return end

    local layer = Layer()
    layer:setTouchEnabled(true)

    self.container:setLayer(layer)

    local camera = MOAICamera()
    layer:setCamera(camera)
    self.camera = camera
    self._moveCamera = true

    return layer
end


function ScrollView:onTouchDown(e)
    if not isTouchInsideRect(e.wx, e.wy, self.touchRect) then
        return
    end
    
    if (self._curScrollThread) then
        self._curScrollThread:stop()
        self._curScrollThread = nil
    end

    self._touchIdx = e.idx
    self._initialLocX = e.wx
    self._initialLocY = e.wy
    self._trackingTouch = false
    self._velocityAccumulator:clear()
    self._velocityAccumulator:startTracking()
end

function ScrollView:onTouchMove(e)
    if self._touchIdx ~= e.idx then
        return
    end

    if self._trackingTouch and self._lastTouchX then
        self:applyOffset(e.wx - self._lastTouchX, e.wy - self._lastTouchY)
        self._velocityAccumulator:add(e.wx - self._lastTouchX)
        e:stop()
    end
    self._lastTouchX = e.wx
    self._lastTouchY = e.wy

    if not self._trackingTouch and 
    (self._xScrollEnabled and self._initialLocX and math.abs(e.wx - self._initialLocX) > self.touchDistanceToSlide or
     self._yScrollEnabled and self._initialLocY and math.abs(e.wy - self._initialLocY) > self.touchDistanceToSlide) then
        self._trackingTouch = true
        self:dispatchEvent(ScrollEvent.SCROLL_BEGIN, self._xScrollPosition)

        -- cancel touch for other listeners on this layer
        -- local e2 = table.copy(e, Event())
        -- e2.type = Event.TOUCH_CANCEL
        -- e2.data = {swallowScrollTouch = true}
        -- self.layer:dispatchEvent(e2)
        self.layer.scene:swallowTouch(self.touchArea, e)
    end
end

function ScrollView:onTouchUp(e)
    if self._touchIdx ~= e.idx then
        return
    end

    if self._trackingTouch then
        e:stop()
    end

    self:startKineticScroll()

    self._touchIdx = nil
    self._lastTouchX = nil
    self._lastTouchY = nil
    self._initialLocX = nil
    self._initialLocY = nil
    self._trackingTouch = nil
    self._velocityAccumulator:stopTracking()
end

function ScrollView:onTouchCancel(e)
    if self._touchIdx ~= e.idx or (e.data and e.data.swallowScrollTouch) then
        return
    end

    if self._trackingTouch then
        e:stop()
    end

    self:startKineticScroll()

    self._touchIdx = nil
    self._lastTouchX = nil
    self._lastTouchY = nil
    self._initialLocX = nil
    self._initialLocY = nil
    self._trackingTouch = nil
    self._velocityAccumulator:stopTracking()
end

function ScrollView:setScrollBounds(xMin, yMin, xMax, yMax)
    self._scrollBounds = {left = xMin or 0, right = xMax or 0, top = yMin or 0, bottom = yMax or 0}
end

function ScrollView:setTouchBounds(xMin, yMin, xMax, yMax)
    self.touchRect = {xMin, yMin, xMax, yMax}
    self.touchArea:setBounds(0, 0, 0, xMax - xMin, yMax - yMin, 0)
    self.touchArea:setLoc(xMin, yMin)
end

function ScrollView:getScrollBounds()
    return self._scrollBounds.xMin, self._scrollBounds.yMin, self._scrollBounds.xMax, self._scrollBounds.yMax
end

-- Return values:
-- bool: x bounds are ok, 
-- bool: y bounds are ok, 
-- number: x correction offset, 
-- number: y correction offset
function ScrollView:checkBounds(dx, dy)
    dx = dx or 0
    dy = dy or 0
    
    local newX = -(self._xScrollPosition + dx)
    local newY = -(self._yScrollPosition + dy)
    local xMin, yMin, xMax, yMax = unpack(self.touchRect)

    local xOffset, yOffset = 0, 0
    if newX + xMax > self._scrollBounds.right then
        xOffset = newX + xMax - self._scrollBounds.right
    end
    if newX + xMin < self._scrollBounds.left then
        xOffset = newX + xMin - self._scrollBounds.left
    end

    if newY + yMax < self._scrollBounds.bottom then
        yOffset = newY + yMax - self._scrollBounds.bottom
    end
    if newY + yMin > self._scrollBounds.top then
        yOffset = newY + yMin - self._scrollBounds.top
    end
    -- if newY + yMax < self._scrollBounds.bottom or newY + yMin > self._scrollBounds.top then
    --     yOk = false
    -- end
    return xOffset == 0, yOffset == 0, xOffset, yOffset
end

function ScrollView:applyOffset(dx, dy)
    local xOk, yOk = self:checkBounds(dx, dy)
    if self._touchIdx and not xOk then dx = 0.33 * dx end
    if self._touchIdx and not yOk then dy = 0.33 * dy end

    if self._xScrollEnabled then
        self._xScrollPosition = self._xScrollPosition + dx
    end
    if self._yScrollEnabled then
        self._yScrollPosition = self._yScrollPosition + dy
    end
    
    self:updatePosition()
end

function ScrollView:updatePosition()
    self.camera:setLoc(-self._xScrollPosition, -self._yScrollPosition)
    -- self.scrollContainer:setLoc(self._xScrollPosition, self._yScrollPosition)
    self:dispatchEvent(ScrollEvent.POSITION_CHANGED, self._xScrollPosition)
end

function ScrollView:scrollToPosition(newX, time)
    assert(newX)
    if self._curScrollThread then
        self._curScrollThread:stop()
    end

    local time = time or 0.1 * math.abs(newX - self._xScrollPosition)
    local animCurve = MOAIAnimCurve.new()
    local animLength = 10 + time
    animCurve:reserveKeys(2)
    animCurve:setKey(1, 0, self._xScrollPosition, MOAIEaseType.SOFT_EASE_IN)
    animCurve:setKey(2, animLength, newX)

    local thread = MOAICoroutine.new()
    thread:run(
        function ()
            for f = 1, animLength do
                self._xScrollPosition = animCurve:getValueAtTime(f)
                self:updatePosition()
                coroutine.yield()
            end
            self:dispatchEvent(ScrollEvent.SCROLL_END, self._xScrollPosition)
        end
    )
    self._curScrollThread = thread
end

function ScrollView:startKineticScroll()
    self._currentVelocity = math.clamp(self._velocityAccumulator:average(), -self._maxVelocity, self._maxVelocity)
    if self._curScrollThread then
        self._curScrollThread:stop()
    end

    self._curScrollThread = flower.Executors.callLoop(function()
        local xOk, yOk = self:checkBounds(0,0)

        if not xOk or math.abs(self._currentVelocity) < self._minVelocity then
            self:startRubberEffect()
            return true
        end

        self._currentVelocity = self.scrollDamping * self._currentVelocity * (xOk and 1 or M.SCROLL_RUBBER_EFFECT_DAMPING)
        self._xScrollPosition = self._xScrollPosition + self._currentVelocity
        self:updatePosition()
    end)
end

function ScrollView:startRubberEffect()
    local xOk, yOk, xOffset, yOffset = self:checkBounds()
    if xOk and yOk then
        return
    end

    self:scrollToPosition(self._xScrollPosition + xOffset)
end






