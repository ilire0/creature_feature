local Mod = RegisterMod("CF", 1)
local game = Game()

-------------------------------------------------
-- ITEM SETUP
-------------------------------------------------
local MyItemID = Isaac.GetItemIdByName("Cigarette Bud")

-------------------------------------------------
-- DAMAGE CACHE (stackable)
-------------------------------------------------
function Mod:CigaretteBudEvaluateCache(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        local count = player:GetCollectibleNum(MyItemID)
        if count > 0 then
            player.Damage = player.Damage + (1.00 * count)
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.CigaretteBudEvaluateCache)

-------------------------------------------------
-- ONE-TIME BLACK HEART ON PICKUP
-------------------------------------------------
function Mod:CigaretteBudPostUpdate(player)
    local data = player:GetData()
    if player:HasCollectible(MyItemID) and not data.CigaretteBud_HPGiven then
        player:AddBlackHearts(2) -- 1 full black heart
        data.CigaretteBud_HPGiven = true
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.CigaretteBudPostUpdate)

-------------------------------------------------
-- BURN EFFECT + ASCHGRAUE TRÄNEN
-------------------------------------------------
function Mod:CigaretteBudPostTear(tear)
    local player = tear.SpawnerEntity
    if player and player:ToPlayer() then
        player = player:ToPlayer()
        if player:HasCollectible(MyItemID) then
            -- Luck-based burn chance
            local luck = player.Luck
            local chance = 5 + luck * 2 -- 5% base + 2% per luck
            if math.random(100) <= chance then
                tear:AddTearFlags(TearFlags.TEAR_BURN)
            end

            -- Aschegrau-Farbe
            tear.Color = Color(0.5, 0.5, 0.5, 1, 0, 0, 0) -- RGBA, 0.5 = Grau
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.CigaretteBudPostTear)
