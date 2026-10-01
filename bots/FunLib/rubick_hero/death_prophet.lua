local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Swarm = bot:GetAbilityByName('death_prophet_carrion_swarm')
local Silence = bot:GetAbilityByName('death_prophet_silence')
local Siphon = bot:GetAbilityByName('death_prophet_spirit_siphon')
local Exorcism = bot:GetAbilityByName('death_prophet_exorcism')

local function Refresh()
    Swarm = bot:GetAbilityByName('death_prophet_carrion_swarm')
    Silence = bot:GetAbilityByName('death_prophet_silence')
    Siphon = bot:GetAbilityByName('death_prophet_spirit_siphon')
    Exorcism = bot:GetAbilityByName('death_prophet_exorcism')
end

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

local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit)
end

local function Bound(point, range)
    local offset = point - bot:GetLocation()
    return offset:Length2D() > range and bot:GetLocation() + offset:Normalized() * range or point
end

local function SwarmDelay(unit)
    return Swarm:GetCastPoint() + GetUnitToUnitDistance(bot, unit) / Swarm:GetSpecialValueInt('speed')
end

local function SwarmHit(unit, point)
    if not J.IsValid(unit) or unit:IsInvulnerable() or unit:IsMagicImmune() then return false end
    local offset = J.GetCorrectLoc(unit, SwarmDelay(unit)) - bot:GetLocation()
    local direction = (point - bot:GetLocation()):Normalized()
    local along = offset.x * direction.x + offset.y * direction.y
    local length = Swarm:GetSpecialValueInt('range')
    if along < 0 or along > length then return false end
    local width = Swarm:GetSpecialValueInt('start_radius')
        + (Swarm:GetSpecialValueInt('end_radius') - Swarm:GetSpecialValueInt('start_radius')) * along / length
    return math.abs(offset.x * direction.y - offset.y * direction.x) <= width
end

function X.ConsiderSwarm()
    if not J.CanCastAbility(Swarm) then return BOT_ACTION_DESIRE_NONE end
    local heroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    for _, enemy in pairs(heroes) do
        if Enemy(enemy) and not J.CannotBeKilled(bot, enemy) then
            local point = Bound(J.GetCorrectLoc(enemy, SwarmDelay(enemy)), CastRange(Swarm))
            if SwarmHit(enemy, point) and J.WillKillTarget(enemy, Swarm:GetSpecialValueInt('damage'),
                DAMAGE_TYPE_MAGICAL, SwarmDelay(enemy)) then return BOT_ACTION_DESIRE_HIGH, point, 'lethal' end
        end
    end
    local target = J.GetProperTarget(bot)
    if Enemy(target) and (J.IsGoingOnSomeone(bot) or (J.IsRetreating(bot) and J.IsChasingTarget(target, bot))) then
        local point = Bound(J.GetCorrectLoc(target, SwarmDelay(target)), CastRange(Swarm))
        if SwarmHit(target, point) then return BOT_ACTION_DESIRE_HIGH, point end
    end
    if not J.IsAllowedToSpam(bot, Swarm:GetManaCost()) then return BOT_ACTION_DESIRE_NONE end
    if J.IsInTeamFight(bot, 1200) or J.IsLaning(bot) then
        for _, enemy in pairs(heroes) do
            if Enemy(enemy) then
                local point, count = Bound(J.GetCorrectLoc(enemy, SwarmDelay(enemy)), CastRange(Swarm)), 0
                for _, other in pairs(heroes) do if Enemy(other) and SwarmHit(other, point) then count = count + 1 end end
                if count >= 2 then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    local creeps = bot:GetNearbyLaneCreeps(1200, true)
    if J.IsFarming(bot) then
        for _, creep in pairs(bot:GetNearbyNeutralCreeps(1200)) do table.insert(creeps, creep) end
    end
    if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) then
                local point, hits, kills = Bound(J.GetCorrectLoc(creep, SwarmDelay(creep)), CastRange(Swarm)), 0, 0
                for _, other in pairs(creeps) do
                    if SwarmHit(other, point) then
                        hits = hits + 1
                        if J.WillKillTarget(other, Swarm:GetSpecialValueInt('damage'), DAMAGE_TYPE_MAGICAL,
                            SwarmDelay(other)) then kills = kills + 1 end
                    end
                end
                if (J.IsLaning(bot) and (kills >= 2 or (kills >= 1
                    and string.find(creep:GetUnitName(), 'ranged') ~= nil
                    and SwarmHit(creep, point) and J.WillKillTarget(creep, Swarm:GetSpecialValueInt('damage'),
                        DAMAGE_TYPE_MAGICAL, SwarmDelay(creep)))))
                    or (not J.IsLaning(bot) and hits >= 3) then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target)) or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and J.IsAttacking(bot) then
        local point = Bound(target:GetLocation(), CastRange(Swarm))
        if SwarmHit(target, point) then return BOT_ACTION_DESIRE_HIGH, point end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function SilenceLocation(unit)
    if not Enemy(unit) or unit:IsSilenced() then return nil end
    local delay = Silence:GetCastPoint() + math.min(GetUnitToUnitDistance(bot, unit), CastRange(Silence))
        / Silence:GetSpecialValueInt('projectile_speed')
    local predicted = J.GetCorrectLoc(unit, delay)
    local point = Bound(predicted, CastRange(Silence))
    if (predicted - point):Length2D() <= Silence:GetSpecialValueInt('radius') then return point, delay end
    return nil
