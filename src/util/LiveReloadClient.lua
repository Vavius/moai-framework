--------------------------------------------------------------------------------
-- Just import this script to enable live reload of code and assets on device
-- 
-- 
--------------------------------------------------------------------------------

local ResourceMgr = require("core.ResourceMgr")
local SceneMgr = require("core.SceneMgr")
local Runtime = require("core.Runtime")
local Scene = require("core.Scene")

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

local LIVE_UPDATE_PATH = string.pathJoin(MOAIEnvironment.documentDirectory, "live_update")

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
    -- if SceneMgr.currentScene.name == requirePath then
    try(function() SceneMgr:replaceScene(SceneMgr.currentScene.name) end)
    -- end
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
        local status, result = try(function() require(requirePath) end)

        -- if status and result and result.isScene then
        if status then
            restartScene(requirePath)
        end
        -- end
    end

    if IMAGE_EXTENSIONS[ext] then
        reloadTexture(relPath)
    end
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
                local archivePath = string.pathJoin(LIVE_UPDATE_PATH, localPath)
                MOAIFileSystem.affirmPath(string.pathDir(archivePath))
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

---
-- @param table sourcePath Custom src path
function M:init(sourcePath)
    if MOAIEnvironment.documentDirectory then
        local paths = ""
        for i, v in ipairs(sourcePath) do
            paths = paths .. string.pathJoin(LIVE_UPDATE_PATH, v) .. ';'
        end
        package.path = paths .. package.path

        -- resource directories are sorted in descending order by scale threshold 
        -- here we increase threshold slightly to force lookup of live_update assets before the main assets
        local newResources = {}
        for k, v in pairs(ResourceMgr.resourceDirectories) do
            local path = string.pathJoin(LIVE_UPDATE_PATH, v.path) 
            newResources[#newResources+1] = {path, v.scale, v.threshold + 0.001}
        end

        for k, v in pairs(newResources) do
            ResourceMgr:addResourceDirectory(unpack(v))
        end
    end

    local function onSessionEnd()
        self:stop()
    end

    local function onSessionStart()
        self:start()
    end

    Runtime:addEventListener(Event.SESSION_START, onSessionStart)
    Runtime:addEventListener(Event.SESSION_END, onSessionEnd)

    self:start()
end

function M:start()
    if not self.runner then
        local runner = MOAICoroutine.new()
        runner:run(runnerFunc)
        self.runner = runner
    end
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

