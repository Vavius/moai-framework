--------------------------------------------------------------------------------
-- Resource cache
-- 
-- 
--------------------------------------------------------------------------------

local ResourceMgr = { }

local App = require("display.App")

local _createTexture
local _createFont
local _createStretchRowsOrColumns
local _getNineImageContentPadding

--------------------------------------------------------------------------------
-- Texture and Deck cache
--------------------------------------------------------------------------------

ResourceMgr.resourceDirectories = {}
ResourceMgr.filepathCache = {}
ResourceMgr.textureCache = setmetatable({}, {__mode = "v"})
ResourceMgr.fontCache = {}

ResourceMgr.imageDecks = setmetatable({}, {__mode = "v"})
ResourceMgr.tileImageDecks = setmetatable({}, {__mode = "v"})
ResourceMgr.atlasDecks = setmetatable({}, {__mode = "v"})
ResourceMgr.nineImageDecks = setmetatable({}, {__mode = "v"})

-- Internal lookup table to find atlas name for given sprite name
ResourceMgr.spriteFrameAtlases = {}

--- Default Texture filter
local DEFAULT_TEXTURE_FILTER = MOAITexture.GL_LINEAR

---
-- Constructor.
-- @param path Texture path
-- @param filter Texture filter
function _createTexture(path, filter)
    local texture = MOAITexture.new()

    texture:load(path)
    texture.path = path
    texture.filter = filter or DEFAULT_TEXTURE_FILTER

    if texture.filter then
        texture:setFilter(texture.filter)
    end

    return texture
end

---
-- Constructor.
-- @param path Font path
function _createFont(path)
    local font = MOAIFont.new()
    font:load(path)
    
    font.path = path
    
    return font
end

---
-- Add the resource directory path.
-- You can omit the file path by adding.
-- It is assumed that the file is switched by the resolution and the environment.
-- @param path resource directory path
-- @param scale (option) resolution scale for image files
-- @param threshold (option) when viewport scale is bigger than threshold, this directory will have a priority over another
function ResourceMgr:addResourceDirectory(path, scale, threshold)
    scale = scale or 1
    threshold = threshold or scale
    local dirInfo = {path = path, scale = scale, threshold = threshold}
    
    table.push(self.resourceDirectories, dirInfo)
    table.sort(self.resourceDirectories, function(a, b) return a.threshold > b.threshold end)
end

---
-- Search in ResourceDirectories for file. 
-- @param fileName name of the file
-- @return filePath, scale  returns full path to file and scale factor of the directory that contain this file
function ResourceMgr:getResourceFilePath(fileName)
    if self.filepathCache[fileName] then
        return unpack(self.filepathCache[fileName])
    end

    if MOAIFileSystem.checkFileExists(fileName) then
        self.filepathCache[fileName] = {fileName, 1} 
        return fileName, 1
    end

    local scaleFactor = App:getContentScale() or 1
    for i, pathInfo in ipairs(self.resourceDirectories) do
        if pathInfo.threshold <= scaleFactor then
            local filePath = pathInfo.path .. "/" .. fileName
            if MOAIFileSystem.checkFileExists(filePath) then
                self.filepathCache[fileName] = {filePath, pathInfo.scale}
                return filePath, pathInfo.scale
            end
        end
    end

    return nil
end

---
-- Loads (or obtains from its cache) a texture and returns it.
-- Textures are cached.
-- @param path The path of the texture
-- @return Texture instance
function ResourceMgr:getTexture(path)
    if type(path) == "userdata" then
        return path
    end
    
    local cache = self.textureCache
    local filepath, scale = self:getResourceFilePath(path)
    
    if not filepath then
        return nil
    end
    
    local texture = cache[filepath]
    if texture == nil then
        texture = _createTexture(filepath)
        texture.scale = scale
        cache[filepath] = texture
    end
    return texture
end

---
-- Loads (or obtains from its cache) a font and returns it.
-- @param path The path of the font.
-- @return Font instance
function ResourceMgr:getFont(path)
    if type(path) == "userdata" then
        return path
    end

    local cache = self.fontCache
    path = self:getResourceFilePath(path)

    assert(path, "Font not found: " .. path)

    if cache[path] == nil then
        local font = _createFont(path)
        cache[path] = font
    end
    return cache[path]
end

---
-- Returns the file data.
-- @param fileName file name
-- @return file data
function ResourceMgr:readFile(fileName)
    local path = self:getResourceFilePath(fileName)
    local input = assert(io.input(path))
    local data = input:read("*a")
    input:close()
    return data
end

---
-- Returns the result of executing the dofile.
-- Browse to the directory of the resource.
-- @param fileName lua file name
-- @return results of running the dofile
function ResourceMgr:dofile(fileName)
    local filePath = self:getResourceFilePath(fileName)
    return dofile(filePath)
end

