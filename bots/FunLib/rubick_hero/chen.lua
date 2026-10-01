local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Penitence, HolyPersuasion, DivineFavor, Zealot, HandOfGod

function X.ConsiderStolenSpell(ability)
    local name = ability:GetName()
    if name ~= 'chen_penitence' and name ~= 'chen_holy_persuasion'
        and name ~= 'chen_divine_favor' and name ~= 'chen_hand_of_god' then return nil end
    bot = GetBot()
    if J.CanNotUseAbility(bot) then return false end
    local desire, target
    if name == 'chen_hand_of_god' then
        HandOfGod = ability
        if X.ConsiderHandOfGod() > 0 then bot:Action_UseAbility(ability); return true end
    elseif name == 'chen_penitence' then
        Penitence = ability
        desire, target = X.ConsiderPenitence()
    elseif name == 'chen_holy_persuasion' then
        HolyPersuasion = ability
        desire, target = X.ConsiderHolyPersuasion()
    else
        DivineFavor = ability
        desire, target = X.ConsiderDivineFavor()
    end
    if desire ~= nil and desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
    return false
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function AllyHero(unit)
    -- Hand of God explicitly heals invulnerable and hidden allies; J.IsValidHero excludes them.
    return unit ~= nil and not unit:IsNull() and unit:IsAlive() and unit:IsHero()
        and unit:GetTeam() == bot:GetTeam() and not unit:IsIllusion()
end

local function HealBlocked(unit)
    return unit:HasModifier('modifier_ice_blast') or unit:HasModifier('modifier_doom_bringer_doom')
end

local function OwnedUnits(persuadedOnly)
    local units = {}
    for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if unit ~= nil and not unit:IsNull() and unit:IsAlive() and not unit:IsHero()
            and unit:GetPlayerID() == bot:GetPlayerID()
            and (unit:HasModifier('modifier_chen_holy_persuasion')
                or not persuadedOnly and string.find(unit:GetUnitName(), 'npc_dota_chen_zealot', 1, true)) then
            units[#units + 1] = unit
        end
    end
    return units
end

local function PenitenceTarget(unit)
    return J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit)
        and J.CanCastOnTargetAdvanced(unit) and not J.IsSuspiciousIllusion(unit)
        and J.IsInRange(bot, unit, CastRange(Penitence))
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
        and not unit:HasModifier('modifier_abaddon_borrowed_time')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end

function X.ConsiderPenitence()
    if not J.CanCastAbility(Penitence) then return BOT_ACTION_DESIRE_NONE, nil end
    local enemies = J.GetNearbyHeroes(bot, math.min(CastRange(Penitence), 1600), true, BOT_MODE_NONE)
    for _, enemy in ipairs(enemies) do
        if PenitenceTarget(enemy) and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_oracle_false_promise_timer')
            and J.CanKillTarget(enemy, Penitence:GetSpecialValueInt('damage'), DAMAGE_TYPE_PURE) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    for _, enemy in ipairs(enemies) do
        if PenitenceTarget(enemy) and not enemy:HasModifier('modifier_chen_penitence') then
            if J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            for _, ally in ipairs(J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_NONE)) do
                if J.IsValidHero(ally) and J.IsRetreating(ally) and J.IsChasingTarget(enemy, ally) then
                    return BOT_ACTION_DESIRE_HIGH, enemy
                end
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if PenitenceTarget(target) and not target:HasModifier('modifier_chen_penitence') then
        if J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200) then
            return BOT_ACTION_DESIRE_HIGH, target
        end
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target)
            or J.IsDoingTormentor(bot) and J.IsTormentor(target)) and J.IsAttacking(bot) then
            return BOT_ACTION_DESIRE_HIGH, target
        end
    end
    if J.IsLaning(bot) and bot:GetMana() / bot:GetMaxMana() > 0.45 then
        for _, enemy in ipairs(enemies) do
            if PenitenceTarget(enemy) and not enemy:HasModifier('modifier_chen_penitence') then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

local creepScores = {
    npc_dota_neutral_harpy_storm = 9,
    npc_dota_neutral_centaur_khan = 9,
    npc_dota_neutral_dark_troll_warlord = 9,
    npc_dota_neutral_alpha_wolf = 8,
    npc_dota_neutral_satyr_hellcaller = 8,
    npc_dota_neutral_polar_furbolg_ursa_warrior = 8,
    npc_dota_neutral_enraged_wildkin = 7,
    npc_dota_neutral_warpine_raider = 7,
    npc_dota_neutral_satyr_trickster = 6,
    npc_dota_neutral_mud_golem = 6,
    npc_dota_neutral_black_dragon = 12,
    npc_dota_neutral_granite_golem = 12,
    npc_dota_neutral_big_thunder_lizard = 12,
}

