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

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/mirana')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sRole = J.Item.GetRoleItemsBuyList(bot)

-- Updated to 7.41f from D2PT; forced skipped roles use pos 4.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/mirana')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Starstorm, [2] Sacred Arrow, [3] Leap, [6] Moonlight Shadow.
local nAbilityBuildList = {2,3,1,1,1,6,1,2,2,2,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- Starstorm cooldown
    t15={0,10}, -- Moonlight Shadow evasion
    t20={0,10}, -- Starstorm damage
    t25={0,10}, -- Multishot Sacred Arrows
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_5' then
    X.sBuyList = {
        'item_branches','item_circlet','item_magic_stick','item_ward_sentry','item_tango','item_blood_grenade',
        'item_urn_of_shadows','item_magic_wand','item_essence_distiller','item_arcane_boots',
        'item_cyclone','item_ultimate_scepter',
        -- Bot policy: late upgrades and continuation.
        'item_ultimate_scepter_2','item_aghanims_shard','item_blink','item_wind_waker','item_sheepstick','item_octarine_core',
    }
    X.sSellList = {'item_blink','item_magic_wand'}
else
    -- Bot policy: buy ward components for the observed dispenser.
    X.sBuyList = {
        'item_branches','item_circlet','item_magic_stick','item_tango',
        'item_ward_observer','item_ward_sentry','item_blood_grenade',
        'item_urn_of_shadows','item_magic_wand','item_essence_distiller','item_arcane_boots',
        'item_cyclone','item_ultimate_scepter',
        -- Bot policy: late upgrades and continuation.
        'item_ultimate_scepter_2','item_aghanims_shard','item_blink','item_wind_waker','item_sheepstick','item_octarine_core',
    }
    X.sSellList = {'item_blink','item_magic_wand'}
end

-- Forced core picks omit wards.
if sRole ~= 'pos_4' and sRole ~= 'pos_5' then
    for i = #X.sBuyList, 1, -1 do
        if X.sBuyList[i] == 'item_ward_observer' or X.sBuyList[i] == 'item_ward_sentry' then
            table.remove(X.sBuyList, i)
        end
    end
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'],X['sSellList'] = { 'PvN_ranged_carry' }, {} end

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- D2PT takes an ability at 10, then the first talent at 11.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit)
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

--[[

npc_dota_hero_mirana

"Ability1"		"mirana_starfall"
"Ability2"		"mirana_arrow"
"Ability3"		"mirana_leap"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"mirana_invis"
"Ability10"		"special_bonus_attack_damage_12"
"Ability11"		"special_bonus_hp_150"
"Ability12"		"special_bonus_unique_mirana_3"
"Ability13"		"special_bonus_unique_mirana_1"
"Ability14"		"special_bonus_spell_amplify_10"
"Ability15"		"special_bonus_mana_break_20"
"Ability16"		"special_bonus_unique_mirana_2"
"Ability17"		"special_bonus_unique_mirana_4"

modifier_mirana_starfall_scepter_thinker
modifier_mirana_starfall_thinker
modifier_mirana_leap_charge_counter
modifier_mirana_leap
modifier_mirana_leap_buff
modifier_mirana_moonlight_shadow
modifier_mirana_moonlight_shadow_killtracker

--]]

local abilityQ = bot:GetAbilityByName('mirana_starfall')
local abilityW = bot:GetAbilityByName('mirana_arrow')
local abilityE = bot:GetAbilityByName('mirana_leap')
local abilityR = bot:GetAbilityByName('mirana_invis')


local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget


local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive;
local aetherRange = 0


function X.SkillsComplement()

	if J.CanNotUseAbility(bot) then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	botTarget = J.GetProperTarget(bot);
	hEnemyList = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE);
	hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1600);

	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end


    if SpellDecisions.MoonUseful(abilityR) then
        J.SetQueuePtToINT(bot, true, abilityR)
        bot:ActionQueue_UseAbility(abilityR)
        return
    end
    local interrupt = SpellDecisions.ArrowPoint(abilityW, true)
    if interrupt ~= nil then
        J.SetQueuePtToINT(bot, true, abilityW)
        bot:ActionQueue_UseAbilityOnLocation(abilityW, interrupt)
        return
    end
	castQDesire, castQTarget, sMotive = X.ConsiderQ();
	if ( castQDesire > 0 )
	then
		J.SetReportMotive(bDebugMode,sMotive);

		J.SetQueuePtToINT(bot, true, abilityQ)

		bot:ActionQueue_UseAbility( abilityQ )
		return;
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW();
	if ( castWDesire > 0 )
	then
		J.SetReportMotive(bDebugMode,sMotive);

		J.SetQueuePtToINT(bot, true)

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget )
		return;
	end

	castEDesire, castETarget, sMotive = X.ConsiderE();
	if ( castEDesire > 0 )
	then
		J.SetReportMotive(bDebugMode,sMotive);

		J.SetQueuePtToINT(bot, false)

		bot:ActionQueue_UseAbility( abilityE )
		return;
	end

	castRDesire, castRTarget, sMotive = X.ConsiderR();
	if ( castRDesire > 0 )
	then
		J.SetReportMotive(bDebugMode,sMotive);

		J.SetQueuePtToINT(bot, true)

		bot:ActionQueue_UseAbility( abilityR )
		return;

	end

end


function X.ConsiderQ()
    return SpellDecisions.StarUseful(abilityQ) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
function X.ConsiderW()
    local point = SpellDecisions.ArrowPoint(abilityW, false)
    return point ~= nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE, point
end
function X.ConsiderE()
    return SpellDecisions.LeapUseful(abilityE) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
function X.ConsiderR()
    return SpellDecisions.MoonUseful(abilityR) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
return X
