local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local ThunderClap, CinderBrew, PrimalSplit, pendingBrew

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local name = ability:GetName()
    if name ~= 'brewmaster_cinder_brew' and name ~= 'brewmaster_thunder_clap'
        and name ~= 'brewmaster_primal_split' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    PrimalSplit = name == 'brewmaster_primal_split' and ability
        or bot:GetAbilityByName('brewmaster_primal_split')
    if name == 'brewmaster_primal_split' then
        if X.ConsiderPrimalSplit() > 0 then bot:Action_UseAbility(ability); return true end
    elseif name == 'brewmaster_cinder_brew' then
        CinderBrew = ability
        local desire, location = X.ConsiderCinderBrew()
        if desire > 0 then
            pendingBrew = DotaTime() + ability:GetCastPoint()
                + GetUnitToLocationDistance(bot, location) / ability:GetSpecialValueInt('projectile_speed') + 0.1
            bot:Action_UseAbilityOnLocation(ability, location)
            return true
        end
    else
        ThunderClap = ability
        if X.ConsiderThunderClap() > 0 then bot:Action_UseAbility(ability); return true end
    end
    return false
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit)
    return J.IsValidTarget(unit) and J.CanCastOnNonMagicImmune(unit)
        and not J.IsSuspiciousIllusion(unit)
        and not unit:HasModifier('modifier_abaddon_borrowed_time')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end

local function ReserveSplit(ability)
    return PrimalSplit ~= nil and J.CanCastAbility(PrimalSplit)
        and #bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE) > 0
        and bot:GetMana() < ability:GetManaCost() + PrimalSplit:GetManaCost()
end

local function BrewLocation(location, radius)
    local range = CastRange(CinderBrew)
    local distance = GetUnitToLocationDistance(bot, location)
    if distance <= range then return location end
    if distance <= range + radius then
        return J.Site.GetXUnitsTowardsLocation(bot, location, range)
    end
    return nil
end

