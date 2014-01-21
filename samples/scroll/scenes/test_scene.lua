--------------------------------------------------------------------------------
-- Scene file example
-- 
-- 
--------------------------------------------------------------------------------

local Scene = require("core.Scene")
local Event = require("core.Event")
local SceneTransitions = require("core.SceneTransitions")

-- all scenes should be derived from Scene class
local TestScene = class(Scene)

-- local variables
local layer

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Scene Callbacks
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
function TestScene:init(params)
    Scene.init(self, params)

    self:addEventListener(Event.ENTER, self.onEnter, self)
    self:addEventListener(Event.EXIT, self.onExit, self)
    self:addEventListener(Event.DID_EXIT, self.onDidExit, self)
    self:addEventListener(Event.WILL_ENTER, self.onWillEnter, self)

    self:createScene()
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



-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- User code
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local Sprite = Display.Sprite
local Label = Display.Label

function TestScene:createScene()
    local layer = Display.Layer()
    layer:setTouchEnabled(true)
    self:addLayer(layer)

    -- texture packer test 
    local bg = Sprite("game_bg_iphone5.png")
    bg:setLayer(layer)

    local items = {}
    local y = 200
    local yDec = 40
    for i = 1, 10 do
        local button = Gui.Button {
            normalSprite = Sprite("btn_buy.png"),
            selectedSprite = Sprite("btn_buy_active.png"),
            label = Label("slideBottom", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
            onClick = function()
                SceneMgr:pushScene("scenes.scroll_nest", {transition = SceneTransitions.crossfade()})
            end,
            loc = {0, y, 0},
        }
        y = y - yDec
        items[#items + 1] = button
    end

    local menu = Gui.ScrollView { 
        size = {200, 300}, 
        items = items, 
        contentRect = {-100, -200, 100, 200}, 
        clipRect = {-100, -150, 100, 150}, 
        direction = Gui.ScrollView.VERTICAL, 
        layer = layer, 
        -- snapDistanceY = 40, 
        -- minVelocity = 1, 
    }
end




return TestScene