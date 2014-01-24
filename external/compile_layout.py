#!/usr/bin/env python

import re, sys, os
import argparse

screenWidth = 640
screenHeight = 1136
ratio = 0.5

def transformCoords(x, y, width, height):
    x = float(x) - 0.5 * screenWidth
    y = 0.5 * screenHeight - float(y)
    return ratio * x, ratio * y, ratio * int(width), ratio * int(height)

def makeButton(name, file_name, x, y, width, height, flags): 
    sprites = 'normalSprite = Sprite("%s", %d, %d),' % (file_name, width, height)
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
                width = %d, height = %d, 
            },
    """ % (name, file_name, x, y, width, height)
    return output



lua_guiclass_factory = {
    'btn' : makeButton,
    'spr' : makeSprite,
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

local function layout(layer)
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
    layout = []
    with open(file_in, "rU") as f:
        for line in f:
            layout.append(line.strip())

    # screenWidth, screenHeight = layout.pop(0).split(',')
    if screenWidth < 480:
        ratio = 1
    elif screenWidth < 1100:
        ratio = 0.5
    else:
        ratio = 0.25

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
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--out', help="Output file", default = "out.lua")
    parser.add_argument('file', help="Input file")
    args = parser.parse_args()

    output_file = args.out
    input_file = args.file

    generateLayout(input_file, output_file)

if __name__ == '__main__':
    main()