--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local Group = class()
Group.__index = MOAIProp.getInterfaceTable()
Group.__moai_class = MOAIProp


---
-- The constructor.
-- @param layer (option)layer object
-- @param width (option)width
-- @param height (option)height
function Group:init(layer, width, height)
    self.children = {}
    self.layer = layer
    self:setSize(width or 0, height or 0)
end

---
-- Sets the size.
-- This is the size of a Group, rather than of the children.
-- @param width width
-- @param height height
function Group:setSize(width, height)
    self:setBounds(-0.5 * width, -0.5 * height, 0, 0.5 * width, 0.5 * height, 0)
end

---
-- Sets scissor rect recursively for all children
-- @param MOAIScissorRect scissor rect
function Group:setScissorRect(scissorRect)
    self.scissorRect = scissorRect
    for i, child in ipairs(self.children) do
        child:setScissorRect(scissorRect)
    end
end

---
-- Returns child with specified name or nil if not found
-- @param string name
-- @return object 
function Group:getChildByName(name)
    for i, child in ipairs(self.children) do
        if child.name == name then
            return child
        end
    end

    return nil
end

---
-- Adds the specified child.
-- @param child DisplayObject
-- @param index (option) number index at which to insert child
function Group:addChild(child, index)
    if not table.includes(self.children, child) then
        index = index or (1 + #self.children)
        index = math.clamp(index, 1, #self.children + 1)
        
        table.insert(self.children, index, child)
        child:setParent(self)
        child:setLayer(self.layer)

        if self.scissorRect then 
            child:setScissorRect(self.scissorRect)
        end

        return true
    end
    return false
end

---
-- Add objects to group. 
-- Provides compatibility with propertyUtils
-- @param vararg objects 
function Group:setChildren(...)
    local children = {...}
    for i, child in ipairs(children) do
        self:addChild(child)
    end
end

---
-- Removes a child.
-- @param child DisplayObject
-- @return True if removed.
function Group:removeChild(child)
    if table.removeElement(self.children, child) then
        child:setParent(nil)
        child:setLayer(nil)
        child:setScissorRect(nil)

        return true
    end
    return false
end

---
-- Remove the children.
function Group:removeChildren()
    local children = table.dup(self.children)
    for i, child in ipairs(children) do
        self:removeChild(child)
    end
end

---
-- Sets the layer for this group to use.
-- @param layer MOAILayer object
function Group:setLayer(layer)
    if self.layer == layer then
        return
    end

    if self.layer then
        for i, v in ipairs(self.children) do
            if v.setLayer then
                v:setLayer(nil)
            else
                self.layer:removeProp(v)
            end
        end
    end

    self.layer = layer

    if self.layer then
        for i, v in ipairs(self.children) do
            if v.setLayer then
                v:setLayer(self.layer)
            else
                self.layer:insertProp(v)
            end
        end
    end
end

---
-- Sets the group's priority. 
-- Also sets the priority of any children. 
-- @param number priority
-- @param number stride
-- @return number priority of the last child
function Group:setPriority(priority, stride)
    local priority = priority or 0
    if stride then
        self.stride = stride
    else
        stride = self.stride or 1
    end
    
    for i, v in ipairs(self.children) do
        local last = v:setPriority(priority)
        priority = stride + (last or priority)
    end
    return priority - stride
end

---
-- Call given function for each child
-- @param function function to call. This function recieves child as argument
-- @param bool recursive whether to call this function on nested groups recursively
function Group:forEach(func, recursive)
    for i, child in ipairs(self.children) do
        func(child)
        if recursive and child.forEach then
            child.forEach(func, recursive)
        end
    end
end

return Group