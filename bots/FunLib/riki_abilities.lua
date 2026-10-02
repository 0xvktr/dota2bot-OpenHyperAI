local R={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function R.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function enemy(unit,physical)
    return J.IsValid(unit) and unit:CanBeSeen() and not J.IsSuspiciousIllusion(unit)
        and (physical and J.CanCastOnMagicImmune(unit) and not unit:IsAttackImmune() and not J.IsInEtherealForm(unit)
            or not physical and J.CanCastOnNonMagicImmune(unit))
        and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave')
        and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function toward(bot,point,range)
    local origin=bot:GetLocation();local dx,dy=point.x-origin.x,point.y-origin.y;local length=math.sqrt(dx*dx+dy*dy)
    if length==0 then return origin end
    local step=math.min(length,range)
    return Vector(origin.x+dx*step/length,origin.y+dy*step/length,0)
end
local function safe(point)
    return IsLocationPassable(point) and not J.IsLocHaveTower(700,true,point)
        and not J.IsEnemyChronosphereInLocation(point) and not J.IsEnemyBlackHoleInLocation(point)
end
function R.Smoke(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local radius=ability:GetSpecialValueInt('radius');local range=R.Range(bot,ability)
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)) do
        if enemy(unit,false) and not unit:HasModifier('modifier_riki_smoke_screen') then
            local victim=unit:GetAttackTarget()
            local peel=J.IsValidHero(victim) and victim:GetTeam()==bot:GetTeam() and victim:WasRecentlyDamagedByAnyHero(2)
            if unit:IsChanneling() or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsInTeamFight(bot,1200) or J.IsRetreating(bot) and victim==bot or peel then
                local predicted=unit:GetExtrapolatedLocation(ability:GetCastPoint())
                local point=toward(bot,predicted,range)
                if math.sqrt((predicted.x-point.x)^2+(predicted.y-point.y)^2)<=radius and GetUnitToLocationDistance(bot,point)<=range then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    return 0,nil
end
local function movementLocked(bot)
    return bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_slark_pounce_leash')
        or bot:HasModifier('modifier_puck_coiled') or bot:HasModifier('modifier_grimstroke_soul_chain')
