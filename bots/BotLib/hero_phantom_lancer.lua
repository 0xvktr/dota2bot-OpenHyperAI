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

-- Updated to 7.41f from D2PT: carry; forced roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/phantom_lancer')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Spirit Lance, [2] Doppelganger, [3] Phantom Rush, [6] Juxtapose.
local nAbilityBuildList = {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +3% Juxtapose illusion trigger chance
    t15={0,10}, -- 50% illusion Spirit Lance damage
    t20={0,10}, -- +100 Spirit Lance damage
    t25={0,10}, -- -4s Doppelganger cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_1 = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_power_treads','item_yasha','item_manta','item_ultimate_scepter',
    'item_skadi','item_orchid','item_aghanims_shard','item_bloodthorn',
    -- Bot policy: consume Scepter before the observed late Heart and Butterfly.
    'item_ultimate_scepter_2','item_heart','item_butterfly','item_moon_shard',
}
for role=2,5 do sRoleItemsBuyList['pos_'..role] = sRoleItemsBuyList.pos_1 end
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {'item_manta','item_magic_wand','item_skadi','item_quelling_blade'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_PL'}, {'item_power_treads','item_quelling_blade'} end

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
		if hMinionUnit:IsIllusion() then hMinionUnit.isIllusion = true end
		if hMinionUnit:HasModifier( 'modifier_phantom_lancer_phantom_edge_boost' ) then return end

		Minion.IllusionThink( hMinionUnit )
	end

end



local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


function X.SkillsComplement()
    if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_phantom_lancer_phantom_edge_boost') then return end
    local desire,point=X.ConsiderW()
    if desire>0 then J.SetQueuePtToINT(bot,false,abilityW);bot:ActionQueue_UseAbilityOnLocation(abilityW,point);return end
    if X.ConsiderR()>0 then J.SetQueuePtToINT(bot,false);bot:ActionQueue_UseAbility(abilityR);return end
    if X.ConsiderRushToggle()>0 then bot:Action_UseAbility(abilityE);return end
    local desire,target=X.ConsiderQ()
    if desire>0 then J.SetQueuePtToINT(bot,true);bot:ActionQueue_UseAbilityOnEntity(abilityQ,target) end
end

local function ActualRange(ability)
    local range=ability:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function MobilityBlocked()
    return bot:IsRooted() or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled')
        or bot:HasModifier('modifier_grimstroke_soul_chain') or bot:HasModifier('modifier_bloodseeker_rupture')
end
local function SafePoint(point,scatter)
    if not IsLocationPassable(point) then return false end
    for _,offset in ipairs({Vector(0,0),Vector(scatter,0),Vector(-scatter,0),Vector(0,scatter),Vector(0,-scatter)}) do
        local p=point+offset
        if J.IsLocationInChrono(p) or J.IsLocationInBlackHole(p) or J.IsLocHaveTower(700,true,p) then return false end
    end
    return true
end
local function PointToward(location,range)
    local delta=location-bot:GetLocation()
    if delta:Length2D()==0 then return bot:GetLocation() end
    return bot:GetLocation()+delta:Normalized()*math.min(range,delta:Length2D())
end
function X.ConsiderW()
    if not J.CanCastAbility(abilityW) or MobilityBlocked() then return 0 end
    local incoming=J.IsUnitTargetProjectileIncoming(bot,600) or J.GetAttackProjectileDamageByRange(bot,1000)>=bot:GetHealth()
    local dispel=bot:HasModifier('modifier_item_dustofappearance') or bot:HasModifier('modifier_item_spirit_vessel_damage')
        or bot:HasModifier('modifier_silence') or bot:HasModifier('modifier_item_orchid_malevolence_debuff')
        or bot:HasModifier('modifier_item_bloodthorn_debuff') or bot:HasModifier('modifier_life_stealer_open_wounds')
    if incoming or dispel or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) then
        local range=ActualRange(abilityW)
        local scatter=abilityW:GetSpecialValueInt('target_aoe')
        for _,distance in ipairs({range,range*0.65,range*0.3,0}) do
            local point=PointToward(J.GetEscapeLoc(),distance)
            if SafePoint(point,scatter) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0
end
function X.ConsiderR()
    if not J.CanCastAbility(abilityR) or abilityR:IsPassive() or bot:IsInvisible() then return 0 end
    if (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) or J.IsUnitTargetProjectileIncoming(bot,600)
        or (J.GetHP(bot)<0.35 and #J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)>0) then return BOT_ACTION_DESIRE_HIGH end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and GetUnitToUnitDistance(bot,target)>600
        and GetUnitToUnitDistance(bot,target)<=1600 and #J.GetNearbyHeroes(bot,500,true,BOT_MODE_NONE)==0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) or bot:IsInvisible() then return 0 end
    local range=ActualRange(abilityQ)
    local damage=abilityQ:GetSpecialValueInt('lance_damage')
    local function legal(target) return J.IsValid(target) and J.CanCastOnNonMagicImmune(target) and J.CanCastOnTargetAdvanced(target)
        and GetUnitToUnitDistance(bot,target)<=range and not J.CannotBeKilled(bot,target)
        and not target:HasModifier('modifier_nyx_assassin_spiked_carapace') and not target:HasModifier('modifier_item_blade_mail_reflect') end
    local function lethal(target) return J.WillKillTarget(target,damage,DAMAGE_TYPE_MAGICAL,abilityQ:GetCastPoint()+GetUnitToUnitDistance(bot,target)/abilityQ:GetSpecialValueInt('lance_speed')) end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do if legal(enemy) and lethal(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and legal(target) then return BOT_ACTION_DESIRE_HIGH,target end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do if legal(enemy) and J.IsChasingTarget(enemy,bot) then return BOT_ACTION_DESIRE_HIGH,enemy end end
    end
    if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        if J.IsAllowedToSpam(bot,abilityQ:GetManaCost()+(J.CanCastAbility(abilityW) and abilityW:GetManaCost() or 0)) then
            for _,creep in ipairs(bot:GetNearbyLaneCreeps(range,true)) do
                if legal(creep) and not creep:HasModifier('modifier_fountain_glyph') and lethal(creep)
                    and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()+100 then return BOT_ACTION_DESIRE_HIGH,creep end
            end
            if J.IsFarming(bot) and legal(target) and not J.IsValidHero(target) and target:GetHealth()>damage+bot:GetAttackDamage()
                and bot:GetMana()/bot:GetMaxMana()>0.65 then return BOT_ACTION_DESIRE_HIGH,target end
        end
    end
    return 0
end
function X.ConsiderRushToggle()
    if abilityE==nil or not abilityE:IsTrained() or bot:HasModifier('modifier_phantom_lancer_phantom_edge_boost') then return 0 end
    local disable=J.IsLaning(bot) or J.IsRetreating(bot) or MobilityBlocked()
    if disable~=abilityE:GetToggleState() then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

return X
