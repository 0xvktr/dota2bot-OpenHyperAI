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
function X.SpearPoint(a,urgent)
    if not J.CanCastAbility(a) then return nil end
    local reach=a:GetSpecialValueInt('spear_range')
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,reach),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u)
            and (u:IsChanneling() or not urgent and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot))) then
            local eta=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('spear_speed')
            local point=J.GetCorrectLoc(u,eta)
            if GetUnitToLocationDistance(bot,point)<=reach then return point end
        end
    end
    return nil
end
function X.BulwarkPoint(a)
    if not J.CanCastAbility(a) then return nil end
    local on=a:GetToggleState()
    if on and (J.IsAttacking(bot) or J.IsGoingOnSomeone(bot) or J.IsRetreating(bot)) then
        return bot:GetLocation()+Vector(math.cos(math.rad(bot:GetFacing())),math.sin(math.rad(bot:GetFacing())),0)*100
    end
    if not on and not J.IsAttacking(bot) and not J.IsRetreating(bot) and J.GetHP(bot)>0.5 then
        for _,enemy in pairs(J.GetNearbyHeroes(bot,a:GetSpecialValueInt('redirect_range'),true,BOT_MODE_NONE)) do
            local ally=enemy:GetAttackTarget()
            if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and enemy:GetAttackRange()>325
                and J.IsValidHero(ally) and ally~=bot and ally:GetTeam()==bot:GetTeam()
                and J.GetHP(ally)<0.5 and J.IsInRange(bot,ally,a:GetSpecialValueInt('redirect_close_range')) then return enemy:GetLocation() end
        end
    end
    if on and #J.GetNearbyHeroes(bot,a:GetSpecialValueInt('redirect_range'),true,BOT_MODE_NONE)==0 then return bot:GetLocation()+Vector(100,0,0) end
    return nil
end
function X.RebukePoint(a)
    if not J.CanCastAbility(a) or bot:IsDisarmed() then return nil end
    for _,u in pairs(J.GetNearbyHeroes(bot,a:GetSpecialValueInt('radius'),true,BOT_MODE_NONE)) do
        local damage=bot:GetAttackDamage()*a:GetSpecialValueInt('crit_mult')/100+a:GetSpecialValueInt('bonus_damage_vs_heroes')
        if J.IsValidHero(u) and J.CanBeAttacked(u) and not J.IsSuspiciousIllusion(u) and not J.CannotBeKilled(bot,u)
            and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                or J.WillKillTarget(u,damage,DAMAGE_TYPE_PHYSICAL,a:GetCastPoint())
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)) then return u:GetLocation() end
    end
    return nil
end
function X.ArenaPoint(a)
    if not J.CanCastAbility(a) then return nil end
    local target=J.GetProperTarget(bot)
    if not J.IsGoingOnSomeone(bot) and not J.IsInTeamFight(bot,1200) then return nil end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)+a:GetSpecialValueInt('radius')),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u)
            and (u==target or J.IsInTeamFight(bot,1200)) then
            local point=J.GetCorrectLoc(u,a:GetCastPoint()+a:GetSpecialValueFloat('formation_time'))
            if GetUnitToLocationDistance(bot,point)>X.Range(a) then point=bot:GetLocation()+(point-bot:GetLocation()):Normalized()*X.Range(a) end
            local count=0
            for _,enemy in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and not J.IsSuspiciousIllusion(enemy)
                    and GetUnitToLocationDistance(enemy,point)<a:GetSpecialValueInt('radius')-100 then count=count+1 end
            end
            if count>=2 or u==target and count>=1 and #J.GetNearbyHeroes(bot,900,false,BOT_MODE_NONE)>0 then return point end
        end
    end
    return nil
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='mars_spear' and name~='mars_gods_rebuke' and name~='mars_bulwark' and name~='mars_arena_of_blood' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local point
    if name=='mars_spear' then point=X.SpearPoint(a,false)
    elseif name=='mars_gods_rebuke' then point=X.RebukePoint(a)
    elseif name=='mars_bulwark' then point=X.BulwarkPoint(a)
    else point=X.ArenaPoint(a) end
    if point==nil then return false end
    J.SetQueuePtToINT(bot,true,a);bot:ActionQueue_UseAbilityOnLocation(a,point);return true
end
return X
