local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local Firestorm
local PitOfMalice
local FiendsGate

local botTarget

local gateDestination, gateExpires, gateMinimumDistance, gateFountainOffset

local function CastLocation(location, range)
    local offset = location - bot:GetLocation()
    if offset:Length2D() <= range then return location end
    return bot:GetLocation() + offset:Normalized() * range
end

local function SafeGateLocation(location, minimumDistance)
    return location ~= nil
        and GetUnitToLocationDistance(bot, location) >= (minimumDistance or FiendsGate:GetSpecialValueInt('minimum_distance'))
        and IsLocationPassable(location)
        and not J.IsLocationInChrono(location)
        and not J.IsLocationInBlackHole(location)
        and not J.IsLocationInArena(location, 600)
end

function X.UsePendingGate()
    if gateDestination == nil then return false end
    if DotaTime() > gateExpires or not bot:IsAlive() or not SafeGateLocation(gateDestination, gateMinimumDistance) then
        gateDestination = nil; return false
    end
    if bot:IsChanneling() then return true end
    if bot:IsRooted() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsInvulnerable() or bot:IsUsingAbility() or bot:IsCastingAbility()
        or J.HasQueuedAction(bot) or bot:HasModifier('modifier_doom_bringer_doom') then
        return false
    end
    local warp = bot:GetAbilityByName('abyssal_underlord_portal_warp')
    -- Valve marks this unit-targeted interaction as castable while hidden and silenced.
    if warp == nil or not warp:IsFullyCastable() then return false end
    local portals = J.GetUnderlordPortal()
    if portals == nil then return false end
    local arrivalRadius = 600
    if (gateDestination - J.GetTeamFountain()):Length2D() < 600 then
        arrivalRadius = arrivalRadius + gateFountainOffset
    end
    for i, portal in ipairs(portals) do
        local other = portals[i == 1 and 2 or 1]
        if J.IsValid(portal) and J.IsValid(other)
            and J.IsInRange(bot, portal, warp:GetCastRange())
            and GetUnitToLocationDistance(other, gateDestination) < arrivalRadius then
            gateDestination = nil
            bot:Action_UseAbilityOnEntity(warp, portal)
            return true
        end
    end
    return false
end

local function RememberGate(location)
    gateDestination, gateExpires = location, DotaTime() + FiendsGate:GetSpecialValueInt('duration')
    gateMinimumDistance = FiendsGate:GetSpecialValueInt('minimum_distance')
    gateFountainOffset = FiendsGate:GetSpecialValueInt('distance_from_fountain')
end

local function EnemyCanBeHit(enemy)
    return J.IsValidTarget(enemy) and J.CanCastOnNonMagicImmune(enemy)
        and not J.IsSuspiciousIllusion(enemy)
end

local function FarmLocation(units, range, radius, minimum)
    local best, bestCount = nil, minimum - 1
    for _, unit in pairs(units) do
        if J.IsValid(unit) and not unit:HasModifier('modifier_fountain_glyph') then
            local location = CastLocation(unit:GetLocation(), range)
            local count = 0
            for _, other in pairs(units) do
                if J.IsValid(other) and not other:HasModifier('modifier_fountain_glyph')
                    and GetUnitToLocationDistance(other, location) <= radius then count = count + 1 end
            end
            if count > bestCount then best, bestCount = location, count end
        end
    end
    return best
end