function X.ConsiderPrimalSplit()
    if not J.CanCastAbility(PrimalSplit) then return BOT_ACTION_DESIRE_NONE end
    local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
    local threats = 0
    for _, enemy in pairs(enemies) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and not enemy:IsInvulnerable() then threats = threats + 1 end
    end
    if threats > 0 and bot:WasRecentlyDamagedByAnyHero(3)
        and (J.GetHP(bot) < 0.35 or (J.IsRetreating(bot) and threats >= 2)) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsInTeamFight(bot, 1200) and threats >= 2 then return BOT_ACTION_DESIRE_HIGH end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidTarget(target)
        and not J.IsSuspiciousIllusion(target) and not target:IsAttackImmune()
        and not target:IsInvulnerable() and J.IsInRange(bot, target, 700)
        and not target:HasModifier('modifier_abaddon_borrowed_time')
        and not J.IsLocationInChrono(target:GetLocation())
        and J.IsCore(target) and J.WeAreStronger(bot, 1200) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderThunderClap(lethalOnly)
    if not J.CanCastAbility(ThunderClap) then return BOT_ACTION_DESIRE_NONE end
    local radius = ThunderClap:GetSpecialValueInt('radius')
    local damage = ThunderClap:GetSpecialValueInt('damage')
    local enemies = bot:GetNearbyHeroes(radius, true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, radius)
            and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL)
            and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_oracle_false_promise_timer')
            and not enemy:HasModifier('modifier_templar_assassin_refraction_absorb') then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    if lethalOnly then return BOT_ACTION_DESIRE_NONE end
    if ReserveSplit(ThunderClap) then return BOT_ACTION_DESIRE_NONE end
    -- Let the barrel arrive before spending the ignition damage.
    if pendingBrew ~= nil and DotaTime() < pendingBrew then return BOT_ACTION_DESIRE_NONE end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsInRange(bot, target, radius) then
        return BOT_ACTION_DESIRE_HIGH
    end
    for _, enemy in pairs(enemies) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, radius)
            and ((J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2))
                or (J.IsLaning(bot) and J.GetMP(bot) > 0.5)) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    local creeps = bot:GetNearbyLaneCreeps(radius, true)
    if J.IsLaning(bot) and J.GetMP(bot) > 0.35 then
        local kills = 0
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep)
                and J.IsInRange(bot, creep, radius)
                and J.CanKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL) then
                kills = kills + 1
                if #enemies > 0 and (J.IsKeyWordUnit('ranged', creep)
                    or J.IsKeyWordUnit('siege', creep)) then return BOT_ACTION_DESIRE_HIGH end
            end
        end
        if kills >= 2 then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsAttacking(bot) and J.GetMP(bot) > 0.4 then
        if (J.IsPushing(bot) or J.IsDefending(bot)) and #creeps >= 4 then
            return BOT_ACTION_DESIRE_HIGH
        end
        if J.IsFarming(bot) then
            local neutrals = bot:GetNearbyNeutralCreeps(radius)
            if #creeps >= 3 or #neutrals >= 3
                or (#neutrals >= 2 and neutrals[1]:IsAncientCreep()) then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
        if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot))
            and J.IsValid(target) and J.IsInRange(bot, target, radius)
            and J.CanCastOnNonMagicImmune(target) then return BOT_ACTION_DESIRE_HIGH end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCinderBrew()
    if not J.CanCastAbility(CinderBrew) or ReserveSplit(CinderBrew) then
        return BOT_ACTION_DESIRE_NONE, nil
    end
    local radius = CinderBrew:GetSpecialValueInt('radius')
    local range = CastRange(CinderBrew)
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) or J.IsLaning(bot) then
        if Enemy(target) and not target:HasModifier('modifier_brewmaster_cinder_brew')
            and (not J.IsLaning(bot) or J.GetMP(bot) > 0.45) then
            local delay = CinderBrew:GetCastPoint()
                + GetUnitToUnitDistance(bot, target) / CinderBrew:GetSpecialValueInt('projectile_speed')
            local predicted = J.GetCorrectLoc(target, delay)
            local location = BrewLocation(predicted, radius)
            if location ~= nil and GetLocationToLocationDistance(location, predicted) <= radius then
                return BOT_ACTION_DESIRE_HIGH, location
            end
        end
    end
    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
        for _, enemy in pairs(bot:GetNearbyHeroes(math.min(1600, range), true, BOT_MODE_NONE)) do
            if Enemy(enemy) and bot:WasRecentlyDamagedByHero(enemy, 2)
                and J.IsChasingTarget(enemy, bot)
                and not enemy:HasModifier('modifier_brewmaster_cinder_brew') then
                return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
            end
        end
    end
    if J.IsInTeamFight(bot, 1200) or J.IsPushing(bot) or J.IsDefending(bot) then
        local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), range, radius,
            CinderBrew:GetCastPoint(), 0)
        local useful = 0
        for _, enemy in pairs(J.GetEnemiesNearLoc(aoe.targetloc, radius)) do
            if Enemy(enemy) and not enemy:HasModifier('modifier_brewmaster_cinder_brew') then
                useful = useful + 1
            end
        end
        if useful >= 2 and GetUnitToLocationDistance(bot, aoe.targetloc) <= range then
            return BOT_ACTION_DESIRE_HIGH, aoe.targetloc
        end
    end
    if J.IsAttacking(bot) and J.GetMP(bot) > 0.45
        and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then
        local neutrals = bot:GetNearbyNeutralCreeps(math.min(range, 1600))
        local creeps = bot:GetNearbyLaneCreeps(math.min(range, 1600), true)
        for _, list in ipairs({neutrals, creeps}) do
            for _, center in pairs(list) do
                if J.IsValid(center) and J.CanBeAttacked(center) then
                    local count = 0
                    for _, creep in pairs(list) do
                        if J.IsValid(creep) and J.CanBeAttacked(creep)
                            and GetUnitToUnitDistance(center, creep) <= radius then count = count + 1 end
                    end
                    if count >= 3 or (count >= 2 and center:IsAncientCreep()) then
                        return BOT_ACTION_DESIRE_HIGH, center:GetLocation()
                    end
                end
            end
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsAttacking(bot)
        and J.IsValid(target) and J.CanCastOnNonMagicImmune(target)
        and J.IsInRange(bot, target, range) then
        return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

return X
