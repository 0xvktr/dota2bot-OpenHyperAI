local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: mid, offlane and support; skipped roles use mid without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/earth_spirit')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Boulder Smash, [2] Rolling Boulder, [3] Geomagnetic Grip, [6] Magnetize.
local nAbilityBuildList
if sRole == 'pos_3' or sRole == 'pos_4' then
    nAbilityBuildList = {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6}
else
    nAbilityBuildList = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
end
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +150 Rolling Boulder distance
    t15={10,0}, -- +80 Boulder Smash damage
    t20={0,10}, -- +35 Magnetize damage per second
    t25={0,10}, -- Magnetize self
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_4' then
    -- One charge of each ward produces the observed combined dispenser.
    X.sBuyList = {'item_boots', 'item_ward_observer', 'item_ward_sentry', 'item_blood_grenade',
        'item_urn_of_shadows', 'item_magic_wand',
        -- Bot policy: Tranquils before larger utilities.
        'item_tranquil_boots', 'item_essence_distiller',
        'item_aether_lens', 'item_blink', 'item_aghanims_shard', 'item_cyclone',
        -- Bot policy: Scepter/Blessing and Overwhelming Blink.
        'item_ultimate_scepter', 'item_ultimate_scepter_2', 'item_overwhelming_blink'}
    -- Distiller consumes Urn; Vessel is an alternative path.
    X.sSellList = {'item_ultimate_scepter', 'item_magic_wand'}
else
    if sRole == 'pos_3' then
        X.sBuyList = {'item_double_branches', 'item_branches', 'item_circlet', 'item_magic_stick', 'item_faerie_fire',
            'item_bracer', 'item_urn_of_shadows', 'item_magic_wand', 'item_power_treads'}
        X.sSellList = {'item_black_king_bar', 'item_magic_wand', 'item_shivas_guard', 'item_bracer'}
    else
        X.sBuyList = {'item_double_branches', 'item_double_branches', 'item_tango', 'item_faerie_fire',
            'item_bottle', 'item_magic_wand', 'item_urn_of_shadows', 'item_power_treads'}
        X.sSellList = {'item_black_king_bar', 'item_magic_wand', 'item_shivas_guard', 'item_bottle'}
    end
    for _, item in ipairs({'item_spirit_vessel', 'item_kaya', 'item_black_king_bar',
        'item_kaya_and_sange', 'item_shivas_guard',
        -- Bot policy: late Bloodstone and Shard.
        'item_bloodstone', 'item_aghanims_shard'}) do table.insert(X.sBuyList, item) end
    -- Optional Veil is omitted: the current Shiva recipe does not consume it.
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT spends level 10 on Grip; first talent comes at 11. Preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

local BoulderSmash = bot:GetAbilityByName( "earth_spirit_boulder_smash" )
local RollingBoulder = bot:GetAbilityByName( "earth_spirit_rolling_boulder" )
local GeomagneticGrip = bot:GetAbilityByName( "earth_spirit_geomagnetic_grip" )
local StoneRemnant = bot:GetAbilityByName( "earth_spirit_stone_caller" )
local Magnetize = bot:GetAbilityByName( "earth_spirit_magnetize" )
local GripAllies = bot:GetAbilityByName( "special_bonus_unique_earth_spirit_2" )
local EchantRemnant = bot:GetAbilityByName( "earth_spirit_petrify" )

local BoulderSmashDesire, BoulderSmashLocation, CanRemnantSmashCombo, CanKickNearbyStone
local RollingBoulderDesire, RollingBoulderLocation, CanRemnantRollCombo
local GeomagneticGripDesire, GeomagneticGripLocation, CanRemnantGrip
local StoneRemnantDesire
local EchantRemnantDesire
local MagnetizeDesire
local GripAlliesDesire

local nStone = 0

