local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local Smash, Roll, Grip, Stone, Magnetize, Petrify
local magnetizeSession, lastRefresh = nil, -100
local MAGNETIZE = 'modifier_earth_spirit_magnetize'

local function Refresh()
    bot = GetBot()
    Smash = bot:GetAbilityByName('earth_spirit_boulder_smash')
    Roll = bot:GetAbilityByName('earth_spirit_rolling_boulder')
    Grip = bot:GetAbilityByName('earth_spirit_geomagnetic_grip')
    Stone = bot:GetAbilityByName('earth_spirit_stone_caller')
    Magnetize = bot:GetAbilityByName('earth_spirit_magnetize')
    Petrify = bot:GetAbilityByName('earth_spirit_petrify')
end

local function Distance(a,b)
    return math.sqrt((a.x-b.x)^2 + (a.y-b.y)^2)
end

local function Towards(origin, destination, distance)
    local length = Distance(origin,destination)
    if length == 0 then return origin end
    return Vector(origin.x+(destination.x-origin.x)*distance/length,
        origin.y+(destination.y-origin.y)*distance/length,origin.z)
end

local function Line(location, origin, destination)
    local length = Distance(origin,destination)
    if length == 0 then return 0, Distance(location,origin) end
    local dx,dy = (destination.x-origin.x)/length,(destination.y-origin.y)/length
    local x,y = location.x-origin.x,location.y-origin.y
    return x*dx+y*dy, math.abs(x*dy-y*dx)
end

local function Range(ability, base)
    local range = base or ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit)
    return J.IsValidHero(unit) and unit:GetTeam() ~= bot:GetTeam() and not J.IsSuspiciousIllusion(unit)
end

local function UnitTarget(unit)
    return J.CanCastOnTargetAdvanced(unit)
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
end

