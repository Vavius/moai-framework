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

------------------------------------------------------
--
local Sprite = Display.Sprite
local Label = Display.Label

function TestScene:init(params)
    Scene.init(self, params)
    
    local backTransition = params and params.backTransition or SceneTransitions.crossfade()
    
    self:addEventListener(Event.ENTER, self.onEnter, self)
    self:addEventListener(Event.EXIT, self.onExit, self)
    
    local layer = Display.Layer()
    layer:setTouchEnabled(true)
    self:addLayer(layer)
    
    -- texture packer test 
    local bg = Display.Sprite("finish_iphone5.png")
    bg:setLayer(layer)
    
    local items = {}
    local y = 200
    local yDec = 40
    for i = 1, 5 do
        local button = Gui.Button {
            normalSprite = Sprite("btn_buy.png"),
            activeSprite = Sprite("btn_buy_active.png"),
            label = Label("slideBottom", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
            onClick = function() 
                SceneMgr:popScene({transition = backTransition})
            end,
            loc = {0, y, 0},
        }
        y = y - yDec
        items[#items + 1] = button
    end

    local menu = Gui.ScrollView {
        size = {200, 200}, 
        contentRect = {-200, -100, 200, 100}, 
        clipRect = {-100, -100, 100, 100},
        direction = Gui.ScrollView.HORIZONTAL,
        autoSize = false,
        layer = layer,
        items = {
            Gui.ScrollView {
                size = {200, 300}, 
                contentRect = {-100, -200, 100, 200}, 
                -- clipRect = {-100, -200, 100, 200},
                direction = Gui.ScrollView.VERTICAL,
                autoSize = false,
                layer = layer,
                items = items, 
            }
        },

        -- snapDistanceY = 40,
        -- minVelocity = 1,
    }
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