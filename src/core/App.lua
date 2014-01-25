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
    scaleMode = "best_fit", -- "best_fit", "letterbox"
    viewOffset = {0, 0},
}

---
-- Most common resolutions for mobile devices 
-- Keys are resolution of longer side in pixels, values are view coordinates 
-- Tried to keep view coords close to 320x480 and maintain 
-- integer ratio at the same time 
local mobileResolutions = {
    -- apple
    { [480]  = {480, 320} }, -- 480x320
    { [960]  = {480, 320} }, -- 960x640
    { [1136] = {568, 320} }, -- 1136x640
    { [1024] = {512, 384} }, -- 1024x768
    { [2048] = {512, 384} }, -- 2048x1536

    -- use standard fallback for all androids
    -- { [320]   = {480, 360} }, -- 320x240
    -- { [400]   = {532, 320} }, -- 400x240
    -- { [640]   = {568, 320} }, -- 640x360
    -- { [800]   = {532, 320} }, -- 800x480
    -- { [854]   = {568, 320} }, -- 854x480
    -- { [960]   = {568, 320} }, -- 960x540
    -- { [1280]  = {640, 360} }, -- 1280x720
    -- { [1920]  = {568, 320} }, -- 1920x1080
}

---
-- Create moai window
-- @param title
-- @param windowParams table with parameters
function App:openWindow(title, windowParams)
    windowParams = windowParams or DEFAULT_WINDOW
    title = title or "MOAI"

    for k, v in pairs(DEFAULT_WINDOW) do
        if not windowParams[k] then
            windowParams[k] = v
        end
    end

    Runtime:initialize()
    RenderMgr:initialize()
    InputMgr:initialize()
    SceneMgr:initialize()

    Runtime:addEventListener("resize", self.onResize, self)

    self.screenWidth = windowParams.screenWidth
    self.screenHeight = windowParams.screenHeight
    
    self:updateVieport(windowParams)

    MOAISim.openWindow(title, self.screenWidth, self.screenHeight)
end

--- 
--
--
function App:onResize(event)
    self.screenWidth = event.width
    self.screenHeight = event.height

    self:updateVieport(self.windowParams)
end

---
-- 
-- 
function App:updateVieport(params)
    local width = params.viewWidth
    local height = params.viewHeight

    local wRatio = self.screenWidth / width
    local hRatio = self.screenHeight / height
    
    local view
    if params.scaleMode == "best_fit" then
        if self.screenWidth > self.screenHeight then
            view = mobileResolutions[self.screenWidth]
            self.viewWidth = view and view[1]
            self.viewHeight = view and view[2]
        else
            view = mobileResolutions[self.screenHeight]
            self.viewHeight = view and view[1]
            self.viewWidth = view and view[2]
        end
    end
    
    if not view or params.scaleMode == "letterbox" then
        self.viewWidth = (wRatio > hRatio) and width * wRatio / hRatio or width
        self.viewHeight = (hRatio > wRatio) and height * hRatio / wRatio or height
    end

    self.windowParams = params
    self.viewport = self.viewport or MOAIViewport.new()
    self.viewport:setSize(self.screenWidth, self.screenHeight)
    self.viewport:setScale(self.viewWidth, self.viewHeight)
    self.viewport:setOffset(params.viewOffset[1], params.viewOffset[2])
end

---
function App:getContentScale()
    return self.screenWidth / self.viewWidth
end

return App