end
function R.Blink(bot,ability,native,defensiveOnly)
    if not J.CanCastAbility(ability) or movementLocked(bot) then return 0,nil end
    local range=R.Range(bot,ability)
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        local best,distance=nil,GetUnitToLocationDistance(bot,J.GetEscapeLoc())
        local candidates={}
        for _,list in pairs({J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE),bot:GetNearbyCreeps(math.min(range,1600),false)}) do for _,unit in pairs(list) do candidates[#candidates+1]=unit end end
        for _,unit in pairs(candidates) do
            if unit~=bot and J.IsValid(unit) and unit:CanBeSeen() and J.IsInRange(bot,unit,range)
                and GetUnitToUnitDistance(bot,unit)>300 and safe(unit:GetLocation()) then
                local d=GetUnitToLocationDistance(unit,J.GetEscapeLoc())
                if d<distance then best=unit;distance=d end
            end
        end
        if best then return BOT_ACTION_DESIRE_HIGH,best end
    end
    if defensiveOnly then return 0,nil end
    local damage=bot:GetAttackDamage()+ability:GetSpecialValueInt('bonus_damage')
    local backstab=bot:GetAbilityByName('riki_innate_backstab')
    if backstab and not backstab:IsNull() and backstab:IsTrained() and not J.HasBreakModifier(bot) then damage=damage+bot:GetAttributeValue(ATTRIBUTE_AGILITY)*backstab:GetSpecialValueFloat('damage_multiplier') end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if enemy(unit,true) and J.CanCastOnTargetAdvanced(unit) and safe(unit:GetLocation()) then
            local lethal=J.WillKillTarget(unit,damage,DAMAGE_TYPE_PHYSICAL,ability:GetCastPoint())
            local engage=J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)
            if lethal or engage and #J.GetEnemiesNearLoc(unit:GetLocation(),700)<=#J.GetAlliesNearLoc(unit:GetLocation(),700)+1 then return BOT_ACTION_DESIRE_HIGH,unit end
        end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        for _,unit in pairs(bot:GetNearbyLaneCreeps(math.min(range,1600),true)) do
            if enemy(unit,true) and string.find(unit:GetUnitName(),'ranged') and not unit:HasModifier('modifier_fountain_glyph')
                and J.IsInRange(bot,unit,range) and J.WillKillTarget(unit,damage,DAMAGE_TYPE_PHYSICAL,ability:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,unit end
        end
        local target=J.GetProperTarget(bot)
        if J.IsFarming(bot) and enemy(target,true) and not J.IsValidHero(target) and J.IsInRange(bot,target,range)
            and not J.CanKillTarget(target,bot:GetAttackDamage()*2,DAMAGE_TYPE_PHYSICAL) then return BOT_ACTION_DESIRE_HIGH,target end
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
            and enemy(target,true) and J.IsInRange(bot,target,range) and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH,target end
    end
    return 0,nil
end
function R.Tricks(bot,ability,native)
    if not J.CanCastAbility(ability) or movementLocked(bot) then return 0,nil,nil end
    local range=R.Range(bot,ability);local radius=ability:GetSpecialValueInt('radius')
    local threat=J.IsStunProjectileIncoming(bot,600) or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
    if ability:GetSpecialValueInt('pocket_riki_enabled')>0 then
        for _,unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
            if unit~=bot and J.IsValid(unit) and unit:CanBeSeen() and not unit:IsBuilding() and not string.find(unit:GetUnitName(),'ward')
                and J.IsInRange(bot,unit,range) and safe(unit:GetLocation()) then
                local count=0;for _,enemyUnit in pairs(J.GetEnemiesNearLoc(unit:GetLocation(),radius)) do if enemy(enemyUnit,true) then count=count+1 end end
                if count>0 and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200))
                    or threat and GetUnitToLocationDistance(unit,J.GetEscapeLoc())<GetUnitToLocationDistance(bot,J.GetEscapeLoc()) then return BOT_ACTION_DESIRE_HIGH,unit,'unit' end
            end
        end
    end
    if threat then
        local point=toward(bot,J.GetEscapeLoc(),range)
        if safe(point) then return BOT_ACTION_DESIRE_HIGH,point,'point' end
    end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)) do
        if enemy(unit,true) and (J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)) then
            local point=toward(bot,unit:GetExtrapolatedLocation(ability:GetCastPoint()),range)
            if safe(point) and GetUnitToLocationDistance(unit,point)<=radius then return BOT_ACTION_DESIRE_HIGH,point,'point' end
        end
    end
    if native and J.IsFarming(bot) and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        local creeps=bot:GetNearbyNeutralCreeps(math.min(range+radius,1600))
        if #creeps>=3 and enemy(creeps[1],true) then local point=toward(bot,creeps[1]:GetLocation(),range);if safe(point) and GetUnitToLocationDistance(creeps[1],point)<=radius then return BOT_ACTION_DESIRE_HIGH,point,'point' end end
    end
    return 0,nil,nil
end
function R.Dart(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(R.Range(bot,ability),1600),true,BOT_MODE_NONE)) do
        if enemy(unit,false) and J.CanCastOnTargetAdvanced(unit) and not J.IsDisabled(unit)
            and (unit:IsChanneling() or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsRetreating(bot) and unit:GetAttackTarget()==bot) then return BOT_ACTION_DESIRE_HIGH,unit,'unit' end
    end
    return 0,nil
end
function R.SmokeDuringTricks(bot)
    local source=bot:GetAbilityByName('riki_tricks_of_the_trade')
    if not bot:IsAlive() or not source or source:IsNull() or not source:IsTrained() or source:IsHidden() or not source:IsActivated()
        or not bot:IsChanneling() or bot:GetCurrentActiveAbility()~=source or bot:IsCastingAbility() or bot:NumQueuedActions()>0
        or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local smoke=bot:GetAbilityByName('riki_smoke_screen')
    local desire,point=R.Smoke(bot,smoke)
    if desire<=0 then return false end
    bot:Action_UseAbilityOnLocation(smoke,point);return true
end
return R
