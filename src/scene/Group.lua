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
-- Adds the specified child.
-- @param child DisplayObject
function Group:addChild(child)
    if table.insertIfAbsent(self.children, child) then
        child:setParent(self)
        child:setLayer(self.layer)

        return true
    end
    return false
end

---
-- Removes a child.
-- @param child DisplayObject
-- @return True if removed.
function Group:removeChild(child)
    if table.removeElement(self.children, child) then
        child:setParent(nil)
        child:setLayer(nil)

        return true
    end
    return false
end

---
-- Remove the children.
function Group:removeChildren()
    local children = table.copy(self.children)
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
-- @param priority priority
-- function Group:setPriority(priority)
--     for i, v in ipairs(self.children) do
--         v:setPriority(priority)
--     end
-- end

return Group