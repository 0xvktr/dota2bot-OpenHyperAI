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
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/shadow_shaman')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local pos4 = sRole == 'pos_4'
-- [1] Ether Shock, [2] Hex, [3] Shackles, [6] Mass Serpent Ward.
local nAbilityBuildList = {3,1,3,2,3,6,3,2,2,2,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- Shackles damage
    t15={10,0}, -- Hex breaks
    t20={0,10}, -- Shackles duration
    t25={10,0}, -- Ward attack targets
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = pos4 and {
    'item_boots','item_blood_grenade','item_magic_wand','item_arcane_boots','item_blink',
    'item_aether_lens','item_aghanims_shard','item_black_king_bar','item_refresher',
    -- Bot policy: channel protection and natural boots/Blink upgrades.
    'item_glimmer_cape','item_guardian_greaves','item_arcane_blink',
} or {
    'item_double_branches','item_magic_stick','item_tango','item_faerie_fire','item_blood_grenade',
    'item_magic_wand','item_arcane_boots','item_blink','item_aether_lens','item_glimmer_cape',
    'item_aghanims_shard','item_black_king_bar','item_refresher',
    -- Bot policy: natural boots/Blink upgrades retain the utility inventory.
    'item_guardian_greaves','item_arcane_blink',
}
if sRole == 'pos_5' then table.insert(X.sBuyList,3,'item_ward_sentry') end
X.sSellList = {'item_black_king_bar','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_mage'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end



local M=require(GetScriptDirectory()..'/FunLib/shadow_shaman_abilities')
local considers={
    {'shadow_shaman_voodoo',M.Hex,'unit'},
    {'shadow_shaman_mass_serpent_ward',M.Wards,'point'},
    {'shadow_shaman_urnaconda',M.Urnaconda,'point'},
    {'shadow_shaman_ether_shock',M.Shock,'unit'},
    {'shadow_shaman_shackles',M.Shackles,'unit'},
}
function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    for _,entry in ipairs(considers) do
        local ability=bot:GetAbilityByName(entry[1]);local desire,target=entry[2](bot,ability,true)
        if desire>0 then
            J.SetQueuePtToINT(bot,true)
            if entry[3]=='point' then bot:ActionQueue_UseAbilityOnLocation(ability,target) else bot:ActionQueue_UseAbilityOnEntity(ability,target) end
            return
        end
    end
end
return X
