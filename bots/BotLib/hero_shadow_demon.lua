local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: supports; forced core roles use hard support without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/shadow_demon')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local pos4 = sRole == 'pos_4'
-- [1] Disruption, [2] Disseminate, [3] Shadow Poison, [6] Demonic Purge.
local nAbilityBuildList = {1,3,3,2,3,6,3,2,2,2,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Strength
    t15={10,0}, -- Poison cooldown
    t20={10,0}, -- Purge cooldown
    t25={10,0}, -- Disruption charges
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_double_branches','item_magic_stick','item_tango','item_faerie_fire','item_blood_grenade',
    'item_magic_wand','item_arcane_boots','item_blink',
}
if sRole == 'pos_4' or sRole == 'pos_5' then table.insert(X.sBuyList,3,'item_ward_sentry') end
local continuation = pos4 and {
    'item_aether_lens','item_aghanims_shard','item_force_staff','item_ultimate_scepter',
} or {
    'item_glimmer_cape','item_aghanims_shard','item_aether_lens','item_ultimate_scepter',
}
for _, item in ipairs(continuation) do table.insert(X.sBuyList,item) end
-- Bot policy: consumed Scepter, cooldown reduction, survivability and natural upgrades.
for _, item in ipairs({'item_ultimate_scepter_2','item_octarine_core','item_aeon_disk',
    'item_guardian_greaves','item_arcane_blink'}) do table.insert(X.sBuyList,item) end
X.sSellList = {'item_ultimate_scepter','item_magic_wand'}

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

local M=require(GetScriptDirectory()..'/FunLib/shadow_demon_abilities')
local spells={
    {'shadow_demon_disruption',function(bot,ability) return M.Disruption(bot,ability,false) end,'unit'},
    {'shadow_demon_demonic_cleanse',M.Cleanse,'unit'},
    {'shadow_demon_shadow_poison_release',M.Release,'none'},
    {'shadow_demon_demonic_purge',M.Purge,'unit'},
    {'shadow_demon_disseminate',M.Disseminate,'unit'},
    {'shadow_demon_shadow_poison',M.Poison,'point'},
}
function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    for _,entry in ipairs(spells) do
        local ability=bot:GetAbilityByName(entry[1]);local desire,target=entry[2](bot,ability,true)
        if desire>0 then
            if entry[3]=='unit' then bot:Action_UseAbilityOnEntity(ability,target)
            elseif entry[3]=='point' then bot:Action_UseAbilityOnLocation(ability,target);M.RecordPoison(bot,ability,target)
            else bot:Action_UseAbility(ability) end
            return
        end
    end
end
return X
