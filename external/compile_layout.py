#!/usr/bin/env python

import re, sys, os
import argparse

screenWidth = 640
screenHeight = 1136
targetWidth = 320
targetHeight = 568
offsetX = 0
offsetY = 0


def transformCoords(x, y, width, height):
    global screenWidth, screenHeight, targetWidth, targetHeight, offsetX, offsetY

    x = float(x) - 0.5 * screenWidth
    y = 0.5 * screenHeight - float(y)
    rx = float(targetWidth) / screenWidth
    ry = float(targetHeight) / screenHeight
    return offsetX + rx * x, offsetY + ry * y, rx * float(width), ry * float(height)

def makeButton(name, file_name, x, y, width, height, flags): 
    sprites = 'normalSprite = Sprite("%s", %f, %f),' % (file_name, width, height)
    file_base, file_ext = os.path.splitext(file_name)
    if 'a' in flags: 
        sprites = sprites + '\n' + 16*' ' + 'activeSprite = Sprite("%s"),' % (file_base + '_active' + file_ext)
    
    if 'd' in flags:
        sprites = sprites + '\n' + 16*' ' + 'disabledSprite = Sprite("%s"),' % (file_base + '_disabled' + file_ext)

    output = """
            Button { 
                name = "%s", 
                %s
                loc = {%f, %f, 0}, 
            },
    """ % (name, sprites, x, y)
    return output

def makeSprite(name, file_name, x, y, width, height, flags): 
    output = """
            Sprite { 
                name = "%s", fileName = "%s", 
                loc = {%f, %f, 0}, 
                width = %f, height = %f, 
            },
    """ % (name, file_name, x, y, width, height)
    return output

def makeLabel(name, file_name, x, y, width, height, flags): 
    output = """
            Label { 
                name = "%s", 
                loc = {%f, %f, 0}, 
                width = %f, height = %f, 
                fontName = fontName,
                fontSize = fontSize,
            },
    """ % (name, x, y, width, height)
    return output




lua_guiclass_factory = {
    'btn' : makeButton,
    'spr' : makeSprite,
    'lbl' : makeLabel,
}


# Lua code template
body = """--------------------------------------------------------------------------------
-- %s
-- 
-- WARNING: Do not edit! 
-- This file is auto generated, all changes will be lost.
--------------------------------------------------------------------------------
local Button = Gui.Button
local Sprite = Display.Sprite
local Group = Display.Group

local function layout(layer, fontName, fontSize)
    local group = Group {
        layer = layer,
        children = {
            %s
        }
    }

    return group
end

return layout
"""

def generateLayout(file_in, file_out):
    global screenWidth, screenHeight

    layout = []
    with open(file_in, "rU") as f:
        for line in f:
            layout.append(line.strip())

    screenWidth, screenHeight = [int(x) for x in layout.pop(0).split(',')]

    group = ""
    for line in layout:
        params = line.split(',')
        file_name = params[2]
        x = params[3]
        y = params[4]
        z = params[5]
        name = params[6]
        obj_class = params[7]
        obj_flags = params[8]
        width = params[9]
        height = params[10]
        x, y, width, height = transformCoords(x, y, width, height)
        group = group + lua_guiclass_factory[obj_class](name, file_name, x, y, width, height, obj_flags)

    output = body % (file_out, group)
    
    with open(file_out, "w") as f:
        f.write(output)

def main():
    global screenWidth, screenHeight, offsetX, offsetY, targetWidth, targetHeight

    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--out', help="Output file", default = "out.lua")
    parser.add_argument('-width', help="Target width (in virtual coordinates)", default = 320, type=int)
    parser.add_argument('-height', help="Target height (in virtual coordinates)", default = 568, type=int)
    parser.add_argument('-ox', '--offsetX', help="Canvas offset X (in virtual coordinates)", default = 0, type=int)
    parser.add_argument('-oy', '--offsetY', help="Canvas offset Y (in virtual coordinates)", default = 0, type=int)
    parser.add_argument('file', help="Input file")
    args = parser.parse_args()

    output_file = args.out
    input_file = args.file
    offsetX = args.offsetX
    offsetY = args.offsetY
    targetWidth = args.width
    targetHeight = args.height

    generateLayout(input_file, output_file)

if __name__ == '__main__':
    main()