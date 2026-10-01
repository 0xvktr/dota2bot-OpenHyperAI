local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local WildAxes, CallOfTheWildBoar, CallOfTheWildHawk, PrimalRoar
local Blink, BlinkLocation, BlackKingBar, botTarget

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local name = ability:GetName()
    if name ~= 'beastmaster_primal_roar' and name ~= 'beastmaster_wild_axes'
        and name ~= 'beastmaster_summon_razorback' and name ~= 'beastmaster_summon_raptor' then return nil end
    bot.shouldBlink = false
    if J.CanNotUseAbility(bot) then return false end
    botTarget = J.GetProperTarget(bot)
    -- Stealing Roar does not guarantee that Rubick also has Wild Axes.
    WildAxes = bot:GetAbilityByName('beastmaster_wild_axes')
    PrimalRoar = bot:GetAbilityByName('beastmaster_primal_roar')
    if name == 'beastmaster_primal_roar' then
        PrimalRoar = ability
        local desire, target = X.ConsiderPrimalRoar()
        if desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
        desire, target = X.ConsiderBlinkRoar()
        if desire > 0 then
            bot:Action_ClearActions(false)
            if X.CanBKB() and bot:GetMana() >= PrimalRoar:GetManaCost()
                + Blink:GetManaCost() + BlackKingBar:GetManaCost() then
                bot:ActionQueue_UseAbility(BlackKingBar)
                bot:ActionQueue_Delay(0.1)
            end
            bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
            bot:ActionQueue_Delay(0.1)
            bot:ActionQueue_UseAbilityOnEntity(ability, target)
            return true
        end
    elseif name == 'beastmaster_wild_axes' then
        WildAxes = ability
        local desire, location = X.ConsiderWildAxes()
        if desire > 0 then bot:Action_UseAbilityOnLocation(ability, location); return true end
    elseif name == 'beastmaster_summon_razorback' then
        CallOfTheWildBoar = ability
        if X.ConsiderCallOfTheWildBoar() > 0 then bot:Action_UseAbility(ability); return true end
    else
        CallOfTheWildHawk = ability
        if X.ConsiderCallOfTheWildHawk() > 0 then bot:Action_UseAbility(ability); return true end
    end
    return false
end

local function Castable(ability)
    return ability ~= nil and ability:IsFullyCastable() and not ability:IsHidden()
end

local function CastRange(ability, fallback)
    local range = math.max(ability:GetCastRange(), fallback or 0)
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function ClampLocation(location, range)
    local origin = bot:GetLocation()
    local delta = location - origin
    if delta:Length2D() > range then return origin + delta:Normalized() * range end
    return location
end

local function CanRoar(target)
    return J.IsValidHero(target) and J.CanCastOnMagicImmune(target)
        and J.CanCastOnTargetAdvanced(target) and not J.IsSuspiciousIllusion(target)
        and not target:HasModifier('modifier_antimage_counterspell')
end

local function CanFocus(target)
    return CanRoar(target) and not J.IsDisabled(target) and not J.IsTaunted(target)
        and not target:HasModifier('modifier_abaddon_borrowed_time')
        and not target:HasModifier('modifier_dazzle_shallow_grave')
        and not target:HasModifier('modifier_oracle_false_promise_timer')
        and not target:HasModifier('modifier_necrolyte_reapers_scythe')
end

local function HasBackup(target)
    local allies = J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE)
    local defenders = J.GetNearbyHeroes(target, 1200, false, BOT_MODE_NONE)
    -- The nearby-hero API excludes its source unit.
    return #allies + 1 >= #defenders + 1
end

local function KeepCombatMana(ability)
    local reserve = 0
    if PrimalRoar ~= nil and PrimalRoar:IsTrained() then reserve = PrimalRoar:GetManaCost() end
    return bot:GetMana() - ability:GetManaCost() >= reserve
        and (bot:GetMana() - ability:GetManaCost()) / bot:GetMaxMana() >= 0.25
end

