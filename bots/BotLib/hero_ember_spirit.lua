-- Credit goes to Furious Puppy for Bot Experiment

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: mid; forced other roles use this build.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/ember_spirit')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Chains, [2] Sleight, [3] Flame Guard, [6] Fire Remnant.
local nAbilityBuildList = {3,2,3,1,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +165 Flame Guard barrier
    t15={0,10}, -- +100% Flame Guard DPS
    t20={0,10}, -- +50 Sleight of Fist hero damage
    t25={0,10}, -- 2 Sleight of Fist charges
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_tango', 'item_double_branches', 'item_double_branches', 'item_faerie_fire',
    'item_bottle', 'item_magic_wand', 'item_urn_of_shadows', 'item_phase_boots',
    'item_spirit_vessel', 'item_kaya', 'item_aghanims_shard', 'item_black_king_bar',
    'item_ultimate_scepter', 'item_kaya_and_sange', 'item_shivas_guard', 'item_refresher',
    -- Bot policy: consume Scepter, then add cooldown utility within six slots.
    'item_ultimate_scepter_2', 'item_octarine_core',
}
X.sSellList = {
    'item_black_king_bar', 'item_bottle',
    'item_ultimate_scepter', 'item_magic_wand',
    'item_shivas_guard', 'item_spirit_vessel',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Chains at level 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end
end

local SearingChains 		= bot:GetAbilityByName( "ember_spirit_searing_chains" )
local SleightOfFist 		= bot:GetAbilityByName( "ember_spirit_sleight_of_fist" )
local FlameGuard 			= bot:GetAbilityByName( "ember_spirit_flame_guard" )
local ActivateFireRemnant 	= bot:GetAbilityByName( "ember_spirit_activate_fire_remnant" )
local FireRemnant 			= bot:GetAbilityByName( "ember_spirit_fire_remnant" )

local SearingChainsDesire
local SleightOfFistDesire, SoFLocation
local FlameGuardDesire
local ActivateFireRemnantDesire, ActivateRemnantLocation
local FireRemnantDesire, FireRemnantLocation

local SleightChainsDesire, SCLocation

local remnantCastTime = -100
local remnantCastGap  = 0.5


local function OwnedRemnant(unit)
    return unit ~= nil and not unit:IsNull() and unit:IsAlive()
        and unit:GetUnitName() == 'npc_dota_ember_spirit_remnant'
        and unit:GetPlayerID() == bot:GetPlayerID()
end

local function ChainsTargets(location)
    local count = 0
    local radius = SearingChains:GetSpecialValueInt('radius')
    for _, list in ipairs({J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE), bot:GetNearbyCreeps(1600, true)}) do
        for _, unit in pairs(list) do
            if J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit) and not unit:IsInvisible()
                and GetUnitToLocationDistance(unit, location) <= radius then count = count + 1 end
        end
    end
    return count
end

