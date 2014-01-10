package.path = "../../src/?.lua;" .. package.path 

require("include")

local ObservableTable = require("util.ObservableTable")
local OnChange = ObservableTable.OnChange

local NewModel = ObservableTable()

function onChange(event)
    if event.data then 
        print(key, event.data.oldValue, event.data.newValue)
    end
end

NewModel:addEventListener(OnChange("tracked"), onChange)

NewModel:initTracking()

NewModel.property = 123
NewModel.tracked = 321

print(NewModel.property)
print(NewModel.tracked)