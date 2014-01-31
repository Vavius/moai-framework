--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local ResourceMgr = require("core.ResourceMgr")

local SoundMgr = {}

local UntzSoundEngine
local MockSoundEngine


---
-- Initialize
-- @param string sound engine name
function SoundMgr:init(soundEngine)
    if not self._soundEngine then
        if soundEngine then
            self._soundEngine = soundEngine
        elseif MOAIUntzSystem then
            self._soundEngine = UntzSoundEngine()
        else
            self._soundEngine = MockSoundEngine()
        end
    end
end

---
-- Play the sound.
-- @param sound file path or object.
-- @param volume (Optional)volume. Default value is 1.
-- @param loop (Optional)loop flag. Default value is 'false'.
-- @return Sound object
function SoundMgr:playEffect(sound, volume, loop)
    return self._soundEngine:play(sound, volume, loop)
end

---
-- Start background music playback. It will be streamed from filesystem
-- without loading into memory. 
-- @param sound file name
-- @param volume 
-- @param loop (optional) default is 'false'
function SoundMgr:playMusic(sound, volume, loop)
    return self._soundEngine:play(sound, volume, loop)
end

---
-- Pause the sound.
-- @param sound file path or object.
function SoundMgr:pause(sound)
    self._soundEngine:pause(sound)
end

---
-- Stop the sound.
-- @param sound file path or object.
function SoundMgr:stop(sound)
    self._soundEngine:stop(sound)
end

---
-- Set the system level volume.
-- @param volume volume(0 <= volume <= 1)
function SoundMgr:setVolume(volume)
    self._soundEngine:setVolume(volume)
end

---
-- Return the system level volume.
-- @return volume
function SoundMgr:getVolume(volume)
    self._soundEngine:getVolume()
end

---
-- Return SoundEngine a singleton.
-- @return soundEngine
function SoundMgr:getSoundMgr()
    return self._soundEngine
end

----------------------------------------------------------------------------------------------------
-- @type UntzSoundMgr
-- 
-- This is UntzSoundMgr class using MOAIUntz.
----------------------------------------------------------------------------------------------------
UntzSoundMgr = class()
M.UntzSoundMgr = UntzSoundMgr

--- sampleRate
UntzSoundMgr.SAMPLE_RATE = nil

--- numFrames
UntzSoundMgr.NUM_FRAMES = nil

---
-- Constructor.
-- @param sampleRate sample rate
-- @param numFrames num frames
function UntzSoundMgr:init(sampleRate, numFrames)
    if not MOAIUntzSystem._initialized then
        sampleRate = sampleRate or UntzSoundMgr.SAMPLE_RATE
        numFrames = numFrames or UntzSoundMgr.NUM_FRAMES
        MOAIUntzSystem.initialize(sampleRate, numFrames)
        MOAIUntzSystem._initialized = true
    end
    
    self._soundMap = {}
end

---
-- Load the MOAIUntzSound.
-- @param filePath file path.
-- @return sound
function UntzSoundMgr:loadSound(filePath)
    local sound = MOAIUntzSound.new()
    sound:load(filePath)
    sound:setVolume(1)
    sound:setLooping(false)
    return sound
end

---
-- Return the MOAIUntzSound cached.
-- @param filePath file path.
-- @return sound
function UntzSoundMgr:getSound(filePath)
    filePath = Resources.getResourceFilePath(filePath)
    
    if not self._soundMap[filePath] then
        self._soundMap[filePath] = self:loadSound(filePath)
    end
    
    return self._soundMap[filePath]
end

---
-- Release the MOAIUntzSound.
-- @param filePath file path.
-- @return cached sound.
function UntzSoundMgr:release(filePath)
    local sound = self._soundMap[filePath]
    self._soundMap[filePath] = nil
    return sound
end

---
-- Play the sound.
-- @param sound file path or object.
-- @param volume (Optional)volume. Default value is 1.
-- @param looping (Optional)looping flag. Default value is 'false'.
-- @return Sound object
function UntzSoundMgr:play(sound, volume, looping)
    sound = type(sound) == "string" and self:getSound(sound) or sound
    volume = volume or 1
    looping = looping and true or false
    
    sound:setVolume(volume)
    sound:setLooping(looping)
    sound:play()
    return sound
end

---
-- Pause the sound.
-- @param sound file path or object.
function UntzSoundMgr:pause(sound)
    sound = type(sound) == "string" and self:getSound(sound) or sound
    sound:pause()
end

---
-- Stop the sound.
-- @param sound file path or object.
function UntzSoundMgr:stop(sound)
    sound = type(sound) == "string" and self:getSound(sound) or sound
    sound:stop()
end

---
-- Set the system level volume.
-- @param volume
function UntzSoundMgr:setVolume(volume)
   MOAIUntzSystem.setVolume(volume)
end

---
-- Return the system level volume.
-- @return volume
function UntzSoundMgr:getVolume()
   return MOAIUntzSystem.getVolume()
end


return M