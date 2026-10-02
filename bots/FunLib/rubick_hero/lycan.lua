local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local function Wolves()
    local out = {}
    for _,u in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if J.IsValid(u) and string.find(u:GetUnitName(),'npc_dota_lycan_wolf')
            and u:GetPlayerID() == bot:GetPlayerID() then out[#out+1] = u end
    end
    return out
end
local function Enemy(u)
    return J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and J.CanBeAttacked(u)
end
function X.SummonUseful(a)
    if not J.CanCastAbility(a) or #Wolves() >= a:GetSpecialValueInt('wolf_count') then return false end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsInRange(bot,target,800) then return true end
    if not J.IsAttacking(bot) then return false end
    if J.IsRoshan(target) or J.IsTormentor(target) then return J.IsInRange(bot,target,400) end
    if J.IsLaning(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        return #bot:GetNearbyLaneCreeps(800,true)>0
            or J.IsValidBuilding(target) and J.CanBeAttacked(target) and J.IsInRange(bot,target,600)
    end
    return J.IsFarming(bot) and (#bot:GetNearbyNeutralCreeps(600)>=2 or #bot:GetNearbyLaneCreeps(600,true)>=3)
end
function X.HowlUseful(a)
    if not J.CanCastAbility(a) then return false end
    local night = (GetTimeOfDay() < 0.25 or GetTimeOfDay() >= 0.75)
    local wolves = Wolves()
    for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(u) and J.CanCastOnNonMagicImmune(u) and not u:HasModifier('modifier_lycan_howl') then
            local reach = night or J.IsInRange(bot,u,a:GetSpecialValueInt('radius'))
            for _,wolf in pairs(wolves) do reach = reach or J.IsInRange(wolf,u,a:GetSpecialValueInt('radius')) end
            if reach then
                if J.IsRetreating(bot) and J.IsChasingTarget(u,bot) then return true end
                for _,ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
                    if J.IsValidHero(ally) and not ally:IsIllusion() and J.IsAttacking(ally)
                        and ally:GetAttackTarget()==u and J.IsInRange(ally,u,ally:GetAttackRange()+150) then return true end
                end
                for _,wolf in pairs(wolves) do if wolf:GetAttackTarget()==u then return true end end
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsAttacking(bot) and target~=nil and J.IsInRange(bot,target,a:GetSpecialValueInt('radius'))
        and not target:IsMagicImmune() and not target:HasModifier('modifier_lycan_howl') then
        return J.IsValidBuilding(target) and J.CanBeAttacked(target) or J.IsRoshan(target)
            or J.IsFarming(bot) and #bot:GetNearbyNeutralCreeps(600)>=2
    end
    return false
end
function X.ShapeUseful(a)
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_lycan_shapeshift') then return false end
    local target = J.GetProperTarget(bot)
    if J.IsRetreating(bot) and not bot:IsRooted() and J.GetHP(bot)<0.65 then
        for _,u in pairs(J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)) do
            if Enemy(u) and J.IsChasingTarget(u,bot) and not J.IsDisabled(u) then return true end
        end
    end
    -- A copied transformation also reduces ranged attack reach to melee range.
    return bot:GetAttackRange()<=325 and (J.IsInTeamFight(bot,1000)
        or J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsInRange(bot,target,900))
end
function X.BiteTarget(a)
    local shape = bot:GetAbilityByName('lycan_shapeshift')
    if not J.CanCastAbility(a) or shape==nil or not shape:IsTrained() then return nil end
    local lens = J.IsItemAvailable('item_aether_lens')
    local range = a:GetCastRange()+(lens~=nil and lens:GetSpecialValueInt('cast_range_bonus') or 0)
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    local best,damage = nil,0
    for _,ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and ally:GetAttackRange()<=325 and not J.IsDisabled(ally) and J.IsInRange(bot,ally,range)
            and not ally:HasModifier('modifier_lycan_shapeshift') and not ally:HasModifier('modifier_lycan_wolf_bite')
            and J.IsGoingOnSomeone(ally) and Enemy(J.GetProperTarget(ally))
            and J.IsInRange(ally,J.GetProperTarget(ally),900) and ally:GetAttackDamage()>damage then
            best,damage=ally,ally:GetAttackDamage()
        end
    end
    return best
end
function X.UseHightail(wolf)
    if wolf==nil or not J.IsValid(wolf) or not string.find(wolf:GetUnitName(),'npc_dota_lycan_wolf')
        or wolf:GetPlayerID()~=bot:GetPlayerID() or J.CanNotUseAbility(wolf) then return false end
    local hightail = wolf:GetAbilityByName('lycan_summon_wolves_hightail')
    if not J.CanCastAbility(hightail) or wolf:HasModifier('modifier_lycan_summon_wolves_hightail') then return false end
    local target = wolf:GetAttackTarget()
    if Enemy(target) and J.IsInRange(wolf,target,700)
        or J.GetHP(wolf)<0.4 and wolf:WasRecentlyDamagedByAnyHero(2) then
        wolf:Action_UseAbility(hightail); return true
    end
    return false
end
function X.ConsiderStolenSpell(a)
    local name = a:GetName()
    if name~='lycan_summon_wolves' and name~='lycan_howl' and name~='lycan_shapeshift' and name~='lycan_wolf_bite' then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) then return false end
    local target = name=='lycan_wolf_bite' and X.BiteTarget(a) or nil
    local useful = name=='lycan_summon_wolves' and X.SummonUseful(a)
        or name=='lycan_howl' and X.HowlUseful(a) or name=='lycan_shapeshift' and X.ShapeUseful(a) or target~=nil
    if not useful then return false end
    J.SetQueuePtToINT(bot,true,a)
    if target~=nil then bot:ActionQueue_UseAbilityOnEntity(a,target) else bot:ActionQueue_UseAbility(a) end
    return true
end
return X
