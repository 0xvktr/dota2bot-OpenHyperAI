local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/lycan')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: offlane only; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/lycan')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Summon Wolves, [2] Howl, [3] Feral Impulse, [6] Shapeshift.
local nAbilityBuildList = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +14 Wolves damage
    t15={10,0}, -- -15s Shapeshift cooldown
    t20={10,0}, -- +25% Feral Impulse damage
    t25={0,10}, -- Howl reduces total attack damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_double_branches','item_sobi_mask','item_magic_stick',
    'item_helm_of_iron_will','item_helm_of_the_dominator','item_magic_wand',
    'item_helm_of_the_overlord','item_aghanims_shard','item_assault',
    'item_black_king_bar','item_nullifier',
    -- Bot policy: late mobility, consumed Scepter and a disable within six slots.
    'item_travel_boots','item_ultimate_scepter','item_ultimate_scepter_2','item_sheepstick',
}
X.sSellList = {
    'item_helm_of_the_dominator','item_quelling_blade',
    'item_assault','item_sobi_mask',
    'item_ultimate_scepter','item_magic_wand',
}

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
    if SpellDecisions.UseHightail(hMinionUnit) then return end
    Minion.MinionThink(hMinionUnit)
end

local SummonWolves  = bot:GetAbilityByName('lycan_summon_wolves')
local Howl          = bot:GetAbilityByName('lycan_howl')
local FeralImpulse  = bot:GetAbilityByName('lycan_feral_impulse')
local WolfBite      = bot:GetAbilityByName('lycan_wolf_bite')
local ShapeShift    = bot:GetAbilityByName('lycan_shapeshift')

local SummonWolvesDesire
local HowlDesire
local WolfBiteTarget
local ShapeShiftDesire

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    ShapeShiftDesire = X.ConsiderShapeShift()
    if ShapeShiftDesire > 0
    then
        J.SetQueuePtToINT(bot, true, ShapeShift)
        bot:ActionQueue_UseAbility(ShapeShift)
        return
    end

    HowlDesire = X.ConsiderHowl()
    if HowlDesire > 0
    then
        J.SetQueuePtToINT(bot, true, Howl)
        bot:ActionQueue_UseAbility(Howl)
        return
    end

    SummonWolvesDesire = X.ConsiderSummonWolves()
    if SummonWolvesDesire > 0
    then
        J.SetQueuePtToINT(bot, true, SummonWolves)
        bot:ActionQueue_UseAbility(SummonWolves)
        return
    end

    WolfBiteTarget = SpellDecisions.BiteTarget(WolfBite)
    if WolfBiteTarget ~= nil then
        J.SetQueuePtToINT(bot, true, WolfBite)
        bot:ActionQueue_UseAbilityOnEntity(WolfBite, WolfBiteTarget)
    end
end

function X.ConsiderSummonWolves()
    return SpellDecisions.SummonUseful(SummonWolves) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
function X.ConsiderHowl()
    return SpellDecisions.HowlUseful(Howl) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
function X.ConsiderShapeShift()
    return SpellDecisions.ShapeUseful(ShapeShift) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
return X
