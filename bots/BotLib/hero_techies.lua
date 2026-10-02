local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local TU            = dofile( GetScriptDirectory()..'/FunLib/techies_utility' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: both supports; forced cores use support without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/techies')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Sticky Bomb, [2] Reactive Tazer, [3] Blast Off!, [6] Proximity Mines.
local nAbilityBuildList = {3,2,3,2,3,6,3,2,2,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- -2s Proximity Mines cooldown
    t15={0,10}, -- +175 Blast Off! damage
    t20={10,0}, -- -15s Blast Off! cooldown
    t25={10,0}, -- -0.8s Proximity Mines activation delay
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local roleItems = {}
roleItems.pos_4 = {
    -- Ward dispenser charges are ambiguous; a Sentry is bot policy.
    'item_boots','item_ward_sentry','item_blood_grenade',
    'item_tranquil_boots','item_magic_wand','item_aether_lens','item_kaya','item_sheepstick',
    -- Bot policy: upgrade Kaya, then optional mobility and Shard after the observed core.
    'item_yasha_and_kaya','item_blink','item_aghanims_shard',
    -- Bot policy: consume Scepter before late Ethereal Blade; six persistent slots.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_ethereal_blade',
}
roleItems.pos_5 = {
    'item_double_branches','item_magic_stick','item_ward_sentry','item_tango','item_faerie_fire','item_blood_grenade',
    'item_tranquil_boots','item_magic_wand','item_soul_ring','item_aether_lens','item_kaya',
    'item_yasha_and_kaya','item_sheepstick','item_glimmer_cape','item_aghanims_shard',
    -- Bot policy: consumed Scepter and late cooldowns, retaining Lens separately.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_octarine_core',
}
for _,r in ipairs({'pos_1','pos_2','pos_3'}) do
    roleItems[r] = {}
    for _,item in ipairs(roleItems.pos_4) do
        if item ~= 'item_ward_sentry' then table.insert(roleItems[r],item) end
    end
end
X.sBuyList = roleItems[sRole]
X.sSellList = {'item_sheepstick','item_magic_wand','item_glimmer_cape','item_soul_ring'}

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

local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/techies')
X.ConsiderStickyBomb = SpellDecisions.ConsiderStickyBomb
X.ConsiderReactiveTazer = SpellDecisions.ConsiderReactiveTazer
X.ConsiderReactiveTazerStop = SpellDecisions.ConsiderReactiveTazerStop
X.ConsiderBlastOff = SpellDecisions.ConsiderBlastOff
X.ConsiderProximityMines = SpellDecisions.ConsiderProximityMines
X.ConsiderMineFieldSign = SpellDecisions.ConsiderMineFieldSign
X.ConsiderMAD = SpellDecisions.ConsiderMAD
X.ConsiderMADDetonate = SpellDecisions.ConsiderMADDetonate
function X.SkillsComplement()
    SpellDecisions.UseNative()
end
return X
