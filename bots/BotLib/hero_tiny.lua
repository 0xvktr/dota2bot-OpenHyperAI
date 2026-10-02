local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: carry, mid and support; forced picks use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/tiny')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Avalanche, [2] Toss, [3] Tree Grab, [6] Grow.
local nAbilityBuildList = sRole=='pos_2' and {3,1,1,2,1,6,1,2,2,2,6,3,3,3,6}
    or sRole=='pos_4' and {1,2,2,1,2,6,2,1,1,3,6,3,3,3,6}
    or {3,1,3,1,3,6,3,1,1,2,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10=(sRole=='pos_1' or sRole=='pos_3' or sRole=='pos_5') and {10,0} or {0,10},
    t15=(sRole=='pos_1' or sRole=='pos_3' or sRole=='pos_5') and {0,10} or {10,0},
    t20=sRole=='pos_4' and {10,0} or {0,10},
    t25={10,0}, -- two Toss charges
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local roleItems = {}
roleItems.pos_1 = {
    'item_double_gauntlets','item_double_branches','item_magic_stick',
    'item_magic_wand','item_power_treads','item_echo_sabre','item_invis_sword','item_blink',
    'item_silver_edge','item_black_king_bar','item_harpoon','item_lesser_crit','item_greater_crit',
    -- Bot policy: natural Blink upgrade and observed Shard; six major items.
    'item_swift_blink','item_aghanims_shard',
}
roleItems.pos_2 = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_soul_ring','item_power_treads','item_blink','item_echo_sabre',
    -- Bot policy: observed optional burst progression and natural upgrades.
    'item_invis_sword','item_black_king_bar','item_lesser_crit','item_silver_edge','item_harpoon',
    'item_aghanims_shard','item_greater_crit','item_swift_blink',
}
roleItems.pos_4 = {
    -- Ward dispenser is ambiguous; use a sentry as support policy.
    'item_boots','item_ward_sentry','item_blood_grenade',
    'item_arcane_boots','item_magic_wand','item_blink','item_cyclone','item_force_staff','item_wind_waker',
    -- Bot policy: observed late utility, capped at six major items.
    'item_aghanims_shard','item_lotus_orb','item_sheepstick','item_overwhelming_blink',
}
roleItems.pos_3, roleItems.pos_5 = roleItems.pos_1, roleItems.pos_1
X.sBuyList = roleItems[sRole]
X.sSellList = {'item_black_king_bar','item_magic_wand','item_black_king_bar','item_soul_ring',
    'item_silver_edge','item_bottle','item_wind_waker','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

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
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end
end

local SpellDecisions=require(GetScriptDirectory()..'/FunLib/rubick_hero/tiny')
X.ConsiderAvalanche=SpellDecisions.ConsiderAvalanche
X.ConsiderToss=SpellDecisions.ConsiderToss
X.ConsiderTreeGrab=SpellDecisions.ConsiderTreeGrab
X.ConsiderTreeThrow=SpellDecisions.ConsiderTreeThrow
X.ConsiderTreeVolley=SpellDecisions.ConsiderTreeVolley
function X.SkillsComplement() SpellDecisions.UseNative() end
return X
