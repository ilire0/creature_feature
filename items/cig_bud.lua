local Mod = RegisterMod("CF", 1)
local game = Game()

-------------------------------------------------
-- ITEM SETUP
-------------------------------------------------
local MyItemID = Isaac.GetItemIdByName("Cigarette Bud") -- Replace with your item name

-------------------------------------------------
-- DAMAGE CACHE
-------------------------------------------------
function Mod:CigaretteBudEvaluateCache(player, cacheFlag)
    if player:HasCollectible(MyItemID) then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 1.10
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.CigaretteBudEvaluateCache)

-------------------------------------------------
-- ONE-TIME HP UP ON PICKUP
-------------------------------------------------
function Mod:CigaretteBudPostUpdate(player)
    if player:HasCollectible(MyItemID) then
        local data = player:GetData()
        if not data.CigaretteBud_HPGiven then
            -- Heal 1 full heart
            player:AddBlackHearts(2) -- adds 1 full black heart -- heals 1 red heart
            data.CigaretteBud_HPGiven = true
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.CigaretteBudPostUpdate)
