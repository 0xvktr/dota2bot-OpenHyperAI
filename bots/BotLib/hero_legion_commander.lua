local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Spells = require(GetScriptDirectory()..'/FunLib/rubick_hero/legion_commander')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: offlane; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/legion_commander')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Overwhelming Odds, [2] Press the Attack, [3] Moment of Courage, [6] Duel.
local nAbilityBuildList = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- -2s Overwhelming Odds cooldown
    t15={10,0}, -- +35 Overwhelming Odds damage per hero
    t20={0,10}, -- +0.75s Duel duration
    t25={10,0}, -- Duel victory advances cooldown by 30s
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
-- Condense the observed double Bracer to one temporary lane item.
X.sBuyList = {'item_quelling_blade','item_gauntlets','item_double_branches','item_circlet','item_tango',
    'item_bracer','item_magic_wand','item_phase_boots','item_blink','item_blade_mail','item_black_king_bar',
    'item_aghanims_shard','item_assault','item_lesser_crit',
    -- Bot policy: finish damage and Blink upgrades, then consumed late upgrades.
    'item_greater_crit','item_overwhelming_blink','item_ultimate_scepter','item_ultimate_scepter_2','item_moon_shard'}
X.sSellList = {'item_blade_mail','item_quelling_blade','item_black_king_bar','item_magic_wand','item_assault','item_bracer'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Moment of Courage at 10, first talent at 11; preserve custom builds.
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

local abilityQ, abilityW, abilityR
local function Refresh()
    abilityQ=bot:GetAbilityByName(sAbilityList[1])
    abilityW=bot:GetAbilityByName(sAbilityList[2])
    abilityR=bot:GetAbilityByName(sAbilityList[6])
end
function X.ConsiderQ()
    Refresh()
    return Spells.OddsUseful(abilityQ) and BOT_ACTION_DESIRE_HIGH or 0
end
function X.ConsiderW()
    Refresh()
    local target=Spells.PressTarget(abilityW,false)
    return target and BOT_ACTION_DESIRE_HIGH or 0,target
end
function X.ConsiderR()
    Refresh()
    local target=Spells.DuelTarget(abilityR)
    return target and BOT_ACTION_DESIRE_HIGH or 0,target
end
function X.SkillsComplement()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    Refresh()
    local dueling=bot:HasModifier('modifier_legion_commander_duel')
    local save=Spells.PressTarget(abilityW,true)
    if save then
        if not dueling then J.SetQueuePtToINT(bot,true,abilityW) end
        Spells.CastPress(abilityW,save,not dueling)
        return
    end
    local target=Spells.DuelTarget(abilityR)
    if target then
        J.SetQueuePtToINT(bot,true,abilityR)
        local mana=bot:GetMana()-abilityR:GetManaCost()
        if J.CanCastAbility(abilityW) and mana>=abilityW:GetManaCost()
            and not bot:IsMagicImmune() and not bot:HasModifier('modifier_legion_commander_press_the_attack') then
            Spells.CastPress(abilityW,bot,true)
            mana=mana-abilityW:GetManaCost()
        end
        local bladeMail=J.IsItemAvailable('item_blade_mail')
        if bladeMail and bladeMail:IsFullyCastable() and mana>=bladeMail:GetManaCost()
            and not bot:HasModifier('modifier_item_blade_mail_reflect') then
            bot:ActionQueue_UseAbility(bladeMail)
        end
        -- Keep preparation and Duel in one queue; an immediate cast cancels it.
        bot:ActionQueue_UseAbilityOnEntity(abilityR,target)
        return
    end
    if Spells.OddsUseful(abilityQ) then
        if dueling then bot:Action_UseAbility(abilityQ)
        else J.SetQueuePtToINT(bot,true,abilityQ);bot:ActionQueue_UseAbility(abilityQ) end
        return
    end
    local press=Spells.PressTarget(abilityW,false)
    if press then
        if not dueling then J.SetQueuePtToINT(bot,true,abilityW) end
        Spells.CastPress(abilityW,press,not dueling)
    end
end
return X
