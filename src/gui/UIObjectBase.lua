--------------------------------------------------------------------------------
-- 
-- 
-- 
--------------------------------------------------------------------------------

local EventDispatcher = require("event.EventDispatcher")
local PropertyUtils = require("util.PropertyUtils")

local UIObjectBase = class(EventDispatcher)

UIObjectBase.propertyOrder = {}

function UIObjectBase:init(params)
    EventDispatcher.init(self)
    self:setProperties(params)
end

function UIObjectBase:setProperties(params)
    local nextStep = 1
    
    while not table.empty(params) do
        local nextStepParams = {}
        local step = nextStep
        nextStep = 99999999
        for name, value in pairs(params) do
            local order = self.propertyOrder[name]
            if order and order > step then
                nextStepParams[name] = value
                nextStep = order < nextStep and order or nextStep
            else
                PropertyUtils.setProperty(self, name, value, true)
            end
        end

        params = table.dup(nextStepParams)
    end
end

return UIObjectBase