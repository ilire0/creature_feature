local SarahMod = RegisterMod("CF", 1)
local game = Game()

-------------------------------------------------
-- ITEM SETUP
-------------------------------------------------
local MyItemID = Isaac.GetItemIdByName("Blueberries") -- Replace with your item name

-------------------------------------------------
-- DAMAGE CACHE
-------------------------------------------------
function SarahMod:BlueberryEvaluateCache(player, cacheFlag)
    if player:HasCollectible(MyItemID) then
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 0.20
        end
    end
end

SarahMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SarahMod.BlueberryEvaluateCache)

-------------------------------------------------
-- ONE-TIME HP UP ON PICKUP
-------------------------------------------------
function SarahMod:BlueberryPostUpdate(player)
    if player:HasCollectible(MyItemID) then
        local data = player:GetData()
        if not data.Blueberry_HPGiven then
            -- Give +1 heart container
            player:AddMaxHearts(2) -- adds 1 full red heart container
            -- Heal 1 full heart
            player:AddHearts(2)    -- heals 1 red heart
            data.Blueberry_HPGiven = true
        end
    end
end

SarahMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, SarahMod.BlueberryPostUpdate)
