local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,IcarusDive,IcarusDiveStop,FireSpirits,FireSpiritsLaunch,SunRay,SunRayStop,ToggleMovement,Supernova
local function Refresh()
 bot=GetBot();IcarusDive=bot:GetAbilityByName('phoenix_icarus_dive');IcarusDiveStop=bot:GetAbilityByName('phoenix_icarus_dive_stop')
 FireSpirits=bot:GetAbilityByName('phoenix_fire_spirits');FireSpiritsLaunch=bot:GetAbilityByName('phoenix_launch_fire_spirit')
 SunRay=bot:GetAbilityByName('phoenix_sun_ray');SunRayStop=bot:GetAbilityByName('phoenix_sun_ray_stop')
 ToggleMovement=bot:GetAbilityByName('phoenix_sun_ray_toggle_move');Supernova=bot:GetAbilityByName('phoenix_supernova')
end
local function ActualRange(ability)
    local range=ability:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(target)
    return J.IsValid(target) and J.CanCastOnNonMagicImmune(target) and not J.CannotBeKilled(bot,target)
        and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function SafePoint(point)
    return not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point) and not J.IsLocHaveTower(700,true,point)
end
local function Toward(location,range)
    local delta=location-bot:GetLocation()
    return delta:Length2D()==0 and bot:GetLocation() or bot:GetLocation()+delta:Normalized()*math.min(range,delta:Length2D())
end
local function SpiritPoint(ability,target)
    local range=ActualRange(ability)
    local eta=ability:GetCastPoint()+GetUnitToUnitDistance(bot,target)/ability:GetSpecialValueInt('spirit_speed')
    local predicted=J.GetCorrectLoc(target,eta)
    local point=Toward(predicted,range)
    if (point-predicted):Length2D()>ability:GetSpecialValueInt('radius') then return nil end
    if target:HasModifier('modifier_phoenix_fire_spirit_burn') then
        local index=target:GetModifierByName('modifier_phoenix_fire_spirit_burn')
        if index>=0 and target:GetModifierRemainingDuration(index)>eta+0.2 then return nil end
    end
    local pending=bot.phoenixSpiritPending
    if pending~=nil and pending.target==target and DotaTime()<pending.untilTime then return nil end
    return point,eta
end
local function SpiritOpportunity(ability)
    local range=ActualRange(ability)+ability:GetSpecialValueInt('radius')
    local target=J.GetProperTarget(bot)
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy) then
            local point,eta=SpiritPoint(ability,enemy)
            if point~=nil then
                local lethal=J.WillKillTarget(enemy,ability:GetSpecialValueInt('damage_per_second')*ability:GetSpecialValueFloat('duration'),DAMAGE_TYPE_MAGICAL,eta+ability:GetSpecialValueFloat('duration'))
                if lethal or (J.IsGoingOnSomeone(bot) and (enemy==target or enemy:GetAttackTarget()==bot))
                    or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) or J.IsInTeamFight(bot,1200) then return point,enemy,eta end
            end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,100) then
        local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
        for _,creep in ipairs(creeps) do
            if Enemy(creep) then
                local point,eta=SpiritPoint(ability,creep)
                if point~=nil then
                    local count=0
                    for _,other in ipairs(creeps) do if Enemy(other) and (J.GetCorrectLoc(other,eta)-point):Length2D()<=ability:GetSpecialValueInt('radius') then count=count+1 end end
                    if count>=3 then return point,creep,eta end
                end
            end
        end
    end
    return nil
end
function X.ConsiderFireSpirits()
    if not J.CanCastAbility(FireSpirits) or bot:HasModifier('modifier_phoenix_supernova_hiding')
        or bot:HasModifier('modifier_phoenix_fire_spirit_count') or J.GetHP(bot)*(1-FireSpirits:GetSpecialValueInt('hp_cost_perc')/100)<0.25 then return 0 end
    if SpiritOpportunity(FireSpirits)~=nil then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderFireSpiritsLaunch()
    if not J.CanCastAbility(FireSpiritsLaunch) or bot:HasModifier('modifier_phoenix_supernova_hiding') then return 0 end
    local point,target,eta=SpiritOpportunity(FireSpiritsLaunch)
    if point~=nil then return BOT_ACTION_DESIRE_HIGH,point,target,eta end
    return 0
