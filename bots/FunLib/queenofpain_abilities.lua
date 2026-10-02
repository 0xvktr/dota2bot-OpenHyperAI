local Q={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function Q.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function enemy(unit,pierce)
    return J.IsValid(unit) and not J.IsSuspiciousIllusion(unit) and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit))
        and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave')
        and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function screamBudget(bot,ability,origin)
    local count=0
    for _,unit in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if enemy(unit,false) and J.IsValidHero(unit) and GetUnitToLocationDistance(unit,origin)<=ability:GetSpecialValueInt('area_of_effect') then count=count+1 end
    end
    return bot:GetHealth()-count*ability:GetSpecialValueInt('damage')*ability:GetSpecialValueFloat('damage_reflected_to_self')/100>=bot:GetMaxHealth()*0.18
end
function Q.Strike(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil,nil end
    local pointCast=ability:GetSpecialValueInt('aoe_radius')>0
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(Q.Range(bot,ability),1600),true,BOT_MODE_NONE)) do
        if enemy(unit,false) and (pointCast or J.CanCastOnTargetAdvanced(unit)) then
            local refresh=unit:HasModifier('modifier_queenofpain_shadow_strike')
            local damage=ability:GetSpecialValueInt('strike_damage')
            local scream=bot:GetAbilityByName('queenofpain_scream_of_pain')
            local burst=refresh and pointCast and ability:GetSpecialValueInt('generate_scream')>0
                and scream and not scream:IsNull() and scream:IsTrained() and scream:IsActivated() and not scream:IsHidden()
            if burst then damage=damage+scream:GetSpecialValueInt('damage') end
            local speed=ability:GetSpecialValueInt('projectile_speed')
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/(speed>0 and speed or 900)
            local kill=J.WillKillTarget(unit,damage,DAMAGE_TYPE_MAGICAL,delay)
            local useful=J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsLaning(bot) and J.IsAllowedToSpam(bot,ability:GetManaCost())
                or J.IsRetreating(bot) and unit:GetAttackTarget()==bot
            if (kill or useful and (not refresh or burst)) and (not burst or kill or screamBudget(bot,scream,unit:GetLocation())) then
                if pointCast then
                    local point=unit:GetExtrapolatedLocation(ability:GetCastPoint())
                    if GetUnitToLocationDistance(bot,point)<=Q.Range(bot,ability) then return BOT_ACTION_DESIRE_HIGH,point,'point' end
                else return BOT_ACTION_DESIRE_HIGH,unit,'unit' end
            end
        end
    end
    return 0,nil,nil
end
function Q.Scream(bot,ability)
    if not J.CanCastAbility(ability) then return 0 end
    local useful=false;local lethal=false
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(ability:GetSpecialValueInt('area_of_effect'),1600),true,BOT_MODE_NONE)) do
        if enemy(unit,false) then
            lethal=lethal or J.WillKillTarget(unit,ability:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/math.max(ability:GetSpecialValueInt('projectile_speed'),900))
            useful=useful or J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and unit:GetAttackTarget()==bot
        end
    end
    if lethal or useful and screamBudget(bot,ability,bot:GetLocation()) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local function toward(bot,point,range)
    local dx,dy=point.x-bot:GetLocation().x,point.y-bot:GetLocation().y;local length=math.sqrt(dx*dx+dy*dy)
    if length==0 then return bot:GetLocation() end
    local step=math.min(length,range)
    return Vector(bot:GetLocation().x+dx*step/length,bot:GetLocation().y+dy*step/length,0)
end
local function safe(point)
    return IsLocationPassable(point) and not J.IsLocHaveTower(700,true,point)
        and not J.IsEnemyChronosphereInLocation(point) and not J.IsEnemyBlackHoleInLocation(point)
end
function Q.Blink(bot,ability,defensiveOnly)
    if not J.CanCastAbility(ability) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture')
        or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled')
        or bot:HasModifier('modifier_grimstroke_soul_chain') then return 0,nil end
    -- Bound the displacement itself; never aim far beyond it and trigger overshoot behavior.
    local range=ability:GetCastRange()
    if J.IsStuck(bot) or J.IsStunProjectileIncoming(bot,1000) or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        local point=toward(bot,J.GetEscapeLoc(),range)
        if GetUnitToLocationDistance(bot,point)>=ability:GetSpecialValueInt('min_blink_range') and safe(point) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    if defensiveOnly then return 0,nil end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and enemy(target,true)
        and not J.IsInRange(bot,target,bot:GetAttackRange()+50) and J.GetHP(bot)>0.5 then
        local destination=toward(bot,target:GetLocation(),math.max(0,GetUnitToUnitDistance(bot,target)-330))
        destination=toward(bot,destination,range)
        if GetUnitToLocationDistance(bot,destination)<ability:GetSpecialValueInt('min_blink_range') or not safe(destination)
            or #J.GetEnemiesNearLoc(destination,700)>#J.GetAlliesNearLoc(destination,700)+1 then return 0,nil end
        local follow=false
        for _,name in pairs({'queenofpain_shadow_strike','queenofpain_scream_of_pain','queenofpain_sonic_wave'}) do
            local spell=bot:GetAbilityByName(name)
            if J.CanCastAbility(spell) and bot:GetMana()>=ability:GetManaCost()+spell:GetManaCost()
                and (name=='queenofpain_sonic_wave' or J.CanCastOnNonMagicImmune(target)) then follow=true end
        end
        if follow then return BOT_ACTION_DESIRE_HIGH,destination end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot)) and J.IsValid(target) and not J.IsValidHero(target)
        and #J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)==0 and J.GetMP(bot)>0.7
        and GetUnitToUnitDistance(bot,target)>900 then
        local point=toward(bot,target:GetLocation(),range)
        if safe(point) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    return 0,nil
end
local function inCone(bot,ability,direction,unit)
    local origin=bot:GetLocation();local dx,dy=direction.x-origin.x,direction.y-origin.y
    local length=math.sqrt(dx*dx+dy*dy);if length==0 then return false end
    dx,dy=dx/length,dy/length
    local point=unit:GetExtrapolatedLocation(ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('speed'))
    local x,y=point.x-origin.x,point.y-origin.y;local along=x*dx+y*dy;local distance=ability:GetSpecialValueInt('distance')
    local width=ability:GetSpecialValueInt('starting_aoe')+(ability:GetSpecialValueInt('final_aoe')-ability:GetSpecialValueInt('starting_aoe'))*along/math.max(distance,1)
    return along>=0 and along<=distance and math.abs(x*dy-y*dx)<=width
end
function Q.Wave(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local enemies=J.GetNearbyHeroes(bot,math.min(ability:GetSpecialValueInt('distance')+ability:GetSpecialValueInt('final_aoe'),1600),true,BOT_MODE_NONE)
    for _,unit in pairs(enemies) do
        if enemy(unit,true) then
            local point=toward(bot,unit:GetExtrapolatedLocation(ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('speed')),Q.Range(bot,ability))
            if inCone(bot,ability,point,unit) then
                local count=0
                for _,other in pairs(enemies) do if enemy(other,true) and inCone(bot,ability,point,other) then count=count+1 end end
                if J.WillKillTarget(unit,ability:GetSpecialValueInt('damage'),DAMAGE_TYPE_PURE,ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('speed'))
                    or J.IsInTeamFight(bot,1200) and count>=2
                    or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) and count>=2 then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    return 0,nil
end
return Q
