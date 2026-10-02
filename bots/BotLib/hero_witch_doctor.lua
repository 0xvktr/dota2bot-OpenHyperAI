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

-- Updated to 7.41f from D2PT; forced skipped roles use pos 5.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/witch_doctor')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Paralyzing Cask, [2] Voodoo Restoration, [3] Maledict, [6] Death Ward.
local roleAbilityBuilds, roleTalentTrees = {}, {}
roleAbilityBuilds.pos_4 = {3,1,3,1,3,6,3,1,1,2,6,2,2,2,6}
roleTalentTrees.pos_4 = {
    t10={10,0}, -- Health
    t15={10,0}, -- Maledict duration
    t20={0,10}, -- Maledict bursts spread
    t25={10,0}, -- Death Ward damage
}
roleAbilityBuilds.pos_5 = {3,1,3,1,3,6,3,1,1,2,6,2,2,2,6}
roleTalentTrees.pos_5 = {
    t10={10,0}, -- Health
    t15={10,0}, -- Maledict duration
    t20={0,10}, -- Maledict bursts spread
    t25={10,0}, -- Death Ward damage
}
local nAbilityBuildList = roleAbilityBuilds[sRole] or roleAbilityBuilds.pos_5
local nTalentBuildList = J.Skill.GetTalentBuild(roleTalentTrees[sRole] or roleTalentTrees.pos_5)
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList, sRoleItemsSellList = {}, {}
sRoleItemsBuyList.pos_4 = {
        'item_double_branches','item_magic_stick','item_tango','item_ward_observer','item_ward_sentry',
        'item_faerie_fire','item_blood_grenade','item_magic_wand','item_arcane_boots','item_blink',
        'item_aghanims_shard',
        -- Bot policy: selected situational items and late upgrades.
        'item_glimmer_cape','item_ultimate_scepter','item_ultimate_scepter_2','item_black_king_bar','item_refresher',
        'item_sheepstick','item_overwhelming_blink',
}
sRoleItemsSellList.pos_4 = {'item_black_king_bar','item_magic_wand'}
sRoleItemsBuyList.pos_5 = {
        'item_double_branches','item_magic_stick','item_ward_sentry','item_tango','item_faerie_fire',
        'item_blood_grenade','item_magic_wand','item_arcane_boots','item_aghanims_shard','item_blink',
        -- Bot policy: selected situational items and late upgrades.
        'item_glimmer_cape','item_ultimate_scepter','item_ultimate_scepter_2','item_black_king_bar','item_refresher',
        'item_sheepstick','item_overwhelming_blink',
}
sRoleItemsSellList.pos_5 = {'item_black_king_bar','item_magic_wand'}
sRoleItemsBuyList.pos_1 = sRoleItemsBuyList.pos_5
sRoleItemsSellList.pos_1 = sRoleItemsSellList.pos_5
sRoleItemsBuyList.pos_2 = sRoleItemsBuyList.pos_5
sRoleItemsSellList.pos_2 = sRoleItemsSellList.pos_5
sRoleItemsBuyList.pos_3 = sRoleItemsBuyList.pos_5
sRoleItemsSellList.pos_3 = sRoleItemsSellList.pos_5
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = sRoleItemsSellList[sRole]
-- Core bots omit observed starting wards.
if sRole == 'pos_1' or sRole == 'pos_2' or sRole == 'pos_3' then
    local coreBuyList = {}
    for _, item in ipairs(X.sBuyList) do
        if item ~= 'item_ward_observer' and item ~= 'item_ward_sentry' then table.insert(coreBuyList, item) end
    end
    X.sBuyList = coreBuyList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT takes an ability at 10, then the first talent at 11.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if X.HandleDeathWard(hMinionUnit) then return end
	if Minion.IsValidUnit( hMinionUnit )
		and hMinionUnit:GetUnitName() ~= 'npc_dota_witch_doctor_death_ward'
	then
		Minion.IllusionThink( hMinionUnit )
	end

end


local W = require(GetScriptDirectory()..'/FunLib/rubick_hero/witch_doctor')
X.UseRestorationDuringChannel = W.UseRestorationDuringChannel
X.HandleDeathWard = W.HandleDeathWard
local lastAmulet = -90
local function WardProtection()
    if not bot:IsChanneling() or bot:IsInvisible() or bot:IsMuted() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or J.HasQueuedAction(bot) then return false end
    if bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local active=bot:GetCurrentActiveAbility()
    if active==nil or active:IsNull() or active~=bot:GetAbilityByName('witch_doctor_death_ward') then return false end
    if #bot:GetNearbyTowers(880,true)>0 then return false end
    for _,name in ipairs({'item_glimmer_cape','item_shadow_amulet'}) do
        local item=J.IsItemAvailable(name)
        if item~=nil and item:IsFullyCastable() and (name~='item_shadow_amulet' or DotaTime()-lastAmulet>10) then
            if name=='item_shadow_amulet' then lastAmulet=DotaTime() end
            bot:Action_UseAbilityOnEntity(item,bot);return true
        end
    end
    return false
end
function X.SkillsComplement()
    if W.UseRestorationDuringChannel() or WardProtection() then return end
    W.UseNative()
end

return X