local function Remnants()
    local out = {}
    for _,unit in pairs(GetUnitList(UNIT_LIST_ALLIED_OTHER)) do
        -- Stones are invulnerable, so the usual J.IsValid filter would discard them.
        if unit ~= nil and not unit:IsNull() and unit:IsAlive() and unit:GetTeam() == bot:GetTeam()
            and unit:GetUnitName() == 'npc_dota_earth_spirit_stone' then out[#out+1] = unit end
    end
    return out
end

local function CanMakeStone(ability)
    return J.CanCastAbility(Stone) and Stone:GetCurrentCharges() > 0
        and bot:GetMana() >= ability:GetManaCost() + Stone:GetManaCost()
end

local function FarmMana(ability, fresh)
    local reserve = Magnetize ~= nil and Magnetize:IsTrained() and Magnetize:GetManaCost() or 0
    return bot:GetMana() - ability:GetManaCost() >= math.max(reserve, bot:GetMaxMana()*0.25)
        and (not fresh or Stone:GetCurrentCharges() > 2)
end

local function SafeLocation(location)
    return IsLocationPassable(location) and not J.IsLocationInChrono(location) and not J.IsLocationInBlackHole(location)
end

local function RollBlocked(location, target)
    local origin = bot:GetLocation()
    local distance = Distance(origin,location)
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(1600,distance+200),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and enemy ~= target then
            local along,side = Line(enemy:GetExtrapolatedLocation(Roll:GetSpecialValueFloat('delay')),origin,location)
            if along >= 0 and along < distance - Roll:GetSpecialValueInt('radius')
                and side <= Roll:GetSpecialValueInt('radius') then return true end
        end
    end
    return false
end

local function ExistingRollStone(location)
    local origin = bot:GetLocation()
    local nearest, first = nil, math.huge
    local radius = Roll:GetSpecialValueInt('radius')
    for _,stone in pairs(Remnants()) do
        local along,side = Line(stone:GetLocation(),origin,location)
        if along >= 0 and along <= Distance(origin,location) and side <= radius then
            -- Use center travel conservatively; do not assume an engine pickup radius.
            local trigger = along
            if trigger <= Roll:GetSpecialValueInt('distance') and trigger < first then nearest,first=stone,trigger end
        end
    end
    return nearest,first
end

local function RollPlan(target)
    local origin = bot:GetLocation()
    local base = Roll:GetSpecialValueInt('distance')
    local location = target:GetLocation()
    local existing, pickup = ExistingRollStone(location)
    local boosted = existing ~= nil
    local fresh = not boosted and GetUnitToUnitDistance(bot,target) > base - 50 and CanMakeStone(Roll)
    boosted = boosted or fresh
    local reach = base * (boosted and Roll:GetSpecialValueFloat('rock_distance_multiplier') or 1)
    local speed = math.max(1,Roll:GetSpecialValueInt('speed'))
    local rockSpeed = math.max(1,Roll:GetSpecialValueInt('rock_speed'))
    if fresh then pickup = Stone:GetSpecialValueInt('rolling_offset_distance') end
    local function Travel(distance)
        if not boosted then return distance/speed end
        local ordinary = math.min(distance,pickup)
        return ordinary/speed + (distance-ordinary)/rockSpeed
    end
    local delay = Roll:GetCastPoint()+Roll:GetSpecialValueFloat('delay')+Travel(Distance(origin,location))
    for _=1,3 do
        location = target:GetExtrapolatedLocation(delay)
        delay = Roll:GetCastPoint()+Roll:GetSpecialValueFloat('delay')+Travel(Distance(origin,location))
    end
    if Distance(origin,location) > reach - 30 or RollBlocked(location,target) or not SafeLocation(location) then return nil end
    if boosted and not fresh and ExistingRollStone(location) == nil then return nil end
    return {location=location,stone=fresh and Towards(origin,location,Stone:GetSpecialValueInt('rolling_offset_distance')) or nil,
        delay=delay}
end

function X.ConsiderRollingBoulder()
    if not J.CanCastAbility(Roll) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture')
        or bot:HasModifier('modifier_earth_spirit_rolling_boulder_caster') then return BOT_ACTION_DESIRE_NONE,nil end
    local enemies = J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)
    if J.IsRetreating(bot) and (bot:WasRecentlyDamagedByAnyHero(2) or #enemies > 0) or J.IsStuck(bot) then
        local escape = J.GetEscapeLoc()
        local boosted = ExistingRollStone(escape) ~= nil
        local fresh = not boosted and #enemies > 0 and CanMakeStone(Roll)
        local distance = Roll:GetSpecialValueInt('distance') * ((boosted or fresh) and Roll:GetSpecialValueFloat('rock_distance_multiplier') or 1)
        local landing = Towards(bot:GetLocation(),escape,distance)
        if SafeLocation(landing) and not RollBlocked(landing,nil) then
            return BOT_ACTION_DESIRE_HIGH,{location=landing,stone=fresh and Towards(bot:GetLocation(),escape,Stone:GetSpecialValueInt('rolling_offset_distance')) or nil},true
        end
    end
    local damage = Roll:GetSpecialValueInt('damage') + bot:GetAttributeValue(ATTRIBUTE_STRENGTH)*Roll:GetSpecialValueInt('damage_str')/100
    for _,enemy in pairs(enemies) do
        if Enemy(enemy) and J.CanCastOnNonMagicImmune(enemy) then
            local plan = RollPlan(enemy)
            if plan ~= nil and (enemy:IsChanneling() or J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,plan.delay)) then
                return BOT_ACTION_DESIRE_HIGH,plan,true
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.CanCastOnNonMagicImmune(target) then
        local plan = RollPlan(target)
        if plan ~= nil and #J.GetNearbyHeroes(target,900,false,BOT_MODE_NONE) <= #J.GetNearbyHeroes(target,900,true,BOT_MODE_NONE)+1 then
            return BOT_ACTION_DESIRE_HIGH,plan,false
        end
    end
    return BOT_ACTION_DESIRE_NONE,nil
end

local function SmashPlan(location)
    local origin = bot:GetLocation()
    if Distance(origin,location) > Smash:GetSpecialValueInt('rock_distance') then return nil end
    local point = Towards(origin,location,math.min(100,Range(Smash)))
    local nearest,nearestDistance = nil,math.huge
    for _,stone in pairs(Remnants()) do
        local d = GetUnitToUnitDistance(bot,stone)
        if d <= Smash:GetSpecialValueInt('rock_search_aoe') and d < nearestDistance then nearest,nearestDistance=stone,d end
    end
    if nearest ~= nil then
        local endpoint = Towards(nearest:GetLocation(),Vector(nearest:GetLocation().x+location.x-origin.x,
            nearest:GetLocation().y+location.y-origin.y,0),Smash:GetSpecialValueInt('rock_distance'))
        local along,side = Line(location,nearest:GetLocation(),endpoint)
        if along >= 0 and along <= Smash:GetSpecialValueInt('rock_distance') + Smash:GetSpecialValueInt('radius')
            and side <= Smash:GetSpecialValueInt('radius')
            and Distance(nearest:GetLocation(),point) <= Smash:GetSpecialValueInt('rock_search_aoe') then
            return {location=point,aim=location,origin=nearest:GetLocation()}
        end
    end
    if CanMakeStone(Smash) then
        local fresh=Towards(origin,location,10)
        return {location=point,aim=location,stone=fresh,origin=fresh}
    end
    return nil
