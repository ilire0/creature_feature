local Mod = CF
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
-- BASE STATS (Item Compatible)
-------------------------------------------------

local ISAAC_BASE_DAMAGE = 3.5
local ISAAC_BASE_SPEED = 1.0
local ISAAC_BASE_SHOTSPEED = 1.0
local ISAAC_BASE_LUCK = 0
local ISAAC_BASE_FIREDELAY = (30 / 2.73) - 1
local ISAAC_BASE_RANGE = 260

-- Duster desired base stats
local DUSTER_DAMAGE = 3.40
local DUSTER_SPEED = 1.10
local DUSTER_SHOTSPEED = 1.10
local DUSTER_LUCK = 1
local DUSTER_FIREDELAY = (30 / 2.85) - 1
local DUSTER_RANGE = 6.60 * 40 -- matches your design

function Mod:EvaluateCache(player, cacheFlag)
    if player:GetPlayerType() ~= DusterType then return end

    if cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed - ISAAC_BASE_SPEED + DUSTER_SPEED
    end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage - ISAAC_BASE_DAMAGE + DUSTER_DAMAGE
    end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay - ISAAC_BASE_FIREDELAY + DUSTER_FIREDELAY
    end

    if cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange - ISAAC_BASE_RANGE + DUSTER_RANGE
    end

    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed - ISAAC_BASE_SHOTSPEED + DUSTER_SHOTSPEED
    end

    if cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck - ISAAC_BASE_LUCK + DUSTER_LUCK
    end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.EvaluateCache)
