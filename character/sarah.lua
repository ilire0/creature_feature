local SarahMod = CF
local game = Game()

-- Replace with your actual character ID
local SarahType = Isaac.GetPlayerTypeByName("Sarah", false)

-- Cache tables
local usedTrinketsThisFloor = {}

-- Utility: Check if player is Sarah
local function IsSarah(player)
    return player:GetPlayerType() == SarahType
end

-------------------------------------------------
-- SARAH BASE STATS (Item-Compatible)
-------------------------------------------------

function SarahMod:OnCache(player, cacheFlag)
    if not IsSarah(player) then return end

    if cacheFlag == CacheFlag.CACHE_SPEED then
        -- Isaac base = 1.0
        player.MoveSpeed = player.MoveSpeed - 1.0 + 0.8
    end

    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        -- Isaac base = 3.5
        player.Damage = player.Damage - 3.5 + 3.75
    end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        local currentTears = 30 / (player.MaxFireDelay + 1)
        local adjustedTears = currentTears + (3.25 - 2.73)

        player.MaxFireDelay = math.max(0, 30 / adjustedTears - 1)
    end

    if cacheFlag == CacheFlag.CACHE_RANGE then
        -- Isaac base range values
        player.TearHeight = player.TearHeight - (-23.75) + (-23.75)
        player.TearRange = player.TearRange - 260 + 160
    end
end

SarahMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SarahMod.OnCache)

-------------------------------------------------
-- SARAH STARTS WITH 6D (FULLY CHARGED)
-------------------------------------------------

local SixDID = Isaac.GetItemIdByName("6D")

function SarahMod:OnPlayerInit(player)
    if not IsSarah(player) then return end

    -- Only give item on new run (not continue)
    if game:GetFrameCount() == 0 then
        if not player:HasCollectible(SixDID) then
            player:AddCollectible(SixDID, 0, true)
        end

        local maxCharges = Isaac.GetItemConfig():GetCollectible(SixDID).MaxCharges
        player:SetActiveCharge(maxCharges, ActiveSlot.SLOT_PRIMARY)

        -- Force stat update
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
        player:EvaluateItems()
    end
end

SarahMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, SarahMod.OnPlayerInit)

-------------------------------------------------
-- FLOOR RESET (clear used trinkets & cleared rooms)
-------------------------------------------------

function SarahMod:OnNewFloor()
    usedTrinketsThisFloor = {}

    for i = 0, game:GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if IsSarah(player) then
            -- Remove slot 1 first (Belly Button slot)
            for slot = 1, 0, -1 do
                local trinket = player:GetTrinket(slot)
                if trinket ~= 0 then
                    player:TryRemoveTrinket(trinket)
                end
            end
        end
    end
end

SarahMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, SarahMod.OnNewFloor)

-------------------------------------------------
-- WEIGHTED TRINKET REPLACEMENT
-------------------------------------------------

local function GetWeightedRandomTrinket()
    local itemPool = game:GetItemPool()
    for i = 1, 20 do
        local trinket = itemPool:GetTrinket(false)
        if not usedTrinketsThisFloor[trinket] then
            usedTrinketsThisFloor[trinket] = true
            return trinket
        end
    end
    return itemPool:GetTrinket(false)
end

local function IsQuestItem(collectibleID)
    return collectibleID == CollectibleType.COLLECTIBLE_KNIFE_PIECE_1
        or collectibleID == CollectibleType.COLLECTIBLE_KNIFE_PIECE_2
        or collectibleID == CollectibleType.COLLECTIBLE_DADS_NOTE
        or collectibleID == CollectibleType.COLLECTIBLE_POLAROID
        or collectibleID == CollectibleType.COLLECTIBLE_NEGATIVE
end

