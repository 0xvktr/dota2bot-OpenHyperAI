local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local U = require(GetScriptDirectory()..'/FunLib/minion_lib/utils')
local X = {}

-- Only effects confirmed to be removable by a basic dispel belong here.
local alliedDebuffs = {
    'modifier_crystal_maiden_frostbite',
    'modifier_bane_enfeeble_effect',
    'modifier_orchid_malevolence_debuff',
    'modifier_bloodthorn_debuff',
    'modifier_item_diffusal_blade_slow',
}
local enemyBuffs = {
    'modifier_abaddon_aphotic_shield',
    'modifier_ember_spirit_flame_guard',
}

local function HasAnyModifier(unit, modifiers)
    for _, name in ipairs(modifiers) do
        if unit:HasModifier(name) then return true end
    end
    return false
end

local function CanUse(unit, ability)
    return ability ~= nil and ability:IsFullyCastable() and not ability:IsHidden()
        and not U.CanNotUseAbility(unit)
end

local function CanDisable(unit, target, ability)
    return U.IsValidUnit(target) and target:GetTeam() ~= unit:GetTeam()
        and not target:IsMagicImmune() and not target:IsInvulnerable()
        and not J.IsSuspiciousIllusion(target) and J.CanCastOnTargetAdvanced(target)
        and not target:HasModifier('modifier_antimage_counterspell')
        and GetUnitToUnitDistance(unit, target) <= ability:GetCastRange()
end

local function InterruptTarget(unit, ability, enemies)
    if not CanUse(unit, ability) then return nil end
    for _, enemy in pairs(enemies) do
        if CanDisable(unit, enemy, ability) and enemy:IsChanneling() then return enemy end
    end
    return nil
end

local function AttackAllowed(unit, target)
    return U.IsValidTarget(target) and target:GetTeam() ~= unit:GetTeam()
        and not U.IsNotAllowedToAttack(target)
        and not target:HasModifier('modifier_abaddon_borrowed_time')
end

local function AttackTarget(unit, focus)
    if U.CantAttack(unit) then return nil end
    if AttackAllowed(unit, focus) and GetUnitToUnitDistance(unit, focus) <= 1600 then return focus end
    local groups = {
        unit:GetNearbyHeroes(1600, true, BOT_MODE_NONE),
        unit:GetNearbyLaneCreeps(1600, true),
        unit:GetNearbyBarracks(1600, true),
        unit:GetNearbyTowers(1600, true),
    }
    for _, units in ipairs(groups) do
        local best
        for _, target in pairs(units) do
            if AttackAllowed(unit, target) and (best == nil or target:GetHealth() < best:GetHealth()) then
                best = target
            end
        end
        if best ~= nil then return best end
    end
    return nil
end

local function DispelLocation(unit, ability, target)
    local location = target:GetLocation()
    local delta = location - unit:GetLocation()
    if delta:Length2D() > ability:GetCastRange() then
        location = unit:GetLocation() + delta:Normalized() * ability:GetCastRange()
    end
    if GetUnitToLocationDistance(target, location) <= ability:GetSpecialValueInt('radius') then
        return location
    end
    return nil
end

local function UsefulDispel(unit, ability, enemies)
    if not CanUse(unit, ability) then return nil end
    local reach = math.min(ability:GetCastRange() + ability:GetSpecialValueInt('radius'), 1600)
    for _, ally in pairs(unit:GetNearbyHeroes(reach, false, BOT_MODE_NONE)) do
        if U.IsValidUnit(ally) and HasAnyModifier(ally, alliedDebuffs) then
            local location = DispelLocation(unit, ability, ally)
            if location ~= nil then return location end
        end
    end
    for _, enemy in pairs(enemies) do
        if U.IsValidUnit(enemy) and not enemy:IsMagicImmune() and not enemy:IsInvulnerable()
            and (enemy:IsIllusion() or HasAnyModifier(enemy, enemyBuffs)) then
            local location = DispelLocation(unit, ability, enemy)
            if location ~= nil then return location end
        end
    end
    return nil
end

