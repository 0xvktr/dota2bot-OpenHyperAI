local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: mid/offlane and both supports; forced carry uses mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/snapfire')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Scatterblast, [2] Firesnap Cookie, [3] Lil' Shredder, [6] Mortimer Kisses.
local nAbilityBuildList = {1,2,1,2,1,6,1,2,2,3,6,3,3,3,6}
local support = sRole=='pos_4' or sRole=='pos_5'
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10=support and {10,0} or {0,10}, -- Kisses burn DPS / Scatterblast damage
    t15={10,0}, -- +125 cast range
    t20={10,0}, -- two Firesnap Cookie charges
    t25={10,0}, -- +6 Mortimer Kisses launched
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local roleItems = {}
roleItems.pos_2 = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_soul_ring','item_travel_boots','item_blink',
    'item_aghanims_shard','item_kaya','item_yasha_and_kaya','item_black_king_bar','item_shivas_guard',
    -- Bot policy: observed late refresh and natural upgrades, within six slots.
    'item_refresher','item_travel_boots_2','item_overwhelming_blink',
}
roleItems.pos_3 = {
    'item_double_gauntlets','item_double_branches','item_magic_stick',
    'item_bracer','item_soul_ring','item_magic_wand','item_aghanims_shard','item_travel_boots',
    'item_blink','item_kaya','item_yasha_and_kaya',
    -- Bot policy: observed optional BKB/Shiva, then refresh and Blink upgrade.
    'item_black_king_bar','item_shivas_guard','item_refresher','item_overwhelming_blink',
}
roleItems.pos_4 = {
    'item_double_branches','item_magic_stick','item_ward_sentry','item_tango','item_faerie_fire','item_blood_grenade',
    'item_magic_wand','item_arcane_boots','item_aghanims_shard','item_blink',
    -- Bot policy: observed caster continuation, capped at six major items.
    'item_kaya','item_yasha_and_kaya','item_shivas_guard','item_black_king_bar','item_sheepstick',
    'item_overwhelming_blink',
}
roleItems.pos_5 = {
    'item_double_branches','item_magic_stick','item_ward_sentry','item_tango','item_faerie_fire','item_blood_grenade',
    'item_magic_wand','item_arcane_boots','item_aghanims_shard','item_blink',
    -- Bot policy: observed caster continuation, then team escape within six slots.
    'item_kaya','item_yasha_and_kaya','item_black_king_bar','item_sheepstick','item_glimmer_cape',
    'item_overwhelming_blink',
}
roleItems.pos_1 = roleItems.pos_2
X.sBuyList = roleItems[sRole]
X.sSellList = {'item_black_king_bar','item_magic_wand','item_black_king_bar','item_bracer',
    'item_shivas_guard','item_soul_ring','item_shivas_guard','item_bottle','item_sheepstick','item_magic_wand'}

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
    Minion.MinionThink(hMinionUnit)
end

local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/snapfire')

function X.SkillsComplement()
    SpellDecisions.UseNative()
end

X.ConsiderScatterBlast = SpellDecisions.ConsiderScatterBlast
X.ConsiderFiresnapCookie = SpellDecisions.ConsiderFiresnapCookie
X.ConsiderLilShredder = SpellDecisions.ConsiderLilShredder
X.ConsiderGobbleUp = SpellDecisions.ConsiderGobbleUp
X.ConsiderSpitOut = SpellDecisions.ConsiderSpitOut
X.ConsiderMortimerKisses = SpellDecisions.ConsiderMortimerKisses
return X
