--------------------------------------------------------------------------------
-- Animation.lua
-- 
-- Set of Helper functions for making sprite animation actions
-- 
--------------------------------------------------------------------------------


local ResourceMgr = require("core.ResourceMgr")

local Animation = {}

---
-- Creates MOAIAnim from given sequence of indices and their timings
-- @param table sequence format: {{idx : number, delay : number}, }
-- @param MOAIProp target 
function Animation.animFromSequence(sequence, target)
    local curve = MOAIAnimCurve.new()
    local anim = MOAIAnim.new()

    local size = #sequence
    curve:reserveKeys(size + 1)
    local time = 0
    for i = 1, size do
        curve:setKey(i, time, sequence[i].idx, MOAIEaseType.FLAT)
        time = time + sequence[i].delay
    end
    curve:setKey(size + 1, time, sequence[size].idx, MOAIEaseType.FLAT)

    anim:reserveLinks(1)
    anim:setLink(1, curve, target, MOAIProp.ATTR_INDEX )
    anim:setCurve(curve)

    return anim
end


---
-- Construct sequence table from given frame name and range
-- @param string printf-like format string, i.e. "frame_%.2d"
-- @param number first frame number
-- @param number last frame number
-- @param number delay between frames
function Animation.sequence(frameFormat, first, last, delay)
    local firstFrame = string.format(frameFormat, first)
    local name = ResourceMgr:getAtlasName(firstFrame)
    local deck = ResourceMgr:getAtlasDeck(name)
    assert(deck, "Not found atlas containing frame " .. name)

    local t = {}
    for i = first, last do
        local frame = string.format(frameFormat, i)
        t[#t + 1] = {idx = deck.names[frame], delay = delay}
    end

    return t
end


return Animation