function X.SkillsComplement()

    if bot:IsUsingAbility()
	or bot:IsChanneling()
	or bot:IsSilenced()
	or bot:NumQueuedActions() > 0
	then
		return
	end

    if StoneRemnant:IsFullyCastable()
    then
        nStone = 1
    else
        nStone = 0
    end

	EchantRemnantDesire, EnchantTarget = X.ConsiderEchantRemnant()
    if EchantRemnantDesire > 0
    then
        bot:ActionQueue_UseAbilityOnEntity(EchantRemnant, EnchantTarget)
		bot:ActionQueue_UseAbilityOnLocation(BoulderSmash, bot:GetLocation() + RandomVector(800))
		return
    end

	RollingBoulderDesire, RollingBoulderLocation, CanRemnantRollCombo = X.ConsiderRollingBoulder()
    if RollingBoulderDesire > 0
	then
		if CanRemnantRollCombo
		then
			bot:Action_ClearActions(false)
			bot:ActionQueue_UseAbilityOnLocation(StoneRemnant, bot:GetLocation())
			bot:ActionQueue_UseAbilityOnLocation(RollingBoulder, RollingBoulderLocation)
			return
		else
			bot:Action_UseAbilityOnLocation(RollingBoulder, RollingBoulderLocation)
			return
		end
	end

	MagnetizeDesire = X.ConsiderMagnetize()
    if MagnetizeDesire > 0
    then
        bot:Action_UseAbility(Magnetize)
		return
    end

	BoulderSmashDesire, BoulderSmashLocation, CanRemnantSmashCombo, CanKickNearbyStone = X.ConsiderBoulderSmash()
    if BoulderSmashDesire > 0
	then
		if CanRemnantSmashCombo
		then
			bot:Action_ClearActions(false)
			bot:ActionQueue_UseAbilityOnLocation(StoneRemnant, bot:GetLocation())
			bot:ActionQueue_UseAbilityOnLocation(BoulderSmash, BoulderSmashLocation)
			return
		else
			if CanKickNearbyStone
			then
				bot:Action_UseAbilityOnLocation(BoulderSmash, BoulderSmashLocation)
				return
			end
		end
	end

	GeomagneticGripDesire, GeomagneticGripLocation, CanRemnantGrip = X.ConsiderGeomagneticGrip()
    if GeomagneticGripDesire > 0
	then
		if CanRemnantGrip
		then
			bot:Action_ClearActions(false)
			bot:ActionQueue_UseAbilityOnLocation(StoneRemnant, GeomagneticGripLocation)
			bot:ActionQueue_UseAbilityOnLocation(GeomagneticGrip, GeomagneticGripLocation)
			return
		else
			if J.HasAghanimsShard(bot)
			then
				bot:Action_UseAbilityOnEntity(GeomagneticGrip, GeomagneticGripLocation)
			else
				bot:Action_UseAbilityOnLocation(GeomagneticGrip, GeomagneticGripLocation)
			end

			return
		end
	end
end

function X.ConsiderBoulderSmash()
    if not BoulderSmash:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0, false, false
	end

	local nCastRange = BoulderSmash:GetCastRange()
	local nAttackRange = bot:GetAttackRange()
	local nSpeed = BoulderSmash:GetSpecialValueInt('speed')
	local nDamage = BoulderSmash:GetSpecialValueInt('rock_damage')
	local stoneNearby = IsStoneNearby(bot:GetLocation(), nAttackRange)
	local nMana = bot:GetMana() / bot:GetMaxMana()

	local nInRangeEnemy = J.GetNearbyHeroes(bot,nAttackRange, true, BOT_MODE_NONE)
	local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
	for _, enemyHero in pairs(nInRangeEnemy)
	do
		if J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nAttackRange)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			if nInRangeAlly ~= nil and #nInRangeAlly >= 1
			then
				return BOT_ACTION_DESIRE_HIGH, nInRangeAlly[#nInRangeAlly]:GetLocation(), false, true
			else
				return BOT_ACTION_DESIRE_HIGH, GetAncient(GetTeam()):GetLocation(), false, true
			end
		end
	end

	if stoneNearby
	then
		local nEnemyHeroes = J.GetNearbyHeroes(bot,math.min(nCastRange, 1600), true, BOT_MODE_NONE)
		local target = J.GetCanBeKilledUnit(nEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)

		if target ~= nil
		and not J.IsSuspiciousIllusion(target)
		then
			local loc = J.GetCorrectLoc(target, GetUnitToUnitDistance(bot, target) / nSpeed)
			return BOT_ACTION_DESIRE_HIGH, loc, false, true
		end
	elseif nStone >= 1
	then
		local nEnemyHeroes = J.GetNearbyHeroes(bot,math.min(nCastRange, 1600), true, BOT_MODE_NONE)
		local target = J.GetCanBeKilledUnit(nEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)

		if target ~= nil
		and not J.IsSuspiciousIllusion(target)
		then
			local loc = J.GetCorrectLoc(target, GetUnitToUnitDistance(bot, target) / nSpeed)
			return BOT_ACTION_DESIRE_HIGH, loc, true, false
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, math.min(nCastRange, 1600))
		and not J.IsSuspiciousIllusion(botTarget)
		then
			local loc = J.GetCorrectLoc(botTarget, GetUnitToUnitDistance(bot, botTarget) / nSpeed)

			if stoneNearby
			then
				return BOT_ACTION_DESIRE_HIGH, loc, false, true
			elseif nStone >= 1
			then
				return BOT_ACTION_DESIRE_HIGH, loc, true, false
			end
		end
	end

	if J.IsRetreating(bot)
	and bot:WasRecentlyDamagedByAnyHero(2)
	then
		local nAllyHeroes = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
		local nEnemyHeroes = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

		local target = J.GetClosestUnit(nEnemyHeroes)
		if target ~= nil and stoneNearby
		then
			if nAllyHeroes ~= nil and nEnemyHeroes ~= nil
			and #nAllyHeroes <= 1 and #nEnemyHeroes <= 1
			then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), false, true
			end
		elseif target ~= nil and nStone >= 1
		then
			if nAllyHeroes ~= nil and nEnemyHeroes ~= nil
			and #nAllyHeroes <= 1 and #nEnemyHeroes <= 1
			and bot:IsFacingLocation(J.GetEscapeLoc(), 30)
			then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), true, false
			end
		end
	end

	if J.IsLaning(bot)
	then
		if nStone >= 1
		and nMana > 0.33
		then
			local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(StoneRemnant:GetCastRange(), true)

			for _, creep in pairs(nEnemyLaneCreeps)
			do
				if J.IsValid(creep)
				and J.IsKeyWordUnit('ranged', creep)
				and creep:GetHealth() <= nDamage
				then
					local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

					if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
					and GetUnitToUnitDistance(creep, nEnemyHeroes[1]) <= 600
					then
						return BOT_ACTION_DESIRE_HIGH, creep:GetLocation(), true, false
					end
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0, false, false
end