function X.ConsiderPrimalRoar()
    if not Castable(PrimalRoar) then return BOT_ACTION_DESIRE_NONE, nil end
    local range = CastRange(PrimalRoar)
    local enemies = J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if CanRoar(enemy) and J.IsInRange(bot, enemy, range)
            and (enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy)) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    for _, enemy in pairs(enemies) do
        if CanFocus(enemy) and J.IsInRange(bot, enemy, range)
            and J.CanCastOnNonMagicImmune(enemy)
            and J.CanKillTarget(enemy, PrimalRoar:GetSpecialValueInt('damage'), DAMAGE_TYPE_MAGICAL)
            and (not Castable(WildAxes)
                or not J.CanKillTarget(enemy, WildAxes:GetSpecialValueInt('axe_damage'), DAMAGE_TYPE_MAGICAL)) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _, enemy in pairs(enemies) do
            if CanFocus(enemy) and J.IsInRange(bot, enemy, range)
                and enemy:IsFacingLocation(bot:GetLocation(), 45) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    if J.IsGoingOnSomeone(bot) and CanFocus(botTarget)
        and J.IsInRange(bot, botTarget, range) and HasBackup(botTarget) then
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    if J.IsInTeamFight(bot, 1200) then
        local best, threat = nil, -1
        for _, enemy in pairs(enemies) do
            if CanFocus(enemy) and J.IsInRange(bot, enemy, range) then
                local damage = enemy:GetEstimatedDamageToTarget(true, bot, 5, DAMAGE_TYPE_ALL)
                if J.IsHaveAegis(enemy) or enemy:HasModifier('modifier_skeleton_king_reincarnation') then
                    damage = damage * 0.3
                end
                if damage > threat then best, threat = enemy, damage end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.HasBlink()
    Blink = nil
    for i = 0, 5 do
        local item = bot:GetItemInSlot(i)
        if item ~= nil and (item:GetName() == 'item_blink' or item:GetName() == 'item_overwhelming_blink'
            or item:GetName() == 'item_arcane_blink' or item:GetName() == 'item_swift_blink')
            and item:IsFullyCastable() then
            Blink = item
            return true
        end
    end
    return false
end

function X.CanDoBlinkRoar()
    return Castable(PrimalRoar) and not bot:IsRooted()
        and not bot:HasModifier('modifier_bloodseeker_rupture')
        and X.HasBlink() and bot:GetMana() >= PrimalRoar:GetManaCost() + Blink:GetManaCost()
end

function X.ConsiderBlinkRoar()
    bot.shouldBlink = false
    if not J.IsGoingOnSomeone(bot) or not X.CanDoBlinkRoar() then
        return BOT_ACTION_DESIRE_NONE, nil
    end
    local range = CastRange(PrimalRoar)
    local blinkRange = CastRange(Blink, Blink:GetSpecialValueInt('blink_range'))
    if blinkRange <= 0 then return BOT_ACTION_DESIRE_NONE, nil end
    local candidates = {botTarget}
    for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(range + blinkRange, 1600), true, BOT_MODE_NONE)) do
        table.insert(candidates, enemy)
    end
    for _, enemy in pairs(candidates) do
        if CanFocus(enemy) and not J.IsInRange(bot, enemy, range)
            and J.IsInRange(bot, enemy, range + blinkRange - 100) and HasBackup(enemy) then
            -- Stop in Roar range, without asking Blink to exceed its maximum distance.
            local distance = GetUnitToUnitDistance(bot, enemy)
            local landing = ClampLocation(enemy:GetLocation(), math.min(blinkRange - 1, distance - range + 100))
            if IsLocationPassable(landing) and not J.IsLocationInChrono(landing)
                and not J.IsLocationInBlackHole(landing) then
                bot.shouldBlink = true
                BlinkLocation = landing
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.CanBKB()
    for i = 0, 5 do
        local item = bot:GetItemInSlot(i)
        if item ~= nil and item:GetName() == 'item_black_king_bar' and item:IsFullyCastable()
            and not bot:IsMagicImmune() then
            BlackKingBar = item
            return true
        end
    end
    return false
end

local function AxesLocation(target)
    local range = CastRange(WildAxes)
    local delay = WildAxes:GetCastPoint()
        + WildAxes:GetSpecialValueFloat('min_throw_duration')
    if not J.IsDisabled(target) then
        local distance = GetUnitToUnitDistance(bot, target)
        delay = WildAxes:GetCastPoint() + WildAxes:GetSpecialValueFloat('min_throw_duration')
            + (WildAxes:GetSpecialValueFloat('max_throw_duration')
                - WildAxes:GetSpecialValueFloat('min_throw_duration')) * math.min(distance / range, 1)
    end
    local location = J.IsDisabled(target) and target:GetLocation() or target:GetExtrapolatedLocation(delay)
    local castLocation = ClampLocation(location, range)
    if (location - castLocation):Length2D() > WildAxes:GetSpecialValueInt('radius') then return nil end
    return castLocation
end

local function CanAxes(target)
    return J.IsValid(target) and J.CanCastOnNonMagicImmune(target)
        and not target:HasModifier('modifier_abaddon_borrowed_time')
end

