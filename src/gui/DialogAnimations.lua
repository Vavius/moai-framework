--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local DialogAnimations = {}


-- fadeScaleIn
-- fadeScaleOut

local no_params = {time = 0.4}


function DialogAnimations.fadeScaleIn(params)
    params = params or no_params
    return function(dialog)
        local time = params.time
        local ease = params.ease or MOAIEaseType.EASE_OUT
        local scale = params.scale or {0.5, 0.5, 1}

        dialog:setVisible(true)

        dialog:setColor(0, 0, 0, 0)
        dialog:setScl(unpack(scale))

        local action1 = dialog:seekColor(1, 1, 1, 1, time, ease)
        local action2 = dialog:seekScl(1, 1, 1, time, ease)
        MOAICoroutine.blockOnAction(action1)
    end
end


function DialogAnimations.fadeScaleOut(params)
    params = params or no_params
    return function(dialog)
        local time = params.time
        local ease = params.ease or MOAIEaseType.EASE_IN
        local scaleX = params.scale and params.scale[1] or 0.5
        local scaleY = params.scale and params.scale[2] or 0.5

        local action1 = dialog:seekColor(0, 0, 0, 1, time, ease)
        local action2 = dialog:seekScl(scaleX, scaleY, 1, time, ease)
        MOAICoroutine.blockOnAction(action1)

        dialog:setColor(1, 1, 1, 1)
        dialog:setScl(1, 1, 1)
        dialog:setVisible(false)
    end
end


function DialogAnimations.scaleIn(params)
    params = params or no_params
    return function(dialog)
        local time = params.time
        local ease = params.ease or MOAIEaseType.EASE_OUT
        local scale = params.scale or {0.5, 0.5, 1}

        dialog:setVisible(true)

        dialog:setColor(0, 0, 0, 0)
        dialog:setScl(unpack(scale))

        local action = dialog:seekScl(1, 1, 1, time, ease)
        MOAICoroutine.blockOnAction(action)
    end
end

function DialogAnimations.scaleOut(params)
    params = params or no_params
    return function(dialog)
        local time = params.time
        local ease = params.ease or MOAIEaseType.EASE_IN
        local scaleX = params.scale and params.scale[1] or 0.5
        local scaleY = params.scale and params.scale[2] or 0.5

        local action = dialog:seekScl(scaleX, scaleY, 1, time, ease)
        MOAICoroutine.blockOnAction(action)

        dialog:setColor(1, 1, 1, 1)
        dialog:setScl(1, 1, 1)
        dialog:setVisible(false)
    end
end


function DialogAnimations.scaleButtons(params)
    params = params or no_params
    return function(dialog)
        
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