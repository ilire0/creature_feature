local shoyuMod = RegisterMod("Shoyu", 1)

local shoyuItem = Isaac.GetItemIdByName("Shoyu")

function shoyuMod:addStats(player, flag)
    local shoyuAmount = player:GetCollectibleNum(shoyuItem)
    if flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + 0.5 * shoyuAmount
    elseif flag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.2 * shoyuAmount
    end
end
shoyuMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, shoyuMod.addStats)