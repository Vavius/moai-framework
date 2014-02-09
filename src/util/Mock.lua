--------------------------------------------------------------------------------
-- Mock.lua
-- 
-- 
--------------------------------------------------------------------------------

---
-- Mock object that allow calling and indexing any values without exceptions
-- Returns itself on indexing, so calls can be chained
-- Can print accesses for debug purposes

local Mock = {}
setmetatable(Mock, Mock)


function Mock:__call(name, verbose)
    local mock = {}
    mock.name = name or "mock"
    mock.verbose = verbose or false

    mock.__index = self.__index
    mock.__newindex = self.__newindex
    mock.__call = function(m) return m end
    setmetatable(mock, mock)
    return mock
end

function Mock:__index(key)
    if self.verbose then
        print(self.name .. ": " .. tostring(key))
    end
    return self
end

function Mock:__newindex(key, value)
    if self.verbose then
        print(self.name .. ' assigned: ' .. tostring(value) .. ' to ' .. tostring(key))
    end
end


return Mock