end

local function PredictSmash(unit)
    local delay=Smash:GetCastPoint()
    local plan
    for _=1,3 do
        plan=SmashPlan(unit:GetExtrapolatedLocation(delay))
        if plan==nil then return nil,delay end
        delay=Smash:GetCastPoint()+(plan.stone~=nil and Stone:GetCastPoint() or 0)
            +Distance(plan.origin,unit:GetExtrapolatedLocation(delay))/math.max(1,Smash:GetSpecialValueInt('speed'))
    end
    return plan,delay
end

function X.ConsiderBoulderSmash()
    if not J.CanCastAbility(Smash) then return BOT_ACTION_DESIRE_NONE,nil end
    local enemies = J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)
    if J.IsRetreating(bot) then
        for _,enemy in pairs(enemies) do
            if Enemy(enemy) and J.CanCastOnNonMagicImmune(enemy) and UnitTarget(enemy)
                and GetUnitToUnitDistance(bot,enemy) <= Range(Smash) and J.IsChasingTarget(enemy,bot) then
                return BOT_ACTION_DESIRE_HIGH,{unit=enemy}
            end
        end
    end
    for _,enemy in pairs(enemies) do
        if Enemy(enemy) and J.CanCastOnNonMagicImmune(enemy) then
            local plan,delay=PredictSmash(enemy)
            if plan~=nil and J.WillKillTarget(enemy,Smash:GetSpecialValueInt('rock_damage'),DAMAGE_TYPE_MAGICAL,delay) then
                return BOT_ACTION_DESIRE_HIGH,plan
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.CanCastOnNonMagicImmune(target) then
        local plan=PredictSmash(target)
        if plan ~= nil then return BOT_ACTION_DESIRE_HIGH,plan end
    end
    if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        local creeps = J.IsFarming(bot) and bot:GetNearbyNeutralCreeps(1600) or bot:GetNearbyLaneCreeps(1600,true)
        for _,creep in pairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) then
                local plan,delay=PredictSmash(creep)
                local location=creep:GetExtrapolatedLocation(delay)
                if plan ~= nil and FarmMana(Smash,plan.stone~=nil) then
                    local count=0
                    for _,other in pairs(creeps) do
                        local origin=plan.origin
                        local endpoint=Vector(origin.x+location.x-bot:GetLocation().x,origin.y+location.y-bot:GetLocation().y,origin.z)
                        local along,side=Line(other:GetExtrapolatedLocation(delay),origin,endpoint)
                        if J.IsValid(other) and J.CanCastOnNonMagicImmune(other) and along>=0
                            and along<=Smash:GetSpecialValueInt('rock_distance') and side<=Smash:GetSpecialValueInt('radius') then count=count+1 end
                    end
                    if count>=3 or J.IsLaning(bot) and string.find(creep:GetUnitName(),'ranged',1,true)
                        and J.WillKillTarget(creep,Smash:GetSpecialValueInt('rock_damage'),DAMAGE_TYPE_MAGICAL,delay) then
                        return BOT_ACTION_DESIRE_HIGH,plan
                    end
                end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE,nil
end

