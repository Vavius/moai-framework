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

    local menu = Display.Group(layer, 0, 0)

    local fadeIn = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("fadeIn", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.fadeIn(), 
                 backTransition = SceneTransitions.fadeIn()})
        end,
        loc = {0, -180, 0},
    }

    local fadeOutIn = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("fadeOutIn", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.fadeOutIn(),
                 backTransition = SceneTransitions.fadeOutIn()})
        end,
        loc = {0, -140, 0},
    }

    local crossfade = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("crossfade", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.crossfade(),
                 backTransition = SceneTransitions.crossfade()})
        end,
        loc = {0, -100, 0},
    }

    local fromRight = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("fromRight", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.fromRight(),
                 backTransition = SceneTransitions.fromLeft()})
        end,
        loc = {0, -60, 0},
    }

    local fromLeft = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("fromLeft", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.fromLeft(),
                 backTransition = SceneTransitions.fromRight()})
        end,
        loc = {0, -20, 0},
    }

    local fromTop = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("fromTop", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.fromTop(),
                 backTransition = SceneTransitions.fromBottom()})
        end,
        loc = {0, 20, 0},
    }

    local fromBottom = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("fromBottom", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.fromBottom(),
                 backTransition = SceneTransitions.fromTop()})
        end,
        loc = {0, 60, 0},
    }

    local slideRight = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("slideRight", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.slideRight(),
                 backTransition = SceneTransitions.slideLeft()})
        end,
        loc = {0, 100, 0},
    }

    local slideLeft = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("slideLeft", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.slideLeft(),
                 backTransition = SceneTransitions.slideRight()})
        end,
        loc = {0, 140, 0},
    }

    local slideTop = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("slideTop", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.slideTop(),
                 backTransition = SceneTransitions.slideBottom()})
        end,
        loc = {0, 180, 0},
    }

    local slideBottom = Gui.Button {
        normalSprite = Sprite("btn_buy.png"),
        selectedSprite = Sprite("btn_buy_active.png"),
        label = Label("slideBottom", nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
        onClick = function() 
            SceneMgr:pushScene("scenes.test_scene_1", 
                {transition = SceneTransitions.slideBottom(),
                 backTransition = SceneTransitions.slideTop()})
        end,
        loc = {0, 220, 0},
    }

    menu:addChild ( fadeIn )
    menu:addChild ( fadeOutIn )
    menu:addChild ( crossfade )
    menu:addChild ( fromRight )
    menu:addChild ( fromLeft )
    menu:addChild ( fromTop )
    menu:addChild ( fromBottom )
    menu:addChild ( slideRight )
    menu:addChild ( slideLeft )
    menu:addChild ( slideTop )
    menu:addChild ( slideBottom )
end




return TestScene