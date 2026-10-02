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
function G.Phantom(bot, ability, interruptOnly)
    if not J.CanCastAbility(ability) then return 0, nil end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, G.Range(bot, ability), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:IsInvisible() and not enemy:IsSilenced()
            and not enemy:HasModifier('modifier_grimstroke_ink_creature_debuff') then
            -- Silence starts on arrival; the phantom can be attacked before the rend.
            if enemy:IsChanneling() and GetUnitToUnitDistance(bot, enemy) / ability:GetSpecialValueInt('speed') < 0.5 then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            if not interruptOnly and (useful(bot, enemy)
                or J.CanKillTarget(enemy, ability:GetSpecialValueInt('damage_per_second') * 0.5, DAMAGE_TYPE_MAGICAL)) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    return 0, nil
end
function G.Swell(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    local candidates = {bot}
    for _, ally in pairs(J.GetNearbyHeroes(bot, G.Range(bot, ability), false, BOT_MODE_NONE)) do candidates[#candidates + 1] = ally end
    local carrier, distance = nil, math.huge
    local target = J.GetProperTarget(bot)
    for _, ally in pairs(candidates) do
        if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally)
            and not ally:HasModifier('modifier_grimstroke_spirit_walk_buff') then
            if bot:HasModifier('modifier_item_aghanims_shard') and (ally:IsRooted() or ally:IsSilenced()) and not ally:IsStunned()
                and not ally:HasModifier('modifier_doom_bringer_doom') then
                return BOT_ACTION_DESIRE_HIGH, ally
            end
            local close = #J.GetNearbyHeroes(ally, ability:GetSpecialValueInt('radius'), true, BOT_MODE_NONE) > 0
            if close and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)
                or J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2)) then
                local d = J.IsValidHero(target) and GetUnitToUnitDistance(ally, target) or 0
                if d < distance then carrier, distance = ally, d end
            end
        end
    end
    if carrier then return BOT_ACTION_DESIRE_HIGH, carrier end
    return 0, nil
end
function G.Bind(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, G.Range(bot, ability), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_grimstroke_soul_chain') and useful(bot, enemy) then
            for _, other in pairs(J.GetEnemiesNearLoc(enemy:GetLocation(), ability:GetSpecialValueInt('chain_latch_radius'))) do
                if other ~= enemy and J.IsValidHero(other) and not J.IsSuspiciousIllusion(other) then
                    return BOT_ACTION_DESIRE_HIGH, enemy
                end
            end
        end
    end
    return 0, nil
end
function G.Portrait(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    local best, damage = nil, 0
    for _, enemy in pairs(J.GetNearbyHeroes(bot, G.Range(bot, ability), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not J.IsSuspiciousIllusion(enemy) and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then
            local output = enemy:GetAttackDamage() / math.max(enemy:GetSecondsPerAttack(), 0.2)
            if output > damage then best, damage = enemy, output end
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH, best end
    return 0, nil
end
function G.Stroke(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, G.Range(bot, ability), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and (useful(bot, enemy) or J.CanKillTarget(enemy, ability:GetSpecialValueInt('damage'), DAMAGE_TYPE_MAGICAL)) then
            local point = enemy:GetExtrapolatedLocation(ability:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / ability:GetSpecialValueInt('projectile_speed'))
            if GetUnitToLocationDistance(bot, point) <= G.Range(bot, ability) then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    return 0, nil
end
return G
