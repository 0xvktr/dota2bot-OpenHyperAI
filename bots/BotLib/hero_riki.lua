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

-- Updated to 7.41f from D2PT: carry and mid; forced other roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/riki')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Smoke Screen, [2] Blink Strike, [3] Tricks, [6] Cloak and Dagger.
local nAbilityBuildList = {2,3,2,1,2,6,2,3,3,3,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +10% Cloak and Dagger movement speed
    t15={0,10}, -- 15% base damage added to Tricks
    t20={0,10}, -- +0.3 Backstab multiplier
    t25={10,0}, -- +500 Blink Strike cast range
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_1 = {
    'item_quelling_blade','item_slippers','item_double_branches','item_circlet','item_tango',
    'item_wraith_band','item_magic_wand','item_power_treads','item_phylactery','item_diffusal_blade',
    'item_yasha','item_manta','item_aghanims_shard','item_disperser','item_basher','item_butterfly',
    -- Bot policy: natural Khanda/Abyssal upgrades, then consumed attack speed.
    'item_angels_demise','item_abyssal_blade','item_moon_shard',
}
sRoleItemsBuyList.pos_2 = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_power_treads','item_diffusal_blade','item_yasha','item_manta',
    'item_aghanims_shard','item_disperser','item_basher',
    -- Bot policy: consume Scepter before late dispel and protection slots.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_nullifier','item_sphere',
    'item_abyssal_blade','item_moon_shard',
}
for role=3,5 do sRoleItemsBuyList['pos_'..role] = sRoleItemsBuyList.pos_1 end
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {'item_manta','item_magic_wand','item_disperser','item_wraith_band','item_disperser','item_quelling_blade','item_disperser','item_bottle'}

if J.Role.IsPvNMode() then X.sBuyList, X.sSellList = {'PvN_BH'}, {'item_power_treads','item_quelling_blade'} end

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


local R=require(GetScriptDirectory()..'/FunLib/riki_abilities')
function X.UseSmokeDuringTricks() return R.SmokeDuringTricks(bot) end
function X.SkillsComplement()
    if X.UseSmokeDuringTricks() then return end
    if J.CanNotUseAbility(bot) then return end
    local blink=bot:GetAbilityByName('riki_blink_strike')
    local desire,target=R.Blink(bot,blink,true,true)
    if desire>0 then bot:Action_UseAbilityOnEntity(blink,target);return end
    local tricks=bot:GetAbilityByName('riki_tricks_of_the_trade')
    local shape
    desire,target,shape=R.Tricks(bot,tricks,true)
    if desire>0 and (J.IsRetreating(bot) or J.IsStunProjectileIncoming(bot,600)) then
        if shape=='unit' then bot:Action_UseAbilityOnEntity(tricks,target) else bot:Action_UseAbilityOnLocation(tricks,target) end
        return
    end
    local smoke=bot:GetAbilityByName('riki_smoke_screen')
    local smokeDesire,point=R.Smoke(bot,smoke)
    if smokeDesire>0 then J.SetQueuePtToINT(bot,true,smoke);bot:ActionQueue_UseAbilityOnLocation(smoke,point);return end
    local dart=bot:GetAbilityByName('riki_poison_dart')
    local dartDesire,dartTarget=R.Dart(bot,dart)
    if dartDesire>0 then J.SetQueuePtToINT(bot,true,dart);bot:ActionQueue_UseAbilityOnEntity(dart,dartTarget);return end
    local blinkDesire,blinkTarget=R.Blink(bot,blink,true)
    if blinkDesire>0 then J.SetQueuePtToINT(bot,true,blink);bot:ActionQueue_UseAbilityOnEntity(blink,blinkTarget);return end
    if desire>0 then
        J.SetQueuePtToINT(bot,true,tricks)
        if shape=='unit' then bot:ActionQueue_UseAbilityOnEntity(tricks,target) else bot:ActionQueue_UseAbilityOnLocation(tricks,target) end
    end
end
function X.ConsiderQ() return R.Smoke(bot,bot:GetAbilityByName('riki_smoke_screen')) end
function X.ConsiderW() return R.Blink(bot,bot:GetAbilityByName('riki_blink_strike'),true) end
function X.ConsiderE() return R.Tricks(bot,bot:GetAbilityByName('riki_tricks_of_the_trade'),true) end
function X.ConsiderAS() return R.Dart(bot,bot:GetAbilityByName('riki_poison_dart')) end
return X