local function CycloneTarget(bot, unit, ability, focus, enemies)
    if not CanUse(unit, ability) then return nil end
    local realEnemies = 0
    for _, enemy in pairs(enemies) do
        if U.IsValidUnit(enemy) and not J.IsSuspiciousIllusion(enemy) then realEnemies = realEnemies + 1 end
    end
    if realEnemies < 2 then return nil end
    local best, threat = nil, -1
    for _, enemy in pairs(enemies) do
        if enemy ~= focus and CanDisable(unit, enemy, ability)
            and not J.IsDisabled(enemy) and not J.IsTaunted(enemy)
            and not enemy:HasModifier('modifier_abaddon_borrowed_time') then
            local damage = enemy:GetEstimatedDamageToTarget(true, bot, 5, DAMAGE_TYPE_ALL)
            if damage > threat then best, threat = enemy, damage end
        end
    end
    return best
end

local function MoveAway(unit)
    if not U.CantMove(unit) then unit:Action_MoveToLocation(J.GetTeamFountain()) end
end

function X.MinionThink(bot, unit)
    if not U.IsValidUnit(unit) or U.IsBusy(unit) then return end
    local focus = J.GetProperTarget(bot)
    local enemies = unit:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    local name = unit:GetUnitName()

    if string.find(name, 'npc_dota_brewmaster_storm') then
        local dispel = unit:GetAbilityByName('brewmaster_storm_dispel_magic')
        local cyclone = unit:GetAbilityByName('brewmaster_storm_cyclone')
        local windWalk = unit:GetAbilityByName('brewmaster_storm_wind_walk')
        local target = InterruptTarget(unit, cyclone, enemies)
        if target ~= nil then unit:Action_UseAbilityOnEntity(cyclone, target); return end
        local escape = unit:GetHealth() <= unit:GetMaxHealth() * 0.3 or J.IsRetreating(bot)
        if escape then
            if #enemies > 0 and not unit:IsInvisible() and CanUse(unit, windWalk) then
                unit:Action_UseAbility(windWalk)
                unit.primalSplitWindWalkTime = DotaTime()
            else
                MoveAway(unit)
            end
            return
        end
        if windWalk ~= nil and unit.primalSplitWindWalkTime ~= nil
            and DotaTime() - unit.primalSplitWindWalkTime < windWalk:GetSpecialValueFloat('fade_time') then
            return
        end
        local location = UsefulDispel(unit, dispel, enemies)
        if location ~= nil then unit:Action_UseAbilityOnLocation(dispel, location); return end
        target = CycloneTarget(bot, unit, cyclone, focus, enemies)
        if target ~= nil then unit:Action_UseAbilityOnEntity(cyclone, target); return end
        if not unit:IsInvisible() and CanUse(unit, windWalk) and AttackTarget(unit, focus) ~= nil then
            unit:Action_UseAbility(windWalk)
            unit.primalSplitWindWalkTime = DotaTime()
            return
        end
    elseif string.find(name, 'npc_dota_brewmaster_earth') then
        local boulder = unit:GetAbilityByName('brewmaster_earth_hurl_boulder')
        local target = InterruptTarget(unit, boulder, enemies)
        if target ~= nil then unit:Action_UseAbilityOnEntity(boulder, target); return end
        -- Earth is the first rebirth location; preserve it before ordinary damage casts.
        if unit:GetHealth() <= unit:GetMaxHealth() * 0.3 then MoveAway(unit); return end
        if CanUse(unit, boulder) then
            if CanDisable(unit, focus, boulder) and not J.IsDisabled(focus) and not J.IsTaunted(focus) then
                target = focus
            else
                for _, enemy in pairs(enemies) do
                    if CanDisable(unit, enemy, boulder) and not J.IsDisabled(enemy) and not J.IsTaunted(enemy)
                        and (target == nil or enemy:GetHealth() < target:GetHealth()) then target = enemy end
                end
            end
            if target ~= nil then unit:Action_UseAbilityOnEntity(boulder, target); return end
        end
    end
    -- Fire's abilities are passive. Current Primal Split summons no Void spirit.
    -- Scepter cancel is present on the spirits, but automatic early rebirth needs engine validation.
    local target = AttackTarget(unit, focus)
    if target ~= nil then unit:Action_AttackUnit(target, false); return end
    if U.CantMove(unit) then return end
    local location = J.GetClosestTeamLane(unit)
    if #J.GetEnemiesNearLoc(location, 1600) == 0 then
        unit:Action_MoveToLocation(location)
    else
        local allies = unit:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
        if U.IsValidUnit(allies[1]) then unit:Action_MoveToLocation(allies[1]:GetLocation())
        else MoveAway(unit) end
    end
end

return X
