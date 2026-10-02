local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,Void,CripplingFear,MidnightFeast,DarkAscension
function X.IsNight()
    local time = GetTimeOfDay()
    return time < 0.25 or time > 0.75 or bot:HasModifier('modifier_night_stalker_darkness')
end
local function SpellRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(enemy)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and J.CanCastOnNonMagicImmune(enemy)
end
function X.ConsiderVoid()
    if not J.CanCastAbility(Void) then return 0 end
    local range = SpellRange(Void)
    local damage = Void:GetSpecialValueInt('damage')
    local enemies = J.GetNearbyHeroes(bot, math.min(range + Void:GetSpecialValueInt('cast_radius'), 1600), true, BOT_MODE_NONE)
    for _, enemy in ipairs(enemies) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, range) and J.CanCastOnTargetAdvanced(enemy)
            and (X.IsNight() and enemy:IsChanneling() or J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL)
                and not J.CannotBeKilled(bot, enemy)) then return BOT_ACTION_DESIRE_HIGH, enemy end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsInRange(bot, target, range)
        and J.CanCastOnTargetAdvanced(target) and not J.CannotBeKilled(bot, target) then return BOT_ACTION_DESIRE_HIGH, target end
    for _, enemy in ipairs(enemies) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, range) and J.CanCastOnTargetAdvanced(enemy)
            and J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
            and J.IsChasingTarget(enemy, bot) then return BOT_ACTION_DESIRE_HIGH, enemy end
    end
    if J.IsInTeamFight(bot, 1200) then
        local best, count = nil, 0
        local radius = Void:GetSpecialValueInt('cast_radius')
        for _, enemy in ipairs(enemies) do
            if Enemy(enemy) and J.IsInRange(bot, enemy, range) and J.CanCastOnTargetAdvanced(enemy) then
                local affected = 1
                if radius > 0 then
                    for _, other in ipairs(enemies) do
                        if other ~= enemy and Enemy(other) and J.IsInRange(enemy, other, radius) then affected = affected + 1 end
                    end
                end
                if affected > count then best, count = enemy, affected end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    end
    if J.IsLaning(bot) and J.IsAllowedToSpam(bot, Void:GetManaCost()) then
        for _, creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range, 1600), true)) do
            if J.IsValid(creep) and J.IsKeyWordUnit('ranged', creep) and J.CanCastOnNonMagicImmune(creep)
                and J.IsInRange(bot, creep, range) and J.CanKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL)
                and not J.IsInRange(bot, creep, bot:GetAttackRange()) then return BOT_ACTION_DESIRE_HIGH, creep end
        end
    end
    return 0
end
function X.ConsiderCripplingFear()
    if not J.CanCastAbility(CripplingFear) or bot:HasModifier('modifier_night_stalker_crippling_fear') then return 0 end
    local radius = CripplingFear:GetSpecialValueInt('radius')
    local count = 0
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, radius) then
            count = count + 1
            if enemy:IsChanneling() and not enemy:IsSilenced() then return BOT_ACTION_DESIRE_HIGH end
            if (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2))
                and not enemy:IsSilenced() then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if J.IsInTeamFight(bot, 1200) and count >= 2 then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and J.IsAllowedToSpam(bot, CripplingFear:GetManaCost())
        and #bot:GetNearbyCreeps(math.min(radius, 1600), true) >= 4 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderMidnightFeast()
    if not J.CanCastAbility(MidnightFeast) or not X.IsNight() then return 0 end
    local hpRestore = MidnightFeast:GetSpecialValueInt('hp_restore') / 100
    local mpRestore = MidnightFeast:GetSpecialValueInt('mp_restore') / 100
    if (bot:HasModifier('modifier_ice_blast') or J.GetHP(bot) > 1 - hpRestore)
        and J.GetMP(bot) > 1 - mpRestore then return 0 end
    local range = SpellRange(MidnightFeast)
    local best
    for _, creep in ipairs(bot:GetNearbyCreeps(math.min(range, 1600), true)) do
        if J.IsValid(creep) and creep:GetTeam() ~= bot:GetTeam() and not creep:IsAncientCreep()
            and J.CanCastOnNonMagicImmune(creep) and J.IsInRange(bot, creep, range)
            and (best == nil or creep:GetHealth() > best:GetHealth()) then best = creep end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return 0
end
function X.ConsiderDarkAscension()
    if not J.CanCastAbility(DarkAscension) or bot:HasModifier('modifier_night_stalker_darkness') then return 0 end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and not bot:IsRooted()
        and #J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE) > 0 then return BOT_ACTION_DESIRE_HIGH end
    local target = J.GetProperTarget(bot)
    local reserve = J.CanCastAbility(Void) and Void:GetManaCost() or 0
    if bot:GetMana() < DarkAscension:GetManaCost() + reserve then return 0 end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and not J.IsSuspiciousIllusion(target)
        and J.CanBeAttacked(target) and J.IsInRange(bot, target, 1000)
        and not J.CannotBeKilled(bot, target) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsInTeamFight(bot, 1200) and #J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE) >= 2 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    if name~='night_stalker_void' and name~='night_stalker_crippling_fear'
        and name~='night_stalker_midnight_feast' and name~='night_stalker_darkness' then return nil end
    bot=GetBot();Void=bot:GetAbilityByName('night_stalker_void')
    if J.CanNotUseAbility(bot) or bot:IsChanneling() then return false end
    local desire,target
    if name=='night_stalker_void' then Void=ability;desire,target=X.ConsiderVoid()
    elseif name=='night_stalker_crippling_fear' then CripplingFear=ability;desire=X.ConsiderCripplingFear()
    elseif name=='night_stalker_midnight_feast' then MidnightFeast=ability;desire,target=X.ConsiderMidnightFeast()
    else DarkAscension=ability;desire=X.ConsiderDarkAscension() end
    if desire>0 then
        if target~=nil then bot:Action_UseAbilityOnEntity(ability,target) else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
