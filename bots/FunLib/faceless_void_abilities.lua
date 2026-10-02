local F={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function F.Observe(bot,walk,state)
    local now,hp=DotaTime(),bot:GetHealth()
    local window=walk and walk:GetSpecialValueFloat('backtrack_duration') or 2
    state.history=state.history or {}
    local recent={};state.lost=0
    for _,entry in pairs(state.history) do
        if now-entry.time<=window then recent[#recent+1]=entry;state.lost=math.max(state.lost,entry.hp-hp) end
    end
    recent[#recent+1]={time=now,hp=hp};state.history=recent
end
function F.Bound(bot,point,range)
    local origin=bot:GetLocation();local dx,dy=point.x-origin.x,point.y-origin.y
    local d=math.sqrt(dx*dx+dy*dy)
    if d<=range then return point end
    return Vector(origin.x+dx*range/d,origin.y+dy*range/d,origin.z)
end
function F.Walk(bot,ability,state)
    if not J.CanCastAbility(ability) or bot:IsRooted() or bot:HasModifier('modifier_faceless_void_chronosphere_speed') then return 0,nil,false end
    local range=ability:GetSpecialValueInt('range')
    local escape=F.Bound(bot,J.GetEscapeLoc(),range)
    if IsLocationPassable(escape) and (J.IsStuck(bot) or J.IsStunProjectileIncoming(bot,600)
        or J.IsUnitTargetProjectileIncoming(bot,400)
        or state.lost>=bot:GetMaxHealth()*0.15 and bot:WasRecentlyDamagedByAnyHero(ability:GetSpecialValueFloat('backtrack_duration'))
        or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) then
        return BOT_ACTION_DESIRE_HIGH,escape,true
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnMagicImmune(target)
        and J.CanBeAttacked(target) and not J.IsInEtherealForm(target)
        and not J.IsInRange(bot,target,bot:GetAttackRange()+75) then
        local chrono=bot:GetAbilityByName('faceless_void_chronosphere')
        local readyChrono=J.CanCastAbility(chrono) and bot:GetMana()-ability:GetManaCost()>=chrono:GetManaCost()
        local lock=bot:GetAbilityByName('faceless_void_time_lock')
        local upgradedHits=bot:HasScepter() and lock and lock:IsTrained() and not J.HasBreakModifier(bot)
        if ability:GetLevel()<3 and not readyChrono and not upgradedHits then return 0,nil,false end
        local point=F.Bound(bot,J.GetCorrectLoc(target,ability:GetCastPoint()),range)
        if IsLocationPassable(point) and not J.IsLocationInArena(point,600)
            and #J.GetEnemiesNearLoc(point,800)<=#J.GetAlliesNearLoc(point,800)+1 then
            return BOT_ACTION_DESIRE_HIGH,point,false
        end
    end
    return 0,nil,false
end
function F.RecordWalk(bot,ability,point,state)
    state.origin=bot:GetLocation()
    state.reverseUntil=DotaTime()+ability:GetCastPoint()+GetUnitToLocationDistance(bot,point)/ability:GetSpecialValueInt('speed')+1.5
end
function F.Reverse(bot,ability,state)
    if not J.CanCastAbility(ability) or bot:IsRooted() or not state.origin
        or DotaTime()>(state.reverseUntil or -1) or bot:HasModifier('modifier_faceless_void_chronosphere_speed') then return 0 end
    if not IsLocationPassable(state.origin)
        or #J.GetEnemiesNearLoc(state.origin,600)>#J.GetEnemiesNearLoc(bot:GetLocation(),600) then return 0 end
    if J.IsRetreating(bot) or J.IsStunProjectileIncoming(bot,600) or J.IsUnitTargetProjectileIncoming(bot,400) then
        if J.GetLocationToLocationDistance(state.origin,J.GetEscapeLoc())+100
            < GetUnitToLocationDistance(bot,J.GetEscapeLoc()) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function F.Dilation(bot,ability)
    if not J.CanCastAbility(ability) then return 0 end
    local target=J.GetProperTarget(bot);local count=0
    for _,enemy in pairs(J.GetNearbyHeroes(bot,ability:GetSpecialValueInt('radius'),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and not enemy:HasModifier('modifier_faceless_void_time_dilation') then
            -- Enemy cooldowns are not exposed by the bot API. Base stack still makes combat use valuable.
            if enemy==target and J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)
                or J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then count=count+1 end
        end
    end
    -- Current Dilation has one base stack even before a spell enters cooldown.
    return count>0 and BOT_ACTION_DESIRE_HIGH or 0
end
function F.Chrono(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=ability:GetCastRange();local radius=ability:GetSpecialValueInt('radius')
    for slot=0,5 do
        local item=bot:GetItemInSlot(slot)
        if item and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
    end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    local target=J.GetProperTarget(bot);local candidates={}
    if J.IsInTeamFight(bot,1200) then
        local aoe=bot:FindAoELocation(true,true,bot:GetLocation(),range,radius*0.8,ability:GetCastPoint(),0)
        candidates[#candidates+1]=F.Bound(bot,aoe.targetloc,range)
    end
    if J.IsValidHero(target) and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot)) then
        candidates[#candidates+1]=F.Bound(bot,J.GetCorrectLoc(target,ability:GetCastPoint()),range)
    end
    for _,point in pairs(candidates) do
        local alliesInside=0
        for _,ally in pairs(J.GetAlliesNearLoc(point,radius)) do
            if ally~=bot and J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally)
                and ally:GetUnitName()~='npc_dota_hero_faceless_void' then alliesInside=alliesInside+1 end
        end
        local enemiesInside={}
        for _,enemy in pairs(J.GetEnemiesNearLoc(point,radius)) do
            -- Enemy Faceless Void moves freely in every Chronosphere.
            if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy)
                and enemy:GetUnitName()~='npc_dota_hero_faceless_void'
                and J.GetLocationToLocationDistance(J.GetCorrectLoc(enemy,ability:GetCastPoint()),point)<=radius
                and not enemy:HasModifier('modifier_faceless_void_chronosphere_freeze') then
                enemiesInside[#enemiesInside+1]=enemy
            end
        end
        if alliesInside==0 and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point) then
            if #enemiesInside>=2 then return BOT_ACTION_DESIRE_HIGH,point end
            if #enemiesInside==1 and J.IsGoingOnSomeone(bot) and not bot:IsDisarmed()
                and J.CanBeAttacked(enemiesInside[1]) and not J.IsInEtherealForm(enemiesInside[1])
                and not enemiesInside[1]:HasModifier('modifier_abaddon_borrowed_time')
                and not enemiesInside[1]:HasModifier('modifier_dazzle_shallow_grave') then
                local attacks=math.max(0,(ability:GetSpecialValueFloat('duration')-0.5)/bot:GetSecondsPerAttack())
                if J.CanKillTarget(enemiesInside[1],bot:GetAttackDamage()*attacks,DAMAGE_TYPE_PHYSICAL) then
                    return BOT_ACTION_DESIRE_HIGH,point
                end
            end
        end
    end
    return 0,nil
end
return F
