--------------------------------------------------------------------------------
-- @type SceneMgr
-- 
-- 
--------------------------------------------------------------------------------

local EventDispatcher = require("core.EventDispatcher")

local SceneMgr = EventDispatcher()

local RenderMgr         = require("core.RenderMgr")
local InputMgr          = require("core.InputMgr")
local Event             = require("core.Event")
local EventDispatcher   = require("core.EventDispatcher")
local Executors         = require("core.Executors")
local Scene             = require("core.Scene")
local SceneTransitions  = require("core.SceneTransitions")

SceneMgr.scenes = {}
SceneMgr.renderTable = {}
SceneMgr.currentScene = nil
SceneMgr.nextScene = nil
SceneMgr.nextSceneIndex = nil
SceneMgr.closingSceneSize = nil
SceneMgr.closingSceneGroup = nil
SceneMgr.transitioning = false


--------------------------------------------------------------------------------
---
-- Initialize the SceneMgr
function SceneMgr:initialize()
    InputMgr:addEventListener(Event.TOUCH_DOWN, self.onTouch, self)
    InputMgr:addEventListener(Event.TOUCH_UP, self.onTouch, self)
    InputMgr:addEventListener(Event.TOUCH_MOVE, self.onTouch, self)
    InputMgr:addEventListener(Event.TOUCH_CANCEL, self.onTouch, self)
    Runtime:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)

    RenderMgr:addChild(self.renderTable)

    self.focus = {}
end

---
-- Add new scene to stack
-- @param scene filename
function SceneMgr:pushScene(scene, params)
    if type(scene) == "string" then
        local sceneClass = require(scene)
        scene = sceneClass(params)
    end
    scene.name = sceneName
    self:internalOpenScene(scene, params, false)
end

---
-- Replace current scene with this one
-- @param scene filename
function SceneMgr:replaceScene(scene, params)
    if type(scene) == "string" then
        local sceneClass = require(scene)
        scene = sceneClass(params)
    end
    scene.name = sceneName
    self:internalOpenScene(scene, params, true)
end

---
-- Close current scene and run previous scene in stack
-- 
function SceneMgr:popScene(params)

    self:closeScene(params, 1)
end

