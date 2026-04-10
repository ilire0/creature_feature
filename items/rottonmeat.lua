local RottonMeatMod = RegisterMod("Rotton Meat Mod", 1)
local game = Game()

-- Get item ID automatically by name (must match items.xml name)
local ITEM_ROTTON_MEAT = Isaac.GetItemIdByName("Rotton Meat")

function RottonMeatMod:OnUseItem(itemID, rng, player, useFlags, activeSlot, varData)
    if itemID == ITEM_ROTTON_MEAT then
        -- Remove 1 full red heart if possible
        if player:GetHearts() > 0 then
            player:AddHearts(-2)
        else
            -- If no red hearts, remove 1 soul heart instead
            if player:GetSoulHearts() > 0 then
                player:AddSoulHearts(-2)
            end
        end

        return true
    end
end

RottonMeatMod:AddCallback(ModCallbacks.MC_USE_ITEM, RottonMeatMod.OnUseItem)
