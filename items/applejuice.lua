local appleJuiceMod = RegisterMod("Apple Juice", 1)

local appleJuiceItem = Isaac.GetItemIdByName("Apple Juice")

function appleJuiceMod:addStats(player, flag)
    local appleJuiceAmount = player:GetCollectibleNum(appleJuiceItem)
    if flag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.2 * appleJuiceAmount
    elseif flag == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + 2 * 40 * appleJuiceAmount
    end
end
appleJuiceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, appleJuiceMod.addStats)