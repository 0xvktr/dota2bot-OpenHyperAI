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

-- D2PT 7.41f: mid/offlane; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/slardar')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Guardian Sprint, [2] Slithereen Crush, [3] Bash of the Deep, [6] Corrosive Haze.
local nAbilityBuildList = {2,3,2,1,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +2s Guardian Sprint duration
    t15={10,0}, -- -3 Corrosive Haze armor
    t20={0,10}, -- +125 Slithereen Crush damage
    t25={10,0}, -- Corrosive Haze undispellable
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local mid = sRole == 'pos_2'
X.sBuyList = mid and {
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_power_treads','item_blink','item_aghanims_shard','item_black_king_bar',
    'item_ultimate_scepter','item_assault',
    -- Bot policy: consume Scepter; late dispel, pull and Blink upgrade preserve six slots.
    'item_ultimate_scepter_2','item_nullifier','item_echo_sabre','item_harpoon','item_overwhelming_blink',
} or {
    'item_quelling_blade','item_gauntlets','item_double_branches','item_circlet','item_tango',
    'item_bracer','item_magic_wand','item_power_treads','item_soul_ring','item_blink',
    'item_aghanims_shard','item_black_king_bar','item_ultimate_scepter','item_nullifier',
    -- Bot policy: consume Scepter before late armor/pull; upgrade Blink within six slots.
    'item_ultimate_scepter_2','item_assault','item_echo_sabre','item_harpoon','item_overwhelming_blink',
}
X.sSellList = {'item_blink','item_bracer','item_black_king_bar','item_magic_wand',
    'item_ultimate_scepter',mid and 'item_bottle' or 'item_soul_ring','item_blink','item_quelling_blade'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

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

local Abilities=require(GetScriptDirectory()..'/FunLib/rubick_hero/slardar')
function X.SkillsComplement() Abilities.UseNative() end
return X
