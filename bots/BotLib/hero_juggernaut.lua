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
local U = require(GetScriptDirectory()..'/FunLib/juggernaut_abilities')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: carry only; forced other roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/juggernaut')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Blade Fury, [2] Healing Ward, [3] Blade Dance, [6] Omnislash.
local nAbilityBuildList = {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- -1s Bladeform stack gain interval
    t15={0,10}, -- -15s Omnislash cooldown
    t20={0,10}, -- +15% Blade Dance critical damage
    t25={10,0}, -- +40% Blade Dance lifesteal
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_power_treads','item_bfury','item_yasha','item_manta',
    'item_butterfly','item_blink','item_ultimate_scepter','item_swift_blink',
    -- Bot policy: consume Scepter, add a disable, then replace farming cleave with sustain.
    'item_ultimate_scepter_2','item_basher','item_abyssal_blade','item_satanic',
    'item_aghanims_shard','item_moon_shard',
}
X.sSellList = {'item_ultimate_scepter','item_magic_wand','item_satanic','item_bfury'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_melee_carry' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Blade Dance point at 10, then the first talent at 11. Preserve custom progressions.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		if hMinionUnit:GetUnitName() == 'npc_dota_juggernaut_healing_ward'
		then
			Minion.HealingWardThink( hMinionUnit )
		else
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

--[[

npc_dota_hero_juggernaut

"Ability1"		"juggernaut_blade_fury"
"Ability2"		"juggernaut_healing_ward"
"Ability3"		"juggernaut_blade_dance"
"Ability4"		"juggernaut_swift_slash"
"Ability5"		"generic_hidden"
"Ability6"		"juggernaut_omni_slash"
"Ability10"		"special_bonus_all_stats_5"
"Ability11"		"special_bonus_movement_speed_20"
"Ability12"		"special_bonus_unique_juggernaut_4"
"Ability13"		"special_bonus_attack_speed_20"
"Ability14"		"special_bonus_armor_8"
"Ability15"		"special_bonus_unique_juggernaut_3"
"Ability16"		"special_bonus_hp_475"
"Ability17"		"special_bonus_unique_juggernaut_2"

modifier_juggernaut_blade_fury
modifier_juggernaut_healing_ward_aura
modifier_juggernaut_healing_ward_tracker
modifier_juggernaut_healing_ward_heal
modifier_juggernaut_blade_dance
modifier_juggernaut_omnislash
modifier_juggernaut_omnislash_invulnerability


--]]

local abilityQ = bot:GetAbilityByName('juggernaut_blade_fury')
local abilityW = bot:GetAbilityByName('juggernaut_healing_ward')
local abilityE = bot:GetAbilityByName('juggernaut_blade_dance')
local abilityR = bot:GetAbilityByName('juggernaut_omni_slash')
local abilityD = bot:GetAbilityByName('juggernaut_swift_slash')
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget
local castDDesire, castDTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.UseHealingWardDuringSlash()
    return U.WardDuringSlash(bot, abilityW)
end
function X.SkillsComplement()
    if X.UseHealingWardDuringSlash() then return end
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    nLV=bot:GetLevel();nMP=J.GetMP(bot);nHP=J.GetHP(bot);botTarget=J.GetProperTarget(bot)
    hEnemyList=J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE);hAllyList=J.GetAlliesNearLoc(bot:GetLocation(),1600)
    if U.Fury(bot,abilityQ,true)>0 then bot:Action_UseAbility(abilityQ);return end
    local desire,target=X.ConsiderW()
    if desire>0 then bot:Action_UseAbilityOnLocation(abilityW,target);return end
    desire,target=X.ConsiderD()
    if desire>0 then bot:Action_UseAbilityOnEntity(abilityD,target);return end
    desire,target=X.ConsiderR()
    if desire>0 then bot:Action_UseAbilityOnEntity(abilityR,target);return end
    if X.ConsiderQ()>0 then bot:Action_UseAbility(abilityQ) end
end
function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) or bot:HasModifier('modifier_juggernaut_blade_fury') or bot:HasModifier('modifier_juggernaut_omnislash') then return 0 end
    local combat=U.Fury(bot,abilityQ)
    if combat>0 then return combat end
    local nCastRange=abilityQ:GetSpecialValueInt('blade_fury_radius')
    local nRadius=nCastRange
    local nManaCost=abilityQ:GetManaCost()
    local hCastTarget,sCastMotive
	--带线AOE
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and #hAllyList <= 2 
		and J.IsItemAvailable( "item_bfury" ) == nil
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nCastRange , true )
		if ( #laneCreepList >= 4 or ( #laneCreepList >= 3 and nMP > 0.82 ) )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			hCastTarget = laneCreepList[1]
			sCastMotive = 'Q-带线AOE'..(#laneCreepList)
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end
	
	
	
	--打野AOE
	if J.IsFarming( bot )
		and DotaTime() > 6 * 60
		and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
		and J.IsItemAvailable( "item_bfury" ) == nil
	then
		local creepList = bot:GetNearbyNeutralCreeps( nRadius )

		if #creepList >= 4
			and J.IsValid( botTarget )
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-打野AOE'..(#creepList)
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
	    end
	end



	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW() return U.Ward(bot,abilityW) end
function X.ConsiderR() return U.Slash(bot,abilityR) end
function X.ConsiderD() return U.Slash(bot,abilityD) end
return X
