local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local function Eligible(u)
    return J.IsValid(u) and not u:IsInvulnerable() and not u:IsMagicImmune() and not u:IsInvisible()
end
local function ClearPath(a,target,point)
    local start=bot:GetLocation()
    local direction=point-start
    local length=direction:Length2D()
    if length<1 then return false end
    direction=direction:Normalized()
    for _,u in pairs(GetUnitList(UNIT_LIST_ALL)) do
        if u~=target and J.IsValid(u) and u:GetTeam()~=bot:GetTeam() and (u:IsHero() or u:IsCreep()) and not u:IsInvulnerable() then
            local delta=u:GetLocation()-start
            local along=delta.x*direction.x+delta.y*direction.y
            local cross=math.abs(delta.x*direction.y-delta.y*direction.x)
            if along>0 and along<length and cross<=a:GetSpecialValueInt('arrow_width')+24 then return false end
        end
    end
    return true
end
function X.ArrowPoint(a,urgent)
    if not J.CanCastAbility(a) then return nil end
    for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and not u:IsMagicImmune()
            and J.IsInRange(bot,u,a:GetSpecialValueInt('arrow_range')) then
            local eta=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('arrow_speed')
            local setup=0
            for _,m in pairs({'modifier_eul_cyclone','modifier_shadow_demon_disruption','modifier_obsidian_destroyer_astral_imprisonment_prison'}) do setup=math.max(setup,J.GetModifierTime(u,m)) end
            local banish=setup>0 and math.abs(setup-eta)<=0.15
            local disable=math.max(J.GetRemainStunTime(u),J.GetModifierTime(u,'modifier_bane_nightmare'),J.GetModifierTime(u,'modifier_rooted'))>=eta
            local channel=u:IsChanneling() and not u:IsInvulnerable()
            if (not u:IsInvulnerable() or banish) and (channel or not urgent and (disable or banish or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot))) then
                local point=(disable or channel or banish) and u:GetLocation() or J.GetCorrectLoc(u,eta)
                if GetUnitToLocationDistance(bot,point)<=a:GetSpecialValueInt('arrow_range') and ClearPath(a,u,point) then return point end
            end
        end
    end
    if not urgent and J.IsFarming(bot) and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        for _,u in pairs(bot:GetNearbyNeutralCreeps(1600)) do
            if Eligible(u) and not u:IsAncientCreep() and u:GetHealth()>700 and ClearPath(a,u,u:GetLocation()) then return u:GetLocation() end
        end
    end
    return nil
end
function X.StarUseful(a)
    if not J.CanCastAbility(a) then return false end
    local closest,distance=nil,a:GetSpecialValueInt('starfall_secondary_radius')+1
    for _,u in pairs(GetUnitList(UNIT_LIST_ALL)) do
        if Eligible(u) and u:GetTeam()~=bot:GetTeam() and (u:IsHero() or u:IsCreep()) then
            local d=GetUnitToUnitDistance(bot,u)
            if d<distance then closest,distance=u,d end
        end
    end
    for _,u in pairs(J.GetNearbyHeroes(bot,a:GetSpecialValueInt('starfall_radius'),true,BOT_MODE_NONE)) do
        if Eligible(u) and not J.IsSuspiciousIllusion(u) and not J.CannotBeKilled(bot,u) then
            local damage=a:GetSpecialValueInt('damage')*(1+(u==closest and a:GetSpecialValueInt('secondary_starfall_damage_percent')/100 or 0))
            if J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,a:GetCastPoint()+0.57)
                or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsRetreating(bot) then return true end
        end
    end
    return J.IsFarming(bot) and J.IsAllowedToSpam(bot,a:GetManaCost())
        and (#bot:GetNearbyLaneCreeps(a:GetSpecialValueInt('starfall_radius'),true)>=3 or #bot:GetNearbyNeutralCreeps(a:GetSpecialValueInt('starfall_radius'))>=3)
end
function X.LeapUseful(a)
    if not J.CanCastAbility(a) or a:GetCurrentCharges()<=0 or bot:IsRooted()
        or bot:HasModifier('modifier_bloodseeker_rupture') then return false end
    local angle=math.rad(bot:GetFacing())
    local landing=bot:GetLocation()+Vector(math.cos(angle),math.sin(angle),0)*a:GetSpecialValueInt('leap_distance')
    if J.IsRetreating(bot) then
        local safer,threat=false,false
        for _,u in pairs(J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)) do
            if J.IsValidHero(u) and J.IsChasingTarget(u,bot) and not J.IsDisabled(u) then
                threat=true
                if GetUnitToLocationDistance(u,landing)<=GetUnitToUnitDistance(bot,u)+250 then return false end
                safer=true
            end
        end
        return threat and safer
    end
    local target=J.GetProperTarget(bot)
    return a:GetCurrentCharges()>=2 and not bot:HasModifier('modifier_mirana_leap_buff')
        and J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanBeAttacked(target)
        and not J.IsSuspiciousIllusion(target) and GetUnitToLocationDistance(target,landing)<=bot:GetAttackRange()
        and GetUnitToUnitDistance(bot,target)>bot:GetAttackRange()
        and #J.GetAlliesNearLoc(landing,900)+1>=#J.GetEnemiesNearLoc(landing,900)
end
function X.MoonUseful(a)
    if not J.CanCastAbility(a) then return false end
    for _,ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvisible()
            and not ally:HasModifier('modifier_mirana_moonlight_shadow') and J.IsRetreating(ally)
            and ally:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(ally,900,true,BOT_MODE_NONE)>0 then return true end
    end
    for _,ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        local target=J.IsValidHero(ally) and J.GetProperTarget(ally) or nil
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvisible()
            and J.IsGoingOnSomeone(ally) and J.IsValidHero(target) and not J.IsSuspiciousIllusion(target)
            and not J.IsInRange(ally,target,1600) and J.IsInRange(ally,target,2800)
            and #J.GetAlliesNearLoc(ally:GetLocation(),1000)>=2 then return true end
    end
    return false
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='mirana_arrow' and name~='mirana_starfall' and name~='mirana_leap' and name~='mirana_invis' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local point
    if name=='mirana_arrow' then point=X.ArrowPoint(a,false);if point==nil then return false end
    elseif name=='mirana_starfall' then if not X.StarUseful(a) then return false end
    elseif name=='mirana_leap' then if not X.LeapUseful(a) then return false end
    else if not X.MoonUseful(a) then return false end end
    J.SetQueuePtToINT(bot,true,a)
    if point~=nil then bot:ActionQueue_UseAbilityOnLocation(a,point) else bot:ActionQueue_UseAbility(a) end
    return true
end
return X
