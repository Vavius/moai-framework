--------------------------------------------------------------------------------
-- result.lua
-- 
-- WARNING: Do not edit! 
-- This file is auto generated, all changes will be lost.
--------------------------------------------------------------------------------
local Button = Gui.Button
local Sprite = Display.Sprite
local Group = Display.Group
local Label = Display.Label

local function layout(layer)
    local group = Group {
        layer = layer,
        children = {
            Button { 
                name = "btnLevel", loc = {27.000000, 40.500000, 0}, 
                normalSprite = Sprite ("point.png", 19.5, 10.5),
                activeSprite = Sprite ("play_btn.png", 12.5, 15.0),
            },
            Button { 
                name = "level", loc = {-78.750000, 84.750000, 0}, 
                normalSprite = Sprite ("point.png", 19.5, 10.5),
                activeSprite = Sprite ("point_active.png", 19.5, 10.5),
                disabledSprite = Sprite ("point_disabled.png", 19.5, 10.5),
            },
        }
    }

    return group
end

return layout
