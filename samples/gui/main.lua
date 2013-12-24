package.path = "../../src/?.lua;" .. package.path 

require("include")

Display:openWindow("Scene test")

ResourceMgr:addResourceDirectory("sd")
ResourceMgr:addResourceDirectory("hd", 2, 1.5)

ResourceMgr:cacheSpriteFrames("bg.lua")
ResourceMgr:cacheSpriteFrames("interface.lua")

SceneMgr:pushScene("scenes.menu")

