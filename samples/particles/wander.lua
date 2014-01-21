require 'ParticleHelper'

viewport = MOAIViewport.new ()
viewport:setSize ( 640, 480 )
viewport:setScale ( 640, 480 )

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

MOAISim.openWindow ( "cathead", 640, 480 )

CONST = MOAIParticleScript.packConst

-- local r1 = MOAIParticleScript.packReg ( 1 )

----------------------------------------------------------------
-- local init = MOAIParticleScript.new ()

-- init:vecAngle            ( r1, MOAIParticleScript.PARTICLE_DX, MOAIParticleScript.PARTICLE_DY )
-- init:sub             ( r1, CONST ( 180.0 ), r1 )

-- local render = MOAIParticleScript.new ()

-- render:add               ( MOAIParticleScript.PARTICLE_X, MOAIParticleScript.PARTICLE_X, MOAIParticleScript.PARTICLE_DX )
-- render:add               ( MOAIParticleScript.PARTICLE_Y, MOAIParticleScript.PARTICLE_Y, MOAIParticleScript.PARTICLE_DY )

-- render:sprite            ()
-- render:set               ( MOAIParticleScript.SPRITE_ROT, r1 )
-- render:ease              ( MOAIParticleScript.SPRITE_X_SCL, CONST ( 0.5 ), CONST ( 3 ), MOAIEaseType.SHARP_EASE_IN )
-- render:ease              ( MOAIParticleScript.SPRITE_OPACITY, CONST ( 1 ), CONST ( 0 ), MOAIEaseType.EASE_OUT )

-----------------------------
local reg={}    --shared register table

local init = makeParticleScript(function()
    p.dx = rand(10, 40)
    p.dy = rand(-20, -10)
    r = rand(0.3, 0.7)
    g = rand(0.3, 0.7)
    b = rand(0.7, 1)
end,reg)

local render = makeParticleScript(function (  )
    sprite()
    sp.opacity = ease(0, 0.6, EaseType.SOFT_EASE_IN)
    sp.r = r
    sp.g = g
    sp.b = b
end,reg)

local render2 = makeParticleScript(function (  )
    sprite()
    sp.opacity = ease(0.6, 0, EaseType.SOFT_EASE_OUT)
    sp.r = r
    sp.g = g
    sp.b = b
end,reg)


----------------------------------------------------------------
texture = MOAIGfxQuad2D.new ()
texture:setTexture ( "NeGeo.png" )
texture:setRect ( -16, -16, 16, 16 )

system = MOAIParticleSystem.new ()
system:reserveParticles ( 256, 3 )
system:reserveSprites ( 256 )
system:reserveStates ( 2 )
system:setDeck ( texture )
system:start ()
layer:insertProp ( system )

force = MOAIParticleForce.new()
force:initLinear(6, 15)

force2 = MOAIParticleForce.new()
force2:initLinear(6, -15)

forceMouse = MOAIParticleForce.new()

state = MOAIParticleState.new ()
state:setTerm ( 1, 3 )
state:setInitScript ( init )
state:setRenderScript ( render )
state:pushForce ( force )
state:pushForce ( forceMouse )
system:setState ( 1, state )

state2 = MOAIParticleState.new ()
state2:setTerm ( 1, 3 )
state2:setRenderScript ( render2 )
state2:pushForce ( force2 )
state2:pushForce ( forceMouse )
system:setState ( 2, state2 )


emitter = MOAIParticleTimedEmitter.new ()
emitter:setLoc ( 0, 0 )
emitter:setSystem ( system )
emitter:setRect ( -360, -240, 320, 240 )
emitter:setFrequency(0.1, 0.2)
emitter:setEmission(4)
emitter:start ()

state:setNext(state2)
state2:setNext(state)

function pointerCallback ( x, y )
    
    mouseX, mouseY = layer:wndToWorld ( x, y )
    
    forceMouse:setLoc(mouseX, mouseY)
end

function leftCallback ( down )
    if down then
        forceMouse:initAttractor(140, -1000)
    else
        forceMouse:initAttractor(0, 0)
    end
end

MOAIInputMgr.device.pointer:setCallback ( pointerCallback )
MOAIInputMgr.device.mouseLeft:setCallback ( leftCallback )