function X.UseChainsDuringSleight()
    if not bot:HasModifier('modifier_ember_spirit_sleight_of_fist_caster')
        or not bot:IsAlive() or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed()
        or bot:IsNightmared() or bot:IsChanneling() or bot:IsCastingAbility() or bot:NumQueuedActions() > 0
        or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active')
        or not J.CanCastAbility(SearingChains) then return false end
    local radius = SearingChains:GetSpecialValueInt('radius')
    for _, enemy in pairs(J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and not enemy:IsInvisible() and not J.IsDisabled(enemy) then
            bot:Action_UseAbility(SearingChains)
            return true
        end
    end
    return false
end

function X.SkillsComplement()
    if X.UseChainsDuringSleight() then return end
    if J.CanNotUseAbility(bot) then return end

    if J.IsRetreating(bot) then
        local desire, location = X.ConsiderActivateFireRemnant()
        if desire > 0 then
            bot:Action_UseAbilityOnLocation(ActivateFireRemnant, location)
            return
        end
    end

	SleightChainsDesire, SCLocation = X.ConsiderSleightChains()
	if SleightChainsDesire > 0
	then
		-- Chains is issued only after Sleight movement is observed, not blindly queued.
		bot:Action_UseAbilityOnLocation(SleightOfFist, SCLocation)
		return
	end

	SleightOfFistDesire, SoFLocation = X.ConsiderSleightOfFist()
	if SleightOfFistDesire > 0
	then
		bot:Action_UseAbilityOnLocation(SleightOfFist, SoFLocation)
		return
	end

	SearingChainsDesire = X.ConsiderSearingChains()
	if SearingChainsDesire > 0
	then
		bot:Action_UseAbility(SearingChains)
		return
	end

	FireRemnantDesire, FireRemnantLocation = X.ConsiderFireRemnant()
    if FireRemnantDesire > 0
	then
		bot:Action_UseAbilityOnLocation(FireRemnant, FireRemnantLocation)
		remnantCastTime = DotaTime()
		return
	end

	ActivateFireRemnantDesire, ActivateRemnantLocation = X.ConsiderActivateFireRemnant()
	if ActivateFireRemnantDesire > 0
	then
		bot:Action_UseAbilityOnLocation(ActivateFireRemnant, ActivateRemnantLocation)
		return
	end

	FlameGuardDesire = X.ConsiderFlameGuard()
	if FlameGuardDesire > 0
	then
		bot:Action_UseAbility(FlameGuard)
		return
	end
end

function X.ConsiderSearingChains()
	if not J.CanCastAbility(SearingChains)
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = SearingChains:GetSpecialValueInt('radius')
	local nDamage = SearingChains:GetSpecialValueInt('damage_per_second') * SearingChains:GetSpecialValueFloat('duration')
	local nEnemyHeroes = J.GetAroundEnemyHeroList(nRadius)
	local botTarget = J.GetProperTarget(bot)

	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not enemyHero:IsInvisible()
		and J.IsInRange(bot, enemyHero, nRadius)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not J.IsDisabled(enemyHero)
		then
			if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
			then
				return BOT_ACTION_DESIRE_HIGH
			end

			if ChainsTargets(bot:GetLocation()) <= SearingChains:GetSpecialValueInt('unit_count')
                and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius + 50, true, BOT_MODE_NONE)

		if J.IsValidHero(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and J.CanCastOnNonMagicImmune(botTarget )
		and not botTarget:IsInvisible()
		and not J.IsDisabled(botTarget)
		and not J.IsSuspiciousIllusion(botTarget)
		then
			if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end

	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius + 50, true, BOT_MODE_NONE)

		if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeEnemy > #nInRangeAlly
		and (#nInRangeEnemy >= 2 or (J.GetHP(bot) < 0.6 or bot:WasRecentlyDamagedByAnyHero(2)))
		then
			if J.IsValidHero(nInRangeEnemy[1])
			and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
            and not nInRangeEnemy[1]:IsInvisible()
			and not J.IsDisabled(nInRangeEnemy[1])
			and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
			and not nInRangeEnemy[1]:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and not J.IsDisabled(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSleightOfFist()
	if not J.CanCastAbility(SleightOfFist) or bot:IsRooted() or bot:IsDisarmed()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = SleightOfFist:GetSpecialValueInt('radius')
	local nCastRange = SleightOfFist:GetCastRange()
	local nCastPoint = SleightOfFist:GetCastPoint()
	local nManaCost = SleightOfFist:GetManaCost()
	local nDamage = bot:GetAttackDamage() + SleightOfFist:GetSpecialValueInt('bonus_hero_damage')
	local nAbilityLevel = SleightOfFist:GetLevel()
	local botTarget = J.GetProperTarget(bot)

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if J.IsValidHero(enemyHero)
		and J.CanCastOnMagicImmune(enemyHero)
		and J.CanBeAttacked(enemyHero) and not J.IsInEtherealForm(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange)
		and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
		end
	end

	if J.IsStunProjectileIncoming(bot, bot:GetAttackRange())
	then
		local nInRangeCreeps = bot:GetNearbyCreeps(nCastRange, true)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if nInRangeCreeps ~= nil and #nInRangeCreeps >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeCreeps[1]:GetLocation()
		elseif nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if nLocationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnMagicImmune(botTarget)
		and J.CanBeAttacked(botTarget) and not J.IsInEtherealForm(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
		then
			if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and ((#nInRangeAlly >= #nInRangeEnemy) or (#nInRangeEnemy > #nInRangeAlly and J.WeAreStronger(bot, 1000)))
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 250, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange + 100, true, BOT_MODE_NONE)

		if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeEnemy > #nInRangeAlly
		and (#nInRangeEnemy >= 2 or (J.GetHP(bot) < 0.6 or bot:WasRecentlyDamagedByAnyHero(2.5)))
		then
			if J.IsValidHero(nInRangeEnemy[1])
			and J.CanCastOnMagicImmune(nInRangeEnemy[1])
			and J.CanBeAttacked(nInRangeEnemy[1]) and not J.IsInEtherealForm(nInRangeEnemy[1])
			and not J.IsDisabled(nInRangeEnemy[1])
			and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
			and not nInRangeEnemy[1]:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
			end
		end
	end

    if J.IsFarming(bot)
	and nAbilityLevel >= 3
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if nLocationAoE.count >= 3 and #nNeutralCreeps >= 3
		then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsLaning(bot) and J.AllowedToSpam(bot, nManaCost)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		local creepDamage = bot:GetAttackDamage()

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep))
			and creep:GetHealth() <= creepDamage
			then
				local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

				if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
				then
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
				end
			end
		end
	end

	if (J.IsPushing(bot) or J.IsDefending(bot))
	and nAbilityLevel >= 3
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		local nLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		and nLocationAoE.count >= 4
		then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFlameGuard()
	if not J.CanCastAbility(FlameGuard) or bot:HasModifier('modifier_ember_spirit_flame_guard')
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = FlameGuard:GetSpecialValueInt('radius')
	local botTarget = J.GetProperTarget(bot)

	if J.IsInTeamFight(bot, 1200)
	then
		local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
		and J.IsInRange(bot, nEnemyHeroes[1], nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius - 75)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeEnemy > #nInRangeAlly
		and (#nInRangeEnemy >= 2 or (J.GetHP(bot) < 0.7 and bot:WasRecentlyDamagedByAnyHero(2)))
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsFarming(bot)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)

		if nNeutralCreeps ~= nil and #nNeutralCreeps >= 3
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderActivateFireRemnant()
	if not J.CanCastAbility(ActivateFireRemnant) or bot:IsRooted()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	if DotaTime() < remnantCastTime + remnantCastGap
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local botTarget = J.GetProperTarget(bot)

	if J.IsGoingOnSomeone(bot)
	and not CanDoSleightChains()
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
		local closestRemnantToTarget = nil
		local targetDist = 100000

		for _, u in pairs(GetUnitList(UNIT_LIST_ALLIES))
		do
			if OwnedRemnant(u)
			and J.IsValidTarget(botTarget)
			then
				local dist = GetUnitToUnitDistance(u, botTarget)
				if dist < targetDist
				then
					targetDist = dist
					closestRemnantToTarget = u
				end
			end
		end

		if closestRemnantToTarget ~= nil
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.CanCastOnNonMagicImmune(botTarget)
        and targetDist <= FireRemnant:GetSpecialValueInt('radius')
		and ((#nInRangeAlly >= #nInRangeEnemy) or (#nInRangeEnemy > #nInRangeAlly and J.WeAreStronger(bot, 1200)))
		then
			return BOT_ACTION_DESIRE_HIGH, closestRemnantToTarget:GetLocation()
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
		local closestRemnantToAncient = nil
		local targetDist = 100000

		for _, u in pairs(GetUnitList(UNIT_LIST_ALLIES))
		do
			if OwnedRemnant(u)
			then
				local dist = GetUnitToUnitDistance(u, GetAncient(GetTeam()))
				if dist < targetDist
                and GetUnitToUnitDistance(bot, u) > 350
                and dist + 250 < GetUnitToUnitDistance(bot, GetAncient(GetTeam()))
                and #J.GetNearbyHeroes(u, 600, true, BOT_MODE_NONE) <= #J.GetNearbyHeroes(u, 600, false, BOT_MODE_NONE)
				then
					targetDist = dist
					closestRemnantToAncient = u
				end
			end
		end

		if closestRemnantToAncient ~= nil
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and (#nInRangeEnemy >= #nInRangeAlly)
		and (#nInRangeEnemy >= 2 or J.GetHP(bot) < 0.7)
		then
			return BOT_ACTION_DESIRE_HIGH, closestRemnantToAncient:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFireRemnant()
	if not J.CanCastAbility(FireRemnant)
	or ActivateFireRemnant == nil
    or bot:GetMana() < ActivateFireRemnant:GetManaCost()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	if DotaTime() < remnantCastTime + remnantCastGap
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = FireRemnant:GetCastRange()
	local nCastPoint = FireRemnant:GetCastPoint()
	local nDamage = FireRemnant:GetSpecialValueInt('damage')
	local nSpeed = bot:GetCurrentMovementSpeed() * (FireRemnant:GetSpecialValueInt('speed_multiplier') / 100)
	local botTarget = J.GetProperTarget(bot)

	if bot:HasScepter() then
        nCastRange = math.max(nCastRange, FireRemnant:GetSpecialValueInt('scepter_range'))
        nSpeed = nSpeed * FireRemnant:GetSpecialValueInt('scepter_speed_multiplier')
    end

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if J.CanCastOnNonMagicImmune(enemyHero)
		and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not enemyHero:HasModifier('modifier_faceless_void_chronosphere')
		and GetUnitToUnitDistance(bot, enemyHero) > bot:GetAttackRange() - 25
		then
			local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
			return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
		end
	end

	if J.IsGoingOnSomeone(bot)
    and FireRemnant:GetCurrentCharges() > 1
	and not CanDoSleightChains()
	then
		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, nCastRange + 100, false, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(botTarget, nCastRange, true, BOT_MODE_NONE)

			if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			and GetUnitToUnitDistance(bot, botTarget) > 600
			then
				local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

		if bot:WasRecentlyDamagedByAnyHero(2.5)
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and (#nInRangeEnemy >= #nInRangeAlly)
		and (#nInRangeEnemy >= 2 or J.GetHP(bot) < 0.7)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		then
			local loc = J.GetEscapeLoc()
			local dist = nCastRange * (1 - J.GetHP(bot))

			if dist < 600 then dist = 600 end

			return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, dist)
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderSleightChains()
	if CanDoSleightChains()
	then
		local nCastRange = SleightOfFist:GetCastRange()
		local botTarget = J.GetProperTarget(bot)

		if J.IsGoingOnSomeone(bot)
		then
			local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

			if J.IsValidTarget(botTarget)
			and J.CanCastOnNonMagicImmune(botTarget)
            and J.CanBeAttacked(botTarget) and not J.IsInEtherealForm(botTarget)
            and not botTarget:IsInvisible()
            and ChainsTargets(botTarget:GetLocation()) <= SearingChains:GetSpecialValueInt('unit_count')
			and J.IsInRange(bot, botTarget, nCastRange)
			and not J.IsInRange(bot, botTarget, bot:GetAttackRange() + 75)
			and not J.IsSuspiciousIllusion(botTarget)
			and not J.IsDisabled(botTarget)
			and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
			then
				if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
				and ((#nInRangeAlly >= #nInRangeEnemy) or (#nInRangeEnemy > #nInRangeAlly and J.WeAreStronger(bot, 1000)))
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
				end
			end
		end

		if J.IsRetreating(bot)
		then
			local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 250, false, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange + 100, true, BOT_MODE_NONE)

			if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeEnemy > #nInRangeAlly
			and (#nInRangeEnemy >= 2 or (J.GetHP(bot) < 0.6 or bot:WasRecentlyDamagedByAnyHero(2)))
			then
				if J.IsValidHero(nInRangeEnemy[1])
				and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
				and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
				and not J.IsInRange(bot, nInRangeEnemy[1], bot:GetAttackRange() + 75)
				and not J.IsDisabled(nInRangeEnemy[1])
				and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
				and not nInRangeEnemy[1]:IsDisarmed()
				then
					return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]:GetLocation()
				end
			end
		end
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function CanDoSleightChains()
	if J.CanCastAbility(SleightOfFist)
    and J.CanCastAbility(SearingChains)
    and not bot:IsRooted() and not bot:IsDisarmed()
    then
        local manaCost = SleightOfFist:GetManaCost() + SearingChains:GetManaCost()

        if bot:GetMana() >= manaCost
        then
            return true
        end
    end

    return false
end

return X