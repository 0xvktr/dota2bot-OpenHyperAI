local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function X.Range(a)
    local range=a:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot)
        if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
    end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
function X.UseGunslinger()
    local gun=bot:GetAbilityByName('muerta_gunslinger')
    if gun==nil or not J.CanCastAbility(gun) or gun:GetToggleState() then return false end
    -- Live Gunslinger ignores silence and invisibility, but cannot interrupt another action.
    if not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsInvulnerable()
        or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    bot:Action_UseAbility(gun);return true
end
function X.DeadShotTarget(a)
    if not J.CanCastAbility(a) then return nil end
    local range=X.Range(a)
    local target=J.GetProperTarget(bot)
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and J.CanCastOnTargetAdvanced(u)
            and not J.IsSuspiciousIllusion(u) and not J.CannotBeKilled(bot,u) then
            local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('speed')
            -- A direct impact slows. Fear belongs to the vector ricochet, not this target.
            if J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay)
                or J.IsGoingOnSomeone(bot) and u==target
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot) then return u end
        end
    end
    if J.IsLaning(bot) and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        for _,creep in pairs(bot:GetNearbyLaneCreeps(range,true)) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and J.IsKeyWordUnit('ranged',creep)
                and J.WillKillTarget(creep,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,
                    a:GetCastPoint()+GetUnitToUnitDistance(bot,creep)/a:GetSpecialValueInt('speed')) then return creep end
        end
    end
    return nil
end
function X.ShouldVeil(a)
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_muerta_pierce_the_veil_buff') then return false end
    if J.IsStunProjectileIncoming(bot,500) then return true end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,bot:GetAttackRange()+150),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) then
            if J.GetHP(bot)<0.5 and bot:WasRecentlyDamagedByAnyHero(2) and u:GetAttackTarget()==bot then return true end
            if not bot:IsDisarmed() and J.CanCastOnNonMagicImmune(u) and not J.CannotBeKilled(bot,u)
                and not u:HasModifier('modifier_item_blade_mail_reflect') and J.IsInRange(bot,u,bot:GetAttackRange())
                and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)) then return true end
        end
    end
    return false
end
function X.CallingPoint(a)
    if not J.CanCastAbility(a) then return nil end
    local range=X.Range(a)
    local radius=a:GetSpecialValueInt('dead_zone_distance')+a:GetSpecialValueInt('hit_radius')
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range+radius),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u)
            and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)) then
            local point=J.GetCorrectLoc(u,a:GetCastPoint()+0.5)
            local delta=point-bot:GetLocation()
            if delta:Length2D()>range then point=bot:GetLocation()+delta:Normalized()*range end
            if GetUnitToLocationDistance(u,point)<radius then return point end
        end
    end
    return nil
end
function X.SlugTarget(a)
    if not J.CanCastAbility(a) then return nil end
    local veil=bot:GetAbilityByName('muerta_pierce_the_veil')
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and J.CanCastOnTargetAdvanced(u)
            and not J.IsSuspiciousIllusion(u) and not u:HasModifier('modifier_muerta_spectral_slug_ethereal')
            and not J.CannotBeKilled(bot,u) then
            local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('projectile_speed')
            if J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay)
                or J.IsRetreating(bot) and u:GetAttackTarget()==bot and not u:IsDisarmed()
                or veil~=nil and veil:IsTrained() and J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                    and J.IsInRange(bot,u,bot:GetAttackRange()) then return u end
        end
    end
    return nil
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='muerta_dead_shot' and name~='muerta_the_calling' and name~='muerta_gunslinger'
        and name~='muerta_pierce_the_veil' and name~='muerta_spectral_slug' then return nil end
    if name=='muerta_gunslinger' then return X.UseGunslinger() end
    if J.CanNotUseAbility(bot) then return false end
    local target
    if name=='muerta_pierce_the_veil' then
        if not X.ShouldVeil(a) then return false end
        J.SetQueuePtToINT(bot,true,a);bot:ActionQueue_UseAbility(a);return true
    elseif name=='muerta_the_calling' then
        local point=X.CallingPoint(a)
        if point==nil then return false end
        J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbilityOnLocation(a,point);return true
    elseif name=='muerta_dead_shot' then target=X.DeadShotTarget(a)
    else target=X.SlugTarget(a) end
    if target==nil then return false end
    J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbilityOnEntity(a,target);return true
end
return X
