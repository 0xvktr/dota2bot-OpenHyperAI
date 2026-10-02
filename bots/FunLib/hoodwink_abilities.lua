local H = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
function H.Range(bot, ability)
    local bonus = 0
    for slot = 0, 5 do local item = bot:GetItemInSlot(slot); if item and item:GetName() == 'item_aether_lens' then bonus = item:GetSpecialValueInt('cast_range_bonus'); break end end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus = bonus + supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange() + bonus
end
local function useful(bot, enemy)
    if enemy:IsChanneling() or enemy == J.GetProperTarget(bot) and J.IsGoingOnSomeone(bot)
        or J.IsInTeamFight(bot, 1200) or J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot) then return true end
    for _, ally in pairs(J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2)
            and J.IsChasingTarget(enemy, ally) then return true end
    end
    return false
end
function H.HasTree(bot, point, radius)
    for _, id in pairs(bot:GetNearbyTrees(1600)) do
        if J.GetLocationToLocationDistance(GetTreeLocation(id), point) <= radius then return true end
    end
    return false
end
function H.Bush(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, H.Range(bot, ability), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and not enemy:IsInvisible()
            and not enemy:HasModifier('modifier_hoodwink_bushwhack_trap') and useful(bot, enemy) then
            local point = enemy:GetExtrapolatedLocation(ability:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / ability:GetSpecialValueInt('projectile_speed'))
            if GetUnitToLocationDistance(bot, point) <= H.Range(bot, ability)
                and H.HasTree(bot, point, ability:GetSpecialValueInt('trap_radius') - 25) then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    return 0, nil
end
function H.Acorn(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, H.Range(bot, ability), true, BOT_MODE_NONE)) do
        local damage = ability:GetSpecialValueInt('acorn_shot_damage') + bot:GetAttackDamage() * ability:GetSpecialValueInt('base_damage_pct') / 100
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and J.CanBeAttacked(enemy)
            and (useful(bot, enemy) or J.CanKillTarget(enemy, damage, DAMAGE_TYPE_PHYSICAL)) then
            local bush = bot:GetAbilityByName('hoodwink_bushwhack')
            local point = enemy:GetExtrapolatedLocation(ability:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / ability:GetSpecialValueInt('projectile_speed'))
            if J.CanCastAbility(bush) and bot:GetMana() >= ability:GetManaCost() + bush:GetManaCost()
                and not H.HasTree(bot, point, bush:GetSpecialValueInt('trap_radius') - 25)
                and GetUnitToLocationDistance(bot, point) <= H.Range(bot, ability) then
                return BOT_ACTION_DESIRE_HIGH, point, true
            end
            if J.CanCastOnTargetAdvanced(enemy) then return BOT_ACTION_DESIRE_HIGH, enemy, false end
        end
    end
    if (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot)) and J.GetMP(bot) > 0.4 then
        local creeps = bot:GetNearbyLaneCreeps(H.Range(bot, ability), true)
        if #creeps >= 3 and J.IsValid(creeps[1]) and J.CanBeAttacked(creeps[1]) then
            return BOT_ACTION_DESIRE_HIGH, creeps[1], false
        end
    end
    return 0, nil
end
function H.Scurry(bot, ability)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_hoodwink_scurry_active') or bot:IsRooted() then return 0 end
    if J.IsRetreating(bot) and (#J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE) > 0 or bot:WasRecentlyDamagedByAnyHero(2)) then
        return BOT_ACTION_DESIRE_HIGH
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.IsChasingTarget(bot, target)
        and not J.IsInRange(bot, target, bot:GetAttackRange()) and ability:GetCurrentCharges() > 1 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function H.Decoy(bot, ability)
    if not J.CanCastAbility(ability) or bot:IsInvisible() then return 0 end
    if (J.IsRetreating(bot) or J.GetHP(bot) < 0.45) and #J.GetNearbyHeroes(bot, 900, true, BOT_MODE_NONE) > 0
        or J.IsStunProjectileIncoming(bot, 900) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function H.Boomerang(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, H.Range(bot, ability), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and not enemy:HasModifier('modifier_hoodwink_hunters_boomerang_debuff') and useful(bot, enemy) then
            local point = enemy:GetExtrapolatedLocation(ability:GetCastPoint())
            if GetUnitToLocationDistance(bot, point) <= H.Range(bot, ability) then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    return 0, nil
end
local function clearShot(bot, target, point, width)
    local origin = bot:GetLocation(); local dx, dy = point.x-origin.x, point.y-origin.y
    local length2 = dx*dx+dy*dy
    if length2 == 0 then return false end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)) do
        if enemy ~= target and J.IsValidHero(enemy) then
            local p = enemy:GetLocation(); local t = ((p.x-origin.x)*dx+(p.y-origin.y)*dy)/length2
            if t > 0 and t < 1 then
                local x,y = origin.x+t*dx, origin.y+t*dy
                if (p.x-x)^2+(p.y-y)^2 <= width*width then return false end
            end
        end
    end
    return true
end
function H.Sharpshooter(bot, ability)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_hoodwink_sharpshooter_windup') or J.IsRetreating(bot) then return 0, nil end
    local range = ability:GetSpecialValueInt('arrow_range')
    for _, enemy in pairs(J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and useful(bot, enemy)
            and not enemy:HasModifier('modifier_item_blade_mail_reflect')
            and (J.IsDisabled(enemy) or enemy:GetMovementDirectionStability() >= 0.95)
            and #J.GetNearbyHeroes(bot, 400, true, BOT_MODE_NONE) == 0 then
            local point = enemy:GetExtrapolatedLocation(ability:GetSpecialValueFloat('max_charge_time') + GetUnitToUnitDistance(bot, enemy)/ability:GetSpecialValueInt('arrow_speed'))
            if GetUnitToLocationDistance(bot, point) <= range and clearShot(bot, enemy, point, ability:GetSpecialValueInt('arrow_width')) then
                return BOT_ACTION_DESIRE_HIGH, point
            end
        end
    end
    return 0, nil
end
function H.Release(bot, shot, release, started)
    if not started or shot == nil or shot:IsNull() or not bot:HasModifier('modifier_hoodwink_sharpshooter_windup') or not J.CanCastAbility(release)
        or not bot:IsAlive() or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsChanneling() or bot:NumQueuedActions() > 0 or bot:IsInvulnerable()
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    if DotaTime() >= started + shot:GetSpecialValueFloat('max_charge_time') then
        bot:Action_UseAbility(release); return true
    end
    return false
end
return H
