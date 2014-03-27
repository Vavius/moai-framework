--------------------------------------------------------------------------------
-- 
-- 
-- 
--------------------------------------------------------------------------------

local Scene = require("core.Scene")
local Event = require("core.Event")
local Executors = require("core.Executors")
local UIEvent = require("gui.UIEvent")
local InputMgr = require("core.InputMgr")
local DialogAnimations = require("gui.DialogAnimations")

local Dialog = class(Scene)
Dialog.isOverlay = true

---
-- 
-- 
function Dialog:init(params)
    Scene.init(self, params)

    self.openAnimation = params.openAnimation
    self.closeAnimation = params.closeAnimation
    self.modal = params.modal
end

---
-- Open dialog. It will be rendered as overlay
-- @param table params  {animation = "string"}
function Dialog:open(params)
    local animation = params.animation or self.openAnimation

    local onTransitionFinished = function()
        if self.modal then
            SceneMgr:setFocus(self)
        end
        self:dispatchEvent(Event.ENTER)
    end

    if type(animation) == "string" then
        animation = DialogAnimations[animation]()
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
    
    SceneMgr:addOverlay(self)
    Scene.open(self, params)
    Scene.start(self, params)
    self:dispatchEvent(Event.WILL_ENTER)
end

---
-- Close dialog
-- @param table params  {animation = "string"}
function Dialog:close(params)
    local animation = params.animation or self.closeAnimation

    local onTransitionFinished = function()
        if self.modal then
            SceneMgr:removeFocus(self)
        end
        SceneMgr:removeDialog(self)
        self:dispatchEvent(Event.DID_EXIT)
        SceneMgr:removeOverlay(self)
    end
    
    if type(animation) == "string" then
        animation = DialogAnimations[animation]()
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

    Scene.close(self, params)
    self:dispatchEvent(Event.EXIT)
end


return Dialog
