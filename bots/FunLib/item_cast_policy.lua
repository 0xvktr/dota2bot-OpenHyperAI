-- Mana items consume a current, validated hero decision; they never guess a
-- spell by scanning the ability bar or count a future random mana proc.
local P = {}

function P.Ready(ability)
    return ability ~= nil and not ability:IsNull() and ability:IsTrained() and not ability:IsHidden()
        and ability:IsActivated() and not ability:IsPassive()
        and ability:GetCooldownTimeRemaining() <= 0
end

function P.CanConsider(bot, ability)
    return ability:IsFullyCastable()
        or (P.Ready(ability) and ability:GetManaCost() > bot:GetMana())
end

local function unlocked(bot)
    return bot:IsAlive() and not bot:IsChanneling() and not bot:IsCastingAbility()
        and not bot:IsUsingAbility() and bot:NumQueuedActions() == 0
        and not bot:IsSilenced() and not bot:IsStunned() and not bot:IsHexed()
        and not bot:IsNightmared() and not bot:IsInvisible()
        and not bot:HasModifier('modifier_teleporting')
end

function P.Clear(bot) bot.ohaManaCastIntent = nil end

-- Called only after Consider has selected a useful cast. Re-evaluate that
-- decision before spending an item; an old target or changed mode is invalid.
function P.Request(bot, ability, target, kind, validate, J)
    P.Clear(bot)
    if not unlocked(bot) or not P.Ready(ability) or ability:GetManaCost() <= bot:GetMana() then return false end
    bot.ohaManaCastIntent = { ability=ability, target=target, kind=kind,
        validate=validate, mode=bot:GetActiveMode(), expires=DotaTime() + 0.35 }
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item and P.RestoreDesire(bot, item, J) > 0 then return true end
    end
    P.Clear(bot)
    return false
end

function P.Intent(bot, J)
    local intent = bot.ohaManaCastIntent
    if not intent or DotaTime() > intent.expires or bot:GetActiveMode() ~= intent.mode
        or not unlocked(bot) or not P.Ready(intent.ability)
        or intent.ability:GetManaCost() <= bot:GetMana() then return nil end
    if intent.kind == 'unit' then
        local target = intent.target
        if not J.IsValidHero(target) or not target:IsAlive()
            or not J.IsInRange(bot, target, intent.ability:GetCastRange()) then return nil end
        if target:GetTeam() ~= bot:GetTeam()
            and (not J.CanCastOnNonMagicImmune(target) or not J.CanCastOnTargetAdvanced(target)) then return nil end
    elseif intent.kind == 'ground' then
        if intent.target == nil or GetUnitToLocationDistance(bot, intent.target) > intent.ability:GetCastRange() then return nil end
    elseif intent.kind ~= 'none' then return nil end
    if not intent.validate or not intent.validate() then return nil end
    return intent
end

local function special(item, name, fallback)
    local value = item:GetSpecialValueInt(name)
    return value > 0 and value or fallback
end

function P.SoulRingUseful(bot, item, ability, enemyCount, deficitOnly)
    if not P.Ready(ability) or not item or not item:IsFullyCastable() then return false end
    local cost, mana = ability:GetManaCost(), bot:GetMana()
    local gain = special(item, 'mana_gain', 170)
    -- AbilityHealthCost is 170 in pinned Valve 7.41f data; the bot item API
    -- does not expose it as an AbilityValues special.
    local healthCost = 170
    local hp = bot:OriginalGetHealth()
    local maxHP = bot:OriginalGetMaxHealth()
    -- Keep at least half real health after paying; Medusa's effective health
    -- and temporary Soul Ring mana are not a health reserve.
    if hp - healthCost < maxHP * (0.5 + math.min(enemyCount, 3) * 0.1) then return false end
    if cost > mana then return cost <= mana + gain end
    if deficitOnly then return false end
    -- An already affordable, selected spell can use temporary mana now, but
    -- small casts / a nearly full pool do not justify the health payment.
    return math.min(cost, bot:GetMaxMana() - mana) >= gain * 0.75
end

function P.RestoreDesire(bot, item, J)
    local name = item:GetName()
    if name ~= 'item_enchanted_mango' and name ~= 'item_magic_stick'
        and name ~= 'item_magic_wand' and name ~= 'item_soul_ring' then return 0 end
    local intent = P.Intent(bot, J)
    if not intent or bot:IsMuted() or not item:IsFullyCastable() then return 0 end
    local gain = 0
    if name == 'item_enchanted_mango' then
        gain = special(item, 'replenish_amount', 100)
    elseif name == 'item_magic_stick' or name == 'item_magic_wand' then
        gain = item:GetCurrentCharges() * special(item, 'restore_per_charge', 15)
    elseif name == 'item_soul_ring' then
        if P.SoulRingUseful(bot, item, intent.ability, J.GetEnemyCount(bot, 1600), true) then return BOT_ACTION_DESIRE_HIGH end
        return 0
    end
    -- One use must actually enable the selected spell. Do not burn several
    -- consumables on an unaffordable spell or a cooldown/target failure.
    if gain > 0 and intent.ability:GetManaCost() <= math.min(bot:GetMaxMana(), bot:GetMana() + gain) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

local silenceSensitive = {
    npc_dota_hero_sniper = { 'sniper_assassinate' },
    npc_dota_hero_medusa = { 'medusa_stone_gaze' },
    npc_dota_hero_faceless_void = { 'faceless_void_chronosphere', 'faceless_void_time_walk' },
}

function P.AllowMask(bot, enemiesNearby)
    if bot:GetUnitName() == 'npc_dota_hero_drow_ranger' then return false end
    if not enemiesNearby then return true end
    for _, name in ipairs(silenceSensitive[bot:GetUnitName()] or {}) do
        -- Read remaining cooldown, not the ability's base cooldown. Reserve
        -- ready spells even if current mana is low or the bot is silenced.
        if P.Ready(bot:GetAbilityByName(name)) then return false end
    end
    return true
end

return P
