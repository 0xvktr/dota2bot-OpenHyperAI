local M={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local epicenterIntent=nil
local function distance(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
local function toward(bot,point,range)
    local origin=bot:GetLocation();local dx,dy=point.x-origin.x,point.y-origin.y;local length=math.sqrt(dx*dx+dy*dy)
    if length==0 then return origin end
    local step=math.min(length,range)
    return Vector(origin.x+dx*step/length,origin.y+dy*step/length,0)
end
function M.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function enemy(unit,physical)
    return J.IsValid(unit) and unit:CanBeSeen() and (physical and J.CanBeAttacked(unit) or not physical and J.CanCastOnNonMagicImmune(unit))
        and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave')
        and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace') and not unit:HasModifier('modifier_item_blade_mail_reflect')
end
local function canMove(bot)
    return not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_slark_pounce_leash')
        and not bot:HasModifier('modifier_puck_coiled') and not bot:HasModifier('modifier_grimstroke_soul_chain')
end
local function safe(bot,point)
    if not IsLocationPassable(point) or J.GetHP(bot)<.35 then return false end
    local foes,friends=0,1
    for _,unit in pairs(J.GetEnemiesNearLoc(point,700)) do if J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) then foes=foes+1 end end
    for _,unit in pairs(J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)) do if unit~=bot and J.IsValidHero(unit) and not unit:IsIllusion() and GetUnitToLocationDistance(unit,point)<=900 then friends=friends+1 end end
    for _,tower in pairs(bot:GetNearbyTowers(1600,true)) do if J.IsValid(tower) and GetUnitToLocationDistance(tower,point)<=tower:GetAttackRange()+100 then return false end end
    return foes<=friends+1
end
local function blink(bot)
    if bot:IsMuted() or not canMove(bot) then return nil end
    for slot=0,5 do local item=bot:GetItemInSlot(slot)
        if item and not item:IsNull() and item:IsFullyCastable() then local name=item:GetName()
            if name=='item_blink' or name=='item_overwhelming_blink' or name=='item_arcane_blink' or name=='item_swift_blink' then return item end
        end
    end
end
local function lineHit(bot,ability,unit,point,delay)
    local origin=bot:GetLocation();local dx,dy=point.x-origin.x,point.y-origin.y;local length=distance(origin,point)
    if length==0 then return distance(origin,unit:GetExtrapolatedLocation(delay))<=ability:GetSpecialValueInt('burrow_width') end
    dx,dy=dx/length,dy/length
    local predicted=unit:GetExtrapolatedLocation(delay);local x,y=predicted.x-origin.x,predicted.y-origin.y;local along=x*dx+y*dy
    return along>=0 and along<=length and math.abs(x*dy-y*dx)<=ability:GetSpecialValueInt('burrow_width')
end
function M.Burrow(bot,ability,native)
    if not J.CanCastAbility(ability) or not canMove(bot) then return 0,nil end
    -- Burrow physically moves to its endpoint: do not add approach padding or cast bonuses to the displacement.
    local range=ability:GetCastRange();local damage=ability:GetAbilityDamage()
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range+ability:GetSpecialValueInt('burrow_width'),1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and not J.IsSuspiciousIllusion(unit) then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('burrow_speed')
            local point=toward(bot,unit:GetExtrapolatedLocation(delay),range)
            local peel=false
            for _,ally in pairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do if J.IsValidHero(ally) and unit:GetAttackTarget()==ally and J.GetHP(ally)<.5 then peel=true;break end end
            if lineHit(bot,ability,unit,point,delay) and safe(bot,point) and (unit:IsChanneling() or peel
                or J.WillKillTarget(unit,damage,DAMAGE_TYPE_MAGICAL,delay) or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsInTeamFight(bot,1200) and not J.IsDisabled(unit)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        local point=toward(bot,J.GetEscapeLoc(),range)
        if IsLocationPassable(point) and GetUnitToLocationDistance(GetAncient(GetTeam()),point)<GetUnitToUnitDistance(bot,GetAncient(GetTeam())) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
        for _,unit in pairs(creeps) do
            if enemy(unit) and not unit:HasModifier('modifier_fountain_glyph') and (J.IsLaning(bot) and string.find(unit:GetUnitName(),'ranged') and J.WillKillTarget(unit,damage,DAMAGE_TYPE_MAGICAL,GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('burrow_speed'))
                or #creeps>=3 and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))) then
                local point=toward(bot,unit:GetLocation(),range);local hits=0
                for _,creep in pairs(creeps) do if enemy(creep) and lineHit(bot,ability,creep,point,0) then hits=hits+1 end end
                if (J.IsLaning(bot) or hits>=3) and safe(bot,point) then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
        local target=J.GetProperTarget(bot)
        if J.IsDoingRoshan(bot) and J.IsRoshan(target) and enemy(target) and J.IsInRange(bot,target,range) and safe(bot,target:GetLocation()) then return BOT_ACTION_DESIRE_HIGH,target:GetLocation() end
    end
    return 0,nil
end
function M.Storm(bot,ability,native)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_sandking_sand_storm') then return 0 end
    local radius=ability:GetSpecialValueInt('sand_storm_radius')
    if J.IsStunProjectileIncoming(bot,350) then return BOT_ACTION_DESIRE_HIGH end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and (J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
            or J.IsRetreating(bot) and unit:GetAttackTarget()==bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then
        local count=0;for _,unit in pairs(bot:GetNearbyCreeps(math.min(radius,1600),true)) do if enemy(unit) and not unit:HasModifier('modifier_fountain_glyph') then count=count+1 end end
        if count>=3 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function M.Stinger(bot,ability,native)
    if not J.CanCastAbility(ability) or bot:IsDisarmed() then return 0,nil end
    local range=M.Range(bot,ability);local radius=ability:GetSpecialValueInt('radius')
    local function hit(unit)
        local predicted=unit:GetExtrapolatedLocation(ability:GetCastPoint());local point=toward(bot,predicted,range)
        if distance(predicted,point)>radius then return nil end
        local damage=bot:GetAttackDamage()+ability:GetSpecialValueInt('attack_damage')
        if distance(predicted,point)<=ability:GetSpecialValueInt('inner_radius') then damage=damage*(1+ability:GetSpecialValueInt('inner_radius_bonus_damage_pct')/100) end
        return point,damage
    end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)) do
        if enemy(unit,true) and not J.IsSuspiciousIllusion(unit) then local point,damage=hit(unit)
            if point and (J.WillKillTarget(unit,damage,DAMAGE_TYPE_PHYSICAL,ability:GetCastPoint()) or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsInTeamFight(bot,1200) or J.IsRetreating(bot) and unit:GetAttackTarget()==bot) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(math.min(range+radius,1600),true)
        for _,unit in pairs(creeps) do if enemy(unit,true) and not unit:HasModifier('modifier_fountain_glyph') then local point,damage=hit(unit)
            if point and (J.IsLaning(bot) and J.WillKillTarget(unit,damage,DAMAGE_TYPE_PHYSICAL,ability:GetCastPoint())
                or #creeps>=3 and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))) then return BOT_ACTION_DESIRE_HIGH,point end
        end end
        local target=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target)) and enemy(target,true) then local point=hit(target);if point then return BOT_ACTION_DESIRE_HIGH,point end end
    end
    return 0,nil
