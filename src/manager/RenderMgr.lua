----------------------------------------------------------------------------------------------------
-- @type RenderMgr
--
-- This is a singleton class that manages the rendering object.
----------------------------------------------------------------------------------------------------

local RenderMgr = {}

function RenderMgr:initialize()
    self.renderTable = {}
    MOAIRenderMgr.setRenderTable(self.renderTable)
end


function RenderMgr:addChild(render)
    table.insertIfAbsent(self.renderTable, render)
end


function RenderMgr:removeChild(render)
    table.removeElement(self.renderTable, render)
end

return RenderMgr