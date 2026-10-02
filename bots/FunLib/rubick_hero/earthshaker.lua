local bot=GetBot()
local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local Fissure, EnchantTotem, Aftershock, EchoSlam
local pendingRidge, ridges = nil, {}
local tickUnits
local function Refresh()
    tickUnits=nil
    Fissure = bot:GetAbilityByName('earthshaker_fissure')
    EnchantTotem = bot:GetAbilityByName('earthshaker_enchant_totem')
    Aftershock = bot:GetAbilityByName('earthshaker_aftershock')
    EchoSlam = bot:GetAbilityByName('earthshaker_echo_slam')
end
Refresh()

local function BonusRange()
    local bonus = 0
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:GetName() == 'item_aether_lens' then
            bonus = item:GetSpecialValueInt('cast_range_bonus'); break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        bonus = bonus + supremacy:GetSpecialValueInt('cast_range')
    end
    return bonus
end
local function CastRange(ability) return ability:GetCastRange() + BonusRange() end
local function ShockAvailable()
    return Aftershock ~= nil and not Aftershock:IsNull() and Aftershock:IsTrained() and not J.HasBreakModifier(bot)
end
local function DamageUnit(unit)
    return J.IsValid(unit) and unit:GetTeam() ~= bot:GetTeam() and not unit:IsInvulnerable() and not unit:IsMagicImmune()
end
local function Enemy(unit)
    return J.IsValidHero(unit) and DamageUnit(unit) and not J.IsSuspiciousIllusion(unit)
        and not unit:HasModifier('modifier_enigma_black_hole_pull')
        and not unit:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end
