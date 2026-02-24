local Mod = RegisterMod("CF", 1)
local game = Game()

-------------------------------------------------
-- IDS
-------------------------------------------------
local DusterType = Isaac.GetPlayerTypeByName("Duster", false)
local JamID = Isaac.GetItemIdByName("Jam")

-- Track jam buff per player
local JamBuffActive = {}

-------------------------------------------------
-- USE ITEM (THROW JAM)
-------------------------------------------------
function Mod:OnUseJam(itemID, rng, player, flags, slot)
    if itemID ~= JamID then return end

    local direction = player:GetAimDirection()
    if direction:Length() == 0 then
        direction = Vector(0, 1)
    end

    -- Spawn a custom effect
    local jar = Isaac.Spawn(
        EntityType.ENTITY_EFFECT,
        EffectVariant.BRIMSTONE_SWIRL, -- Use a generic effect variant as placeholder
        0,
        player.Position,
        direction:Resized(13),
        player
    ):ToEffect()

    if jar then
        jar.SpriteScale = Vector(1, 1)
        jar.Scale = 1

        -- Replace sprite with custom animation
        local sprite = jar:GetSprite()
        sprite:Load("gfx/effects/jam.anm2", true) -- <-- your jam.anm2
        sprite:Play("Idle")                       -- Make sure your .anm2 has an 'Idle' animation

        local data = jar:GetData()
        data.Owner = player
        data.IsJamJar = true
    end

    return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.OnUseJam, JamID)

-------------------------------------------------
-- JAR UPDATE
-------------------------------------------------
function Mod:JamJarUpdate(effect)
    if effect.Variant ~= EffectVariant.BRIMSTONE_SWIRL then return end
    local data = effect:GetData()
    if not data.IsJamJar then return end

    local room = game:GetRoom()

    -- Fly forward
    effect.Position = effect.Position + effect.Velocity
    effect.SpriteRotation = effect.SpriteRotation + effect.Velocity:Length() * 4
    effect.Velocity = effect.Velocity * 0.95

    -- Wall collision
    if room:GetGridCollisionAtPos(effect.Position) ~= GridCollisionClass.COLLISION_NONE then
        Mod:BreakJar(effect)
        return
    end

    -- Enemy collision
    local enemies = Isaac.FindInRadius(effect.Position, 20, EntityPartition.ENEMY)
    for _, enemy in ipairs(enemies) do
        if enemy:IsVulnerableEnemy() and not enemy:IsDead() then
            Mod:BreakJar(effect)
            return
        end
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Mod.JamJarUpdate)

-------------------------------------------------
-- BREAK JAR
-------------------------------------------------
function Mod:BreakJar(effect)
    if not effect:Exists() then return end
    local data = effect:GetData()
    local player = data.Owner
    local pos = effect.Position

    if not player or not player:Exists() then
        effect:Remove()
        return
    end

    -- Glass shatter sound
    SFXManager():Play(SoundEffect.SOUND_GLASS_BREAK, 1.0, 0, false, 1.0)

    -- Small explosion
    Isaac.Explode(pos, player, 40)

    -- Glass shard burst
    for i = 0, 7 do
        local angle = i * 45
        local velocity = Vector.FromAngle(angle):Resized(7)
        local shard = Isaac.Spawn(
            EntityType.ENTITY_TEAR,
            TearVariant.ICE,
            0,
            pos,
            velocity,
            player
        ):ToTear()
        shard.Scale = 0.8
        shard.CollisionDamage = player.Damage * 0.75
        shard.Color = Color(1, 1, 1, 1, 0, 0, 0)
        shard.FallingAcceleration = 0
        shard.FallingSpeed = 0
    end

    -- Remove jar immediately to avoid visual lingering/blink
    effect:Remove()

    -- Spawn Lemon Party creep safely
    local creepEntity = Isaac.Spawn(
        EntityType.ENTITY_EFFECT,
        EffectVariant.PLAYER_CREEP_LEMON_PARTY,
        0,
        pos,
        Vector.Zero,
        player
    )

    local creep = creepEntity:ToEffect()
    if creep then
        creep.SpriteScale = Vector(1, 1)
        creep.Color = Color(1, 0.2, 0.2, 1, 0, 0, 0) -- red tint
        creep.Timeout = 120                          -- 2 seconds
        creep:GetData().JamCreep = true
    end
end

-------------------------------------------------
-- JAM BUFF DETECTION
-------------------------------------------------
function Mod:PostUpdate()
    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:GetPlayerType() ~= DusterType then goto continue end

        local inJam = false
        local creeps = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_LEMON_PARTY)

        for _, creep in ipairs(creeps) do
            local data = creep:GetData()
            if data.JamCreep then
                local radius = creep.Size
                if player.Position:Distance(creep.Position) <= radius then
                    inJam = true
                    break
                end
            end
        end

        if inJam and not JamBuffActive[i] then
            JamBuffActive[i] = true
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            player:EvaluateItems()
        elseif not inJam and JamBuffActive[i] then
            JamBuffActive[i] = false
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:AddCacheFlags(CacheFlag.CACHE_SPEED)
            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            player:EvaluateItems()
        end

        ::continue::
    end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Mod.PostUpdate)

-------------------------------------------------
-- APPLY BUFF STATS
-------------------------------------------------
function Mod:EvaluateCache(player, cacheFlag)
    if player:GetPlayerType() ~= DusterType then return end

    local index = player.ControllerIndex
    if not JamBuffActive[index] then return end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + 1.0
    elseif cacheFlag == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.3
    elseif cacheFlag == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + 1
    end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.EvaluateCache)