local function GripPlan(enemy)
    local origin=bot:GetLocation()
    local radius=Grip:GetSpecialValueInt('radius')
    for _,stone in pairs(Remnants()) do
        if GetUnitToUnitDistance(bot,stone)<=Range(Grip) then
            local speed=math.max(1,Grip:GetSpecialValueInt('pull_units_per_second'))
            local delay=Grip:GetCastPoint()+GetUnitToUnitDistance(stone,enemy)/speed
            for _=1,3 do
                delay=Grip:GetCastPoint()+Distance(stone:GetLocation(),enemy:GetExtrapolatedLocation(delay))/speed
            end
            local along,side=Line(enemy:GetExtrapolatedLocation(delay),origin,stone:GetLocation())
            if along>=math.max(0,GetUnitToUnitDistance(bot,stone)-Grip:GetSpecialValueInt('total_pull_distance')-radius)
                and along<=GetUnitToUnitDistance(bot,stone)+radius and side<=radius then return {unit=stone,delay=delay} end
        end
    end
    if CanMakeStone(Grip) then
        local predicted=enemy:GetExtrapolatedLocation(Grip:GetCastPoint()+Stone:GetCastPoint())
        local location=Towards(origin,predicted,Distance(origin,predicted)+100)
        if Distance(origin,location)<=math.min(Range(Stone),Range(Grip)) then
            return {stone=location,location=location,delay=Grip:GetCastPoint()+Stone:GetCastPoint()+100/math.max(1,Grip:GetSpecialValueInt('pull_units_per_second'))}
        end
    end
    return nil
end

function X.ConsiderGeomagneticGrip(saveOnly)
    if not J.CanCastAbility(Grip) then return BOT_ACTION_DESIRE_NONE,nil end
    if SafeLocation(bot:GetLocation()) and #J.GetNearbyHeroes(bot,400,true,BOT_MODE_NONE)==0 then
        for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,Range(Grip,Grip:GetSpecialValueInt('cast_range_heroes'))),false,BOT_MODE_NONE)) do
            if ally~=bot and not ally:IsIllusion() and GetUnitToUnitDistance(bot,ally)>=250
                and GetUnitToUnitDistance(bot,ally)<=Range(Grip,Grip:GetSpecialValueInt('cast_range_heroes'))
                and not ally:HasModifier('modifier_legion_commander_duel')
                and not ally:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not ally:HasModifier('modifier_enigma_black_hole_pull')
                and not ally:HasModifier('modifier_bloodseeker_rupture')
                and (J.IsRetreating(ally) or J.GetHP(ally)<0.5) and ally:WasRecentlyDamagedByAnyHero(2)
                and #J.GetNearbyHeroes(ally,600,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH,{unit=ally},true end
        end
    end
    if saveOnly then return BOT_ACTION_DESIRE_NONE,nil end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if Enemy(enemy) and J.CanCastOnNonMagicImmune(enemy) then
            local plan=GripPlan(enemy)
            if plan ~= nil and (J.WillKillTarget(enemy,Grip:GetSpecialValueInt('rock_damage'),DAMAGE_TYPE_MAGICAL,plan.delay)
                or J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and not enemy:IsSilenced()
                or J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) and not enemy:IsSilenced()) then
                return BOT_ACTION_DESIRE_HIGH,plan,false
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE,nil
end

function X.ConsiderMagnetize()
    if not J.CanCastAbility(Magnetize) then return BOT_ACTION_DESIRE_NONE end
    local count=0
    for _,enemy in pairs(J.GetNearbyHeroes(bot,Magnetize:GetSpecialValueInt('cast_radius'),true,BOT_MODE_NONE)) do
        if Enemy(enemy) and not enemy:HasModifier(MAGNETIZE) then
            count=count+1
            if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) or J.IsRetreating(bot) and enemy:WasRecentlyDamagedByAnyHero(2) then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end
    if count>=2 then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

local function CastMagnetize()
    bot:Action_UseAbility(Magnetize)
    magnetizeSession=DotaTime()+Magnetize:GetSpecialValueFloat('damage_duration')+1
end

