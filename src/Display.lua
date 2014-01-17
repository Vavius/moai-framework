--------------------------------------------------------------------------------
-- Set of global helper functions
-- 
-- This file is just an example that meant to be changed for specific project. 
-- It includes useful factory methods to create rigs. 
--------------------------------------------------------------------------------

local Display = {}

local Label = require("core.Label")
local Group = require("core.Group")
local Layer = require("core.Layer")
local PropertyUtils = require("util.PropertyUtils")

---
-- Create MOAIProp with deck set to proper texture file
-- @param   fileName    Texture name or sprite frame name
-- @param   width       (option) image width
-- @param   height      (option) image height
-- 
-- @overload
-- @param   table       Properties
function Display.Sprite(fileName, width, height)
    local properties
    if type(fileName) == 'table' then
        properties = fileName
        fileName = properties['name']
        width = properties['width']
        height = properties['height']

        properties['name'] = nil
        properties['width'] = nil
        properties['height'] = nil
    end
    
    local deck = ResourceMgr:getImageDeck(fileName, width, height)
    if not deck then
        local atlas = ResourceMgr:getAtlasName(fileName)
        assert(atlas, "Image not found: " .. fileName)
        deck = ResourceMgr:getAtlasDeck(atlas)
    end
    
    local sprite = MOAIProp.new()
    sprite:setDeck(deck)
    sprite.deck = deck
    sprite:setIndexByName(fileName)
    
    if properties then
        PropertyUtils.setProperties(sprite, properties, true)
    end

    return sprite
end

---
-- Create Text Box
-- @param str string
-- @param 
function Display.TextBox(str, width, height, fontName, fontSize, color)
    local properties
    if type(str) == 'table' then
        properties = str
        str = properties['text']
        width = properties['width']
        height = properties['height']
        fontName = properties['fontName']
        fontSize = properties['fontSize']
        color = properties['color']

        properties['text'] = nil
        properties['width'] = nil
        properties['height'] = nil
        properties['fontName'] = nil
        properties['fontSize'] = nil
        properties['color'] = nil
    end

    local label = Label(str, width, height, fontName, fontSize)
    if color then
        label:setColor(unpack(color))
    end

    if properties then
        PropertyUtils.setProperties(label, properties, true)
    end

    return label
end

---
-- Create Label. The only difference with text box that label cannot have pages. 
-- Label will try to use smaller font size until every glyph is fitted into bounds. 
-- @param str string
-- @param 
function Display.Label(str, width, height, fontName, fontSize, color)
    local label = Display.TextBox(str, width, height, fontName, fontSize, color)
    Display.FitLabelText(label)
    return label
end

---
-- Try to use smaller font size until all glyphs are visible. 
--  
-- @param label
-- @param decrement     font size decrement. By default is 2
-- @return nil
function Display.FitLabelText(label, decrement)
    decrement = decrement or 2

    label:forceUpdate()

    local style = label:getStyle()
    local fontSize = style:getSize()
    while label:more() and fontSize > 0 do
        fontSize = fontSize - decrement
        style:setSize(fontSize)
        label:forceUpdate()
    end
end

-- Expose other factory methods
Display.Group = Group
Display.Layer = Layer


return Display