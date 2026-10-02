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
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/phantom_assassin')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Dagger, [2] Phantom Strike, [5] Immaterial, [6] Coup de Grace.
local nAbilityBuildList = {1,2,1,2,1,6,1,2,2,5,6,5,5,5,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +0.8s Phantom Strike duration
    t15={0,10}, -- +20% Immaterial evasion
    t20={10,0}, -- +60 Phantom Strike attack speed
    t25={10,0}, -- Triple Strike Stifling Dagger
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_1 = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_power_treads','item_bfury','item_desolator','item_black_king_bar',
    'item_basher','item_lifesteal','item_aghanims_shard','item_satanic','item_abyssal_blade',
    -- Bot policy: consumed attack speed after the observed six-slot inventory.
    'item_moon_shard',
}
for role=2,5 do sRoleItemsBuyList['pos_'..role] = sRoleItemsBuyList.pos_1 end
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {'item_bfury','item_magic_wand','item_desolator','item_quelling_blade'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_PA'}, {'item_power_treads','item_quelling_blade'} end

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



local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )
local Immaterial = bot:GetAbilityByName('phantom_assassin_immaterial')


local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire
local castASDesire, castASTarget


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive


local lastSkillCreep

function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) then return end

	nKeepMana = 300
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	castEDesire = X.ConsiderE()
	if castEDesire > 0
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityE )
		return

	end
	
	castASDesire = X.ConsiderAS()
	if castASDesire > 0
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityAS )
		return

	end

	castQDesire, castQTarget = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ , castQTarget )
		return
	end

	castWDesire, castWTarget = X.ConsiderW()
	if castWDesire > 0
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnEntity( abilityW , castWTarget )
		return
	end


end


local function ActualRange(ability)
    local range=ability:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function PhysicalTarget(target)
    return J.IsValid(target) and J.CanCastOnMagicImmune(target) and J.CanBeAttacked(target)
        and not target:HasModifier('modifier_ghost_state') and not target:HasModifier('modifier_item_ethereal_blade_ethereal')
        and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
        and not J.CannotBeKilled(bot,target)
end
local function BlinkBlocked()
    return bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_slark_pounce_leash')
        or bot:HasModifier('modifier_puck_coiled') or bot:HasModifier('modifier_grimstroke_soul_chain')
end
function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    local range=ActualRange(abilityQ)
    local damage=abilityQ:GetSpecialValueInt('base_damage')+bot:GetAttackDamage()*abilityQ:GetSpecialValueInt('attack_factor_tooltip')/100
    local function legal(target) return PhysicalTarget(target) and GetUnitToUnitDistance(bot,target)<=range and J.CanCastOnTargetAdvanced(target) end
    local function lethal(target) return J.WillKillTarget(target,damage,DAMAGE_TYPE_PHYSICAL,abilityQ:GetCastPoint()+GetUnitToUnitDistance(bot,target)/abilityQ:GetSpecialValueInt('dagger_speed')) end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if legal(enemy) and lethal(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and legal(target) then return BOT_ACTION_DESIRE_HIGH,target end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
            if legal(enemy) and not enemy:IsMagicImmune() and J.IsChasingTarget(enemy,bot) then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,abilityQ:GetManaCost()) then
        local creeps=bot:GetNearbyLaneCreeps(range,true)
        for _,creep in ipairs(creeps) do
            if legal(creep) and lethal(creep) and (J.IsLaning(bot) or GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()+100) then return BOT_ACTION_DESIRE_HIGH,creep end
        end
        if J.IsFarming(bot) and legal(target) and bot:GetMana()/bot:GetMaxMana()>0.5 then return BOT_ACTION_DESIRE_HIGH,target end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and (J.IsRoshan(target) or J.IsTormentor(target)) and legal(target) then return BOT_ACTION_DESIRE_HIGH,target end
    return 0
end
function X.ConsiderW()
    if not J.CanCastAbility(abilityW) or abilityW:GetCurrentCharges()<=0 or BlinkBlocked() then return 0 end
    local range=ActualRange(abilityW)
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        local best,bestDistance=nil,GetUnitToLocationDistance(bot,J.GetEscapeLoc())-200
        local candidates=J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)
        for _,creep in ipairs(bot:GetNearbyLaneCreeps(range,false)) do candidates[#candidates+1]=creep end
        for _,ally in ipairs(candidates) do
            if J.IsValid(ally) and not ally:IsInvulnerable() and GetUnitToUnitDistance(bot,ally)<=range
                and not J.IsLocationInChrono(ally:GetLocation()) and not J.IsLocationInBlackHole(ally:GetLocation()) then
                local distance=GetUnitToLocationDistance(ally,J.GetEscapeLoc())
                if distance<bestDistance then best,bestDistance=ally,distance end
            end
        end
        if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    end
    if bot:IsDisarmed() or bot:HasModifier('modifier_phantom_assassin_phantom_strike') then return 0 end
    local target=J.GetProperTarget(bot)
    if PhysicalTarget(target) and GetUnitToUnitDistance(bot,target)<=range and J.CanCastOnTargetAdvanced(target)
        and not J.IsLocationInChrono(target:GetLocation()) and not J.IsLocationInBlackHole(target:GetLocation()) then
        if J.IsGoingOnSomeone(bot) and J.IsValidHero(target)
            and not J.IsLocHaveTower(700,true,target:GetLocation())
            and #J.GetNearbyHeroes(target,1000,true,BOT_MODE_NONE)<=#J.GetNearbyHeroes(target,1000,false,BOT_MODE_NONE)+1 then return BOT_ACTION_DESIRE_HIGH,target end
        if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and (J.IsRoshan(target) or J.IsTormentor(target)) then return BOT_ACTION_DESIRE_HIGH,target end
        if J.IsFarming(bot) and not J.IsValidHero(target) and target:GetHealth()>bot:GetAttackDamage()*2
            and bot:GetMana()/bot:GetMaxMana()>0.5 and abilityW:GetCurrentCharges()>=2 then return BOT_ACTION_DESIRE_HIGH,target end
    end
    return 0
end
function X.ConsiderE()
    if not J.CanCastAbility(abilityE) or bot:HasModifier('modifier_phantom_assassin_blur_active') then return 0 end
    if J.IsUnitTargetProjectileIncoming(bot,600) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsFarming(bot) or J.IsPushing(bot)) and J.IsAttacking(bot) and J.IsAllowedToSpam(bot,abilityE:GetManaCost())
        and #J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)==0 then return BOT_ACTION_DESIRE_HIGH end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and GetUnitToUnitDistance(bot,target)>abilityE:GetSpecialValueInt('radius')
        and J.CanCastAbility(abilityW) and bot:GetMana()>=abilityE:GetManaCost()+abilityW:GetManaCost() then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderAS()
    if not J.CanCastAbility(abilityAS) or abilityAS:IsHidden() then return 0 end
    local radius=abilityAS:GetSpecialValueInt('radius')
    local count=0
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
        if PhysicalTarget(enemy) and GetUnitToLocationDistance(bot,J.GetCorrectLoc(enemy,abilityAS:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/abilityAS:GetSpecialValueInt('projectile_speed')))<=radius then
            local damage=enemy:GetMaxHealth()*abilityAS:GetSpecialValueInt('pct_health_damage_initial')/100
            if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_PHYSICAL,abilityAS:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/abilityAS:GetSpecialValueInt('projectile_speed')) then return BOT_ACTION_DESIRE_HIGH end
            count=count+1
            if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if count>=2 or (count>0 and J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

return X