end
function X.ConsiderIcarusDive()
    if not J.CanCastAbility(IcarusDive) or bot:IsRooted() or bot:HasModifier('modifier_phoenix_icarus_dive')
        or bot:HasModifier('modifier_phoenix_supernova_hiding') or bot:HasModifier('modifier_bloodseeker_rupture')
        or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled') then return 0 end
    local range=IcarusDive:GetSpecialValueInt('dash_length')
    local health=J.GetHP(bot)*(1-IcarusDive:GetSpecialValueInt('hp_cost_perc')/100)
    if (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) or J.IsStuck(bot) then
        local point=Toward(J.GetEscapeLoc(),range)
        if health>0.12 and SafePoint(point) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsValidHero(target) and health>0.4
        and GetUnitToUnitDistance(bot,target)>400 and GetUnitToUnitDistance(bot,target)<=range
        and SafePoint(target:GetLocation()) and #J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)<=#J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)+1 then return BOT_ACTION_DESIRE_HIGH,target:GetLocation() end
    return 0
end
function X.ConsiderIcarusDiveStop()
    if not J.CanCastAbility(IcarusDiveStop) or not bot:HasModifier('modifier_phoenix_icarus_dive') then return 0 end
    if bot:HasModifier('modifier_bloodseeker_rupture') then return BOT_ACTION_DESIRE_HIGH end
    local goal=bot.phoenixDiveGoal
    if goal~=nil and GetUnitToLocationDistance(bot,goal)<=175 and SafePoint(bot:GetLocation()) and IsLocationPassable(bot:GetLocation()) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local function RayTarget()
    local range=SunRay:GetCastRange()
    if J.GetHP(bot)<0.35 and not bot:HasModifier('modifier_phoenix_supernova_hiding') then return nil end
    for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:HasModifier('modifier_ice_blast')
            and ally:GetMaxHealth()-ally:GetHealth()>=150 and (J.GetHP(ally)<0.6 or ally:WasRecentlyDamagedByAnyHero(2)) then return ally end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsValidHero(target) and GetUnitToUnitDistance(bot,target)<=range then return target end
    return nil
end
function X.ConsiderSunRay()
    if not J.CanCastAbility(SunRay) or bot:HasModifier('modifier_phoenix_sun_ray') or bot:HasModifier('modifier_phoenix_icarus_dive') then return 0 end
    local target=RayTarget()
    if target~=nil then bot.phoenixRayTarget=target;bot.sun_ray_target=target;return BOT_ACTION_DESIRE_HIGH,J.GetCorrectLoc(target,SunRay:GetCastPoint()) end
    return 0
end
function X.ConsiderSunRayStop()
    if not J.CanCastAbility(SunRayStop) or not bot:HasModifier('modifier_phoenix_sun_ray') or bot:HasModifier('modifier_phoenix_supernova_hiding') then return 0 end
    if J.GetHP(bot)<0.2 then return BOT_ACTION_DESIRE_HIGH end
    local target=bot.phoenixRayTarget
    if target~=nil and (not J.IsValidHero(target) or target:GetTeam()~=bot:GetTeam() and not Enemy(target)
        or target:GetTeam()==bot:GetTeam() and (J.GetHP(target)>0.9 or target:HasModifier('modifier_ice_blast'))
        or GetUnitToUnitDistance(bot,target)>(SunRay~=nil and SunRay:GetCastRange() or 1200)+200) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderToggleMovement()
    if not J.CanCastAbility(ToggleMovement) or not bot:HasModifier('modifier_phoenix_sun_ray') or bot:HasModifier('modifier_phoenix_supernova_hiding') then return 0 end
    local target=bot.phoenixRayTarget
    local move=not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture') and J.IsValidHero(target)
        and GetUnitToUnitDistance(bot,target)>900 and bot:IsFacingLocation(target:GetLocation(),20)
        and SafePoint(bot:GetLocation()+Vector(math.cos(bot:GetFacing()*math.pi/180),math.sin(bot:GetFacing()*math.pi/180),0)*250)
    if move~=ToggleMovement:GetToggleState() then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local function EggSafe()
    local limit=Supernova:GetSpecialValueInt(bot:HasScepter() and 'max_hero_attacks_scepter' or 'max_hero_attacks')
    local attacks=0
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not enemy:IsIllusion() and not enemy:IsDisarmed() then
            local delay=math.max(0,GetUnitToUnitDistance(bot,enemy)-enemy:GetAttackRange())/math.max(1,enemy:GetCurrentMovementSpeed())
            attacks=attacks+math.max(0,6-delay)/math.max(0.2,enemy:GetSecondsPerAttack())
        end
    end
    return attacks<limit
