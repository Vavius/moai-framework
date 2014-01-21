--------------------------------------------------------------------------------
-- Dialog
-- 
-- 
--------------------------------------------------------------------------------

local Dialog = Gui.Dialog

-- forward declarations
local layer


local Dialog = class()


function Dialog:init(params)
    Scene.init(self, params)


end

function Dialog:createScene()
    local layer = Display.Layer()
    layer:setTouchEnabled(true)
    self:addLayer(layer)

end

-- called before transition
function Dialog:onWillEnter()
    
end

-- called after transition
function Dialog:onEnter()
    
end

-- called before transition
function Dialog:onExit()
    
end

-- called after transition
function Dialog:onDidExit()
    
end


return Dialog