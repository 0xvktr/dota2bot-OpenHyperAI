local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Stomp, Astral, Move, Return, Splitter
local spirit, touched, observedAt, returning = nil, {}, 0, false

local function Refresh()
    Stomp = bot:GetAbilityByName('elder_titan_echo_stomp')
    Astral = bot:GetAbilityByName('elder_titan_ancestral_spirit')
    Move = bot:GetAbilityByName('elder_titan_move_spirit')
    Return = bot:GetAbilityByName('elder_titan_return_spirit')
    Splitter = bot:GetAbilityByName('elder_titan_earth_splitter')
end

local function OwnedSpirit(unit)
    return unit ~= nil and not unit:IsNull() and unit:IsAlive()
        and unit:GetTeam() == bot:GetTeam() and unit:GetPlayerID() == bot:GetPlayerID()
        and string.find(unit:GetUnitName(), 'elder_titan_ancestral_spirit', 1, true) ~= nil
end

local function ObserveSpirit(unit)
    if not OwnedSpirit(unit) then return false end
    if spirit ~= unit then spirit, touched, observedAt, returning = unit, {}, DotaTime(), false end
    return true
end

local function FindSpirit()
    if not OwnedSpirit(spirit) then spirit, touched = nil, {} end
    -- Linked handles must actually exist; stealing Stomp does not imply a spirit.
    if Astral == nil or Return == nil or Return:IsHidden() then spirit, touched = nil, {}; return end
    for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if ObserveSpirit(unit) then break end
    end
end

local function Enemy(unit, piercing)
    return J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit)
        and not unit:IsInvulnerable() and (piercing or J.CanCastOnNonMagicImmune(unit))
end

local function Sleeping(unit)
    return unit:HasModifier('modifier_elder_titan_echo_stomp')
end

local function Range(ability)
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

local function Bound(point, range)
    local offset = point - bot:GetLocation()
    return offset:Length2D() > range and bot:GetLocation() + offset:Normalized() * range or point
end

local function PhysicalDamage(unit, damage)
    if J.IsInEtherealForm(unit) or unit:HasModifier('modifier_omniknight_guardian_angel')
        or unit:HasModifier('modifier_winter_wyvern_cold_embrace') then return 0 end
    return unit:GetActualIncomingDamage(damage, DAMAGE_TYPE_PHYSICAL)
end

local function StompHits(unit)
    local point = J.GetCorrectLoc(unit, Stomp:GetCastPoint() + Stomp:GetChannelTime())
    local physical = GetUnitToLocationDistance(bot, point) <= Stomp:GetSpecialValueInt('radius')
    -- A copied spirit needs its own actual Stomp handle before contributing damage/control.
    local echo = spirit ~= nil and spirit:GetAbilityByName('elder_titan_echo_stomp_spirit') or nil
    local magical = echo ~= nil and echo:IsTrained()
        and GetUnitToLocationDistance(spirit, point) <= echo:GetSpecialValueInt('radius')
    return physical, magical, echo
end

function X.ConsiderStomp()
    if not J.CanCastAbility(Stomp) then return BOT_ACTION_DESIRE_NONE end
    -- Shard alt-cast swaps location; do not issue an unverified teleport command.
    if bot:HasShard() and Stomp:GetAutoCastState() then return BOT_ACTION_DESIRE_NONE end
    local count = 0
    local target = J.GetProperTarget(bot)
    local heroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    if spirit ~= nil then
        local seen = {};for _, enemy in pairs(heroes) do seen[enemy] = true end
        for _, enemy in pairs(J.GetNearbyHeroes(spirit, 1600, true, BOT_MODE_NONE)) do
            if not seen[enemy] then heroes[#heroes+1] = enemy;seen[enemy] = true end
        end
    end
    for _, enemy in pairs(heroes) do
        if Enemy(enemy, false) and not Sleeping(enemy) then
            local physical, magical, echo = StompHits(enemy)
            if physical or magical then
                count = count + 1
                local damage = physical and PhysicalDamage(enemy, Stomp:GetSpecialValueInt('stomp_damage')) or 0
                if magical then damage = damage + enemy:GetActualIncomingDamage(
                    echo:GetSpecialValueInt('stomp_damage'), DAMAGE_TYPE_MAGICAL) end
                local delay = Stomp:GetCastPoint() + Stomp:GetChannelTime()
                local interrupt = enemy:IsChanneling() and (not enemy:HasModifier('modifier_teleporting')
                    or J.GetModifierTime(enemy, 'modifier_teleporting') >= delay)
                if interrupt or (not J.CannotBeKilled(bot, enemy)
                    and damage >= enemy:GetHealth() + enemy:GetHealthRegen() * delay)
                    or (J.IsGoingOnSomeone(bot) and enemy == target)
                    or (J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot)) then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end
    if count >= 2 and J.IsInTeamFight(bot, 1200) then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

