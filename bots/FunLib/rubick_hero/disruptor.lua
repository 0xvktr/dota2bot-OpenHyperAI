local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local ThunderStrike, Glimpse, KineticField, KineticFence, StaticStorm
local history = {}
local function Refresh()
    ThunderStrike = bot:GetAbilityByName('disruptor_thunder_strike')
    Glimpse = bot:GetAbilityByName('disruptor_glimpse')
    KineticField = bot:GetAbilityByName('disruptor_kinetic_field')
    KineticFence = bot:GetAbilityByName('disruptor_kinetic_fence')
    StaticStorm = bot:GetAbilityByName('disruptor_static_storm')
end
Refresh()

local function CastRange(ability)
    local range = ability:GetCastRange()
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:GetName() == 'item_aether_lens' then
            range = range + item:GetSpecialValueInt('cast_range_bonus'); break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Heroes()
    -- Glimpse exceeds the engine's 1600 nearby-query cap at high levels.
    local result = {}
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if J.IsValidHero(enemy) then table.insert(result, enemy) end
    end
    return result
end

local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit)
        and not unit:HasModifier('modifier_enigma_black_hole_pull')
        and not unit:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end

local function Targeted(unit, ability)
    return Enemy(unit) and J.IsInRange(bot, unit, CastRange(ability)) and J.CanCastOnTargetAdvanced(unit)
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
end

function X.ObserveGlimpseHistory()
    local live = bot:GetAbilityByName('disruptor_glimpse')
    if live == nil or live:IsNull() or live:IsHidden() or not live:IsTrained() then return false end
    Glimpse = live
    local now = DotaTime()
    for _, enemy in pairs(Heroes()) do
        if not J.IsSuspiciousIllusion(enemy) then
            local entry = history[enemy]
            if entry == nil or now < entry.last or now - entry.last > 0.5 then
                entry = {samples={}, last=now}; history[enemy] = entry
            end
            if #entry.samples == 0 or now - entry.last >= 0.15 then
                local point = enemy:GetLocation()
                local previous = entry.samples[#entry.samples]
                if previous ~= nil and (previous.point - point):Length2D() > 1200 then entry.jump = now end
                table.insert(entry.samples, {time=now, point=point})
                entry.last = now
                while #entry.samples > 0 and now - entry.samples[1].time > 5 do table.remove(entry.samples, 1) end
            end
        end
    end
    return true
end

local function ReturnLocation(enemy)
    local entry = history[enemy]
    if entry == nil or DotaTime() - entry.last > 0.5 then return nil end
    local time = DotaTime() - Glimpse:GetSpecialValueFloat('backtrack_time')
    for index = 1, #entry.samples - 1 do
        local before, after = entry.samples[index], entry.samples[index + 1]
        if before.time <= time and after.time >= time and after.time - before.time <= 0.5 then
            -- Never interpolate across a teleport or Blink discontinuity.
            if (before.point - after.point):Length2D() > 1200 then return nil end
            local fraction = (time - before.time) / (after.time - before.time)
            return before.point + (after.point - before.point) * fraction
        end
    end
    return nil
end

function X.ConsiderGlimpse()
    if not J.CanCastAbility(Glimpse) then return BOT_ACTION_DESIRE_NONE end
    local heroes = Heroes()
    for _, enemy in pairs(heroes) do
        if Targeted(enemy, Glimpse) and (enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy)) then
            return BOT_ACTION_DESIRE_HIGH, enemy, 'interrupt'
        end
    end
    for _, enemy in pairs(heroes) do
        if Targeted(enemy, Glimpse) and not enemy:HasModifier('modifier_disruptor_static_storm')
            and not enemy:HasModifier('modifier_disruptor_glimpse') then
            local point = ReturnLocation(enemy)
            if point ~= nil then
                local entry = history[enemy]
                if entry.jump ~= nil and DotaTime() - entry.jump < 1.5
                    and (point - enemy:GetLocation()):Length2D() > 1400 then
                    return BOT_ACTION_DESIRE_HIGH, enemy, 'arrival'
                end
                local allies = J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_NONE)
                table.insert(allies, bot)
                for _, ally in pairs(allies) do
                    if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally)
                        and J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2)
                        and J.IsChasingTarget(enemy, ally)
                        and GetUnitToLocationDistance(ally, point) > GetUnitToUnitDistance(ally, enemy) + 300 then
                        return BOT_ACTION_DESIRE_HIGH, enemy, 'save'
                    end
                end
                if J.IsGoingOnSomeone(bot) and enemy == J.GetProperTarget(bot)
                    and not J.IsDisabled(enemy) and J.IsChasingTarget(bot, enemy)
                    and GetUnitToLocationDistance(bot, point) + 250 < GetUnitToUnitDistance(bot, enemy) then
                    return BOT_ACTION_DESIRE_HIGH, enemy, 'catch'
                end
            end
        end
    end
    -- Advanced-target helpers intentionally reject illusions; use legal explicit guards here.
    for _, enemy in pairs(heroes) do
        if enemy:IsIllusion() and not enemy:IsInvulnerable() and not enemy:IsMagicImmune()
            and J.IsInRange(bot, enemy, CastRange(Glimpse))
            and not enemy:HasModifier('modifier_item_sphere_target')
            and not enemy:HasModifier('modifier_item_lotus_orb_active')
            and not enemy:HasModifier('modifier_antimage_counterspell')
            and not enemy:HasModifier('modifier_antimage_counterspell_ally')
            and (enemy:GetAttackTarget() == bot or (bot:WasRecentlyDamagedByAnyHero(2)
                and J.IsInRange(bot, enemy, 600))) then return BOT_ACTION_DESIRE_HIGH, enemy, 'illusion' end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function Bound(point, range)
    local offset = point - bot:GetLocation()
    return offset:Length2D() > range and bot:GetLocation() + offset:Normalized() * range or point