local function Units()
    if tickUnits==nil then
        tickUnits={}
        local seen={}
        for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do tickUnits[#tickUnits+1]=unit;seen[unit]=true end
        for _,unit in pairs(bot:GetNearbyNeutralCreeps(1600)) do
            if not seen[unit] then tickUnits[#tickUnits+1]=unit;seen[unit]=true end
        end
    end
    return tickUnits
end
local function Bound(point, range)
    local offset = point - bot:GetLocation()
    return offset:Length2D() > range and bot:GetLocation() + offset:Normalized() * range or point
end
local function LineHit(unit, origin, endpoint, radius, delay)
    local offset = J.GetCorrectLoc(unit, delay) - origin
    local line = endpoint - origin
    local length = line:Length2D()
    if length == 0 then return offset:Length2D() <= radius end
    local direction = line:Normalized()
    local along = math.max(0, math.min(length, offset.x * direction.x + offset.y * direction.y))
    return (offset - direction * along):Length2D() <= radius
end
local function FissureEnd(point)
    return bot:GetLocation() + (point - bot:GetLocation()):Normalized() * CastRange(Fissure)
end
local function FissurePoint(unit)
    if not DamageUnit(unit) then return nil end
    local point = Bound(J.GetCorrectLoc(unit, Fissure:GetCastPoint()), CastRange(Fissure))
    if LineHit(unit, bot:GetLocation(), FissureEnd(point), Fissure:GetSpecialValueInt('fissure_radius'), Fissure:GetCastPoint()) then return point end
    return nil
end
local function Cross(a,b) return a.x*b.y-a.y*b.x end
local function CutsRetreat(point)
    local origin, wall = bot:GetLocation(), FissureEnd(point)-bot:GetLocation()
    for _, ally in pairs(J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally) and J.IsRetreating(ally)
            and ally:WasRecentlyDamagedByAnyHero(2) then
            local route = (J.GetTeamFountain()-ally:GetLocation()):Normalized()*600
            local difference = ally:GetLocation()-origin
            local denominator = Cross(wall,route)
            if math.abs(denominator)>0.001 then
                local t,u = Cross(difference,route)/denominator, Cross(difference,wall)/denominator
                if t>0.05 and t<1 and u>0.05 and u<1 then return true end
            end
        end
    end
    return false
end
local function RecordFissure(point)
    pendingRidge = {ability=Fissure, origin=bot:GetLocation(), endpoint=FissureEnd(point),
        earliest=DotaTime()+Fissure:GetCastPoint()}
    bot:Action_UseAbilityOnLocation(Fissure, point)
end
local function ObserveRidges()
    local now = DotaTime()
    if pendingRidge ~= nil then
        if Fissure ~= pendingRidge.ability or now > pendingRidge.earliest+2 then pendingRidge=nil
        elseif now>=pendingRidge.earliest and Fissure:GetCooldownTimeRemaining()>0 then
            table.insert(ridges,{origin=pendingRidge.origin,endpoint=pendingRidge.endpoint,
                expires=pendingRidge.earliest+Fissure:GetSpecialValueFloat('fissure_duration')})
            pendingRidge=nil
        end
    end
    for index=#ridges,1,-1 do if ridges[index].expires<=now then table.remove(ridges,index) end end
end
local function ShockHit(unit, point, delay)
    if not ShockAvailable() or not DamageUnit(unit) then return false end
    if (J.GetCorrectLoc(unit,delay)-point):Length2D()<=Aftershock:GetSpecialValueInt('aftershock_range') then return true end
    if bot:HasModifier('modifier_item_aghanims_shard') and Fissure~=nil and not Fissure:IsNull() then
        for _,ridge in pairs(ridges) do
            if ridge.expires>DotaTime()+delay and LineHit(unit,ridge.origin,ridge.endpoint,
                Fissure:GetSpecialValueInt('fissure_radius'),delay) then return true end
        end
    end
    return false
end

function X.ConsiderFissure()
    if not J.CanCastAbility(Fissure) then return BOT_ACTION_DESIRE_NONE end
    local units = Units()
    for _,enemy in pairs(units) do
        if Enemy(enemy) then
            local point = FissurePoint(enemy)
            if point ~= nil then
                if enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy) then return BOT_ACTION_DESIRE_HIGH,point,'interrupt' end
                local damage = Fissure:GetSpecialValueInt('fissure_damage')
                if ShockHit(enemy,bot:GetLocation(),Fissure:GetCastPoint()) then damage=damage+Aftershock:GetSpecialValueInt('aftershock_damage') end
                if not J.CannotBeKilled(bot,enemy) and J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,Fissure:GetCastPoint()) then
                    return BOT_ACTION_DESIRE_HIGH,point,'lethal'
                end
            end
        end
    end
    local allies = J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)
    table.insert(allies,bot)
    for _,ally in pairs(allies) do
        if J.IsValidHero(ally) and J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2) then
            for _,enemy in pairs(units) do
                if Enemy(enemy) and not J.IsDisabled(enemy) and J.IsChasingTarget(enemy,ally) then
                    local point=FissurePoint(enemy)
                    if point~=nil and not CutsRetreat(point) then return BOT_ACTION_DESIRE_HIGH,point,'save' end
                end
            end
        end
    end
    if J.IsInTeamFight(bot,1200) then
        for _,enemy in pairs(units) do
            if Enemy(enemy) then
                local point,count=FissurePoint(enemy),0
                if point~=nil and not CutsRetreat(point) then
                    for _,other in pairs(units) do
                        if Enemy(other) and LineHit(other,bot:GetLocation(),FissureEnd(point),Fissure:GetSpecialValueInt('fissure_radius'),Fissure:GetCastPoint()) then count=count+1 end
                    end
                    if count>=2 then return BOT_ACTION_DESIRE_HIGH,point end
                end
            end
        end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and not J.IsDisabled(target) then
        local point=FissurePoint(target)
        if point~=nil and not CutsRetreat(point) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    if not J.IsAllowedToSpam(bot,Fissure:GetManaCost()) then return BOT_ACTION_DESIRE_NONE end
    local reserve=EchoSlam~=nil and EchoSlam:IsTrained() and EchoSlam:GetManaCost() or 0
    if bot:GetMana()-Fissure:GetManaCost()<reserve then return BOT_ACTION_DESIRE_NONE end
    if J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        local creeps=bot:GetNearbyLaneCreeps(1600,true)
        if J.IsFarming(bot) then for _,unit in pairs(bot:GetNearbyNeutralCreeps(1600)) do table.insert(creeps,unit) end end
        for _,creep in pairs(creeps) do
            local point,count=FissurePoint(creep),0
            if point~=nil and not CutsRetreat(point) then
                for _,other in pairs(creeps) do
                    if DamageUnit(other) and LineHit(other,bot:GetLocation(),FissureEnd(point),Fissure:GetSpecialValueInt('fissure_radius'),Fissure:GetCastPoint()) then count=count+1 end
                end
                if count>=3 then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target)) or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and J.IsAttacking(bot) and J.GetHP(bot)>0.6 then
        local point=FissurePoint(target)
        if point~=nil then return BOT_ACTION_DESIRE_HIGH,point end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function CanMove()
    return not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture')
        and not bot:HasModifier('modifier_slark_pounce_leash') and not bot:HasModifier('modifier_tidehunter_dead_in_the_water')