---
-- Load table from lua file. Sets environment to empty table to prevent any code from execution
-- @param fileName
-- @return table
function ResourceMgr:loadTable(fileName)
    local filePath = self:getResourceFilePath(fileName)
    local tbl = assert(loadfile(filePath))
    setfenv(tbl, {})
    return tbl()
end


--------------------------------------------------------------------------------
-- MOAIDeck cache
--------------------------------------------------------------------------------

---
-- Return the Deck for texture.
-- @param width (Optional)width
-- @param height (Optional)height
-- @param flipX (Optional)flipX
-- @param flipY (Optional)flipY
-- @return deck
function ResourceMgr:getImageDeck(texture, filter, width, height, flipX, flipY)
    texture = self:getTexture(texture, filter)
    
    if not texture then
        return nil
    end

    local tw, th = texture:getSize()
    local scale = texture.scale
    width = width or tw / scale
    height = height or th / scale

    flipX = flipX and true or false
    flipY = flipY and true or false
    local key = texture.path .. "$" .. width .. "$" .. height .. "$" .. tostring(flipX) .. "$" .. tostring(flipY)
    local cache = self.imageDecks

    if not cache[key] then
        cache[key] = self:createImageDeck(texture, width, height, flipX, flipY)
    end
    return cache[key]
end

---
-- Create the Deck to be used in the Image.
-- @param width width
-- @param height height
-- @param flipX (Optional)flipX
-- @param flipY (Optional)flipY
-- @return deck
function ResourceMgr:createImageDeck(texture, width, height, flipX, flipY)
    local u0 = flipX and 1 or 0
    local v0 = flipY and 0 or 1
    local u1 = flipX and 0 or 1
    local v1 = flipY and 1 or 0
    local deck = MOAIGfxQuad2D.new()
    deck:setUVRect(u0, v0, u1, v1)
    deck:setRect(-0.5 * width, -0.5 * height, 0.5 * width, 0.5 * height)
    deck:setTexture(texture)
    deck.flipX = flipX
    deck.flipY = flipY
    return deck
end


---
-- Find atlas name for given sprite frame name
-- @param spriteFrameName sprite name
-- @return string atlas lua file name
function ResourceMgr:getAtlasName(spriteFrameName)
    return ResourceMgr.spriteFrameAtlases[spriteFrameName]
end

---
-- Assign atlas name for sprite frame
function ResourceMgr:setAtlasForSprite(luaFilePath, spriteFrameName)
    local existing = self.spriteFrameAtlases[spriteFrameName]

    assert(existing == nil or existing == luaFilePath)

    self.spriteFrameAtlases[spriteFrameName] = luaFilePath
end

function ResourceMgr:cacheSpriteFrames(luaFilePath)
    local frames = self:loadTable(luaFilePath).frames
    for i, frame in ipairs(frames) do
        self:setAtlasForSprite(luaFilePath, frame.name)
    end
end

---
-- Return the Deck for displaying TextureAtlas.
-- @param luaFilePath TexturePacker lua file path
-- @param flipX (option)flipX
-- @param flipY (option)flipY
-- @return Texture atlas deck
function ResourceMgr:getAtlasDeck(luaFilePath, flipX, flipY)
    flipX = flipX and true or false
    flipY = flipY and true or false

    local key = luaFilePath .. "$" .. tostring(flipX) .. "$" .. tostring(flipY)
    local cache = self.atlasDecks

    if not cache[key] then
        cache[key] = self:createAtlasDeck(luaFilePath, flipX, flipY)
    end
    return cache[key]
end

