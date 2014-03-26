#!/usr/bin/env python

import re, sys, os
import argparse
import json
import shutil, subprocess

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
local LocalizedString = LocalizedString or function(s) return s end

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

spriteFuncLua = """Sprite ("%(fileName)s", %(width)s, %(height)s)"""

spriteTableLua = """Sprite { 
    name = "%(name)s", fileName = "%(fileName)s", %(loc)s 
    width = %(width)s, height = %(height)s 
}"""

buttonLua = """Button { 
    name = "%(name)s", %(loc)s 
%(children)s
}"""

groupLua = """Group {
    name = "%(name)s", %(loc)s 
    children = {
%(children)s
    }
}"""

labelLua = """Label { 
    name = "%(name)s",
    string = %(text)s, %(color)s
    width = %(width)s, height = %(height)s, %(loc)s 
    fontName = "%(fontName)s", fontSize = %(fontSize)s,
    alignment = { %(alignment)s, MOAITextBox.LEFT_JUSTIFY },
}"""

def makeLoc(x, y):
    if x != 0 or y != 0:
        return 'loc = {%f, %f, 0},' % (x, y)
    return ''

def makeColor(r, g, b, a):
    if r != 1 or g != 1 or b != 1 or a != 1:
        return 'color = {%f, %f, %f, %f},' % (r, g, b, a)
    return ''

