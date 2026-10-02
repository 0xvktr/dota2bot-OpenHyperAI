local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local host, enteredAt, requestedAt, observedEntry
local function Range(a)
    local lens=J.IsItemAvailable('item_aether_lens')
    local range=a:GetCastRange()+(lens~=nil and lens:GetSpecialValueInt('cast_range_bonus') or 0)
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
function X.RecordHost(unit)
    host=unit;requestedAt=DotaTime();enteredAt=nil;observedEntry=false
end
function X.InfestTarget(a)
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_life_stealer_infest') then return nil end
    local linked=bot:GetAbilityByName('life_stealer_consume')
    if linked==nil or linked:IsNull() or not linked:IsTrained() then return nil end
    local range=Range(a)
    local allies=J.GetNearbyHeroes(bot,math.min(1600,range),false,BOT_MODE_NONE)
    for _,ally in pairs(allies) do
        if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion()
            and not J.IsMeepoClone(ally) and not ally:IsInvulnerable()
            and J.GetHP(ally)<0.3 and ally:WasRecentlyDamagedByAnyHero(2) then return ally end
    end
    local target=J.GetProperTarget(bot)
    if bot:HasScepter() and J.IsGoingOnSomeone(bot) and J.IsValidHero(target)
        and not J.IsSuspiciousIllusion(target) and J.CanCastOnMagicImmune(target)
        and J.CanCastOnTargetAdvanced(target) and J.IsInRange(bot,target,range)
        and not J.CannotBeKilled(bot,target) and J.GetHP(bot)<0.65 then return target end
    if J.IsRetreating(bot) and J.GetHP(bot)<0.4 and bot:WasRecentlyDamagedByAnyHero(2) then
        for _,ally in pairs(allies) do
            if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion()
                and not J.IsMeepoClone(ally) and not ally:IsInvulnerable()
                and J.GetHP(ally)>0.5 and J.IsRetreating(ally) then return ally end
        end
        for _,creep in pairs(bot:GetNearbyLaneCreeps(range,false)) do
            if J.IsValid(creep) and not creep:IsInvulnerable() then return creep end
        end
    end
    return nil
end
function X.UseConsume()
    local consume=bot:GetAbilityByName('life_stealer_consume')
    local infest=bot:GetAbilityByName('life_stealer_infest')
    if host~=nil and (host:IsNull() or not host:IsAlive()) then host,enteredAt,requestedAt=nil,nil,nil end
    if not bot:HasModifier('modifier_life_stealer_infest') then
        -- Item preparation and the queued cast precede the actual infestation marker.
        if observedEntry or requestedAt~=nil and DotaTime()-requestedAt>3 then
            host,enteredAt,requestedAt=nil,nil,nil;observedEntry=false
        end
        return false
    end
    if not observedEntry then enteredAt=DotaTime();observedEntry=true end
    if not bot:IsAlive() or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active')
        or not J.CanCastAbility(consume) or infest==nil or not infest:IsTrained()
        or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility()
        or J.HasQueuedAction(bot) then return false end
    if host==nil or host:IsNull() or not host:IsAlive() then return false end
    -- Scepter's enemy-host attacks/healing last four seconds; do not immediately cancel them.
    if host:GetTeam()~=bot:GetTeam() and host:IsHero() then return false end
    local radius=infest:GetSpecialValueInt('radius')
    local elapsed=DotaTime()-(enteredAt or DotaTime())
    local ready=J.GetHP(bot)>0.9 and elapsed>3
    if J.GetHP(host)<0.2 and J.GetHP(bot)>0.5 then ready=true end
    for _,enemy in pairs(J.GetNearbyHeroes(host,math.min(1600,radius),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and not J.CannotBeKilled(bot,enemy)
            and (J.WillKillTarget(enemy,infest:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,0)
                or J.GetHP(bot)>0.75 and J.IsGoingOnSomeone(bot)) then ready=true end
    end
    if ready then bot:Action_UseAbility(consume);host,enteredAt,requestedAt=nil,nil,nil;observedEntry=false;return true end
    return false
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='life_stealer_rage' and name~='life_stealer_unfettered'
        and name~='life_stealer_open_wounds' and name~='life_stealer_infest'
        and name~='life_stealer_consume' then return nil end
    if name=='life_stealer_consume' then return X.UseConsume() end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a)
        or bot:HasModifier('modifier_life_stealer_infest') then return false end
    if name=='life_stealer_infest' then
        local target=X.InfestTarget(a)
        if target~=nil then J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbilityOnEntity(a,target);X.RecordHost(target);return true end
    elseif name=='life_stealer_open_wounds' then
        local target=J.GetProperTarget(bot)
        if J.IsValidHero(target) and J.CanCastOnNonMagicImmune(target)
            and J.CanCastOnTargetAdvanced(target) and not J.IsSuspiciousIllusion(target)
            and not target:HasModifier('modifier_life_stealer_open_wounds')
            and J.IsInRange(bot,target,Range(a)) and J.IsGoingOnSomeone(bot)
            and (J.IsAttacking(bot) or J.IsChasingTarget(bot,target)) then
            J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbilityOnEntity(a,target);return true
        end
    elseif not bot:IsMagicImmune() and not bot:HasModifier('modifier_life_stealer_rage')
        and (J.IsStunProjectileIncoming(bot,550) or bot:IsRooted() and J.IsRetreating(bot)
            or bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,600,true,BOT_MODE_NONE)>0
                and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot))) then
        J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbility(a);return true
    end
    return false
end
return X
