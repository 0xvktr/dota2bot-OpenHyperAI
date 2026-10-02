local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function X.Range(a)
    local lens=J.IsItemAvailable('item_aether_lens')
    local r=a:GetCastRange()+(lens~=nil and lens:GetSpecialValueInt('cast_range_bonus') or 0)
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then r=r+supremacy:GetSpecialValueInt('cast_range') end
    return r
end
local function Enemy(u,pierces)
    return J.IsValidHero(u) and not J.IsSuspiciousIllusion(u)
        and (pierces and J.CanCastOnMagicImmune(u) or not pierces and J.CanCastOnNonMagicImmune(u))
end
function X.RPUseful(a,urgent)
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_magnataur_skewer_movement') then return false end
    local count=0
    local radius=math.max(a:GetSpecialValueInt('pull_radius'),a:GetSpecialValueInt('push_radius'))
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,radius),true,BOT_MODE_NONE)) do
        if Enemy(u,true) and GetUnitToLocationDistance(bot,J.GetCorrectLoc(u,a:GetCastPoint()))<=radius
            and J.IsInRange(bot,u,radius) then
            if u:IsChanneling() or J.IsRetreating(bot) and J.GetHP(bot)<0.5 and J.IsChasingTarget(u,bot) then return true end
            count=count+1
            if not urgent and J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                and not J.IsDisabled(u) and #J.GetNearbyHeroes(bot,900,false,BOT_MODE_NONE)>0 then return true end
        end
    end
    return not urgent and count>=2 and J.IsInTeamFight(bot,1200)
end
function X.EmpowerTarget(a)
    if not J.CanCastAbility(a) then return nil end
    local best,damage=nil,0
    for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),false,BOT_MODE_NONE)) do
        if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and not ally:HasModifier('modifier_magnataur_empower') and not J.IsDisabled(ally)
            and J.IsInRange(bot,ally,X.Range(a)) and J.IsAttacking(ally)
            and (J.IsGoingOnSomeone(ally) or J.IsFarming(ally) or J.IsPushing(ally)
                or J.IsDoingRoshan(ally) or J.IsDoingTormentor(ally)) then
            local value=ally:GetAttackDamage()*(ally:GetAttackRange()<=325 and 2 or 1)
            if value>damage then best,damage=ally,value end
        end
    end
    return best
end
function X.SkewerFrom(a,origin)
    if not J.CanCastAbility(a) or bot:IsRooted() then return nil end
    local escape=J.GetEscapeLoc()
    if (escape-origin):Length2D()<1 then return nil end
    return origin+(escape-origin):Normalized()*a:GetSpecialValueInt('range')
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='magnataur_shockwave' and name~='magnataur_empower' and name~='magnataur_reverse_polarity'
        and name~='magnataur_skewer' and name~='magnataur_horn_toss' then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) then return false end
    local target,point=nil,nil
    if name=='magnataur_empower' then target=X.EmpowerTarget(a);if target==nil then return false end
    elseif name=='magnataur_reverse_polarity' then if not X.RPUseful(a,false) then return false end
    elseif name=='magnataur_skewer' then
        if not J.IsRetreating(bot) or #J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE)==0 then return false end
        point=X.SkewerFrom(a,bot:GetLocation());if point==nil then return false end
    else
        for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,name=='magnataur_horn_toss' and a:GetSpecialValueInt('radius') or X.Range(a)),true,BOT_MODE_NONE)) do
            if Enemy(u,false) and (u:IsChanneling() or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)) then
                if name=='magnataur_horn_toss' then
                    if bot:IsFacingLocation(u:GetLocation(),a:GetSpecialValueInt('pull_angle')/2) then target=u;break end
                else
                    local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('shock_speed')
                    point=J.GetCorrectLoc(u,delay)
                    if GetUnitToLocationDistance(bot,point)<=X.Range(a) then break else point=nil end
                end
            end
        end
        if target==nil and point==nil then return false end
    end
    J.SetQueuePtToINT(bot,true,a)
    if name=='magnataur_empower' then bot:ActionQueue_UseAbilityOnEntity(a,target)
    elseif point~=nil then bot:ActionQueue_UseAbilityOnLocation(a,point)
    else bot:ActionQueue_UseAbility(a) end
    return true
end
return X
