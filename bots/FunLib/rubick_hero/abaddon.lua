local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local botTarget

local MistCoil
local AphoticShield
local MistCoilDesire, MistCoilTarget
local AphoticShieldDesire, AphoticShieldTarget

local function AbilityCastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local abilityName = ability:GetName()
    if abilityName ~= 'abaddon_aphotic_shield'
    and abilityName ~= 'abaddon_death_coil' then return nil end

    if J.CanNotUseAbility(bot) then return false end

    botTarget = J.GetProperTarget(bot)

    if abilityName == 'abaddon_aphotic_shield'
    then
        AphoticShield = ability
        AphoticShieldDesire, AphoticShieldTarget = X.ConsiderAphoticShield()
        if AphoticShieldDesire > 0
        then
            bot:Action_UseAbilityOnEntity(AphoticShield, AphoticShieldTarget)
            return true
        end
    end

    if abilityName == 'abaddon_death_coil'
    then
        MistCoil = ability
        MistCoilDesire, MistCoilTarget = X.ConsiderMistCoil()
        if MistCoilDesire > 0
        then
            bot:Action_UseAbilityOnEntity(MistCoil, MistCoilTarget)
            return true
        end
    end
    return false
end

local function CanSupport(unit, range, allowImmune)
    return J.IsValidHero(unit) and J.IsInRange(bot, unit, range)
        and unit:CanBeSeen() and not unit:IsInvulnerable() and not unit:IsIllusion()
        and (allowImmune or not unit:IsMagicImmune())
end

local function HealBlocked(unit)
    return unit:HasModifier('modifier_ice_blast') or unit:HasModifier('modifier_doom_bringer_doom')
end

function X.ConsiderMistCoil()
    if not MistCoil:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end
    local range = AbilityCastRange(MistCoil)
    local damage = MistCoil:GetSpecialValueInt('damage_heal')
    -- self_damage is a percentage of the damage/heal, not a flat health cost.
    local cost = damage * MistCoil:GetSpecialValueInt('self_damage') / 100
    local protected = bot:HasModifier('modifier_abaddon_borrowed_time')
    if not protected and bot:GetHealth() <= cost + bot:GetMaxHealth() * 0.15 then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local best, lowest = nil, 1
    for _, ally in pairs(J.GetNearbyHeroes(bot, range, false, BOT_MODE_NONE)) do
        if ally ~= bot and CanSupport(ally, range, true) and not HealBlocked(ally)
        and not ally:HasModifier('modifier_abaddon_borrowed_time')
        and ally:GetMaxHealth() - ally:GetHealth() >= damage * 0.5
        and J.GetHP(ally) < lowest then
            best, lowest = ally, J.GetHP(ally)
        end
    end
    if best ~= nil and (lowest < 0.65 or best:WasRecentlyDamagedByAnyHero(2)) then
        return BOT_ACTION_DESIRE_HIGH, best
    end

    local enemies = J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if J.IsValidHero(enemy) and J.IsInRange(bot, enemy, range)
        and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
        and not enemy:HasModifier('modifier_antimage_counterspell')
        and not J.IsSuspiciousIllusion(enemy) and not J.CannotBeKilled(bot, enemy)
        and not enemy:HasModifier('modifier_templar_assassin_refraction_absorb')
        and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.IsInRange(bot, target, range)
    and J.CanCastOnNonMagicImmune(target) and J.CanCastOnTargetAdvanced(target)
    and not target:HasModifier('modifier_antimage_counterspell')
    and not J.IsSuspiciousIllusion(target) and not J.CannotBeKilled(bot, target)
    and (protected or J.GetHP(bot) > 0.35) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    if best ~= nil and lowest < 0.85 and J.GetMP(bot) > 0.4 then
        return BOT_ACTION_DESIRE_HIGH, best
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValidTarget(target)
    and J.IsInRange(bot, target, range) and J.IsAttacking(bot)
    and J.CanCastOnNonMagicImmune(target) and (protected or J.GetHP(bot) > 0.6) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderAphoticShield()
    if not AphoticShield:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end
    local range = AbilityCastRange(AphoticShield)
    local allies = J.GetNearbyHeroes(bot, range, false, BOT_MODE_NONE)
    local candidates = { bot }
    for _, ally in pairs(allies) do if ally ~= bot then candidates[#candidates + 1] = ally end end
    -- Replacing an existing barrier is worthwhile when it frees a disabled ally.
    for _, ally in pairs(candidates) do
        if CanSupport(ally, range, false)
        and (ally:IsStunned() or ally:IsRooted() or ally:IsHexed() or ally:IsNightmared()
            or (ally:IsSilenced() and not ally:HasModifier('modifier_item_mask_of_madness_berserk')
                and not ally:HasModifier('modifier_doom_bringer_doom')
                and not ally:HasModifier('modifier_riki_smoke_screen')
                and not ally:HasModifier('modifier_disruptor_static_storm'))
            or ally:HasModifier('modifier_dazzle_poison_touch')
            or ally:HasModifier('modifier_bounty_hunter_track')
            or ally:HasModifier('modifier_slardar_amplify_damage')
            or ally:HasModifier('modifier_item_spirit_vessel_damage'))
        and not ally:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not ally:HasModifier('modifier_enigma_black_hole_pull')
        and not ally:HasModifier('modifier_legion_commander_duel')
        and not ally:HasModifier('modifier_axe_berserkers_call') then
            return BOT_ACTION_DESIRE_HIGH, ally
        end
    end
    local best, lowest = nil, 2
    for _, ally in pairs(candidates) do
        if CanSupport(ally, range, false)
        and not ally:HasModifier('modifier_abaddon_aphotic_shield')
        and not ally:HasModifier('modifier_abaddon_borrowed_time') then
            local target = ally:GetAttackTarget()
            local exposed = ally:WasRecentlyDamagedByAnyHero(2)
                or (J.IsGoingOnSomeone(ally) and J.IsValidHero(target) and J.IsInRange(ally, target, 500))
            if exposed and J.GetHP(ally) < lowest then best, lowest = ally, J.GetHP(ally) end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot) then
        local target = J.GetProperTarget(bot)
        if J.IsValidTarget(target) and J.IsInRange(bot, target, 500) and J.IsAttacking(bot) then
            local ally = J.GetAttackableWeakestUnit(bot, range, true, false)
            if CanSupport(ally, range, false) and not ally:HasModifier('modifier_abaddon_aphotic_shield') then
                return BOT_ACTION_DESIRE_HIGH, ally
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

return X
