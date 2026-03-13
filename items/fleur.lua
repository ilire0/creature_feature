local fleurMod = RegisterMod("Fleur-de-lis", 1)

local fleurItem = Isaac.GetItemIdByName("Fleur-de-lis")

function fleurMod:addStats(player, flag)
    local fleurAmount = player:GetCollectibleNum(fleurItem)
    if flag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.2 * fleurAmount
    elseif flag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + 0.2 * fleurAmount
    end
end
fleurMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, fleurMod.addStats)

