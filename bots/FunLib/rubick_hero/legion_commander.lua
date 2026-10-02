local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local function Range(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end
local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnMagicImmune(unit)
        and J.CanCastOnTargetAdvanced(unit) and not J.CannotBeKilled(bot,unit)
end
local function Allies(range)
    local list = {bot}
    for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)) do
        if ally ~= bot then list[#list+1] = ally end
    end
    return list
end
local function PressPoint(ability,ally)
    local loc = ally:GetLocation()
    local offset = loc - bot:GetLocation()
    if offset:Length2D() > Range(ability) then
        loc = bot:GetLocation() + offset:Normalized() * Range(ability)
    end
    return loc
end
function X.PressTarget(ability,urgentOnly)
    if not J.CanCastAbility(ability) then return nil end
    local point = J.CheckBitfieldFlag(ability:GetBehavior(),ABILITY_BEHAVIOR_POINT)
    local radius = point and ability:GetSpecialValueInt('radius') or 0
    local best,score
    for _,ally in pairs(Allies(Range(ability)+radius)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and not ally:IsMagicImmune() and J.IsInRange(bot,ally,Range(ability)+radius) then
            local purge = (J.IsDisabled(ally) or ally:IsSilenced() or ally:IsRooted())
                and not ally:HasModifier('modifier_legion_commander_duel')
                and not ally:HasModifier('modifier_enigma_black_hole_pull')
                and not ally:HasModifier('modifier_faceless_void_chronosphere_freeze')
            local healing = not ally:HasModifier('modifier_ice_blast')
                and ally:GetMaxHealth()-ally:GetHealth() > ability:GetSpecialValueInt('hp_regen')
                    * ability:GetSpecialValueFloat('duration') * 0.6
                and not ally:HasModifier('modifier_legion_commander_press_the_attack')
            local threatened = ally:WasRecentlyDamagedByAnyHero(2)
            local value = purge and 100 or healing and threatened and 50 or 0
            if value == 0 and not urgentOnly and healing
                and (J.GetHP(ally)<0.4 or J.IsGoingOnSomeone(ally) or J.IsRetreating(ally)) then value=10 end
            if value>0 and (not score or value>score) then best,score=ally,value end
        end
    end
    return best
end
function X.CastPress(ability,target,queue)
    local point = J.CheckBitfieldFlag(ability:GetBehavior(),ABILITY_BEHAVIOR_POINT)
    if point then
        if queue then bot:ActionQueue_UseAbilityOnLocation(ability,PressPoint(ability,target))
        else bot:Action_UseAbilityOnLocation(ability,PressPoint(ability,target)) end
    elseif queue then bot:ActionQueue_UseAbilityOnEntity(ability,target)
    else bot:Action_UseAbilityOnEntity(ability,target) end
end
function X.OddsUseful(ability)
    if not J.CanCastAbility(ability) then return false end
    local radius=ability:GetSpecialValueInt('radius')
    local heroes=J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)
    local creeps=bot:GetNearbyCreeps(math.min(radius,1600),true)
    local nHeroes,nCreeps=0,0
    for _,unit in pairs(heroes) do
        if J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit) and J.IsInRange(bot,unit,radius) then nHeroes=nHeroes+1 end
    end
    for _,unit in pairs(creeps) do
        if J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit) and J.IsInRange(bot,unit,radius) then nCreeps=nCreeps+1 end
    end
    local damage=ability:GetSpecialValueInt('damage')+nHeroes*ability:GetSpecialValueInt('damage_per_hero')
        +nCreeps*ability:GetSpecialValueInt('damage_per_unit')
    for _,enemy in pairs(heroes) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and not J.CannotBeKilled(bot,enemy)
            and J.IsInRange(bot,enemy,radius)
            and J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,ability:GetCastPoint()) then return true end
    end
    local target=bot:GetAttackTarget() or J.GetProperTarget(bot)
    if J.IsValidHero(target) and J.CanBeAttacked(target) and J.IsInRange(bot,target,radius)
        and (bot:HasModifier('modifier_legion_commander_duel') or J.IsGoingOnSomeone(bot))
        and not bot:HasModifier('modifier_legion_commander_overwhelming_odds') then return true end
    if J.IsInTeamFight(bot,1200) and nHeroes>=2 then return true end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and nHeroes>0 then return true end
    if not J.IsAllowedToSpam(bot,ability:GetManaCost()) then return false end
    if J.IsLaning(bot) then
        for _,creep in pairs(creeps) do
            if J.IsValid(creep) and J.IsKeyWordUnit('ranged',creep) and J.CanCastOnNonMagicImmune(creep)
                and J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,ability:GetCastPoint())
                and (nHeroes>0 or not J.IsInRange(bot,creep,bot:GetAttackRange())) then return true end
        end
    end
    return (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and nCreeps>=3
end
function X.DuelTarget(ability)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_legion_commander_duel') then return nil end
    local enemies=J.GetNearbyHeroes(bot,math.min(Range(ability),1600),true,BOT_MODE_NONE)
    for _,enemy in pairs(enemies) do
        if Enemy(enemy) and J.IsInRange(bot,enemy,Range(ability)) and enemy:IsChanneling()
            and J.GetHP(bot)>0.25 then return enemy end
    end
    if bot:IsDisarmed() or J.IsInEtherealForm(bot) then return nil end
    local duration=ability:GetSpecialValueFloat('duration')
    for _,enemy in pairs(enemies) do
        if Enemy(enemy) and J.IsInRange(bot,enemy,Range(ability)) and J.CanBeAttacked(enemy)
            and not J.IsInEtherealForm(enemy) and not enemy:HasModifier('modifier_item_blade_mail_reflect')
            and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)) then
            local damage=enemy:GetActualIncomingDamage(bot:GetAttackDamage()
                * math.max(0,duration-0.3)/bot:GetSecondsPerAttack(),DAMAGE_TYPE_PHYSICAL)
            for _,ally in pairs(Allies(1600)) do
                if ally~=bot and not J.IsDisabled(ally) and not ally:IsDisarmed()
                    and ally:GetAttackTarget()==enemy and J.IsInRange(ally,enemy,ally:GetAttackRange()+80) then
                    damage=damage+ally:GetEstimatedDamageToTarget(true,enemy,duration,DAMAGE_TYPE_PHYSICAL)
                end
            end
            local threat=enemy:GetEstimatedDamageToTarget(true,bot,duration,DAMAGE_TYPE_PHYSICAL)
            if damage*0.8>enemy:GetHealth()+enemy:GetHealthRegen()*duration
                and threat<bot:GetHealth()*0.9 then return enemy end
        end
    end
    return nil
end
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    if name~='legion_commander_overwhelming_odds' and name~='legion_commander_press_the_attack'
        and name~='legion_commander_duel' then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local dueling=bot:HasModifier('modifier_legion_commander_duel')
    if name=='legion_commander_press_the_attack' then
        local target=X.PressTarget(ability,false)
        if not target then return false end
        if not dueling then J.SetQueuePtToINT(bot,true,ability) end
        X.CastPress(ability,target,not dueling)
    elseif name=='legion_commander_overwhelming_odds' then
        if not X.OddsUseful(ability) then return false end
        if dueling then bot:Action_UseAbility(ability)
        else J.SetQueuePtToINT(bot,true,ability);bot:ActionQueue_UseAbility(ability) end
    else
        local target=X.DuelTarget(ability)
        if not target then return false end
        J.SetQueuePtToINT(bot,true,ability);bot:ActionQueue_UseAbilityOnEntity(ability,target)
    end
    return true
end
return X
