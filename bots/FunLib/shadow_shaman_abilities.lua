local M={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
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
end
local function controlTime(unit)
    return math.max(J.GetModifierTime(unit,'modifier_shadow_shaman_voodoo'),J.GetModifierTime(unit,'modifier_shadow_shaman_shackles'),J.GetModifierTime(unit,'modifier_stunned'))
end
local function peel(bot,unit)
    for _,ally in pairs(J.GetNearbyHeroes(bot,1200,false,BOT_MODE_NONE)) do if J.IsValidHero(ally) and unit:GetAttackTarget()==ally and J.GetHP(ally)<.5 then return true end end
    return J.IsRetreating(bot) and unit:GetAttackTarget()==bot
end
function M.Hex(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability)
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and J.CanCastOnTargetAdvanced(unit) and (unit:IsChanneling() or J.IsCastingUltimateAbility(unit)
            or controlTime(unit)<=ability:GetCastPoint()+.1 and not unit:IsStunned() and (peel(bot,unit)
                or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200))) then return BOT_ACTION_DESIRE_HIGH,unit end
    end
    return 0,nil
end
function M.Shock(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability);local damage=ability:GetSpecialValueInt('damage')
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and J.CanCastOnTargetAdvanced(unit) and (J.WillKillTarget(unit,damage,DAMAGE_TYPE_MAGICAL,ability:GetCastPoint())
            or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)
            or J.IsLaning(bot) and J.GetMP(bot)>.65 and J.IsAllowedToSpam(bot,ability:GetManaCost())) then return BOT_ACTION_DESIRE_HIGH,unit end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
        for _,unit in pairs(creeps) do
            if enemy(unit) and J.IsInRange(bot,unit,range) and not unit:HasModifier('modifier_fountain_glyph') and not J.IsAllysTarget(unit)
                and (#creeps>=3 and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
                    or J.IsLaning(bot) and string.find(unit:GetUnitName(),'ranged') and J.WillKillTarget(unit,damage,DAMAGE_TYPE_MAGICAL,ability:GetCastPoint())) then return BOT_ACTION_DESIRE_HIGH,unit end
        end
        local target=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
            and enemy(target) and J.IsInRange(bot,target,range) and J.CanCastOnTargetAdvanced(target) then return BOT_ACTION_DESIRE_HIGH,target end
    end
    return 0,nil
end
local function channelSafe(bot,target)
    if J.GetHP(bot)<.25 and target==nil and not bot:IsMagicImmune() then return false end
    for _,unit in pairs(J.GetNearbyHeroes(bot,1000,true,BOT_MODE_NONE)) do
        if unit~=target and J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) and not J.IsDisabled(unit) and unit:GetAttackTarget()==bot then return false end
    end
    return true
end
function M.Shackles(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability)
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and J.CanCastOnTargetAdvanced(unit) and channelSafe(bot,unit) and (unit:IsChanneling() or J.IsCastingUltimateAbility(unit)
            or controlTime(unit)<=ability:GetCastPoint()+.1 and not unit:IsStunned() and (not unit:IsHexed() or unit:HasModifier('modifier_shadow_shaman_voodoo')) and (peel(bot,unit) or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsInTeamFight(bot,1200))) then return BOT_ACTION_DESIRE_HIGH,unit end
    end
    -- Scepter's friendly channel needs the actual upgraded source and a real learned Shock sibling.
    local shock=bot:GetAbilityByName('shadow_shaman_ether_shock')
    if ability:GetSpecialValueInt('alt_cast_on_allies')>0 and shock and not shock:IsNull() and shock:IsTrained() and not shock:IsHidden() and shock:IsActivated() and channelSafe(bot,nil) then
        for _,unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
            if unit~=bot and J.IsValid(unit) and not unit:IsIllusion() and J.IsInRange(bot,unit,range)
                and (unit:IsHero() or string.find(unit:GetUnitName(),'npc_dota_shadow_shaman_ward') and unit:GetPlayerID()==bot:GetPlayerID()) then
                local count=0;for _,foe in pairs(J.GetEnemiesNearLoc(unit:GetLocation(),ability:GetSpecialValueInt('scepter_shock_radius'))) do if enemy(foe) and (J.IsValidHero(foe) or native and (J.IsFarming(bot) or J.IsDefending(bot) or J.IsPushing(bot))) then count=count+1 end end
                if count>=2 and GetUnitToUnitDistance(bot,unit)<ability:GetSpecialValueInt('ally_break_range') then return BOT_ACTION_DESIRE_HIGH,unit end
            end
        end
    end
    return 0,nil
