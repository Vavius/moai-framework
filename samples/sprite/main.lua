package.path = "../../src/?.lua;" .. package.path 

require("include")

Display:openWindow("Moo")

ResourceMgr:addResourceDirectory("sd")
ResourceMgr:addResourceDirectory("hd", 2, 1.5)

local layer = Display.Layer()

local logo = Display.Sprite("dc_logo.png")
logo:setLoc(0, 0)
logo:setLayer(layer)

RenderMgr:addChild(layer)

-- texture packer test 
ResourceMgr:cacheSpriteFrames("interface.lua")
local btn = Display.Sprite("btn_facebook.png")
local btn2 = Display.Sprite("btn_start.png")


local grp = Display.Group(layer, 0, 0)
grp:addChild(btn)

btn:setLoc(100, 0)

grp:seekRot(0, 0, 90, 2)