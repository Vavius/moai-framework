--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local PropertyUtils = require("util.PropertyUtils")
local UIEvent = require("gui.UIEvent")

local ButtonAnimations = {}

local AnimationBase = class()

---
--
--
function AnimationBase:init(params)
    if params then
        PropertyUtils.setProperties(self, params, false)
    end
end


function AnimationBase:setButton(button)
    if self.button then
        self:removeButton(button)
    end

    if not button then return end

    local addEventListener = function(event, callback)
        print(callback)
        if self[callback] then
            button:addEventListener(event, self[callback], self)
        end
    end

    self.button = button

    addEventListener ( UIEvent.DOWN,   "downAnimation" )
    addEventListener ( UIEvent.UP,     "upAnimation" )
    addEventListener ( UIEvent.CANCEL, "cancelAnimation" )
    addEventListener ( UIEvent.CLICK,  "clickAnimation" )
    addEventListener ( UIEvent.ENABLE,  "enabledAnimation" )
    addEventListener ( UIEvent.DISABLE, "disabledAnimation" )
end


function AnimationBase:removeButton(button)
    if not self.button then return end

    button:removeEventListener ( UIEvent.DOWN,      downAnimation, self )
    button:removeEventListener ( UIEvent.UP,        upAnimation, self )
    button:removeEventListener ( UIEvent.CANCEL,    cancelAnimation, self )
    button:removeEventListener ( UIEvent.CLICK,     clickAnimation, self )
    button:removeEventListener ( UIEvent.ENABLE,   enabledAnimation, self )
    button:removeEventListener ( UIEvent.DISABLE,  disabledAnimation, self )
    self.button = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Change = class(AnimationBase)
local Color  = class(AnimationBase)
local Scale  = class(AnimationBase)
local ToggleFlip = class(AnimationBase)

--- 
-- Toggle between normal, selected and disabled images
-- 
function Change:downAnimation(event)
    local button = event.target
    
    print("Down animation")

    if button.normalSprite then
        button.normalSprite:setVisible(false)
    end
    
    if button.selectedSprite then
        button.selectedSprite:setVisible(true)
    end

    if button.disabledSprite then
        button.disabledSprite:setVisible(false)
    end
end

function Change:upAnimation(event)
    local button = event.target

    if button.normalSprite then
        button.normalSprite:setVisible(true)
    end
    
    if button.selectedSprite then
        button.selectedSprite:setVisible(false)
    end

    if button.disabledSprite then
        button.disabledSprite:setVisible(false)
    end
end

function Change:disabledAnimation(event)
    local button = event.target

    if button.normalSprite then
        button.normalSprite:setVisible(false)
    end
    
    if button.selectedSprite then
        button.selectedSprite:setVisible(false)
    end

    if button.disabledSprite then
        button.disabledSprite:setVisible(true)
    end
end

function Change:enabledAnimation(event)
    self:upAnimation(event)
end

function Change:cancelAnimation(event)
    self:upAnimation(event)
end


---
-- Scale animation
-- 

-- Scale {
--     duration = 0.5,
--     selectedEaseType = MOAIEaseType.BOUNCE_IN,
--     normalEaseType = MOAIEaseType.BOUNCE_OUT,
--     selectedScale = 1.2,
--     normalDuration = 0.2,
-- }

Scale.defaultSelectedScale = 1.2
Scale.defaultNormalScale = 1
Scale.defaultDuration = 0.3


function Scale:downAnimation(event)
    local target = event.target

    if self.upAction then
        self.upAction:stop()
        self.upAction = nil
        target:setScl(self.normalScale or self.defaultNormalScale)
    end

    local scl = self.selectedScale or self.defaultSelectedScale
    local dur = self.selectedDuration or self.duration or self.defaultDuration
    self.downAction = target:seekScl(scl, scl, 1, dur, self.selectedEaseType or self.easeType)
end

function Scale:upAnimation(event)
    local target = event.target

    if self.downAction then
        self.downAction:stop()
        self.downAction = nil
        target:setScl(self.selectedScale or self.defaultSelectedScale)
    end

    local scl = self.normalScale or self.defaultNormalScale
    local dur = self.normalDuration or self.duration or self.defaultDuration
    self.upAction = target:seekScl(scl, scl, 1, dur, self.normalEaseType or self.easeType)
end

function Scale:cancelAnimation(event)
    self:upAnimation(event)
end

---
-- Color animation
-- 
-- Color.normalSpriteColor = {1, 1, 1, 1}
-- Color.selectedSpriteColor = {1, 1, 1, 1}
-- Color.disabledSpriteColor = {1, 1, 1, 1}

-- Color.normalTextColor = {0, 0, 0, 1}
-- Color.selectedTextColor = {0, 0, 0, 1}
-- Color.disabledTextColor = {0, 0, 0, 1}

function Color:downAnimation(event)

end



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
ButtonAnimations.Change = Change
ButtonAnimations.Bounce = Bounce
ButtonAnimations.Scale = Scale

return ButtonAnimations