--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local Group = require("core.Group")
local Event = require("core.Event")
local Executors = require("core.Executors")
local UIEvent = require("gui.UIEvent")
local UIObjectBase = require("gui.UIObjectBase")

local Dialog = class(UIObjectBase, Group)

local Group = Display.Group

---
-- Example usage
-- 
-- dialog = Dialog {
--      background = Sprite("bg.png"),
--      size = {400, 300},
--      children = { child1, child2 },
--      
-- }
-- dialog:open()

---
-- 
-- 
function Dialog:init(params)
    Group.init(self)
    UIObjectBase.init(self, params)

    self:initEventListeners()
end


---
-- 
-- 
function Dialog:setChildren(...)
    local children = {...}

    for i, child in ipairs(children) do
        self:addChild(child)
    end
end


---
-- Set the background
-- Background is just a child at index 1
function Dialog:setBackground(bg)
    self.background = bg
    self:addChild(background, 1)

    local w, h = self:getDims()
    if w and h then
        self:setSize(w, h)
    end
end


---
-- 
-- 
function Dialog:setSize(width, height)
    Group.setSize(self, width, height)

    if self.background and self.background:getDims() then
        local bgW, bgH = self.background:getDims()
        if bgW and bgH then
            self.background:setScl(width / bgW, height / bgH)
        end
    end
end

---
-- 
-- 
function Dialog:initEventListeners()

end


---
-- 
-- 
function Dialog:open(animation)
    self:setVisible(true)

    local onTransitionFinished = function()
        self:dispatchEvent(UIEvent.DIALOG_OPEN)
    end

    if animation then
        Executors.callOnce(
        function()
            animation(self)
            onTransitionFinished()
        end
        )
    else
        onTransitionFinished()
    end
    self:dispatchEvent(UIEvent.DIALOG_WILL_OPEN)
end


---
-- 
-- 
function Dialog:close(animation)
    local onTransitionFinished = function()
        self:setVisible(false)
        self:dispatchEvent(UIEvent.DIALOG_DID_CLOSE)
    end

    if animation then
        Executors.callOnce(
        function()
            animation(self)
            onTransitionFinished()
        end
        )
    else
        onTransitionFinished()
    end
    self:dispatchEvent(UIEvent.DIALOG_CLOSE)
end