function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local abilityName = ability:GetName()
    if abilityName ~= 'abyssal_underlord_pit_of_malice'
    and abilityName ~= 'abyssal_underlord_firestorm'
    and abilityName ~= 'abyssal_underlord_dark_portal' then return nil end

    if X.UsePendingGate() then return true end
    if J.CanNotUseAbility(bot) then return false end

    botTarget = J.GetProperTarget(bot)

    if abilityName == 'abyssal_underlord_pit_of_malice'
    then
        PitOfMalice = ability
        PitOfMaliceDesire, PitOfMaliceLocation = X.ConsiderPitOfMalice()
        if PitOfMaliceDesire > 0
        then
            bot:Action_UseAbilityOnLocation(PitOfMalice, PitOfMaliceLocation)
            return true
        end
    end

    if abilityName == 'abyssal_underlord_firestorm'
    then
        Firestorm = ability
        local firestormOnAlly
        FirestormDesire, FirestormLocation, firestormOnAlly = X.ConsiderFirestorm()
        if FirestormDesire > 0
        then
            if firestormOnAlly then bot:Action_UseAbilityOnEntity(Firestorm, FirestormLocation)
            else bot:Action_UseAbilityOnLocation(Firestorm, FirestormLocation) end
            return true
        end
    end

    if abilityName == 'abyssal_underlord_dark_portal'
    then
        FiendsGate = ability
        FiendsGateDesire, FiendsGateLocation = X.ConsiderFiendsGate()
        if FiendsGateDesire > 0
        then
            RememberGate(FiendsGateLocation)
            bot:Action_UseAbilityOnLocation(FiendsGate, FiendsGateLocation)
            return true
        end
    end
    return false
end

