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
function X.SpikePoint(a,u)
    if not Enemy(u) then return nil end
    local point=J.GetCorrectLoc(u,a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('speed'))
    local offset=point-bot:GetLocation()
    local range=Range(a)
    if offset:Length2D()>range+a:GetSpecialValueInt('length_buffer') then return nil end
    return offset:Length2D()>range and bot:GetLocation()+offset:Normalized()*range or point
end
function X.HexTarget(a)
    if not J.CanCastAbility(a) then return nil end
    local target=J.GetProperTarget(bot)
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,Range(a)),true,BOT_MODE_NONE)) do
        if Enemy(u) and J.CanCastOnTargetAdvanced(u) and u:IsChanneling() then return u end
    end
    if Enemy(target) and J.CanCastOnTargetAdvanced(target) and J.IsInRange(bot,target,Range(a))
        and not J.IsDisabled(target) and J.IsGoingOnSomeone(bot) then return target end
    return nil
end
function X.FingerTarget(a)
    if not J.CanCastAbility(a) or a:GetAutoCastState() then return nil end
    local damage=a:GetSpecialValueInt('damage')+J.GetModifierCount(bot,'modifier_lion_finger_of_death_kill_counter')*a:GetSpecialValueInt('damage_per_kill')
    local best,score=nil,1
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,Range(a)),true,BOT_MODE_NONE)) do
        if Enemy(u) and J.CanCastOnTargetAdvanced(u) and not J.CannotBeKilled(bot,u) then
            if J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,a:GetCastPoint()+a:GetSpecialValueFloat('damage_delay')) then return u end
            if bot:HasScepter() and J.IsInTeamFight(bot,1200) then
                local count=0
                for _,other in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
                    if Enemy(other) and J.IsInRange(u,other,a:GetSpecialValueInt('splash_radius')) then count=count+1 end
                end
                if count>score then best,score=u,count end
            end
        end
    end
    return best
end
function X.DrainTarget(a)
    if not J.CanCastAbility(a) or J.IsRetreating(bot) then return nil end
    local range=Range(a)
    local enemies=J.GetNearbyHeroes(bot,math.min(1600,range),true,BOT_MODE_NONE)
    for _,u in pairs(enemies) do
        if J.IsValidHero(u) and u:IsIllusion() and not u:IsMagicImmune()
            and not u:IsInvulnerable() and u:GetUnitName()~='npc_dota_hero_chaos_knight'
            and u:GetUnitName()~='npc_dota_hero_vengefulspirit'
            and not u:HasModifier('modifier_item_sphere_target')
            and not u:HasModifier('modifier_item_lotus_orb_active')
            and not u:HasModifier('modifier_antimage_spell_shield') then return u end
    end
    local target=J.GetProperTarget(bot)
    if Enemy(target) and J.IsInRange(bot,target,range) and J.CanCastOnTargetAdvanced(target)
        and target:GetMana()>50 and J.IsDisabled(target) then return target end
    if #J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)>0 or bot:WasRecentlyDamagedByAnyHero(2) then return nil end
    if bot:GetMana()/bot:GetMaxMana()>0.6 then
        for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,range),false,BOT_MODE_NONE)) do
            if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
                and ally:GetMana()/ally:GetMaxMana()<0.3 then return ally end
        end
    end
    if bot:GetMaxMana()-bot:GetMana()>150 then
        for _,creep in pairs(bot:GetNearbyCreeps(range,true)) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep)
                and creep:GetMana()>150 then return creep end
        end
    end
    return nil
end
function X.StopDrain()
    if not bot:IsChanneling() then return false end
    local active=bot:GetCurrentActiveAbility()
    if active==nil or active:GetName()~='lion_mana_drain' then return false end
    if J.IsRetreating(bot) and (bot:WasRecentlyDamagedByAnyHero(2)
        or #J.GetNearbyHeroes(bot,600,true,BOT_MODE_NONE)>0) then bot:Action_ClearActions(true);return true end
    return false
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='lion_impale' and name~='lion_voodoo' and name~='lion_mana_drain' and name~='lion_finger_of_death' then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(a) then return false end
    local target
    if name=='lion_voodoo' then target=X.HexTarget(a)
    elseif name=='lion_finger_of_death' then target=X.FingerTarget(a)
    elseif name=='lion_mana_drain' then target=X.DrainTarget(a)
    else
        target=J.GetProperTarget(bot)
        for _,u in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
            if Enemy(u) and u:IsChanneling() and X.SpikePoint(a,u)~=nil then target=u;break end
        end
        if not Enemy(target) or not (target:IsChanneling() or J.IsGoingOnSomeone(bot)
            or J.IsRetreating(bot) and J.IsChasingTarget(target,bot)) then return false end
    end
    if target==nil then return false end
    local point=name=='lion_impale' and X.SpikePoint(a,target) or nil
    if name=='lion_impale' and point==nil then return false end
    J.SetQueuePtToINT(bot,true,a)
    if point~=nil then bot:ActionQueue_UseAbilityOnLocation(a,point)
    else bot:ActionQueue_UseAbilityOnEntity(a,target) end
    return true
end
return X
