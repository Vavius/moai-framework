--------------------------------------------------------------------------------
-- Set of global helper functions
-- 
-- 
--------------------------------------------------------------------------------

local Display = {}

local Group = require("scene.Group")
local Layer = require("scene.Layer")

-- forward declarations
local cacheSpriteFrames
local nineImage
local openWindow
local sprite
local updateVieport


local DEFAULT_WINDOW = {
    screenWidth = MOAIEnvironment.horizontalResolution or 640,
    screenHeight = MOAIEnvironment.verticalResolution or 960,
    viewWidth = 320,
    viewHeight = 480,
    scale = "letterbox",
}

local DEFAULT_VIEW_OFFSET = {0, 0}

---
-- Create moai window
-- @param title
-- @param windowParams table with parameters
function Display:openWindow(title, windowParams)
    windowParams = windowParams or DEFAULT_WINDOW
    title = title or "MOAI"

    screenWidth     = windowParams.screenWidth or DEFAULT_WINDOW.screenWidth
    screenHeight    = windowParams.screenHeight or DEFAULT_WINDOW.screenHeight
    viewWidth       = windowParams.viewWidth or DEFAULT_WINDOW.viewWidth
    viewHeight      = windowParams.viewHeight or DEFAULT_WINDOW.viewHeight
    scaleMode       = windowParams.scale or DEFAULT_WINDOW.scale

    Runtime:initialize()
    RenderMgr:initialize()
    InputMgr:initialize()
    SceneMgr:initialize()

    MOAISim.openWindow(title, screenWidth, screenHeight)

    self.screenWidth = screenWidth
    self.screenHeight = screenHeight

    self:updateVieport(viewWidth, viewHeight, scaleMode, DEFAULT_VIEW_OFFSET)
end

---
-- 
-- 
function Display:updateVieport(width, height, scaleMode, offset)
    local wRatio = self.screenWidth / width
    local hRatio = self.screenHeight / height
    if scaleMode == "letterbox" then
        self.viewWidth = (wRatio > hRatio) and width * wRatio / hRatio or width
        self.viewHeight = (hRatio > wRatio) and height * hRatio / wRatio or height
    end

    self.viewport = self.viewport or MOAIViewport.new()
    self.viewport:setSize(self.screenWidth, self.screenHeight)
    self.viewport:setScale(self.viewWidth, self.viewHeight)
    self.viewport:setOffset(offset[1], offset[2])
end

---
function Display:getContentScale()
    return self.screenWidth / self.viewWidth
end

---
-- Create MOAIProp with deck set to proper texture file
-- @param   fileName    Texture name or sprite frame name
-- @param   width       (option) image width
-- @param   height      (option) image height
function Display.Sprite(fileName, width, height)
    
    local deck = ResourceMgr:getImageDeck(fileName, width, height)
    
    if not deck then
        local atlas = ResourceMgr:getAtlasName(fileName)
        assert(atlas, "Image not found: " .. fileName)

        deck = ResourceMgr:getAtlasDeck(atlas)
    end
    
    local sprite = MOAIProp.new()
    sprite:setDeck(deck)
    sprite.deck = deck
    sprite:setIndexByName(fileName)
    
    return sprite
end

Display.Group = Group
Display.Layer = Layer

---
-- Create MOAIProp with MOAIStretchPatch2D deck from file path or atlas frame name
function Display:nineImage(fileName)
    
    local img = MOAIProp.new()
end

return Display