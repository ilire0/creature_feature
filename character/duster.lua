local Mod = RegisterMod("CF", 1)
local game = Game()

-- Character ID
local DusterType = Isaac.GetPlayerTypeByName("Duster", false)
-- Starting Item (Jam)
local JamID = Isaac.GetItemIdByName("Jam")

-------------------------------------------------
-- DUSTER INIT (COSTUME & ITEMS)
-------------------------------------------------
function Mod:OnDusterInit(player)
    if player:GetPlayerType() ~= DusterType then return end

    -- 1. APPLY COSTUME
    -- This path must match exactly: anm2root + anm2path from your XML
    local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/duster.anm2")

    if hairCostume ~= -1 then
        player:AddNullCostume(hairCostume)
    else
        -- If this prints, the game can't see "gfx/characters/duster.anm2" in your costumes2.xml
        Isaac.ConsoleOutput("Error: Duster costume not found at gfx/characters/duster.anm2\n")
    end

    -- 2. GIVE STARTING ITEM (Only on new runs)
    if game:GetFrameCount() == 0 then
        if not player:HasCollectible(JamID) then
            player:AddCollectible(JamID, 0, true)
        end

        -- Fully charge Jam
        local config = Isaac.GetItemConfig():GetCollectible(JamID)
        if config then
            player:SetActiveCharge(config.MaxCharges, ActiveSlot.SLOT_PRIMARY, true)
        end
    end
end

-- CRITICAL: You must register the callback for the function to run!
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
