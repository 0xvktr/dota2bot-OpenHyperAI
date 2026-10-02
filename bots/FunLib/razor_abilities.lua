local R={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local function valid(unit)
    return J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) and J.CanCastOnMagicImmune(unit)
        and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end
function R.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
function R.Plasma(bot,ability)
    if not J.CanCastAbility(ability) then return 0 end
    local radius=ability:GetSpecialValueInt('radius')
    local speed=radius*2/math.max(ability:GetSpecialValueFloat('total_ability_time'),.1)
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
        if valid(unit) and J.CanCastOnNonMagicImmune(unit) and not unit:HasModifier('modifier_item_blade_mail_reflect')
            and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace') then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/speed
            local point=unit:GetExtrapolatedLocation(delay)
            local distance=GetUnitToLocationDistance(bot,point)
            if distance<=radius then
                local damage=ability:GetSpecialValueInt('damage_min')+(ability:GetSpecialValueInt('damage_max')-ability:GetSpecialValueInt('damage_min'))*distance/math.max(radius,1)
                if J.WillKillTarget(unit,damage,DAMAGE_TYPE_MAGICAL,delay)
                    or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                    or J.IsInTeamFight(bot,1200) or J.IsRetreating(bot) and unit:GetAttackTarget()==bot
                    or unit:HasModifier('modifier_flask_healing') then return BOT_ACTION_DESIRE_HIGH end
            end
        end
    end
    return 0
end
function R.Link(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local best,score=nil,-1
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(R.Range(bot,ability),1600),true,BOT_MODE_NONE)) do
        if valid(unit) and J.CanCastOnTargetAdvanced(unit) then
            local index=unit:GetModifierByName('modifier_razor_static_link_debuff')
            local own=index>=0 and unit:GetModifierSourceAbility(index)==ability
            local victim=unit:GetAttackTarget()
            local peel=J.IsValidHero(victim) and victim:GetTeam()==bot:GetTeam() and victim:WasRecentlyDamagedByAnyHero(2)
            if not own and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200) or J.IsLaning(bot)
                or J.IsRetreating(bot) and victim==bot or peel) then
                local value=unit:GetAttackDamage()
                if peel or J.IsRetreating(bot) and victim==bot then value=value+150 end
                if value>score then best=unit;score=value end
            end
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH,best end
    return 0,nil
end
function R.Storm(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0 end
    local radius=ability:GetSpecialValueInt('radius')
    local count=0
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
        if valid(unit) and not unit:IsAttackImmune() and not J.IsInEtherealForm(unit) then
            count=count+1
            if J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and unit:GetAttackTarget()==bot and bot:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    -- A real Refresher recast is useful: successive storms are separate instances.
    if J.IsInTeamFight(bot,1200) and count>=2 then return BOT_ACTION_DESIRE_HIGH end
    if native then
        if bot:HasScepter() and (J.IsPushing(bot) or J.IsDefending(bot)) then
            for _,tower in pairs(bot:GetNearbyTowers(math.min(radius,1600),true)) do
                if J.IsValid(tower) and J.CanBeAttacked(tower) and not tower:HasModifier('modifier_fountain_glyph') then return BOT_ACTION_DESIRE_HIGH end
            end
        end
        if J.IsFarming(bot) and J.IsAllowedToSpam(bot,ability:GetManaCost()) and #bot:GetNearbyNeutralCreeps(math.min(radius,1600))>=3 then return BOT_ACTION_DESIRE_HIGH end
        local target=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
            and J.IsValid(target) and J.IsInRange(bot,target,radius) and J.CanBeAttacked(target) and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
return R
