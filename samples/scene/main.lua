package.path = "../../src/?.lua;" .. package.path 

require("include")

App:openWindow("Scene test")

ResourceMgr:addResourceDirectory("sd")
ResourceMgr:addResourceDirectory("hd", 2, 1.5)

ResourceMgr:cacheSpriteFrames("bg.lua")
ResourceMgr:cacheSpriteFrames("interface.lua")

MOAIDebugLines.showStyle(MOAIDebugLines.PROP_MODEL_BOUNDS)
MOAIDebugLines.showStyle(MOAIDebugLines.PROP_MODEL_BOUNDS)

SceneMgr:pushScene("scenes.test_scene")

