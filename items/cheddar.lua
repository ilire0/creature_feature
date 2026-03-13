local cheddarMod = RegisterMod("Cheddar", 1)

local cheddarItem = Isaac.GetItemIdByName("A Slice of Cheddar")

function cheddarMod:addStats(player, flag)
    local cheddars = player:GetCollectibleNum(cheddarItem)
    if flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + 0.9 * cheddars
    elseif flag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + 0.2 * cheddars
    end
end
cheddarMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cheddarMod.addStats)