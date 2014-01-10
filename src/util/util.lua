---------------------------------------------------------------------------------
-- Common utils and lua language extensions
-- 
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- @type class
--
-- This implements object-oriented style classes in Lua, including multiple inheritance.
-- This particular variation of class implementation copies the base class
-- functions into this class, which improves speed over other implementations
-- in return for slightly larger class tables. Please note that the inherited
-- class members are therefore cached and subsequent changes to a superclass
-- may not be reflected in your subclasses.
---------------------------------------------------------------------------------
class = {}
setmetatable(class, class)

---
-- This allows you to define a class by calling 'class' as a function,
-- specifying the superclasses as a list.  For example:
-- mynewclass = class(superclass1, superclass2)
-- @param ... Base class list.
-- @return class
function class:__call(...)
    local clazz = table.dup(self)
    local bases = {...}
    for i = #bases, 1, -1 do
        table.merge(clazz, bases[i])
    end
    clazz.__super = bases[1]
    clazz.__call = function(self, ...)
        return self:__new(...)
    end
    return setmetatable(clazz, clazz)
end

---
-- Generic constructor function for classes.
-- Note that __new() will call init() if it is available in the class.
-- @return Instance
function class:__new(...)
    local obj = self:__object_factory()

    if obj.init then
        obj:init(...)
    end

    return obj
end

---
-- Returns the new object.
-- @return object
function class:__object_factory()
    local moai_class = self.__moai_class

    if moai_class then
        local obj = moai_class.new()
        obj.__class = self
        obj:setInterface(self)
        return obj
    end

    local obj = {__index = self, __class = self}
    return setmetatable(obj, obj)
end





---------------------------------------------------------------------------------
-- Math module extensions
---------------------------------------------------------------------------------

---
-- Calculate the distance.
-- @param x0 Start position.
-- @param y0 Start position.
-- @param x1 (option)End position (note: default value is 0)
-- @param y1 (option)End position (note: default value is 0)
-- @return distance
function math.distance( x0, y0, x1, y1 )
    if not x1 then x1 = 0 end
    if not y1 then y1 = 0 end

    local dX = x1 - x0
    local dY = y1 - y0
    local dist = math.sqrt((dX * dX) + (dY * dY))
    return dist
end

---
-- Get the normal vector
-- @param x
-- @param y
-- @return x/d, y/d
function math.normalize( x, y )
    local d = math.distance( x, y )
    return x/d, y/d
end

function math.clamp(x, min, max)
    return math.max(min, math.min(x, max))
end


--------------------------------------------------------------------------------
-- Table extensions (lua-enumerable)
--------------------------------------------------------------------------------
table.includes = function(list, value)
    for i,x in ipairs(list) do
        if (x == value) then
            return(true)
        end
    end
    return(false)
end

table.detect = function(list, func)
    for i,x in ipairs(list) do
        if (func(x, i)) then
            return(x)
        end
    end
    return(nil)
end

table.without = function(list, item)
    return table.reject(list, function (x) 
        return x == item 
    end)
end

table.indexOf = function(list, item)
    for i, v in ipairs(list) do
        if v == item then
            return i
        end
    end
    return 0
end

table.removeElement = function(list, item)
    local i = table.indexOf(list, item)
    if i > 0 then
        table.remove(list, i)
    end
    return i
end

table.each = function(list, func)
    for i,v in ipairs(list) do
        func(v, i)
    end
end

table.every = function(list, func)
    for i,v in pairs(list) do
        func(v, i)
    end
end

table.select = function(list, func)
    local results = {}
    for i,x in ipairs(list) do
        if (func(x, i)) then
            table.insert(results, x)
        end
    end
    return(results)
end

table.reject = function(list, func)
    local results = {}
    for i,x in ipairs(list) do
        if (func(x, i) == false) then
            table.insert(results, x)
        end
    end
    return(results)
end

table.partition = function(list, func)
    local matches = {}
    local rejects = {}
    
    for i,x in ipairs(list) do
        if (func(x, i)) then
            table.insert(matches, x)
        else
            table.insert(rejects, x)
        end
    end
    
    return matches, rejects
end

table.merge = function(source, destination)
    for k,v in pairs(destination) do source[k] = v end
    return source
end

table.unshift = function(list, val)
    table.insert(list, 1, val)
end

table.shift = function(list)
    return table.remove(list, 1)
end

table.pop = function(list)
    return table.remove(list)
end

table.push = function(list, item)
    return table.insert(list, item)
end

table.insertIfAbsent = function(list, item)
    if table.includes(list, item) then
        return false
    end
    list[#list+1]=item
    return true
end

table.collect = function(source, func) 
    local result = {}
    for i,v in ipairs(source) do table.insert(result, func(v)) end
    return result
end

table.empty = function(source) 
    return source == nil or next(source) == nil
end

table.present = function(source)
    return not(table.empty(source))
end

table.random = function(source)
    return source[math.random(1, #source)]
end

table.times = function(limit, func)
    for i = 1, limit do
        func(i)
    end
end

table.reverse = function(source)
    local result = {}
    for i,v in ipairs(source) do table.unshift(result, v) end
    return result
end

table.dup = function(source)
    local result = {}
    for k,v in pairs(source) do result[k] = v end
    return result
end

-- fisher-yates shuffle
function table.shuffle(t)
    local n = #t
    while n > 2 do
        local k = math.random(n)
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end
    return t
end

table.keys = function(source)
    local result = {}
    for k,v in pairs(source) do
        table.push(result, k)
    end
    return result
end

