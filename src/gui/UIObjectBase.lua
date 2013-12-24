--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local EventDispatcher = require("event.EventDispatcher")
local PropertyUtils = require("util.PropertyUtils")

local UIObjectBase = class(EventDispatcher)

function UIObjectBase:init(params)
    EventDispatcher.init(self)

    self:setProperties(params)
end

function UIObjectBase:setProperties(params)
    if params then
        PropertyUtils.setProperties(self, params, true)
    end
end

return UIObjectBase