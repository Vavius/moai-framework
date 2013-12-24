--------------------------------------------------------------------------------
-- Scene file example
--
--
--------------------------------------------------------------------------------

local Scene = require("scene.Scene")
local Event = require("event.Event")
local EventDispatcher = require("event.EventDispatcher")

-- all scenes should be derived from Scene
local TestScene = class(Scene)

-- local variables
local layer

function TestScene:init()
    Scene.init(self)

    self:addEventListener(Event.ENTER, self.onEnter, self)
    self:addEventListener(Event.EXIT, self.onExit, self)

    self:create()
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

function TestScene:create()

    layer = Display.Layer()
    layer:setTouchEnabled(true)
    self:addChild(layer)

    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    local bg = Display.Sprite("game_bg_iphone5.png")
    bg:setLayer(layer)


    local button = Gui.Button {
        normalSprite = Display.Sprite("btn_buy.png"),
        selectedSprite = Display.Sprite("btn_buy_active.png"),
        disabledSprite = Display.Sprite("btn_cancel_b.png"),
        onClick = function() print('onClick') end,
        layer = layer,
        toggle = true,
        -- loc = {},
    }


end

return TestScene