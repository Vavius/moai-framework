--------------------------------------------------------------------------------
-- MainScene
-- 
-- 
--------------------------------------------------------------------------------

local Scene = require("core.Scene")
local SceneTransitions = require("core.SceneTransitions")

-- forward declarations
local layer



local MainScene = class(Scene)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Scene Callbacks
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
function MainScene:init(params)
    Scene.init(self, params)

    self:addEventListener(Event.ENTER, self.onEnter, self)
    self:addEventListener(Event.EXIT, self.onExit, self)
    self:addEventListener(Event.DID_EXIT, self.onDidExit, self)
    self:addEventListener(Event.WILL_ENTER, self.onWillEnter, self)

    self:createScene()
end

function MainScene:createScene()
    local layer = Display.Layer()
    layer:setTouchEnabled(true)
    self:addLayer(layer)

    local layout = require("scenes.main_layout")
    local group = layout(layer, self)
    self:addChild(group)
end

-- called before transition
function MainScene:onWillEnter()
    
end

-- called after transition
function MainScene:onEnter()
    
end

-- called before transition
function MainScene:onExit()
    
end

-- called after transition
function MainScene:onDidExit()
    
end




return MainScene