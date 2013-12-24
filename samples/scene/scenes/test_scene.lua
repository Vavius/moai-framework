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

    layer = Display.Layer()
    self:addChild(layer)

    layer:setTouchEnabled(true)

    -- texture packer test 
    local bg = Display.Sprite("game_bg_iphone5.png")
    local btn = Display.Sprite("btn_facebook.png")
    -- local btn2 = Display:sprite("btn_start.png")

    bg:setLayer(layer)

    btn.eventDispatcher = EventDispatcher()
    btn.eventDispatcher:addEventListener(Event.TOUCH_UP, function(e) 
        print("touch up")
    end)

    btn.eventDispatcher:addEventListener(Event.TOUCH_DOWN, function(e) 
        print("touch down")
    end)
    
    btn.eventDispatcher:addEventListener(Event.TOUCH_CANCEL, function(e) 
        print("touch cancel")
    end)
    
    btn.eventDispatcher:addEventListener(Event.TOUCH_MOVE, function(e) 
        print("touch move")
    end)


    local grp = Display.Group(layer, 0, 0)
    grp:addChild(btn)
    btn:setLoc(100, 0)

    grp:seekRot(0, 0, 90, 2)
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