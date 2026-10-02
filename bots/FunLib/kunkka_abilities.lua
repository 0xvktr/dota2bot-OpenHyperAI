local K={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function K.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function enemyValid(enemy)
    return J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and not J.IsSuspiciousIllusion(enemy)
        and not enemy:HasModifier('modifier_abaddon_borrowed_time') and not enemy:HasModifier('modifier_dazzle_shallow_grave')
end
function K.RecordX(state,ability,target)
    state.target=target;state.issued=DotaTime();state.source=ability;state.observed=false
    state.point=nil;state.torrentAt=nil;state.shipAt=nil;state.torrentSource=nil;state.shipSource=nil;state.torrentConfirmed=false;state.shipConfirmed=false
end
function K.Observe(bot,state)
    local target=state.target
    if not target then return false end
    if not enemyValid(target) or target:GetTeam()==bot:GetTeam() then state.target=nil;return false end
    if not target:HasModifier('modifier_kunkka_x_marks_the_spot') then
        if state.observed or DotaTime()>state.issued+state.source:GetCastPoint()+1 then state.target=nil end
        return false
    end
    local index=target:GetModifierByName('modifier_kunkka_x_marks_the_spot')
    if index<0 or target:GetModifierSourceAbility(index)~=state.source then state.target=nil;return false end
    if not state.observed then
        state.point=target:GetLocation();state.observed=true
        local remaining=J.GetModifierTime(target,'modifier_kunkka_x_marks_the_spot')
        state.expiry=DotaTime()+(remaining>0 and remaining or state.source:GetSpecialValueFloat('duration'))
    end
    if DotaTime()>state.expiry then state.target=nil;return false end
    for _,kind in pairs({'torrent','ship'}) do
        local source=state[kind..'Source']
        if source and not state[kind..'Confirmed'] then
            if source:IsNull() then state[kind..'At']=nil;state[kind..'Source']=nil
            elseif source:GetCooldownTimeRemaining()>0 then state[kind..'Confirmed']=true
            elseif DotaTime()>state[kind..'Issued']+source:GetCastPoint()+0.5 then
                -- A canceled/rejected cast must not start the Return timer.
                state[kind..'At']=nil;state[kind..'Source']=nil
            end
        end
    end
    return true
end
function K.RecordSpell(state,ability)
    if not state.observed then return end
    if ability:GetName()=='kunkka_torrent' then state.torrentAt=DotaTime()+ability:GetCastPoint()+ability:GetSpecialValueFloat('delay');state.torrentSource=ability;state.torrentIssued=DotaTime();state.torrentConfirmed=false
    elseif ability:GetName()=='kunkka_ghostship' then state.shipAt=DotaTime()+ability:GetCastPoint()+ability:GetSpecialValueFloat('tooltip_delay');state.shipSource=ability;state.shipIssued=DotaTime();state.shipConfirmed=false end
end
function K.Return(bot,ability,state)
    if not J.CanCastAbility(ability) or not K.Observe(bot,state) then return 0 end
    local when=state.torrentConfirmed and state.torrentAt or state.shipConfirmed and state.shipAt
    if state.target:IsChanneling() or when and DotaTime()+ability:GetCastPoint()>=when-0.1
        or J.IsRetreating(bot) and GetUnitToLocationDistance(state.target,state.point)>300 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function K.X(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(K.Range(bot,ability),1600),true,BOT_MODE_NONE)) do
        if enemyValid(enemy) and J.CanCastOnTargetAdvanced(enemy) and not enemy:HasModifier('modifier_kunkka_x_marks_the_spot')
            and (enemy:IsChanneling() or J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and (enemy:GetAttackTarget()==bot or bot:WasRecentlyDamagedByHero(enemy,3))) then return BOT_ACTION_DESIRE_HIGH,enemy end
    end
    return 0,nil
end
function K.Torrent(bot,ability,state)
    if not J.CanCastAbility(ability) then return 0,nil end
    if state and K.Observe(bot,state) and GetUnitToLocationDistance(bot,state.point)<=K.Range(bot,ability) then return BOT_ACTION_DESIRE_HIGH,state.point end
    local delay=ability:GetCastPoint()+ability:GetSpecialValueFloat('delay')
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(K.Range(bot,ability)+300,1600),true,BOT_MODE_NONE)) do
        local point=enemy:GetExtrapolatedLocation(delay)
        if enemyValid(enemy) and GetUnitToLocationDistance(bot,point)<=K.Range(bot,ability)
            and (enemy:IsChanneling() or J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)
                or J.IsInTeamFight(bot,1200) or J.IsRetreating(bot) and enemy:GetAttackTarget()==bot) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    local target=J.GetProperTarget(bot)
    if J.IsDoingRoshan(bot) and J.IsRoshan(target) and J.CanCastOnNonMagicImmune(target) and J.IsInRange(bot,target,K.Range(bot,ability)) then return BOT_ACTION_DESIRE_LOW,target:GetLocation() end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.GetMP(bot)>0.6 then
        local creeps=bot:GetNearbyCreeps(math.min(K.Range(bot,ability),1600),true)
        for _,creep in pairs(creeps) do
            if J.IsValid(creep) then
                local point=creep:GetExtrapolatedLocation(delay);local count=0
                for _,other in pairs(creeps) do if J.IsValid(other) and GetUnitToLocationDistance(other,point)<=ability:GetSpecialValueInt('radius') then count=count+1 end end
                if count>=4 and GetUnitToLocationDistance(bot,point)<=K.Range(bot,ability) then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    return 0,nil