end
local function CanJump()
    return J.CanCastAbility(EnchantTotem) and bot:HasScepter() and CanMove()
        and bit.band(EnchantTotem:GetBehavior(),DOTA_ABILITY_BEHAVIOR_POINT or 16)~=0
end
local function JumpRange() return EnchantTotem:GetSpecialValueInt('distance_scepter')+BonusRange() end
local function SafeLanding(point)
    if J.GetHP(bot)<0.35 and not J.IsRetreating(bot) and not J.IsStuck(bot) then return false end
    if not IsLocationPassable(point) or J.IsLocationInChrono(point) or J.IsLocationInBlackHole(point)
        or J.IsLocationInArena(point,600) then return false end
    local allies,hasBot,foes=0,false,0
    for _,ally in pairs(J.GetAlliesNearLoc(point,1000)) do
        if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally) then allies=allies+1;if ally==bot then hasBot=true end end
    end
    if not hasBot then allies=allies+1 end
    for _,enemy in pairs(Units()) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and not enemy:IsInvulnerable()
            and GetUnitToLocationDistance(enemy,point)<=1000 then foes=foes+1 end
    end
    return allies>=foes
end
local function EchoValue(point,delay)
    local heroes,bodies,echoes,risk=0,{},0,0
    for _,unit in pairs(Units()) do
        if DamageUnit(unit) and (J.GetCorrectLoc(unit,delay)-point):Length2D()<=EchoSlam:GetSpecialValueInt('echo_slam_echo_search_range') then table.insert(bodies,unit) end
    end
    for _,target in pairs(bodies) do
        if Enemy(target) and not J.CannotBeKilled(bot,target)
            and (J.GetCorrectLoc(target,delay)-point):Length2D()<=EchoSlam:GetSpecialValueInt('echo_slam_damage_range') then
            heroes=heroes+1
            local localEchoes=0
            for _,source in pairs(bodies) do
                if source~=target and (J.GetCorrectLoc(source,delay)-J.GetCorrectLoc(target,delay)):Length2D()<=EchoSlam:GetSpecialValueInt('echo_slam_echo_range') then
                    localEchoes=localEchoes+(source:IsHero() and not source:IsIllusion() and 2 or 1)
                end
            end
            echoes=echoes+localEchoes
            if target:HasModifier('modifier_item_blade_mail_reflect') then
                local damage=EchoSlam:GetSpecialValueInt('echo_slam_initial_damage')+localEchoes*EchoSlam:GetSpecialValueInt('echo_slam_echo_damage')
                if ShockHit(target,point,delay) then damage=damage+Aftershock:GetSpecialValueInt('aftershock_damage') end
                risk=risk+bot:GetActualIncomingDamage(damage,DAMAGE_TYPE_MAGICAL)
            end
        end
    end
    return heroes,#bodies,echoes,risk
