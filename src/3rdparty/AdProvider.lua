--------------------------------------------------------------------------------
-- Ad Providers: adcolony, chartboost, flurry
--
--
--------------------------------------------------------------------------------

local AdProvider = {}

local Mock = require("Mock")

---
-- Required methods for ad provider object:
-- 
-- cacheInterstitial        : preload new ad
-- hasCachedInterstitial    : is ad prealoded and ready to be showed
-- showInterstitial         : show ad
-- 
-- weight member : provider weight

local MOAIChartboost    = MOAIChartboostIOS or MOAIChartboostAndroid
local MOAIAdColony      = MOAIAdColonyIOS   or MOAIAdColonyAndroid
local MOAIPlayHaven     = MOAIPlayHavenIOS  or MOAIPlayHavenAndroid
local MOAIFlurryAds     = MOAIFlurryAdsIOS  or MOAIFlurryAdsAndroid
local MOAIInMobi        = MOAIInMobiIOS     or MOAIInMobiAndroid


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- AdProviderBase
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local AdProviderBase = class()
AdProvider.AdProviderBase = AdProviderBase

function AdProviderBase:init(params)
    self.disableAnimation = params.disableAnimation == nil and true or params.disableAnimation
    self.disableSound = params.disableSound == nil and true or params.disableSound
end

---
-- Preloads ad for future use
function AdProviderBase:cacheInterstitial()
    assert(true, "Must override this method")
end

---
-- Show preloaded ad
function AdProviderBase:showInterstitial()
    assert(true, "Must override this method")
end

---
-- Check whether ad is loaded and ready to be displayed
function AdProviderBase:hasCachedInterstitial()
    assert(true, "Must override this method")
end


function AdProviderBase:onWillShowInterstitial()
    print("---+++--- will show ad ", self.name)

    if self.disableAnimation then
        MOAISim.pauseTimer(true)
    end

    if self.disableSound and SoundMgr then
        self.initialVolume = SoundMgr:getVolume()
        SoundMgr:setVolume(0)
    end
end

function AdProviderBase:onDidDismissInterstitial()
    print("---+++--- did dismiss ad ", self.name)

    if self.disableAnimation then
        MOAISim.pauseTimer(false)
    end

    if self.disableSound and SoundMgr then
        SoundMgr:setVolume(self.initialVolume)
    end

    if self.adManager then
        self.adManager:cacheInterstitial()
    end
end

function AdProviderBase:onLoadFailed()
    print("---+++--- load failed ", self.name)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- AdColony
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local AdColony = class(AdProviderBase)
AdProvider.AdColony = AdColony

AdColony.name = "adcolony ads"

---
-- Adcolony
function AdColony:init(params)
    AdProviderBase.init(self, params)

    self.provider = MOAIAdColony or Mock("AdColony", true)
    
    local appId = assert(params.appId, "AdColony appId is required")
    local zones = assert(params.zones, "AdColony zones table is required")
    local weight = params.weight

    self.zone = table.random(zones)
    self.weight = weight or 1

    if self.provider then
        self.provider.init(appId, zones)
        self.provider.setListener(self.provider.VIDEO_BEGAN_IN_ZONE, function() self:onWillShowInterstitial() end)
        self.provider.setListener(self.provider.VIDEO_ENDED_IN_ZONE, function() self:onDidDismissInterstitial() end)
        self.provider.setListener(self.provider.VIDEO_FAILED_IN_ZONE, function() self:onLoadFailed() end)
        -- self.provider.setListener(MOAIAdColony.VIDEO_PAUSED_IN_ZONE, function() self:onInterstitialDismissed() end)
        -- self.provider.setListener(MOAIAdColony.VIDEO_RESUMED_IN_ZONE, function() self:onInterstitialDismissed() end)
        -- self.provider.setListener(MOAIAdColony.AVAILABILITY_CHANGE, function() self:onInterstitialDismissed() end)
        -- self.provider.setListener(MOAIAdColony.REWARD, function() self:onInterstitialDismissed() end)
    end
end

function AdColony:cacheInterstitial()

end

function AdColony:hasCachedInterstitial()
    return self.provider.videoReadyForZone(self.zone)
end

function AdColony:showInterstitial()
    self.provider.playVideo(self.zone, false, false)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Chartboost
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local Chartboost = class(AdProviderBase)
AdProvider.Chartboost = Chartboost

Chartboost.name = "chartboost ads"

