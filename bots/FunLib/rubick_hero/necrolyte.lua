local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot, botTarget, abilityQ, abilityW, abilityAS, abilityR
local function Refresh()
    bot = GetBot(); botTarget = J.GetProperTarget(bot)
    abilityQ = bot:GetAbilityByName('necrolyte_death_pulse')
    abilityW = bot:GetAbilityByName('necrolyte_ghost_shroud')
    abilityAS = bot:GetAbilityByName('necrolyte_death_seeker')
    abilityR = bot:GetAbilityByName('necrolyte_reapers_scythe')
end
local function SpellRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(enemy)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) or bot:HasModifier('modifier_necrolyte_ghost_shroud') then return 0 end
    local physical, all = 0, 0
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) then
            physical = physical + enemy:GetEstimatedDamageToTarget(false, bot, 2, DAMAGE_TYPE_PHYSICAL)
            all = all + enemy:GetEstimatedDamageToTarget(false, bot, 2, DAMAGE_TYPE_ALL)
        end
    end
    local projectiles = J.GetAttackProjectileDamageByRange(bot, 1600)
    if bot:GetActualIncomingDamage(projectiles, DAMAGE_TYPE_PHYSICAL) >= bot:GetHealth()
        or physical >= bot:GetHealth() * 0.35 and physical >= all * 0.6
        and (J.IsRetreating(bot) or J.GetHP(bot) < 0.6) then return BOT_ACTION_DESIRE_HIGH end
    if not bot:HasModifier('modifier_ice_blast') and J.GetHP(bot) < 0.65
        and all - physical <= physical + bot:GetHealth() * 0.1
        and (bot:GetHealthRegen() >= 30 or J.CanCastAbility(abilityQ)
            and bot:GetMana() >= abilityW:GetManaCost() + abilityQ:GetManaCost()) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) or bot:IsInvisible() then return 0 end
    local radius = abilityQ:GetSpecialValueInt('area_of_effect')
    local heal = abilityQ:GetSpecialValueInt('heal')
    if not bot:HasModifier('modifier_ice_blast') and bot:GetMaxHealth() - bot:GetHealth() >= heal
        and (J.GetHP(bot) < 0.5 or bot:WasRecentlyDamagedByAnyHero(2) or J.IsAllowedToSpam(bot, abilityQ:GetManaCost())) then
        return BOT_ACTION_DESIRE_HIGH
    end
    for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and not ally:HasModifier('modifier_ice_blast') and J.IsInRange(bot, ally, radius)
            and ally:GetMaxHealth() - ally:GetHealth() >= heal
            and (J.GetHP(ally) < 0.4 or ally:WasRecentlyDamagedByAnyHero(2)
                or J.IsAllowedToSpam(bot, abilityQ:GetManaCost())) then return BOT_ACTION_DESIRE_HIGH end
    end
    local damage = abilityQ:GetAbilityDamage()
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, radius)
            and (enemy:HasModifier('modifier_necrolyte_reapers_scythe') or J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL)
                or J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then return BOT_ACTION_DESIRE_HIGH end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot))
        and J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then
        local creeps, kills = bot:GetNearbyCreeps(radius, true), 0
        for _, creep in ipairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep)
                and J.CanKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL) then kills = kills + 1 end
        end
        if kills >= 2 or #creeps >= 3 and not J.IsLaning(bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsValid(botTarget) and (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.CanCastOnNonMagicImmune(botTarget) and J.IsInRange(bot, botTarget, radius)
        and J.IsAttacking(bot) and J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.GetEstDamage(_, enemy, coefficient)
    local delay = abilityR:GetCastPoint() + abilityR:GetSpecialValueFloat('stun_duration')
    local futureHP = math.min(enemy:GetMaxHealth(), enemy:GetHealth() + math.max(0, enemy:GetHealthRegen()) * delay)
    local pulseDamage = 0
    -- Only budget a Pulse that arrives before the Scythe lands and whose mana is reserved.
    if J.CanCastAbility(abilityQ) and bot:GetMana() >= abilityR:GetManaCost() + abilityQ:GetManaCost()
        and J.IsInRange(bot, enemy, abilityQ:GetSpecialValueInt('area_of_effect'))
        and GetUnitToUnitDistance(bot, enemy) / abilityQ:GetSpecialValueInt('projectile_speed')
            + abilityQ:GetCastPoint() < abilityR:GetSpecialValueFloat('stun_duration') then
        pulseDamage = enemy:GetActualIncomingDamage(abilityQ:GetAbilityDamage(), DAMAGE_TYPE_MAGICAL)
    end
    return math.max(0, enemy:GetMaxHealth() - futureHP + pulseDamage) * coefficient
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) then return 0 end
    local range = SpellRange(abilityR)
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, range) and not J.IsHaveAegis(enemy)
            and not enemy:HasModifier('modifier_arc_warden_tempest_double')
            and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
            and not J.CannotBeKilled(bot, enemy) then
            local damage = X.GetEstDamage(bot, enemy, abilityR:GetSpecialValueFloat('damage_per_health'))
            local delay = abilityR:GetCastPoint() + abilityR:GetSpecialValueFloat('stun_duration')
            if J.WillKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL, delay)
                or enemy:IsChanneling() and enemy:HasModifier('modifier_teleporting') then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    return 0
