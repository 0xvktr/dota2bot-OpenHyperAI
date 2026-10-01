-- Shared Power Treads policy. Attribute enums describe the desired stat; the
-- item API reports STR=0, INT=1, AGI=2 (unlike hero STR=0, AGI=1, INT=2).
local P = {}

function P.Stat(item)
    local stat = item:GetPowerTreadsStat()
    if stat == 0 then return ATTRIBUTE_STRENGTH end
    if stat == 1 then return ATTRIBUTE_INTELLECT end
    if stat == 2 then return ATTRIBUTE_AGILITY end
end

function P.SwitchCount(item, attribute)
    local raw = { [ATTRIBUTE_STRENGTH] = 0, [ATTRIBUTE_INTELLECT] = 1, [ATTRIBUTE_AGILITY] = 2 }
    local current, target = item:GetPowerTreadsStat(), raw[attribute]
    if target == nil or current < 0 or current > 2 then return 0 end
    return (target - current + 3) % 3
end

function P.Find(bot)
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item and item:GetName() == 'item_power_treads' and item:IsFullyCastable() then return item end
    end
end

function P.ActionLocked(bot, allowQueued)
    return not bot:IsAlive() or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility()
        or bot:HasModifier('modifier_teleporting')
        or (not allowQueued and bot:NumQueuedActions() > 0)
end

function P.CanSwitch(bot, allowQueued)
    return not P.ActionLocked(bot, allowQueued) and not bot:IsMuted()
        and not bot:IsStunned() and not bot:IsHexed() and not bot:IsNightmared() and not bot:IsInvisible()
end

function P.OffensiveStat(bot)
    local primary = bot:GetPrimaryAttribute()
    if primary == ATTRIBUTE_STRENGTH or primary == ATTRIBUTE_AGILITY or primary == ATTRIBUTE_INTELLECT then
        return primary
    end
    return ATTRIBUTE_AGILITY -- universal: equal attribute damage, extra attack speed
end

function P.SurvivalStat(bot)
    -- Mana Shield makes mana the important survival pool for Medusa.
    if bot:GetUnitName() == 'npc_dota_hero_medusa' then return ATTRIBUTE_INTELLECT end
    return ATTRIBUTE_STRENGTH
end

function P.Threatened(bot, J)
    local lowResource = bot:GetHealth() / math.max(1, bot:GetMaxHealth()) < 0.3
    if bot:GetUnitName() == 'npc_dota_hero_medusa' then
        lowResource = bot:GetMana() / math.max(1, bot:GetMaxMana()) < 0.3
    end
    local mode = bot:GetActiveMode()
    if lowResource or (mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE)
        or mode == BOT_MODE_EVASIVE_MANEUVERS or bot:WasRecentlyDamagedByAnyHero(1.5)
        or bot:WasRecentlyDamagedByTower(1.5) or bot:HasModifier('modifier_sniper_assassinate')
        or J.IsNotAttackProjectileIncoming(bot, 1200) then
        bot.ohaTreadsDangerUntil = DotaTime() + 0.75
        return true
    end
    return DotaTime() < (bot.ohaTreadsDangerUntil or -math.huge)
end

function P.RecordSwitch(bot)
    bot.ohaTreadsSwitchTime = DotaTime()
end

function P.Queue(bot, attribute, allowQueued)
    if not P.CanSwitch(bot, allowQueued) then return 0 end
    local item = P.Find(bot)
    if not item then return 0 end
    local count = P.SwitchCount(item, attribute)
    for _ = 1, count do bot:ActionQueue_UseAbility(item) end
    if count > 0 then P.RecordSwitch(bot) end
    -- Do not queue a restoration switch after the cast: that would cancel a
    -- channel. Idle item logic restores the setting after all actions finish.
    bot.ohaTreadsCastUntil = DotaTime() + 0.3
    return count
end

