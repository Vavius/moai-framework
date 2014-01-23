--------------------------------------------------------------------------------
-- 
-- 
-- 
--------------------------------------------------------------------------------

local Layer = require("core.Layer")
local Event = require("core.Event")
local Executors = require("core.Executors")
local UIEvent = require("gui.UIEvent")
local InputMgr = require("core.InputMgr")
local DialogAnimations = require("gui.DialogAnimations")

local Dialog = class(Layer)

---
-- 
-- 
function Dialog:init(scene, modal)
    Layer.init(self)
    assert(scene, "Dialog scene not specified")

    self.scene = scene
    self.modal = modal
end

---
-- 
-- 
function Dialog:open(animation)
    self.scene:addLayer(self)

    local onTransitionFinished = function()
        if self.modal then
            InputMgr:setFocusLayer(self)
        end
        self:dispatchEvent(UIEvent.DIALOG_OPEN)
    end

    if type(animation) then
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
    self:dispatchEvent(UIEvent.DIALOG_WILL_OPEN)
end


---
-- 
-- 
function Dialog:close(animation)
    local onTransitionFinished = function()
        if self.modal then
            InputMgr:setFocusLayer(self)
        end
        self.scene:removeLayer(self)
        self:dispatchEvent(UIEvent.DIALOG_DID_CLOSE)
    end

    if type(animation) then
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
    self:dispatchEvent(UIEvent.DIALOG_CLOSE)
end


return Dialog
