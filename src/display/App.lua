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
    viewOffset = {0, 0},
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
    
    self:updateVieport(params)

    MOAISim.openWindow(title, screenWidth, screenHeight)
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
    if params.scaleMode == "letterbox" then
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