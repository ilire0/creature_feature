local Mod = RegisterMod("CF", 1)
local game = Game()

-------------------------------------------------
-- ITEM SETUP
-------------------------------------------------
local MyItemID = Isaac.GetItemIdByName("Pomegranate") -- Replace with your item name

-------------------------------------------------
-- DAMAGE CACHE
-------------------------------------------------
function Mod:PomegranateEvaluateCache(player, cacheFlag)
    if player:HasCollectible(MyItemID) then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 1.10
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.PomegranateEvaluateCache)

-------------------------------------------------
-- ONE-TIME HP UP ON PICKUP
-------------------------------------------------
function Mod:PomegranatePostUpdate(player)
    if player:HasCollectible(MyItemID) then
        local data = player:GetData()
        if not data.Pomegranate_HPGiven then
            -- Heal 1 full heart
            player:AddHearts(24) -- heals 1 red heart
            data.Pomegranate_HPGiven = true
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.PomegranatePostUpdate)
