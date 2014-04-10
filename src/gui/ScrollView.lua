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
local InputMgr = require("core.InputMgr")
local math = math

local abs = math.abs
local max = math.max
local min = math.min
local atan = math.atan
local ceil = math.ceil
local clamp = math.clamp
local round = math.round
local distance = math.distance

--------------------------------------------------------------------------------
-- forward declarations
--------------------------------------------------------------------------------
local CircularArray
local Coverflow

local ScrollView = class(UIObjectBase, Group)

ScrollView.HORIZONTAL = "horizontal"
ScrollView.VERTICAL = "vertical"
ScrollView.BOTH = "both"
ScrollView.TOP = "top"
ScrollView.LEFT = "left"
ScrollView.RIGHT = "right"
ScrollView.BOTTOM = "bottom"
ScrollView.CENTER = "center"

---
-- Example usage
-- 
-- scrollView = ScrollView {
--      size = {400, 300}, 
--      clipRect = {xMin, yMin, xMax, yMax}, -- scissor rect, which is propagated to children
--      items = { child1, child2 }, 
--      contentRect = {xMin, yMin, xMax, yMax},-- size of the scroll container, defines scroll bounds
--      damping = 0.95,
--      maxVelocity = 20,
--      minVelocity = 0.3,
--      rubberEffect = false,
--      rubberEffectStrength = 4,
--      direction = ScrollView.HORIZONTAL, -- ScrollView.VERTICAL, ScrollView.BOTH
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
    damping = 0.9,
    maxVelocity = 20,
    minVelocity = 0.3,
    xScrollEnabled = true,
    yScrollEnabled = true,
    direction = ScrollView.BOTH,
    rubberEffect = true,
    touchDistanceToSlide = 15,
    padding = {10, 10, 10, 10},
    snapOffsetX = 0,
    snapDistanceX = nil,
    snapOffsetY = 0,
    snapDistanceY = nil,
}

--------------------------------------------------------------------------------
-- private 
--------------------------------------------------------------------------------
-- class for managing circular array to accumulate user touch updates and compute average velocity
CircularArray = class()

function CircularArray:init(cap)
    self._innerTable = { }
    self._cap = cap or CIRCULAR_ARRAY_DEFAULT_CAPACITY
    self:clear()
end