local function SplitterHit(unit, point, delay)
    local offset = J.GetCorrectLoc(unit, delay) - bot:GetLocation()
    local direction = (point - bot:GetLocation()):Normalized()
    local along = offset.x * direction.x + offset.y * direction.y
    return along >= 0 and along <= Splitter:GetSpecialValueInt('crack_distance')
        and math.abs(offset.x * direction.y - offset.y * direction.x)
            <= Splitter:GetSpecialValueInt('crack_width') / 2
end

function X.ConsiderSplitter()
    if not J.CanCastAbility(Splitter) then return BOT_ACTION_DESIRE_NONE end
    local delay = Splitter:GetCastPoint() + Splitter:GetSpecialValueFloat('crack_time')
    local heroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    for _, enemy in pairs(heroes) do
        if Enemy(enemy, true) then
            local point = Bound(J.GetCorrectLoc(enemy, delay), Range(Splitter))
            if GetUnitToLocationDistance(bot, point) > 0 and SplitterHit(enemy, point, delay) then
                local half = enemy:GetMaxHealth() * Splitter:GetSpecialValueInt('damage_pct') / 200
                local damage = PhysicalDamage(enemy, half)
                    + enemy:GetActualIncomingDamage(half, DAMAGE_TYPE_MAGICAL)
                if not J.CannotBeKilled(bot, enemy) and damage >= enemy:GetHealth() + enemy:GetHealthRegen() * delay then
                    return BOT_ACTION_DESIRE_HIGH, point
                end
                for _, modifier in ipairs({'modifier_elder_titan_echo_stomp',
                    'modifier_faceless_void_chronosphere_freeze', 'modifier_enigma_black_hole_pull'}) do
                    if enemy:HasModifier(modifier) and J.GetModifierTime(enemy, modifier) >= delay then
                        return BOT_ACTION_DESIRE_HIGH, point
                    end
                end
                local count = 0
                for _, other in pairs(heroes) do
                    if Enemy(other, true) and SplitterHit(other, point, delay) then count = count + 1 end
                end
                if count >= 2 and J.IsInTeamFight(bot, 1200) then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderAstral()
    if not J.CanCastAbility(Astral) or spirit ~= nil then return BOT_ACTION_DESIRE_NONE end
    local reserve = Stomp ~= nil and Stomp:IsTrained() and Stomp:GetManaCost() or 0
    if Splitter ~= nil and Splitter:IsTrained() then reserve = reserve + Splitter:GetManaCost() end
    local target = J.GetProperTarget(bot)
    if Enemy(target, true) and not Sleeping(target)
        and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then
        local point = Bound(J.GetCorrectLoc(target, Astral:GetCastPoint()), Range(Astral))
        if GetUnitToLocationDistance(target, point) <= Astral:GetSpecialValueInt('radius') then
            return BOT_ACTION_DESIRE_HIGH, point
        end
    end
    if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        if bot:GetMana() < Astral:GetManaCost() + reserve or not J.IsAllowedToSpam(bot, Astral:GetManaCost()) then
            return BOT_ACTION_DESIRE_NONE
        end
        local creeps = bot:GetNearbyLaneCreeps(1600, true)
        if J.IsFarming(bot) then
            for _, creep in pairs(bot:GetNearbyNeutralCreeps(1600)) do table.insert(creeps, creep) end
        end
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and not creep:IsInvulnerable() then
                local point, count = Bound(creep:GetLocation(), Range(Astral)), 0
                for _, other in pairs(creeps) do
                    if J.IsValid(other) and GetUnitToLocationDistance(other, point) <= Astral:GetSpecialValueInt('radius') then count = count + 1 end
                end
                if count >= 3 then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSpiritControl()
    if spirit == nil or Astral == nil or returning or spirit:IsChanneling()
        or spirit:IsUsingAbility() or spirit:IsCastingAbility() then return BOT_ACTION_DESIRE_NONE end
    local heroes = J.GetNearbyHeroes(spirit, 1600, true, BOT_MODE_NONE)
    local radius = Astral:GetSpecialValueInt('radius')
    local useful, nextTarget = next(touched) ~= nil, nil
    for _, enemy in pairs(heroes) do
        if Enemy(enemy, true) then
            if GetUnitToUnitDistance(spirit, enemy) <= radius then touched[enemy] = true end
            if touched[enemy] then useful = true end
            if not Sleeping(enemy) and not touched[enemy] and (nextTarget == nil
                or GetUnitToUnitDistance(spirit, enemy) < GetUnitToUnitDistance(spirit, nextTarget)) then nextTarget = enemy end
        end
    end
    if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        local creeps = spirit:GetNearbyLaneCreeps(1600, true)
        if J.IsFarming(bot) then
            for _, creep in pairs(spirit:GetNearbyNeutralCreeps(1600)) do table.insert(creeps, creep) end
        end
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and not creep:IsInvulnerable() then
                if GetUnitToUnitDistance(spirit, creep) <= radius then touched[creep] = true end
                if touched[creep] then useful = true end
                if nextTarget == nil and not touched[creep] then nextTarget = creep end
            end
        end
    end
    -- Return accumulated damage/movement before fighting; leave sleep setup intact.
    if J.CanCastAbility(Return) and ((useful and nextTarget == nil)
        or (useful and J.IsRetreating(bot)) or DotaTime() - observedAt >= Astral:GetSpecialValueFloat('spirit_duration') - 1) then
        return BOT_ACTION_DESIRE_HIGH, nil, Return
    end
    if nextTarget ~= nil and J.CanCastAbility(Move) then
        return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(nextTarget,
            GetUnitToUnitDistance(spirit, nextTarget) / math.max(spirit:GetCurrentMovementSpeed(), 1)), Move
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.HandleAstralSpiritMinion(unit)
    Refresh()
    if not ObserveSpirit(unit) then return false end
    -- Do not let generic minion orders overwrite synchronized Stomp, or cancel a hero channel.
    return true
