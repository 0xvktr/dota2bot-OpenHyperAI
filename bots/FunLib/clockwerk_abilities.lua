local C={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local function overclock(bot) return bot:HasModifier('modifier_rattletrap_overclocking') end
local function valid(unit,pierce)
    return J.IsValid(unit) and unit:CanBeSeen() and not J.IsSuspiciousIllusion(unit)
        and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit))
        and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end
local function range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function allyThreat(bot,unit)
    local victim=unit:GetAttackTarget()
    return victim==bot or J.IsValidHero(victim) and victim:GetTeam()==bot:GetTeam()
        and J.IsInRange(bot,victim,900) and victim:WasRecentlyDamagedByAnyHero(2)
end
function C.Battery(bot,ability,native)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_rattletrap_battery_assault') then return 0 end
    local radius=overclock(bot) and ability:GetSpecialValueInt('overclocking_radius') or ability:GetSpecialValueInt('radius')
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
        if valid(unit,false) and (J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200) or allyThreat(bot,unit)) then return BOT_ACTION_DESIRE_HIGH end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        if (J.IsPushing(bot) or J.IsDefending(bot)) and #bot:GetNearbyLaneCreeps(radius,true)>=3 then return BOT_ACTION_DESIRE_HIGH end
        if J.IsFarming(bot) and #bot:GetNearbyNeutralCreeps(radius)>=2 then return BOT_ACTION_DESIRE_HIGH end
        local target=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
            and valid(target,false) and J.IsInRange(bot,target,radius) and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function C.Cogs(bot,ability)
    if not J.CanCastAbility(ability) then return 0 end
    local radius=overclock(bot) and ability:GetSpecialValueInt('cogs_radius_overclock') or ability:GetSpecialValueInt('cogs_radius')
    local trigger=overclock(bot) and ability:GetSpecialValueInt('trigger_distance_overclock') or ability:GetSpecialValueInt('trigger_distance')
    for _,unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if unit and not unit:IsNull() and unit:IsAlive() and unit:GetUnitName()=='npc_dota_rattletrap_cog'
            and unit:GetPlayerID()==bot:GetPlayerID() and J.IsInRange(bot,unit,radius+100) then return 0 end
    end
    -- Do not enclose a threatened ally together with the aggressor.
    for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(radius,1600),false,BOT_MODE_NONE)) do
        if ally~=bot and J.IsValidHero(ally) and ally:WasRecentlyDamagedByAnyHero(2) then return 0 end
    end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(radius+trigger,1600),true,BOT_MODE_NONE)) do
        if valid(unit,true) then
            if J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) and J.IsInRange(bot,unit,radius-25) then return BOT_ACTION_DESIRE_HIGH end
            if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and allyThreat(bot,unit)
                and not J.IsInRange(bot,unit,radius) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    return 0
end
local function safe(point)
    return IsLocationPassable(point) and not J.IsLocHaveTower(700,true,point)
        and not J.IsEnemyChronosphereInLocation(point) and not J.IsEnemyBlackHoleInLocation(point)
        and not J.IsLocationInArena(point,800)
end
local function clearLine(bot,ability,target,point)
    local origin=bot:GetLocation();local dx,dy=point.x-origin.x,point.y-origin.y;local length=math.sqrt(dx*dx+dy*dy)
    if length==0 then return false end
    dx,dy=dx/length,dy/length
    for _,kind in pairs({UNIT_LIST_ALLIES,UNIT_LIST_ENEMIES,UNIT_LIST_NEUTRAL_CREEPS}) do
        for _,unit in pairs(GetUnitList(kind)) do
            if unit~=bot and unit~=target and unit and not unit:IsNull() and unit:IsAlive() and unit:CanBeSeen() and not unit:IsBuilding() and not string.find(unit:GetUnitName(),'ward') then
                local p=unit:GetExtrapolatedLocation(ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('speed'))
                local x,y=p.x-origin.x,p.y-origin.y;local along=x*dx+y*dy
                if along>0 and along<length and math.abs(x*dy-y*dx)<=ability:GetSpecialValueInt('latch_radius')+unit:GetBoundingRadius() then return false end
            end
        end
    end
    return true
