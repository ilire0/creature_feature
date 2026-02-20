local mod = RegisterMod("HikingBootsMod", 1)
local HIKING_BOOTS_ID = Isaac.GetItemIdByName("Hiking Boots")
local pendingTeleport = nil -- Stores the stage we want to go to

function mod:OnUseHikingBoots(item, rng, player, useFlags, slot, customData)
    if item ~= HIKING_BOOTS_ID then return end

    local level = Game():GetLevel()

    -- 1. Determine Target Stage
    if level:GetCurrentRoomIndex() == level:GetStartingRoomIndex() then
        pendingTeleport = "13" -- Home
    else
        local currentStage = level:GetStage()
        pendingTeleport = tostring(math.max(1, currentStage - 1)) -- Previous Floor
    end

    return {
        Discharge = true,
        Remove = true,
        ShowAnim = true,
    }
end

-- 2. Execute the teleport in a separate frame to prevent crashing
function mod:OnUpdate()
    if pendingTeleport then
        Isaac.ExecuteCommand("stage " .. pendingTeleport)
        pendingTeleport = nil -- Reset so it only happens once
    end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.OnUseHikingBoots)
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.OnUpdate)
