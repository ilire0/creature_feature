local SarahMod = RegisterMod("CF", 1)
local game = Game()

-------------------------------------------------
-- ITEM SETUP
-------------------------------------------------

local SixDID = Isaac.GetItemIdByName("6D")

-------------------------------------------------
-- QUEST ITEM CHECK
-------------------------------------------------

local function IsQuestItem(id)
    return id == CollectibleType.COLLECTIBLE_KNIFE_PIECE_1
        or id == CollectibleType.COLLECTIBLE_KNIFE_PIECE_2
        or id == CollectibleType.COLLECTIBLE_DADS_NOTE
        or id == CollectibleType.COLLECTIBLE_POLAROID
        or id == CollectibleType.COLLECTIBLE_NEGATIVE
        or id == CollectibleType.COLLECTIBLE_KEY_PIECE_1
        or id == CollectibleType.COLLECTIBLE_KEY_PIECE_2
end

-------------------------------------------------
-- ROOM ITEM POOL DETECTION
-------------------------------------------------

local function GetRoomItemPool()
    local level = game:GetLevel()
    local room = game:GetRoom()
    local roomDesc = level:GetCurrentRoomDesc()

    if game:IsGreedMode() then
        if room:GetType() == RoomType.ROOM_SHOP then
            return ItemPoolType.POOL_GREED_SHOP
        else
            return ItemPoolType.POOL_GREED_TREASURE
        end
    end

    local roomType = room:GetType()

    if roomType == RoomType.ROOM_TREASURE then
        return ItemPoolType.POOL_TREASURE
    elseif roomType == RoomType.ROOM_BOSS then
        return ItemPoolType.POOL_BOSS
    elseif roomType == RoomType.ROOM_SHOP then
        return ItemPoolType.POOL_SHOP
    elseif roomType == RoomType.ROOM_DEVIL then
        return ItemPoolType.POOL_DEVIL
    elseif roomType == RoomType.ROOM_ANGEL then
        return ItemPoolType.POOL_ANGEL
    elseif roomType == RoomType.ROOM_SECRET then
        return ItemPoolType.POOL_SECRET
    elseif roomType == RoomType.ROOM_SUPERSECRET then
        return ItemPoolType.POOL_ULTRA_SECRET
    elseif roomType == RoomType.ROOM_PLANETARIUM then
        return ItemPoolType.POOL_PLANETARIUM
    elseif roomType == RoomType.ROOM_LIBRARY then
        return ItemPoolType.POOL_LIBRARY
    elseif roomType == RoomType.ROOM_CURSE then
        return ItemPoolType.POOL_CURSE
    elseif roomType == RoomType.ROOM_CHALLENGE then
        return ItemPoolType.POOL_BOSS
    else
        return ItemPoolType.POOL_TREASURE
    end
end

-------------------------------------------------
-- SAFE ENTITY COLLECTION
-------------------------------------------------

local function GetRoomPickups()
    local pickups = {}

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP then
            table.insert(pickups, entity:ToPickup())
        end
    end

    return pickups
end

-------------------------------------------------
-- 6D ACTIVE LOGIC (WITH SHOP HANDLING)
-------------------------------------------------

function SarahMod:UseSixD(_, rng, player, flags, slot)
    local room = game:GetRoom()
    local itemPool = game:GetItemPool()
    local poolType = GetRoomItemPool()

    -------------------------------------------------
    -- SMELT ALL HELD TRINKETS (SAFE METHOD)
    -------------------------------------------------
    for i = 0, game:GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(i)

        for trinketSlot = 0, 1 do
            if p:GetTrinket(trinketSlot) ~= 0 then
                p:UseActiveItem(
                    CollectibleType.COLLECTIBLE_SMELTER,
                    UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER,
                    -1
                )
            end
        end
    end
    -------------------------------------------------

    local isShop = room:GetType() == RoomType.ROOM_SHOP
    local isDevilAngel = room:GetType() == RoomType.ROOM_DEVIL or room:GetType() == RoomType.ROOM_ANGEL
    local isSpecialShop = isShop or isDevilAngel

    local pickups = GetRoomPickups()

    for _, pickup in ipairs(pickups) do
        if pickup and pickup:Exists() then
            local position = pickup.Position
            local originalPrice = pickup.Price

            -- COLLECTIBLE → TRINKET
            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local collectibleID = pickup.SubType

                if collectibleID ~= 0 and not IsQuestItem(collectibleID) then
                    pickup:Remove()

                    local trinketID = itemPool:GetTrinket(false)
                    local trinket = Isaac.Spawn(
                        EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_TRINKET,
                        trinketID,
                        position,
                        Vector.Zero,
                        player
                    ):ToPickup()

                    if isSpecialShop then
                        trinket.Price = originalPrice
                        trinket.AutoUpdatePrice = true
                    end
                end

                -- TRINKET → COLLECTIBLE
            elseif pickup.Variant == PickupVariant.PICKUP_TRINKET then
                pickup:Remove()

                local collectibleID = itemPool:GetCollectible(poolType, true)
                if collectibleID ~= 0 then
                    local spawned = Isaac.Spawn(
                        EntityType.ENTITY_PICKUP,
                        PickupVariant.PICKUP_COLLECTIBLE,
                        collectibleID,
                        position,
                        Vector.Zero,
                        player
                    ):ToPickup()

                    if isSpecialShop then
                        spawned.Price = originalPrice
                        spawned.AutoUpdatePrice = true
                    end
                end
            end
        end
    end

    game:ShakeScreen(10)
    SFXManager():Play(SoundEffect.SOUND_STATIC)
    return true
end

SarahMod:AddCallback(ModCallbacks.MC_USE_ITEM, SarahMod.UseSixD, SixDID)
