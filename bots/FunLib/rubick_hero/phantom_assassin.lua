local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,abilityQ,abilityW,abilityE,abilityAS
local function Refresh()
 bot=GetBot();abilityQ=bot:GetAbilityByName('phantom_assassin_stifling_dagger');abilityW=bot:GetAbilityByName('phantom_assassin_phantom_strike')
 abilityE=bot:GetAbilityByName('phantom_assassin_blur');abilityAS=bot:GetAbilityByName('phantom_assassin_fan_of_knives')
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

function X.ConsiderStolenSpell(ability)
 local name=ability:GetName()
 if name~='phantom_assassin_stifling_dagger' and name~='phantom_assassin_phantom_strike' and name~='phantom_assassin_blur' and name~='phantom_assassin_fan_of_knives' then return nil end
 Refresh()
 if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
 local choices={phantom_assassin_stifling_dagger=X.ConsiderQ,phantom_assassin_phantom_strike=X.ConsiderW,phantom_assassin_blur=X.ConsiderE,phantom_assassin_fan_of_knives=X.ConsiderAS}
 local desire,target=choices[name]()
 if desire<=0 then return false end
 if name=='phantom_assassin_stifling_dagger' or name=='phantom_assassin_phantom_strike' then bot:Action_UseAbilityOnEntity(ability,target) else bot:Action_UseAbility(ability) end
 return true
end
return X
