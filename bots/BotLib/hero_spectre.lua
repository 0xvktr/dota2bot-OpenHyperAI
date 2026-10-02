local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: carry only; forced other roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/spectre')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Spectral Dagger, [2] Shadow Step, [3] Dispersion, [6] Haunt.
local nAbilityBuildList = {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +12 Desolate damage
    t15={0,10}, -- +1s Shadow Step duration
    t20={0,10}, -- +300 health
    t25={0,10}, -- +12% all Spectre illusion damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_branches','item_circlet','item_magic_stick','item_tango',
    'item_urn_of_shadows','item_magic_wand','item_power_treads','item_radiance','item_yasha',
    'item_manta','item_skadi',
    -- Bot policy: observed bash/evasion, consume Scepter before the sixth major slot.
    'item_basher','item_aghanims_shard','item_ultimate_scepter','item_ultimate_scepter_2',
    'item_abyssal_blade','item_butterfly','item_moon_shard',
}
X.sSellList = {'item_skadi','item_magic_wand','item_skadi','item_urn_of_shadows','item_radiance','item_quelling_blade'}

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

local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/spectre')

function X.SkillsComplement()
    SpellDecisions.UseNative()
end

X.ConsiderSpectralDagger = SpellDecisions.ConsiderSpectralDagger
X.ConsiderDispersion = SpellDecisions.ConsiderDispersion
X.ConsiderShadowStep = SpellDecisions.ConsiderShadowStep
X.ConsiderHaunt = SpellDecisions.ConsiderHaunt
X.ConsiderReality = SpellDecisions.ConsiderReality
return X
