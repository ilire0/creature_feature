local GabrielMod = RegisterMod("CF", 1)
local game = Game()


local GABRIEL_TYPE = Isaac.GetPlayerTypeByName("Gabriel", false)
local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/gabriel_hair.anm2")

function GabrielMod:OnGabrielInit(player)
    if player:GetPlayerType() == GABRIEL_TYPE then
        player:AddNullCostume(hairCostume)
    end
end

GabrielMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, GabrielMod.OnGabrielInit)

function GabrielMod:OnCache(player, cacheFlag)
    if player:GetPlayerType() ~= GABRIEL_TYPE then
        return
    end

    -- DAMAGE (Base Isaac damage is 3.5)
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + (2.20 - 3.5)
    end

    -- TEARS (Base Isaac is 2.73 tears)
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        local targetTears = 3.10
        player.MaxFireDelay = (30 / targetTears) - 1
    end

    -- SPEED (Base Isaac is 1.00)
    if cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + (1.10 - 1.00)
    end

    -- RANGE (Base Isaac is 6.5)
    if cacheFlag == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange + ((7.00 - 6.5) * 40)
    end

    -- SHOT SPEED (Base Isaac is 1.00)
    if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + (1.00 - 1.00)
    end

    -- LUCK (Base Isaac is 0)
    if cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck - 0.5
    end
end

GabrielMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GabrielMod.OnCache)
