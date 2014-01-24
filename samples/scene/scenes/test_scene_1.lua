--------------------------------------------------------------------------------
-- Scene file example
--
--
--------------------------------------------------------------------------------

local Scene = require("core.Scene")
local Event = require("core.Event")
local SceneTransitions = require("core.SceneTransitions")

-- all scenes should be derived from Scene
local TestScene = class(Scene)

-- local variables
local layer

function TestScene:init(params)
    Scene.init(self, params)
    
    local backTransition = params and params.backTransition or SceneTransitions.fadeOutIn()
    
    self:addEventListener(Event.ENTER, self.onEnter, self)
    self:addEventListener(Event.EXIT, self.onExit, self)
    
    local layer = Display.Layer()
    layer:setTouchEnabled(true)
    self:addLayer(layer)
    
    -- texture packer test 
    local bg = Display.Sprite("finish_iphone5.png")
    bg:setLayer(layer)
    
    local back = Gui.Button {
        normalSprite = Display.Sprite("btn_buy.png"),
        activeSprite = Display.Sprite("btn_buy_active.png"),
        label = Display.Label("Back", nil, nil, "Verdana.ttf", 24, {0,0,0,1}),
        onClick = function() 
            SceneMgr:popScene({transition = backTransition})
        end,
        layer = layer,
        loc = {0, 0},
    }
    back:seekScl(2, 2, 1, 2)
    
    -- grp:seekRot(0, 0, 90, 2)
end


function TestScene:onEnter()
    print("onEnter")
end


function TestScene:onWillEnter()
    print("onWillEnter")
end


function TestScene:onExit()
    print("onExit")
end


function TestScene:onDidExit()
    print("onDidExit")
end


return TestScene