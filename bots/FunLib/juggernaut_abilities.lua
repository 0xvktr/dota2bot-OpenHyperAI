local U = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
function U.Range(bot, ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
function U.Slash(bot, ability)
    if not J.CanCastAbility(ability) or bot:IsDisarmed() or bot:IsRooted()
        or bot:HasModifier('modifier_juggernaut_blade_fury') or bot:HasModifier('modifier_juggernaut_omnislash') then return 0,nil end
    local target=J.GetProperTarget(bot)
    for _,enemy in pairs(J.GetNearbyHeroes(bot,U.Range(bot,ability),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and J.CanBeAttacked(enemy) and not J.IsSuspiciousIllusion(enemy)
            and not enemy:HasModifier('modifier_abaddon_borrowed_time') and not enemy:HasModifier('modifier_dazzle_shallow_grave') then
            local count=0
            for _,other in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
                if J.IsValid(other) and J.CanBeAttacked(other) and not J.IsValidBuilding(other) and J.IsInRange(enemy,other,425) then count=count+1 end
            end
            local damage=(bot:GetAttackDamage()+ability:GetSpecialValueInt('bonus_damage'))
                * math.floor(ability:GetSpecialValueFloat('duration')*1.4/math.max(bot:GetSecondsPerAttack(),0.2))/math.max(count,1)
            local desperate=J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(bot)<0.4
                or J.IsStunProjectileIncoming(bot,1000)
            if desperate or J.IsGoingOnSomeone(bot) and enemy==target and (count<=2 or J.CanKillTarget(enemy,damage,DAMAGE_TYPE_PHYSICAL))
                or J.IsInTeamFight(bot,1200) and count<=3 then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    return 0,nil
end
function U.Fury(bot, ability, defensiveOnly)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_juggernaut_blade_fury') or bot:HasModifier('modifier_juggernaut_omnislash') then return 0 end
    if J.IsStunProjectileIncoming(bot,1000) or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
        and #J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    if defensiveOnly then return 0 end
    local radius=ability:GetSpecialValueInt('blade_fury_radius')
    local spellDPS=ability:GetSpecialValueInt('blade_fury_damage')
    local attackDPS=bot:GetAttackDamage()/math.max(bot:GetSecondsPerAttack(),0.2)
    for _,enemy in pairs(J.GetNearbyHeroes(bot,radius,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200))
            and (bot:IsDisarmed() or J.IsInEtherealForm(enemy) or spellDPS>attackDPS) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function U.Ward(bot, ability)
    if not J.CanCastAbility(ability) or bot:DistanceFromFountain()<800 then return 0,nil end
    for _,ally in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if J.IsValid(ally) and ally:GetUnitName()=='npc_dota_juggernaut_healing_ward' and ally:GetPlayerID()==bot:GetPlayerID() then return 0,nil end
    end
    local candidates={bot}
    for _,ally in pairs(J.GetNearbyHeroes(bot,U.Range(bot,ability)+ability:GetSpecialValueInt('healing_ward_aura_radius'),false,BOT_MODE_NONE)) do candidates[#candidates+1]=ally end
    for _,ally in pairs(candidates) do
        if (ally==bot and bot:IsAlive() or J.IsValidHero(ally)) and not J.IsSuspiciousIllusion(ally) and J.GetHP(ally)<0.65
            and not ally:HasModifier('modifier_ice_blast') then
            local direction=J.GetEscapeLoc()-ally:GetLocation()
            local point=ally:GetLocation()+direction:Normalized()*250
            local offset=point-bot:GetLocation()
            if GetUnitToLocationDistance(bot,point)>U.Range(bot,ability) then point=bot:GetLocation()+offset:Normalized()*U.Range(bot,ability) end
            local safe=IsLocationPassable(point) and GetUnitToLocationDistance(ally,point)<=ability:GetSpecialValueInt('healing_ward_aura_radius')
            for _,enemy in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and GetUnitToLocationDistance(enemy,point)<enemy:GetAttackRange()+100 then safe=false end
            end
            if safe then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0,nil
end
function U.WardDuringSlash(bot, ability)
    if not (bot:HasModifier('modifier_juggernaut_omnislash') or bot:HasModifier('modifier_juggernaut_swift_slash'))
        or not bot:IsAlive() or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsChanneling() or bot:IsCastingAbility() or bot:NumQueuedActions()>0 or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local desire,point=U.Ward(bot,ability)
    if desire>0 then bot:Action_UseAbilityOnLocation(ability,point);return true end
    return false
end
return U