end
function X.ConsiderEchoSlam()
    if not J.CanCastAbility(EchoSlam) then return BOT_ACTION_DESIRE_NONE end
    local heroes,bodies,echoes,risk=EchoValue(bot:GetLocation(),EchoSlam:GetCastPoint())
    if risk>=bot:GetHealth()*0.8 then return BOT_ACTION_DESIRE_NONE end
    for _,enemy in pairs(Units()) do
        if Enemy(enemy) and GetUnitToUnitDistance(bot,enemy)<=EchoSlam:GetSpecialValueInt('echo_slam_damage_range') then
            local shock=ShockHit(enemy,bot:GetLocation(),EchoSlam:GetCastPoint())
            if shock and (enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy)) then return BOT_ACTION_DESIRE_HIGH,'interrupt' end
            local damage=EchoSlam:GetSpecialValueInt('echo_slam_initial_damage')+(shock and Aftershock:GetSpecialValueInt('aftershock_damage') or 0)
            -- Only immediate guaranteed damage is used for lethal decisions; echoes arrive later.
            if not J.CannotBeKilled(bot,enemy) and J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,EchoSlam:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,'lethal' end
        end
    end
    if (J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot))
        and ((heroes>=2 and echoes>=2) or (heroes>=1 and bodies>=4 and echoes>=3)) then return BOT_ACTION_DESIRE_HIGH,'cluster' end
    return BOT_ACTION_DESIRE_NONE
