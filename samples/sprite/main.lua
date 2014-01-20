package.path = "../../src/?.lua;" .. package.path 

require("include")

App:openWindow("Moo")

ResourceMgr:addResourceDirectory("sd")
ResourceMgr:addResourceDirectory("hd", 2, 1.5)

local layer = Display.Layer()

local logo = Display.Sprite("dc_logo.png")
logo:setLoc(0, 0)
logo:setLayer(layer)

RenderMgr:addChild(layer)

-- texture packer test 
ResourceMgr:cacheSpriteFrames("interface.lua")
ResourceMgr:cacheSpriteFrames("nine.lua")
local btn = Display.Sprite("btn_facebook.png")
-- local btn2 = Display.Sprite("btn_start.png")
-- btn2:setFinalizer(function() print("finalizing") end)

local grp = Display.Group(layer, 0, 0)
grp:addChild(btn)
btn:setLoc(100, 0)

local nineDeck = ResourceMgr:getNineImageDeck("button_selected.9.png")
local nineProp = MOAIProp.new()
nineProp:setDeck(nineDeck)
layer:insertProp(nineProp)
nineProp:setLoc(0, -100, 0)
nineProp:setScl(12, 1, 1)


-- text, width, height, font, textSize
local label = Display.Label("Test Label", 200, 50, "Verdana.ttf", 32)
label:setLayer(layer)
label:setLoc(0, 100, 0)
