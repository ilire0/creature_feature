local spaghettiMonsterMod = RegisterMod("Spaghetti Monster", 1)

local spaghettiMonsterItem = Isaac.GetItemIdByName("Lil' Spaghetti Monster")
local spaghettiMonsterConfig = Isaac.GetItemConfig():GetCollectible(spaghettiMonsterItem)
local spaghettiMonsterVariant = Isaac.GetEntityVariantByName("Lil' Spaghetti Monster")

local tearSpeed = 10

function spaghettiMonsterMod:EvaluateCache(player)
    local effects = player:GetEffects()
    local count = effects:GetCollectibleEffectNum(spaghettiMonsterItem) + player:GetCollectibleNum(spaghettiMonsterItem)
    local rng = RNG()
    local seed = math.max(Random(), 1)
    rng:SetSeed(seed, 35)

    player:CheckFamiliar(spaghettiMonsterVariant, count, rng, spaghettiMonsterConfig)
end
spaghettiMonsterMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, spaghettiMonsterMod.EvaluateCache, CacheFlag.CACHE_FAMILIARS)

function spaghettiMonsterMod:FamiliarInit(familiar)
    familiar:AddToFollowers()
    familiar.FireCooldown = familiar.Player.MaxFireDelay
end
spaghettiMonsterMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, spaghettiMonsterMod.FamiliarInit, spaghettiMonsterVariant)

function spaghettiMonsterMod:UpdateMonster(familiar)
    local sprite = familiar:GetSprite()
    local player = familiar.Player

    local fireDirection = player:GetFireDirection()
    local doFlip = false
    local dir
    local shootAnim

    if fireDirection == Direction.LEFT then
        dir = Vector(-1, 0)
        shootAnim = "FloatShootSide"
        doFlip = true
    elseif fireDirection == Direction.RIGHT then
        dir = Vector(1, 0)
        shootAnim = "FloatShootSide"
    elseif fireDirection == Direction.UP then
        dir = Vector(0, -1)
        shootAnim = "FloatShootUp"
    elseif fireDirection == Direction.DOWN then
        dir = Vector(0, 1)
        shootAnim = "FloatShootDown"
    end

    if dir ~= nil and (familiar.FireCooldown <= 0 or (familiar.FireCooldown == player.MaxFireDelay and player:GetShootingInput() ~= Vector.Zero and player:CanShoot())) then
        local velocity = dir * tearSpeed + player:GetTearMovementInheritance(dir)
        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, familiar.Position, velocity, familiar):ToTear()
        tear.CollisionDamage = player.Damage * 0.25
        sprite.FlipX = doFlip
        sprite:Play(shootAnim, true)
        familiar.FireCooldown = player.MaxFireDelay
    end

    if sprite:IsFinished() then
        sprite:Play("FloatDown")
    end

    familiar:FollowParent()
    if player:GetFireDirection() == Direction.NO_DIRECTION then
        familiar.FireCooldown = player.MaxFireDelay
    else
        familiar.FireCooldown = familiar.FireCooldown - 1
    end
end
spaghettiMonsterMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, spaghettiMonsterMod.UpdateMonster, spaghettiMonsterVariant)