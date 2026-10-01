local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local Bloodrage
local BloodRite
local BloodMist
local Rupture

local botTarget
local nHP

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local abilityName = ability:GetName()
    if abilityName ~= 'bloodseeker_blood_mist'
    and abilityName ~= 'bloodseeker_rupture'
    and abilityName ~= 'bloodseeker_bloodrage'
    and abilityName ~= 'bloodseeker_blood_bath' then return nil end

    if J.CanNotUseAbility(bot) then return false end

    botTarget = J.GetProperTarget(bot)

	nHP = bot:GetHealth()/bot:GetMaxHealth()

    if abilityName == 'bloodseeker_blood_mist'
    then
        BloodMist = ability
        BloodMistDesire = X.ConsiderBloodMist()
        if BloodMistDesire > 0
        then
            bot:Action_UseAbility(BloodMist)
            return true
        end
    end

	if abilityName == 'bloodseeker_rupture'
    then
        Rupture = ability
        RuptureDesire, RuptureTarget = X.ConsiderRupture()
        if RuptureDesire > 0
        then
            bot:Action_UseAbilityOnEntity(Rupture, RuptureTarget)
            return true
        end
    end

    if abilityName == 'bloodseeker_bloodrage'
    then
        Bloodrage = ability
        BloodrageDesire, BloodrageTarget = X.ConsiderBloodrage()
        if BloodrageDesire > 0
        then
            bot:Action_UseAbility(Bloodrage)
            return true
        end
    end

    if abilityName == 'bloodseeker_blood_bath'
    then
        BloodRite = ability
        BloodRiteDesire, BloodRiteLocation = X.ConsiderBloodRite()
        if BloodRiteDesire > 0
        then
            bot:Action_UseAbilityOnLocation(BloodRite, BloodRiteLocation)
            return true
        end
    end
    return false
end

function X.ConsiderBloodrage()

	-- 7.41: Bloodrage is now a no-target self-buff (no longer unit-target)
	if not Bloodrage:IsFullyCastable() then return 0 end

	if bot:HasModifier( 'modifier_bloodseeker_bloodrage' ) then return 0 end

	local nDamage = bot:GetAttackDamage()

	--团战
	if J.IsInTeamFight( bot, 1200 ) or J.IsPushing( bot ) or J.IsDefending( bot )
	then
		local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )
		if #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, 600 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	--打野时加速
	if J.IsValid( botTarget ) and botTarget:GetTeam() == TEAM_NEUTRAL
	then
		local tableNearbyCreeps = bot:GetNearbyCreeps( 1000, true )
		for _, ECreep in pairs( tableNearbyCreeps )
		do
			if J.IsValid( ECreep ) and not J.CanKillTarget( ECreep, nDamage, DAMAGE_TYPE_PHYSICAL )
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderBloodRite()

	if not BloodRite:IsFullyCastable()  then return 0 end

	local nRadius = 600
	local nCastRange = J.GetProperCastRange(false, bot, BloodRite:GetCastRange())
	local nCastPoint = BloodRite:GetCastPoint()
	local nDelay = BloodRite:GetSpecialValueFloat( 'delay' )
	local nManaCost = BloodRite:GetManaCost()
	local nDamage = BloodRite:GetSpecialValueInt( 'damage' )

	local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local tableNearbyAllyHeroes = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_NONE )

	for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if J.IsValid( npcEnemy ) and J.CanCastOnNonMagicImmune( npcEnemy ) and J.CanKillTarget( npcEnemy, nDamage, DAMAGE_TYPE_PURE )
		then
			if npcEnemy:GetMovementDirectionStability() >= 0.75 then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation( nDelay )
			else
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_LANING and J.IsAllowedToSpam( bot, nManaCost )
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage )
		if ( locationAoE.count >= 4 )
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	if ( J.IsPushing( bot ) or J.IsDefending( bot ) ) and J.IsAllowedToSpam( bot, nManaCost )
		and tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0
		and #tableNearbyAllyHeroes <= 2
	then
		local lanecreeps = bot:GetNearbyLaneCreeps( 1000, true )
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage )
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 )
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid( npcEnemy ) and bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 200, nRadius/2, nCastPoint, 0 )
		if ( locationAoE.count >= 2 )
		then
			local nInvUnit = J.GetInvUnitInLocCount( bot, nCastRange, nRadius/2, locationAoE.targetloc, false )
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + nRadius )
		then
			local nCastLoc = J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius, 2.0 )
			if nCastLoc ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nCastLoc
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderRupture()
	if not Rupture:IsFullyCastable() then 	return 0 end

	local nCastRange = Rupture:GetCastRange()

	local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, nCastRange + 200, true, BOT_MODE_NONE )

	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_bloodseeker_rupture' )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy
			end
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and J.Role.IsCarry( npcEnemy:GetUnitName() )
				and not npcEnemy:HasModifier( 'modifier_bloodseeker_rupture' )
				and not J.IsDisabled( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 100 )
			and not botTarget:HasModifier( 'modifier_bloodseeker_rupture' )
			and not J.IsDisabled( botTarget )
		then
			local allies = J.GetNearbyHeroes(botTarget,  1200, true, BOT_MODE_NONE )
			if ( allies ~= nil and #allies >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderBloodMist()
	if not bot:HasScepter()
	or not BloodMist:IsFullyCastable()
	then
		return BOT_MODE_NONE
	end

	local nRadius = 450
	local nInRangeEnemyHeroList = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

	if BloodMist:GetToggleState() == true
	then
		if nHP < 0.2
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		if #nInRangeEnemyHeroList == 0
		then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end

	if not BloodMist:GetToggleState() == false
	and nHP > 0.5
	then
		if J.IsValidHero(botTarget)
		and J.IsInRange(bot, botTarget, nRadius * 0.8)
		and J.CanCastOnNonMagicImmune(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_MODE_NONE
end

return X