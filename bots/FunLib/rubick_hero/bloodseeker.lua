local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local abilityQ, abilityW, abilityR, BloodMist, botTarget

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local name = ability:GetName()
    if name ~= 'bloodseeker_bloodrage' and name ~= 'bloodseeker_blood_bath'
        and name ~= 'bloodseeker_rupture' and name ~= 'bloodseeker_blood_mist' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    botTarget = J.GetProperTarget(bot)
    local desire, target
    if name == 'bloodseeker_bloodrage' then
        abilityQ = ability; desire = X.ConsiderQ()
        if desire > 0 then bot:Action_UseAbility(ability); return true end
    elseif name == 'bloodseeker_blood_bath' then
        abilityW = ability; desire, target = X.ConsiderW()
        if desire > 0 then bot:Action_UseAbilityOnLocation(ability, target); return true end
    elseif name == 'bloodseeker_rupture' then
        abilityR = ability; desire, target = X.ConsiderR()
        if desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
    else
        BloodMist = ability; desire = X.ConsiderBloodMist()
        if desire > 0 then bot:Action_UseAbility(ability); return true end
    end
    return false
end

local function AbilityCastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function ValidEnemy(enemy, immune)
    return J.IsValidHero(enemy) and (immune and J.CanCastOnMagicImmune(enemy) or not immune and J.CanCastOnNonMagicImmune(enemy))
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) then return 0 end
    local range = AbilityCastRange(abilityR)
    local function eligible(enemy)
        return ValidEnemy(enemy, true) and J.IsInRange(bot, enemy, range)
            and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_antimage_counterspell')
            and not enemy:HasModifier('modifier_antimage_counterspell_ally')
            and not enemy:HasModifier('modifier_bloodseeker_rupture')
    end
    if J.IsRetreating(bot) then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
            if eligible(enemy) and bot:WasRecentlyDamagedByHero(enemy, 2) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    if J.IsGoingOnSomeone(bot) and eligible(botTarget) then
        -- Rupture also constrains a disabled enemy once control expires; no two-ally requirement.
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    if J.IsInTeamFight(bot, 1200) then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
            if eligible(enemy) and J.Role.IsCarry(enemy:GetUnitName()) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    return 0
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local range, radius = AbilityCastRange(abilityW), abilityW:GetSpecialValueInt('radius')
    local delay = abilityW:GetCastPoint() + abilityW:GetSpecialValueFloat('delay')
    local damage, mana = abilityW:GetSpecialValueInt('damage'), abilityW:GetManaCost()
    local enemies = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    local function location(enemy)
        if not ValidEnemy(enemy, false) then return nil end
        -- Rupture forces a choice between leaving the ritual and taking movement damage.
        local loc = enemy:HasModifier('modifier_bloodseeker_rupture') and enemy:GetLocation()
            or enemy:GetExtrapolatedLocation(delay)
        local distance = GetUnitToLocationDistance(bot, loc)
        if distance > range + radius then return nil end
        if distance > range then loc = J.GetLocationTowardDistanceLocation(bot, loc, range) end
        return loc
    end
    for _, enemy in ipairs(enemies) do
        local loc = location(enemy)
        if loc and J.WillKillTarget(enemy, damage, DAMAGE_TYPE_PURE, delay) then
            return BOT_ACTION_DESIRE_HIGH, loc
        end
    end
    if J.IsGoingOnSomeone(bot) then
        local loc = location(botTarget)
        if loc then return BOT_ACTION_DESIRE_HIGH, loc end
    end
    if J.IsRetreating(bot) then
        for _, enemy in ipairs(enemies) do
            if ValidEnemy(enemy, false) and J.IsInRange(bot, enemy, radius)
                and bot:WasRecentlyDamagedByHero(enemy, 2) then
                return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
            end
        end
    end
    if J.IsInTeamFight(bot, 1200) then
        local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), range, radius, delay, 0)
        if aoe.count >= 2 and GetUnitToLocationDistance(bot, aoe.targetloc) <= range then
            return BOT_ACTION_DESIRE_HIGH, aoe.targetloc
        end
    end
    if not J.IsAllowedToSpam(bot, mana) then return 0 end
    if bot:GetActiveMode() == BOT_MODE_LANING then
        for _, creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range + radius, 1600), true)) do
            if J.IsValid(creep) and J.IsKeyWordUnit('ranged', creep)
                and not creep:HasModifier('modifier_fountain_glyph')
                and J.WillKillTarget(creep, damage, DAMAGE_TYPE_PURE, delay)
                and GetUnitToLocationDistance(bot, creep:GetLocation()) <= range then
                for _, enemy in ipairs(enemies) do
                    if ValidEnemy(enemy, false) and GetUnitToLocationDistance(enemy, creep:GetLocation()) <= radius then
                        return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
                    end
                end
            end
        end
    end
    if (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot)) and #enemies == 0 then
        local aoe = bot:FindAoELocation(true, false, bot:GetLocation(), range, radius, delay, damage)
        if aoe.count >= 4 and GetUnitToLocationDistance(bot, aoe.targetloc) <= range then
            return BOT_ACTION_DESIRE_HIGH, aoe.targetloc
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(botTarget)
        and J.IsAttacking(bot) and J.IsInRange(bot, botTarget, range) then
        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
    end
    return 0
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) or bot:HasModifier('modifier_bloodseeker_bloodrage') then return 0 end
    if J.IsRetreating(bot) then return 0 end
    if J.IsGoingOnSomeone(bot) and ValidEnemy(botTarget, true) and J.IsInRange(bot, botTarget, 600) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if (J.IsInTeamFight(bot, 1200) or J.IsPushing(bot) or J.IsDefending(bot))
        and #J.GetNearbyHeroes(bot, 600, true, BOT_MODE_NONE) > 0 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsValid(botTarget) and J.IsAttacking(bot)
        and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)
            or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot))
        and bot:GetHealth() / bot:GetMaxHealth() > 0.25
        and not J.CanKillTarget(botTarget, bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

function X.ConsiderBloodMist()
    if not bot:HasScepter() or not J.CanCastAbility(BloodMist) then return 0 end
    local radius = BloodMist:GetSpecialValueInt('radius')
    local hasEnemy = false
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)) do
        if ValidEnemy(enemy, false) and J.IsInRange(bot, enemy, radius) then hasEnemy = true end
    end
    local hp = bot:GetHealth() / bot:GetMaxHealth()
    if BloodMist:GetToggleState() then
        if hp <= 0.25 or not hasEnemy then return BOT_ACTION_DESIRE_HIGH end
    elseif hp > 0.55 and hasEnemy and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

X.ConsiderBloodrage = X.ConsiderQ
X.ConsiderBloodRite = X.ConsiderW
X.ConsiderRupture = X.ConsiderR
return X
