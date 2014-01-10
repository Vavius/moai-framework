--------------------------------------------------------------------------------
-- Just import this script to enable live reload of code and assets on device
-- 
-- 
--------------------------------------------------------------------------------

local ResourceMgr = require("manager.ResourceMgr")


if MOAIEnvironment.documentDirectory then
    package.path = MOAIEnvironment.documentDirectory .. '/?.lua;' .. package.path
end

local socket = require "socket"
local ltn12 = require "ltn12"
local PORT = 8970
local MAGIC_HEADER = "MOAI_REMOTE:"
local PING = MAGIC_HEADER.."PING"
local PONG = MAGIC_HEADER.."PONG:"
local UPDATE = MAGIC_HEADER.."UPDATE:"
local UPDATE_SUCCESS = MAGIC_HEADER.."UPDATE_SUCCESS:"

local IMAGE_EXTENSIONS = {[".jpg"] = true, [".png"] = true}
local LUA_EXTENSIONS = {[".lua"] = true}


_G.liveReloadOverrides = {}

---
-- If reloaded file is currently running scene - then restart it
local function restartScene(luaFilePath)

end

---
-- Reload texture in the cache
-- Also assign it to all Decks that use this texture
local function reloadTexture(texturePath)

end

_require = require
function require(file)
    print('calling new require', file)
    if _G.liveReloadOverrides and _G.liveReloadOverrides[file] then
        return _require(_G.liveReloadOverrides[file])
    else
        return _require(file)
    end
end

local function table_deepCopy(src, dest)
    dest = dest or {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = table_deepCopy(v)
        else
            dest[k] = v
        end
    end
    return dest
end

local function table_removeAllElements(t)
    for k, v in pairs(t) do 
        t[k] = nil 
    end
end

local function reloadPackage(path, absPath)
    if package.loaded[path] then
        table_removeAllElements(package.loaded[path])
        local newTable = dofile(absPath)
        table_deepCopy(newTable, package.loaded[path])
    else
        _require(path)
    end
end

local function updateFile(fullPath, relPath)
    local requirePath
    local ext = string.sub(relPath, -4)
    if LUA_EXTENSIONS[ext] then
        requirePath = string.gsub(relPath, ".lua", "")
        requirePath = string.gsub(requirePath, "/", ".")
        _G.liveReloadOverrides[requirePath] = 'live_update.' .. requirePath
        reloadPackage(_G.liveReloadOverrides[requirePath], fullPath)
    end

end

local function getPath(str,sep)
    sep = sep or'/'
    return str:match(".*"..sep)
end

local function runnerFunc()
    local sock = assert(socket.udp())
    assert(sock:setsockname("*", PORT))
    assert(sock:settimeout(0))
    while true do
        local data, ip, port = sock:receivefrom()
        if data then
            if data:sub(1, #PING) == PING then
                local name = MOAIEnvironment.devModel or "unknown device"
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

                sock:sendTo(UPDATE_SUCCESS .. localPath, ip, port)

                local success, result = xpcall(function()
                        updateFile(archivePath, localPath)
                    end,
                    function(err) return debug.traceback(err) end)
                if not success then
                    print(result)
                end
            end
        end
        coroutine.yield()
    end
    sock:close()
end
