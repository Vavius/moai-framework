--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local Button = require("gui.Button")

local DialogAnimations = {}

local DEFAULT_TIME = 0.4
local no_params = {time = DEFAULT_TIME}


function DialogAnimations.fadeScaleIn(params)
    params = params or no_params
    return function(dialog)
        local group = dialog.group
        local time = params.time or DEFAULT_TIME
        local ease = params.ease or MOAIEaseType.EASE_OUT
        local scale = params.scale or {0.5, 0.5, 1}

        dialog:setVisible(true)

        group:setColor(0, 0, 0, 0)
        group:setScl(unpack(scale))

        local action1 = group:seekColor(1, 1, 1, 1, time, MOAIEaseType.EASE_IN)
        local action2 = group:seekScl(1, 1, 1, time, ease)
        MOAICoroutine.blockOnAction(action1)
    end
end


function DialogAnimations.fadeScaleOut(params)
    params = params or no_params
    return function(dialog)
        local group = dialog.group
        local time = params.time or DEFAULT_TIME
        local ease = params.ease or MOAIEaseType.EASE_IN
        local scaleX = params.scale and params.scale[1] or 0.5
        local scaleY = params.scale and params.scale[2] or 0.5

        local action1 = group:seekColor(0, 0, 0, 0, time, ease)
        local action2 = group:seekScl(scaleX, scaleY, 1, time, ease)
        MOAICoroutine.blockOnAction(action1)

        group:setColor(1, 1, 1, 1)
        group:setScl(1, 1, 1)
        dialog:setVisible(false)
    end
end


function DialogAnimations.scaleIn(params)
    params = params or no_params
    return function(dialog)
        local group = dialog.group
        local time = params.time or DEFAULT_TIME
        local ease = params.ease or MOAIEaseType.EASE_OUT
        local scale = params.scale or {0.5, 0.5, 1}

        dialog:setVisible(true)
        group:setScl(unpack(scale))

        local action = group:seekScl(1, 1, 1, time, ease)
        MOAICoroutine.blockOnAction(action)
    end
end

function DialogAnimations.scaleOut(params)
    params = params or no_params
    return function(dialog)
        local group = dialog.group
        local time = params.time or DEFAULT_TIME
        local ease = params.ease or MOAIEaseType.EASE_IN
        local scaleX = params.scale and params.scale[1] or 0.5
        local scaleY = params.scale and params.scale[2] or 0.5

        local action = group:seekScl(scaleX, scaleY, 1, time, ease)
        MOAICoroutine.blockOnAction(action)

        group:setScl(1, 1, 1)
        dialog:setVisible(false)
    end
end


function DialogAnimations.scaleButtons(params)
    params = params or no_params
    return function(dialog)
        local group = dialog.group
        if not group then
            return
        end

        local time = params.time or 0.3
        local ease = params.ease or MOAIEaseType.EASE_IN
        local scaleX = params.scale and params.scale[1] or 0.4
        local scaleY = params.scale and params.scale[2] or 0.4

        local delay = 4
        local runButtonAnim = function(obj)
            if obj.__class ~= Button then
                return
            end

            obj:setScl(scaleX, scaleY, 1)
            obj:seekScl(1, 1, 1, time, ease)
            for i = 1, delay do
                coroutine.yield()
            end
        end
        group:forEach(runButtonAnim, true)
    end
end


function DialogAnimations.sequence(...)
    local sequence = {...}
    return function(dialog)
        for i, v in ipairs(sequence) do
            v(dialog)
        end
    end
end

return DialogAnimations