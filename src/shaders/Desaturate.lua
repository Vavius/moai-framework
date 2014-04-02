----------------------------------------------------------------------------------------------------
-- @type Desaturate
--
-- Desaturate shader
----------------------------------------------------------------------------------------------------


local Desaturate = class()
Desaturate.__index = MOAIShader.getInterfaceTable()
Desaturate.__moai_class = MOAIShader

local vsh = [=[
attribute vec4 position;
attribute vec2 uv;
attribute vec4 color;

varying MEDP vec2 uvVarying;

void main () {
    gl_Position = position;
    uvVarying = uv;
}
]=]

local fsh = [=[
#ifdef GL_ES
precision mediump int;
precision mediump float;
#endif
varying MEDP vec2 uvVarying;

uniform sampler2D sampler;
uniform float saturation;

void main () {
    vec4 color = texture2D ( sampler, uvVarying );
    float gray = 0.1 * color.r + 0.4 * color.g + 0.1 * color.b;
    gl_FragColor = mix ( vec4 ( gray, gray, gray, color.a ), color, saturation );
}
]=]

function Desaturate:init()
    self:reserveUniforms(1)
    self:declareUniform(1, "saturation", MOAIShader.UNIFORM_FLOAT)
    self:setSaturation(1)

    self:setVertexAttribute ( 1, 'position' )
    self:setVertexAttribute ( 2, 'uv' )
    self:setVertexAttribute ( 3, 'color' )
    
    self:load(vsh, fsh)
end

function Desaturate:setSaturation(value)
    self:setAttr(1, value)
end

function Desaturate:moveSaturation(value, time, ease)
    return self:moveAttr(1, value, time, ease)
end

function Desaturate:getSaturation()
    print("getAttr", self:getAttr(1))
    return self:getAttr(1)
end

return Desaturate