end
function M.Epicenter(bot,ability)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_sand_king_epicenter') or J.GetHP(bot)<.45 then return 0,nil end
    if not J.IsGoingOnSomeone(bot) and not J.IsInTeamFight(bot,1600) then return 0,nil end
    local mover=blink(bot);local burrow=bot:GetAbilityByName('sandking_burrowstrike');local range=ability:GetSpecialValueInt('epicenter_radius_base')
    local reach=range*.75
    if mover then reach=range*.75+mover:GetSpecialValueInt('blink_range') elseif J.CanCastAbility(burrow) and canMove(bot) and bot:GetMana()>=ability:GetManaCost()+burrow:GetManaCost() then reach=range*.75+burrow:GetCastRange() end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(reach,1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and not J.IsSuspiciousIllusion(unit) then
            local point=unit:GetExtrapolatedLocation(ability:GetCastPoint())
            local count=0;for _,other in pairs(J.GetEnemiesNearLoc(point,range)) do if enemy(other) and J.IsValidHero(other) and not J.IsSuspiciousIllusion(other) then count=count+1 end end
            local close=GetUnitToLocationDistance(bot,point)<=range*.75
            local protected=bot:IsInvisible() or bot:IsMagicImmune() or not close or J.IsDisabled(unit)
            local attacked=false;for _,other in pairs(J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE)) do if J.IsValidHero(other) and other:GetAttackTarget()==bot and not J.IsDisabled(other) then attacked=true;break end end
            if count>=2 and GetUnitToLocationDistance(bot,point)<=reach and protected and not attacked and safe(bot,point) then return BOT_ACTION_DESIRE_HIGH,unit end
        end
    end
    return 0,nil
end
function M.RecordEpicenter(bot,ability,target)
    epicenterIntent={bot=bot,source=ability,target=target,time=DotaTime()}
end
function M.RelocateEpicenter(bot)
    local intent=epicenterIntent
    if not intent or intent.bot~=bot or DotaTime()-intent.time>8 or J.CanNotUseAbility(bot) or not canMove(bot) then return false end
    local source=bot:GetAbilityByName('sandking_epicenter')
    if not source or source:IsNull() or source~=intent.source or not source:IsTrained() or source:IsHidden() or not source:IsActivated()
        or source:GetCooldownTimeRemaining()<=0 then return false end
    local index=bot:GetModifierByName('modifier_sand_king_epicenter')
    if index<0 or bot:GetModifierSourceAbility(index)~=source then return false end
    local target=intent.target
    if not enemy(target) or J.IsSuspiciousIllusion(target) then return false end
    local radius=source:GetSpecialValueInt('epicenter_radius_base')
    if J.IsInRange(bot,target,radius*.75) then epicenterIntent=nil;return false end
    local item=blink(bot)
    if item then local point=toward(bot,target:GetLocation(),item:GetSpecialValueInt('blink_range'))
        if GetUnitToLocationDistance(target,point)<=radius*.75 and safe(bot,point) then bot:Action_UseAbilityOnLocation(item,point);epicenterIntent=nil;return true end
    end
    local burrow=bot:GetAbilityByName('sandking_burrowstrike')
    if J.CanCastAbility(burrow) then
        local delay=GetUnitToUnitDistance(bot,target)/burrow:GetSpecialValueInt('burrow_speed')
        local point=toward(bot,target:GetExtrapolatedLocation(delay),burrow:GetCastRange())
        if GetUnitToLocationDistance(target,point)<=radius*.75 and safe(bot,point) then J.SetQueuePtToINT(bot,true);bot:ActionQueue_UseAbilityOnLocation(burrow,point);epicenterIntent=nil;return true end
    end
    return false
end
return M
