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
local function Enemy(u) return J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u) end
function X.StunLocation(a,u)
    if not Enemy(u) then return nil end
    local delay=a:GetCastPoint()+a:GetSpecialValueFloat('light_strike_array_delay_time')
    local point=J.GetCorrectLoc(u,delay)
    local range=Range(a)
    local offset=point-bot:GetLocation()
    local location=offset:Length2D()>range and bot:GetLocation()+offset:Normalized()*range or point
    return (point-location):Length2D()<=a:GetSpecialValueInt('light_strike_array_aoe') and location or nil
end
function X.LagunaTarget(a,opener)
    if not J.CanCastAbility(a) then return nil end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,Range(a)),true,BOT_MODE_NONE)) do
        if Enemy(u) and J.CanCastOnTargetAdvanced(u) and not J.CannotBeKilled(bot,u)
            and J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,
                a:GetCastPoint()+a:GetSpecialValueFloat('damage_delay')) then return u end
    end
    local target=J.GetProperTarget(bot)
    local soul=bot:GetAbilityByName('lina_fiery_soul')
    local stun=bot:GetAbilityByName('lina_light_strike_array')
    if opener and bot:HasModifier('modifier_item_aghanims_shard') and soul~=nil and soul:IsTrained() and not J.HasBreakModifier(bot)
        and J.IsGoingOnSomeone(bot) and Enemy(target) and J.CanCastOnTargetAdvanced(target)
        and J.IsInRange(bot,target,Range(a)) and J.IsInRange(bot,target,bot:GetAttackRange())
        and not J.CannotBeKilled(bot,target) and (J.IsDisabled(target) or not J.CanCastAbility(stun)) then return target end
    return nil
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='lina_light_strike_array' and name~='lina_dragon_slave' and name~='lina_laguna_blade' and name~='lina_flame_cloak' then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) then return false end
    local target=J.GetProperTarget(bot)
    if name=='lina_laguna_blade' then target=X.LagunaTarget(a,false)
    elseif name=='lina_flame_cloak' then
        if bot:HasModifier('modifier_lina_flame_cloak') then return false end
        if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
            or J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsInRange(bot,target,900)
                and (J.CanCastAbility(bot:GetAbilityByName('lina_dragon_slave'))
                    or J.CanCastAbility(bot:GetAbilityByName('lina_laguna_blade'))) then
            J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbility(a);return true
        end
        return false
    elseif name=='lina_light_strike_array' then
        for _,u in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
            if Enemy(u) and u:IsChanneling() and X.StunLocation(a,u)~=nil then target=u;break end
        end
    end
    if not Enemy(target) then return false end
    local point
    if name=='lina_light_strike_array' then point=X.StunLocation(a,target)
    elseif name=='lina_dragon_slave' then
        local distance=GetUnitToUnitDistance(bot,target)
        if distance>a:GetSpecialValueInt('dragon_slave_distance') then return false end
        point=J.GetCorrectLoc(target,a:GetCastPoint()+distance/a:GetSpecialValueInt('dragon_slave_speed'))
        if GetUnitToLocationDistance(bot,point)>a:GetSpecialValueInt('dragon_slave_distance') then return false end
    end
    if name~='lina_laguna_blade' and not (target:IsChanneling() and name=='lina_light_strike_array'
        or J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200) or J.IsRetreating(bot) and J.IsChasingTarget(target,bot)) then return false end
    if name~='lina_laguna_blade' and point==nil then return false end
    J.SetQueuePtToINT(bot,true,a)
    if name=='lina_laguna_blade' then bot:ActionQueue_UseAbilityOnEntity(a,target)
    else bot:ActionQueue_UseAbilityOnLocation(a,point) end
    return true
end
return X