function X.ConsiderRollingBoulder()
    if not RollingBoulder:IsFullyCastable() or bot:IsRooted()
	then
		return BOT_ACTION_DESIRE_NONE, 0, false
	end

	local nDistance = RollingBoulder:GetSpecialValueInt('distance')
	local nDelay = RollingBoulder:GetSpecialValueFloat('delay')
	local nSpeed = RollingBoulder:GetSpecialValueInt('rock_speed')
	local nDamage = RollingBoulder:GetSpecialValueInt('damage')
	local nMana = bot:GetMana() bot:GetMaxMana()
	local nDistance2 = math.min(nDistance * 2, 1600)

	local nNearbyEnemySearchRange = nDistance
	if nStone >= 1
	then
		nNearbyEnemySearchRange = nNearbyEnemySearchRange * 2
	end

	local nEnemyHeroes = J.GetNearbyHeroes(bot,math.min(nNearbyEnemySearchRange, 1600), true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if enemyHero:CanBeSeen() and enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not bot:HasModifier('modifier_earth_spirit_rolling_boulder_caster')
		then
			local loc = J.GetCorrectLoc(enemyHero, (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nDelay)

			if IsStoneInPath(loc, GetUnitToUnitDistance(bot, enemyHero))
			or nStone == 0
			then
				return BOT_ACTION_DESIRE_HIGH, loc, false
			elseif nStone >= 1
			then
				return BOT_ACTION_DESIRE_HIGH, loc, true
			end
		end
	end

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nDistance), false
	end

	if nStone >= 1
	then
		local target = J.GetCanBeKilledUnit(nEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)

		if target ~= nil
		and not J.IsSuspiciousIllusion(target)
		then
			local loc = J.GetCorrectLoc(target, (GetUnitToUnitDistance(bot, target) / nSpeed) + nDelay)

			if IsStoneInPath(loc, GetUnitToUnitDistance(bot, target))
			then
				return BOT_ACTION_DESIRE_HIGH, loc, false
			else
				return BOT_ACTION_DESIRE_HIGH, loc, true
			end
		end
	elseif nStone == 0
	then
		local target = J.GetCanBeKilledUnit(nEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)

		if target ~= nil
		and not J.IsSuspiciousIllusion(target)
		then
			local loc = J.GetCorrectLoc(target, (GetUnitToUnitDistance(bot, target) / nSpeed) + nDelay)
			return BOT_ACTION_DESIRE_HIGH, loc, false
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if nStone >= 1
		and J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nDistance2)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
		then
			local nAllyHeroes = J.GetNearbyHeroes(bot, nDistance2, false, BOT_MODE_NONE)

			if nEnemyHeroes ~= nil and nAllyHeroes ~= nil
			and ((#nAllyHeroes >= #nEnemyHeroes) or (#nEnemyHeroes > #nAllyHeroes and J.WeAreStronger(bot, nDistance)))
			then
				local loc = J.GetCorrectLoc(botTarget, GetUnitToUnitDistance(bot, botTarget) / nSpeed)

				if IsStoneInPath(loc, GetUnitToUnitDistance(bot, botTarget))
				then
					return BOT_ACTION_DESIRE_HIGH, loc, false
				else
					return BOT_ACTION_DESIRE_HIGH, loc, true
				end
			end
		elseif nStone == 0
		and J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nDistance)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
		then
			local loc = J.GetCorrectLoc(botTarget, nDelay)
			return BOT_ACTION_DESIRE_HIGH, loc, false
		end
	end

	local nInRangeAlly  = J.GetNearbyHeroes(bot, nDistance2, false, BOT_MODE_NONE)
	if J.IsRetreating(bot)
	or J.IsRetreating(bot) and (nInRangeAlly ~= nil and nEnemyHeroes ~= nil and #nEnemyHeroes > #nInRangeAlly)
	then
		local nAllyHeroes  = J.GetNearbyHeroes(bot, nDistance2, false, BOT_MODE_NONE)
		local location = J.GetEscapeLoc()
		local loc = J.Site.GetXUnitsTowardsLocation(bot, location, nDistance)

		if nAllyHeroes ~= nil and nEnemyHeroes ~= nil
		and ((#nEnemyHeroes > #nAllyHeroes) or (#nAllyHeroes >= #nEnemyHeroes and J.GetHP(bot) < 0.45))
		then
			if nStone >= 1
			then
				if J.IsInRange(bot, nEnemyHeroes[1], 600)
				then
					return BOT_ACTION_DESIRE_HIGH, loc, true
				else
					return BOT_ACTION_DESIRE_HIGH, loc, false
				end
			elseif nStone == 0
			then
				return BOT_ACTION_DESIRE_HIGH, loc, false
			end
		end
	end

	if nMana > 0.88
	and bot:DistanceFromFountain() > 100
	and bot:DistanceFromFountain() < 6000
	and DotaTime() > 0
	and not J.IsDoingTormentor(bot)
	then
		local nLaneFrontLocationT = GetLaneFrontLocation(GetTeam(), LANE_TOP, 0)
		local nLaneFrontLocationM = GetLaneFrontLocation(GetTeam(), LANE_MID, 0)
		local nLaneFrontLocationB = GetLaneFrontLocation(GetTeam(), LANE_BOT, 0)
		local nDistFromLane = GetUnitToLocationDistance(bot, bot:GetLocation())
		local facingFrontLoc = Vector(0, 0, 0)

		if bot:IsFacingLocation(nLaneFrontLocationT, 45)
		then
			nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocationT)
			facingFrontLoc = nLaneFrontLocationT
		elseif bot:IsFacingLocation(nLaneFrontLocationM, 45)
		then
			nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocationM)
			facingFrontLoc = nLaneFrontLocationM
		elseif bot:IsFacingLocation(nLaneFrontLocationB, 45)
		then
			nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocationB)
			facingFrontLoc = nLaneFrontLocationB
		end

		if nDistFromLane > 1600
		then
			local location = J.Site.GetXUnitsTowardsLocation(bot, facingFrontLoc, nDistance)

			if IsLocationPassable(location)
			then
				return BOT_ACTION_DESIRE_HIGH, location, false
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0, false
end

function X.ConsiderGeomagneticGrip()
    if not GeomagneticGrip:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0, false
	end

	local nCastRange = GeomagneticGrip:GetCastRange()
	local nCastPoint = GeomagneticGrip:GetCastPoint()
	local nMana = bot:GetMana() / bot:GetMaxMana()
	local nDamage = GeomagneticGrip:GetSpecialValueInt('rock_damage')

	if J.HasAghanimsShard(bot)
	then
		local tableNearbyAllies = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
		local tableNearbyEnemies = J.GetNearbyHeroes(bot,300, false, BOT_MODE_NONE)

		for _, ally in pairs(tableNearbyAllies)
		do
			if J.GetHP(ally) < 0.4
			and J.IsInRange(bot, ally, nCastRange)
			and not J.IsInRange(bot, ally, nCastRange - 250)
			and #tableNearbyEnemies == 0
			then
				return BOT_ACTION_DESIRE_HIGH, ally, false
			end

			if J.IsRetreating(ally)
			and ally:WasRecentlyDamagedByAnyHero(2.0)
			and J.IsInRange(bot, ally, nCastRange)
			and not J.IsInRange(bot, ally, nCastRange - 250)
			and #tableNearbyEnemies == 0
			then
				return BOT_ACTION_DESIRE_HIGH, ally, false
			end
		end
	end

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	local target = J.GetCanBeKilledUnit(nEnemyHeroes, nDamage, DAMAGE_TYPE_MAGICAL, false)
	if target ~= nil
	and J.CanCastOnNonMagicImmune(target)
	and J.IsInRange(bot, target, nCastRange)
	and not J.IsSuspiciousIllusion(target)
	then
		local loc = J.GetCorrectLoc(target, nCastPoint)
		local isThereStoneNearTarget = IsStoneNearTarget(target)

		if isThereStoneNearTarget
		then
			return BOT_ACTION_DESIRE_HIGH, loc, false
		elseif nStone >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, loc, true
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_MAGICAL)
		and not J.IsSuspiciousIllusion(botTarget)
		then
			local nTargetAlly  = J.GetNearbyHeroes(botTarget, nCastRange, false, BOT_MODE_NONE)
			local nTargetEnemy = J.GetNearbyHeroes(botTarget, nCastRange, true, BOT_MODE_NONE)

			if nTargetAlly ~= nil and nTargetEnemy ~= nil
			and #nTargetAlly >= #nTargetEnemy
			then
				local loc = J.GetCorrectLoc(botTarget, nCastPoint)
				local isThereStoneNearTarget = IsStoneNearTarget(target)

				if isThereStoneNearTarget
				then
					return BOT_ACTION_DESIRE_HIGH, loc, false
				elseif nStone >= 1
				then
					return BOT_ACTION_DESIRE_HIGH, loc, true
				end
			end
		end
	end

	if J.IsLaning(bot)
	then
		if nStone >= 1
		and nMana > 0.33
		then
			local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(StoneRemnant:GetCastRange(), true)

			for _, creep in pairs(nEnemyLaneCreeps)
			do
				if J.IsValid(creep)
				and J.IsKeyWordUnit('ranged', creep)
				and creep:GetHealth() <= nDamage
				then
					local nEnemyHeroesL = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

					if nEnemyHeroesL ~= nil and #nEnemyHeroesL >= 1
					and GetUnitToUnitDistance(creep, nEnemyHeroesL[1]) <= 600
					then
						return BOT_ACTION_DESIRE_HIGH, creep:GetLocation(), true, false
					end
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0, false, false
end

