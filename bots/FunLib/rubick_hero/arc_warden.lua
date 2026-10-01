local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local Flux
local MagneticField
local SparkWraith
local FluxDesire, FluxTarget, MagneticFieldDesire, MagneticFieldLocation, SparkWraithDesire, SparkWraithLocation

local botTarget

local function ClampLocation(location, range)
    local origin = bot:GetLocation()
    local dx, dy = location.x - origin.x, location.y - origin.y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance > range then return Vector(origin.x + dx * range / distance, origin.y + dy * range / distance, location.z) end
    return location
end

local function WraithClear(location, target, radius)
    for _, creep in pairs(GetUnitList(UNIT_LIST_ENEMY_CREEPS)) do
        if creep ~= target and J.IsValid(creep) and J.CanBeAttacked(creep)
            and GetUnitToLocationDistance(creep, location) <= radius then return false end
    end
    return true
end

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local abilityName = ability:GetName()
    if abilityName ~= 'arc_warden_flux'
    and abilityName ~= 'arc_warden_magnetic_field'
    and abilityName ~= 'arc_warden_spark_wraith' then return nil end

    if J.CanNotUseAbility(bot) then return false end

    botTarget = J.GetProperTarget(bot)

    if abilityName == 'arc_warden_flux'
    then
        Flux = ability
        FluxDesire, FluxTarget = X.ConsiderFlux()
        if FluxDesire > 0
        then
            bot:Action_UseAbilityOnEntity(Flux, FluxTarget)
            return true
        end
    end

    if abilityName == 'arc_warden_magnetic_field'
    then
        MagneticField = ability
        MagneticFieldDesire, MagneticFieldLocation = X.ConsiderMagneticField()
        if MagneticFieldDesire > 0
        then
            bot:Action_UseAbilityOnLocation(MagneticField, MagneticFieldLocation)
            return true
        end
    end

    if abilityName == 'arc_warden_spark_wraith'
    then
        SparkWraith = ability
        SparkWraithDesire, SparkWraithLocation = X.ConsiderSparkWraith()
        if SparkWraithDesire > 0
        then
            bot:Action_UseAbilityOnLocation(SparkWraith, SparkWraithLocation)
            return true
        end
    end
    return false
end

local function IsFluxIsolated(target)
    local radius = Flux:GetSpecialValueInt('search_radius')
    for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if unit ~= target and J.IsValid(unit) and J.IsInRange(target, unit, radius) then return false end
    end
    for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMY_CREEPS)) do
        if unit ~= target and J.IsValid(unit) and J.IsInRange(target, unit, radius) then return false end
    end
    return true
end

