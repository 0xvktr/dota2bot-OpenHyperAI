local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local function Range(a)
    local lens=J.IsItemAvailable('item_aether_lens')
    local range=a:GetCastRange()+(lens~=nil and lens:GetSpecialValueInt('cast_range_bonus') or 0)
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(u) return J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and J.CanCastOnNonMagicImmune(u) and not J.CannotBeKilled(bot,u) end
function X.EclipseLocation(a,beam)
    if not J.CanCastAbility(a) or beam==nil or not beam:IsTrained()
        or beam:GetSpecialValueInt('beam_damage')<=0 then return nil end
    if not (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)) then return nil end
    local radius=a:GetSpecialValueInt('radius')
    local points={bot:GetLocation()}
    local heroes=GetUnitList(UNIT_LIST_ENEMY_HEROES)
    if bot:HasScepter() then
        for _,u in pairs(heroes) do
            if Enemy(u) and J.IsInRange(bot,u,Range(a)) then points[#points+1]=u:GetLocation() end
        end
    end
    local best,score=nil,0
    for _,point in pairs(points) do
        local count,units,weakest=0,0,nil
        for _,u in pairs(heroes) do
            if J.IsValidHero(u) and not u:IsInvulnerable() and not u:IsMagicImmune()
                and not u:IsInvisible() and GetUnitToLocationDistance(u,point)<=radius then
                units=units+1
                if Enemy(u) then count=count+1;if weakest==nil or u:GetHealth()<weakest then weakest=u:GetHealth() end end
            end
        end
        for _,creep in pairs(GetUnitList(UNIT_LIST_ENEMY_CREEPS)) do
            if J.IsValid(creep) and not creep:IsInvulnerable() and not creep:IsMagicImmune()
                and GetUnitToLocationDistance(creep,point)<=radius then units=units+1 end
        end
        if count>0 then
            local hits=math.min(a:GetSpecialValueInt('hit_count'),a:GetSpecialValueInt('beams')/math.max(1,units))
            local value=count*hits
            -- Estimate beam opportunity, never treat random allocation as guaranteed lethal damage.
            if (count>=2 and hits>=2 or count==1 and units<=2 and hits>=3 and weakest>beam:GetSpecialValueInt('beam_damage'))
                and value>score then best,score=point,value end
        end
    end
    return best
end
function X.OrbitUseful(a)
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_luna_lunar_orbit') then return false end
    local radius=a:GetSpecialValueInt('rotating_glaives_movement_radius')+a:GetSpecialValueInt('rotating_glaives_hit_radius')
    local target=J.GetProperTarget(bot)
    if J.IsValidHero(target) and J.CanCastOnMagicImmune(target) and not J.IsSuspiciousIllusion(target)
        and J.IsGoingOnSomeone(bot) and J.IsInRange(bot,target,radius) then return true end
    if bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,700,true,BOT_MODE_NONE)>0 then return true end
    return J.IsFarming(bot) and J.IsAttacking(bot)
        and #bot:GetNearbyCreeps(radius,true)>=2 and J.IsAllowedToSpam(bot,a:GetManaCost())
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='luna_lucent_beam' and name~='luna_lunar_orbit' and name~='luna_eclipse' then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) then return false end
    if name=='luna_eclipse' then
        local point=X.EclipseLocation(a,bot:GetAbilityByName('luna_lucent_beam'))
        if point==nil then return false end
        J.SetQueuePtToINT(bot,true,a)
        if bot:HasScepter() then bot:ActionQueue_UseAbilityOnLocation(a,point) else bot:ActionQueue_UseAbility(a) end
        return true
    elseif name=='luna_lunar_orbit' then
        if not X.OrbitUseful(a) then return false end
        J.SetQueuePtToINT(bot,true,a);bot:ActionQueue_UseAbility(a);return true
    end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,Range(a)),true,BOT_MODE_NONE)) do
        if Enemy(u) and J.CanCastOnTargetAdvanced(u) and (u:IsChanneling()
            or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
            or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)
            or J.WillKillTarget(u,a:GetSpecialValueInt('beam_damage'),DAMAGE_TYPE_MAGICAL,a:GetCastPoint())) then
            J.SetQueuePtToINT(bot,true,a);bot:ActionQueue_UseAbilityOnEntity(a,u);return true
        end
    end
    return false
end
return X
