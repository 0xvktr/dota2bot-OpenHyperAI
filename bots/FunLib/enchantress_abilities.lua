-- Decisions shared by Enchantress and independent stolen spells.
local E = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit)
        and not J.IsSuspiciousIllusion(unit)
end
local function CastRange(bot, ability)
    local bonus = 0
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item and item:GetName() == 'item_aether_lens' then
            bonus = item:GetSpecialValueInt('cast_range_bonus'); break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        bonus = bonus + supremacy:GetSpecialValueInt('cast_range')
    end
    return ability:GetCastRange() + bonus
end

function E.Impetus(bot, ability)
    if not ability or not ability:IsTrained() then return BOT_ACTION_DESIRE_NONE end
    local target = bot:GetAttackTarget()
    local useful = J.CanCastAbility(ability) and not bot:IsDisarmed()
        and J.IsValid(target) and J.CanCastOnNonMagicImmune(target) and J.CanBeAttacked(target)
        and not J.IsInEtherealForm(target) and J.IsInRange(bot, target, bot:GetAttackRange())
        and (J.IsGoingOnSomeone(bot) and Enemy(target)
            or J.IsFarming(bot) and ability:GetLevel() >= 4 and J.GetMP(bot) > 0.45 and not target:IsBuilding()
            or J.IsDoingRoshan(bot) and J.IsRoshan(target) and J.GetMP(bot) > 0.25)
    -- Retain enough mana for the actual heal when trading.
    local heal = bot:GetAbilityByName('enchantress_natures_attendants')
    if useful and heal and heal:IsTrained() and J.GetHP(bot) < 0.75
        and bot:GetMana() < ability:GetManaCost() + heal:GetManaCost() then useful = false end
    if ability:GetAutoCastState() ~= useful then
        ability:ToggleAutoCast(); return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

function E.Heal(bot, ability)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_enchantress_natures_attendants') then return 0 end
    local heroes = {bot}
    for _, ally in pairs(J.GetNearbyHeroes(bot, ability:GetSpecialValueInt('radius'), false, BOT_MODE_NONE)) do
        if ally ~= bot then table.insert(heroes, ally) end
    end
    for _, ally in pairs(heroes) do
        if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally)
            and not ally:HasModifier('modifier_ice_blast') and J.GetHP(ally) < 0.7
            and (ally:WasRecentlyDamagedByAnyHero(2) or J.IsGoingOnSomeone(ally) or J.IsRetreating(ally)
                or ally == bot and J.GetHP(bot) < 0.5 and bot:DistanceFromFountain() > 800) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    return 0
end

function E.LittleFriends(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    local range = CastRange(bot, ability)
    local target = J.GetProperTarget(bot)
    for _, enemy in pairs(J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)) do
        if Enemy(enemy) and J.CanCastOnTargetAdvanced(enemy) and not J.IsDisabled(enemy)
            and (enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy)
                or J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot)
                or J.IsGoingOnSomeone(bot) and enemy == target) then
            -- The base root remains useful even when there are no nearby creeps.
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    return 0, nil
end

function E.Sproink(bot, ability)
    if not J.CanCastAbility(ability) then return 0 end
    local loc, angle = bot:GetLocation(), bot:GetFacing() * math.pi / 180
    local hop = ability:GetSpecialValueInt('hop_distance')
    local landing = Vector(loc.x - math.cos(angle) * hop, loc.y - math.sin(angle) * hop, loc.z)
    if not IsLocationPassable(landing)
        or #J.GetEnemiesNearLoc(landing, 600) > #J.GetNearbyHeroes(bot, 600, true, BOT_MODE_NONE) then return 0 end
    if J.IsStunProjectileIncoming(bot, 600) then return BOT_ACTION_DESIRE_HIGH end
    local impetus = bot:GetAbilityByName('enchantress_impetus')
    local target = J.GetProperTarget(bot)
    if impetus and impetus:IsTrained() and not bot:IsDisarmed() and Enemy(target)
        and J.CanBeAttacked(target) and not J.IsInEtherealForm(target)
        and J.IsInRange(bot, target, bot:GetAttackRange() + ability:GetSpecialValueInt('bonus_attack_range'))
        and GetUnitToLocationDistance(target, landing) > GetUnitToUnitDistance(bot, target) + 100
        and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot)) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

local goodCreeps = {
    npc_dota_neutral_alpha_wolf=true, npc_dota_neutral_centaur_khan=true,
    npc_dota_neutral_polar_furbolg_ursa_warrior=true, npc_dota_neutral_dark_troll_warlord=true,
    npc_dota_neutral_satyr_hellcaller=true, npc_dota_neutral_enraged_wildkin=true,
    npc_dota_neutral_warpine_raider=true,
}
function E.Enchant(bot, ability)
    if not J.CanCastAbility(ability) then return 0, nil end
    local range = CastRange(bot, ability)
    local target = J.GetProperTarget(bot)
    for _, enemy in pairs(J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)) do
        if Enemy(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and (J.IsGoingOnSomeone(bot) and enemy == target
                or J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot)
                or enemy:HasModifier('modifier_ember_spirit_flame_guard')
                or enemy:HasModifier('modifier_dark_seer_surge')
                or enemy:HasModifier('modifier_windrunner_windrun')) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    for _, ally in pairs(J.GetNearbyHeroes(bot, range, false, BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2) then
            for _, enemy in pairs(J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)) do
                if Enemy(enemy) and J.CanCastOnTargetAdvanced(enemy) and not J.IsDisabled(enemy)
                    and J.IsChasingTarget(enemy, ally) then return BOT_ACTION_DESIRE_HIGH, enemy end
            end
        end
    end
    local owned = 0
    for _, creep in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if J.IsValid(creep) and creep:GetPlayerID() == bot:GetPlayerID()
            and creep:HasModifier('modifier_enchantress_enchant')
            and J.GetModifierTime(creep, 'modifier_enchantress_enchant') > 5 then owned = owned + 1 end
    end
    if owned >= ability:GetSpecialValueInt('max_creeps') then return 0, nil end
    for _, creep in pairs(bot:GetNearbyNeutralCreeps(range)) do
        if J.IsValid(creep) and not creep:IsAncientCreep() and not creep:IsMagicImmune()
            and creep:GetLevel() <= ability:GetSpecialValueInt('level_req') and goodCreeps[creep:GetUnitName()] then
            return BOT_ACTION_DESIRE_HIGH, creep
        end
    end
    return 0, nil
end
return E