function X.ConsiderHolyPersuasion()
    if not J.CanCastAbility(HolyPersuasion) or J.IsRetreating(bot) then return BOT_ACTION_DESIRE_NONE, nil end
    local owned = OwnedUnits(true)
    if #owned >= HolyPersuasion:GetSpecialValueInt('max_units') then return BOT_ACTION_DESIRE_NONE, nil end
    local ancients = 0
    for _, unit in ipairs(owned) do if unit:IsAncientCreep() then ancients = ancients + 1 end end
    local ultimate = bot:GetAbilityByName('chen_hand_of_god')
    local ancientLimit = bot:HasShard() and ultimate ~= nil and ultimate:GetLevel() or 0
    local range = CastRange(HolyPersuasion)
    local candidates = bot:GetNearbyNeutralCreeps(math.min(range, 1600))
    -- Enemy summons and dominated creeps are valid recruitment targets too.
    for _, unit in ipairs(bot:GetNearbyCreeps(math.min(range, 1600), true)) do candidates[#candidates + 1] = unit end
    local best, bestScore = nil, -1
    for _, unit in ipairs(candidates) do
        if J.IsValid(unit) and unit:IsCreep() and not unit:IsIllusion()
            and unit:GetTeam() ~= bot:GetTeam() and J.IsInRange(bot, unit, range)
            and unit:GetLevel() <= HolyPersuasion:GetSpecialValueInt('level_req')
            and (not unit:IsAncientCreep() or ancients < ancientLimit)
            and J.CanCastOnTargetAdvanced(unit)
            and not unit:HasModifier('modifier_antimage_counterspell')
            and not unit:HasModifier('modifier_antimage_counterspell_ally') then
            local score = creepScores[unit:GetUnitName()] or unit:GetLevel()
            if score > bestScore then best, bestScore = unit, score end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDivineFavor()
    if not J.CanCastAbility(DivineFavor) then return BOT_ACTION_DESIRE_NONE, nil end
    local range = CastRange(DivineFavor)
    local best, bestScore = nil, 0
    local allies = J.GetNearbyHeroes(bot, math.min(range, 1600), false, BOT_MODE_NONE)
    allies[#allies + 1] = bot
    for _, ally in ipairs(allies) do
        if AllyHero(ally) and not ally:IsInvulnerable() and not ally:IsMagicImmune()
            and J.IsInRange(bot, ally, range)
            and not ally:HasModifier('modifier_chen_divine_favor_armor_buff') then
            local score = 0
            if ally:WasRecentlyDamagedByAnyHero(3) then score = 2 + (1 - J.GetHP(ally)) * 4 end
            if J.IsGoingOnSomeone(ally) or J.IsInTeamFight(ally, 1200) then score = score + 1 end
            if ally == bot then
                for _, creep in ipairs(OwnedUnits(false)) do
                    if J.IsInRange(bot, creep, 1200) and (creep:WasRecentlyDamagedByAnyHero(3)
                        or J.IsPushing(bot) or J.IsInTeamFight(bot, 1200)) then score = score + 1 end
                end
            end
            if score > bestScore then best, bestScore = ally, score end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderHandOfGod()
    if not J.CanCastAbility(HandOfGod) then return BOT_ACTION_DESIRE_NONE end
    local heal = HandOfGod:GetSpecialValueInt('heal_amount')
    local wounded = 0
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if AllyHero(ally) then
            if HandOfGod:GetSpecialValueInt('does_purge') > 0
                and not ally:HasModifier('modifier_doom_bringer_doom')
                and (ally:IsStunned() or ally:IsHexed() or ally:IsRooted() or ally:IsNightmared())
                and ally:WasRecentlyDamagedByAnyHero(3) then return BOT_ACTION_DESIRE_HIGH end
            if not HealBlocked(ally) then
                local missing = ally:GetMaxHealth() - ally:GetHealth()
                if missing >= heal * 0.75 and ally:WasRecentlyDamagedByAnyHero(4) then
                    wounded = wounded + 1
                    if J.GetHP(ally) < 0.55 then return BOT_ACTION_DESIRE_HIGH end
                end
            end
        end
    end
    if wounded >= 2 then return BOT_ACTION_DESIRE_HIGH end
    local endangeredArmy = 0
    for _, unit in ipairs(OwnedUnits(true)) do
        if unit:GetLevel() >= 5 and not HealBlocked(unit) and J.GetHP(unit) < 0.4
            and unit:GetMaxHealth() - unit:GetHealth() >= heal
            and unit:WasRecentlyDamagedByAnyHero(3) then endangeredArmy = endangeredArmy + 1 end
    end
    if endangeredArmy >= 2 then return BOT_ACTION_DESIRE_HIGH end
    if bot:HasScepter() then
        local threatened = 0
        for _, ally in ipairs(J.GetNearbyHeroes(bot, HandOfGod:GetSpecialValueInt('debuff_immune_radius'), false, BOT_MODE_NONE)) do
            if AllyHero(ally) and not ally:IsMagicImmune() and ally:WasRecentlyDamagedByAnyHero(2) then
                threatened = threatened + 1
            end
        end
        if threatened >= 2 then return BOT_ACTION_DESIRE_HIGH end
    end
    return BOT_ACTION_DESIRE_NONE
end

return X