function X.ConsiderFlux()
    if not Flux:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range = Flux:GetCastRange()
    local damage = Flux:GetSpecialValueInt('damage_per_second') * Flux:GetSpecialValueFloat('duration')
    local enemies = J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)
    local function canFlux(enemy)
        return J.IsValidHero(enemy) and J.IsInRange(bot, enemy, range)
            and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_antimage_counterspell')
            and not J.IsSuspiciousIllusion(enemy)
            and not enemy:HasModifier('modifier_abaddon_borrowed_time')
            and not enemy:HasModifier('modifier_oracle_false_promise_timer')
    end
    for _, enemy in pairs(enemies) do
        -- Nearby friendly units pause damage; slow still works in a pack.
        if canFlux(enemy) and IsFluxIsolated(enemy)
            and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_templar_assassin_refraction_absorb')
            and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    if J.IsRetreating(bot) then
        for _, enemy in pairs(enemies) do
            if canFlux(enemy) and not J.IsDisabled(enemy)
                and (J.IsChasingTarget(enemy, bot) or bot:WasRecentlyDamagedByHero(enemy, 2)) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    if (J.IsGoingOnSomeone(bot) or (J.IsLaning(bot) and J.GetMP(bot) > 0.5))
        and canFlux(botTarget) and IsFluxIsolated(botTarget) then
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    if J.IsInTeamFight(bot, 1200) then
        local best, mostDamage = nil, -1
        for _, enemy in pairs(enemies) do
            if canFlux(enemy) and (IsFluxIsolated(enemy) or J.IsChasingTarget(enemy, bot)) then
                local threat = enemy:GetEstimatedDamageToTarget(false, bot, 3, DAMAGE_TYPE_ALL)
                if threat > mostDamage then best, mostDamage = enemy, threat end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderMagneticField()
    if not MagneticField:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range = MagneticField:GetCastRange()
    local radius = MagneticField:GetSpecialValueInt('radius')
    local allies = J.GetAlliesNearLoc(bot:GetLocation(), range)
    local seen = {}; table.insert(allies, bot)
    for _, ally in pairs(allies) do
        if not seen[ally] and J.IsValidHero(ally) and (not ally:IsIllusion() or ally:HasModifier('modifier_arc_warden_tempest_double'))
            and J.IsInRange(bot, ally, range)
            and not ally:HasModifier('modifier_arc_warden_magnetic_field') then
            seen[ally] = true
            for _, enemy in pairs(J.GetNearbyHeroes(ally, 1200, true, BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and enemy:GetAttackTarget() == ally
                    and not J.IsInRange(enemy, ally, radius)
                    and (J.IsRetreating(ally) or J.GetHP(ally) < 0.45) then
                    return BOT_ACTION_DESIRE_HIGH, ally:GetLocation(), true
                end
            end
        end
    end
    -- Both Arc Warden and Rubick can use the current Field to activate a river rune.
    if bot:GetActiveMode() == BOT_MODE_RUNE then
        for _, rune in pairs({RUNE_POWERUP_1, RUNE_POWERUP_2}) do
            local location = GetRuneSpawnLocation(rune)
            if GetRuneStatus(rune) == RUNE_STATUS_AVAILABLE
                and GetUnitToLocationDistance(bot, location) <= range then
                return BOT_ACTION_DESIRE_HIGH, location
            end
        end
    end
    for _, ally in pairs(allies) do
        local attackTarget = ally:GetAttackTarget()
        if J.IsValidHero(ally) and (not ally:IsIllusion() or ally:HasModifier('modifier_arc_warden_tempest_double'))
            and J.IsInRange(bot, ally, range)
            and not ally:HasModifier('modifier_arc_warden_magnetic_field')
            and J.IsValid(attackTarget)
            and J.IsInRange(ally, attackTarget, ally:GetAttackRange() + 50)
            and (J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot)
                or J.IsPushing(bot) or J.IsDefending(bot) or J.IsDoingRoshan(bot)
                or J.IsDoingTormentor(bot) or (J.IsFarming(bot) and J.IsAllowedToSpam(bot, MagneticField:GetManaCost()))) then
            return BOT_ACTION_DESIRE_HIGH, ally:GetLocation()
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSparkWraith()
	if not SparkWraith:IsFullyCastable() then	return 0 end

	local nRadius = SparkWraith:GetSpecialValueInt( "radius" )
	local nCastRange = SparkWraith:GetCastRange()
	local nDamage = SparkWraith:GetSpecialValueInt( "spark_damage_base" )
	local nDelay = SparkWraith:GetSpecialValueFloat( "base_activation_delay" ) + SparkWraith:GetCastPoint()

	if J.IsValidHero( botTarget )
		and J.CanCastOnNonMagicImmune( botTarget )
	then
		if J.CanKillTarget( botTarget, nDamage, DAMAGE_TYPE_MAGICAL )
			and J.IsInRange( botTarget, bot, nCastRange )
            and WraithClear(botTarget:GetExtrapolatedLocation(nDelay), botTarget, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, ClampLocation(botTarget:GetExtrapolatedLocation( nDelay ), nCastRange)
		end
	end


	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		local botTarget = bot:GetAttackTarget()
		if J.IsRoshan( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.GetHP( botTarget ) > 0.2
		then
			return BOT_ACTION_DESIRE_LOW, ClampLocation(botTarget:GetLocation(), nCastRange)
		end
	end


	if J.IsInTeamFight( bot, 1200 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nDelay, 0 )
		if locationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, ClampLocation(locationAoE.targetloc, nCastRange)
		end
	end


	if J.IsGoingOnSomeone( bot )
	then

		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
            and WraithClear(botTarget:GetExtrapolatedLocation(nDelay), botTarget, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE, ClampLocation(botTarget:GetExtrapolatedLocation( nDelay ), nCastRange)
		end

		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nDelay, 0 )
		if locationAoE.count >= 1
			and not bot:HasModifier( "modifier_silencer_curse_of_the_silent" )
		then
			local nCreep = J.GetVulnerableUnitNearLoc( bot, false, true, 1600, nRadius, locationAoE.targetloc )
			if nCreep == nil
				or bot:HasModifier( "modifier_arc_warden_tempest_double" )
			then
				return BOT_ACTION_DESIRE_HIGH, ClampLocation(locationAoE.targetloc, nCastRange)
			end
		end

	end

	if J.IsRetreating( bot )
		and bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_HIGH
		and not bot:HasModifier( "modifier_silencer_curse_of_the_silent" )
	then
		local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid( npcEnemy ) and bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, ClampLocation(bot:GetLocation(), nCastRange)
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_FARM
		or J.IsPushing( bot )
		or J.IsDefending( bot )
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nDelay, 0 )
		if locationAoE.count > 2
			and not bot:HasModifier( "modifier_silencer_curse_of_the_silent" )
		then
			if bot:HasModifier( "modifier_arc_warden_tempest_double" )
			then
				return BOT_ACTION_DESIRE_HIGH, ClampLocation(locationAoE.targetloc, nCastRange)
			end

			local nLaneCreeps = bot:GetNearbyLaneCreeps( 1400, true )
			if #nLaneCreeps >= 2
			then
				if J.GetMP( bot ) > 0.62
				then
					return BOT_ACTION_DESIRE_HIGH, ClampLocation(locationAoE.targetloc, nCastRange)
				end
			else
				if J.GetMP( bot ) > 0.75
				then
					return BOT_ACTION_DESIRE_HIGH, ClampLocation(locationAoE.targetloc, nCastRange)
				end
			end
		end

	end


	if SparkWraith:GetLevel() >= 3 and bot:GetActiveMode() ~= BOT_MODE_LANING and J.IsAllowedToSpam( bot, 80 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nDelay, 0 )
		if locationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_HIGH, ClampLocation(locationAoE.targetloc, nCastRange)
		end
	end


	if bot:GetLevel() >= 10
		and ( J.IsAllowedToSpam( bot, 80 ) or bot:HasModifier( "modifier_arc_warden_tempest_double" ) )
		and DotaTime() > 8 * 60
	then

		local nEnemysHerosCanSeen = GetUnitList( UNIT_LIST_ENEMY_HEROES )
		local nTargetHero = nil
		local nTargetHeroHealth = 99999
		for _, enemy in pairs( nEnemysHerosCanSeen )
		do
			if J.IsValidHero( enemy )
				and GetUnitToUnitDistance( bot, enemy ) <= nCastRange
				and enemy:GetHealth() < nTargetHeroHealth
			then
				nTargetHero = enemy
				nTargetHeroHealth = enemy:GetHealth()
			end
		end
		if nTargetHero ~= nil
		then
			for i=0, 350, 50
			do
				local castLocation = J.GetLocationTowardDistanceLocation( nTargetHero, J.GetEnemyFountain(), 350 - i )
				if GetUnitToLocationDistance( bot, castLocation ) <= nCastRange
				then
					return BOT_ACTION_DESIRE_MODERATE, ClampLocation(castLocation, nCastRange)
				end
			end
		end


		local nLaneCreeps = bot:GetNearbyLaneCreeps( 1600, true )
		if #nLaneCreeps >= 3
		then
			local targetCreep = nLaneCreeps[#nLaneCreeps]
			if J.IsValid( targetCreep )
			then
				local castLocation = J.GetFaceTowardDistanceLocation( targetCreep, 375 )
				return BOT_ACTION_DESIRE_MODERATE , castLocation
			end
		end

		local nEnemyHeroesInView = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
		local nEnemyLaneFront = J.GetNearestLaneFrontLocation( bot:GetLocation(), true, nRadius/2 )
		if #nEnemyHeroesInView == 0 and nEnemyLaneFront ~= nil
			and GetUnitToLocationDistance( bot, nEnemyLaneFront ) <= nCastRange + nRadius
			and GetUnitToLocationDistance( bot, nEnemyLaneFront ) >= 800
		then
			local castLocation = J.GetLocationTowardDistanceLocation( bot, nEnemyLaneFront, nCastRange )
			if GetUnitToLocationDistance( bot, nEnemyLaneFront ) < nCastRange
			then
				castLocation = nEnemyLaneFront
			end
			return BOT_ACTION_DESIRE_MODERATE , castLocation
		end
	end


	local castLocation = J.GetLocationTowardDistanceLocation( bot, J.GetEnemyFountain(), nCastRange )
	if bot:HasModifier( "modifier_arc_warden_tempest_double" )
		or ( J.GetMP( bot ) > 0.92 and bot:GetLevel() > 11 and not IsLocationVisible( castLocation ) )
		or ( J.GetMP( bot ) > 0.38 and J.GetDistanceFromEnemyFountain( bot ) < 4300 )
	then
		if IsLocationPassable( castLocation )
			and not bot:HasModifier( "modifier_silencer_curse_of_the_silent" )
		then
			return BOT_ACTION_DESIRE_MODERATE, ClampLocation(castLocation, nCastRange)
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

return X
