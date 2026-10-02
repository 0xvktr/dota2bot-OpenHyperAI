local G = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
function G.Range(bot, ability)
    local bonus = 0
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item and item:GetName() == 'item_aether_lens' then bonus = item:GetSpecialValueInt('cast_range_bonus'); break end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus = bonus + supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange() + bonus
end
local function useful(bot, enemy)
    return enemy == J.GetProperTarget(bot) and J.IsGoingOnSomeone(bot)
        or J.IsInTeamFight(bot, 1200) or J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot)
end
function G.Barrage(bot, ability)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_gyrocopter_rocket_barrage') then return 0 end
    local radius = ability:GetSpecialValueInt('radius')
    local heroes = J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)
    local count = #heroes + #bot:GetNearbyCreeps(radius, true)
    local damage = ability:GetSpecialValueInt('rocket_damage') * ability:GetSpecialValueInt('rockets_per_second')
        * ability:GetSpecialValueFloat('barrage_duration') / math.max(count, 1)
    for _, enemy in pairs(heroes) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and not enemy:IsInvisible()
            and (useful(bot, enemy) or count == 1 and J.IsDisabled(enemy) and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL)) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    return 0
end
function G.Missile(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, G.Range(bot, ability), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_gyrocopter_homing_missile') and useful(bot, enemy) then
            -- Attackable missile has a 2.5 s pre-flight delay; this is setup, not an instant interrupt.
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    return 0, nil
end
function G.Flak(bot, ability)
    if not J.CanCastAbility(ability) or bot:IsDisarmed() or bot:HasModifier('modifier_gyrocopter_flak_cannon') then return 0 end
    local primary = bot:GetAttackTarget()
    if not J.IsValid(primary) or not J.CanBeAttacked(primary) or not J.IsInRange(bot, primary, bot:GetAttackRange()) then return 0 end
    local count = 0
    for _, enemy in pairs(J.GetNearbyHeroes(bot, ability:GetSpecialValueInt('radius'), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanBeAttacked(enemy) then count = count + 1 end
    end
    if count >= 2 and (J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot)) then return BOT_ACTION_DESIRE_HIGH end
    local creeps = bot:GetNearbyLaneCreeps(ability:GetSpecialValueInt('radius'), true)
    local neutrals = bot:GetNearbyNeutralCreeps(ability:GetSpecialValueInt('radius'))
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.GetMP(bot) > 0.35 and #creeps + #neutrals >= 3 then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end
function G.Call(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    local delay = ability:GetCastPoint() + ability:GetSpecialValueFloat('missile_delay_tooltip')
    for _, enemy in pairs(J.GetNearbyHeroes(bot, G.Range(bot, ability), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and (useful(bot, enemy) or J.IsDisabled(enemy) and J.CanKillTarget(enemy, ability:GetSpecialValueInt('damage'), DAMAGE_TYPE_MAGICAL)) then
            local point = enemy:GetExtrapolatedLocation(delay)
            if GetUnitToLocationDistance(bot, point) <= G.Range(bot, ability) then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    return 0, nil
end
return G