local illusionSpells = {
    naga_siren_mirror_image = true, terrorblade_conjure_image = true,
    chaos_knight_phantasm = true, phantom_lancer_doppelwalk = true,
}
local urgentSpells = {
    antimage_counterspell = true, antimage_counterspell_ally = true,
    dazzle_shallow_grave = true, oracle_false_promise = true, oracle_fates_edict = true,
    omniknight_guardian_angel = true, omniknight_purification = true, omniknight_martyr = true,
    legion_commander_press_the_attack = true,
}

function P.AbilityStat(bot, ability)
    if ability then
        local name = ability:GetName()
        if urgentSpells[name] then return nil end
        if illusionSpells[name] then return P.OffensiveStat(bot) end
        if ability:GetManaCost() <= 0 then return nil end
    end
    return ATTRIBUTE_INTELLECT
end

local restorationItems = {
    item_magic_stick = true, item_magic_wand = true, item_bottle = true,
    item_enchanted_mango = true, item_famango = true, item_great_famango = true,
    item_greater_famango = true, item_flask = true, item_clarity = true,
    item_tango = true, item_tango_single = true,
}
local urgentItems = {
    item_black_king_bar = true, item_glimmer_cape = true, item_force_staff = true,
    item_hurricane_pike = true, item_lotus_orb = true, item_sphere = true,
    item_mekansm = true, item_guardian_greaves = true, item_satanic = true,
    item_soul_ring = true, item_armlet = true, item_bloodstone = true,
    item_cyclone = true, item_wind_waker = true, item_disperser = true,
}

function P.SafeRestoration(bot, J)
    return not P.Threatened(bot, J) and #J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE) == 0
end

-- Return true only when preparation actually queued toggles. The executor
-- must append the chosen item action to that same queue, never replace it.
function P.PrepareItem(bot, item, target, castType, J)
    local name = item:GetName()
    if name == 'item_power_treads' or urgentItems[name] or not P.CanSwitch(bot)
        or bot:IsSilenced() or P.Threatened(bot, J) then return false end
    if castType == 'unit' and target and target ~= bot
        and (target:IsChanneling() or target:IsCastingAbility()) then return false end
    local attribute
    if restorationItems[name] then
        -- Feeding an ally or sharing a Tango does not restore our own pools.
        if castType == 'unit' and target ~= bot then return false end
        if not P.SafeRestoration(bot, J) then return false end
        attribute = ATTRIBUTE_AGILITY
    elseif name == 'item_manta' then
        attribute = P.OffensiveStat(bot)
    elseif item:GetManaCost() > 0 then
        attribute = ATTRIBUTE_INTELLECT
    end
    return attribute ~= nil and P.Queue(bot, attribute) > 0
end

local restorationModifiers = {
    'modifier_flask_healing', 'modifier_clarity_potion', 'modifier_tango_heal',
    'modifier_item_urn_heal', 'modifier_item_spirit_vessel_heal', 'modifier_bottle_regeneration',
}

function P.Consider(bot, item, J)
    if not P.CanSwitch(bot) or DotaTime() < (bot.ohaTreadsSwitchTime or -math.huge) + 0.2 then return 0 end
    local attribute, motive
    if P.Threatened(bot, J) then
        attribute, motive = P.SurvivalStat(bot), 'Power Treads: survival'
    else
        if DotaTime() < (bot.ohaTreadsCastUntil or -math.huge) then return 0 end
        attribute, motive = P.OffensiveStat(bot), 'Power Treads: offensive default'
        for _, modifier in ipairs(restorationModifiers) do
            if bot:HasModifier(modifier) and P.SafeRestoration(bot, J) then
                attribute, motive = ATTRIBUTE_AGILITY, 'Power Treads: restoration'
                break
            end
        end
    end
    local count = P.SwitchCount(item, attribute)
    if count == 0 then return 0 end
    return BOT_ACTION_DESIRE_HIGH, bot, count == 2 and 'twice' or 'none', motive
end

return P