class LayoutParser(object):
    indentLevel = 3
    offsetX = 0
    offsetY = 0
    fontPathCache = {}

    """LayoutParser"""
    def __init__(self, params):
        super(LayoutParser, self).__init__()
        self.params = params

    def reindent(self, s):
        s = s.split('\n')
        s = [(self.indentLevel * 4 * ' ') + line for line in s]
        s = '\n'.join(s)
        return s

    def affirmFont(self, fontName):
        fontPathCache = self.fontPathCache
        if not fontName in fontPathCache:
            selfDir = os.path.dirname(os.path.realpath(__file__))
            path = subprocess.check_output([os.path.join(selfDir, 'fontfinder'), fontName], stderr=subprocess.STDOUT).strip()
            if path:
                fontPathCache[fontName] = path
                outDir = self.params['fontsFolder']
                if not os.path.isdir(outDir):
                    os.makedirs(outDir)
                shutil.copyfile(path, os.path.join(outDir, os.path.basename(path)))
            else:
                print("Font not found in system", fontName)
                print("Aborting...")
                exit(0)
        
        fileName = os.path.basename(fontPathCache[fontName])
        return os.path.join(self.params['fontPrefix'], fileName)

    def generateLayout(self, layout, outName):
        self.screenWidth = layout['size'][0]
        self.screenHeight = layout['size'][1]

        children = ""
        for obj in layout['layout']:
            children = children + self.makeObject(obj) + ','
            if obj != layout['layout'][-1]:
                children = children + '\n'

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
            'loc' : makeLoc(x, y),
            'width' : width,
            'height' : height,
        }

        if data['name'] == '' and data['loc'] == '':
            return self.reindent(spriteFuncLua % data)
        else:
            return self.reindent(spriteTableLua % data)

    def makeGroup(self, obj):
        initialIndent = self.indentLevel
        initialOffsetX = self.offsetX
        initialOffsetY = self.offsetY

        x, y, width, height = self.transformCoords(obj['pos'][0], obj['pos'][1], obj['size'][0], obj['size'][1])
        data = {
            'name' : obj['name'],
            'loc' : makeLoc(x, y),
        }

        children = ""
        self.indentLevel = 2
        self.offsetX = self.offsetX + x
        self.offsetY = self.offsetY + y

        for child in obj['children']:
            children = children + self.makeObject(child) + ','
            if child != obj['children'][-1]:
                children = children + '\n'

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

        ry = float(self.params['targetHeight']) / self.screenHeight
        x, y, width, height = self.transformCoords(obj['pos'][0], obj['pos'][1], obj['size'][0], obj['size'][1])
        text = ('l' in obj['flags']) and 'LocalizedString([=[%s]=])' or '[=[%s]=]'
        r, g, b, a = obj['color']

        data = {
            'name' : obj['name'],
            'text' : text % obj['text'],
            'fontName' : self.affirmFont(obj['fontName']),
            'fontSize' : obj['fontSize'] * ry,
            'alignment' : alignmentTypes[obj['alignment']],
            'loc' : makeLoc(x, y),
            'width' : width,
            'height' : height,
            'color' : makeColor(r, g, b, a),
        }

        return self.reindent(labelLua % data)

    def makeButton(self, obj):
        initialIndent = self.indentLevel
        initialOffsetX = self.offsetX
        initialOffsetY = self.offsetY

        x, y, width, height = self.transformCoords(obj['pos'][0], obj['pos'][1], obj['size'][0], obj['size'][1])
        data = {
            'name' : obj['name'],
            'loc' : makeLoc(x, y),
        }

        flags = obj['flags']
        
        file_base, file_ext = os.path.splitext(obj['normalSprite']['fileName'])

        self.indentLevel = 1
        self.offsetX = self.offsetX + x
        self.offsetY = self.offsetY + y
        
        normalSprite = self.makeObject(obj['normalSprite']).split('\n')
        normalSprite[0] = normalSprite[0].lstrip()
        buttonChildren = "    normalSprite = %s," % '\n'.join(normalSprite)

        if 'activeSprite' in obj:
            activeSprite = self.makeObject(obj['activeSprite']).split('\n')
            activeSprite[0] = activeSprite[0].lstrip()
            buttonChildren = buttonChildren + "\n    activeSprite = %s," % '\n'.join(activeSprite)
        elif 'a' in flags:
            aDict = obj['normalSprite'].copy()
            aDict['fileName'] = file_base + '_active' + file_ext
            activeSprite = self.makeObject(aDict).split('\n')
            activeSprite[0] = activeSprite[0].lstrip()
            buttonChildren = buttonChildren + "\n    activeSprite = %s," % '\n'.join(activeSprite)

        if 'disabledSprite' in obj:
            disabledSprite = self.makeObject(obj['disabledSprite']).split('\n')
            disabledSprite[0] = disabledSprite[0].lstrip()
            buttonChildren = buttonChildren + "\n    disabledSprite = %s," % '\n'.join(disabledSprite)
        elif 'd' in flags:
            dDict = obj['normalSprite'].copy()
            dDict['fileName'] = file_base + '_disabled' + file_ext
            disabledSprite = self.makeObject(dDict).split('\n')
            disabledSprite[0] = disabledSprite[0].lstrip()
            buttonChildren = buttonChildren + "\n    disabledSprite = %s," % '\n'.join(disabledSprite)

        if 'label' in obj:
            label = self.makeObject(obj['label']).split('\n')
            label[0] = label[0].lstrip()
            buttonChildren = buttonChildren + "\n    label = %s," % '\n'.join(label)

        children = ''
        if 'children' in obj:
            self.indentLevel = 2
            for child in obj['children']:
                children = children + self.makeObject(child) + ','
                if child != obj['children'][-1]:
                    children = children + '\n'
            self.indentLevel = 1
            buttonChildren = buttonChildren + """\n    children = {
%s
}""" % children

        data['children'] = buttonChildren

        self.indentLevel = initialIndent
        self.offsetX = initialOffsetX
        self.offsetY = initialOffsetY

        return self.reindent(buttonLua % data)

    def transformCoords(self, x, y, width, height):
        x = float(x) - 0.5 * self.screenWidth
        y = 0.5 * self.screenHeight - float(y)
        rx = float(self.params['targetWidth']) / self.screenWidth
        ry = float(self.params['targetHeight']) / self.screenHeight
        return -self.offsetX + self.params['offsetX'] + rx * x, -self.offsetY + self.params['offsetY'] + ry * y, rx * float(width), ry * float(height)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--out', help="Output file", default = "out.lua")
    parser.add_argument('-width', help="Target width (in virtual coordinates)", default = 320, type=int)
    parser.add_argument('-height', help="Target height (in virtual coordinates)", default = 568, type=int)
    parser.add_argument('-ox', '--offsetX', help="Canvas offset X (in virtual coordinates)", default = 0, type=int)
    parser.add_argument('-oy', '--offsetY', help="Canvas offset Y (in virtual coordinates)", default = 0, type=int)
    parser.add_argument('-fonts', help="Output path for font files from layout", default = "fonts", type=str)
    parser.add_argument('-fp', '--fontPrefix', help="Font path prefix that will be added to included font file names", default = "", type=str)
    parser.add_argument('file', help="Input file")
    args = parser.parse_args()

    params = {
        "offsetX" : args.offsetX,
        "offsetY" : args.offsetY,
        "targetWidth" : args.width,
        "targetHeight" : args.height,
        "fontsFolder" : args.fonts,
        "fontPrefix" : args.fontPrefix,
    }

    layoutParser = LayoutParser(params)
    with open(args.file) as f_in:
        layoutDict = json.load(f_in)
        with open(args.out, "w") as f:
            f.write(layoutParser.generateLayout(layoutDict, args.out))


if __name__ == '__main__':
    main()