end

function X.ConsiderSilence()
    if not J.CanCastAbility(Silence) then return BOT_ACTION_DESIRE_NONE end
    local heroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    for _, enemy in pairs(heroes) do
        local point = SilenceLocation(enemy)
        if point ~= nil and (enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy)) then
            return BOT_ACTION_DESIRE_HIGH, point, 'interrupt'
        end
    end
    if J.IsInTeamFight(bot, 1200) then
        for _, enemy in pairs(heroes) do
            local point, delay = SilenceLocation(enemy)
            if point ~= nil then
                local count = 0
                for _, other in pairs(heroes) do
                    if Enemy(other) and not other:IsSilenced()
                        and (J.GetCorrectLoc(other, delay) - point):Length2D() <= Silence:GetSpecialValueInt('radius') then count = count + 1 end
                end
                if count >= 2 then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and not J.IsDisabled(target) then
        local point = SilenceLocation(target)
        if point ~= nil then return BOT_ACTION_DESIRE_HIGH, point end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _, enemy in pairs(heroes) do
            if Enemy(enemy) and not J.IsDisabled(enemy) and J.IsChasingTarget(enemy, bot) then
                local point = SilenceLocation(enemy)
                if point ~= nil then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function SiphonTarget(unit)
    return J.IsValid(unit) and unit:GetTeam() ~= bot:GetTeam() and not unit:IsInvulnerable()
        and not unit:IsMagicImmune() and not J.IsSuspiciousIllusion(unit)
        and J.IsInRange(bot, unit, CastRange(Siphon)) and J.CanCastOnTargetAdvanced(unit)
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
        and not unit:HasModifier('modifier_death_prophet_spirit_siphon_slow')
        and not J.CannotBeKilled(bot, unit)
        and unit:GetHealth() > unit:GetActualIncomingDamage(Siphon:GetSpecialValueInt('damage'), DAMAGE_TYPE_MAGICAL)
end

