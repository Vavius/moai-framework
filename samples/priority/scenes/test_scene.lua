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

    local grp = Display.Group(layer, 0, 0)
    local menu = Display.Group(nil, 0, 0)

    grp:addChild(menu)

    local y = -200
    for i = 1, 10 do
        local btn = Gui.Button {
            normalSprite = Sprite("btn_buy.png"),
            activeSprite = Sprite("btn_buy_active.png"),
            label = Label(tostring(i), nil, nil, "Verdana.ttf", 18, {0,0,0,1}),
            onClick = function(btn) 
                print("")
                print("Priority normal: ", btn.normalSprite:getPriority())
                print("Priority active: ", btn.activeSprite:getPriority())
                print("Priority label: ", btn.label:getPriority())
                print("")
            end,
            loc = {0, y, 0},
        }
        y = y + 40
        menu:addChild(btn)
    end

    grp:setPriority(100)
end




return TestScene