local function FarmAxes(units, minimum)
    local range, radius = CastRange(WildAxes), WildAxes:GetSpecialValueInt('radius')
    local best, count = nil, 0
    for _, unit in pairs(units) do
        if CanAxes(unit) then
            local location = ClampLocation(unit:GetLocation(), range)
            local hits = 0
            for _, other in pairs(units) do
                if CanAxes(other) and GetUnitToLocationDistance(other, location) <= radius
                    and not other:HasModifier('modifier_fountain_glyph') then hits = hits + 1 end
            end
            if hits > count then best, count = location, hits end
        end
    end
    if count >= minimum then return BOT_ACTION_DESIRE_HIGH, best end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderWildAxes()
    if not Castable(WildAxes) then return BOT_ACTION_DESIRE_NONE, nil end
    local range, radius = CastRange(WildAxes), WildAxes:GetSpecialValueInt('radius')
    local damage = WildAxes:GetSpecialValueInt('axe_damage')
    local enemies = J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if CanAxes(enemy) and not J.IsSuspiciousIllusion(enemy) and J.IsInRange(bot, enemy, range)
            and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_oracle_false_promise_timer')
            and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL) then
            local location = AxesLocation(enemy)
            if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
        end
    end
    if J.IsInTeamFight(bot, range) then
        local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), range, radius, WildAxes:GetCastPoint(), 0)
        if aoe.count >= 2 then
            local location = ClampLocation(aoe.targetloc, range)
            local count = 0
            for _, enemy in pairs(enemies) do
                if CanAxes(enemy) and not J.IsSuspiciousIllusion(enemy)
                    and GetUnitToLocationDistance(enemy, location) <= radius then count = count + 1 end
            end
            if count >= 2 then return BOT_ACTION_DESIRE_HIGH, location end
        end
    end
    if (J.IsGoingOnSomeone(bot) or J.IsLaning(bot) and KeepCombatMana(WildAxes))
        and CanAxes(botTarget) and J.IsValidHero(botTarget) and not J.IsSuspiciousIllusion(botTarget)
        and J.IsInRange(bot, botTarget, range) and HasBackup(botTarget) then
        local location = AxesLocation(botTarget)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _, enemy in pairs(enemies) do
            if CanAxes(enemy) and not J.IsSuspiciousIllusion(enemy)
                and J.IsInRange(bot, enemy, 700) and enemy:IsFacingLocation(bot:GetLocation(), 45) then
                local location = AxesLocation(enemy)
            if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    if KeepCombatMana(WildAxes) then
        if J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot) then
            local desire, location = FarmAxes(bot:GetNearbyLaneCreeps(math.min(range, 1600), true), 3)
            if desire > 0 then return desire, location end
            if J.IsFarming(bot) and J.IsAttacking(bot) then
                return FarmAxes(bot:GetNearbyNeutralCreeps(800), 2)
            end
        end
        if J.IsLaning(bot) then
            local lastHits = {}
            for _, creep in pairs(bot:GetNearbyLaneCreeps(math.min(range, 1600), true)) do
                if CanAxes(creep) and J.CanKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL) then
                    table.insert(lastHits, creep)
                end
            end
            return FarmAxes(lastHits, 2)
        end
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(botTarget))
        or (J.IsDoingTormentor(bot) and J.IsTormentor(botTarget)))
        and CanAxes(botTarget) and J.IsInRange(bot, botTarget, range) and J.IsAttacking(bot) then
        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderCallOfTheWildBoar()
    if not Castable(CallOfTheWildBoar) then return BOT_ACTION_DESIRE_NONE end
    if J.IsGoingOnSomeone(bot) and J.IsValidTarget(botTarget) and J.IsInRange(bot, botTarget, 900) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsLaning(bot) and KeepCombatMana(CallOfTheWildBoar)
        and (#bot:GetNearbyLaneCreeps(800, true) > 0 or #J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE) > 0) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot)) and J.IsAttacking(bot)
        and KeepCombatMana(CallOfTheWildBoar)
        and (#bot:GetNearbyLaneCreeps(800, true) > 0 or #bot:GetNearbyNeutralCreeps(800) > 0
            or #bot:GetNearbyTowers(800, true) > 0) then return BOT_ACTION_DESIRE_HIGH end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(botTarget))
        or (J.IsDoingTormentor(bot) and J.IsTormentor(botTarget)))
        and J.IsInRange(bot, botTarget, 600) and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCallOfTheWildHawk()
    if not Castable(CallOfTheWildHawk) then return BOT_ACTION_DESIRE_NONE end
    -- Raptors remain for 25 seconds and automatically prioritize heroes and our attack target.
    local radius = CallOfTheWildHawk:GetSpecialValueInt('attack_radius')
    for _, enemy in pairs(J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and not J.IsSuspiciousIllusion(enemy) and J.IsInRange(bot, enemy, radius)
            and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)
                or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
                or J.IsLaning(bot) and KeepCombatMana(CallOfTheWildHawk)) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    if KeepCombatMana(CallOfTheWildHawk) and J.IsAttacking(bot)
        and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and (#bot:GetNearbyNeutralCreeps(radius) > 0 or #bot:GetNearbyLaneCreeps(radius, true) > 0) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(botTarget))
        or (J.IsDoingTormentor(bot) and J.IsTormentor(botTarget)))
        and J.IsInRange(bot, botTarget, radius) and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

return X
