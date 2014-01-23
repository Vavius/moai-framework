--------------------------------------------------------------------------------
-- Scene file example
-- 
-- 
--------------------------------------------------------------------------------

local Scene = require("core.Scene")
local Event = require("core.Event")

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
local Button = Gui.Button
local ScrollView = Gui.ScrollView

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
                SceneMgr:pushScene("scenes.scroll_nest", {transition = "crossfade"})
            end,
            loc = {0, y, 0},
        }
        y = y - yDec
        items[#items + 1] = button
    end

    local menu = Gui.ScrollView { 
        size = {200, 300}, 
        items = items, 
        contentRect = {-200, -300, 200, 300}, 
        clipRect = {-100, -150, 100, 150}, 
        direction = Gui.ScrollView.BOTH, 
        layer = layer, 
    }
    menu:seekLoc(100, 100, 0, 2)

    local topBtn = Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("Top", nil, nil, "Verdana.ttf", 18, {0, 0, 0, 1}),
        layer = layer,
        loc = {-120, -220},
        scl = {0.5, 0.5},
        onClick = function(e) menu:scrollTo(ScrollView.TOP) end,
    }

    local bottomBtn = Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("Bottom", nil, nil, "Verdana.ttf", 18, {0, 0, 0, 1}),
        layer = layer,
        loc = {-40, -220},
        scl = {0.5, 0.5},
        onClick = function(e) menu:scrollTo(ScrollView.BOTTOM) end,
    }

    local leftBtn = Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("Left", nil, nil, "Verdana.ttf", 18, {0, 0, 0, 1}),
        layer = layer,
        loc = {40, -220},
        scl = {0.5, 0.5},
        onClick = function(e) menu:scrollTo(ScrollView.LEFT) end,
    }

    local rightBtn = Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("Right", nil, nil, "Verdana.ttf", 18, {0, 0, 0, 1}),
        layer = layer,
        loc = {120, -220},
        scl = {0.5, 0.5},
        onClick = function(e) menu:scrollTo(ScrollView.RIGHT) end,
    }
end




return TestScene