end
function C.Hook(bot,ability)
    if not J.CanCastAbility(ability) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture')
        or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled')
        or bot:HasModifier('modifier_grimstroke_soul_chain') then return 0,nil end
    local target=J.GetProperTarget(bot)
    local candidates={}
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and valid(target,true) then candidates={target}
    elseif J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then candidates=GetUnitList(UNIT_LIST_ALLIES) end
    for _,unit in pairs(candidates) do
        if unit~=bot and unit and not unit:IsNull() and unit:IsAlive() and unit:CanBeSeen() and not unit:IsBuilding() and not string.find(unit:GetUnitName(),'ward') and J.IsInRange(bot,unit,range(bot,ability)) then
            local distance=GetUnitToUnitDistance(bot,unit)
            local point=unit:GetExtrapolatedLocation(ability:GetCastPoint()+distance/ability:GetSpecialValueInt('speed'))
            local retreat=unit:GetTeam()==bot:GetTeam()
            local follow=bot:GetAbilityByName('rattletrap_battery_assault')
            local setup=J.CanCastAbility(follow) and bot:GetMana()>=ability:GetManaCost()+follow:GetManaCost()
            local allies=#J.GetAlliesNearLoc(point,900);local enemies=#J.GetEnemiesNearLoc(point,900)
            local useful=retreat and distance>700 and GetUnitToLocationDistance(unit,J.GetEscapeLoc())<GetUnitToLocationDistance(bot,J.GetEscapeLoc())
                or not retreat and distance>400 and (setup or unit:IsChanneling() or allies>=enemies and allies>0)
            if useful and GetUnitToLocationDistance(bot,point)<=range(bot,ability) and safe(point) and clearLine(bot,ability,unit,point) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0,nil
end
function C.Flare(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0,nil end
    local damage=ability:GetSpecialValueInt('damage')
    local upgrade=bot:GetAbilityByName('rattletrap_overclocking')
    if overclock(bot) and upgrade and not upgrade:IsNull() and upgrade:IsTrained() then damage=damage*(1+upgrade:GetSpecialValueInt('rocket_flare_damage_pct')/100) end
    for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if valid(unit,false) and not unit:HasModifier('modifier_oracle_false_promise_timer') and not unit:HasModifier('modifier_templar_assassin_refraction_absorb') then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('speed')
            if J.WillKillTarget(unit,damage,DAMAGE_TYPE_MAGICAL,delay)
                or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsRetreating(bot) and allyThreat(bot,unit) then
                return BOT_ACTION_DESIRE_HIGH,unit:GetExtrapolatedLocation(delay)
            end
        end
    end
    if native then
        local fight=J.GetTeamFightLocation(bot)
        if fight and GetUnitToLocationDistance(bot,fight)>bot:GetCurrentVisionRange() then return BOT_ACTION_DESIRE_HIGH,fight end
        if (J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
            local creeps=bot:GetNearbyLaneCreeps(1600,true)
            if #creeps>=4 then return BOT_ACTION_DESIRE_HIGH,J.GetCenterOfUnits(creeps) end
        end
        local target=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target)) and valid(target,false) then return BOT_ACTION_DESIRE_HIGH,target:GetLocation() end
    end
    return 0,nil
end
function C.Jetpack(bot,ability)
    if not J.CanCastAbility(ability) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture')
        or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled')
        or bot:HasModifier('modifier_rattletrap_jetpack') or bot:HasModifier('modifier_rattletrap_jetpack_tracker') then return 0 end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function C.JetpackToggle(bot,ability)
    if not J.CanCastAbility(ability) or not bot:HasModifier('modifier_rattletrap_jetpack_tracker') then return 0 end
    local active=bot:HasModifier('modifier_rattletrap_jetpack')
    local target=J.GetProperTarget(bot)
    if active and J.IsGoingOnSomeone(bot) and J.IsValid(target) and J.IsInRange(bot,target,bot:GetAttackRange()+50) then return BOT_ACTION_DESIRE_HIGH end
    if not active and not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture') and not bot:HasModifier('modifier_slark_pounce_leash')
        and not bot:HasModifier('modifier_puck_coiled') and not bot:HasModifier('modifier_grimstroke_soul_chain') and J.IsRetreating(bot)
        and bot:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function C.Overclock(bot,ability)
    if not J.CanCastAbility(ability) or overclock(bot) then return 0 end
    if not J.IsGoingOnSomeone(bot) and not J.IsInTeamFight(bot,1200) then return 0 end
    for _,name in pairs({'rattletrap_battery_assault','rattletrap_power_cogs','rattletrap_hookshot','rattletrap_rocket_flare'}) do
        local linked=bot:GetAbilityByName(name)
        if J.CanCastAbility(linked) and bot:GetMana()>=ability:GetManaCost()+linked:GetManaCost() then
            local desire=({rattletrap_battery_assault=C.Battery,rattletrap_power_cogs=C.Cogs,rattletrap_hookshot=C.Hook,rattletrap_rocket_flare=C.Flare})[name](bot,linked)
            if desire>0 then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    return 0
end
return C