end
function X.ConsiderBlinkSlam()
    if not J.CanCastAbility(EchoSlam) or not CanMove() or not (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1600)) then return BOT_ACTION_DESIRE_NONE end
    local blink
    for slot=0,5 do
        local item=bot:GetItemInSlot(slot)
        if item~=nil and item:IsFullyCastable() and (item:GetName()=='item_blink' or item:GetName()=='item_overwhelming_blink'
            or item:GetName()=='item_arcane_blink' or item:GetName()=='item_swift_blink') then blink=item;break end
    end
    if blink==nil or bot:GetMana()<EchoSlam:GetManaCost()+blink:GetManaCost() then return BOT_ACTION_DESIRE_NONE end
    local range=blink:GetSpecialValueInt('blink_range')+BonusRange()
    for _,enemy in pairs(Units()) do
        if Enemy(enemy) then
            local point=Bound(J.GetCorrectLoc(enemy,0.1),range)
            local heroes,bodies,echoes,risk=EchoValue(point,0.1)
            if GetUnitToLocationDistance(bot,point)>150 and risk<bot:GetHealth()*0.8 and SafeLanding(point)
                and ((heroes>=2 and echoes>=2) or (heroes>=1 and bodies>=4 and echoes>=3)) then
                return BOT_ACTION_DESIRE_HIGH,point,blink
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end
function X.ConsiderTotemSlam()
    if not CanJump() or not J.CanCastAbility(EchoSlam) or bot:GetMana()<EnchantTotem:GetManaCost()+EchoSlam:GetManaCost()
        or not (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1600)) then return BOT_ACTION_DESIRE_NONE end
    local delay=EnchantTotem:GetCastPoint()+EnchantTotem:GetSpecialValueFloat('scepter_leap_duration')
    for _,enemy in pairs(Units()) do
        if Enemy(enemy) then
            local point=Bound(J.GetCorrectLoc(enemy,delay),JumpRange())
            local heroes,bodies,echoes,risk=EchoValue(point,delay)
            if GetUnitToLocationDistance(bot,point)>150 and risk<bot:GetHealth()*0.8 and SafeLanding(point)
                and ((heroes>=2 and echoes>=2) or (heroes>=1 and bodies>=4 and echoes>=3)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end
function X.ConsiderEnchantTotem()
    if not J.CanCastAbility(EnchantTotem) then return BOT_ACTION_DESIRE_NONE end
    local delay=EnchantTotem:GetCastPoint()
    for _,enemy in pairs(Units()) do
        if Enemy(enemy) and ShockHit(enemy,bot:GetLocation(),delay)
            and (enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy)) then return BOT_ACTION_DESIRE_HIGH,nil,false,'interrupt' end
    end
    if CanJump() and (J.IsStuck(bot) or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2))) then
        local point=Bound(J.GetTeamFountain(),JumpRange())
        if SafeLanding(point) then return BOT_ACTION_DESIRE_HIGH,point,true,'escape' end
    end
    local target=J.GetProperTarget(bot)
    if (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200) or J.IsLaning(bot) or J.IsRetreating(bot)) then
        for _,enemy in pairs(Units()) do
            if Enemy(enemy) and not J.IsDisabled(enemy) and ShockHit(enemy,bot:GetLocation(),delay) then return BOT_ACTION_DESIRE_HIGH,nil,false end
        end
    end
    local buff=bot:HasModifier('modifier_earthshaker_enchant_totem')
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and not J.IsSuspiciousIllusion(target)
        and J.CanBeAttacked(target) and not J.CannotBeKilled(bot,target) then
        if CanJump() and (not bot:IsDisarmed() or (Enemy(target) and ShockAvailable()))
            and not J.IsInRange(bot,target,bot:GetAttackRange()+EnchantTotem:GetSpecialValueInt('bonus_attack_range')) then
            local travel=delay+EnchantTotem:GetSpecialValueFloat('scepter_leap_duration')
            local point=Bound(J.GetCorrectLoc(target,travel),JumpRange())
            if (J.GetCorrectLoc(target,travel)-point):Length2D()<=bot:GetAttackRange()+EnchantTotem:GetSpecialValueInt('bonus_attack_range')
                and SafeLanding(point) then return BOT_ACTION_DESIRE_HIGH,point,true end
        end
        if not buff and not bot:IsDisarmed() and J.IsInRange(bot,target,1000) then
            local reserve=EchoSlam~=nil and EchoSlam:IsTrained() and EchoSlam:GetManaCost() or 0
            if J.IsInRange(bot,target,bot:GetAttackRange()+EnchantTotem:GetSpecialValueInt('bonus_attack_range'))
                or bot:GetMana()>=EnchantTotem:GetManaCost()+reserve then return BOT_ACTION_DESIRE_HIGH,nil,false,'prepare' end
        end
    end
    if buff or not J.IsAllowedToSpam(bot,EnchantTotem:GetManaCost()) then return BOT_ACTION_DESIRE_NONE end
    if J.IsLaning(bot) and not bot:IsDisarmed() then
        local reach=bot:GetAttackRange()+EnchantTotem:GetSpecialValueInt('bonus_attack_range')
        local creeps=bot:GetNearbyLaneCreeps(math.min(reach,1600),true)
        for _,creep in pairs(bot:GetNearbyLaneCreeps(math.min(reach,1600),false)) do
            if J.GetHP(creep)<0.5 then table.insert(creeps,creep) end
        end
        local damage=bot:GetAttackDamage()+math.max(0,bot:GetBaseDamage()-bot:GetBaseDamageVariance())*EnchantTotem:GetSpecialValueInt('totem_damage_percentage')/100
        for _,creep in pairs(creeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and J.IsInRange(bot,creep,reach)
                and not J.WillKillTarget(creep,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL,bot:GetAttackPoint())
                and J.WillKillTarget(creep,damage,DAMAGE_TYPE_PHYSICAL,delay+bot:GetAttackPoint()) then
                return BOT_ACTION_DESIRE_HIGH,nil,false,'last-hit',creep
            end
        end
    end
    if J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        local count=0
        local creeps=bot:GetNearbyLaneCreeps(1600,true)
        if J.IsFarming(bot) then for _,creep in pairs(bot:GetNearbyNeutralCreeps(1600)) do table.insert(creeps,creep) end end
        for _,creep in pairs(creeps) do if ShockHit(creep,bot:GetLocation(),delay) then count=count+1 end end
        if count>=3 then return BOT_ACTION_DESIRE_HIGH,nil,false end
    end
    if not bot:IsDisarmed() and J.CanBeAttacked(target) and J.IsAttacking(bot)
        and J.IsInRange(bot,target,bot:GetAttackRange()+EnchantTotem:GetSpecialValueInt('bonus_attack_range'))
        and ((J.IsPushing(bot) and J.IsValidBuilding(target)) or (J.IsDoingRoshan(bot) and J.IsRoshan(target))
            or (J.IsDoingTormentor(bot) and J.IsTormentor(target) and J.GetHP(bot)>0.65)) then return BOT_ACTION_DESIRE_HIGH,nil,false end
    return BOT_ACTION_DESIRE_NONE
end
local function UseTotem(point,jump,attack)
    if jump then bot:Action_UseAbilityOnLocation(EnchantTotem,point)
    elseif bot:HasScepter() and bit.band(EnchantTotem:GetBehavior(),DOTA_ABILITY_BEHAVIOR_POINT or 16)~=0 then bot:Action_UseAbilityOnEntity(EnchantTotem,bot)
    else bot:Action_UseAbility(EnchantTotem) end
    if attack~=nil then bot:ActionQueue_AttackUnit(attack,true) end
end
local function QueueBlink(point,blink)
    bot:ActionQueue_UseAbilityOnLocation(blink,point)
    bot:ActionQueue_UseAbility(EchoSlam)
end
local function QueueTotem(point)
    bot:ActionQueue_UseAbilityOnLocation(EnchantTotem,point)
    bot:ActionQueue_Delay(EnchantTotem:GetSpecialValueFloat('scepter_leap_duration')+0.05)
    bot:ActionQueue_UseAbility(EchoSlam)
end

function X.ConsiderStolenSpell(ability)
    Refresh()
    local name=ability:GetName()
    if name=='earthshaker_fissure' then Fissure=ability
    elseif name=='earthshaker_enchant_totem' then EnchantTotem=ability
    elseif name=='earthshaker_echo_slam' then EchoSlam=ability
    elseif name=='earthshaker_aftershock' then return false
    else return nil end
    ObserveRidges()
    if J.CanNotUseAbility(bot) then return false end
    local echo,echoReason=X.ConsiderEchoSlam()
    if echo>0 and echoReason=='interrupt' then bot:Action_UseAbility(EchoSlam);return true end
    local fissure,fissurePoint,fissureReason=X.ConsiderFissure()
    local totem,totemPoint,jump,totemReason=X.ConsiderEnchantTotem()
    if totem>0 and totemReason=='interrupt' and (fissure==0 or EnchantTotem:GetCastPoint()<=Fissure:GetCastPoint()) then
        UseTotem(totemPoint,jump);return true
    end
    if fissure>0 and fissureReason=='interrupt' then RecordFissure(fissurePoint);return true end
    if name=='earthshaker_fissure' then
        local desire,point=X.ConsiderFissure()
        if desire>0 then RecordFissure(point);return true end
    elseif name=='earthshaker_enchant_totem' then
        local desire,point,jump,reason,attack=X.ConsiderEnchantTotem()
        if desire>0 and (reason=='interrupt' or reason=='escape') then UseTotem(point,jump,attack);return true end
        local combo,landing=X.ConsiderTotemSlam()
        if combo>0 then QueueTotem(landing);return true end
        if desire>0 then UseTotem(point,jump,attack);return true end
    else
        local desire,reason=X.ConsiderEchoSlam()
        if desire>0 and (reason=='interrupt' or reason=='lethal') then bot:Action_UseAbility(ability);return true end
        local combo,point,blink=X.ConsiderBlinkSlam()
        if combo>0 then QueueBlink(point,blink);return true end
        if desire>0 then bot:Action_UseAbility(ability);return true end
    end
    return false
end
return X
