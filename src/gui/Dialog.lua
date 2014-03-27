--------------------------------------------------------------------------------
-- 
-- 
-- 
--------------------------------------------------------------------------------

local Scene = require("core.Scene")
local Event = require("core.Event")
local Executors = require("core.Executors")
local InputMgr = require("core.InputMgr")
local UIEvent = require("gui.UIEvent")
local DialogAnimations = require("gui.DialogAnimations")
local ShaderCache = require("core.ShaderCache")

local Dialog = class(Scene)
Dialog.isOverlay = true

---
-- 
-- 
function Dialog:init(params)
    Scene.init(self, params)

    self.openAnimation = DialogAnimations["fadeScaleIn"] { ease = MOAIEaseType.BACK_EASE_IN }
    self.closeAnimation = DialogAnimations["fadeScaleOut"] { ease = MOAIEaseType.BACK_EASE_OUT, scale = {1.5, 1.5} }
    self.modal = true
    self.desaturate = true
end

---
-- Open dialog. It will be rendered as overlay
-- @param table params  {animation = "string"}
function Dialog:open(params)
    local animation = params and params.animation or self.openAnimation

    local onTransitionFinished = function()
        if self.modal then
            SceneMgr:setFocus(self)
        end
        self:dispatchEvent(Event.ENTER, params)
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

        if self.desaturate then
            local desaturate = ShaderCache.desaturate
            local scene = SceneMgr.currentScene
            for i, layer in ipairs(scene.layers) do
                layer:setShader(desaturate)
            end

            desaturate:setSaturation(1)
            desaturate:moveSaturation(-0.8, 1)
        end
    else
        onTransitionFinished()
    end
    
    SceneMgr:addOverlay(self)
    Scene.open(self, params)
    Scene.start(self, params)
    self:dispatchEvent(Event.WILL_ENTER, params)
end

---
-- Close dialog
-- @param table params  {animation = "string"}
function Dialog:close(params)
    local animation = params and params.animation or self.closeAnimation

    local onTransitionFinished = function()
        if self.modal then
            SceneMgr:removeFocus(self)
        end

        self:dispatchEvent(Event.DID_EXIT, params)
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

        if self.desaturate then
            Executors.callOnce(function()
                local desaturate = ShaderCache.desaturate
                local scene = SceneMgr.currentScene
                MOAICoroutine.blockOnAction(desaturate:moveSaturation(0.8, 0.3))
                for i, layer in ipairs(scene.layers) do
                    layer:setShader(nil)
                end
            end)
        end
    else
        onTransitionFinished()
    end

    Scene.close(self, params)
    self:dispatchEvent(Event.EXIT, params)
end


return Dialog
