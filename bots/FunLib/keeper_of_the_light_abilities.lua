local K={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function K.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    local form=bot:GetAbilityByName('keeper_of_the_light_spirit_form')
    if form and form:IsTrained() and bot:HasModifier('modifier_keeper_of_the_light_spirit_form') then bonus=bonus+form:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
function K.Chakra(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local candidates={bot};for _,ally in pairs(J.GetNearbyHeroes(bot,K.Range(bot,ability),false,BOT_MODE_NONE)) do candidates[#candidates+1]=ally end
    local best,score=nil,0
    for _,ally in pairs(candidates) do
        if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally) then
            local bonus=ally==bot and 1+ability:GetSpecialValueInt('self_bonus')/100 or 1
            local mana=math.min(ally:GetMaxMana()-ally:GetMana(),ability:GetSpecialValueInt('mana_restore')*bonus)
            local cooldown=0
            for slot=0,23 do
                local spell=ally:GetAbilityInSlot(slot)
                if spell and spell:IsTrained() and not spell:IsPassive() and not spell:IsHidden() and not spell:IsUltimate() then
                    cooldown=cooldown+math.min(spell:GetCooldownTimeRemaining(),ability:GetSpecialValueFloat('cooldown_reduction')*bonus)
                end
            end
            local value=mana+cooldown*50
            if ability:GetSpecialValueInt('strong_dispel')>0 and (ally:IsRooted() or ally:IsSilenced() or ally:IsStunned()) then value=value+1000 end
            if value>score and value>=75 then best,score=ally,value end
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH,best end
    return 0,nil
end
function K.Blind(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=K.Range(bot,ability);local radius=ability:GetSpecialValueInt('radius')
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(1600,range+radius),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and not enemy:HasModifier('modifier_enigma_black_hole_pull') and not enemy:HasModifier('modifier_faceless_void_chronosphere_freeze') then
            local awayFrom=nil
            if J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then awayFrom=bot end
            for _,ally in pairs(J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)) do
                if J.IsValidHero(ally) and J.IsRetreating(ally) and J.IsChasingTarget(enemy,ally) then awayFrom=ally;break end
            end
            local point=enemy:GetExtrapolatedLocation(ability:GetCastPoint())
            if awayFrom then
                -- Origin on ally's side: knockback travels away from the ally.
                point=point+(awayFrom:GetLocation()-point):Normalized()*(radius*0.4)
            elseif J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) then
                point=point+(point-bot:GetLocation()):Normalized()*(radius*0.4)
            elseif not J.CanKillTarget(enemy,ability:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL) then point=nil end
            if point and GetUnitToLocationDistance(bot,point)<=range and GetUnitToLocationDistance(enemy,point)<radius then
                return BOT_ACTION_DESIRE_HIGH,point
            end
        end
    end
    return 0,nil
end
function K.Wisp(bot,ability)
    if not J.CanCastAbility(ability) or not J.IsInTeamFight(bot,1200) then return 0,nil end
    local range=K.Range(bot,ability);local radius=ability:GetSpecialValueInt('radius')
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(1600,range+radius),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) then
            local point=enemy:GetExtrapolatedLocation(ability:GetCastPoint())
            if GetUnitToLocationDistance(bot,point)>range then point=bot:GetLocation()+(point-bot:GetLocation()):Normalized()*range end
            local count=0
            for _,other in pairs(J.GetEnemiesNearLoc(point,radius)) do if J.IsValidHero(other) and J.CanCastOnNonMagicImmune(other) then count=count+1 end end
            if count>=2 then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    -- Pull is explicitly non-interrupting; no fake TP cancellation.
    return 0,nil
end
function K.Form(bot,ability)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_keeper_of_the_light_spirit_form') then return 0 end
    if J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot) and J.IsValidHero(J.GetProperTarget(bot)) then return BOT_ACTION_DESIRE_HIGH end
    for _,ally in pairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and J.GetHP(ally)<0.6 and not ally:HasModifier('modifier_ice_blast') then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function K.Bind(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,K.Range(bot,ability),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_keeper_of_the_light_radiant_bind')
            and (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) or J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot)) then
            return BOT_ACTION_DESIRE_HIGH,enemy
        end
    end
    return 0,nil
end
function K.Record(bot,ability,point,state)
    state.started=DotaTime();state.origin=bot:GetLocation();state.point=point;state.source=ability
end
local function inWave(unit,state,range,width,delay)
    local p=unit:GetExtrapolatedLocation(delay);local dx,dy=state.point.x-state.origin.x,state.point.y-state.origin.y
    local length=math.sqrt(dx*dx+dy*dy);if length==0 then return false end
    dx,dy=dx/length,dy/length
    local x,y=p.x-state.origin.x,p.y-state.origin.y;local along=x*dx+y*dy
    return along>=0 and along<=range and math.abs(x*dy-y*dx)<=width
end
function K.Release(bot,release,state)
    local source=state.source
    if not state.started or not source or source:IsNull() or not J.CanCastAbility(release)
        or not bot:IsAlive() or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsCastingAbility() or bot:NumQueuedActions()>0 or bot:IsInvulnerable()
        or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local current=bot:GetCurrentActiveAbility()
    local ownChannel=bot:IsChanneling() and current and current:GetName()=='keeper_of_the_light_illuminate'
    local spirit=bot:HasModifier('modifier_keeper_of_the_light_spirit_form') and not bot:IsChanneling()
    if not ownChannel and (not spirit or bot:IsUsingAbility()) then return false end
    local elapsed=DotaTime()-state.started
    local maximum=source:GetSpecialValueFloat('max_channel_time')
    if maximum<=0 or elapsed<0 or elapsed>maximum+0.5 then return false end
    local damage=source:GetSpecialValueInt('total_damage')*math.min(1,elapsed/maximum)
    local target=state.target
    if elapsed>=maximum or target and J.IsValid(target) and J.CanCastOnNonMagicImmune(target)
        and inWave(target,state,source:GetSpecialValueInt('range'),source:GetSpecialValueInt('radius'),GetUnitToLocationDistance(target,state.origin)/source:GetSpecialValueInt('speed'))
        and J.CanKillTarget(target,damage,DAMAGE_TYPE_MAGICAL) then
        bot:Action_UseAbility(release);state.started=nil;return true
    end
    return false
end
function K.Illuminate(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local form=bot:HasModifier('modifier_keeper_of_the_light_spirit_form')
    if not form and #J.GetNearbyHeroes(bot,500,true,BOT_MODE_NONE)>0 then return 0,nil end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,ability:GetSpecialValueInt('range'),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)) then
            local point=enemy:GetExtrapolatedLocation(ability:GetSpecialValueFloat('max_channel_time')+GetUnitToUnitDistance(bot,enemy)/ability:GetSpecialValueInt('speed'))
            if GetUnitToLocationDistance(bot,point)<=ability:GetSpecialValueInt('range') then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if form then
        for _,ally in pairs(J.GetNearbyHeroes(bot,ability:GetSpecialValueInt('range'),false,BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and J.GetHP(ally)<0.6 and not ally:HasModifier('modifier_ice_blast') then return BOT_ACTION_DESIRE_HIGH,ally:GetLocation() end
        end
    end
    return 0,nil
end
return K