---
-- Create the Deck for displaying TextureAtlas.
-- @param luaFilePath TexturePacker lua file path
-- @return Texture atlas deck
function ResourceMgr:createAtlasDeck(luaFilePath, flipX, flipY)
    local atlas = self:loadTable(luaFilePath)
    local frames = atlas.frames
    local boundsDeck = MOAIBoundsDeck.new()
    boundsDeck:reserveBounds(#frames)
    boundsDeck:reserveIndices(#frames)

    local deck = MOAIGfxQuadDeck2D.new()
    deck:setBoundsDeck(boundsDeck)
    deck:reserve(#frames)
    deck.frames = frames
    deck.names = {}
    deck.flipX = flipX
    deck.flipY = flipY

    local texture = self:getTexture(atlas.texture)
    local inv_scale = 1 / texture.scale
    deck:setTexture(texture)

    for i, frame in ipairs(frames) do
        local uvRect = frame.uvRect
        local uv = {uvRect.u0, uvRect.v0, uvRect.u1, uvRect.v0, uvRect.u1, uvRect.v1, uvRect.u0, uvRect.v1}
        local r = frame.spriteColorRect
        local b = frame.spriteSourceSize

        table.every(r, function(v, i) r[i] = inv_scale * v end)
        table.every(b, function(v, i) b[i] = inv_scale * v end)

        if frame.textureRotated then
            uv = {uv[3], uv[4], uv[5], uv[6], uv[7], uv[8], uv[1], uv[2]}
        end
        if flipX then
            uv = {uv[3], uv[4], uv[1], uv[2], uv[7], uv[8], uv[5], uv[6]}
        end
        if flipY then
            uv = {uv[7], uv[8], uv[5], uv[6], uv[3], uv[4], uv[1], uv[2]}
        end

        deck:setUVQuad(i, unpack(uv))
        deck.names[frame.name] = i
        deck:setRect(i, r.x - 0.5 * b.width, r.y - 0.5 * b.height, r.x + r.width - 0.5 * b.width, r.y + r.height - 0.5 * b.height)
        boundsDeck:setBounds(i, -0.5 * b.width, -0.5 * b.height, 0, 0.5 * b.width, 0.5 * b.height, 0)
        boundsDeck:setIndex(i, i)

        self:setAtlasForSprite(luaFilePath, frame.name)
    end

    return deck
end

---
-- Returns the Deck to draw NineImage.
-- For caching, you must not change the Deck.
-- @param fileName fileName
-- @return MOAIStretchPatch2D instance
function ResourceMgr:getNineImageDeck(fileName)
    local filePath = self:getResourceFilePath(fileName)
    local cache = Decks.nineImageDecks

    if not cache[filePath] then
        cache[filePath] = self:createNineImageDeck(filePath)
    end
    return cache[filePath]
end

---
-- Create the Deck to draw NineImage.
-- @param fileName fileName
-- @return MOAIStretchPatch2D instance
function ResourceMgr:createNineImageDeck(fileName)
    local filePath = self:getResourceFilePath(fileName)

    local image = MOAIImage.new()
    image:load(filePath)

    local texture = self:getTexture(filePath)
    local scale = texture.scale

    local imageWidth, imageHeight = image:getSize()
    local displayWidth, displayHeight = (imageWidth - 2) / scale, (imageHeight - 2) / scale
    local stretchRows = _createStretchRowsOrColumns(image, true)
    local stretchColumns = _createStretchRowsOrColumns(image, false)
    local contentPadding = _getNineImageContentPadding(image)
    local uvRect = {1 / imageWidth, 1 / imageHeight, (imageWidth - 1) / imageWidth, (imageHeight - 1) / imageHeight}

    local deck = MOAIStretchPatch2D.new()
    deck.imageWidth = imageWidth
    deck.imageHeight = imageHeight
    deck.displayWidth = displayWidth
    deck.displayHeight = displayHeight
    deck.contentPadding = contentPadding
    deck:reserveUVRects(1)
    deck:setTexture(texture)
    deck:setRect(-0.5 * displayWidth, -0.5 * displayHeight, 0.5 * displayWidth, 0.5 * displayHeight)
    deck:setUVRect(1, unpack(uvRect))
    deck:reserveRows(#stretchRows)
    deck:reserveColumns(#stretchColumns)

    for i, row in ipairs(stretchRows) do
        deck:setRow(i, row.weight, row.stretch)
    end
    for i, column in ipairs(stretchColumns) do
        deck:setColumn(i, column.weight, column.stretch)
    end

    return deck
end

function _createStretchRowsOrColumns(image, isRow)
    local stretchs = {}
    local imageWidth, imageHeight = image:getSize()
    local targetSize = isRow and imageHeight or imageWidth
    local stretchSize = 0
    local pr, pg, pb, pa = image:getRGBA(0, 1)

    for i = 1, targetSize - 2 do
        local r, g, b, a = image:getRGBA(isRow and 0 or i, isRow and i or 0)
        stretchSize = stretchSize + 1

        if pa ~= a then
            table.insert(stretchs, {weight = stretchSize / (targetSize - 2), stretch = pa > 0})
            pa, stretchSize = a, 0
        end
    end
    if stretchSize > 0 then
        table.insert(stretchs, {weight = stretchSize / (targetSize - 2), stretch = pa > 0})
    end

    return stretchs
end

function _getNineImageContentPadding(image)
    local imageWidth, imageHeight = image:getSize()
    local paddingLeft = 0
    local paddingTop = 0
    local paddingRight = 0
    local paddingBottom = 0

    for x = 0, imageWidth - 2 do
        local r, g, b, a = image:getRGBA(x + 1, imageHeight - 1)
        if a > 0 then
            paddingLeft = x
            break
        end
    end
    for x = 0, imageWidth - 2 do
        local r, g, b, a = image:getRGBA(imageWidth - x - 2, imageHeight - 1)
        if a > 0 then
            paddingRight = x
            break
        end
    end
    for y = 0, imageHeight - 2 do
        local r, g, b, a = image:getRGBA(imageWidth - 1, y + 1)
        if a > 0 then
            paddingTop = y
            break
        end
    end
    for y = 0, imageHeight - 2 do
        local r, g, b, a = image:getRGBA(imageWidth - 1, imageHeight - y - 2)
        if a > 0 then
            paddingBottom = y
            break
        end
    end

    return {paddingLeft, paddingTop, paddingRight, paddingBottom}
end

return ResourceMgr