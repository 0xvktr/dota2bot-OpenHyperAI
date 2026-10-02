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
local function Recipient(u)
    return J.IsValid(u) and not u:IsInvisible() and not u:IsInvulnerable() and not u:IsMagicImmune()
end
function X.SnakeTarget(a)
    if not J.CanCastAbility(a) then return nil end
    local pool,seen={},{ }
    local function Add(list) for _,u in pairs(list) do if Recipient(u) and not seen[u] then seen[u]=true;pool[#pool+1]=u end end end
    Add(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE));Add(bot:GetNearbyLaneCreeps(1600,true));Add(bot:GetNearbyNeutralCreeps(1600))
    local best,score=nil,0
    for _,start in pairs(pool) do
        if J.IsInRange(bot,start,Range(a)) and J.CanCastOnTargetAdvanced(start) then
            local visited,current,count,mana,heroes={[start]=true},start,0,0,0
            for _=1,a:GetSpecialValueInt('snake_jumps') do
                count=count+1;mana=mana+current:GetMaxMana()*a:GetSpecialValueInt('snake_mana_steal')/100
                if J.IsValidHero(current) and not J.IsSuspiciousIllusion(current) then heroes=heroes+1 end
                local nextUnit,dist=nil,a:GetSpecialValueInt('radius')+1
                for _,u in pairs(pool) do
                    local d=GetUnitToUnitDistance(current,u)
                    if not visited[u] and d<=a:GetSpecialValueInt('radius') and d<dist then nextUnit,dist=u,d end
                end
                if nextUnit==nil then break end
                visited[nextUnit]=true;current=nextUnit
            end
            local lethal=J.IsValidHero(start) and not J.CannotBeKilled(bot,start)
                and J.WillKillTarget(start,a:GetSpecialValueInt('snake_damage'),DAMAGE_TYPE_MAGICAL,
                    a:GetCastPoint()+GetUnitToUnitDistance(bot,start)/a:GetSpecialValueInt('initial_speed'))
            local combat=(J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200) or J.IsRetreating(bot)) and heroes>0
            local refill=J.GetMP(bot)<0.8 and mana>a:GetManaCost()+50
            local farm=J.IsFarming(bot) and count>=3 and J.IsAllowedToSpam(bot,a:GetManaCost())
            if lethal or combat or refill or farm then
                local value=(lethal and 10000 or 0)+heroes*300+math.min(mana,bot:GetMaxMana()-bot:GetMana())+count*50
                if value>score then best,score=start,value end
            end
        end
    end
    return best
end
function X.GazeUseful(a)
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_medusa_stone_gaze') then return false end
    local facing=0
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,a:GetSpecialValueInt('radius')),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnMagicImmune(u) and not J.IsSuspiciousIllusion(u)
            and u:IsFacingLocation(bot:GetLocation(),60) and not J.IsDisabled(u) then
            facing=facing+1
            local shield=bot:GetAbilityByName('medusa_mana_shield')
            local threatened=shield~=nil and shield:IsTrained() and J.GetMP(bot)<0.35 or J.GetHP(bot)<0.5
            if J.IsRetreating(bot) and (J.IsChasingTarget(u,bot) or threatened)
                or threatened and bot:WasRecentlyDamagedByAnyHero(2) and J.IsInRange(bot,u,700) then return true end
        end
    end
    return facing>=2 and (J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot))
end
function X.GraspPoint(a)
    if not J.CanCastAbility(a) then return nil end
    local target=J.GetProperTarget(bot)
    if not J.IsValidHero(target) or not J.CanCastOnNonMagicImmune(target) or J.IsSuspiciousIllusion(target)
        or not (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot) and J.IsChasingTarget(target,bot)) then return nil end
    local point=J.GetCorrectLoc(target,a:GetCastPoint()+a:GetSpecialValueFloat('delay')+a:GetSpecialValueFloat('volley_interval'))
    local distance=GetUnitToLocationDistance(bot,point)
    local radius=a:GetSpecialValueInt('radius')+a:GetSpecialValueInt('radius_grow')
    if distance>Range(a)+radius then return nil end
    if distance>Range(a) then point=bot:GetLocation()+(point-bot:GetLocation()):Normalized()*Range(a) end
    return point
end
function X.UseSplitShot()
    local split=bot:GetAbilityByName('medusa_split_shot')
    if split==nil or not J.CanCastAbility(split) then return false end
    if not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsInvulnerable()
        or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local radius=math.min(1600,bot:GetAttackRange()+split:GetSpecialValueInt('split_shot_bonus_range'))
    local count=0
    for _,u in pairs(J.GetNearbyHeroes(bot,radius,true,BOT_MODE_NONE)) do if J.CanBeAttacked(u) then count=count+1 end end
    for _,u in pairs(bot:GetNearbyCreeps(radius,true)) do if J.CanBeAttacked(u) then count=count+1 end end
    local desired=not J.IsLaning(bot) and count>=2
    if split:GetToggleState()~=desired then bot:Action_UseAbility(split);return true end
    return false
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='medusa_split_shot' and name~='medusa_mystic_snake' and name~='medusa_stone_gaze' and name~='medusa_gorgon_grasp' then return nil end
    if name=='medusa_split_shot' then return X.UseSplitShot() end
    if J.CanNotUseAbility(bot) then return false end
    local target,point
    if name=='medusa_mystic_snake' then target=X.SnakeTarget(a);if target==nil then return false end
    elseif name=='medusa_gorgon_grasp' then point=X.GraspPoint(a);if point==nil then return false end
    elseif not X.GazeUseful(a) then return false end
    J.SetQueuePtToINT(bot,true,a)
    if target~=nil then bot:ActionQueue_UseAbilityOnEntity(a,target)
    elseif point~=nil then bot:ActionQueue_UseAbilityOnLocation(a,point) else bot:ActionQueue_UseAbility(a) end
    return true
end
return X
