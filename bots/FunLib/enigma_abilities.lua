local E = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
function E.CastRange(bot, ability)
    local bonus = 0
    for slot=0,5 do
        local item=bot:GetItemInSlot(slot)
        if item and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end
    end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
function E.Bound(bot, point, range)
    local origin=bot:GetLocation()
    local x,y=point.x-origin.x,point.y-origin.y
    local length=math.sqrt(x*x+y*y)
    if length<=range then return point end
    return Vector(origin.x+x*range/length,origin.y+y*range/length,origin.z)
end
function E.HoleTargets(point, radius, delay)
    local targets={}
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy)
            and GetUnitToLocationDistance(enemy, point) <= radius
            and J.GetLocationToLocationDistance(J.GetCorrectLoc(enemy, delay or 0), point) <= radius
            and not enemy:HasModifier('modifier_item_aeon_disk_buff')
            and not enemy:HasModifier('modifier_faceless_void_chronosphere_freeze') then
            targets[#targets+1]=enemy
        end
    end
    return targets
end
function E.Hole(bot, ability, range)
    if not J.CanCastAbility(ability) then return 0,nil end
    local delay=ability:GetCastPoint() + (range and 0.1 or 0)
    range=range or E.CastRange(bot,ability)
    local radius=ability:GetSpecialValueInt('radius')
    local target=J.GetProperTarget(bot)
    if J.IsInTeamFight(bot,1200) then
        local aoe=bot:FindAoELocation(true,true,bot:GetLocation(),range,radius*0.85,ability:GetCastPoint(),0)
        local point=E.Bound(bot,aoe.targetloc,range)
        if #E.HoleTargets(point,radius,delay)>=2 then return BOT_ACTION_DESIRE_HIGH,point end
    end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnMagicImmune(target)
        and not target:HasModifier('modifier_abaddon_borrowed_time')
        and not target:HasModifier('modifier_dazzle_shallow_grave')
        and not target:HasModifier('modifier_oracle_false_promise_timer') then
        local point=E.Bound(bot,J.GetCorrectLoc(target,delay),range)
        local targets=E.HoleTargets(point,radius,delay)
        if #targets>=2 then return BOT_ACTION_DESIRE_HIGH,point end
        local damage=ability:GetSpecialValueInt('damage')*ability:GetSpecialValueFloat('duration')
        if bot:HasScepter() then damage=damage+target:GetMaxHealth()*ability:GetSpecialValueInt('scepter_pct_damage')/100*ability:GetSpecialValueFloat('duration') end
        if #targets==1 and targets[1]==target and target:GetHealth()>200
            and J.CanKillTarget(target,damage,DAMAGE_TYPE_PURE) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    return 0,nil
end
function E.Pulse(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range,radius=E.CastRange(bot,ability),ability:GetSpecialValueInt('radius')
    local target=J.GetProperTarget(bot)
    if J.IsInTeamFight(bot,1200) then
        local aoe=bot:FindAoELocation(true,true,bot:GetLocation(),range,radius*0.8,ability:GetCastPoint(),0)
        local point=E.Bound(bot,aoe.targetloc,range)
        if #E.HoleTargets(point,radius)>=2 then return BOT_ACTION_DESIRE_HIGH,point end
    end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnMagicImmune(target) then
        local point=E.Bound(bot,J.GetCorrectLoc(target,ability:GetCastPoint()),range)
        if GetUnitToLocationDistance(target,point)<=radius*0.8 then return BOT_ACTION_DESIRE_HIGH,point end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target)
        and (J.IsRoshan(target) or J.IsTormentor(target)) and J.IsInRange(bot,target,range) then
        return BOT_ACTION_DESIRE_HIGH,target:GetLocation()
    end
    return 0,nil
end
return E