function X.UseMagnetizeStone()
    Refresh()
    if J.CanNotUseAbility(bot) or bot:IsChanneling() or bot:IsUsingAbility() or bot:IsCastingAbility()
        or Magnetize==nil or Magnetize:IsNull() or not Magnetize:IsTrained() or Magnetize:IsHidden()
        or magnetizeSession==nil or DotaTime()>magnetizeSession or DotaTime()-lastRefresh<0.5
        or not J.CanCastAbility(Stone) or Stone:GetCurrentCharges()<=0 then return false end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if Enemy(enemy) and enemy:HasModifier(MAGNETIZE) then
            local remaining=J.GetModifierTime(enemy,MAGNETIZE)
            if remaining>0.2 and remaining<=1.8
                and not J.WillKillTarget(enemy,Magnetize:GetSpecialValueInt('damage_per_second')*remaining,DAMAGE_TYPE_MAGICAL,remaining) then
                local location=enemy:GetExtrapolatedLocation(Stone:GetCastPoint())
                location=Towards(bot:GetLocation(),location,math.min(Range(Stone),Distance(bot:GetLocation(),location)))
                local radius=Magnetize:GetSpecialValueInt('rock_search_radius')
                local existing=false
                for _,stone in pairs(Remnants()) do
                    if stone:GetPlayerID()==bot:GetPlayerID() and GetUnitToUnitDistance(stone,enemy)<=radius then existing=true end
                end
                if not existing and Distance(location,enemy:GetLocation())<=radius-30 then
                    bot:Action_UseAbilityOnLocation(Stone,location)
                    lastRefresh=DotaTime();magnetizeSession=DotaTime()+Magnetize:GetSpecialValueFloat('damage_duration')+1
                    return true
                end
            end
        end
    end
    return false
end

function X.ConsiderEchantRemnant()
    if not J.CanCastAbility(Petrify) then return BOT_ACTION_DESIRE_NONE,nil end
    for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,Range(Petrify,Petrify:GetSpecialValueInt('ally_cast_range'))),false,BOT_MODE_NONE)) do
        if ally~=bot and not ally:IsIllusion() and J.GetHP(ally)<0.35 and ally:WasRecentlyDamagedByAnyHero(2)
            and GetUnitToUnitDistance(bot,ally)<=Range(Petrify,Petrify:GetSpecialValueInt('ally_cast_range'))
            and #J.GetNearbyHeroes(ally,500,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH,ally,true end
    end
    if J.GetHP(bot)<0.25 and bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,500,true,BOT_MODE_NONE)>=2
        and (bot:IsRooted() or not J.CanCastAbility(Roll)) then return BOT_ACTION_DESIRE_HIGH,bot,true end
    local target=J.GetProperTarget(bot)
    if Enemy(target) and J.CanCastOnNonMagicImmune(target) and UnitTarget(target)
        and GetUnitToUnitDistance(bot,target)<=Range(Petrify)
        and (target:IsChanneling() or J.IsGoingOnSomeone(bot) and not J.IsDisabled(target)) then
        return BOT_ACTION_DESIRE_HIGH,target,target:IsChanneling()
    end
    return BOT_ACTION_DESIRE_NONE,nil
end

local function CastPlan(ability,plan)
    if plan.stone~=nil then
        bot:ActionQueue_UseAbilityOnLocation(Stone,plan.stone)
        bot:ActionQueue_UseAbilityOnLocation(ability,plan.location)
    elseif plan.unit~=nil then bot:Action_UseAbilityOnEntity(ability,plan.unit)
    else bot:Action_UseAbilityOnLocation(ability,plan.location) end
end

function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    if name~='earth_spirit_boulder_smash' and name~='earth_spirit_rolling_boulder'
        and name~='earth_spirit_geomagnetic_grip' and name~='earth_spirit_magnetize'
        and name~='earth_spirit_petrify' and name~='earth_spirit_stone_caller' then return nil end
    Refresh()
    if J.CanNotUseAbility(bot) then return false end
    local desire,plan
    if name=='earth_spirit_boulder_smash' then Smash=ability;desire,plan=X.ConsiderBoulderSmash()
    elseif name=='earth_spirit_rolling_boulder' then Roll=ability;desire,plan=X.ConsiderRollingBoulder()
    elseif name=='earth_spirit_geomagnetic_grip' then Grip=ability;desire,plan=X.ConsiderGeomagneticGrip()
    elseif name=='earth_spirit_petrify' then
        Petrify=ability;local target;desire,target=X.ConsiderEchantRemnant()
        if desire>0 then bot:Action_UseAbilityOnEntity(ability,target);return true end
        return false
    elseif name=='earth_spirit_magnetize' then
        Magnetize=ability
        if X.ConsiderMagnetize()>0 then CastMagnetize();return true end
        return X.UseMagnetizeStone()
    else return X.UseMagnetizeStone() end
    if desire>0 then CastPlan(ability,plan);return true end
    return false
end
Refresh()
return X
