local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local ringCenter,ringUntil
local projectiles={}
function X.RecordRing(point,a) ringCenter=point;ringUntil=DotaTime()+a:GetSpecialValueFloat('duration')+2 end
function X.InRing()
    return bot:HasModifier('modifier_monkey_king_fur_army_bonus_damage')
end
function X.StrikePoint(a,urgent)
    if not J.CanCastAbility(a) then return nil end
    local range=a:GetSpecialValueInt('strike_cast_range')
    local damage=bot:GetAttackDamage()*a:GetSpecialValueInt('strike_crit_mult')/100+a:GetSpecialValueInt('strike_flat_damage')
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u)
            and (u:IsChanneling() or not urgent and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                or J.WillKillTarget(u,damage,DAMAGE_TYPE_PHYSICAL,a:GetCastPoint())
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot))) then
            local point=J.GetCorrectLoc(u,a:GetCastPoint())
            if GetUnitToLocationDistance(bot,point)<=range then return point end
        end
    end
    return nil
end
function X.RingPoint(a)
    if not J.CanCastAbility(a) or X.InRing() then return nil end
    local target=J.GetProperTarget(bot)
    if not (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)) then return nil end
    local radius=a:GetSpecialValueInt('second_radius')
    local range=math.min(a:GetSpecialValueInt('cast_range'),radius-100)
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range+radius),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanBeAttacked(u) and not J.IsSuspiciousIllusion(u)
            and (u==target and J.IsDisabled(u) or J.IsInTeamFight(bot,1200)) then
            local point=J.GetCorrectLoc(u,a:GetCastPoint()+1)
            if GetUnitToLocationDistance(bot,point)>range then point=bot:GetLocation()+(point-bot:GetLocation()):Normalized()*range end
            local count=0
            for _,enemy in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and J.CanBeAttacked(enemy) and not J.IsSuspiciousIllusion(enemy)
                    and GetUnitToLocationDistance(enemy,point)<=radius-150 then count=count+1 end
            end
            if count>=2 or count==1 and u==target and J.IsDisabled(u) then return point end
        end
    end
    return nil
end
function X.GuardPoint(a)
    local ring=bot:GetAbilityByName('monkey_king_wukongs_command')
    if not J.CanCastAbility(a) or bot:IsRooted() or not X.InRing() or ring==nil or not ring:IsTrained()
        or ringCenter==nil or DotaTime()>(ringUntil or 0) then return nil end
    if J.IsStunProjectileIncoming(bot,500) or J.GetHP(bot)<0.35 and bot:WasRecentlyDamagedByAnyHero(1) then
        -- The live subability chooses the nearest valid Wukong soldier, excluding Scepter soldiers.
        return ringCenter
    end
    return nil
end
function X.MischiefImminent(a)
    if not J.CanCastAbility(a) then return false end
    local now=DotaTime()
    local imminent=false
    for _,p in pairs(bot:GetIncomingTrackingProjectiles()) do
        if p.caster~=nil and p.caster:GetTeam()~=bot:GetTeam() then
            local key=p.ability or p.caster
            local distance=GetUnitToLocationDistance(bot,p.location)
            local previous=projectiles[key]
            if previous~=nil and now>previous.time and now-previous.time<0.3 then
                local speed=(previous.distance-distance)/(now-previous.time)
                if speed>0 and distance/speed<=a:GetSpecialValueFloat('invul_duration')-a:GetCastPoint() then imminent=true end
            end
            projectiles[key]={distance=distance,time=now}
        end
    end
    return imminent
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='monkey_king_boundless_strike' and name~='monkey_king_wukongs_command'
        and name~='monkey_king_tree_dance' and name~='monkey_king_primal_spring'
        and name~='monkey_king_transfiguration' and name~='monkey_king_mischief' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local point
    if name=='monkey_king_boundless_strike' then point=X.StrikePoint(a,false)
    elseif name=='monkey_king_wukongs_command' then point=X.RingPoint(a)
    elseif name=='monkey_king_transfiguration' then point=X.GuardPoint(a)
    elseif name=='monkey_king_mischief' then
        if not X.MischiefImminent(a) then return false end
        bot:Action_UseAbility(a);return true
    else return false end -- Perch/Spring linked availability needs live verification when copied.
    if point==nil then return false end
    J.SetQueuePtToINT(bot,true,a);bot:ActionQueue_UseAbilityOnLocation(a,point)
    if name=='monkey_king_wukongs_command' then X.RecordRing(point,a) end
    return true
end
return X
