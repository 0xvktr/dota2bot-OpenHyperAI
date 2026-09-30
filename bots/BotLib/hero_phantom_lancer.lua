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
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: carry; forced roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/phantom_lancer')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Spirit Lance, [2] Doppelganger, [3] Phantom Rush, [6] Juxtapose.
local nAbilityBuildList = {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +3% Juxtapose illusion trigger chance
    t15={0,10}, -- 50% illusion Spirit Lance damage
    t20={0,10}, -- +100 Spirit Lance damage
    t25={0,10}, -- -4s Doppelganger cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_1 = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_power_treads','item_yasha','item_manta','item_ultimate_scepter',
    'item_skadi','item_orchid','item_aghanims_shard','item_bloodthorn',
    -- Bot policy: consume Scepter before the observed late Heart and Butterfly.
    'item_ultimate_scepter_2','item_heart','item_butterfly','item_moon_shard',
}
for role=2,5 do sRoleItemsBuyList['pos_'..role] = sRoleItemsBuyList.pos_1 end
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {'item_manta','item_magic_wand','item_skadi','item_quelling_blade'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_PL'}, {'item_power_treads','item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X.bDeafaultAbility = false
X.bDeafaultItem = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		if hMinionUnit:IsIllusion() then hMinionUnit.isIllusion = true end
		if hMinionUnit:HasModifier( 'modifier_phantom_lancer_phantom_edge_boost' ) then return end

		Minion.IllusionThink( hMinionUnit )
	end

end



local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castWDesire, castWLocation
local castRDesire


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0

local boostRange = 0


function X.SkillsComplement()


	if J.CanNotUseAbility( bot )
		or bot:IsInvisible()
		or bot:HasModifier( 'modifier_phantom_lancer_phantom_edge_boost' )
	then return end


	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	if abilityE:IsTrained() then boostRange = abilityE:GetSpecialValueInt( "max_distance" ) end
	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end


	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end


	castWDesire, castWLocation, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
	end
	
	castRDesire, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityR )
		return
	end

end

