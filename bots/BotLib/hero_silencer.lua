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

-- D2PT 7.41f: supports; forced core roles use hard support without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/silencer')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local pos4 = sRole == 'pos_4'
-- [1] Arcane Curse, [2] Glaives, [3] Last Word, [6] Global Silence.
local nAbilityBuildList = {2,1,1,3,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Silenced-target damage
    t15={0,10}, -- Global cooldown
    t20={10,0}, -- Last Word AoE
    t25={10,0}, -- Global duration
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = pos4 and {
    'item_branches','item_double_circlet','item_tango','item_faerie_fire','item_faerie_fire',
    'item_null_talisman','item_magic_wand','item_power_treads','item_force_staff',
    'item_dragon_lance','item_hurricane_pike','item_aghanims_shard',
    -- Bot policy: stronger Globals, escape utility and a six-slot late continuation.
    'item_ultimate_scepter','item_refresher','item_glimmer_cape','item_ultimate_scepter_2',
    'item_octarine_core','item_sheepstick',
} or {
    'item_double_branches','item_magic_stick','item_tango','item_faerie_fire','item_blood_grenade',
    'item_null_talisman','item_magic_wand','item_arcane_boots','item_force_staff',
    'item_ultimate_scepter','item_aghanims_shard','item_refresher',
    -- Bot policy: escape utility, consumed Scepter and supportive late upgrades.
    'item_glimmer_cape','item_ultimate_scepter_2','item_octarine_core','item_sheepstick',
    'item_guardian_greaves',
}
if sRole == 'pos_5' then table.insert(X.sBuyList,3,'item_ward_sentry') end
X.sSellList = {
    'item_force_staff','item_null_talisman',
    'item_ultimate_scepter','item_magic_wand',
}
if pos4 then
    table.insert(X.sSellList,'item_force_staff'); table.insert(X.sSellList,'item_circlet')
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_priest'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

local M=require(GetScriptDirectory()..'/FunLib/silencer_abilities')
local considers={{'silencer_global_silence',M.Global,'none'},{'silencer_curse_of_the_silent',M.Curse,'point'},{'silencer_last_word',M.Word,'word'},{'silencer_glaives_of_wisdom',M.Glaives,'unit'}}
function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    for _,entry in ipairs(considers) do
        local a=bot:GetAbilityByName(entry[1]);local desire,target,point=entry[2](bot,a,true)
        if desire>0 then
            J.SetQueuePtToINT(bot,false)
            if entry[3]=='none' then bot:ActionQueue_UseAbility(a)
            elseif entry[3]=='point' or point then bot:ActionQueue_UseAbilityOnLocation(a,target)
            else bot:ActionQueue_UseAbilityOnEntity(a,target) end
            return
        end
    end
end
return X
