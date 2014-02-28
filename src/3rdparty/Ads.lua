--------------------------------------------------------------------------------
--
--
--
--------------------------------------------------------------------------------

local Mock = require("Mock")
local AdProvider = require("AdProvider")

local Ads = class()

-- workaround lua bug with math.random
math.random() math.random() math.random()

---
-- Ads - class for ad rotation from several ad SDKs
-- can receive weight config from remote server
local DEFAULT_URL = "pnc.cloudteam.pro/app/ad_test/"

---
-- Supported providers list. Used as keys in configuration table
Ads.CHARTBOOST = "chartboost"
Ads.PLAYHAVEN = "playhaven"
Ads.AD_COLONY = "adcolony"
Ads.APP_FLOOD = "appflood"
Ads.FLURRY = "flurry"
Ads.INMOBI = "inmobi"
Ads.CPIERA = "cpiera"


local ProviderFactory = {
    chartboost = AdProvider.Chartboost,
    playhaven = AdProvider.PlayHaven,
    adcolony = AdProvider.AdColony,
    flurry = AdProvider.FlurryAds,
    inmobi = AdProvider.InMobi,
}


--- 
-- Initialize configuration 
-- @param string url remote configuration server address 
-- @param table providers       initial ad providers configuration. All ad providers in this table will be created. 
--                              Keys are different for each provider (appIds, zones, placements), however 
-- 
-- Example configuration table: 
-- {
--     chartboost = { weight = 1, appId = "id", appSignature = "sign" }, 
--     playhaven = { weight = 1, appId = "id", appSignature = "sign", placement = "place" }, 
--     adcolony = { weight = 1, appId = "id", zones = {"zone1", "zone2"} }, 
--     flurry = { weight = 1, space = "space" }, -- flurry analytics should be initialized before calling this 
-- }
function Ads:init(providers, url)
    self:setProviders(providers)
    
    self.url = url or DEFAULT_URL
    self.os = MOAIAppAndroid and "android" or "ios"
end


function Ads:setProviders(providers)
    self.providers = {}

    for k, v in pairs(providers) do
        local providerClass = ProviderFactory[k]
        if not providerClass then
            print("Provider for key " .. k .. " not found. Maybe it is not implemented")
        else
            self.providers[k] = providerClass(v)
            self.providers[k].active = true
            self.providers[k].adManager = self
        end
    end
end


function Ads:cacheInterstitial()
    for providerName, provider in pairs(self.providers) do
        if not provider:hasCachedInterstitial() then
            provider:cacheInterstitial()
        end
    end
end


function Ads:hasCachedInterstitial()
    for providerName, provider in pairs(self.providers) do
        if provider:hasCachedInterstitial() then
            return true
        end
    end
    return false
end

---
-- Returns true if ad was cached and been showed to the user
function Ads:showInterstitial()
    local queue = self:getProviderQueue()
    print("Provider queue", queue)

    for i, provider in ipairs(queue) do
        print("----- Trying: ", provider.name)
        if provider:hasCachedInterstitial() then
            print("----- Has cached ad: ", provider.name)
            provider:showInterstitial()
            return true
        end
    end

    -- cache all interstitials if nothing been showed
    self:cacheInterstitial()
    return false
end

---
-- Returns a table with providers
-- shuffled, taking into account their weights
function Ads:getProviderQueue()
    local queue = {}
    local providers = table.dup(self.providers)

    local key, prov = self:getProvider(providers)
    while prov do
        queue[#queue + 1] = prov
        providers[key] = nil
        key, prov = self:getProvider(providers)
    end

    return queue
end


function Ads:getProvider(providers)
    local rnd = math.random()
    local total = 0
    for k, provider in pairs(providers) do
        if provider.active then
            total = total + provider.weight
        end
    end

    rnd = rnd * total
    total = 0
    for k, provider in pairs(providers) do
        if provider.active then
            total = total + provider.weight
            if rnd <= total then
                return k, provider
            end
        end
    end
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Weight management from server
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

---
-- Request new weight parameters from server and apply them to current providers
-- Some providers can be removed from pool completely
-- Async
function Ads:updateWeights()
    local httpTask = HttpTask.new()

    httpTask:setUrl(self.url .. "preferences?os=" .. self.os)
    httpTask:setVerb(HttpTask.HTTP_GET)
    httpTask:setCallback(function(task)
        local confStr = task:getString()
        if confStr then
            local conf = MOAIJsonParser.decode(confStr)
            self:onConfigReceived(conf)
        end
    end)
    httpTask:performAsync()
end


function Ads:onConfigReceived(config)
    local res, validConfig = self:validateConfig(config)
    self:applyConfig(validConfig)
end

---
-- @return bool, table  first return value is the result of validation, second value is valid config table. 
--                      valid table is built by deleting any invalid key-value pairs. 
function Ads:validateConfig(config)
    local result = true
    local validConfig = table.dup(config)

    if not config then
        print("Ads: config is nil")
        return false
    end

    for k, v in pairs(config) do
        if not self.providers[k] then
            print("Ads: provider not initialized - " .. k)
            result = false
            validConfig[k] = nil
        end
        if type(v) ~= "number" then
            print("Ads: weight value [" .. tostring(v) .. "] is not a number for provider " .. k)
            result = false
            validConfig[k] = nil
        end
    end

    return result, validConfig
end


function Ads:applyConfig(config)
    for k, v in pairs(self.providers) do
        if config[k] then
            v.weight = config[k]
            v.active = true
        else
            v.active = false
        end
    end
end

return Ads