---
-- Close all scenes except root
-- 
function SceneMgr:popToRootScene(params)

    self:closeScene(params, #self.scenes - 1)
end

---
-- Add an overlay. Overlays are rendered above all scenes and don't move with scene transitions
-- @param table scene   Overlay scene. 
function SceneMgr:addOverlay(scene)
    self:addScene(scene)
    self:addSceneToRenderTable(scene, true)
end

---
-- Remove overlay 
-- @param table scene   Overlay scene. 
function SceneMgr:removeOverlay(scene)
    self:removeScene(scene)
    self:removeSceneFromRenderTable(scene)
end

---
-- Open the scene for internal implementation.
-- Params will be passed to scene events
-- special param value is 'transition'
function SceneMgr:internalOpenScene(scene, params, currentCloseFlag)
    params = params or {}

    -- state check
    if self.transitioning then
        return
    end
    self.transitioning = true

    -- stop
    if self.currentScene then
        self.currentScene:stop(params)
        self.currentScene:dispatchEvent(Event.EXIT, params)
    end

    -- create next scene
    self.nextScene = scene
    self.nextScene:open(params)
    self:addScene(self.nextScene)
    self:addSceneToRenderTable(self.nextScene)

    local function onTransitionFinished()
        if self.currentScene then
            self.currentScene:dispatchEvent(Event.DID_EXIT, params)
            self:removeSceneFromRenderTable(self.currentScene)
            if currentCloseFlag then
                self.currentScene:close(params)
                self:removeScene(self.currentScene)
            end
        end

        self.currentScene = self.nextScene
        self.nextScene = nil
        self.transitioning = false
        self.currentScene:start(params)
        self.currentScene:dispatchEvent(Event.ENTER, params)
    end

    local animation = params.transition
    if type(animation) == "string" then
        animation = SceneTransitions[animation]()
    end

    self.nextScene:dispatchEvent(Event.WILL_ENTER, params)
    if animation then
        Executors.callOnce(
        function()
            animation(self.currentScene or Scene(), self.nextScene)
            onTransitionFinished()
        end
        )
    else
        onTransitionFinished()
    end
end

---
-- Close the Scene.
-- variable that can be specified in params are as follows.
-- <ul>
--   <li>animation: Scene animation of transition. </li>
--   <li>duration: Time to scene animation. </li>
--   <li>easeType: EaseType to animation scene. </li>
-- </ul>
-- @param params (option)Parameters of the Scene
function SceneMgr:closeScene(params, backCount)
    params = params or {}

    -- state check
    if self.transitioning or not self.currentScene or backCount == 0 then
        return
    end
    self.transitioning = true

    -- set next scene
    self.nextScene = self.scenes[#self.scenes - backCount]
    self.nextSceneIndex = table.indexOf(self.scenes, self.nextScene)
    if self.nextScene then
        self.nextScene:dispatchEvent(Event.WILL_ENTER, params)
    end

    -- set closing scenes
    self.closingSceneSize = #self.scenes - self.nextSceneIndex
    self.closingSceneGroup = Scene()
    for i = 0, self.closingSceneSize - 1 do
        local scene = self.scenes[#self.scenes - i]
        self.closingSceneGroup:addChild(scene)
    end

    -- stop current scene
    self.currentScene:stop(params)
    self.currentScene:dispatchEvent(Event.EXIT, params)

    local function onTransitionFinished()
        self.currentScene:dispatchEvent(Event.DID_EXIT, params)
        for i, scene in ipairs(self.closingSceneGroup.children) do
            scene:close(params)
            self:removeScene(scene)
            self:removeSceneFromRenderTable(scene)
        end

        self.closingSceneGroup = nil
        self.closingSceneSize = nil
        self.currentScene = self.nextScene
        self.nextScene = nil
        self.transitioning = false

        if self.currentScene then
            self:addSceneToRenderTable(self.currentScene)
            self.currentScene:start(params)
            self.currentScene:dispatchEvent(Event.ENTER, params)
        end
    end

    local animation = params.transition
    if type(animation) == "string" then
        animation = SceneTransitions[animation]()
    end
    
    if animation then
        Executors.callOnce(
        function()
            local animation = params.transition
            animation(self.closingSceneGroup, self.nextScene or Scene(), params)
            onTransitionFinished()
        end
        )
    else    
        onTransitionFinished()
    end
end


function SceneMgr:addScene(scene)
    table.insertIfAbsent(self.scenes, scene)
end

function SceneMgr:removeScene(scene)
    table.removeElement(self.scenes, scene)
end

function SceneMgr:addSceneToRenderTable(scene, overlay)
    if table.includes(self.renderTable, scene) then
        return
    end

    if not overlay then
        for i, v in ipairs(self.renderTable) do
            if v.isOverlay then
                table.insert(self.renderTable, i, scene)
                return
            end
        end
    end

    table.insert(self.renderTable, scene.layers)
end

function SceneMgr:removeSceneFromRenderTable(scene)
    table.removeElement(self.renderTable, scene.layers)
end

function SceneMgr:setFocus(scene)
    table.push(self.focus, scene)
end

function SceneMgr:removeFocus(scene)
    table.removeElement(self.focus, scene)
end

---
-- The event handler is called when you touch the screen.
-- Touch to fire a event to Scene.
-- @param e Touch event
function SceneMgr:onTouch(e)

    local focus = self.focus[#self.focus]
    if focus and focus.sceneTouchEnabled then
        focus:dispatchEvent(e)
        return
    end
    
    local curr = self.currentScene
    if curr and curr.sceneTouchEnabled then
        curr:dispatchEvent(e)
    end
    
    -- send touches to all overlays
    for i, scene in ipairs(self.scenes) do
        if scene.isOverlay and scene.sceneTouchEnabled then
            scene:dispatchEvent(e)
        end
    end
end

---
-- The event handler is called when enter frame.
-- Fire a event to Scene.
-- @param e Enter frame event
function SceneMgr:onEnterFrame(e)

    for i, scene in ipairs(self.scenes) do
        if scene.sceneUpdateEnabled then
            scene:dispatchEvent(Event.UPDATE)
        end
    end
end


return SceneMgr