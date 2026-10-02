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

-- D2PT 7.41f: carry/mid/offlane; forced supports use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/slark')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local mid = sRole == 'pos_2'
-- [1] Dark Pact, [2] Pounce, [3] Saltwater Shiv, [6] Shadow Dance.
local nAbilityBuildList = mid and {3,2,3,1,1,6,1,1,2,2,6,2,3,3,6}
    or {2,3,1,1,1,6,1,2,2,2,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +0.5s Pounce leash
    t15={0,10}, -- +70 Dark Pact damage
    t20={10,0}, -- +100 Shadow Dance attack speed
    t25={10,0}, -- +1 agility per Essence Shift stack
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local roleItems = {}
roleItems.pos_1 = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_power_treads','item_diffusal_blade','item_ultimate_scepter','item_aghanims_shard',
    'item_black_king_bar','item_disperser','item_skadi',
    -- Bot policy: consume Scepter before late attack lockdown and mobility.
    'item_ultimate_scepter_2','item_basher','item_abyssal_blade','item_blink','item_swift_blink',
}
roleItems.pos_2 = {
    'item_double_branches','item_double_circlet','item_tango','item_faerie_fire',
    -- Bot policy: two Wraith Bands consume both observed starting Circlets.
    'item_wraith_band','item_wraith_band','item_magic_wand','item_power_treads','item_diffusal_blade',
    'item_ultimate_scepter','item_aghanims_shard','item_black_king_bar','item_disperser','item_blink',
    -- Bot policy: consume Scepter, then late durability and attack lockdown within six slots.
    'item_ultimate_scepter_2','item_skadi','item_basher','item_abyssal_blade',
}
roleItems.pos_3 = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_power_treads','item_diffusal_blade','item_mage_slayer',
    'item_ultimate_scepter','item_aghanims_shard','item_disperser','item_black_king_bar',
    -- Bot policy: consumed Scepter and late durability/mobility within six slots.
    'item_ultimate_scepter_2','item_skadi','item_blink','item_swift_blink',
}
roleItems.pos_4, roleItems.pos_5 = roleItems.pos_1, roleItems.pos_1
X.sBuyList = roleItems[sRole]
X.sSellList = {'item_diffusal_blade','item_quelling_blade','item_ultimate_scepter','item_magic_wand',
    'item_black_king_bar','item_wraith_band','item_disperser','item_wraith_band'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_melee_carry' }, {"item_power_treads", 'item_quelling_blade'} end

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

local Abilities=require(GetScriptDirectory()..'/FunLib/rubick_hero/slark')
function X.UseShadowDanceSpells() return Abilities.UseShadowDanceSpells() end
function X.SkillsComplement() Abilities.UseNative() end
return X
