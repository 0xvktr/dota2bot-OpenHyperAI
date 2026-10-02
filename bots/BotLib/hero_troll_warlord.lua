local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: carry only; forced roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/troll_warlord')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [2] linked Axes, [4] Fervor, [5] Berserker's Rage, [6] Battle Trance.
local nAbilityBuildList = {2,5,2,4,2,6,2,4,4,4,6,5,5,5,6}
local nTalentBuildList = J.Skill.GetTalentBuild({t10={10,0},t15={0,10},t20={10,0},t25={10,0}})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    -- Sange and Yasha is more picked (52.3%) than the displayed Manta (36.2%).
    'item_magic_wand','item_power_treads','item_bfury','item_yasha','item_sange_and_yasha',
    'item_black_king_bar','item_ultimate_scepter','item_ultimate_scepter_2','item_aghanims_shard',
    -- Bot policy: common late inventory, natural Blink upgrade and consumed attack speed.
    'item_blink','item_monkey_king_bar','item_swift_blink','item_moon_shard',
}
X.sSellList = {'item_bfury','item_quelling_blade','item_blink','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_antimage'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local M=require(GetScriptDirectory()..'/FunLib/troll_warlord_abilities')
function X.UseBattleStance()
    if not bot:IsSilenced() and not bot:IsInvisible() then return false end
    return M.UseStance(bot,true)
end
function X.SkillsComplement()
    if X.UseBattleStance() then return end
    if J.CanNotUseAbility(bot) then return end
    local r=bot:GetAbilityByName('troll_warlord_battle_trance')
    if M.Trance(bot,r,true)>0 then M.CastTrance(bot,r);return end
    if M.UseStance(bot,true) then return end
    local w=bot:GetAbilityByName('troll_warlord_whirling_axes_melee')
    if M.Melee(bot,w,true)>0 then bot:Action_UseAbility(w);return end
    local q=bot:GetAbilityByName('troll_warlord_whirling_axes_ranged')
    local desire,target=M.Ranged(bot,q,true)
    if desire>0 then bot:Action_UseAbilityOnLocation(q,target) end
end
return X