---
-- chartboost
function Chartboost:init(params)
    AdProviderBase.init(self, params)
    
    self.provider = MOAIChartboost or Mock("Chartboost", true)

    local appId = assert(params.appId, "Chartboost appId is required")
    local appSignature = assert(params.appSignature, "Chartboost appSignature is required")
    local weight = params.weight

    self.weight = weight or 1

    if self.provider then
        self.provider.init(appId, appSignature)
        -- self.provider.setListener(MOAIChartBoost.INTERSTITIAL_LOAD_FAILED, function() self:onLoadFailed() end)
        self.provider.setListener(self.provider.INTERSTITIAL_DISMISSED, function() self:onDidDismissInterstitial() end)
        self.provider.setListener(self.provider.INTERSTITIAL_WILL_SHOW, function() self:onWillShowInterstitial() end)
    end
end

function Chartboost:cacheInterstitial()
    self.provider.loadInterstitial()    
end

function Chartboost:hasCachedInterstitial()
    return self.provider.hasCachedInterstitial()
end

function Chartboost:showInterstitial()
    self.provider.showInterstitial()
end


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- InMobi
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local InMobi = class(AdProviderBase)
AdProvider.InMobi = InMobi

InMobi.name = "inmobi ads"

---
-- InMobi
function InMobi:init(params)
    AdProviderBase.init(self, params)
    
    self.provider = MOAIInMobi or Mock("InMobi", true)

    local appId = assert(params.appId, "InMobi appId is required")
    local weight = params.weight

    self.weight = weight or 1

    if self.provider then
        self.provider.init(appId)
        -- self.provider.setListener(MOAIInMobi.INTERSTITIAL_LOAD_FAILED, function() self:onLoadFailed() end)
        self.provider.setListener(self.provider.INTERSTITIAL_DISMISSED, function() self:onDidDismissInterstitial() end)
        self.provider.setListener(self.provider.INTERSTITIAL_WILL_SHOW, function() self:onWillShowInterstitial() end)
    end
end

function InMobi:cacheInterstitial()
    self.provider.loadInterstitial()
end

function InMobi:hasCachedInterstitial()
    return self.provider.hasCachedInterstitial()
end

function InMobi:showInterstitial()
    self.provider.showInterstitial()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- PlayHaven
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local PlayHaven = class(AdProviderBase)
AdProvider.PlayHaven = PlayHaven

PlayHaven.name = "playhaven ads"

---
-- PlayHaven
function PlayHaven:init(params)
    AdProviderBase.init(self, params)
    
    self.provider = MOAIPlayHaven or Mock("PlayHaven", true)

    local appId = assert(params.appId, "PlayHaven appId is required")
    local appSignature = assert(params.appSignature, "PlayHaven appSignature is required")
    local placement = params.placement
    local weight = params.weight

    self.weight = weight or 1
    self.placement = placement or "all"

    if self.provider then
        self.provider.init(appId, appSignature)
        self.provider.setListener(self.provider.INTERSTITIAL_WILL_DISPLAY,  function() self:onWillShowInterstitial() end)
        self.provider.setListener(self.provider.INTERSTITIAL_DID_DISMISS,   function() self:onDidDismissInterstitial() end)
    end
end

function PlayHaven:cacheInterstitial()
    self.provider.cacheContent(self.placement)
end

function PlayHaven:hasCachedInterstitial()
    return self.provider.hasCachedContent()
end

function PlayHaven:showInterstitial()
    self.provider.showContent()
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Fluryy Ads
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
local FlurryAds = class(AdProviderBase)
AdProvider.FlurryAds = FlurryAds

FlurryAds.name = "flurry ads"

---
-- Initialize flurry ads. Requires flurry analytics module. 
-- IMPORTANT: Must be called after initializing flurry analytics
-- @param string space  Ad space to use. Can be configured in 
function FlurryAds:init(params)
    AdProviderBase.init(self, params)
    
    self.provider = MOAIFlurryAds or Mock("FlurryAds", true)

    local space = assert(params.space, "FlurryAds space is required")
    local weight = params.weight

    self.weight = weight or 1

    if self.provider then
        self.provider.init(space)
        self.provider.setListener(self.provider.AD_LOAD_FAILED, function() self:onLoadFailed() end)
        self.provider.setListener(self.provider.AD_WILL_SHOW,   function() self:onWillShowInterstitial() end)
        self.provider.setListener(self.provider.AD_DISMISSED,   function() self:onDidDismissInterstitial() end)
    end
end

function FlurryAds:cacheInterstitial()
    self.provider.loadAd()
end

function FlurryAds:hasCachedInterstitial()
    return self.provider.hasCachedAd()
end

function FlurryAds:showInterstitial()
    self.provider.showAd()
end

return AdProvider