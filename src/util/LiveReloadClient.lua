--------------------------------------------------------------------------------
-- Just import this script to enable live reload of code and assets on device
-- 
-- 
--------------------------------------------------------------------------------

local ResourceMgr = require("core.ResourceMgr")
local SceneMgr = require("core.SceneMgr")

if MOAIEnvironment.documentDirectory then
    package.path = MOAIEnvironment.documentDirectory .. '/live_update/?.lua;' .. package.path

    -- resource directories are sorted in descending order by scale threshold 
    -- here we increase threshold slightly to force lookup of live_update assets before the main assets
    local newResources = {}
    for k, v in pairs(ResourceMgr.resourceDirectories) do
        local path = MOAIEnvironment.documentDirectory .. "/live_update/" .. v.path 
        newResources[#newResources+1] = {path, v.scale, v.threshold + 0.001}
    end

    for k, v in pairs(newResources) do
        ResourceMgr:addResourceDirectory(unpack(v))
    end
end


local socket = require "socket"
local ltn12 = require "ltn12"
local PORT = 8970
local MAGIC_HEADER = "MOAI_REMOTE:"
local PING = MAGIC_HEADER.."PING"
local PONG = MAGIC_HEADER.."PONG:"
local UPDATE = MAGIC_HEADER.."UPDATE:"
local UPDATE_SUCCESS = MAGIC_HEADER.."UPDATE_SUCCESS:"
local RESTART = MAGIC_HEADER.."RESTART"

local IMAGE_EXTENSIONS = {[".jpg"] = true, [".png"] = true}
local LUA_EXTENSIONS = {[".lua"] = true}

local function try(func)
    return xpcall(func, 
        function(err) 
            print(err) 
            print(debug.traceback()) 
        end)
end

---
-- If reloaded file is currently running scene - then restart it
-- Files with scenes determined by their directory
local function restartScene(requirePath)
    local scenesDir = "scenes."
    if requirePath:sub(1, #scenesDir) == scenesDir and SceneMgr.currentScene.name == requirePath then
        try(function() SceneMgr:replaceScene(requirePath) end)
    end
end

---
-- Reload texture in the cache
-- All props and decks will be updated automatically
local function reloadTexture(texturePath)
    local filepath = ResourceMgr:getResourceFilePath(texturePath)
    local texture = ResourceMgr.textureCache[filepath]
    if texture then
        texture:load(filepath)
    end
end

local function updateFile(relPath)
    local requirePath
    local ext = string.sub(relPath, -4)
    if LUA_EXTENSIONS[ext] then
        requirePath = string.gsub(relPath, ".lua", "")
        requirePath = string.gsub(requirePath, "/", ".")
        package.loaded[requirePath] = nil

        -- check if file is parsable
        local status = try(function() require(requirePath) end)

        if status then
            restartScene(requirePath)
        end
    end

    if IMAGE_EXTENSIONS[ext] then
        reloadTexture(relPath)
    end
end

local function getPath(str,sep)
    sep = sep or'/'
    return str:match(".*"..sep)
end

local M = {}

local function runnerFunc()
    local sock = assert(socket.udp())
    assert(sock:setsockname("*", PORT))
    assert(sock:settimeout(0))
    M.socket = sock
    while true do
        local data, ip, port = sock:receivefrom()
        if data then
            if data:sub(1, #PING) == PING then
                local name = MOAIEnvironment.devName or "unknown device"
                sock:sendto(PONG .. name, ip, port)

            elseif data:sub(1, #UPDATE) == UPDATE then
                local dataPort = data:sub(#UPDATE + 1, #UPDATE + 5)
                local localPath = data:sub(#UPDATE + 6)

                local dataSock = assert(socket.tcp())
                assert(dataSock:connect(ip, tonumber(dataPort)))
                local source = socket.source("until-closed", dataSock)
                MOAIFileSystem.affirmPath(MOAIEnvironment.documentDirectory .. "/live_update/" .. (getPath(localPath) or ""))
                local archivePath = MOAIEnvironment.documentDirectory.."/live_update/" .. localPath
                local file = assert(io.open(archivePath, "wb"))
                local sink = ltn12.sink.file(file)
                while ltn12.pump.step(source, sink) do
                    coroutine.yield()
                end

                dataSock:close()

                updateFile(localPath)
            end
        end
        coroutine.yield()
    end
    M.socket = nil
    sock:close()
end

function M:start()
    local runner = MOAICoroutine.new()
    runner:run(runnerFunc)
    self.runner = runner
end

function M:stop()
    if self.runner then
        self.runner:stop()
        self.runner = nil
        if self.socket then
            self.socket:close()
            self.socket = nil
        end
    end
end

function M:updateFile(localPath)
    updateFile(localPath)
end

return M

