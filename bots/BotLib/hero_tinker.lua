local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: mid only; forced picks use mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/tinker')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Laser, [2] March of the Machines, [3] Deploy Turrets, [6] Rearm.
local nAbilityBuildList = {1,3,2,2,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- manacost/manaloss reduction
    t15={10,0}, -- Laser damage
    t20={0,10}, -- Deploy Turrets missile damage
    t25={10,0}, -- Rearm channel time
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_kaya','item_blink','item_aghanims_shard','item_aether_lens',
    'item_ultimate_scepter','item_kaya_and_sange','item_black_king_bar',
    -- Bot policy: consume Scepter, then observed escape and a six-slot control finish.
    'item_ultimate_scepter_2','item_cyclone','item_wind_waker','item_arcane_blink','item_sheepstick',
}
X.sSellList = {'item_black_king_bar','item_bottle'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

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

local SpellDecisions=require(GetScriptDirectory()..'/FunLib/rubick_hero/tinker')
X.ConsiderLaser=SpellDecisions.ConsiderLaser
X.ConsiderMarchOfTheMachines=SpellDecisions.ConsiderMarch
X.ConsiderDeployTurrets=SpellDecisions.ConsiderTurrets
X.ConsiderWarpFlare=SpellDecisions.ConsiderWarp
X.ConsiderRearm=SpellDecisions.ConsiderRearm
X.ConsiderKeenConveyance=SpellDecisions.ConsiderTeleport
function X.SkillsComplement() SpellDecisions.UseNative() end
return X
