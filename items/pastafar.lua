local pastafarMod = RegisterMod("Pastafarianism", 1)

local pastafarItem = Isaac.GetItemIdByName("Pastafarianism")

function pastafarMod:addStats(player, flag)
    local pastafarAmount = player:GetCollectibleNum(pastafarItem)
    if flag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + 1 * pastafarAmount
    end
end
pastafarMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, pastafarMod.addStats)