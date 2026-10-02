local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function X.Range(a)
    local range=a:GetCastRange()
    for slot=0,5 do
        local item=bot:GetItemInSlot(slot)
        if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
    end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    local innate=bot:GetAbilityByName('morphling_ebb_and_flow')
    if innate~=nil and innate:IsTrained() and not J.HasBreakModifier(bot) then
        range=range+bot:GetAttributeValue(ATTRIBUTE_STRENGTH)*innate:GetSpecialValueInt('cast_range_per_str')/100
    end
    return range
end
function X.Clamp(point,a)
    local delta=point-bot:GetLocation()
    if delta:Length2D()>X.Range(a) then return bot:GetLocation()+delta:Normalized()*X.Range(a) end
    return point
end
function X.AdaptiveTarget(a,urgent)
    if not J.CanCastAbility(a) then return nil end
    local range=X.Range(a)
    local agility=bot:GetAttributeValue(ATTRIBUTE_AGILITY)
    local strength=bot:GetAttributeValue(ATTRIBUTE_STRENGTH)
    -- The thresholds are verified; intermediate scaling is conservatively estimated at the minimum.
    local multiplier=a:GetSpecialValueFloat(agility>=strength*1.5 and 'damage_max' or 'damage_min')
    local damage=a:GetSpecialValueInt('damage_base')+agility*multiplier
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and J.CanCastOnTargetAdvanced(u)
            and not J.IsSuspiciousIllusion(u) then
            local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('projectile_speed')
            if u:IsChanneling() or u:HasModifier('modifier_teleporting') then return u end
            if not urgent and not J.CannotBeKilled(bot,u) and (J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,delay)
                or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)) then return u end
        end
    end
    return nil
end
function X.UseStrengthShift()
    local shift=bot:GetAbilityByName('morphling_morph_str')
    if shift==nil or not shift:IsTrained() then return false end
    if not bot:IsAlive() or bot:IsSilenced() or bot:IsHexed() or bot:IsNightmared() or bot:IsInvulnerable()
        or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    if bot:IsStunned() and shift:GetSpecialValueInt('castable_while_stunned')==0 then return false end
    if shift:GetToggleState() or not J.CanCastAbility(shift) then return false end
    if J.GetHP(bot)<0.4 and (bot:WasRecentlyDamagedByAnyHero(1) or J.IsStunProjectileIncoming(bot,500)) then
        bot:Action_UseAbility(shift);return true
    end
    return false
end
function X.WavePoint(a)
    if not J.CanCastAbility(a) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') then return nil end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) or J.IsStunProjectileIncoming(bot,500) then
        return X.Clamp(J.GetTeamFountain(),a)
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnNonMagicImmune(target)
        and not J.CannotBeKilled(bot,target) and not J.IsInRange(bot,target,bot:GetAttackRange())
        and #J.GetAlliesNearLoc(target:GetLocation(),1000)>=#J.GetEnemiesNearLoc(target:GetLocation(),1000) then
        local point=J.GetCorrectLoc(target,a:GetCastPoint()+GetUnitToUnitDistance(bot,target)/a:GetSpecialValueInt('speed'))
        if GetUnitToLocationDistance(bot,point)<=X.Range(a)+a:GetSpecialValueInt('width') and IsLocationPassable(X.Clamp(point,a)) then
            return X.Clamp(point,a)
        end
    end
    return nil
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='morphling_waveform' and name~='morphling_adaptive_strike_agi' and name~='morphling_morph_str'
        and name~='morphling_morph_agi' and name~='morphling_replicate' and name~='morphling_morph_replicate' then return nil end
    if name=='morphling_morph_str' then return X.UseStrengthShift() end
    if J.CanNotUseAbility(bot) then return false end
    if name=='morphling_adaptive_strike_agi' then
        local target=X.AdaptiveTarget(a,false)
        if target==nil then return false end
        J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbilityOnEntity(a,target);return true
    elseif name=='morphling_waveform' then
        local point=X.WavePoint(a)
        if point==nil then return false end
        J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbilityOnLocation(a,point);return true
    end
    -- Agility shifting and form swaps require native attribute/form management.
    return false
end
return X