end

function X.ConsiderAS()
    if not J.CanCastAbility(abilityAS) or bot:IsRooted() then return 0 end
    local range = SpellRange(abilityAS)
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        local best, safest = nil, #J.GetNearbyHeroes(bot, 700, true, BOT_MODE_NONE)
        for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), false, BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
                and J.IsInRange(bot, ally, range) and not J.IsInRange(bot, ally, 250) then
                local danger = #J.GetNearbyHeroes(ally, 700, true, BOT_MODE_NONE)
                if danger < safest then best, safest = ally, danger end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    end
    if J.IsGoingOnSomeone(bot) and Enemy(botTarget) and J.IsInRange(bot, botTarget, range)
        and not J.IsInRange(bot, botTarget, 250) and J.GetHP(bot) > 0.35 then
        local allies = J.GetNearbyHeroes(botTarget, 800, false, BOT_MODE_NONE)
        local enemies = J.GetNearbyHeroes(botTarget, 800, true, BOT_MODE_NONE)
        if #allies + 1 >= #enemies then return BOT_ACTION_DESIRE_HIGH, botTarget end
    end
    -- Reposition to a wounded ally for healing; don't jump blindly into a stronger enemy cluster.
    if J.CanCastAbility(abilityQ) and J.GetHP(bot) > 0.4 then
        for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), false, BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
                and not ally:HasModifier('modifier_ice_blast') and J.GetHP(ally) < 0.4
                and J.IsInRange(bot, ally, range)
                and #J.GetNearbyHeroes(ally, 700, true, BOT_MODE_NONE) <= 1 then
                return BOT_ACTION_DESIRE_HIGH, ally
            end
        end
    end
    return 0
end

function X.ConsiderStolenSpell(ability)
    local name = ability:GetName()
    if name ~= 'necrolyte_death_pulse' and name ~= 'necrolyte_ghost_shroud'
        and name ~= 'necrolyte_death_seeker' and name ~= 'necrolyte_reapers_scythe' then return nil end
    Refresh()
    if J.CanNotUseAbility(bot) or bot:IsChanneling() then return false end
    local desire, target
    if name == 'necrolyte_death_pulse' then abilityQ=ability;desire=X.ConsiderQ()
    elseif name == 'necrolyte_ghost_shroud' then abilityW=ability;desire=X.ConsiderW()
    elseif name == 'necrolyte_death_seeker' then abilityAS=ability;desire,target=X.ConsiderAS()
    else abilityR=ability;desire,target=X.ConsiderR() end
    if desire > 0 then
        if name == 'necrolyte_death_seeker' or name == 'necrolyte_reapers_scythe' then
            bot:Action_UseAbilityOnEntity(ability, target)
        else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
