local DemonHeadMod = RegisterMod("DemonHeadMod", 1)
local game = Game()

local CollectibleType = {
    DEMON_HEAD = Isaac.GetItemIdByName("Demon Head")
}

-- CONFIG
local SPLIT_COUNT = 2           -- tears per split (lower for multi-shot items)
local MAX_SPLITS = 6            -- per original tear
local MAX_SPLITS_PER_FRAME = 20 -- safety per frame
local MAX_DEMON_HEAD_ALIVE = 50 -- total alive Demon Head tears
local HOMING_STRENGTH = 0.06    -- soft homing
local SPLIT_AGE = 15            -- frames before forced split
local SPLIT_MAXTRAVEL = 120     -- max travel distance for split tears

-- Track splits per original tear
local processedTears = {} -- prevents re-processing
local rootSplitCount = {} -- split count per original tear

local splitsThisFrame = 0 -- reset every frame

-- Reset per room
function DemonHeadMod:OnNewRoom()
    processedTears = {}
    rootSplitCount = {}
    splitsThisFrame = 0
end

DemonHeadMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DemonHeadMod.OnNewRoom)

-- Reset per frame
function DemonHeadMod:OnNewFrame()
    splitsThisFrame = 0
end

DemonHeadMod:AddCallback(ModCallbacks.MC_POST_UPDATE, DemonHeadMod.OnNewFrame)

-- Closest enemy helper
local function GetClosestEnemy(position)
    local enemies = Isaac.FindInRadius(position, 600, EntityPartition.ENEMY)
    local closest = nil
    local minDist = 999999
    for _, enemy in ipairs(enemies) do
        if enemy:IsActiveEnemy() and not enemy:IsDead() then
            local dist = position:Distance(enemy.Position)
            if dist < minDist then
                minDist = dist
                closest = enemy
            end
        end
    end
    return closest
end

-- Count alive Demon Head tears
local function CountDemonHeadTears()
    local tears = Isaac.FindByType(EntityType.ENTITY_TEAR)
    local count = 0
    for _, t in ipairs(tears) do
        local d = t:GetData()
        if d.IsDemonHead then count = count + 1 end
    end
    return count
end

-- Tear Init
function DemonHeadMod:OnTearInit(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(CollectibleType.DEMON_HEAD) then return end

    local data = tear:GetData()
    if not data.RootID then
        data.RootID = tear.InitSeed
        rootSplitCount[data.RootID] = 0
    end

    data.IsDemonHead = true
    data.StartPos = tear.Position
    data.MaxTravel = SPLIT_MAXTRAVEL
    data.Age = 0

    tear.FallingSpeed = -5
    tear.FallingAcceleration = 1.5
    tear.TearFlags = tear.TearFlags | TearFlags.TEAR_PIERCING
end

DemonHeadMod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, DemonHeadMod.OnTearInit)

-- Tear Update + soft homing
function DemonHeadMod:OnTearUpdate(tear)
    local data = tear:GetData()
    if not data.IsDemonHead then return end

    data.Age = (data.Age or 0) + 1

    -- Split if max travel reached OR tear is too old
    if data.StartPos and data.MaxTravel then
        if tear.Position:Distance(data.StartPos) >= data.MaxTravel or data.Age >= SPLIT_AGE then
            tear:Die() -- triggers split
            return
        end
    end

    local target = GetClosestEnemy(tear.Position)
    if target then
        local desired = (target.Position - tear.Position):Normalized() * tear.Velocity:Length()
        tear.Velocity = tear.Velocity:Lerp(desired, HOMING_STRENGTH)
    end
end

DemonHeadMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, DemonHeadMod.OnTearUpdate)

-- Tear Removed / Split
function DemonHeadMod:OnTearRemoved(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if not player or not player:HasCollectible(CollectibleType.DEMON_HEAD) then return end

    local data = tear:GetData()
    if not data.IsDemonHead or not data.RootID then return end

    local rootID = data.RootID

    if rootSplitCount[rootID] >= MAX_SPLITS then return end
    if processedTears[tear.InitSeed] then return end
    if splitsThisFrame >= MAX_SPLITS_PER_FRAME then return end
    if CountDemonHeadTears() >= MAX_DEMON_HEAD_ALIVE then return end

    processedTears[tear.InitSeed] = true

    local tearPos = tear.Position

    -- find valid enemies
    local enemies = Isaac.FindInRadius(tearPos, 600, EntityPartition.ENEMY)
    local validEnemies = {}
    for _, enemy in ipairs(enemies) do
        if enemy:IsActiveEnemy() and not enemy:IsDead() then
            table.insert(validEnemies, enemy)
        end
    end

    for i = 1, SPLIT_COUNT do
        if rootSplitCount[rootID] >= MAX_SPLITS then break end
        if splitsThisFrame >= MAX_SPLITS_PER_FRAME then break end
        if CountDemonHeadTears() >= MAX_DEMON_HEAD_ALIVE then break end

        local target = validEnemies[i]
        local direction
        if target then
            direction = (target.Position - tearPos):Normalized()
        else
            direction = Vector.FromAngle(math.random(0, 360))
        end

        local newTear = player:FireTear(
            tearPos,
            direction * 7,
            false,
            false,
            false,
            player
        )

        local newData = newTear:GetData()
        newData.RootID = rootID
        newData.IsDemonHead = true
        newData.Age = 0

        newTear.CollisionDamage = tear.CollisionDamage * 0.7
        newTear.Scale = 0.7

        rootSplitCount[rootID] = rootSplitCount[rootID] + 1
        splitsThisFrame = splitsThisFrame + 1
    end
end

DemonHeadMod:AddCallback(
    ModCallbacks.MC_POST_ENTITY_REMOVE,
    DemonHeadMod.OnTearRemoved,
    EntityType.ENTITY_TEAR
)
