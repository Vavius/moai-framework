--------------------------------------------------------------------------------
-- 
-- 
-- 
--------------------------------------------------------------------------------

local Group = require("display.Group")
local Event = require("event.Event")
local UIEvent = require("gui.UIEvent")
local UIObjectBase = require("gui.UIObjectBase")
local Executors = require("util.Executors")

local ScrollView = class(UIObjectBase, Group)


---
-- Example usage
-- 
-- scrollView = ScrollView {
--      size = {400, 300}, 
--      clipRect = {x1, y1, x2, y2}, 
--      items = { child1, child2 }, 
--      direction = scrollView.HORIZONTAL, -- VERTICAL, BOTH
--      
-- }
-- 
-- scrollView:addItem() -- add item to scroll container