--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local App = require("display.App")

local SceneTransitions = {}

-- fadeIn
-- fadeOut
-- fadeOutIn
-- crossfade
-- zoomOutIn
-- zoomOutInFade
-- zoomInOut
-- zoomItOutFade
-- fromRight
-- fromLeft
-- fromTop
-- fromBottom
-- slideRight
-- slideLeft
-- slideTop
-- slideBottom

-- params:
--  duration
--  easeType
--  
--  

local no_params = {}

SceneTransitions.fadeIn = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.diration or 0.5
        local easeType = params.easeType

        sceneIn:setVisible(true)
        sceneIn:setColor(0, 0, 0, 0)

        MOAICoroutine.blockOnAction(sceneIn:seekColor(1, 1, 1, 1, duration, easeType))
        
        sceneOut:setVisible(false)
    end
end

SceneTransitions.fadeOutIn = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.diration or 0.5
        local easeType = params.easeType

        sceneIn:setVisible(true)
        sceneIn:setColor(0, 0, 0, 0)

        MOAICoroutine.blockOnAction(sceneOut:seekColor(0, 0, 0, 0, duration, easeType))
        MOAICoroutine.blockOnAction(sceneIn:seekColor(1, 1, 1, 1, duration, easeType))
        
        sceneOut:setVisible(false)
        sceneOut:setColor(1, 1, 1, 1)
    end
end

SceneTransitions.crossfade = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.diration or 0.5
        local easeType = params.easeType

        sceneIn:setVisible(true)
        sceneIn:setColor(0, 0, 0, 0)

        local action1 = sceneOut:seekColor(0, 0, 0, 0, duration, easeType)
        local action2 = sceneIn:seekColor(1, 1, 1, 1, duration, easeType)
        MOAICoroutine.blockOnAction(action1)
        
        sceneOut:setVisible(false)
        sceneOut:setColor(1, 1, 1, 1)
    end
end

SceneTransitions.fromRight = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.duration or 0.5
        local easeType = params.easeType
        local sw, sh = App.screenWidth, App.screenHeight

        sceneIn:setVisible(true)
        sceneIn:setLoc(sw, 0)
        
        MOAICoroutine.blockOnAction(sceneIn:moveLoc(-sw, 0, 0, duration, easeType))
        
        sceneOut:setVisible(false)
        sceneIn:setLoc(0, 0)
    end
end

SceneTransitions.fromLeft = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.duration or 0.5
        local easeType = params.easeType
        local sw, sh = App.screenWidth, App.screenHeight

        sceneIn:setVisible(true)
        sceneIn:setLoc(-sw, 0)
        
        MOAICoroutine.blockOnAction(sceneIn:moveLoc(sw, 0, 0, duration, easeType))
        
        sceneOut:setVisible(false)
        sceneIn:setLoc(0, 0)
    end
end

SceneTransitions.fromTop = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.duration or 0.5
        local easeType = params.easeType
        local sw, sh = App.screenWidth, App.screenHeight

        sceneIn:setVisible(true)
        sceneIn:setLoc(0, -sh)
        
        MOAICoroutine.blockOnAction(sceneIn:moveLoc(0, sh, 0, duration, easeType))
        
        sceneOut:setVisible(false)
        sceneIn:setLoc(0, 0)
    end
end

SceneTransitions.fromBottom = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.duration or 0.5
        local easeType = params.easeType
        local sw, sh = App.screenWidth, App.screenHeight

        sceneIn:setVisible(true)
        sceneIn:setLoc(0, sh)
        
        MOAICoroutine.blockOnAction(sceneIn:moveLoc(0, -sh, 0, duration, easeType))
        
        sceneOut:setVisible(false)
        sceneIn:setLoc(0, 0)
    end
end

SceneTransitions.slideRight = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.duration or 0.5
        local easeType = params.easeType
        local sw, sh = App.screenWidth, App.screenHeight

        sceneIn:setVisible(true)
        sceneIn:setLoc(-sw, 0)
        
        local action1 = sceneOut:moveLoc(sw, 0, 0, duration, easeType)
        local action2 = sceneIn:moveLoc(sw, 0, 0, duration, easeType)
        MOAICoroutine.blockOnAction(action1)
        
        sceneOut:setVisible(false)
        sceneOut:setLoc(0, 0)
        sceneIn:setLoc(0, 0)
    end
end

SceneTransitions.slideLeft = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.duration or 0.5
        local easeType = params.easeType
        local sw, sh = App.screenWidth, App.screenHeight

        sceneIn:setVisible(true)
        sceneIn:setLoc(sw, 0)
        
        local action1 = sceneOut:moveLoc(-sw, 0, 0, duration, easeType)
        local action2 = sceneIn:moveLoc(-sw, 0, 0, duration, easeType)
        MOAICoroutine.blockOnAction(action1)
        
        sceneOut:setVisible(false)
        sceneOut:setLoc(0, 0)
        sceneIn:setLoc(0, 0)
    end
end

SceneTransitions.slideTop = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.duration or 0.5
        local easeType = params.easeType
        local sw, sh = App.screenWidth, App.screenHeight

        sceneIn:setVisible(true)
        sceneIn:setLoc(0, sh)
        
        local action1 = sceneOut:moveLoc(0, -sh, 0, duration, easeType)
        local action2 = sceneIn:moveLoc(0, -sh, 0, duration, easeType)
        MOAICoroutine.blockOnAction(action1)
        
        sceneOut:setVisible(false)
        sceneOut:setLoc(0, 0)
        sceneIn:setLoc(0, 0)
    end
end

SceneTransitions.slideBottom = function(params)
    params = params or no_params
    return function(sceneOut, sceneIn)
        local duration = params.duration or 0.5
        local easeType = params.easeType
        local sw, sh = App.screenWidth, App.screenHeight

        sceneIn:setVisible(true)
        sceneIn:setLoc(0, -sh)
        
        local action1 = sceneOut:moveLoc(0, sh, 0, duration, easeType)
        local action2 = sceneIn:moveLoc(0, sh, 0, duration, easeType)
        MOAICoroutine.blockOnAction(action1)
        
        sceneOut:setVisible(false)
        sceneOut:setLoc(0, 0)
        sceneIn:setLoc(0, 0)
    end
end



return SceneTransitions