end

local function AreaLocation(ability, unit, delay, range)
    if not Enemy(unit) then return nil end
    local point = Bound(J.GetCorrectLoc(unit, delay), range)
    if (J.GetCorrectLoc(unit, delay) - point):Length2D() <= ability:GetSpecialValueInt('radius') then return point end
    return nil
end

local function AreaCount(ability, point, delay)
    local count = 0
    for _, enemy in pairs(Heroes()) do
        if Enemy(enemy) and (J.GetCorrectLoc(enemy, delay) - point):Length2D() <= ability:GetSpecialValueInt('radius') then count = count + 1 end
    end
    return count
end

function X.ConsiderStaticStorm()
    if not J.CanCastAbility(StaticStorm) then return BOT_ACTION_DESIRE_NONE end
    local delay = StaticStorm:GetCastPoint()
    for _, enemy in pairs(Heroes()) do
        local point = AreaLocation(StaticStorm, enemy, delay, CastRange(StaticStorm))
        if point ~= nil and not enemy:IsSilenced() and (enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy)) then
            return BOT_ACTION_DESIRE_HIGH, point, 'interrupt'
        end
    end
    if J.IsInTeamFight(bot, 1200) then
        for _, enemy in pairs(Heroes()) do
            local point = AreaLocation(StaticStorm, enemy, delay, CastRange(StaticStorm))
            if point ~= nil and AreaCount(StaticStorm, point, delay) >= 2 then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and not J.CannotBeKilled(bot, target)
        and (J.IsDisabled(target) or J.IsCore(target) or bot:HasScepter()) then
        local point = AreaLocation(StaticStorm, target, delay, CastRange(StaticStorm))
        if point ~= nil then return BOT_ACTION_DESIRE_HIGH, point end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderKineticField()
    if not J.CanCastAbility(KineticField) then return BOT_ACTION_DESIRE_NONE end
    local delay = KineticField:GetCastPoint() + KineticField:GetSpecialValueFloat('formation_time')
    if J.IsInTeamFight(bot, 1200) then
        for _, enemy in pairs(Heroes()) do
            local point = AreaLocation(KineticField, enemy, delay, CastRange(KineticField))
            if point ~= nil and AreaCount(KineticField, point, delay) >= 2 then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) then
        local point = AreaLocation(KineticField, target, delay, CastRange(KineticField))
        if point ~= nil then return BOT_ACTION_DESIRE_HIGH, point end
    end
    for _, enemy in pairs(Heroes()) do
        if Enemy(enemy) and J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
            and J.IsChasingTarget(enemy, bot) and not J.IsDisabled(enemy) then
            local point = AreaLocation(KineticField, enemy, delay, CastRange(KineticField))
            if point ~= nil then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function QueueStorm(point)
    local follow = J.CanCastAbility(KineticField)
        and bot:GetMana() >= StaticStorm:GetManaCost() + KineticField:GetManaCost()
        and GetUnitToLocationDistance(bot, point) <= CastRange(KineticField)
        and AreaCount(KineticField, point, StaticStorm:GetCastPoint() + KineticField:GetCastPoint()
            + KineticField:GetSpecialValueFloat('formation_time')) >= 1
    bot:Action_UseAbilityOnLocation(StaticStorm, point)
    if follow then bot:ActionQueue_UseAbilityOnLocation(KineticField, point) end