end

function X.UseAstralSpirit()
    Refresh(); FindSpirit()
    if J.CanNotUseAbility(bot) or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() then return false end
    if X.ConsiderStomp() > 0 or X.ConsiderSplitter() > 0 then return false end
    local desire, point, ability = X.ConsiderSpiritControl()
    if desire <= 0 then return false end
    if point ~= nil then bot:Action_UseAbilityOnLocation(ability, point) else bot:Action_UseAbility(ability); returning = true end
    return true
end

local decisions = {
    elder_titan_echo_stomp = {'ConsiderStomp', 'none'},
    elder_titan_ancestral_spirit = {'ConsiderAstral', 'point'},
    elder_titan_earth_splitter = {'ConsiderSplitter', 'point'},
    elder_titan_move_spirit = {'ConsiderSpiritControl', 'control'},
    elder_titan_return_spirit = {'ConsiderSpiritControl', 'control'},
}

function X.ConsiderStolenSpell(ability)
    local entry = decisions[ability:GetName()]
    if entry == nil then
        if ability:GetName() == 'elder_titan_natural_order' or ability:GetName() == 'elder_titan_momentum' then return false end
        return nil
    end
    Refresh()
    local name = ability:GetName()
    if name == 'elder_titan_echo_stomp' then Stomp = ability
    elseif name == 'elder_titan_ancestral_spirit' then Astral = ability
    elseif name == 'elder_titan_earth_splitter' then Splitter = ability
    elseif name == 'elder_titan_move_spirit' then Move = ability
    else Return = ability end
    FindSpirit()
    if J.CanNotUseAbility(bot) or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() then return false end
    local desire, point, control = X[entry[1]]()
    if desire <= 0 then return false end
    if entry[2] == 'control' then
        if control ~= ability then return false end
        if point ~= nil then bot:Action_UseAbilityOnLocation(ability, point) else bot:Action_UseAbility(ability); returning = true end
    elseif entry[2] == 'none' then bot:Action_UseAbility(ability)
    else bot:Action_UseAbilityOnLocation(ability, point) end
    return true
end

return X
