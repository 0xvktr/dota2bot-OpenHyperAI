----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: offlane and mid; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/sand_king')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Burrowstrike, [2] Sand Storm, [3] Stinger, [6] Epicenter.
local nAbilityBuildList = sRole=='pos_2'
    and {2,3,2,1,2,6,2,1,1,1,6,3,3,3,6}
    or {2,1,2,3,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +12% Stinger slow
    t15=sRole=='pos_2' and {10,0} or {0,10}, -- Burrowstrike range / Sand Storm damage
    t20={10,0}, -- +6 Epicenter pulses
    t25={0,10}, -- +125 Stinger damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_3 = {
    'item_quelling_blade','item_gauntlets','item_double_branches','item_circlet','item_tango',
    'item_bracer','item_magic_wand','item_phase_boots','item_blink','item_ultimate_scepter',
    'item_aghanims_shard','item_cyclone',
    -- Bot policy: protection and armor, then consumed Scepter and natural upgrades.
    'item_black_king_bar','item_shivas_guard','item_ultimate_scepter_2',
    'item_wind_waker','item_overwhelming_blink',
}
sRoleItemsBuyList.pos_2 = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_double_branches','item_double_branches','item_branches','item_tango',
    'item_bottle','item_magic_wand','item_phase_boots','item_blink','item_ultimate_scepter',
    'item_aghanims_shard','item_black_king_bar','item_shivas_guard',
    -- Bot policy: omit optional Veil; Shiva does not consume it. Consume Scepter for late slots.
    'item_ultimate_scepter_2','item_lesser_crit','item_greater_crit','item_cyclone',
    'item_wind_waker','item_overwhelming_blink',
}
sRoleItemsBuyList.pos_1 = sRoleItemsBuyList.pos_3
sRoleItemsBuyList.pos_4 = sRoleItemsBuyList.pos_3
sRoleItemsBuyList.pos_5 = sRoleItemsBuyList.pos_3
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {'item_ultimate_scepter','item_magic_wand','item_black_king_bar','item_bracer','item_shivas_guard','item_bottle','item_blink','item_quelling_blade'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_tank'}, {'item_power_treads','item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X.bDeafaultAbility = false
X.bDeafaultItem = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end


local M=require(GetScriptDirectory()..'/FunLib/sand_king_abilities')
function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    if M.RelocateEpicenter(bot) then return end
    local epicenter=bot:GetAbilityByName('sandking_epicenter')
    local desire,target=M.Epicenter(bot,epicenter)
    if desire>0 then
        J.SetQueuePtToINT(bot,true);bot:ActionQueue_UseAbility(epicenter)
        M.RecordEpicenter(bot,epicenter,target);return
    end
    local burrow=bot:GetAbilityByName('sandking_burrowstrike')
    desire,target=M.Burrow(bot,burrow,true)
    if desire>0 then J.SetQueuePtToINT(bot,true);bot:ActionQueue_UseAbilityOnLocation(burrow,target);return end
    local storm=bot:GetAbilityByName('sandking_sand_storm')
    if M.Storm(bot,storm,true)>0 then J.SetQueuePtToINT(bot,true);bot:ActionQueue_UseAbility(storm);return end
    local stinger=bot:GetAbilityByName('sandking_scorpion_strike')
    desire,target=M.Stinger(bot,stinger,true)
    if desire>0 then J.SetQueuePtToINT(bot,false);bot:ActionQueue_UseAbilityOnLocation(stinger,target) end
end
return X
