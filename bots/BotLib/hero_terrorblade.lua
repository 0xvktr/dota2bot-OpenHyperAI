local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: carry; forced other roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/terrorblade')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Reflection, [2] Conjure Image, [3] Metamorphosis, [6] Sunder.
local nAbilityBuildList = {2,3,2,3,2,6,2,3,3,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- -2s Conjure Image cooldown
    t15={0,10}, -- -10s Metamorphosis cooldown
    t20={10,0}, -- +8s Conjure Image duration
    t25={10,0}, -- +30s Metamorphosis duration
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_power_treads','item_falcon_blade','item_yasha','item_manta','item_aghanims_shard',
    'item_dragon_lance','item_skadi','item_hurricane_pike','item_black_king_bar',
    -- Bot policy: late evasion/damage, avoiding multiple competing damage branches.
    'item_butterfly',
}
X.sSellList = {'item_dragon_lance','item_quelling_blade','item_skadi','item_magic_wand',
    'item_black_king_bar','item_falcon_blade'}

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

local SpellDecisions=require(GetScriptDirectory()..'/FunLib/rubick_hero/terrorblade')
X.ConsiderReflection=SpellDecisions.ConsiderReflection
X.ConsiderConjureImage=SpellDecisions.ConsiderConjureImage
X.ConsiderMetamorphosis=SpellDecisions.ConsiderMetamorphosis
X.ConsiderSunder=SpellDecisions.ConsiderSunder
X.ConsiderDemonZeal=SpellDecisions.ConsiderDemonZeal
X.ConsiderTerrorWave=SpellDecisions.ConsiderTerrorWave
function X.SkillsComplement() SpellDecisions.UseNative() end
return X