function X.ConsiderSiphon()
    if not J.CanCastAbility(Siphon) then return BOT_ACTION_DESIRE_NONE end
    local healing = J.GetHP(bot) < 0.65 and not bot:HasModifier('modifier_ice_blast')
    local urgent = healing and (bot:WasRecentlyDamagedByAnyHero(2) or J.GetHP(bot) < 0.4)
    local target = J.GetProperTarget(bot)
    local heroes = J.GetNearbyHeroes(bot, math.min(CastRange(Siphon), 1600), true, BOT_MODE_NONE)
    if urgent or J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200) or bot:HasModifier('modifier_death_prophet_exorcism') then
        local best, score = nil, -1
        for _, enemy in pairs(heroes) do
            if SiphonTarget(enemy) then
                local distance = GetUnitToUnitDistance(bot, enemy)
                local value = enemy:GetHealth() - distance + (enemy == target and 500 or 0)
                if value > score then best, score = enemy, value end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best, urgent end
    end
    if healing and (urgent or J.IsLaning(bot) or J.IsFarming(bot)) then
        local units = bot:GetNearbyLaneCreeps(math.min(CastRange(Siphon), 1600), true)
        for _, creep in pairs(bot:GetNearbyNeutralCreeps(math.min(CastRange(Siphon), 1600))) do table.insert(units, creep) end
        local best, health = nil, 0
        for _, creep in pairs(units) do
            if SiphonTarget(creep) and creep:GetHealth() > health then best, health = creep, creep:GetHealth() end
        end
        if best ~= nil and (urgent or Siphon:GetCurrentCharges() > 1) then return BOT_ACTION_DESIRE_HIGH, best, urgent end
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target)) or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and J.IsAttacking(bot) and SiphonTarget(target) and (healing or Siphon:GetCurrentCharges() > 1) then
        return BOT_ACTION_DESIRE_HIGH, target, urgent
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderExorcism()
    if not J.CanCastAbility(Exorcism) or bot:HasModifier('modifier_death_prophet_exorcism')
        or J.GetHP(bot) < 0.35 then return BOT_ACTION_DESIRE_NONE end
    local radius = Exorcism:GetSpecialValueInt('radius')
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnMagicImmune(target)
        and J.CanBeAttacked(target) and J.IsInRange(bot, target, radius)
        and not J.CannotBeKilled(bot, target) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsInTeamFight(bot, 1200) then
        local count = 0
        for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
            if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy) and J.CanBeAttacked(enemy) then count = count + 1 end
        end
        if count >= 2 then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsPushing(bot) and J.IsValidBuilding(target) and J.CanBeAttacked(target)
        and J.IsInRange(bot, target, radius) and J.GetHP(bot) > 0.45
        and target:GetHealth() > bot:GetAttackDamage() * 2
        and not target:HasModifier('modifier_fountain_glyph')
        and not target:HasModifier('modifier_backdoor_protection')
        and not target:HasModifier('modifier_backdoor_protection_active')
        and #bot:GetNearbyLaneCreeps(1000, false) > 0 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsDoingRoshan(bot) and J.IsRoshan(target) and J.CanBeAttacked(target)
        and J.IsAttacking(bot) and J.IsInRange(bot, target, radius) and J.GetHP(bot) > 0.6 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsDoingTormentor(bot) and J.IsTormentor(target) and J.CanBeAttacked(target)
        and J.IsAttacking(bot) and J.IsInRange(bot, target, radius) and J.GetHP(bot) > 0.65
        and #J.GetAlliesNearLoc(target:GetLocation(), 900) >= 3 then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderStolenSpell(ability)
    Refresh()
    local name = ability:GetName()
    if name == 'death_prophet_carrion_swarm' then Swarm = ability
    elseif name == 'death_prophet_silence' then Silence = ability
    elseif name == 'death_prophet_spirit_siphon' then Siphon = ability
    elseif name == 'death_prophet_exorcism' then Exorcism = ability
    else return nil end
    if J.CanNotUseAbility(bot) then return false end
    local desire, target
    if name == 'death_prophet_carrion_swarm' then
        desire, target = X.ConsiderSwarm()
        if desire > 0 then bot:Action_UseAbilityOnLocation(ability, target); return true end
    elseif name == 'death_prophet_silence' then
        desire, target = X.ConsiderSilence()
        if desire > 0 then bot:Action_UseAbilityOnLocation(ability, target); return true end
    elseif name == 'death_prophet_spirit_siphon' then
        desire, target = X.ConsiderSiphon()
        if desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
    elseif X.ConsiderExorcism() > 0 then bot:Action_UseAbility(ability); return true end
    return false
end
return X
