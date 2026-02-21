local GabrielMod = RegisterMod("CF", 1)
local game = Game()

local GABRIEL_TYPE = Isaac.GetPlayerTypeByName("Gabriel", false)
local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/gabriel_hair.anm2")
local ATROPAX = Isaac.GetItemIdByName("Aropax")

-- =========================
-- INIT
-- =========================
function GabrielMod:OnGabrielInit(player)
    if player:GetPlayerType() == GABRIEL_TYPE then
        -- Hair costume
        player:AddNullCostume(hairCostume)

        -- Give Atropax at start if not owned
        if not player:HasCollectible(ATROPAX) then
            player:AddCollectible(ATROPAX, 0, true)
        end

        -- Initialize custom data
        local data = player:GetData()
        if not data.GabrielTears then data.GabrielTears = 3.10 end
        if not data.AtropaxTearsUp then data.AtropaxTearsUp = 0 end
        if not data.AtropaxDamageDown then data.AtropaxDamageDown = 0 end

        -- Force cache update
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end

GabrielMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, GabrielMod.OnGabrielInit)

-- =========================
-- CACHE: STATS + UNCAPPED TEARS
-- =========================
function GabrielMod:OnCache(player, cacheFlag)
    if player:GetPlayerType() ~= GABRIEL_TYPE then return end
    local data = player:GetData()

    -- DAMAGE
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        local reduction = data.AtropaxDamageDown or 0
        -- Add reduction to current player damage (includes collectibles)
        player.Damage = math.max(0.8, player.Damage + reduction)
    end

    -- SPEED
    if cacheFlag == CacheFlag.CACHE_SPEED then
        -- Base Gabriel bonus + additive to items
        player.MoveSpeed = player.MoveSpeed + (1.10 - 1.0)
    end

    -- RANGE
    if cacheFlag == CacheFlag.CACHE_RANGE then
        -- Add Gabriel base range bonus (scale for game units)
        player.TearRange = player.TearRange + ((7.0 - 6.5) * 40)
    end

    -- SHOT SPEED
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + (1.0 - 1.0) -- no base bonus, safe additive
    end

    -- LUCK
    if cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + (-0.5 - 0)
    end

    -- TRUE UNCAPPED TEARS
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        local baseTears = data.GabrielTears or 3.10
        local atropaxBonus = data.AtropaxTearsUp or 0

        -- Calculate current tears from items (including vanilla bonuses)
        local currentTears = 30 / (player.MaxFireDelay + 1)
        local finalTears = baseTears + atropaxBonus + (currentTears - 2.73)

        -- Set MaxFireDelay with no soft cap
        player.MaxFireDelay = math.max(0, 30 / finalTears - 1)
    end
end

GabrielMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GabrielMod.OnCache)
