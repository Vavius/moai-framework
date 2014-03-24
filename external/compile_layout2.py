#!/usr/bin/env python

import re, sys, os
import argparse
import json


# Lua code templates
bodyLua = """--------------------------------------------------------------------------------
-- %s
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
%s
        }
    }

    return group
end

return layout
"""

spriteLua = """Sprite { 
    name = "%(name)s", fileName = "%(fileName)s", loc = {%(x)f, %(y)f, 0}, 
    width = "%(width)s", height = "%(height)s" 
}"""

buttonLua = """Button { 
    name = "%(name)s", loc = {%(x)f, %(y)f, 0}, 
    %(children)s
}"""

groupLua = """Group {
    name = "%(name)s", loc = {%(x)f, %(y)f, 0}, 
    children = {
%(children)s
    }
}"""

labelLua = """Label { 
    name = "%(name)s",
    loc = {%(x)f, %(y)f, 0}, width = "%(width)s", height = "%(height)s",
    fontName = "%(fontName)s", fontSize = "%(fontSize)s",
    alignment = { %(alignment)s, MOAITextBox.LEFT_JUSTIFY },
}"""

class LayoutParser(object):
    indentLevel = 3
    offsetX = 0
    offsetY = 0

    """LayoutParser"""
    def __init__(self, params):
        super(LayoutParser, self).__init__()
        self.params = params

    def reindent(self, s):
        s = s.split('\n')
        s = [(self.indentLevel * 4 * ' ') + line for line in s]
        s = '\n'.join(s)
        return s

    def generateLayout(self, layout, outName):
        self.screenWidth = layout['size'][0]
        self.screenHeight = layout['size'][1]

        children = ""
        for obj in layout['layout']:
            children = children + self.makeObject(obj) + ',\n'

        return bodyLua % (outName, children)

    def makeObject(self, obj):
        factory = {
            "spr" : self.makeSprite,
            "grp" : self.makeGroup,
            "lbl" : self.makeLabel,
            "btn" : self.makeButton
        }
        return factory[obj['type']](obj)

    def makeSprite(self, obj):
        x, y, width, height = self.transformCoords(obj['pos'][0], obj['pos'][1], obj['size'][0], obj['size'][1])
        data = {
            'name' : obj['name'],
            'fileName' : obj['fileName'],
            'x' : x,
            'y' : y,
            'width' : width,
            'height' : height,
        }

        return self.reindent(spriteLua % data)

    def makeGroup(self, obj):
        initialIndent = self.indentLevel
        initialOffsetX = self.offsetX
        initialOffsetY = self.offsetY

        x, y, width, height = self.transformCoords(obj['pos'][0], obj['pos'][1], 0, 0)
        data = {
            'name' : obj['name'],
            'x' : x,
            'y' : y,
        }

        children = ""
        self.indentLevel = 2
        self.offsetX = self.offsetX + data['x']
        self.offsetY = self.offsetY + data['y']

        for child in obj['children']:
            children = children + self.makeObject(child) + ',\n'

        self.indentLevel = initialIndent
        self.offsetX = initialOffsetX
        self.offsetY = initialOffsetY

        data['children'] = children
        return self.reindent(groupLua % data)

    def makeLabel(self, obj):
        alignmentTypes = {
            "center" : "MOAITextBox.CENTER_JUSTIFY",
            "left" : "MOAITextBox.LEFT_JUSTIFY",
            "right" : "MOAITextBox.RIGHT_JUSTIFY",
        }

        x, y, width, height = self.transformCoords(obj['pos'][0], obj['pos'][1], obj['size'][0], obj['size'][1])
        data = {
            'name' : obj['name'],
            'text' : obj['text'],
            'fontName' : obj['fontName'],
            'fontSize' : obj['fontSize'],
            'alignment' : alignmentTypes[obj['alignment']],
            'x' : x,
            'y' : y,
            'width' : width,
            'height' : height,
        }
        return self.reindent(labelLua % data)

    def makeButton(self, obj):
        initialIndent = self.indentLevel
        initialOffsetX = self.offsetX
        initialOffsetY = self.offsetY

        x, y, width, height = self.transformCoords(obj['pos'][0], obj['pos'][1], 0, 0)
        data = {
            'name' : obj['name'],
            'x' : x,
            'y' : y,
        }

        flags = obj['flags']
        normalSprite = self.makeObject(obj['normalSprite'])

        file_base, file_ext = os.path.splitext(obj['normalSprite'].fileName)

        buttonChildren = ""

        if activeSprite in obj:
            activeSprite = self.makeObject(obj['activeSprite'])
            buttonChildren = buttonChildren + "    activeSprite = %s,\n" % activeSprite
        elif "a" in flags:
            aDict = obj['activeSprite'].copy()
            aDict.fileName = file_base + "_active" + file_ext
            activeSprite = self.makeObject(aDict)
            buttonChildren = buttonChildren + "    activeSprite = %s,\n" % activeSprite

        if disabledSprite in obj:
            disabledSprite = self.makeObject(obj['disabledSprite'])
            buttonChildren = buttonChildren + "    disabledSprite = %s,\n" % disabledSprite
        elif "d" in flags:
            dDict = obj['disabledSprite'].copy()
            dDict.fileName = file_base + "_disabled" + file_ext
            disabledSprite = self.makeObject(dDict)
            buttonChildren = buttonChildren + "    disabledSprite = %s,\n" % disabledSprite

        if label in obj:
            label = self.makeObject(obj['label'])
            buttonChildren = buttonChildren + "    label = %s,\n" % label            

        data['children'] = buttonChildren

        self.indentLevel = initialIndent
        self.offsetX = initialOffsetX
        self.offsetY = initialOffsetY

        return buttonLua % data

    def transformCoords(self, x, y, width, height):
        x = float(x) - 0.5 * self.screenWidth
        y = 0.5 * self.screenHeight - float(y)
        rx = float(self.params['targetWidth']) / self.screenWidth
        ry = float(self.params['targetHeight']) / self.screenHeight
        return self.offsetX + self.params['offsetX'] + rx * x, self.offsetY + self.params['offsetY'] + ry * y, rx * float(width), ry * float(height)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--out', help="Output file", default = "out.lua")
    parser.add_argument('-width', help="Target width (in virtual coordinates)", default = 320, type=int)
    parser.add_argument('-height', help="Target height (in virtual coordinates)", default = 568, type=int)
    parser.add_argument('-ox', '--offsetX', help="Canvas offset X (in virtual coordinates)", default = 0, type=int)
    parser.add_argument('-oy', '--offsetY', help="Canvas offset Y (in virtual coordinates)", default = 0, type=int)
    parser.add_argument('file', help="Input file")
    args = parser.parse_args()

    params = {
        "offsetX" : args.offsetX,
        "offsetY" : args.offsetY,
        "targetWidth" : args.width,
        "targetHeight" : args.height
    }

    layoutParser = LayoutParser(params)
    with open(args.file) as f_in:
        layoutDict = json.load(f_in)
        with open(args.out, "w") as f:
            f.write(layoutParser.generateLayout(layoutDict, args.out))


    # generateLayout(input_file, output_file)

if __name__ == '__main__':
    main()