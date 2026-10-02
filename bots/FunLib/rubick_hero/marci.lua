local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function X.Range(a)
    local lens=J.IsItemAvailable('item_aether_lens')
    local range=a:GetCastRange()+(lens~=nil and lens:GetSpecialValueInt('cast_range_bonus') or 0)
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
function X.GuardTarget(a,urgent)
    if not J.CanCastAbility(a) then return nil end
    local best,score=nil,0
    for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),false,BOT_MODE_NONE)) do
        if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and not ally:HasModifier('modifier_marci_bodyguarded') and not ally:HasModifier('modifier_marci_guardian_buff')
            and J.IsInRange(bot,ally,X.Range(a)) then
            local threatened=ally:WasRecentlyDamagedByAnyHero(2) and J.GetHP(ally)<0.5
            local dispel=a:GetName()=='marci_bodyguard' and a:GetSpecialValueInt('strong_dispel')>0 and J.IsDisabled(ally)
            local active=J.IsAttacking(ally) and (J.IsGoingOnSomeone(ally) or J.IsFarming(ally) or J.IsDoingRoshan(ally))
            if threatened or dispel or not urgent and active then
                local value=(threatened and 10000*(1-J.GetHP(ally)) or 0)+(dispel and 10000 or 0)+ally:GetAttackDamage()
                if value>score then best,score=ally,value end
            end
        end
    end
    return best
end
function X.DisposeTarget(a,urgent)
    if not J.CanCastAbility(a) then return nil end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.IsInRange(bot,u,X.Range(a)) and J.CanCastOnNonMagicImmune(u)
            and J.CanCastOnTargetAdvanced(u) and not J.IsSuspiciousIllusion(u)
            and (u:IsChanneling() or not urgent and J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)) then return u end
    end
    local angle=math.rad(bot:GetFacing())
    local landing=bot:GetLocation()-Vector(math.cos(angle),math.sin(angle),0)*a:GetSpecialValueInt('throw_distance_behind')
    for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),false,BOT_MODE_NONE)) do
        if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and J.IsInRange(bot,ally,X.Range(a)) and not ally:IsChanneling()
            and J.GetHP(ally)<0.35 and ally:WasRecentlyDamagedByAnyHero(2) then
            local safer,threat=false,false
            for _,enemy in pairs(J.GetNearbyHeroes(ally,700,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and J.IsChasingTarget(enemy,ally) then
                    threat=true
                    if GetUnitToLocationDistance(enemy,landing)<GetUnitToUnitDistance(enemy,ally)+150 then safer=false;break end
                    safer=true
                end
            end
            if threat and safer then return ally end
        end
    end
    return nil
end
function X.UnleashUseful(a)
    if not J.CanCastAbility(a) or bot:IsDisarmed() or bot:HasModifier('modifier_marci_unleash') then return false end
    local target=J.GetProperTarget(bot)
    return J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and not J.IsSuspiciousIllusion(target)
        and J.CanBeAttacked(target) and J.IsInRange(bot,target,bot:GetAttackRange()+150)
        and not J.CannotBeKilled(bot,target) and not target:HasModifier('modifier_item_blade_mail_reflect')
        and target:GetHealth()>bot:GetAttackDamage()*2
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='marci_grapple' and name~='marci_guardian' and name~='marci_bodyguard'
        and name~='marci_unleash' and name~='marci_companion_run' then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) then return false end
    -- The engine's vector landing endpoint has no verified bot action API.
    if name=='marci_companion_run' then return false end
    local target=nil
    if name=='marci_grapple' then target=X.DisposeTarget(a,false)
    elseif name~='marci_unleash' then target=X.GuardTarget(a,false)
    elseif not X.UnleashUseful(a) then return false end
    if name~='marci_unleash' and target==nil then return false end
    J.SetQueuePtToINT(bot,false,a)
    if target~=nil then bot:ActionQueue_UseAbilityOnEntity(a,target) else bot:ActionQueue_UseAbility(a) end
    return true
end
return X
