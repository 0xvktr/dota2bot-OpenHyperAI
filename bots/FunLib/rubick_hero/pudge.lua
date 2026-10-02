local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,MeatHook,Rot,MeatShield,Dismember
local function Refresh()
 bot=GetBot();MeatHook=bot:GetAbilityByName('pudge_meat_hook');Rot=bot:GetAbilityByName('pudge_rot')
 MeatShield=bot:GetAbilityByName('pudge_flesh_heap');Dismember=bot:GetAbilityByName('pudge_dismember')
end
local function ActualRange(ability)
    local range=ability:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(target,pierce)
    return J.IsValid(target) and (pierce and J.CanCastOnMagicImmune(target) or not pierce and J.CanCastOnNonMagicImmune(target))
        and not J.CannotBeKilled(bot,target) and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function HookPoint(target)
    local range=ActualRange(MeatHook)
    local eta=MeatHook:GetCastPoint()+GetUnitToUnitDistance(bot,target)/MeatHook:GetSpecialValueInt('hook_speed')
    local predicted=J.GetCorrectLoc(target,eta)
    local delta=predicted-bot:GetLocation()
    local length=delta:Length2D()
    if length==0 or length>range then return nil end
    local direction=delta:Normalized()
    for _,unit in ipairs(GetUnitList(UNIT_LIST_ALL)) do
        if unit~=bot and unit~=target and J.IsValid(unit) and not unit:IsBuilding() and not unit:IsAncientCreep()
            and not J.IsRoshan(unit) and not string.find(unit:GetUnitName(),'ward') then
            local offset=unit:GetLocation()-bot:GetLocation()
            local forward=offset.x*direction.x+offset.y*direction.y
            local blockLoc=J.GetCorrectLoc(unit,MeatHook:GetCastPoint()+math.max(0,forward)/MeatHook:GetSpecialValueInt('hook_speed'))-bot:GetLocation()
            forward=blockLoc.x*direction.x+blockLoc.y*direction.y
            local side=math.abs(blockLoc.x*direction.y-blockLoc.y*direction.x)
            if forward>0 and forward<length and side<=MeatHook:GetSpecialValueInt('hook_width')+unit:GetBoundingRadius() then return nil end
        end
    end
    return predicted,eta