function X.ConsiderR()

	if not abilityR:IsFullyCastable()
		or not bot:HasScepter()
		or true
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if J.IsRetreating(bot)
	and J.GetHP(bot) < 0.4
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
		and J.IsInRange( bot, botTarget, 1200 )
		and not J.IsInRange( bot, botTarget, 650 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange

	if #hEnemyList <= 1 then nCastRange = nCastRange + 200 end

	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( 'lance_damage' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange + 50, true, BOT_MODE_NONE )


	local nAttackDamage = bot:GetAttackDamage()

	--击杀
	if ( not J.IsValidHero( botTarget ) or J.GetHP( botTarget ) > 0.2 )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "Q击杀"..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--对线
	if bot:GetActiveMode() == BOT_MODE_LANING
		and #hAllyList <= 2
	then
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nCastRange + 90, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and J.IsKeyWordUnit( "ranged", creep )
				and not J.IsAllysTarget( creep )
				and not J.IsInRange( bot, creep, 300 )
			then
				local nDelay = nCastPoint + GetUnitToUnitDistance( bot, creep )/1000
				if J.WillKillTarget( creep, nDamage, nDamageType, nDelay * 0.95 )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q对线'
				end
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
		and ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "Q撤退"..npcEnemy:GetUnitName()
			end
		end
	end


	--打钱
	if J.IsFarming( bot ) and nLV > 5
		and J.IsAllowedToSpam( bot, 30 )
	then
		if J.IsValid( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and ( botTarget:GetMagicResist() < 0.3 or nMP > 0.9 )
			and not J.CanKillTarget( botTarget, nAttackDamage * 1.38, DAMAGE_TYPE_PHYSICAL )
			and not J.CanKillTarget( botTarget, nDamage -10, nDamageType )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q打野'
		end
	end

	--打架
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 50 )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q进攻'..J.Chat.GetNormName( botTarget )
		end

		--团战
		if J.IsInTeamFight( bot, 900 ) and nLV > 5
		then
			for _, npcEnemy in pairs( nInRangeEnemyList )
			do
				if J.IsValidHero( npcEnemy )
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and J.CanCastOnTargetAdvanced( npcEnemy )
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'Q团战'..J.Chat.GetNormName( npcEnemy )
				end
			end
		end
	end


	--推线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and #hAllyList <= 2 and nLV >= 8
		and J.IsAllowedToSpam( bot, 30 )
	then
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nCastRange + 220, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and ( J.IsKeyWordUnit( "ranged", creep )
						or ( nMP > 0.6 and J.IsKeyWordUnit( "melee", creep ) ) )
				and not J.IsAllysTarget( creep )
				and creep:GetHealth() > nDamage * 0.88
			then

				local nDelay = nCastPoint + GetUnitToUnitDistance( bot, creep )/1000
				if J.WillKillTarget( creep, nDamage, nDamageType, nDelay * 0.98 )
					and not J.WillKillTarget( creep, nAttackDamage, DAMAGE_TYPE_PHYSICAL, nDelay )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q推线1'
				end

				local hAllyCreepList = bot:GetNearbyLaneCreeps( 1200, false )
				if #hAllyCreepList == 0
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q推线2'
				end

			end
		end
	end


	--肉山
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and nLV > 15 and nMP > 0.4
	then
		if J.IsRoshan( botTarget )
			and J.GetHP( botTarget ) > 0.2
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q肉山'
		end
	end

	--通用


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()


	if not abilityW:IsFullyCastable() or bot:DistanceFromFountain() < 600 then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + aetherRange
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	local vEscapeLoc = J.GetLocationTowardDistanceLocation( bot, J.GetTeamFountain(), nCastRange )


	--躲避
	if J.IsNotAttackProjectileIncoming( bot, 500 )
		or ( J.IsWithoutTarget( bot ) and J.GetAttackProjectileDamageByRange( bot, 1600 ) >= bot:GetHealth() )
	then
		return BOT_ACTION_DESIRE_HIGH, vEscapeLoc, 'W躲避'
	end

	--撤退
	if J.IsRetreating( bot )
		and ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
		and #hEnemyList >= 1
	then
		return BOT_ACTION_DESIRE_HIGH, vEscapeLoc, 'W撤退'
	end

	--打架
	if J.IsGoingOnSomeone( bot )
		and not bot:HasModifier( 'modifier_phantom_lancer_phantom_edge_agility' )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and not J.IsDisabled( botTarget )
			and ( X.IsEnemyCastAbility() or nHP < 0.2 )
			and ( nSkillLV >= 3 or nMP > 0.6 or nHP < 0.4 or J.GetHP( botTarget ) < 0.4 or DotaTime() > 9 * 60 )
		then

			--迷惑目标
			local vBestCastLoc = nil
			local nDistMin = 9999
			local vTargetLoc = J.GetCorrectLoc( botTarget, 1.0 )
			for i = 30, nCastRange, 30
			do
				local vFirstLoc = J.GetFaceTowardDistanceLocation( bot, i )
				local nDistance = J.GetLocationToLocationDistance( vTargetLoc, vFirstLoc )
				if nDistance > 300
					and ( nDistance < boostRange - 300 or nDistance < 500 )
					and nDistance < nDistMin
				then
					nDistMin = nDistance
					vBestCastLoc = vFirstLoc
				end
			end
			if vBestCastLoc ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, vBestCastLoc, 'W迷惑'..J.Chat.GetNormName( botTarget )
			end

			--追击目标
			local vSecondLoc = J.GetUnitTowardDistanceLocation( bot, botTarget, nCastRange )
			if nSkillLV >= 4
				and not J.IsInRange( bot, botTarget, boostRange + 400 )
				and J.IsInRange( bot, botTarget, boostRange + 1000 )
				and bot:IsFacingLocation( botTarget:GetLocation(), 30 )
				and botTarget:IsFacingLocation( J.GetEnemyFountain(), 30 )
			then
				return BOT_ACTION_DESIRE_HIGH, vSecondLoc, 'W追击'..J.Chat.GetNormName( botTarget )
			end

		end
	end

	--打钱和推线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and #hAllyList <= 2 and nLV >= 9
		and J.IsAllowedToSpam( bot, 100 )
	then
		if J.IsValid( botTarget )
			and not J.IsInRange( bot, botTarget, boostRange + 300 )
			and J.IsInRange( bot, botTarget, boostRange + 1200 )
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetUnitTowardDistanceLocation( bot, botTarget, nCastRange ), 'W打钱'
		end
	end

	--通用

	return BOT_ACTION_DESIRE_NONE


end

local sIgnoreAbilityIndex = {

	["antimage_blink"] = true,
	["arc_warden_magnetic_field"] = true,
	["arc_warden_spark_wraith"] = true,
	["arc_warden_tempest_double"] = true,
	["chaos_knight_phantasm"] = true,
	["clinkz_burning_army"] = true,
	["death_prophet_exorcism"] = true,
	["dragon_knight_elder_dragon_form"] = true,
	["juggernaut_healing_ward"] = true,
	["necrolyte_death_pulse"] = true,
	["necrolyte_sadist"] = true,
	["omniknight_guardian_angel"] = true,
	["phantom_assassin_blur"] = true,
	["pugna_nether_ward"] = true,
	["skeleton_king_mortal_strike"] = true,
	["sven_warcry"] = true,
	["sven_gods_strength"] = true,
	["templar_assassin_refraction"] = true,
	["templar_assassin_psionic_trap"] = true,
	["windrunner_windrun"] = true,
	["witch_doctor_voodoo_restoration"] = true,

}


function X.IsEnemyCastAbility()

	local enemyList = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )

	for _, npcEnemy in pairs( enemyList )
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
			and npcEnemy:IsFacingLocation( bot:GetLocation(), 25 )
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
			then
				local nAbilityBehavior = nAbility:GetBehavior()
				local sAbilityName = nAbility:GetName()
				if nAbilityBehavior ~= ABILITY_BEHAVIOR_UNIT_TARGET
					and ( npcEnemy:IsBot() or npcEnemy:GetLevel() >= 5 )
					and sIgnoreAbilityIndex[sAbilityName] ~= true 
				then
					return true
				end

				if nAbilityBehavior == ABILITY_BEHAVIOR_UNIT_TARGET
					and not npcEnemy:IsBot()
					and npcEnemy:GetLevel() >= 6
					and not J.IsAllyUnitSpell( sAbilityName )
					and ( not J.IsProjectileUnitSpell( sAbilityName ) or J.IsInRange( bot, npcEnemy, 400 ) )
				then
					return true
				end
			end
		end
	end

	return false

end

return X
-- dota2jmz@163.com QQ:2462331592..





