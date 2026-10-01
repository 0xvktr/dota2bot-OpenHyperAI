local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local abilityQ, abilityW, abilityR
function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local name = ability:GetName()
    if name ~= 'chaos_knight_chaos_bolt' and name ~= 'chaos_knight_reality_rift'
        and name ~= 'chaos_knight_phantasm' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local desire, target
    if name == 'chaos_knight_phantasm' then
        abilityR=ability; desire=X.ConsiderPhantasm()
        if desire > 0 then bot:ActionQueue_UseAbility(ability); return true end
    elseif name == 'chaos_knight_chaos_bolt' then abilityQ=ability; desire,target=X.ConsiderChaosBolt()
    else abilityW=ability; desire,target=X.ConsiderRealityRift() end
    if desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
    return false
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function CanTarget(enemy, ability, immune)
    return J.IsValid(enemy) and J.IsInRange(bot, enemy, CastRange(ability))
        and (immune and J.CanCastOnMagicImmune(enemy) or not immune and J.CanCastOnNonMagicImmune(enemy))
        and J.CanCastOnTargetAdvanced(enemy)
        and not enemy:HasModifier('modifier_antimage_counterspell')
        and not enemy:HasModifier('modifier_antimage_counterspell_ally')
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    local enemies = J.GetNearbyHeroes(bot, math.min(CastRange(abilityQ), 1600), true, BOT_MODE_NONE)
    local damage = abilityQ:GetSpecialValueInt('damage_min')
    for _, enemy in ipairs(enemies) do
        if CanTarget(enemy, abilityQ, false) then
            local delay = abilityQ:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / abilityQ:GetSpecialValueInt('chaos_bolt_speed')
            -- Only the minimum random roll can guarantee a kill.
            if enemy:IsChanneling() or J.WillMagicKillTarget(bot, enemy, damage, delay) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and CanTarget(target, abilityQ, false)
        and not J.IsDisabled(target) then return BOT_ACTION_DESIRE_HIGH, target end
    local best, power = nil, 0
    for _, enemy in ipairs(enemies) do
        if CanTarget(enemy, abilityQ, false) and not J.IsDisabled(enemy) then
            if J.IsRetreating(bot) and bot:WasRecentlyDamagedByHero(enemy, 3) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            if J.IsInTeamFight(bot, 1200) then
                local value = enemy:GetEstimatedDamageToTarget(false, bot, 3, DAMAGE_TYPE_ALL)
                if value > power then best, power = enemy, value end
            end
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH, best end
    return 0
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) or bot:IsRooted() then return 0 end
    local target = J.GetProperTarget(bot)
    local talent = bot:GetAbilityByName('special_bonus_unique_chaos_knight')
    local immune = abilityW:GetSpecialValueInt('pierces_immunity') == 1 or talent ~= nil and talent:IsTrained()
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and CanTarget(target, abilityW, immune)
        and not target:IsAttackImmune()
        and (not J.IsInRange(bot, target, bot:GetAttackRange())
            or not target:HasModifier('modifier_chaos_knight_reality_rift')) then
        -- Pull allied-controlled targets as well: the armor debuff benefits the illusion burst.
        return BOT_ACTION_DESIRE_HIGH, target
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target)
        and (J.IsRoshan(target) or J.IsTormentor(target)) and J.IsAttacking(bot)
        and CanTarget(target, abilityW, immune) then return BOT_ACTION_DESIRE_HIGH, target end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) == 0
        and J.IsAllowedToSpam(bot, abilityW:GetManaCost()) then
        for _, creep in ipairs(bot:GetNearbyLaneCreeps(math.min(CastRange(abilityW), 1600), true)) do
            if CanTarget(creep, abilityW, immune) and J.IsKeyWordUnit('ranged', creep)
                and not creep:HasModifier('modifier_fountain_glyph')
                and not J.IsInRange(bot, creep, 350) then return BOT_ACTION_DESIRE_HIGH, creep end
        end
    end
    return 0
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) or bot:DistanceFromFountain() < 500 then return 0 end
    if bot:IsRooted() or bot:HasModifier('modifier_item_dustofappearance')
        or J.IsUnitTargetProjectileIncoming(bot, 800) then return BOT_ACTION_DESIRE_HIGH end
    local target = J.GetProperTarget(bot)
    local enemies = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE)
    local reserve = 0
    for _, name in ipairs({'chaos_knight_chaos_bolt','chaos_knight_reality_rift'}) do
        local spell = bot:GetAbilityByName(name)
        if J.CanCastAbility(spell) then reserve = reserve + spell:GetManaCost() end
    end
    if bot:GetMana() - abilityR:GetManaCost() < reserve then return 0 end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnMagicImmune(target)
        and J.IsInRange(bot, target, 1000) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsInTeamFight(bot, 1200) and #enemies >= 2 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsRetreating(bot) and #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if #enemies == 0 and J.IsFarming(bot) and J.IsAttacking(bot) then
        local creeps = bot:GetNearbyNeutralCreeps(700)
        for _, creep in ipairs(creeps) do
            if J.IsValid(creep) and (creep:IsAncientCreep() or #creeps >= 3)
                and creep:GetHealth() > bot:GetAttackDamage() * 3 then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if J.IsPushing(bot) and #bot:GetNearbyLaneCreeps(1000, false) >= 2
        and (#bot:GetNearbyTowers(700, true) > 0 or #bot:GetNearbyBarracks(500, true) > 0) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target)
        and (J.IsRoshan(target) or J.IsTormentor(target)) and J.IsAttacking(bot)
        and J.IsInRange(bot, target, 700) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

X.ConsiderChaosBolt=X.ConsiderQ
X.ConsiderRealityRift=X.ConsiderW
X.ConsiderPhantasm=X.ConsiderR
return X