end
local function onPath(unit,origin,point,width,length)
    local dx,dy=point.x-origin.x,point.y-origin.y;local distance=math.sqrt(dx*dx+dy*dy)
    if distance==0 then return false end
    dx,dy=dx/distance,dy/distance
    local ux,uy=unit.x-origin.x,unit.y-origin.y
    local along=ux*dx+uy*dy
    return along>=distance-length and along<=distance and math.abs(ux*dy-uy*dx)<=width
end
function K.Ship(bot,ability,state)
    if not J.CanCastAbility(ability) then return 0,nil end
    if state and K.Observe(bot,state) and GetUnitToLocationDistance(bot,state.point)<=K.Range(bot,ability) then return BOT_ACTION_DESIRE_HIGH,state.point end
    local delay=ability:GetCastPoint()+ability:GetSpecialValueFloat('tooltip_delay')
    local nearby=J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)
    for _,enemy in pairs(nearby) do
        local point=enemy:GetExtrapolatedLocation(delay)
        if enemyValid(enemy) and GetUnitToLocationDistance(bot,point)<=K.Range(bot,ability) then
            local hits=0;local protected=0
            for _,other in pairs(nearby) do
                if enemyValid(other) and J.GetDistance(other:GetExtrapolatedLocation(delay),point)<=ability:GetSpecialValueInt('ghostship_width') then hits=hits+1 end
            end
            local allies={bot};for _,ally in pairs(J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)) do allies[#allies+1]=ally end
            for _,ally in pairs(allies) do
                if J.IsValidHero(ally) and J.GetHP(ally)<0.6 and ally:WasRecentlyDamagedByAnyHero(3)
                    and not ally:HasModifier('modifier_kunkka_ghost_ship_damage_absorb')
                    and onPath(ally:GetLocation(),bot:GetLocation(),point,ability:GetSpecialValueInt('ghostship_width'),ability:GetSpecialValueInt('ghostship_distance')) then protected=protected+1 end
            end
            if J.CanKillTarget(enemy,ability:GetAbilityDamage(),DAMAGE_TYPE_MAGICAL)
                or J.IsInTeamFight(bot,1200) and hits>=2 or protected>0 and hits>0 then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0,nil
end
function K.Wave(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(K.Range(bot,ability),1600),true,BOT_MODE_NONE)) do
        if enemyValid(enemy) then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/ability:GetSpecialValueInt('speed')
            local point=enemy:GetExtrapolatedLocation(delay)
            if GetUnitToLocationDistance(bot,point)<=K.Range(bot,ability)
                and (enemy:IsChanneling() or J.IsRetreating(bot) and enemy:GetAttackTarget()==bot
                    or J.CanKillTarget(enemy,ability:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0,nil
end
local function physical(unit) return J.IsValid(unit) and J.CanBeAttacked(unit) end
function K.Tide(bot,ability)
    if not J.CanCastAbility(ability) or bot:IsDisarmed() or J.HasBreakModifier(bot) then return 0,nil end
    local target=J.GetProperTarget(bot)
    if not physical(target) then return 0,nil end
    local attackRange=bot:GetAttackRange()
    if J.IsInRange(bot,target,attackRange) then return BOT_ACTION_DESIRE_HIGH,target end
    if not J.IsValidHero(target) or J.IsSuspiciousIllusion(target) then return 0,nil end
    local candidates=bot:GetNearbyCreeps(math.min(attackRange,1600),true)
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(attackRange,1600),true,BOT_MODE_NONE)) do candidates[#candidates+1]=enemy end
    for _,primary in pairs(candidates) do
        if physical(primary) and J.IsInRange(bot,primary,attackRange) then
            local origin=bot:GetLocation();local point=primary:GetLocation();local tx,ty=target:GetLocation().x-origin.x,target:GetLocation().y-origin.y
            local dx,dy=point.x-origin.x,point.y-origin.y;local length=math.sqrt(dx*dx+dy*dy)
            if length>0 then
                dx,dy=dx/length,dy/length
                local along=tx*dx+ty*dy;local distance=ability:GetSpecialValueInt('cleave_distance')
                local width=ability:GetSpecialValueInt('cleave_starting_width')+(ability:GetSpecialValueInt('cleave_ending_width')-ability:GetSpecialValueInt('cleave_starting_width'))*along/math.max(distance,1)
                if along>length and along<=distance and math.abs(tx*dy-ty*dx)<=width then return BOT_ACTION_DESIRE_HIGH,primary end
            end
        end
    end
    return 0,nil
end
return K
