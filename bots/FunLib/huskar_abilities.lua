local H = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
function H.Range(bot, ability)
    local bonus = 0
    for slot = 0, 5 do local item = bot:GetItemInSlot(slot); if item and item:GetName() == 'item_aether_lens' then bonus = item:GetSpecialValueInt('cast_range_bonus'); break end end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus = bonus + supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange() + bonus
end
function H.Cauterize(bot, ability)
    -- The engine adds an active component to this passive with Shard. Other passives remain excluded.
    if ability == nil or ability:IsNull() or not ability:IsTrained() or ability:IsHidden() or not ability:IsActivated()
        or not ability:IsFullyCastable() or ability:GetSpecialValueInt('activatable') <= 0
        or bot:HasModifier('modifier_ice_blast') then return 0 end
    local cost = bot:GetHealth() * ability:GetSpecialValueFloat('activation_healthcost_pct') / 100
    if bot:GetHealth() - cost < bot:GetMaxHealth() * 0.25 then return 0 end
    if bot:IsRooted() or bot:HasModifier('modifier_item_spirit_vessel_damage')
        or bot:HasModifier('modifier_item_urn_damage') or bot:HasModifier('modifier_venomancer_venomous_gale') then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end
function H.Spears(bot, ability)
    if ability == nil or not ability:IsTrained() or ability:IsHidden() or not ability:IsActivated() then return 0, nil end
    local blood = bot:GetAbilityByName('huskar_berserkers_blood')
    local sustained = blood ~= nil and blood:IsTrained() and not J.HasBreakModifier(bot) and not bot:HasModifier('modifier_ice_blast')
    local floor = sustained and 0.15 or 0.35
    local safe = bot:GetHealth() - bot:GetMaxHealth() * ability:GetSpecialValueFloat('max_health_cost') / 100 > bot:GetMaxHealth() * floor
    local target = bot:GetAttackTarget()
    local valid = J.IsValid(target) and J.CanCastOnNonMagicImmune(target) and J.CanBeAttacked(target)
        and not bot:IsDisarmed() and J.IsInRange(bot, target, bot:GetAttackRange())
    local auto = safe and valid and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200) or J.IsFarming(bot)
        or J.IsDoingRoshan(bot) or J.IsLaning(bot))
    if ability:GetAutoCastState() ~= auto then ability:ToggleAutoCast() end
    if safe and valid and J.CanCastAbility(ability) and not auto and J.IsRetreating(bot) and J.IsValidHero(target)
        and J.IsChasingTarget(target, bot) then return BOT_ACTION_DESIRE_HIGH, target end
    return 0, nil
end
function H.Fire(bot, ability)
    if not J.CanCastAbility(ability) or bot:GetHealth()-ability:GetSpecialValueInt('health_cost') < bot:GetMaxHealth()*0.15 then return 0 end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, ability:GetSpecialValueInt('radius'), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and (enemy:IsChanneling() or J.CanKillTarget(enemy, ability:GetSpecialValueInt('damage'), DAMAGE_TYPE_MAGICAL)
                or J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot)
                or J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot) and enemy == J.GetProperTarget(bot)) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    return 0
end
function H.Break(bot, ability)
    if not J.CanCastAbility(ability) or bot:IsRooted() or bot:IsDisarmed()
        or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_huskar_life_break_charge') then return 0, nil end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnMagicImmune(target) and J.CanCastOnTargetAdvanced(target)
        and J.IsInRange(bot, target, H.Range(bot, ability))
        and not target:HasModifier('modifier_abaddon_borrowed_time') and not target:HasModifier('modifier_item_blade_mail_reflect')
        and not target:HasModifier('modifier_dazzle_shallow_grave') then
        local blood = bot:GetAbilityByName('huskar_berserkers_blood')
        local sustained = blood ~= nil and blood:IsTrained() and not J.HasBreakModifier(bot) and not bot:HasModifier('modifier_ice_blast')
        local floor = sustained and 0.15 or 0.35
        local remaining = bot:GetHealth() * (1-ability:GetSpecialValueFloat('health_cost_percent'))
        if remaining > bot:GetMaxHealth()*floor
            and #J.GetNearbyHeroes(target, 1000, true, BOT_MODE_NONE) <= #J.GetNearbyHeroes(target, 1000, false, BOT_MODE_NONE)+1 then
            return BOT_ACTION_DESIRE_HIGH, target
        end
    end
    return 0, nil
end
return H