end

function X.ConsiderThunderStrike()
    if not J.CanCastAbility(ThunderStrike) then return BOT_ACTION_DESIRE_NONE end
    local count = ThunderStrike:GetSpecialValueInt('strikes')
    local base = ThunderStrike:GetSpecialValueInt('strike_damage')
    local bonus = ThunderStrike:GetSpecialValueInt('strike_damage_bonus')
    local damage = base * count + bonus * count * (count - 1) / 2
    local delay = ThunderStrike:GetCastPoint() + ThunderStrike:GetSpecialValueFloat('strike_interval') * (count - 1)
    for _, enemy in pairs(Heroes()) do
        if Targeted(enemy, ThunderStrike) and not enemy:HasModifier('modifier_disruptor_thunder_strike')
            and not J.CannotBeKilled(bot, enemy) and J.WillKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL, delay) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    local target = J.GetProperTarget(bot)
    if Targeted(target, ThunderStrike) and not target:HasModifier('modifier_disruptor_thunder_strike')
        and (J.IsGoingOnSomeone(bot) or (J.IsLaning(bot) and J.IsAllowedToSpam(bot, ThunderStrike:GetManaCost()))
            or (J.IsRetreating(bot) and J.IsChasingTarget(target, bot))) then return BOT_ACTION_DESIRE_HIGH, target end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target)) or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and J.IsValid(target) and not target:IsInvulnerable() and not target:IsMagicImmune()
        and J.IsInRange(bot, target, CastRange(ThunderStrike)) and J.IsAttacking(bot)
        and not target:HasModifier('modifier_disruptor_thunder_strike')
        and J.GetHP(bot) > 0.5 then return BOT_ACTION_DESIRE_HIGH, target end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot, ThunderStrike:GetManaCost()) then
        local creeps = bot:GetNearbyLaneCreeps(math.min(CastRange(ThunderStrike), 1600), true)
        if J.IsFarming(bot) then
            for _, creep in pairs(bot:GetNearbyNeutralCreeps(math.min(CastRange(ThunderStrike), 1600))) do table.insert(creeps, creep) end
        end
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and not creep:IsMagicImmune() and not creep:IsInvulnerable()
                and J.IsInRange(bot, creep, CastRange(ThunderStrike))
                and not creep:HasModifier('modifier_disruptor_thunder_strike')
                and creep:GetHealth() > creep:GetActualIncomingDamage(base, DAMAGE_TYPE_MAGICAL) then
                local hits = 0
                for _, other in pairs(creeps) do
                    if J.IsValid(other) and not other:IsMagicImmune() and not other:IsInvulnerable()
                        and J.IsInRange(creep, other, ThunderStrike:GetSpecialValueInt('radius')) then hits = hits + 1 end
                end
                if hits >= 3 then return BOT_ACTION_DESIRE_HIGH, creep end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderKineticFence()
    -- Current Shard is a vector wall. No verified bot action accepts both endpoints.
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderStolenSpell(ability)
    Refresh()
    local name = ability:GetName()
    if name == 'disruptor_thunder_strike' then ThunderStrike = ability
    elseif name == 'disruptor_glimpse' then Glimpse = ability
    elseif name == 'disruptor_kinetic_field' then KineticField = ability
    elseif name == 'disruptor_kinetic_fence' then KineticFence = ability
    elseif name == 'disruptor_static_storm' then StaticStorm = ability
    else return nil end
    X.ObserveGlimpseHistory()
    if J.CanNotUseAbility(bot) then return false end
    local desire, target
    if name == 'disruptor_glimpse' then
        desire, target = X.ConsiderGlimpse()
        if desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
    elseif name == 'disruptor_static_storm' then
        desire, target = X.ConsiderStaticStorm()
        if desire > 0 then QueueStorm(target); return true end
    elseif name == 'disruptor_kinetic_field' then
        desire, target = X.ConsiderKineticField()
        if desire > 0 then bot:Action_UseAbilityOnLocation(ability, target); return true end
    elseif name == 'disruptor_thunder_strike' then
        desire, target = X.ConsiderThunderStrike()
        if desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
    end
    return false
end
return X
