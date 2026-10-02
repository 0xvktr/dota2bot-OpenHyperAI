local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: both supports; forced cores use ward-free hard support.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/treant')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Nature's Grasp, [2] Leech Seed, [3] Living Armor, [6] Overgrowth.
local nAbilityBuildList = {2,3,3,1,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- Living Armor duration
    t15={10,0}, -- Nature's Grasp damage
    t20={0,10}, -- Living Armor damage block
    t25={10,0}, -- AoE Living Armor
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    -- Pos 4's ward dispenser is ambiguous; use the observed pos 5 sentry.
    'item_boots','item_ward_sentry','item_blood_grenade',
    'item_magic_wand','item_arcane_boots','item_blink','item_aghanims_shard',
    -- Bot policy: observed utility and natural upgrades, within six slots.
    'item_cyclone','item_force_staff','item_mekansm','item_guardian_greaves',
    'item_ultimate_scepter','item_ultimate_scepter_2','item_refresher','item_wind_waker','item_lotus_orb',
    'item_overwhelming_blink',
}
if sRole~='pos_4' and sRole~='pos_5' then
    local items = {}
    for _,item in ipairs(X.sBuyList) do if item~='item_ward_sentry' then items[#items+1]=item end end
    X.sBuyList = items
end
X.sSellList = {'item_guardian_greaves','item_magic_wand'}

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

local SpellDecisions=require(GetScriptDirectory()..'/FunLib/rubick_hero/treant')
X.ConsiderNaturesGrasp=SpellDecisions.ConsiderNaturesGrasp
X.ConsiderLeechSeed=SpellDecisions.ConsiderLeechSeed
X.ConsiderLivingArmor=SpellDecisions.ConsiderLivingArmor
X.ConsiderOvergrowth=SpellDecisions.ConsiderOvergrowth
X.ConsiderEyesInTheForest=SpellDecisions.ConsiderEyesInTheForest
X.ConsiderNaturesGuise=SpellDecisions.ConsiderNaturesGuise
X.ConsiderSuperBloom=SpellDecisions.ConsiderSuperBloom
function X.SkillsComplement() SpellDecisions.UseNative() end
return X
