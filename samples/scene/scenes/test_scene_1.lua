--------------------------------------------------------------------------------
-- Scene file example
--
--
--------------------------------------------------------------------------------

local Scene = require("scene.Scene")
local Event = require("event.Event")

-- all scenes should be derived from Scene
local TestScene = class(Scene)

-- local variables
local layer

function TestScene:init()
    Scene.init(self)

    self:addEventListener(Event.ENTER, self.onEnter, self)
    self:addEventListener(Event.EXIT, self.onExit, self)

    layer = MOAILayer.new()
    layer:setViewport(Display.viewport)
    self:addChild(layer)



    -- texture packer test 
    local bg = Display:sprite("game_bg_iphone5.png")
    bg:setLayer(layer)

    local btn = Display:sprite("btn_facebook.png")
    local btn2 = Display:sprite("btn_start.png")

    local grp = Display:group(layer, 0, 0)
    grp:addChild(btn)
    grp:addChild(btn2)
    btn:setLoc(100, 0)

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