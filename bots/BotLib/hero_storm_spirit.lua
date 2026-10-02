-- Credit goes to Furious Puppy for Bot Experiment

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: mid only; forced other roles use mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/storm_spirit')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Remnant, [2] Vortex, [3] Overload, [6] Ball Lightning.
local nAbilityBuildList = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Mana regeneration
    t15={10,0}, -- Remnant damage
    t20={0,10}, -- Vortex duration
    t25={0,10}, -- Overload bounce
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    -- Observed ward omitted: core bots do not place wards.
    'item_four_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_soul_ring','item_power_treads','item_kaya','item_witch_blade',
    'item_kaya_and_sange','item_black_king_bar','item_devastator','item_aghanims_shard',
    'item_shivas_guard','item_ultimate_scepter',
    -- Bot policy: consume Scepter before late control to retain six major slots.
    'item_ultimate_scepter_2','item_sheepstick',
}
X.sSellList = {
    'item_black_king_bar','item_bottle',
    'item_shivas_guard','item_magic_wand',
    'item_ultimate_scepter','item_soul_ring',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_mid'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
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

local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/storm_spirit')
X.UseBallFlightSpells = SpellDecisions.UseBallFlightSpells
X.ConsiderStaticRemnant = SpellDecisions.ConsiderStaticRemnant
X.ConsiderElectricVortex = SpellDecisions.ConsiderElectricVortex
X.ConsiderOverload = SpellDecisions.ConsiderOverload
X.ConsiderBallLightning = SpellDecisions.ConsiderBallLightning
function X.SkillsComplement()
    SpellDecisions.UseNative()
end
return X