function SarahMod:ReplacePedestals()
    local sarahExists = false
    for i = 0, game:GetNumPlayers() - 1 do
        if IsSarah(Isaac.GetPlayer(i)) then
            sarahExists = true
            break
        end
    end
    if not sarahExists then return end

    local room = game:GetRoom()
    local roomType = room:GetType()

    -- Skip shops, black markets, and Devil/Angel rooms
    if roomType == RoomType.ROOM_SHOP
        or roomType == RoomType.ROOM_BLACK_MARKET
        or roomType == RoomType.ROOM_DEVIL
        or roomType == RoomType.ROOM_ANGEL then
        return
    end

    local entities = Isaac.GetRoomEntities()
    for _, entity in ipairs(entities) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            local pickup = entity:ToPickup()
            if pickup and not IsQuestItem(pickup.SubType) then
                local position = pickup.Position
                pickup:Remove()

                local trinketID = GetWeightedRandomTrinket()
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, trinketID, position, Vector.Zero, nil)
            end
        end
    end
end

SarahMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SarahMod.ReplacePedestals)

-------------------------------------------------
-- Shop Item replacement (collectible → trinket, keeping price)
-------------------------------------------------

function SarahMod:ReplaceShopItemsWithTrinkets()
    -- Only run if Sarah exists
    local sarahExists = false
    for i = 0, game:GetNumPlayers() - 1 do
        if IsSarah(Isaac.GetPlayer(i)) then
            sarahExists = true
            break
        end
    end
    if not sarahExists then return end

    local room = game:GetRoom()
    if room:GetType() ~= RoomType.ROOM_SHOP then return end -- Only normal shops

    local entities = Isaac.GetRoomEntities()
    for _, entity in ipairs(entities) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            local pickup = entity:ToPickup()
            if pickup then
                local price = pickup.Price
                local position = pickup.Position
                local shopId = pickup.ShopItemId -- Preserve the shop association
                pickup:Remove()

                local trinketID = GetWeightedRandomTrinket()
                local trinket = Isaac.Spawn(
                    EntityType.ENTITY_PICKUP,
                    PickupVariant.PICKUP_TRINKET,
                    trinketID,
                    position,
                    Vector.Zero,
                    nil
                ):ToPickup()

                -- Preserve shop association and price
                trinket.ShopItemId = shopId or -1
                trinket.Price = price
                trinket.AutoUpdatePrice = true
            end
        end
    end
end

SarahMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SarahMod.ReplaceShopItemsWithTrinkets)

-------------------------------------------------
-- DEVIL / ANGEL ROOM TRINKET LIMIT (SARAH ONLY)
-------------------------------------------------

function SarahMod:ReplaceDealsWithTrinketLimit()
    -- Only run if Sarah exists
    local sarahExists = false
    for i = 0, game:GetNumPlayers() - 1 do
        if IsSarah(Isaac.GetPlayer(i)) then
            sarahExists = true
            break
        end
    end
    if not sarahExists then return end

    local room = game:GetRoom()
    local roomType = room:GetType()
    if roomType ~= RoomType.ROOM_DEVIL and roomType ~= RoomType.ROOM_ANGEL then return end

    local entities = Isaac.GetRoomEntities()
    local trinketSpawned = false

    for _, entity in ipairs(entities) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            local pickup = entity:ToPickup()
            if pickup then
                local price = pickup.Price
                local position = pickup.Position

                -- Only spawn 1 trinket for the first collectible
                if not trinketSpawned then
                    local trinketID = GetWeightedRandomTrinket()
                    local trinket = Isaac.Spawn(
                        EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_TRINKET,
                        trinketID,
                        position,
                        Vector.Zero,
                        nil
                    ):ToPickup()
                    trinket.Price = price
                    trinket.AutoUpdatePrice = true
                    trinketSpawned = true
                end

                -- Remove the collectible anyway
                pickup:Remove()
            end
        end
    end
end

-- Register callback for Devil/Angel rooms
SarahMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SarahMod.ReplaceDealsWithTrinketLimit)