end
function X.ConsiderSupernova()
    if not J.CanCastAbility(Supernova) or bot:HasModifier('modifier_phoenix_supernova_hiding') then return 0 end
    if not EggSafe() then return 0 end
    if bot:HasScepter() then
        for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(ActualRange(Supernova),1600),false,BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and GetUnitToUnitDistance(bot,ally)<=ActualRange(Supernova)
                and J.GetHP(ally)<0.25 and ally:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH,ally end
        end
    end
    if J.GetHP(bot)<0.3 and bot:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
    local enemies=J.GetNearbyHeroes(bot,math.min(Supernova:GetSpecialValueInt('aura_radius'),1600),true,BOT_MODE_NONE)
    if #enemies>=2 and J.IsInTeamFight(bot,1200) and #J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)>=1 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderEggSunRay()
    if not bot:HasModifier('modifier_phoenix_supernova_hiding') or not bot:HasModifier('modifier_item_aghanims_shard')
        or not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsSilenced() or bot:IsChanneling()
        or bot:IsCastingAbility() or bot:IsUsingAbility() or J.HasQueuedAction(bot) or bot:IsNightmared()
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local desire,point=X.ConsiderSunRay()
    if desire>0 then bot:Action_UseAbilityOnLocation(SunRay,point);return true end
    return false
end

function X.ConsiderStolenEggSunRay()
 local caster=GetBot()
 if not caster:HasModifier('modifier_phoenix_supernova_hiding') or not caster:HasModifier('modifier_item_aghanims_shard') then return false end
 Refresh();return X.ConsiderEggSunRay()
end
function X.ConsiderStolenSpell(ability)
 local name=ability:GetName()
 local names={phoenix_icarus_dive=true,phoenix_icarus_dive_stop=true,phoenix_fire_spirits=true,phoenix_launch_fire_spirit=true,
 phoenix_sun_ray=true,phoenix_sun_ray_stop=true,phoenix_sun_ray_toggle_move=true,phoenix_supernova=true}
 if not names[name] then return nil end
 Refresh()
 if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
 local choices={phoenix_icarus_dive=X.ConsiderIcarusDive,phoenix_icarus_dive_stop=X.ConsiderIcarusDiveStop,phoenix_fire_spirits=X.ConsiderFireSpirits,
 phoenix_launch_fire_spirit=X.ConsiderFireSpiritsLaunch,phoenix_sun_ray=X.ConsiderSunRay,phoenix_sun_ray_stop=X.ConsiderSunRayStop,
 phoenix_sun_ray_toggle_move=X.ConsiderToggleMovement,phoenix_supernova=X.ConsiderSupernova}
 local desire,point,target,eta=choices[name]()
 if desire<=0 then return false end
 if name=='phoenix_icarus_dive' then bot.phoenixDiveGoal=point end
 if name=='phoenix_launch_fire_spirit' then bot.phoenixSpiritPending={target=target,untilTime=DotaTime()+eta+0.2} end
 if name=='phoenix_supernova' and point~=nil then bot:Action_UseAbilityOnEntity(ability,point)
 elseif name=='phoenix_icarus_dive' or name=='phoenix_launch_fire_spirit' or name=='phoenix_sun_ray' then bot:Action_UseAbilityOnLocation(ability,point)
 else bot:Action_UseAbility(ability) end
 return true
end
return X