end
local function wardCount(bot,point,radius)
    local count=0
    for _,unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do if unit and not unit:IsNull() and unit:IsAlive() and string.find(unit:GetUnitName(),'npc_dota_shadow_shaman_ward')
        and unit:GetPlayerID()==bot:GetPlayerID() and GetUnitToLocationDistance(unit,point)<=radius then count=count+1 end end
    return count
end
local function pointFor(bot,location,range)
    local origin=bot:GetLocation();local dx,dy=location.x-origin.x,location.y-origin.y;local length=math.sqrt(dx*dx+dy*dy)
    if length<=range then return location end
    return Vector(origin.x+dx*range/length,origin.y+dy*range/length,0)
end
function M.Wards(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability);local target=J.GetProperTarget(bot)
    if enemy(target,true) and not J.IsSuspiciousIllusion(target) and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)) then
        local point=target:GetExtrapolatedLocation(ability:GetCastPoint())
        local count=0;for _,unit in pairs(J.GetEnemiesNearLoc(point,450)) do if enemy(unit,true) and J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) then count=count+1 end end
        if GetUnitToLocationDistance(bot,point)<=range and (controlTime(target)>=ability:GetCastPoint() or J.IsDisabled(target) or count>=2)
            and (wardCount(bot,point,450)<ability:GetSpecialValueInt('ward_count') or count>=2 or J.GetHP(target)>.4) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    if native and J.IsPushing(bot) then
        local list={};for _,unit in pairs(bot:GetNearbyTowers(1600,true)) do list[#list+1]=unit end;for _,unit in pairs(bot:GetNearbyBarracks(1600,true)) do list[#list+1]=unit end
        local ancient=GetAncient(GetOpposingTeam());if ancient then list[#list+1]=ancient end
        for _,unit in pairs(list) do
            if J.IsValidBuilding(unit) and not unit:HasModifier('modifier_fountain_glyph') and not unit:HasModifier('modifier_backdoor_protection')
                and not unit:HasModifier('modifier_backdoor_protection_active') then
                local point=pointFor(bot,unit:GetLocation(),range)
                if IsLocationPassable(point) and GetUnitToLocationDistance(unit,point)<=650-ability:GetSpecialValueInt('spawn_radius')+ability:GetSpecialValueInt('bonus_attack_range') then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    return 0,nil
end
function M.Urnaconda(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability);local radius=ability:GetSpecialValueInt('impact_radius')
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)) do
        if J.IsValidHero(unit) and J.CanCastOnMagicImmune(unit) and not J.IsSuspiciousIllusion(unit) then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('speed')
            local predicted=unit:GetExtrapolatedLocation(delay);local point=pointFor(bot,predicted,range)
            if GetUnitToLocationDistance(unit,point)<=radius and math.sqrt((predicted.x-point.x)^2+(predicted.y-point.y)^2)<=radius
                and (J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200) or peel(bot,unit)
                    or J.WillKillTarget(unit,ability:GetSpecialValueInt('impact_damage'),ability:GetDamageType(),delay)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
        if #creeps>=3 and (J.IsFarming(bot) or J.IsDefending(bot) or J.IsPushing(bot)) and J.IsValid(creeps[1]) and not creeps[1]:HasModifier('modifier_fountain_glyph') then return BOT_ACTION_DESIRE_HIGH,creeps[1]:GetLocation() end
        if J.IsPushing(bot) then for _,unit in pairs(bot:GetNearbyTowers(1600,true)) do if J.IsValidBuilding(unit) and not unit:HasModifier('modifier_fountain_glyph') and not unit:HasModifier('modifier_backdoor_protection') and not unit:HasModifier('modifier_backdoor_protection_active') then local point=pointFor(bot,unit:GetLocation(),range);if GetUnitToLocationDistance(unit,point)<=650 and IsLocationPassable(point) then return BOT_ACTION_DESIRE_HIGH,point end end end end
    end
    return 0,nil
end
return M
