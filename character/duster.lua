local Mod = RegisterMod("CF", 1)
local game = Game()

-- Character ID
local DusterType = Isaac.GetPlayerTypeByName("Duster", false)
local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/duster_head.png")
-- Starting Item (Jam)
local JamID = Isaac.GetItemIdByName("Jam")

-------------------------------------------------
-- DUSTER INIT (COSTUME)
-------------------------------------------------
function Mod:OnDusterInit(player)
    if player:GetPlayerType() == DusterType then
        player:AddNullCostume(hairCostume)
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.OnDusterInit)

-------------------------------------------------
-- GIVE STARTING ITEM FULLY CHARGED
-------------------------------------------------
function Mod:OnPlayerInit(player)
    if player:GetPlayerType() ~= DusterType then return end

    -- Only give item on new run (not continue)
    if game:GetFrameCount() == 0 then
        if not player:HasCollectible(JamID) then
            player:AddCollectible(JamID, 0, true)
        end

        -- Fully charge Jam
        local maxCharges = Isaac.GetItemConfig():GetCollectible(JamID).MaxCharges
        player:SetActiveCharge(maxCharges, ActiveSlot.SLOT_PRIMARY, true)
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.OnPlayerInit)

-------------------------------------------------
-- BASE STATS
-------------------------------------------------
function Mod:EvaluateCache(player, cacheFlag)
    if player:GetPlayerType() ~= DusterType then return end

    if cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = 1.10
    elseif cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = 3.40
    elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = 9 -- Tears ~2.85
    elseif cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearRange = 6.60 * 40
    elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = 1.10
    elseif cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = 1
    end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.EvaluateCache)
