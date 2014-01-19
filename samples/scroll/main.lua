package.path = "../../src/?.lua;" .. package.path 

require("include")

App:openWindow("Scene test")

ResourceMgr:addResourceDirectory("sd")
ResourceMgr:addResourceDirectory("hd", 2, 1.5)

ResourceMgr:cacheSpriteFrames("bg.lua")
ResourceMgr:cacheSpriteFrames("interface.lua")

MOAIGfxDevice.getFrameBuffer():setClearColor(1,1,1,1)

SceneMgr:pushScene("scenes.test_scene")