function X.ConsiderEchantRemnant()
	if not EchantRemnant:IsTrained()
	or not EchantRemnant:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderMagnetize()
	if not Magnetize:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius    = Magnetize:GetSpecialValueInt('cast_radius')
	local botTarget = J.GetProperTarget(bot)

	if J.IsInTeamFight(bot, 1200)
	then
		local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nAllyHeroes = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
		local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and not J.IsSuspiciousIllusion(botTarget)
		and nAllyHeroes ~= nil and nEnemyHeroes ~= nil
		and #nAllyHeroes <= 1 and #nEnemyHeroes <= 1
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsRetreating(bot)
	then
		local nAllyHeroes = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
		local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if nEnemyHeroes ~= nil and nAllyHeroes ~= nil
		and #nEnemyHeroes >= 2
		and bot:WasRecentlyDamagedByAnyHero(2)
		and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
		and J.IsInRange(bot, nEnemyHeroes[1], nRadius)
		and not J.IsSuspiciousIllusion(nEnemyHeroes[1])
		and #nEnemyHeroes > #nAllyHeroes
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

-- HELPER FUNCS --
function IsStoneNearby(location, radius)
	local units = GetUnitList(UNIT_LIST_ALLIED_OTHER)

	for _, u in pairs(units)
	do
		if u ~= nil and u:GetUnitName() == "npc_dota_earth_spirit_stone"
		and GetUnitToLocationDistance(u, location) < radius
		then
			return true
		end
	end

	return false
end

function IsStoneInPath(location, dist)
	if bot:IsFacingLocation(location, 5)
	then
		local units = GetUnitList(UNIT_LIST_ALLIED_OTHER)

		for _, u in pairs(units)
		do
			if u ~= nil
			and u:GetUnitName() == "npc_dota_earth_spirit_stone"
			and bot:IsFacingLocation(u:GetLocation(), 5)
			and GetUnitToUnitDistance(u, bot) < dist
			then
				return true
			end
		end
	end

	return false
end

function IsStoneNearTarget(target)
	local units = GetUnitList(UNIT_LIST_ALLIED_OTHER)

	for _, u in pairs(units)
	do
		if u ~= nil
		and u:GetUnitName() == "npc_dota_earth_spirit_stone"
		and GetUnitToLocationDistance(u, target:GetLocation()) < 100
		then
			return true
		end
	end

	return false
end

return X
