package.path = "../../src/?.lua;" .. package.path 

require("include")

App:openWindow("Text test")

ResourceMgr:addResourceDirectory("sd")
ResourceMgr:addResourceDirectory("hd", 2, 1.5)

MOAIDebugLines.setStyle(MOAIDebugLines.TEXT_BOX)
MOAIDebugLines.setStyle(MOAIDebugLines.TEXT_BOX_LAYOUT)

local layer = Display.Layer()

RenderMgr:addChild(layer)

-- text, width, height, font, textSize

local label = Display.Label("TestLabelOneTwo Ωåß∂œ", 200, 30, "Verdana.ttf", 24)
label:setLayer(layer)
label:setLoc(0, 100, 0)
label:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox. CENTER_JUSTIFY)

local img = label.font:getImage()
img:writePNG("glyphs.png")