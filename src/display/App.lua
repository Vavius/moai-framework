--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local App = {}

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
function App:openWindow(title, windowParams)
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
function App:updateVieport(width, height, scaleMode, offset)
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
function App:getContentScale()
    return self.screenWidth / self.viewWidth
end

return App