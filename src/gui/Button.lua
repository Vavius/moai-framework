--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local Group = require("display.Group")
local Event = require("event.Event")
local UIEvent = require("gui.UIEvent")
local UIObjectBase = require("gui.UIObjectBase")
local ButtonAnimations = require("gui.ButtonAnimations")

local Button = class(UIObjectBase, Group)

---
-- Example usage
-- Button can be initialized in declarative way

-- Button {
--     normalSprite = Sprite("normal.png"),
--     selectedSprite = Sprite("selected.png"),
--     disabledSprite = Sprite("disabled.png"),
--     label = Label("Button", 200, 100, "Verdana.ttf", 24),
--     onClick = function(e) print("click") end,
--     animations = {ButtonAnimations.Bounce()},
--     toggle = false,
-- }


Button.propertyOrder = {
    label = 2,
    layer = 3,
}

function Button:init(params)
    Group.init(self)
    UIObjectBase.init(self, params)
    
    if table.empty(self.animations) then
        self:addAnimation(ButtonAnimations.Change())
    end

    self:initEventListeners()
    self:setEnabled(true)
    self:setSelected(false)

    assert(self.normalSprite, "Button: normal sprite is not set")

    local w, h = self.normalSprite:getDims()
    self:setSize(w, h)
end


function Button:initEventListeners()
    self:addEventListener(Event.TOUCH_DOWN, self.onTouchDown, self)
    self:addEventListener(Event.TOUCH_UP, self.onTouchUp, self)
    self:addEventListener(Event.TOUCH_MOVE, self.onTouchMove, self)
    self:addEventListener(Event.TOUCH_CANCEL, self.onTouchCancel, self)
end

---
-- 
-- 
function Button:setNormalSprite(sprite)
    if self.normalSprite then
        self:removeChild(self.normalSprite)
        self.normalSprite = nil
    end

    if sprite then
        self:addChild(sprite)
        self.normalSprite = sprite
    end
end

---
-- 
-- 
function Button:setSelectedSprite(sprite)
    if self.selectedSprite then
        self:removeChild(self.selectedSprite)
        self.selectedSprite = nil
    end

    if sprite then
        self:addChild(sprite)
        self.selectedSprite = sprite
    end
end

---
-- 
-- 
function Button:setDisabledSprite(sprite)
    if self.disabledSprite then
        self:removeChild(self.disabledSprite)
        self.disabledSprite = nil
    end

    if sprite then
        self:addChild(sprite)
        self.disabledSprite = sprite
    end
end

---
-- 
-- 
function Button:setLabel(label)
    if self.label then
        self:removeChild(self.label)
        self.label = nil
    end

    if label then
        self:addChild(label)
        self.label = label
    end
end

---
--
--
function Button:setEnabled(value)
    self.enabled = value

    if value then
        self:dispatchEvent(UIEvent.ENABLE)
    else
        self:dispatchEvent(UIEvent.DISABLE)
    end
end

---
-- 
-- 
function Button:setSelected(value)
    self.selected = value

    if value then
        self:dispatchEvent(UIEvent.DOWN)
    else
        self:dispatchEvent(UIEvent.UP)
    end
end

---
-- 
-- 
function Button:setAnimations(...)
    local animList = {...}

    if self.animations then
        for animCalss, anim in pairs(self.animations) do
            anim:setButton(nil)
        end
    end

    self.animations = {}

    for i, anim in ipairs(animList) do
        self:addAnimation(anim)
    end
end

---
-- 
-- 
function Button:addAnimation(animation)
    -- use animation class as key
    -- so there are only one animation of each type
    
    if not self.animations then
        self.animations = {}
    end

    if self.animations[animation] then
        self:removeAnimation(animation)
    end

    animation:setButton(self)
    self.animations[animation.__class] = animation
end

---
-- 
-- 
function Button:removeAnimation(animation)
    self.animations[animation]:setButton(nil)
end

---
-- 
-- 
function Button:onTouchDown(event)
    event:stop()

    if self._touchDownIdx ~= nil then
        return
    end
    self._touchDownIdx = event.idx
    
    self:setSelected(true)
end

---
-- 
-- 
function Button:onTouchMove(event)
    event:stop()
    
    if self._touchDownIdx ~= event.idx then
        return
    end
    
    local inside = self:inside(event.wx, event.wy, 0)

    if inside ~= self.selected then
        self:setSelected(inside)
    end

    if inside then return end
    
    self:dispatchEvent(UIEvent.CANCEL)
end

---
-- 
-- 
function Button:onTouchUp(event)
    event:stop()

    if self._touchDownIdx ~= event.idx then
        return
    end
    self._touchDownIdx = nil
    
    self:setSelected(false)

    if not self:inside(event.wx, event.wy, 0) then
        return
    end

    if self.toggle then
        self:setEnabled(not self.enabled)
        if self.onToggle then
            self.onToggle(self.enabled)
        end
    else
        self:dispatchEvent(UIEvent.CLICK)
        if self.onClick then
            self.onClick()
        end
    end
end

---
-- 
-- 
function Button:onTouchCancel(event)
    event:stop()
    
    if self._touchDownIdx ~= event.idx then
        return
    end
    self._touchDownIdx = nil
    
    if not self.toggle then
        self:dispatchEvent(UIEvent.CANCEL)
    end
end



return Button