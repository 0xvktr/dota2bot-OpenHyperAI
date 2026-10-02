local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: support/hard support; forced other roles use hard support.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/ringmaster')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Tame the Beasts, [2] Escape Act, [3] Impalement Arts, [6] Wheel of Wonder.
local nAbilityBuildList = {3,1,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +75 Tame the Beasts radius
    t15={10,0}, -- Tame the Beasts grants debuff immunity while channeling
    t20={10,0}, -- +75/+300 Tame the Beasts damage
    t25={10,0}, -- Escape Act strong dispel and flying movement
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
-- Bot policy: Sentry for the ambiguous pos4 ward bundle; both observed openings otherwise match.
X.sBuyList = {
    'item_double_branches','item_magic_stick','item_ward_sentry','item_tango','item_faerie_fire','item_blood_grenade',
    'item_magic_wand','item_arcane_boots','item_glimmer_cape','item_blink','item_cyclone','item_aether_lens',
    'item_ultimate_scepter','item_aghanims_shard',
    -- Bot policy: consume Scepter, upgrade Eul's and add late control within six slots.
    'item_ultimate_scepter_2','item_wind_waker','item_sheepstick',
}
X.sSellList = {'item_aether_lens','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Impalement Arts point at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local M=require(GetScriptDirectory()..'/FunLib/ringmaster_abilities')
function X.UseTameTheBeastsCrack() return M.ReleaseWhip(bot) end
function X.UseCarnivalSouvenir() return M.UseSouvenir(bot,true) end
local names={'ringmaster_the_box','ringmaster_wheel','ringmaster_tame_the_beasts','ringmaster_impalement','ringmaster_spotlight'}
local considers={M.Box,M.Wheel,M.Whip,M.Dagger,M.Spotlight}
function X.SkillsComplement()
    if X.UseTameTheBeastsCrack() or X.UseCarnivalSouvenir() then return end
    if J.CanNotUseAbility(bot) then return end
    for index,name in ipairs(names) do
        local ability=bot:GetAbilityByName(name)
        local desire,target,shape=considers[index](bot,ability,true)
        if desire>0 then
            J.SetQueuePtToINT(bot,true,ability)
            if shape=='unit' then bot:ActionQueue_UseAbilityOnEntity(ability,target) else bot:ActionQueue_UseAbilityOnLocation(ability,target) end
            if name=='ringmaster_tame_the_beasts' then M.RecordWhip(bot,ability,target) end
            return
        end
        if index==1 and M.UseSouvenir(bot,false) then return end
    end
end
function X.ConsiderTameTheBeasts() return M.Whip(bot,bot:GetAbilityByName('ringmaster_tame_the_beasts'),true) end
function X.ConsiderTameTheBeastsCrack() return M.Crack(bot,bot:GetAbilityByName('ringmaster_tame_the_beasts_crack')) end
function X.ConsiderEscapeAct() return M.Box(bot,bot:GetAbilityByName('ringmaster_the_box')) end
function X.ConsiderImpalementArts() return M.Dagger(bot,bot:GetAbilityByName('ringmaster_impalement'),true) end
function X.ConsiderSpotlight() return M.Spotlight(bot,bot:GetAbilityByName('ringmaster_spotlight')) end
function X.ConsiderWheelOfWonder() return M.Wheel(bot,bot:GetAbilityByName('ringmaster_wheel')) end
return X
