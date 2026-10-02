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

-- Updated to 7.41f from D2PT: carry, mid and offlane; forced supports use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/razor')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Plasma Field, [2] Static Link, [3] Storm Surge, [6] Eye of the Storm.
local nAbilityBuildList = (sRole=='pos_1' or sRole=='pos_2')
    and {2,1,2,1,1,6,1,3,3,3,6,3,2,2,6}
    or {1,2,1,2,1,6,1,3,3,3,6,3,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +4 armor
    t15={10,0}, -- +12 strength
    t20={10,0}, -- -0.1s Eye of the Storm strike interval
    t25={10,0}, -- Static Link steals attack speed
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_1 = {
    'item_branches','item_magic_wand','item_faerie_fire',
    'item_power_treads','item_falcon_blade','item_maelstrom','item_yasha','item_mjollnir',
    'item_manta','item_black_king_bar','item_satanic',
    -- Bot policy: consumed upgrades before the late Butterfly.
    'item_aghanims_shard','item_ultimate_scepter','item_ultimate_scepter_2','item_butterfly','item_moon_shard',
}
sRoleItemsBuyList.pos_2 = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_power_treads','item_yasha','item_manta',
    'item_black_king_bar','item_aghanims_shard','item_satanic',
    -- Bot policy: consume Scepter before late damage and protection.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_butterfly','item_sphere','item_moon_shard',
}
sRoleItemsBuyList.pos_3 = {
    'item_slippers','item_double_branches','item_circlet','item_tango','item_faerie_fire',
    'item_wraith_band','item_magic_wand','item_power_treads','item_falcon_blade',
    'item_yasha','item_manta','item_black_king_bar','item_sphere','item_satanic',
    -- Bot policy: consumed upgrades before the late Butterfly.
    'item_aghanims_shard','item_ultimate_scepter','item_ultimate_scepter_2','item_butterfly','item_moon_shard',
}
sRoleItemsBuyList.pos_4 = sRoleItemsBuyList.pos_3
sRoleItemsBuyList.pos_5 = sRoleItemsBuyList.pos_3
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {
    'item_black_king_bar','item_magic_wand','item_satanic','item_falcon_blade',
    'item_sphere','item_wraith_band','item_satanic','item_bottle',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_mid'}, {} end

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
		Minion.IllusionThink( hMinionUnit )
	end

end



local R=require(GetScriptDirectory()..'/FunLib/razor_abilities')
local abilityQ=bot:GetAbilityByName('razor_plasma_field')
local abilityW=bot:GetAbilityByName('razor_static_link')
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR=bot:GetAbilityByName('razor_eye_of_the_storm')


local castQDesire
local castWDesire, castWTarget
local castRDesire

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive

local aetherRange = 0

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    J.ConsiderForMkbDisassembleMask(bot)
    nKeepMana=280;nLV=bot:GetLevel();nMP=J.GetMP(bot);nHP=J.GetHP(bot)
    botTarget=J.GetProperTarget(bot);hEnemyList=J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE);hAllyList=J.GetAlliesNearLoc(bot:GetLocation(),1600)
    local desire,target=R.Link(bot,abilityW)
    if desire>0 then J.SetQueuePtToINT(bot,false,abilityW);bot:ActionQueue_UseAbilityOnEntity(abilityW,target);return end
    if R.Storm(bot,abilityR,true)>0 then J.SetQueuePtToINT(bot,true,abilityR);bot:ActionQueue_UseAbility(abilityR);return end
    if R.Plasma(bot,abilityQ)>0 or X.ConsiderQ()>0 then J.SetQueuePtToINT(bot,true,abilityQ);bot:ActionQueue_UseAbility(abilityQ) end
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    if #J.GetNearbyHeroes(bot,abilityQ:GetSpecialValueInt('radius'),true,BOT_MODE_NONE)>0 then return 0 end
    local nCastRange=abilityQ:GetSpecialValueInt('radius');local nCastPoint=abilityQ:GetCastPoint()
    local nManaCost=abilityQ:GetManaCost();local nDamageMin=abilityQ:GetSpecialValueInt('damage_min');local nDamageMax=abilityQ:GetSpecialValueInt('damage_max')
    local nSpeed=nCastRange*2/math.max(abilityQ:GetSpecialValueFloat('total_ability_time'),.1)
    local nDamageType=DAMAGE_TYPE_MAGICAL
	--推线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and #hAllyList < 3 and nLV > 7
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local nCanKillCount = 0
		local nCanHurtCount = 0
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nCastRange, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
                and J.CanCastOnNonMagicImmune(creep)
                and J.IsInRange(bot,creep,nCastRange)
				and not creep:HasModifier( "modifier_fountain_glyph" )
			then
				nCanHurtCount = nCanHurtCount + 1
				local nDist = GetUnitToUnitDistance( bot, creep )
				local nDamage = RemapValClamped( nDist, 0, nCastRange, nDamageMin, nDamageMax )
				if J.WillKillTarget( creep, nDamage, nDamageType, nDist/nSpeed )
				then
					nCanKillCount = nCanKillCount + 1
				end
			end
		end

		if nCanKillCount >= 3 or nCanHurtCount >= 5
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q推进'..nCanHurtCount
		end
	end

	--打钱
	if J.IsFarming( bot ) and nLV > 7 and bot:GetMana() > nKeepMana
	then
		local nCreepList = bot:GetNearbyNeutralCreeps( nCastRange )
		local nNearCreepList = bot:GetNearbyNeutralCreeps( 400 )
		if ( #nCreepList >= 3 and #nNearCreepList <= 2 )
			or #nCreepList >= 5
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q打野'..( #nCreepList )
		end

	end

	--对线
	if J.IsLaning( bot )
	then
		local nCanKillMeleeCount = 0
		local nCanKillRangedCount = 0
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nCastRange, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
                and J.CanCastOnNonMagicImmune(creep)
                and J.IsInRange(bot,creep,nCastRange)
				and not creep:HasModifier( "modifier_fountain_glyph" )
			then
				local nDist = GetUnitToUnitDistance( bot, creep )
				local nDamage = RemapValClamped( nDist, 0, nCastRange, nDamageMin, nDamageMax )
				if J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint + nDist/nSpeed )
				then
					if J.IsKeyWordUnit( 'ranged', creep )
					then
						nCanKillRangedCount = nCanKillRangedCount + 1
						if not J.IsInRange( bot, creep, bot:GetAttackRange() + 50 )
						then
							return BOT_ACTION_DESIRE_HIGH, 'Q对线1'
						end
					end

					if J.IsKeyWordUnit( 'melee', creep )
					then
						nCanKillMeleeCount = nCanKillMeleeCount + 1
					end

				end
			end
		end

		if nCanKillMeleeCount + nCanKillRangedCount >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q对线2'
		end

		if nCanKillRangedCount >= 1 and nCanKillMeleeCount >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q对线3'
		end


	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW() return R.Link(bot,abilityW) end
function X.ConsiderR() return R.Storm(bot,abilityR,true) end
return X
