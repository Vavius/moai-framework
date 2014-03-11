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
-- @param   width       (option) image width. This will modify prop scale
-- @param   height      (option) image height. This will modify prop scale
-- 
-- @overload
-- @param   table       Properties
function Display.Sprite(fileName, width, height)
    local properties
    if type(fileName) == 'table' then
        properties = fileName
        fileName = properties['fileName']
        width = properties['width']
        height = properties['height']

        properties['fileName'] = nil
        properties['width'] = nil
        properties['height'] = nil
    end
    
    local deck
    if string.endswith(fileName, ".9.png") then
        deck = ResourceMgr:getNineImageDeck(fileName)
    else
        deck = ResourceMgr:getImageDeck(fileName)
    end
    if not deck then
        local atlas = ResourceMgr:getAtlasName(fileName)
        assert(atlas, "Image not found: " .. fileName)
        deck = ResourceMgr:getAtlasDeck(atlas)
    end
    
    local sprite = MOAIProp.new()
    sprite:setDeck(deck)
    sprite.deck = deck
    sprite:setIndexByName(fileName)

    local w, h = sprite:getDims()
    local sx = width and width / w or 1
    local sy = height and height / h or 1
    sprite:setScl(sx, sy, 1)
    
    if properties then
        PropertyUtils.setProperties(sprite, properties, true)
    end

    return sprite
end

---
-- Create Text Box
-- @param str string
-- @param width
-- @param height
-- @param fontName
-- @param fontSize
-- @param color
--
-- @overload
-- @param   table       Properties
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
    Display.fitLabelText(label)
    return label
end

---
-- Try to use smaller font size until all glyphs are visible. 
-- 
-- @param label
-- @param decrement     font size decrement
-- @return nil
function Display.fitLabelText(label, decrement)
    decrement = decrement or label.contentScale or 2

    label:forceUpdate()

    local style = label:getStyle()
    local fontSize = style:getSize()
    while label:more() and fontSize > 0 do
        fontSize = fontSize - decrement
        style:setSize(fontSize)
        label:forceUpdate()
    end
end

---
-- Create group
-- @param layer
-- @param width
-- @param height
--
-- @override
-- @param table Properties
function Display.Group(layer, width, height)
    local properties
    if layer and not layer.__class then
        properties = layer
        layer = properties['layer']
        width = properties['width']
        height = properties['height']

        properties['layer'] = nil
        properties['width'] = nil
        properties['height'] = nil
    end

    local group = Group(layer, width, height)
    if properties then
        if properties.children then
            group:setChildren(unpack(properties.children))
            properties.children = nil
        end
        PropertyUtils.setProperties(group, properties, true)
    end
    return group
end

-- Expose other factory methods
Display.Layer = Layer


return Display