local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot, botTarget, abilityR, FeastOfSouls
local function Souls()
    local index = bot:GetModifierByName('modifier_nevermore_necromastery')
    return index >= 0 and bot:GetModifierStackCount(index) or 0
end

local function Enemy(enemy)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and J.CanCastOnNonMagicImmune(enemy)
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) then return 0 end
    local radius = abilityR:GetSpecialValueInt('requiem_radius')
    local delay = abilityR:GetCastPoint()
    local near, total = 0, 0
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
        local cyclone = J.GetModifierTime(enemy, 'modifier_eul_cyclone')
        if cyclone == 0 then cyclone = J.GetModifierTime(enemy, 'modifier_brewmaster_storm_cyclone') end
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and not enemy:IsMagicImmune()
            and cyclone > 0 and cyclone <= delay and J.IsInRange(bot, enemy, 350) then return BOT_ACTION_DESIRE_HIGH end
        if Enemy(enemy) and GetUnitToLocationDistance(bot, J.GetCorrectLoc(enemy, delay)) <= radius then
            total = total + 1
            if J.IsInRange(bot, enemy, 350) then
                near = near + 1
                if J.IsGoingOnSomeone(bot) and (J.IsDisabled(enemy) or J.Utils.IsTruelyInvisible(bot)
                    or bot:IsMagicImmune()) then return BOT_ACTION_DESIRE_HIGH end
            end
        end
    end
    if near > 0 and J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
        and J.GetHP(bot) < 0.5 and (bot:IsMagicImmune() or near == 1) then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsInTeamFight(bot, 1000) or J.IsGoingOnSomeone(bot))
        and (total >= 3 or near >= 1 and total >= 2) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.IsUnitNearLoc(unit, location, radius, delay)
    return GetUnitToLocationDistance(unit, location) <= radius + unit:GetCurrentMovementSpeed() * delay
        and J.GetLocationToLocationDistance(J.GetCorrectLoc(unit, delay), location) <= radius
end

function X.IsUnitCanBeKill(unit, damage, bonus, delay, ability)
    local total = damage + J.GetModifierCount(unit, 'modifier_nevermore_shadowraze_debuff') * bonus
    if ability ~= nil then total = total + Souls() * ability:GetSpecialValueInt('damage_per_soul') end
    return J.WillKillTarget(unit, total, DAMAGE_TYPE_MAGICAL, delay)
end

function X.Consider(ability)
    if not J.CanCastAbility(ability) then return 0 end
    local radius = ability:GetSpecialValueInt('shadowraze_radius')
    -- Razes are facing-based ground blasts: cast-range items cannot move their center.
    local distance = ability:GetSpecialValueInt('shadowraze_range')
    local location = J.GetFaceTowardDistanceLocation(bot, distance)
    local delay = ability:GetCastPoint()
    local damage, bonus = ability:GetSpecialValueInt('shadowraze_damage'), ability:GetSpecialValueInt('stack_bonus_damage')
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(distance + radius + 200, 1600), true, BOT_MODE_NONE)) do
        if Enemy(enemy) and X.IsUnitNearLoc(enemy, location, radius, delay)
            and not J.CannotBeKilled(bot, enemy)
            and (X.IsUnitCanBeKill(enemy, damage, bonus, delay, ability)
                or (J.IsGoingOnSomeone(bot) or J.IsLaning(bot) or J.IsInTeamFight(bot, 1000))
                    and J.IsAllowedToSpam(bot, ability:GetManaCost())
                or J.IsRetreating(bot) and enemy:HasModifier('modifier_nevermore_shadowraze_debuff')
                    and ability:GetSpecialValueInt('movement_speed_debuff') > 0) then return BOT_ACTION_DESIRE_HIGH end
    end
    if not J.IsRetreating(bot) and J.IsAllowedToSpam(bot, ability:GetManaCost()) then
        local creeps, hit, kills, rangedKill = bot:GetNearbyCreeps(math.min(distance + radius, 1600), true), 0, 0, false
        for _, creep in ipairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep)
                and X.IsUnitNearLoc(creep, location, radius, delay) then
                hit = hit + 1
                if X.IsUnitCanBeKill(creep, damage, bonus, delay, ability) then
                    kills = kills + 1
                    if J.IsKeyWordUnit('ranged', creep) then rangedKill = true end
                end
            end
        end
        if kills >= 2 or J.IsLaning(bot) and rangedKill
            or (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and hit >= 3 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end

function X.ConsiderFeastOfSouls()
    if not J.CanCastAbility(FeastOfSouls) or bot:HasModifier('modifier_nevermore_frenzy') then return 0 end
    local radius = FeastOfSouls:GetSpecialValueInt('soul_collection_radius')
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
        and #J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE) > 0 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget) and not J.IsSuspiciousIllusion(botTarget)
        and J.CanBeAttacked(botTarget) and not bot:IsDisarmed()
        and J.IsInRange(bot, botTarget, math.max(bot:GetAttackRange(), radius))
        and not J.CannotBeKilled(bot, botTarget) then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAttacking(bot)
        and J.IsAllowedToSpam(bot, FeastOfSouls:GetManaCost()) then
        if #bot:GetNearbyCreeps(math.min(radius, 1600), true) >= 3
            or #bot:GetNearbyNeutralCreeps(math.min(radius, 1600)) >= 2 then return BOT_ACTION_DESIRE_HIGH end
        if J.IsValidBuilding(botTarget) and J.CanBeAttacked(botTarget)
            and J.IsInRange(bot, botTarget, bot:GetAttackRange()) then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsValid(botTarget) and (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, bot:GetAttackRange()) and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.ConsiderStolenSpell(ability)
    local name = ability:GetName()
    if name ~= 'nevermore_shadowraze1' and name ~= 'nevermore_shadowraze2' and name ~= 'nevermore_shadowraze3'
        and name ~= 'nevermore_frenzy' and name ~= 'nevermore_requiem' then return nil end
    bot=GetBot();botTarget=J.GetProperTarget(bot)
    if J.CanNotUseAbility(bot) or bot:IsChanneling() then return false end
    local desire
    if name == 'nevermore_requiem' then abilityR=ability;desire=X.ConsiderR()
    elseif name == 'nevermore_frenzy' then FeastOfSouls=ability;desire=X.ConsiderFeastOfSouls()
    else desire=X.Consider(ability) end
    if desire > 0 then bot:Action_UseAbility(ability);return true end
    return false
end
return X
