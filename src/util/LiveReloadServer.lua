--------------------------------------------------------------------------------
-- Live-reload implementation for MOAI SDK
-- Folder-watcher script + socket file transport
-- 
-- @author vavius <Vasiliy Yanushevich>
--------------------------------------------------------------------------------

local socket = require("socket")
local ltn12 = require "ltn12"

local DATA_SEND_TIMEOUT = 2
local PORT = 8970
local DATA_PORT_START = 51198
local MAGIC_HEADER = "MOAI_REMOTE:"
local PING = MAGIC_HEADER.."PING"
local PONG = MAGIC_HEADER.."PONG:"
local UPDATE = MAGIC_HEADER.."UPDATE:"
local UPDATE_SUCCESS = MAGIC_HEADER.."UPDATE_SUCCESS:"
local RESTART = MAGIC_HEADER.."RESTART"

local sendFile
local onFileChanged
local search

local dataPort = DATA_PORT_START


-- Listen and find available deployment devices on local network that run liveReload app
-- returns ip address
function search(timeout)
    local deviceList = {}
    timeout = timeout or 2
    local sock = assert(socket.udp())
    assert(sock:settimeout(timeout))
    assert(sock:setoption("broadcast", true))
    sock:sendto(PING, "255.255.255.255", PORT)
    while true do
        local data, ip, port = sock:receivefrom()
        if data then
            if data:sub(1, #PONG) == PONG then
                print("Pong", ip)
                deviceList[#deviceList + 1] = {ip = ip, name = data:sub(#PONG + 1)}
            end
        else
            break
        end
    end

    return deviceList
end

function sendFile(workingDir, path, address, attempts)
    attempts = attempts or 3
    if attempts < 0 then
        return
    end

    print('changed', path)

    local file = assert(io.open(workingDir .. path, "rb"))
    local cmdSock = assert(socket.udp())
    local dataSock = assert(socket.tcp())

    local tryCmd = socket.newtry(function() cmdSock:close() end)

    dataSock:settimeout(DATA_SEND_TIMEOUT)
    dataSock:bind("*", dataPort)
    assert(dataSock:listen(1))
    
    tryCmd(cmdSock:sendto(UPDATE .. dataPort .. path, address, PORT))

    local client, err = dataSock:accept()

    if client == nil then
        print('waiting for client failed: ' .. err)
        sendFile(path, attempts - 1)
    else
        dataPort = dataPort + 1
        local sink = socket.sink("close-when-done", client)
        local source = ltn12.source.file(file)
        if ltn12.pump.all(source, sink) then
            print('file sent successfully', path)
        else
            print('error sending file', path)
            sendFile(path, attempts - 1)
        end
    end
    
    cmdSock:close()
end

function onFileChanged(workingDir, path, address)
    sendFile(workingDir, path, address, 5)
end

-- Module
local M = {
    search = search,
    onFileChanged = onFileChanged,
}

return M