function CircularArray:startTracking()
    self:stopTracking()
    self._updateThread = Executors.callLoop(function()
        for k, v in pairs(self._innerTable) do
            v.elapsedFrames = v.elapsedFrames + 1
            if v.elapsedFrames > self._cap then
                self._innerTable[k].x = 0
                self._innerTable[k].y = 0
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

function CircularArray:add(x, y)
    local index = self._lastIndex
    self._innerTable[index] = {
        x = x,
        y = y,
        elapsedFrames = 0,
    }
    self._lastIndex = 1 + (index + 1) % self._cap
end

function CircularArray:clear()
    for i = 1, self._cap do
        self._innerTable[i] = {x = 0, y = 0, elapsedFrames = 0}
    end
    self._lastIndex = 1
end

function CircularArray:average()
    local totalX = 0
    local totalY = 0
    local count = 0
    
    for k, v in pairs(self._innerTable) do
        if v.elapsedFrames <= self._cap then
            totalX = totalX + v.x
            totalY = totalY + v.y
            count = count + 1
        end
    end

    if count > 0 then
        return totalX / count, totalY / count
    else
        return 0, 0
    end
end

local function attenuation(distance)
    return 4 * atan(0.25 * distance) / distance
    -- distance = distance < 1 and 1 or math.pow(distance/2, 0.667)
    -- return 1 / distance
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------

-- cache event data table
local scrollEventData = {x = 0, y = 0}

ScrollView.propertyOrder = {
    items = 2,
    direction = 3,
    layer = 3,
}

function ScrollView:init(params)
    Group.init(self)
    
    -- default values
    for k, v in pairs(SCROLL_PARAMS) do
        self[k] = v
    end

    self.container = Group()
    self.contentRect = {0, 0, 0, 0}
    self:addChild(self.container)

    -- now set all user properties
    UIObjectBase.init(self, params)

    self._velocityAccumulator = CircularArray()
    self._scrollPositionX = 0
    self._scrollPositionY = 0
end


function ScrollView:setContentRect(xMin, yMin, xMax, yMax)
    self.contentRect[1] = xMin or 0
    self.contentRect[2] = yMin or 0
    self.contentRect[3] = xMax or 0
    self.contentRect[4] = yMax or 0
    self:updatePossibleDirections()
end


function ScrollView:setLayer(layer)
    if self.layer == layer then return end

    if self.layer then
        self.layer:removeEventListener(Event.TOUCH_DOWN, self.onTouchDown, self)
        self.layer:removeEventListener(Event.TOUCH_UP, self.onTouchUp, self)
        self.layer:removeEventListener(Event.TOUCH_MOVE, self.onTouchMove, self)
        self.layer:removeEventListener(Event.TOUCH_CANCEL, self.onTouchCancel, self)
    end

    Group.setLayer(self, layer)

    if layer then
        self.layer:addEventListener(Event.TOUCH_DOWN, self.onTouchDown, self, -10)
        self.layer:addEventListener(Event.TOUCH_UP, self.onTouchUp, self, -10)
        self.layer:addEventListener(Event.TOUCH_MOVE, self.onTouchMove, self, -10)
        self.layer:addEventListener(Event.TOUCH_CANCEL, self.onTouchCancel, self, -10)
    end
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

---
-- 
function ScrollView:setDirection(dir)
    self.direction = dir
    self:updatePossibleDirections()
end

---
-- Scrolls to predefined position
-- One of: "top", "left", "right", "bottom", "center"
function ScrollView:scrollTo(position, time, ease)
    local x, y = self._scrollPositionX, self._scrollPositionY
    local xMin, yMin, zMin, xMax, yMax, zMax = self:getBounds()
    if position == ScrollView.TOP then
        y = yMax - self.contentRect[4]
    elseif position == ScrollView.BOTTOM then
        y = yMin - self.contentRect[2]
    elseif position == ScrollView.LEFT then
        x = xMin - self.contentRect[1]
    elseif position == ScrollView.RIGHT then
        x = xMax - self.contentRect[3]
    elseif position == ScrollView.CENTER then
        x = 0
        y = 0
    end
    self:scrollToPosition(x, y, time, ease)
end

function ScrollView:setClipRect(xMin, yMin, xMax, yMax)
    self.scissorRect = self.scissorRect or MOAIScissorRect.new()
    self.scissorRect:setRect(xMin, yMin, xMax, yMax)
    
    self.scissorRect:setAttrLink(MOAITransform.INHERIT_TRANSFORM, self, MOAITransform.TRANSFORM_TRAIT)
    
    self:setScissorRect(self.scissorRect)
end

function ScrollView:addItem(item)
    return self.container:addChild(item)
end

function ScrollView:removeItem(item)
    return self.container:removeChild(item)
end

function ScrollView:removeAllItems()
    self.container:removeChildren()
end


function ScrollView:setItems(...)
    items = {...}

    for i, item in ipairs(items) do
        self.container:addChild(item)
    end
end

---
-- Disables scroll in certain directions if container size is too small
function ScrollView:updatePossibleDirections()
    local xMin, yMin, zMin, xMax, yMax, zMax = self:getBounds()
    local xPossible = xMax - xMin < self.contentRect[3] - self.contentRect[1]
    local yPossible = yMax - yMin < self.contentRect[4] - self.contentRect[2]

    if self.direction == ScrollView.HORIZONTAL then
        self.xScrollEnabled = xPossible
        self.yScrollEnabled = false
    end
    
    if self.direction == ScrollView.VERTICAL then
        self.xScrollEnabled = false
        self.yScrollEnabled = yPossible
    end

    if self.direction == ScrollView.BOTH then
        self.xScrollEnabled = xPossible
        self.yScrollEnabled = yPossible
    end
end

function ScrollView:onTouchDown(e)
    if not self:inside(e.wx, e.wy, 0) then
        return
    end
    
    if self._curScrollThread then
        self._curScrollThread:stop()
        self._curScrollThread = nil
    end

    self._touchIdx = e.idx
    self._initialLocX = e.wx
    self._initialLocY = e.wy
    self._lastTouchX = e.wx
    self._lastTouchY = e.wy
    self._trackingTouch = false
    self._discardCancelEvent = false
    self._velocityAccumulator:clear()
    self._velocityAccumulator:startTracking()
end

function ScrollView:onTouchMove(e)
    if self._touchIdx ~= e.idx then
        return
    end

    if self._trackingTouch then
        self:applyOffset(e.wx - self._lastTouchX, e.wy - self._lastTouchY)
        self._velocityAccumulator:add(e.wx - self._lastTouchX, e.wy - self._lastTouchY)
        e:stop()
    end
    self._lastTouchX = e.wx
    self._lastTouchY = e.wy

    if not self._trackingTouch and 
    (self.xScrollEnabled and abs(e.wx - self._initialLocX) > self.touchDistanceToSlide or
     self.yScrollEnabled and abs(e.wy - self._initialLocY) > self.touchDistanceToSlide) then
        self._trackingTouch = true
        scrollEventData.x = self._scrollPositionX
        scrollEventData.y = self._scrollPositionY
        self:dispatchEvent(UIEvent.SCROLL_BEGIN, scrollEventData)

        self._discardCancelEvent = true
        InputMgr:dispatchCancelEvent(e, self)
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
    if self._touchIdx ~= e.idx or self._discardCancelEvent then
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

--- Check scroll bounds after applying dx and dy offsets
-- Return values:
-- bool: x bounds are ok, 
-- bool: y bounds are ok, 
-- number: x correction offset, 
-- number: y correction offset
function ScrollView:checkBounds(dx, dy)
    dx = dx or 0
    dy = dy or 0
    
    local newX = -(self._scrollPositionX + dx)
    local newY = -(self._scrollPositionY + dy)
    local xMin, yMin, zMin, xMax, yMax, zMax = self:getBounds()
    local xMinContent, yMinContent, xMaxContent, yMaxContent = unpack(self.contentRect)

    -- this prevents scrolling when content area is smaller than scroll view size
    if xMaxContent - xMinContent < xMax - xMin then
        xMinContent = xMaxContent - xMax + xMin
    end
    if yMaxContent - yMinContent < yMax - yMin then
        yMinContent = yMaxContent - yMax + yMin
    end

    local xOffset, yOffset = 0, 0
    if newX + xMax > xMaxContent then
        xOffset = newX + xMax - xMaxContent
    end
    if newX + xMin < xMinContent then
        xOffset = newX + xMin - xMinContent
    end

    if newY + yMin < yMinContent then
        yOffset = newY + yMin - yMinContent
    end
    if newY + yMax > yMaxContent then
        yOffset = newY + yMax - yMaxContent
    end

    return xOffset == 0, yOffset == 0, xOffset, yOffset
end

function ScrollView:applyOffset(dx, dy)
    local xOk, yOk, xOffset, yOffset = self:checkBounds(dx, dy)
    if self._touchIdx and not xOk then 
        dx = self.rubberEffect and attenuation(abs(xOffset)) * dx or (dx + xOffset)
    end
    if self._touchIdx and not yOk then 
        dy = self.rubberEffect and attenuation(abs(yOffset)) * dy or (dy + yOffset)
    end

    if self.xScrollEnabled then
        self._scrollPositionX = self._scrollPositionX + dx
    end
    if self.yScrollEnabled then
        self._scrollPositionY = self._scrollPositionY + dy
    end
    
    self:updatePosition()
end

function ScrollView:updatePosition()
    self.container:setLoc(self._scrollPositionX, self._scrollPositionY)
    scrollEventData.x = self._scrollPositionX
    scrollEventData.y = self._scrollPositionY
    self:dispatchEvent(UIEvent.SCROLL_POSITION_CHANGED, scrollEventData)
end

-- cache anim curves
local animCurveX = MOAIAnimCurve.new()
local animCurveY = MOAIAnimCurve.new()
animCurveX:reserveKeys(2)
animCurveY:reserveKeys(2)

function ScrollView:scrollToPosition(newX, newY, time, ease, unbounded)
    newX = newX or self._scrollPositionX
    newY = newY or self._scrollPositionY
    time = time or (1 / 6 + 1 / 600 * distance(newX, newY, self._scrollPositionX, self._scrollPositionY))
    ease = ease or MOAIEaseType.SOFT_EASE_IN
    if self._curScrollThread then
        self._curScrollThread:stop()
        self._curScrollThread = nil
    end

    if time == 0 then
        self._scrollPositionX = newX
        self._scrollPositionY = newY
        if not unbounded then
            local yOk, xOk, offsetX, offsetY = self:checkBounds()
            self._scrollPositionX = newX + offsetX
            self._scrollPositionY = newY + offsetY
        end
        self:updatePosition()
        return
    end

    local animLength = ceil(MOAISim.timeToFrames(time))
    animCurveX:setKey(1, 0, self._scrollPositionX, ease)
    animCurveX:setKey(2, animLength, newX)

    animCurveY:setKey(1, 0, self._scrollPositionY, ease)
    animCurveY:setKey(2, animLength, newY)

    local thread = MOAICoroutine.new()
    thread:run(
        function ()
            local xOk, yOk, offsetX, offsetY
            for f = 1, animLength do
                self._scrollPositionX = animCurveX:getValueAtTime(f)
                self._scrollPositionY = animCurveY:getValueAtTime(f)
                if not unbounded then
                    local yOk, xOk, offsetX, offsetY = self:checkBounds()
                    self._scrollPositionX = self._scrollPositionX + offsetX
                    self._scrollPositionY = self._scrollPositionY + offsetY
                end
                self:updatePosition()
                coroutine.yield()
            end
            scrollEventData.x = self._scrollPositionX
            scrollEventData.y = self._scrollPositionY
            self:dispatchEvent(UIEvent.SCROLL_END, scrollEventData)
        end
    )
    self._curScrollThread = thread
end

function ScrollView:startKineticScroll()
    local velX, velY = self._velocityAccumulator:average()
    self._currentVelocityX = clamp(velX, -self.maxVelocity, self.maxVelocity)
    self._currentVelocityY = clamp(velY, -self.maxVelocity, self.maxVelocity)
    if self._curScrollThread then
        self._curScrollThread:stop()
    end

    self._curScrollThread = Executors.callLoop(function()
        local dx = self._currentVelocityX
        local dy = self._currentVelocityY
        local xOk, yOk, xOffset, yOffset = self:checkBounds(dx, dy)
        
        local xReadyToRubber = not self.xScrollEnabled or (abs(dx) < self.minVelocity)
        local yReadyToRubber = not self.yScrollEnabled or (abs(dy) < self.minVelocity)

        if xReadyToRubber and yReadyToRubber then
            self:startRubberEffect()
            return true
        end

        if self.xScrollEnabled then
            self._currentVelocityX = self.damping * dx
            if not xOk then
                local att = attenuation(abs(xOffset))
                self._currentVelocityX = self._currentVelocityX * att
                self._scrollPositionX = self._scrollPositionX + (self.rubberEffect and self._currentVelocityX or (dx + xOffset))
            else
                self._scrollPositionX = self._scrollPositionX + dx
            end
        end

        if self.yScrollEnabled then
            self._currentVelocityY = self.damping * dy
            if not yOk then
                local att = attenuation(abs(yOffset))
                self._currentVelocityY = self._currentVelocityY * att
                self._scrollPositionY = self._scrollPositionY + (self.rubberEffect and self._currentVelocityY or (dy + yOffset))
            else
                self._scrollPositionY = self._scrollPositionY + dy
            end
        end

        self:updatePosition()
    end)
end

function ScrollView:startRubberEffect()
    local xOk, yOk, xOffset, yOffset = self:checkBounds()
    
    local x = self._scrollPositionX + xOffset
    local y = self._scrollPositionY + yOffset

    if not self.rubberEffect then
        self._scrollPositionX = x
        self._scrollPositionY = y
        self:updatePosition()
        return
    end    

    if self.snapDistanceX then
        local velOffset = self._currentVelocityX / (1 - self.damping)
        x = round(x + velOffset - self.snapOffsetX, self.snapDistanceX) + self.snapOffsetX
        xOk = false
    end
    if self.snapDistanceY then
        local velOffset = self._currentVelocityY / (1 - self.damping)
        y = round(y + velOffset - self.snapOffsetY, self.snapDistanceY) + self.snapOffsetY
        yOk = false
    end

    if (not xOk and self.xScrollEnabled) or (not yOk and self.yScrollEnabled) then
        self:scrollToPosition(x, y, nil, nil, true)
    end
end

return ScrollView