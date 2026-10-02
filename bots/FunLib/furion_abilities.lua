local F={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function F.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
function F.Sprout(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=F.Range(bot,ability);local target=J.GetProperTarget(bot)
    for _,enemy in pairs(J.GetNearbyHeroes(bot,range,true,BOT_MODE_NONE)) do
        local useful = enemy==target and J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)
            or J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot)
        for _, ally in pairs(J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2)
                and J.IsChasingTarget(enemy,ally) then useful = true end
        end
        if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy)
            and not enemy:HasModifier('modifier_hoodwink_scurry_active')
            and not enemy:HasModifier('modifier_broodmother_spin_web')
            and not enemy:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and useful then
            local point=J.GetCorrectLoc(enemy,ability:GetCastPoint())
            local clear=GetUnitToLocationDistance(bot,point)>ability:GetSpecialValueInt('sprout_damage_radius')
            for _,ally in pairs(J.GetAlliesNearLoc(point,ability:GetSpecialValueInt('sprout_damage_radius'))) do
                if ally~=bot and J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally) then clear=false end
            end
            if clear and GetUnitToLocationDistance(bot,point)<=range then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0,nil
end
function F.SourceTeleportSafe(bot)
    return not bot:IsRooted() and not J.IsStunProjectileIncoming(bot,1200)
        and (#J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)==0 or J.IsRealInvisible(bot))
end
function F.TeleportSafe(bot,point)
    return IsLocationPassable(point) and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point)
        and (#J.GetEnemiesNearLoc(point,1200)<=#J.GetAlliesNearLoc(point,1200)+1
            or J.GetLocationToLocationDistance(point,J.GetTeamFountain())<800)
end
function F.CallPoint(bot,ability,near)
    local range=F.Range(bot,ability);local radius=ability:GetSpecialValueInt('area_of_effect')
    local trees=bot:GetNearbyTrees(math.min(1600,range+radius));local best,bestCount=nil,0
    for _,id in pairs(trees) do
        local point=GetTreeLocation(id)
        if GetUnitToLocationDistance(bot,point)<=range and (not near or J.GetLocationToLocationDistance(point,near)<=radius) then
            local count=0
            for _,other in pairs(trees) do if J.GetLocationToLocationDistance(GetTreeLocation(other),point)<=radius then count=count+1 end end
            if count>bestCount then best,bestCount=point,count end
        end
    end
    return best
end
function F.Call(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local teleport=bot:GetAbilityByName('furion_teleportation')
    if J.CanCastAbility(teleport) and bot:GetMana()-ability:GetManaCost()<teleport:GetManaCost() then return 0,nil end
    local target=J.GetProperTarget(bot)
    if J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot) and J.IsValidHero(target)
        or J.IsPushing(bot) or J.IsDefending(bot)
        or (J.IsFarming(bot) or J.IsLaning(bot)) and #bot:GetNearbyLaneCreeps(900,true)>=2
        or J.IsFarming(bot) and #bot:GetNearbyNeutralCreeps(900)>=2
        or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot) then
        local point=F.CallPoint(bot,ability)
        if point then return BOT_ACTION_DESIRE_HIGH,point end
    end
    return 0,nil
end
function F.Curse(bot,ability)
    if not J.CanCastAbility(ability) then return 0 end
    local target=J.GetProperTarget(bot)
    for _,enemy in pairs(J.GetNearbyHeroes(bot,ability:GetSpecialValueInt('range'),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and not enemy:HasModifier('modifier_furion_curse_of_the_forest') then
            local radius=ability:GetSpecialValueInt('radius')
            local trees=#enemy:GetNearbyTrees(radius)
            for _,list in ipairs({GetUnitList(UNIT_LIST_ALLIES),GetUnitList(UNIT_LIST_ENEMIES)}) do
                for _,unit in pairs(list) do
                    if J.IsValid(unit) and unit:GetUnitName()=='npc_dota_furion_treant' and J.IsInRange(unit,enemy,radius) then trees=trees+1 end
                end
            end
            if trees>0 and (enemy==target and J.IsGoingOnSomeone(bot)
                or J.IsInTeamFight(bot,1200) or J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot)
                or J.CanKillTarget(enemy,trees*ability:GetSpecialValueInt('damage_per_tree')*ability:GetSpecialValueFloat('duration'),DAMAGE_TYPE_MAGICAL)) then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end
    return 0
end
function F.Wrath(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local target=J.GetProperTarget(bot);local firstDamage=ability:GetSpecialValueInt('damage')
    for _,enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_abaddon_borrowed_time')
            and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_oracle_false_promise_timer')
            and (J.CanKillTarget(enemy,firstDamage,DAMAGE_TYPE_MAGICAL)
                or enemy==target and J.IsGoingOnSomeone(bot)
                or bot:HasScepter() and J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot)) then
            -- Guaranteed first bounce, no assumed maximum global bounce damage.
            return BOT_ACTION_DESIRE_HIGH,enemy
        end
    end
    return 0,nil
end
return F
