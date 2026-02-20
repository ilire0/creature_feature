-- Grease Spray item
local GreaseSprayMod = RegisterMod("Grease Spray", 1)

local GreaseSprayItem = Isaac.GetItemIdByName("Grease Spray")

-- Cache flags for speed (tar / slowing surfaces)
function GreaseSprayMod:onCache(player, flag)
	if player:HasCollectible(GreaseSprayItem) then
		if flag == CacheFlag.CACHE_SPEED then
			-- Boost speed slightly to counter tar slow
			player.MoveSpeed = player.MoveSpeed + 0.15
		end
	end
end

GreaseSprayMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GreaseSprayMod.onCache)

-- Completely remove slipperiness / ice sliding
function GreaseSprayMod:onPlayerUpdate(player)
	if player:HasCollectible(GreaseSprayItem) then
		-- Friction factor neutralizes slipperiness
		player.Friction = 1.0
	end
end

GreaseSprayMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, GreaseSprayMod.onPlayerUpdate)

-- Handle creep damage negation
function GreaseSprayMod:onEntityTakeDamage(entity, amount, flags, source, countdown)
	if entity.Type == EntityType.ENTITY_PLAYER then
		local player = entity:ToPlayer()
		if player:HasCollectible(GreaseSprayItem) then
			-- Check for any effect on Isaac colliding with him
			local room = Game():GetRoom()
			local effects = Isaac.FindByType(EntityType.ENTITY_EFFECT)
			for _, eff in ipairs(effects) do
				if eff.Position:Distance(player.Position) <= player.Size + 5 then
					local effectSubType = eff.SubType
					-- 1 = blue creep, 2 = red creep, 3 = green, 4 = puddle (etc.)
					-- We'll negate all of them
					if eff.Type == EntityType.ENTITY_EFFECT then
						return false
					end
				end
			end
		end
	end
end

GreaseSprayMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, GreaseSprayMod.onEntityTakeDamage)

-- Reduce donation machine jam chance dynamically
function GreaseSprayMod:onPostPlayerUpdate(player)
	if not player:HasCollectible(GreaseSprayItem) then return end

	local room = Game():GetRoom()
	local machines = Isaac.FindByType(EntityType.ENTITY_SLOT, 200) -- Donation machines
	for _, machine in ipairs(machines) do
		local dist = machine.Position:Distance(player.Position)
		if dist <= 40 then -- Player is "using" the machine
			-- Reduce jam chance by 50%
			local jamChance = machine:GetData().JamChance or 0.0
			if jamChance > 0 then
				machine:GetData().JamChance = jamChance * 0.5
			end
		end
	end
end

GreaseSprayMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, GreaseSprayMod.onPostPlayerUpdate)
