local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local VoidAbilities = require(GetScriptDirectory()..'/FunLib/faceless_void_abilities')
local walkState = {}
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: carry; forced other roles use this build.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/faceless_void')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Time Walk, [2] Time Dilation, [3] Time Lock, [6] Chronosphere.
local nAbilityBuildList = {1,2,3,1,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +0.5s Time Walk backtrack duration
    t15={10,0}, -- +125 Time Walk range
    t20={10,0}, -- -1s Time Walk cooldown
    t25={0,10}, -- +20% Backtrack chance
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade', 'item_double_branches', 'item_magic_stick', 'item_tango', 'item_faerie_fire',
    'item_magic_wand', 'item_power_treads', 'item_bfury', 'item_yasha', 'item_manta',
    'item_ultimate_scepter', 'item_aghanims_shard', 'item_black_king_bar',
    -- Bot policy: consume Scepter; add damage, replace farming with sustain, then double Chronosphere.
    'item_ultimate_scepter_2', 'item_monkey_king_bar', 'item_satanic', 'item_refresher', 'item_moon_shard',
}
X.sSellList = {'item_black_king_bar','item_magic_wand','item_satanic','item_bfury'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Time Lock at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local TimeWalk 			= bot:GetAbilityByName('faceless_void_time_walk')
local TimeDilation 		= bot:GetAbilityByName('faceless_void_time_dilation')
local Chronosphere 		= bot:GetAbilityByName('faceless_void_chronosphere')
local TimeWalkReverse 	= bot:GetAbilityByName('faceless_void_time_walk_reverse')

local TimeWalkDesire, TimeWalkLocation
local TimeDilationDesire
local ChronosphereDesire, ChronosphereLocation
local TimeWalkReverseDesire



local botTarget

function X.SkillsComplement()
    VoidAbilities.Observe(bot, TimeWalk, walkState)
    if J.CanNotUseAbility(bot) then return end

	botTarget = J.GetProperTarget(bot)

	TimeWalkReverseDesire = X.ConsiderTimeWalkReverse()
	if TimeWalkReverseDesire > 0
	then
		bot:Action_UseAbility(TimeWalkReverse)
		return
	end

    TimeWalkDesire, TimeWalkLocation = X.ConsiderTimeWalk()
    if TimeWalkDesire > 0 and walkState.emergency then
        VoidAbilities.RecordWalk(bot, TimeWalk, TimeWalkLocation, walkState)
        bot:Action_UseAbilityOnLocation(TimeWalk, TimeWalkLocation); return
    end
    ChronosphereDesire, ChronosphereLocation = X.ConsiderChronosphere()
    if ChronosphereDesire > 0 then
        bot:Action_UseAbilityOnLocation(Chronosphere, ChronosphereLocation); return
    end
    if TimeWalkDesire > 0 and IsAllowedToCast(TimeWalk:GetManaCost()) then
        J.SetQueuePtToINT(bot, false)
        VoidAbilities.RecordWalk(bot, TimeWalk, TimeWalkLocation, walkState)
        bot:Action_UseAbilityOnLocation(TimeWalk, TimeWalkLocation); return
    end
    TimeDilationDesire = X.ConsiderTimeDilation()
    if TimeDilationDesire > 0 and IsAllowedToCast(TimeDilation:GetManaCost()) then
        bot:Action_UseAbility(TimeDilation)
    end
end

function X.CanUseRefresherShard()
	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = '刷新技能'
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	if #nInRangeEnmyList > 0
		and ( J.IsGoingOnSomeone( bot ) or J.IsInTeamFight( bot ) )
		and J.CanUseRefresherShard( bot )
		and not bot:HasModifier("modifier_faceless_void_chronosphere_speed")
	then
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return false
end

function X.ConsiderTimeWalk()
    if not J.CanCastAbility(TimeWalk) or bot:IsRooted()
        or bot:HasModifier('modifier_faceless_void_chronosphere_speed') then return 0,nil end
    local desire, point, emergency = VoidAbilities.Walk(bot, TimeWalk, walkState)
    walkState.emergency = emergency
    if desire > 0 then return desire, point end
    local nCastRange = TimeWalk:GetSpecialValueInt('range')
    local nEnemyHeroes = J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)

	if J.IsPushing(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
		and GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nEnemyLaneCreeps)) > 500
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
		end
	end

	if J.IsFarming(bot)
	then
		if J.IsValid(botTarget)
		and GetUnitToUnitDistance(bot, botTarget) > 500
		then
			local point = VoidAbilities.Bound(bot, botTarget:GetLocation(), nCastRange)
            if IsLocationPassable(point) then return BOT_ACTION_DESIRE_HIGH, point end
		end
	end

	if J.IsLaning(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		-- for _, creep in pairs(nEnemyLaneCreeps)
		-- do
		-- 	if J.IsValid(creep)
		-- 	and J.CanBeAttacked(creep)
		-- 	and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
		-- 	and GetUnitToUnitDistance(creep, bot) > 500
		-- 	then
		-- 		local nCreepInRangeHero = creep:GetNearbyHeroes(creep:GetCurrentVisionRange(), false, BOT_MODE_NONE)
		-- 		local nCreepInRangeTower = creep:GetNearbyTowers(700, false)
		-- 		local nTime = (GetUnitToUnitDistance(bot, creep) / nSpeed) + nCastPoint
		-- 		local nDamage = bot:GetAttackDamage()

		-- 		if J.WillKillTarget(creep, nDamage, DAMAGE_TYPE_PHYSICAL, nTime)
		-- 		and nCreepInRangeHero ~= nil and #nCreepInRangeHero == 0
		-- 		and nCreepInRangeTower ~= nil and #nCreepInRangeTower == 0
		-- 		then
		-- 			bot:SetTarget(creep)
		-- 			return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
		-- 		end
		-- 	end
		-- end

		if ((bot:GetMana() - TimeWalk:GetManaCost()) / bot:GetMaxMana()) > 0.85
		and bot:DistanceFromFountain() > 100
		and bot:DistanceFromFountain() < 6000
		and J.IsInLaningPhase()
		and #nEnemyHeroes == 0
		then
			local nLane = bot:GetAssignedLane()
			local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(), nLane, 0)
			local nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocation)

			if nDistFromLane > nCastRange
			then
				local nLocation = J.Site.GetXUnitsTowardsLocation(bot, nLaneFrontLocation, nCastRange)
				if IsLocationPassable(nLocation)
				then
					return BOT_ACTION_DESIRE_HIGH, nLocation
				end
			end
		end
	end

	if J.IsDoingRoshan(bot)
    then
		local roshLoc = J.GetCurrentRoshanLocation()
        if GetUnitToLocationDistance(bot, roshLoc) > nCastRange
        then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, roshLoc, nCastRange)
			local nInRangeEnemy = J.GetEnemiesNearLoc(roshLoc, 1600)

			if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and IsLocationPassable(targetLoc)
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end
        end
    end

    if J.IsDoingTormentor(bot)
    then
		local tormentorLoc = J.GetTormentorLocation(GetTeam())
        if GetUnitToLocationDistance(bot, tormentorLoc) > nCastRange
        then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, tormentorLoc, nCastRange)
			local nInRangeEnemy = J.GetEnemiesNearLoc(targetLoc, 1600)

			if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and IsLocationPassable(targetLoc)
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end

        end
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderTimeDilation() return VoidAbilities.Dilation(bot, TimeDilation) end
function X.ConsiderChronosphere() return VoidAbilities.Chrono(bot, Chronosphere) end
function X.ConsiderTimeWalkReverse() return VoidAbilities.Reverse(bot, TimeWalkReverse, walkState) end

--Helper Funcs
function IsAllowedToCast(manaCost)
	if Chronosphere ~= nil
	and not Chronosphere:IsNull()
	and Chronosphere:IsTrained()
	and Chronosphere:IsFullyCastable()
	then
		local ultCost = Chronosphere:GetManaCost()
		if bot:GetMana() - manaCost >= ultCost
		then
			return true
		else
			return false
		end
	end

	return true
end

return X