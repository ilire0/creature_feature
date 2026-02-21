local GabrielMod = RegisterMod("CF", 1)
local game = Game()

local ATROPAX = Isaac.GetItemIdByName("Aropax")
local GABRIEL_TYPE = Isaac.GetPlayerTypeByName("Gabriel", false)
local GABRIEL_MIN_DAMAGE = 0.8 -- Minimum damage to allow Atropax use

-- =========================
-- ATROPAX USE (DEBUG)
-- =========================
function GabrielMod:OnUseAtropax(_, rng, player, flags, slot)
    -- Only affect Gabriel
    if player:GetPlayerType() ~= GABRIEL_TYPE then
        return true
    end

    local data = player:GetData()

    -- Initialize Atropax stats
    if data.AtropaxTearsUp == nil then data.AtropaxTearsUp = 0 end
    if data.AtropaxDamageDown == nil then data.AtropaxDamageDown = 0 end

    -- === Use current total damage (includes temp effects) ===
    local currentDamage = player.Damage

    -- Check if damage is enough to use the item
    if currentDamage - 0.10 < GABRIEL_MIN_DAMAGE then
        return false
    end

    -- === Apply Atropax effects ===
    data.AtropaxDamageDown = data.AtropaxDamageDown - 0.10
    data.AtropaxTearsUp = data.AtropaxTearsUp + 0.20

    -- Recalculate stats via cache
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
    player:EvaluateItems()

    return true
end

GabrielMod:AddCallback(ModCallbacks.MC_USE_ITEM, GabrielMod.OnUseAtropax, ATROPAX)

-- =========================
-- APPLY STORED STATS (CACHE)
-- =========================
function GabrielMod:OnCache(player, cacheFlag)
    local data = player:GetData()
    if not data.AtropaxDamageDown and not data.AtropaxTearsUp then return end

    -- DAMAGE
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        -- Apply Atropax reductions on top of all current damage (permanent + temporary)
        player.Damage = math.max(GABRIEL_MIN_DAMAGE, player.Damage + (data.AtropaxDamageDown or 0))
    end

    -- TEARS
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        -- Gabriel unlimited fire rate system
        local baseTears = 3.10
        local atropaxBonus = data.AtropaxTearsUp or 0
        local currentTears = 30 / (player.MaxFireDelay + 1)
        local finalTears = baseTears + atropaxBonus + (currentTears - 2.73)
        player.MaxFireDelay = math.max(0, 30 / finalTears - 1)
    end
end

GabrielMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GabrielMod.OnCache)