function X.ConsiderFirestorm()
    if not Firestorm:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range, radius = Firestorm:GetCastRange(), Firestorm:GetSpecialValueInt('radius')
    local delay = Firestorm:GetCastPoint()

    -- Shard can attach the storm to a frontliner instead of leaving it behind during a chase.
    if Firestorm:GetSpecialValueInt('can_target_units') > 0 then
        local allies = J.GetAlliesNearLoc(bot:GetLocation(), range)
        table.insert(allies, bot)
        for _, ally in pairs(allies) do
            if J.IsValidHero(ally) and not ally:IsInvulnerable() and not J.IsSuspiciousIllusion(ally)
                and J.IsGoingOnSomeone(ally) and J.IsInRange(bot, ally, range) then
                local target = J.GetProperTarget(ally)
                if EnemyCanBeHit(target) and J.IsInRange(ally, target, radius * 0.8) then
                    return BOT_ACTION_DESIRE_HIGH, ally, true
                end
            end
        end
    end

    if J.IsInTeamFight(bot, 1200) then
        local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), range, radius, delay, 0)
        local location = CastLocation(aoe.targetloc, range)
        local count = 0
        for _, enemy in pairs(J.GetEnemiesNearLoc(location, radius)) do
            if EnemyCanBeHit(enemy) and (enemy:GetExtrapolatedLocation(delay) - location):Length2D() <= radius then
                count = count + 1
            end
        end
        if count >= 2 then return BOT_ACTION_DESIRE_HIGH, location end
    end

    -- Follow a root or another ally disable even if the bot's active mode is not attack.
    if EnemyCanBeHit(botTarget) and J.IsInRange(bot, botTarget, range + radius)
        and (J.IsGoingOnSomeone(bot) or J.IsDisabled(botTarget))
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time') then
        local predicted = J.IsDisabled(botTarget) and botTarget:GetLocation() or botTarget:GetExtrapolatedLocation(delay)
        local location = CastLocation(predicted, range)
        if (predicted - location):Length2D() <= radius then
            return BOT_ACTION_DESIRE_HIGH, location
        end
    end

    if (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot)
        or (J.IsLaning(bot) and Firestorm:GetLevel() >= 3))
        and J.IsAllowedToSpam(bot, Firestorm:GetManaCost()) then
        local creeps = bot:GetNearbyLaneCreeps(range + radius, true)
        local location = FarmLocation(creeps, range, radius, 3)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
        if J.IsFarming(bot) and J.IsAttacking(bot) then
            location = FarmLocation(bot:GetNearbyNeutralCreeps(range + radius), range, radius, 2)
            if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
        end
    end

    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(botTarget)
        and J.IsInRange(bot, botTarget, range + radius) and J.IsAttacking(bot) then
        return BOT_ACTION_DESIRE_HIGH, CastLocation(botTarget:GetLocation(), range)
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderPitOfMalice()
    if not PitOfMalice:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range, radius = PitOfMalice:GetCastRange(), PitOfMalice:GetSpecialValueInt('radius')
    local delay = PitOfMalice:GetCastPoint()
    for _, enemy in pairs(J.GetNearbyHeroes(bot, range + radius, true, BOT_MODE_NONE)) do
        if EnemyCanBeHit(enemy) and enemy:IsChanneling()
            and not enemy:HasModifier('modifier_abyssal_underlord_pit_of_malice_ensare') then
            return BOT_ACTION_DESIRE_HIGH, CastLocation(enemy:GetLocation(), range)
        end
    end

    if J.IsInTeamFight(bot, 1200) or J.IsPushing(bot) or J.IsDefending(bot) then
        local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), range, radius, delay, 0)
        local location = CastLocation(aoe.targetloc, range)
        local count = 0
        for _, enemy in pairs(J.GetEnemiesNearLoc(location, radius)) do
            if EnemyCanBeHit(enemy) and not enemy:IsRooted()
                and (enemy:GetExtrapolatedLocation(delay) - location):Length2D() <= radius then count = count + 1 end
        end
        if count >= 2 then return BOT_ACTION_DESIRE_HIGH, location end
    end

    if J.IsGoingOnSomeone(bot) and EnemyCanBeHit(botTarget)
        and J.IsInRange(bot, botTarget, range + radius) and not botTarget:IsRooted()
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe') then
        local predicted = J.IsDisabled(botTarget) and botTarget:GetLocation() or botTarget:GetExtrapolatedLocation(delay)
        local location = CastLocation(predicted, range)
        if (predicted - location):Length2D() <= radius then
            return BOT_ACTION_DESIRE_HIGH, location
        end
    end

    if J.IsRetreating(bot) then
        for _, enemy in pairs(J.GetNearbyHeroes(bot, range + radius, true, BOT_MODE_NONE)) do
            if EnemyCanBeHit(enemy) and J.IsChasingTarget(enemy, bot) and not J.IsDisabled(enemy)
                and bot:WasRecentlyDamagedByAnyHero(2.5) then
                local predicted = enemy:GetExtrapolatedLocation(delay)
                local location = CastLocation(predicted, range)
                if (predicted - location):Length2D() <= radius then
                    return BOT_ACTION_DESIRE_HIGH, location
                end
            end
        end
    end
    -- Keep Pit mana for hero control rather than boss damage.
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderFiendsGate()
    if not FiendsGate:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    -- Begin an escape while the long portal channel is still possible.
    if J.IsRetreating(bot) and J.GetHP(bot) < 0.55 and bot:WasRecentlyDamagedByAnyHero(2.5) then
        local fountain = J.GetTeamFountain()
        if SafeGateLocation(fountain) then return BOT_ACTION_DESIRE_HIGH, fountain end
    end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)

    if nTeamFightLocation ~= nil
    and GetUnitToLocationDistance(bot, nTeamFightLocation) > 2500
    and not J.IsGoingOnSomeone(bot)
    and not J.IsRetreating(bot)
    and not J.IsInLaningPhase()
    then
        local nInRangeAlly = J.GetAlliesNearLoc(nTeamFightLocation, 1200)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nTeamFightLocation, 1200)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly + 1 >= #nInRangeEnemy
        and #nInRangeEnemy >= 1 and #nInRangeAlly >= 1
        then
            local targetLoc = J.GetCenterOfUnits(nInRangeAlly)

            if SafeGateLocation(targetLoc)
            and not J.IsLocationInChrono(targetLoc)
            and not J.IsLocationInBlackHole(targetLoc)
            and not J.IsLocationInArena(targetLoc, 600)
            then
                bot:SetTarget(nInRangeEnemy[1])
                return BOT_ACTION_DESIRE_HIGH, targetLoc
            end
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and GetUnitToUnitDistance(bot, botTarget) > 2500
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsInLaningPhase()
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
            local nEnemyTowers = bot:GetNearbyTowers(700, true)

			if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and nInRangeEnemy ~= nil and nEnemyTowers ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            and #nInRangeEnemy == 0 and #nEnemyTowers == 0 and #nInRangeAlly >= 1
            then
                local targetLoc = J.GetCenterOfUnits(nInRangeAlly)

                if SafeGateLocation(targetLoc)
                and not J.IsLocationInChrono(targetLoc)
                and not J.IsLocationInBlackHole(targetLoc)
                and not J.IsLocationInArena(targetLoc, 600)
                then
                    bot:SetTarget(botTarget)
                    return BOT_ACTION_DESIRE_HIGH, targetLoc
                end
            end
		end
	end

    local aveDist = {0,0,0}
    local pushCount = {0,0,0}
    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if J.IsValidHero(allyHero)
        and J.IsGoingOnSomeone(allyHero)
        and GetUnitToUnitDistance(bot, allyHero) > 2500
        and not allyHero:IsIllusion()
        and not J.IsInLaningPhase()
        then
            local allyTarget = allyHero:GetAttackTarget()
            local nAllyInRangeAlly = J.GetNearbyHeroes(allyHero, 800, false, BOT_MODE_NONE)

            if J.IsValidTarget(allyTarget)
            and J.IsInRange(allyHero, allyTarget, 800)
            and J.GetHP(allyHero) > 0.5
            and J.IsCore(allyTarget)
            and not J.IsSuspiciousIllusion(allyTarget)
            then
                local nTargetInRangeAlly = J.GetNearbyHeroes(allyTarget, 800, false, BOT_MODE_NONE)
                local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
                local nEnemyTowers = bot:GetNearbyTowers(700, true)

                if nAllyInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nAllyInRangeAlly + 1 >= #nTargetInRangeAlly
                and #nTargetInRangeAlly >= 1
                and nInRangeEnemy ~= nil and nEnemyTowers ~= nil
                and #nInRangeEnemy == 0 and #nEnemyTowers == 0
                then
                    local targetLoc = allyHero:GetExtrapolatedLocation(1)

                    if SafeGateLocation(targetLoc)
                    and not J.IsLocationInChrono(targetLoc)
                    and not J.IsLocationInBlackHole(targetLoc)
                    and not J.IsLocationInArena(targetLoc, 600)
                    then
                        bot:SetTarget(allyTarget)
                        return BOT_ACTION_DESIRE_HIGH, targetLoc
                    end
                end
            end
        end

        if J.IsValidHero(allyHero)
        and bot ~= allyHero
        and not J.IsSuspiciousIllusion(allyHero)
        and not J.IsMeepoClone(allyHero)
        then
            if allyHero:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
            and bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
            then
                pushCount[1] = pushCount[1] + 1
                aveDist[1] = aveDist[1] + GetUnitToLocationDistance(allyHero, GetLaneFrontLocation(GetTeam(), LANE_TOP, 0))
            end

            if allyHero:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
            and bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
            then
                pushCount[2] = pushCount[2] + 1
                aveDist[2] = aveDist[2] + GetUnitToLocationDistance(allyHero, GetLaneFrontLocation(GetTeam(), LANE_MID, 0))
            end

            if allyHero:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
            and bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
            then
                pushCount[3] = pushCount[3] + 1
                aveDist[3] = aveDist[3] + GetUnitToLocationDistance(allyHero, GetLaneFrontLocation(GetTeam(), LANE_BOT, 0))
            end
        end
    end

    if pushCount[1] ~= nil and pushCount[1] >= 3 and (aveDist[1] / pushCount[1]) <= 1200
    then
        if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), LANE_TOP, 0)) > 4000
        then
            return BOT_ACTION_DESIRE_HIGH, GetUnitToLocationDistance(GetTeam(), LANE_TOP, 0)
        end
    elseif pushCount[2] ~= nil and pushCount[2] >= 3 and (aveDist[2] / pushCount[2]) <= 1200
    then
        if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), LANE_MID, 0)) > 4000
        then
            return BOT_ACTION_DESIRE_HIGH, GetUnitToLocationDistance(GetTeam(), LANE_MID, 0)
        end
    elseif pushCount[3] ~= nil and pushCount[3] >= 3 and (aveDist[3] / pushCount[3]) <= 1200
    then
        if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), LANE_BOT, 0)) > 4000
        then
            return BOT_ACTION_DESIRE_HIGH, GetUnitToLocationDistance(GetTeam(), LANE_BOT, 0)
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

return X
