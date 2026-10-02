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

-- D2PT 7.41f: offlane; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/tidehunter')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Gush, [2] Kraken Shell, [3] Anchor Smash, [6] Ravage.
local nAbilityBuildList = {1,3,3,2,3,6,3,2,2,2,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +20% Gush slow
    t15={0,10}, -- +90 Gush damage
    t20={10,0}, -- +4 Gush armor reduction
    t25={0,10}, -- +1s Ravage stun duration
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_double_gauntlets','item_double_branches','item_magic_stick',
    'item_bracer','item_bracer','item_magic_wand','item_soul_ring','item_phase_boots',
    -- Bot policy: the popular optional Vladmir aura supports the team.
    'item_vladmir','item_blink','item_aghanims_shard','item_ultimate_scepter','item_shivas_guard',
    -- Bot policy: consume Scepter before Refresher/BKB; retain six persistent slots.
    'item_ultimate_scepter_2','item_refresher','item_black_king_bar','item_overwhelming_blink',
}
X.sSellList = {'item_blink','item_bracer','item_blink','item_bracer',
    'item_ultimate_scepter','item_magic_wand','item_shivas_guard','item_soul_ring'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_heavens_halberd", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

-- Observed ability at 10, first talent at 11; preserve custom overrides.
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

local SpellDecisions=require(GetScriptDirectory()..'/FunLib/rubick_hero/tidehunter')
X.ConsiderQ=SpellDecisions.ConsiderQ
X.ConsiderW=SpellDecisions.ConsiderW
X.ConsiderE=SpellDecisions.ConsiderE
X.ConsiderR=SpellDecisions.ConsiderR
X.ConsiderDeadInTheWater=SpellDecisions.ConsiderDeadInTheWater
function X.SkillsComplement() SpellDecisions.UseNative() end
return X
