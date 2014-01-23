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

        dialog:setVisible(true)

        dialog:setColor(0, 0, 0, 0)
        dialog:setScl(0.5, 0.5, 1)

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

        local action1 = dialog:seekColor(0, 0, 0, 1, time, ease)
        local action2 = dialog:seekScl(0.5, 0.5, 0.5, time, ease)
        MOAICoroutine.blockOnAction(action1)

        dialog:setColor(1, 1, 1, 1)
        dialog:setScl(1, 1, 1)
        dialog:setVisible(false)
    end
end


return DialogAnimations