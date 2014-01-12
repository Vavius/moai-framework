--------------------------------------------------------------------------------
-- @type SceneMgr
-- 
-- 
--------------------------------------------------------------------------------

local EventDispatcher = require("event.EventDispatcher")

local SceneMgr = EventDispatcher()

local RenderMgr         = require("manager.RenderMgr")
local InputMgr          = require("manager.InputMgr")
local Event             = require("event.Event")
local EventDispatcher   = require("event.EventDispatcher")
local Executors         = require("util.Executors")
local Scene             = require("scene.Scene")

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
end

---
-- Add new scene to stack
-- @param scene filename
function SceneMgr:pushScene(sceneName, params)
    local sceneClass = require(sceneName)
    local scene = sceneClass(params)
    scene.name = sceneName
    self:internalOpenScene(scene, params, false)
end

---
-- Replace current scene with this one
-- @param scene filename
function SceneMgr:replaceScene(sceneName, params)
    local sceneClass = require(sceneName)
    local scene = sceneClass(params)
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
-- Open the scene for internal implementation.
-- variable that can be specified in params are as follows.
-- <ul>
--   <li>animation: Scene animation of transition. </li>
--   <li>duration: Transition time. </li>
--   <li>easeType: EaseType to animation scene. </li>
-- </ul>
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
    end

    -- create next scene
    self.nextScene = scene
    self.nextScene:open(params)
    self:addScene(self.nextScene)

    local function onTransitionFinished()
        if self.currentScene and currentCloseFlag then
            self.currentScene:close(params)
            self:removeScene(self.currentScene)
        end

        self.currentScene = self.nextScene
        self.nextScene = nil
        self.transitioning = false
        self.currentScene:start(params)
    end

    local animation = params.transition

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

    -- set closing scenes
    self.closingSceneSize = #self.scenes - self.nextSceneIndex
    self.closingSceneGroup = Scene()
    for i = 0, self.closingSceneSize - 1 do
        local scene = self.scenes[#self.scenes - i]
        self.closingSceneGroup:addChild(scene)
    end

    -- stop current scene
    self.currentScene:stop(params)

    local function onTransitionFinished()

        for i, scene in ipairs(self.closingSceneGroup.children) do
            scene:close(params)
            self:removeScene(scene)
        end

        self.closingSceneGroup = nil
        self.closingSceneSize = nil
        self.currentScene = self.nextScene
        self.nextScene = nil
        self.transitioning = false

        if self.currentScene then
            self.currentScene:start(params)
        end
    end

    local animation = params.transition

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
    table.insertIfAbsent(self.renderTable, scene.layers)
end

function SceneMgr:removeScene(scene)
    table.removeElement(self.scenes, scene)
    table.removeElement(self.renderTable, scene.layers)
end

---
-- The event handler is called when you touch the screen.
-- Touch to fire a event to Scene.
-- @param e Touch event
function SceneMgr:onTouch(e)

    local scene = self.currentScene
    if scene and scene.sceneTouchEnabled then
        scene:dispatchEvent(e)
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