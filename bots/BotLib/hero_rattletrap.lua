local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: both supports; forced cores use hard support without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/rattletrap')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Battery Assault, [2] Power Cogs, [3] Rocket Flare, [6] Hookshot.
local nAbilityBuildList = {2,1,2,3,2,6,2,3,3,3,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +1.5 mana regen
    t15={0,10}, -- -8s Hookshot cooldown
    t20={0,10}, -- Rocket Flare true sight
    t25={0,10}, -- 3 Rocket Flare charges
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_5 = {
    'item_boots','item_ward_sentry','item_blood_grenade',
    'item_tranquil_boots','item_magic_wand','item_urn_of_shadows','item_essence_distiller',
    'item_blink','item_cyclone','item_aghanims_shard',
    -- Bot policy: team escape, consumed Scepter and late defensive upgrades.
    'item_force_staff','item_ultimate_scepter','item_ultimate_scepter_2','item_wind_waker',
    'item_glimmer_cape','item_overwhelming_blink',
}
sRoleItemsBuyList.pos_4 = {
    'item_boots','item_ward_observer','item_ward_sentry','item_blood_grenade',
    'item_tranquil_boots','item_magic_wand','item_urn_of_shadows','item_essence_distiller',
    'item_cyclone','item_aghanims_shard','item_ultimate_scepter',
    -- Bot policy: consume Scepter, then initiation and team escape.
    'item_ultimate_scepter_2','item_blink','item_force_staff','item_glimmer_cape',
    'item_wind_waker','item_overwhelming_blink',
}
for role=1,3 do
    sRoleItemsBuyList['pos_'..role] = {}
    for _,item in ipairs(sRoleItemsBuyList.pos_5) do
        if item ~= 'item_ward_sentry' then table.insert(sRoleItemsBuyList['pos_'..role],item) end
    end
end
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {'item_blink','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_antimage'}, {} end

nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X.bDeafaultAbility = false
X.bDeafaultItem = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local C=require(GetScriptDirectory()..'/FunLib/clockwerk_abilities')
local names={'rattletrap_jetpack_toggle','rattletrap_jetpack','rattletrap_overclocking','rattletrap_hookshot','rattletrap_power_cogs','rattletrap_battery_assault','rattletrap_rocket_flare'}
local considers={C.JetpackToggle,C.Jetpack,C.Overclock,C.Hook,C.Cogs,C.Battery,C.Flare}
local scoutTime=-math.huge
function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    for index,name in ipairs(names) do
        local ability=bot:GetAbilityByName(name)
        local desire,point=considers[index](bot,ability,true)
        if desire>0 then
            if point then
                J.SetQueuePtToINT(bot,true,ability)
                bot:ActionQueue_UseAbilityOnLocation(ability,point)
            else bot:Action_UseAbility(ability) end
            return
        end
    end
    -- Keep proactive pit scouting, without depending on an unowned Hookshot handle.
    local flare=bot:GetAbilityByName('rattletrap_rocket_flare')
    if J.IsDoingRoshan(bot) and J.CanCastAbility(flare) and DotaTime()>scoutTime+15 then
        local location=J.GetCurrentRoshanLocation()
        if location and GetUnitToLocationDistance(bot,location)>1600 and J.IsAllowedToSpam(bot,flare:GetManaCost()) then
            J.SetQueuePtToINT(bot,true,flare);bot:ActionQueue_UseAbilityOnLocation(flare,location);scoutTime=DotaTime()
        end
    end
end
function X.ConsiderBatteryAssault() return C.Battery(bot,bot:GetAbilityByName('rattletrap_battery_assault'),true) end
function X.ConsiderPowerCogs() return C.Cogs(bot,bot:GetAbilityByName('rattletrap_power_cogs')) end
function X.ConsiderRocketFlare() return C.Flare(bot,bot:GetAbilityByName('rattletrap_rocket_flare'),true) end
function X.ConsiderHookshot() return C.Hook(bot,bot:GetAbilityByName('rattletrap_hookshot')) end
function X.ConsiderJetpack() return C.Jetpack(bot,bot:GetAbilityByName('rattletrap_jetpack')) end
function X.ConsiderOverclocking() return C.Overclock(bot,bot:GetAbilityByName('rattletrap_overclocking')) end
return X
