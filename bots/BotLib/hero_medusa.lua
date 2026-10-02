----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/medusa')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use pos 1.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/medusa')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Split Shot, [2] Mystic Snake, [3] Gorgon's Grasp, [6] Stone Gaze.
local nAbilityBuildList = {2,3,2,1,2,1,2,1,1,6,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Stone Gaze physical damage
    t15={10,0}, -- Mystic Snake cooldown
    t20={10,0}, -- Split Shot outgoing damage
    t25={10,0}, -- Intelligence
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_double_branches','item_magic_wand','item_null_talisman','item_power_treads',
    'item_yasha','item_manta','item_butterfly','item_skadi',
    'item_lesser_crit','item_aghanims_shard','item_greater_crit',
    -- Bot policy: late upgrades and continuation.
    'item_blink','item_swift_blink','item_ultimate_scepter','item_ultimate_scepter_2','item_moon_shard',
}
X.sSellList = {'item_skadi','item_magic_wand','item_lesser_crit','item_null_talisman'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT takes an ability at 10, then the first talent at 11.
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

--[[

npc_dota_hero_medusa

"Ability1"		"medusa_split_shot"
"Ability2"		"medusa_mystic_snake"
"Ability3"		"medusa_mana_shield"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"medusa_stone_gaze"
"Ability10"		"special_bonus_attack_damage_15"
"Ability11"		"special_bonus_evasion_15"
"Ability12"		"special_bonus_attack_speed_30"
"Ability13"		"special_bonus_unique_medusa_3"
"Ability14"		"special_bonus_unique_medusa_5"
"Ability15"		"special_bonus_unique_medusa"
"Ability16"		"special_bonus_mp_1000"
"Ability17"		"special_bonus_unique_medusa_4"

modifier_medusa_split_shot
modifier_medusa_mana_shield
modifier_medusa_stone_gaze_tracker
modifier_medusa_stone_gaze
modifier_medusa_stone_gaze_slow
modifier_medusa_stone_gaze_facing
modifier_medusa_stone_gaze_stone


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilityM = nil
local GorgonGrasp = bot:GetAbilityByName('medusa_gorgon_grasp')

local castQDesire
local castWDesire, castWTarget
local castEDesire
local castRDesire
local GorgonGraspDesire, GorgonGraspLocation

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList
local lastToggleTime = 0


X.UseSplitShot = SpellDecisions.UseSplitShot

function X.SkillsComplement()

    if X.UseSplitShot() then return end
	J.ConsiderForMkbDisassembleMask( bot )
	J.ConsiderTarget()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )


    if SpellDecisions.GazeUseful(abilityR) then
        J.SetQueuePtToINT(bot, true, abilityR)
        bot:ActionQueue_UseAbility(abilityR)
        return
    end
	castWDesire, castWTarget = X.ConsiderW()
	if castWDesire > 0
	then

		J.SetQueuePtToINT( bot, true, abilityW )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end


	castRDesire = X.ConsiderR()
	if castRDesire > 0
	then

		J.SetQueuePtToINT( bot, true, abilityR )

		bot:ActionQueue_UseAbility( abilityR )
		return

	end

	GorgonGraspDesire, GorgonGraspLocation = X.ConsiderGorgonGrasp()
	if GorgonGraspDesire > 0
	then
		J.SetQueuePtToINT(bot, false, GorgonGrasp)
		bot:ActionQueue_UseAbilityOnLocation(GorgonGrasp, GorgonGraspLocation)
		return
	end


end

function X.ConsiderGorgonGrasp()
    local target = SpellDecisions.GraspPoint(GorgonGrasp)
    return target ~= nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE, target
end


function X.ConsiderW()
    local target = SpellDecisions.SnakeTarget(abilityW)
    return target ~= nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE, target
end


function X.ConsiderR()
    return SpellDecisions.GazeUseful(abilityR) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end

function X.GetHurtCount( nUnit, nCount )

	local nHeroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	local nCreeps = bot:GetNearbyCreeps( 1600, true, BOT_MODE_NONE )
	local nTable = {}
	table.insert( nTable, nUnit )
	local nHurtCount = 1

	for i=1, nCount
	do
		local nNeastUnit = X.GetNearestUnit( nUnit, nHeroes, nCreeps, nTable )

		if nNeastUnit ~= nil
			and GetUnitToUnitDistance( nUnit, nNeastUnit ) <= 475
		then
			nHurtCount = nHurtCount + 1
			table.insert( nTable, nNeastUnit )
		else
			break
		end
	end


	return nHurtCount

end

function X.GetNearestUnit( nUnit, nHeroes, nCreeps, nTable )

	local NearestUnit = nil
	local NearestDist = 9999
	for _, unit in pairs( nHeroes )
	do
		if unit ~= nil
			and unit:IsAlive()
			and not X.IsExistInTable( unit, nTable )
			and GetUnitToUnitDistance( nUnit, unit ) < NearestDist
		then
			NearestUnit = unit
			NearestDist = GetUnitToUnitDistance( nUnit, unit )
		end
	end

	for _, unit in pairs( nCreeps )
	do
		if unit ~= nil
			and unit:IsAlive()
			and not X.IsExistInTable( unit, nTable )
			and GetUnitToUnitDistance( nUnit, unit ) < NearestDist
		then
			NearestUnit = unit
			NearestDist = GetUnitToUnitDistance( nUnit, unit )
		end
	end

	return NearestUnit

end

function X.IsExistInTable( u, tUnit )
	for _, t in pairs( tUnit )
	do
		if t == u
		then
			return true
		end
	end
	return false
end

return X
-- dota2jmz@163.com QQ:2462331592..