end
function X.ConsiderMeatHook()
    if not J.CanCastAbility(MeatHook) then return 0 end
    local range=ActualRange(MeatHook)
    if not J.IsLocationInChrono(bot:GetLocation()) and not J.IsLocationInBlackHole(bot:GetLocation()) then
        for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() then
                local trapped=ally:HasModifier('modifier_faceless_void_chronosphere_freeze') or ally:HasModifier('modifier_enigma_black_hole_pull')
                local retreat=J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2) and J.GetHP(ally)<0.4
                    and GetUnitToLocationDistance(bot,J.GetEscapeLoc())+250<GetUnitToLocationDistance(ally,J.GetEscapeLoc())
                if trapped or retreat then local point=HookPoint(ally);if point~=nil then return BOT_ACTION_DESIRE_HIGH,point end end
            end
        end
    end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy,true) then
            local point,eta=HookPoint(enemy)
            if point~=nil and (enemy:IsChanneling() or J.WillKillTarget(enemy,MeatHook:GetSpecialValueInt('damage'),DAMAGE_TYPE_PURE,eta)
                or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and #J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE)<=#J.GetNearbyHeroes(bot,1000,false,BOT_MODE_NONE)+1)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,MeatHook:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
        for _,creep in ipairs(creeps) do
            if J.IsValid(creep) and not creep:IsAncientCreep() and not J.IsRoshan(creep) and not J.IsTormentor(creep)
                and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()+100 then
                local point=HookPoint(creep)
                if point~=nil then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    return 0
end
function X.ConsiderRot()
    if Rot==nil or Rot:IsNull() or Rot:IsHidden() or not Rot:IsActivated() or not Rot:IsTrained() then return 0 end
    local want=false
    if J.GetHP(bot)>0.22 then
        local radius=Rot:GetSpecialValueInt('rot_radius')
        for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
            if Enemy(enemy,false) then want=true;break end
        end
        if not want and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAttacking(bot) and J.GetHP(bot)>0.35 then
            for _,creep in ipairs(bot:GetNearbyCreeps(radius,true)) do if Enemy(creep,false) then want=true;break end end
        end
    end
    if want~=Rot:GetToggleState() then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderMeatShield()
    if not J.CanCastAbility(MeatShield) or bot:HasModifier('modifier_pudge_flesh_heap_block') then return 0 end
    if (Rot~=nil and not Rot:IsNull() and Rot:GetToggleState()) or bot:WasRecentlyDamagedByAnyHero(2) or J.GetAttackProjectileDamageByRange(bot,1000)>80 then return BOT_ACTION_DESIRE_HIGH end
    if bot:IsChanneling() then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderDismember()
    if not J.CanCastAbility(Dismember) then return 0 end
    local range=ActualRange(Dismember)
    local dps=Dismember:GetSpecialValueInt('dismember_damage')+bot:GetAttributeValue(ATTRIBUTE_STRENGTH)*Dismember:GetSpecialValueFloat('strength_damage')
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy,true) and J.CanCastOnTargetAdvanced(enemy) and GetUnitToUnitDistance(bot,enemy)<=range then
            if enemy:IsChanneling() or J.WillKillTarget(enemy,dps*0.5,DAMAGE_TYPE_MAGICAL,Dismember:GetCastPoint()+0.5)
                or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and not J.IsDisabled(enemy))
                or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(bot)<0.3) then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    if J.GetHP(bot)<0.6 and not bot:HasModifier('modifier_ice_blast') and #J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)==0
        and J.IsAllowedToSpam(bot,Dismember:GetManaCost()) then
        for _,creep in ipairs(bot:GetNearbyNeutralCreeps(range)) do
            if Enemy(creep,true) and J.CanCastOnTargetAdvanced(creep) and creep:GetHealth()>dps and GetUnitToUnitDistance(bot,creep)<=range then return BOT_ACTION_DESIRE_HIGH,creep end
        end
    end
    return 0
end
function X.ConsiderDismemberSupport()
    if not bot:IsChanneling() then return false end
    local active=bot:GetCurrentActiveAbility()
    if active==nil or active:GetName()~='pudge_dismember' or not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsSilenced() or bot:IsInvulnerable() or bot:IsCastingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    if X.ConsiderMeatShield()>0 then bot:Action_UseAbility(MeatShield);return true end
    if X.ConsiderRot()>0 then bot:Action_UseAbility(Rot);return true end
    return false
end

function X.ConsiderStolenDismemberSupport()
 local caster=GetBot()
 if not caster:IsChanneling() then return false end
 local active=caster:GetCurrentActiveAbility()
 if active==nil or active:GetName()~='pudge_dismember' then return false end
 Refresh();return X.ConsiderDismemberSupport()
end
function X.ConsiderStolenSpell(ability)
 local name=ability:GetName()
 if name~='pudge_meat_hook' and name~='pudge_rot' and name~='pudge_flesh_heap' and name~='pudge_dismember' then return nil end
 Refresh()
 if J.CanNotUseAbility(bot) or (name~='pudge_rot' and not J.CanCastAbility(ability)) then return false end
 local choices={pudge_meat_hook=X.ConsiderMeatHook,pudge_rot=X.ConsiderRot,pudge_flesh_heap=X.ConsiderMeatShield,pudge_dismember=X.ConsiderDismember}
 local desire,target=choices[name]()
 if desire<=0 then return false end
 if name=='pudge_meat_hook' then bot:Action_UseAbilityOnLocation(ability,target)
 elseif name=='pudge_dismember' then bot:Action_UseAbilityOnEntity(ability,target) else bot:Action_UseAbility(ability) end
 return true
end
return X
