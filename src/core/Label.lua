--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local App = require("core.App")

local Label = class()
local MOAITextBoxInterface = MOAITextBox.getInterfaceTable()
Label.__index = MOAITextBoxInterface
Label.__moai_class = MOAITextBox

--- Max width for fit size.
Label.MAX_FIT_WIDTH = 10000000

--- Max height for fit size.
Label.MAX_FIT_HEIGHT = 10000000

--- default fit length.
Label.DEFAULT_FIT_LENGTH = 10000000

--- default fit padding.
Label.DEFAULT_FIT_PADDING = 2

Label.DEFAULT_POINTS = 24

---
-- Constructor.
-- @param text Text
-- @param width Width
-- @param height Height
-- @param font (option) Font path, or Font object
-- @param textSize (option) TextSize
function Label:init(text, width, height, font, textSize)
    self.contentScale = App:getContentScale() or 1
    self.textSize = textSize or self.DEFAULT_POINTS

    font = ResourceMgr:getFont(font)

    self:setFont(font)
    self.font = font
    self:setYFlip(true)
    self:setSize(width or 10, height or 10)
    self:setTextSize(self.textSize)
    self:setTextScale(1 / self.contentScale)
    self:setString(text)

    if not width or not height then
        self:fitSize(#text, width, height)
    end
end

---
-- Sets the size.
-- @param width Width
-- @param height Height
function Label:setSize(width, height)
    self:setRect(-0.5 * width, -0.5 * height, 0.5 * width, 0.5 * height)
end

---
-- Sets the text size.
-- @param points points
-- @param dpi (Option)dpi
function Label:setTextSize(points)
    MOAITextBoxInterface.setTextSize(self, self.textSize * self.contentScale)
end

---
-- Sets the text scale.
-- @param scale scale
function Label:setTextScale(scale)
    local style = self:affirmStyle ()
    style:setScale(scale)
end

---
-- Sets the fit size.
-- @param length (Option)Length of the text.
-- @param maxWidth (Option)maxWidth of the text.
-- @param maxHeight (Option)maxHeight of the text.
-- @param padding (Option)padding of the text.
function Label:fitSize(length, maxWidth, maxHeight, padding)
    length = length or Label.DEFAULT_FIT_LENGTH
    maxWidth = maxWidth or Label.MAX_FIT_WIDTH
    maxHeight = maxHeight or Label.MAX_FIT_HEIGHT
    padding = padding or Label.DEFAULT_FIT_PADDING

    self:setSize(maxWidth, maxHeight)
    local left, top, right, bottom = self:getStringBounds(1, length)
    left, top, right, bottom = left or 0, top or 0, right or 0, bottom or 0
    local width, height = right - left + padding, bottom - top + padding

    self:setSize(width, height)
end

---
-- Sets the fit height.
-- @param length (Option)Length of the text.
-- @param maxHeight (Option)maxHeight of the text.
-- @param padding (Option)padding of the text.
function Label:fitHeight(length, maxHeight, padding)
    self:fitSize(length, self:getWidth(), maxHeight, padding)
end

---
-- Sets the fit height.
-- @param length (Option)Length of the text.
-- @param maxWidth (Option)maxWidth of the text.
-- @param padding (Option)padding of the text.
function Label:fitWidth(length, maxWidth, padding)
    self:fitSize(length, maxWidth, self:getHeight(), padding)
end


return Label