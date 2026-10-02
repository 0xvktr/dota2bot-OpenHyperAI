local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local function OwnMeepos()
    local out={}
    for _,u in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if J.IsValidHero(u) and u:GetUnitName()=='npc_dota_hero_meepo' and not u:IsIllusion()
            and u:GetPlayerID()==bot:GetPlayerID() then out[#out+1]=u end
    end
    return out
end
local function Range(a)
    local lens=J.IsItemAvailable('item_aether_lens')
    local r=a:GetCastRange()+(lens~=nil and lens:GetSpecialValueInt('cast_range_bonus') or 0)
    local sup=bot:GetAbilityByName('rubick_arcane_supremacy')
    if sup~=nil and sup:IsTrained() and not J.HasBreakModifier(bot) then r=r+sup:GetSpecialValueInt('cast_range') end
    return r
end
function X.DigUseful(a)
    return J.CanCastAbility(a) and not bot:IsRooted() and J.GetHP(bot)<0.4
        and (bot:WasRecentlyDamagedByAnyHero(2) or J.IsRetreating(bot))
        and not bot:HasModifier('modifier_meepo_petrify')
end
function X.MegaUseful(a)
    if not J.CanCastAbility(a) or J.IsMeepoClone(bot) or bot:HasModifier('modifier_meepo_megameepo_self') then return false end
    for _,u in pairs(OwnMeepos()) do
        if u~=bot and J.IsInRange(bot,u,a:GetSpecialValueInt('radius')) and not u:HasModifier('modifier_meepo_petrify')
            and J.GetHP(u)<0.4 and u:WasRecentlyDamagedByAnyHero(2) then return true end
    end
    return false
end
function X.NetPoint(a,urgent)
    if not J.CanCastAbility(a) then return nil end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,Range(a)+a:GetSpecialValueInt('radius')),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u)
            and (u:IsChanneling() or not urgent and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot))) then
            local eta=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('speed')
            if J.GetModifierTime(u,'modifier_meepo_earthbind')<=eta then
                local point=J.GetCorrectLoc(u,eta)
                if GetUnitToLocationDistance(bot,point)<=Range(a)+a:GetSpecialValueInt('radius') then
                    if GetUnitToLocationDistance(bot,point)>Range(a) then point=bot:GetLocation()+(point-bot:GetLocation()):Normalized()*Range(a) end
                    local covered=false
                    for _,member in pairs(OwnMeepos()) do
                        local cast=member.earth_bind_cast
                        if member~=bot and cast~=nil and GameTime()+eta<cast.time+(cast.flight or 0)+a:GetSpecialValueFloat('duration')
                            and (point-cast.location):Length2D()<a:GetSpecialValueInt('radius') then covered=true end
                    end
                    if not covered then return point end
                end
            end
        end
    end
    return nil
end
function X.PoofTarget(a)
    if not J.CanCastAbility(a) or a:GetAutoCastState() or bot:IsRooted() or J.IsStunProjectileIncoming(bot,500) then return nil end
    if J.IsRetreating(bot) and J.GetHP(bot)<0.5 then
        for _,u in pairs(OwnMeepos()) do
            if u~=bot and not u:IsInvulnerable() and J.GetHP(u)>0.5
                and u:DistanceFromFountain()<800 and #J.GetNearbyHeroes(u,900,true,BOT_MODE_NONE)==0 then return u end
        end
        return nil
    end
    local target=J.GetProperTarget(bot)
    local radius=a:GetSpecialValueInt('radius')
    if J.GetHP(bot)>0.5 and J.IsGoingOnSomeone(bot) and J.IsValidHero(target)
        and J.CanCastOnNonMagicImmune(target) and not J.IsSuspiciousIllusion(target)
        and J.IsDisabled(target) and J.GetModifierTime(target,'modifier_meepo_earthbind')>=a:GetSpecialValueFloat('cast_duration') then
        if J.IsInRange(bot,target,radius) then return bot end
        for _,u in pairs(OwnMeepos()) do
            if u~=bot and J.GetHP(u)>0.5 and J.IsInRange(u,target,radius)
                and #J.GetNearbyHeroes(u,900,true,BOT_MODE_NONE)<=#J.GetNearbyHeroes(u,900,false,BOT_MODE_NONE)+1 then return u end
        end
    end
    if J.IsAttacking(bot) and J.IsAllowedToSpam(bot,a:GetManaCost()) and not bot:WasRecentlyDamagedByAnyHero(2)
        and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and (#bot:GetNearbyLaneCreeps(radius,true)>=3 or #bot:GetNearbyNeutralCreeps(radius)>=2) then return bot end
    if J.IsLaning(bot) and not bot:WasRecentlyDamagedByAnyHero(2) then
        local count=0
        for _,u in pairs(bot:GetNearbyLaneCreeps(radius,true)) do
            if J.IsValid(u) and J.WillKillTarget(u,a:GetSpecialValueInt('poof_damage')*2,DAMAGE_TYPE_MAGICAL,a:GetSpecialValueFloat('cast_duration')) then count=count+1 end
        end
        if count>=2 then return bot end
    end
    return nil
end
function X.FlingTarget(a)
    if not J.CanCastAbility(a) or not bot:HasModifier('modifier_meepo_megameepo_self') then return nil end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnNonMagicImmune(target)
        and not J.IsSuspiciousIllusion(target) and not target:HasModifier('modifier_item_sphere_target')
        and J.IsInRange(bot,target,Range(a)) and not J.CannotBeKilled(bot,target) then return target end
    return nil
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='meepo_earthbind' and name~='meepo_poof' and name~='meepo_petrify' and name~='meepo_megameepo' and name~='meepo_megameepo_fling' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local point,target
    if name=='meepo_earthbind' then point=X.NetPoint(a,false);if point==nil then return false end
    elseif name=='meepo_poof' then target=X.PoofTarget(a);if target==nil then return false end
    elseif name=='meepo_petrify' then if not X.DigUseful(a) then return false end
    elseif name=='meepo_megameepo' then if not X.MegaUseful(a) then return false end
    else target=X.FlingTarget(a);if target==nil then return false end end
    J.SetQueuePtToINT(bot,false,a)
    if point~=nil then bot:ActionQueue_UseAbilityOnLocation(a,point)
    elseif target~=nil then bot:ActionQueue_UseAbilityOnEntity(a,target) else bot:ActionQueue_UseAbility(a) end
    return true
end
return X
