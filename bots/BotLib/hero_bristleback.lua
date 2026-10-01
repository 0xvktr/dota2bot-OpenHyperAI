local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: positions 3 (offlane) and 1 (carry); forced other roles use pos 3.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/bristleback')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Viscous Nasal Goo, [2] Quill Spray, [3] Bristleback, [6] Warpath.
-- D2PT shows only the first ten levels; later levels are a legal continuation.
local nAbilityBuildList, nTalentBuildList
if sRole == 'pos_1' then
    nAbilityBuildList = {2,3,2,3,2,6,2,3,3,1,6,1,1,1,6}
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={0,10}, -- +25 attack speed
        t15={10,0}, -- +8%/4% Bristleback back/side damage reduction
        t20={0,10}, -- +25 health regen
        t25={10,0}, -- +18 Warpath damage per stack
    })
else
    nAbilityBuildList = {2,3,2,1,2,6,2,3,3,3,6,1,1,1,6}
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={0,10}, -- +25 attack speed
        t15={10,0}, -- +8%/4% Bristleback back/side damage reduction
        t20={10,0}, -- +20 Quill Spray stack damage
        t25={10,0}, -- +18 Warpath damage per stack
    })
end
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_1' then
    X.sBuyList = {
        'item_tango', 'item_quelling_blade', 'item_branches', 'item_circlet', 'item_magic_stick', 'item_bracer',
        'item_power_treads', 'item_magic_wand', 'item_sphere', 'item_aghanims_shard', 'item_sange',
        'item_sange_and_yasha', 'item_black_king_bar', 'item_heart',
        -- Reviewed late continuation, not D2PT core.
        'item_ultimate_scepter_2', 'item_moon_shard',
    }
    X.sSellList = {
        'item_power_treads', 'item_quelling_blade',
        'item_sange_and_yasha', 'item_bracer',
        'item_black_king_bar', 'item_magic_wand',
    }
else
    X.sBuyList = {
        'item_double_branches', 'item_double_gauntlets', 'item_magic_stick', 'item_bracer', 'item_magic_wand',
        'item_soul_ring', 'item_power_treads', 'item_aghanims_shard', 'item_lotus_orb', 'item_sange',
        'item_sange_and_yasha', 'item_heart', 'item_black_king_bar',
        -- Reviewed late continuation, not D2PT core.
        'item_ultimate_scepter_2', 'item_moon_shard',
    }
    X.sSellList = {
        'item_power_treads', 'item_gauntlets',
        'item_lotus_orb', 'item_bracer',
        'item_heart', 'item_magic_wand',
        'item_black_king_bar', 'item_soul_ring',
    }
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Level 10 still spends an ability point in both roles, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

local ViscousNasalGoo = bot:GetAbilityByName('bristleback_viscous_nasal_goo')
local QuillSpray = bot:GetAbilityByName('bristleback_quill_spray')
local Bristleback = bot:GetAbilityByName('bristleback_bristleback')
local Hairball = bot:GetAbilityByName('bristleback_hairball')

function X.SkillsComplement()
    bot = GetBot()
    if J.CanNotUseAbility(bot) then return end
    if J.CanCastAbility(QuillSpray) and QuillSpray:GetAutoCastState() then QuillSpray:ToggleAutoCast() end
    if X.ConsiderQuillKill() > 0 then
        bot:Action_UseAbility(QuillSpray)
        return
    end
    local desire, target = X.ConsiderHairball()
    if desire > 0 then
        J.SetQueuePtToINT(bot, true, Hairball)
        bot:ActionQueue_UseAbilityOnLocation(Hairball, target)
        return
    end
    desire, target = X.ConsiderViscousNasalGoo()
    if desire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(ViscousNasalGoo, target)
        return
    end
    desire, target = X.ConsiderBristleback()
    if desire > 0 then
        J.SetQueuePtToINT(bot, true)
        bot:ActionQueue_UseAbilityOnLocation(Bristleback, target)
        return
    end
    if X.ConsiderQuillSpray() > 0 then
        J.SetQueuePtToINT(bot, true, QuillSpray)
        bot:ActionQueue_UseAbility(QuillSpray)
    end
end

-- Cast reach excludes the movement allowance in GetProperCastRange.
local function CastRange(ability)
    local range = ability:GetCastRange()
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:GetName() == 'item_aether_lens' then
            range = range + item:GetSpecialValueInt('cast_range_bonus')
            break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function PhysicalTarget(unit)
    return J.IsValid(unit) and unit:CanBeSeen() and not unit:IsInvulnerable()
        and not unit:IsAttackImmune()
        and not unit:HasModifier('modifier_omninight_guardian_angel')
        and not unit:HasModifier('modifier_winter_wyvern_cold_embrace')
        and not unit:HasModifier('modifier_abaddon_borrowed_time')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end

local function GooTarget(unit, range)
    return J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit)
        and J.CanCastOnNonMagicImmune(unit) and J.CanCastOnTargetAdvanced(unit)
        and J.IsInRange(bot, unit, range)
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
        and (J.GetModifierCount(unit, 'modifier_bristleback_viscous_nasal_goo')
            < ViscousNasalGoo:GetSpecialValueInt('stack_limit')
            or J.GetModifierTime(unit, 'modifier_bristleback_viscous_nasal_goo') < 1.5)
end

local function ReserveQuill(cost)
    local spray = bot:GetAbilityByName('bristleback_quill_spray')
    return spray == nil or not spray:IsTrained() or bot:GetMana() - cost >= spray:GetManaCost()
end

local function QuillDamage(unit)
    return math.min(QuillSpray:GetSpecialValueInt('max_damage'),
        QuillSpray:GetSpecialValueInt('quill_base_damage')
        + J.GetModifierCount(unit, 'modifier_bristleback_quill_spray')
            * QuillSpray:GetSpecialValueInt('quill_stack_damage'))
end

local function QuillKill(unit)
    return PhysicalTarget(unit) and not unit:HasModifier('modifier_dazzle_shallow_grave')
        and J.IsInRange(bot, unit, QuillSpray:GetSpecialValueInt('radius'))
        and J.CanKillTarget(unit, QuillDamage(unit), DAMAGE_TYPE_PHYSICAL)
end

function X.ConsiderQuillKill()
    if not J.CanCastAbility(QuillSpray) then return BOT_ACTION_DESIRE_NONE end
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, QuillSpray:GetSpecialValueInt('radius'), true, BOT_MODE_NONE)) do
        if QuillKill(enemy) then return BOT_ACTION_DESIRE_HIGH end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderViscousNasalGoo()
    if not J.CanCastAbility(ViscousNasalGoo)
        or not ReserveQuill(ViscousNasalGoo:GetManaCost()) then return BOT_ACTION_DESIRE_NONE, nil end
    local range = CastRange(ViscousNasalGoo)
    local target = J.GetProperTarget(bot)
    if (J.IsGoingOnSomeone(bot) or J.IsLaning(bot)) and GooTarget(target, range) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    local enemies = J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)
    for _, enemy in ipairs(enemies) do
        if GooTarget(enemy, range) then
            if J.IsInTeamFight(bot, 1200) or J.IsLaning(bot)
                or (J.IsRetreating(bot) and not J.IsRealInvisible(bot)
                    and J.IsChasingTarget(enemy, bot)) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            for _, ally in ipairs(J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE)) do
                if ally ~= bot and J.IsValidHero(ally) and J.IsRetreating(ally)
                    and not J.IsRealInvisible(ally) and J.IsChasingTarget(enemy, ally) then
                    return BOT_ACTION_DESIRE_HIGH, enemy
                end
            end
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target)
        and (J.IsRoshan(target) or J.IsTormentor(target)) and J.IsAttacking(bot)
        and J.CanCastOnNonMagicImmune(target) and J.CanCastOnTargetAdvanced(target)
        and J.IsInRange(bot, target, range) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderQuillSpray()
    if not J.CanCastAbility(QuillSpray) then return BOT_ACTION_DESIRE_NONE end
    local radius = QuillSpray:GetSpecialValueInt('radius')
    local target = J.GetProperTarget(bot)
    local enemies = J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)
    for _, enemy in ipairs(enemies) do
        if PhysicalTarget(enemy) and (QuillKill(enemy) or J.IsInTeamFight(bot, 1200)
            or (J.IsGoingOnSomeone(bot) and enemy == target)
            or (J.IsLaning(bot) and (bot:GetMana() - QuillSpray:GetManaCost()) / bot:GetMaxMana() > 0.35)
            or (J.IsRetreating(bot) and not J.IsRealInvisible(bot)
                and (J.IsChasingTarget(enemy, bot) or bot:WasRecentlyDamagedByHero(enemy, 3)))) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    if J.IsLaning(bot) then
        for _, creep in ipairs(bot:GetNearbyLaneCreeps(radius, true)) do
            if QuillKill(creep) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    local manaAfter = (bot:GetMana() - QuillSpray:GetManaCost()) / bot:GetMaxMana()
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and manaAfter > 0.25 then
        local count = 0
        for _, creep in ipairs(bot:GetNearbyCreeps(radius, true)) do
            if PhysicalTarget(creep) then count = count + 1 end
        end
        if count >= 2 or (J.IsFarming(bot) and PhysicalTarget(target) and target:IsCreep()
            and J.IsInRange(bot, target, radius) and target:GetHealth() > bot:GetAttackDamage() * 2) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsAttacking(bot)
        and PhysicalTarget(target) and (J.IsRoshan(target) or J.IsTormentor(target))
        and J.IsInRange(bot, target, radius) then return BOT_ACTION_DESIRE_HIGH end

    -- Build movement/damage before a real engagement, not empty casts near the fountain.
    local warpath = bot:GetAbilityByName('bristleback_warpath')
    if warpath ~= nil and warpath:IsTrained() and not J.HasBreakModifier(bot) and manaAfter > 0.6
        and J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and PhysicalTarget(target)
        and not J.IsInRange(bot, target, radius) and J.IsInRange(bot, target, 1600)
        and (J.GetModifierCount(bot, 'modifier_bristleback_warpath') < warpath:GetSpecialValueInt('max_stacks')
            or J.GetModifierTime(bot, 'modifier_bristleback_warpath') < 3) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

local function HairballLocation(target)
    local range = CastRange(Hairball)
    local delay = Hairball:GetCastPoint()
        + math.min(GetUnitToUnitDistance(bot, target), range) / Hairball:GetSpecialValueInt('projectile_speed')
    local location = target:GetExtrapolatedLocation(delay)
    local offset = location - bot:GetLocation()
    if offset:Length2D() > range then location = bot:GetLocation() + offset:Normalized() * range end
    if GetUnitToLocationDistance(target, location) <= Hairball:GetSpecialValueInt('radius')
        and (target:GetExtrapolatedLocation(delay) - location):Length2D() <= Hairball:GetSpecialValueInt('radius') then
        return location, delay
    end
    return nil
end

function X.ConsiderHairball()
    if not J.CanCastAbility(Hairball) or not ReserveQuill(Hairball:GetManaCost()) then
        return BOT_ACTION_DESIRE_NONE, nil
    end
    local radius = Hairball:GetSpecialValueInt('radius')
    local enemies = J.GetNearbyHeroes(bot, CastRange(Hairball) + radius, true, BOT_MODE_NONE)
    local target = J.GetProperTarget(bot)
    for _, enemy in ipairs(enemies) do
        -- Hairball is a point cast: spell reflection does not make the area unsafe.
        if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy) then
            local location, delay = HairballLocation(enemy)
            if location ~= nil then
                local count = 0
                for _, other in ipairs(enemies) do
                    if J.IsValidHero(other) and J.CanCastOnMagicImmune(other)
                        and (other:GetExtrapolatedLocation(delay) - location):Length2D() <= radius then count = count + 1 end
                end
                if (J.IsInTeamFight(bot, 1400) and count >= 2)
                    or (J.IsGoingOnSomeone(bot) and enemy == target)
                    or (J.IsRetreating(bot) and not J.IsRealInvisible(bot) and J.IsChasingTarget(enemy, bot)) then
                    return BOT_ACTION_DESIRE_HIGH, location
                end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBristleback()
    if not J.CanCastAbility(Bristleback) or not bot:HasScepter() then return BOT_ACTION_DESIRE_NONE, nil end
    local spray = bot:GetAbilityByName('bristleback_quill_spray')
    local radius = spray ~= nil and spray:GetSpecialValueInt('radius') or 700
    local delay = Bristleback:GetSpecialValueFloat('activation_delay')
    local target = J.GetProperTarget(bot)
    if J.IsRetreating(bot) then
        -- The active disarms, locks facing and slows us: avoid sacrificing an escape.
        return BOT_ACTION_DESIRE_NONE, nil
    end
    local candidates = J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)
    if J.IsValid(target) then table.insert(candidates, 1, target) end
    for _, unit in ipairs(candidates) do
        if PhysicalTarget(unit) and J.IsInRange(bot, unit, radius)
            and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then
            local predicted = unit:GetExtrapolatedLocation(delay)
            if GetUnitToLocationDistance(bot, predicted) <= radius
                and (J.IsDisabled(unit) or not J.IsChasingTarget(bot, unit)) then
                return BOT_ACTION_DESIRE_HIGH, predicted
            end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAttacking(bot)
        and (bot:GetMana() - Bristleback:GetManaCost()) / bot:GetMaxMana() > 0.35
        and #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) == 0 then
        local creeps = bot:GetNearbyCreeps(radius, true)
        for _, creep in ipairs(creeps) do
            if PhysicalTarget(creep) then
                local count = 0
                for _, other in ipairs(creeps) do
                    if PhysicalTarget(other) and J.IsInRange(creep, other, 150) then count = count + 1 end
                end
                if count >= 4 or (count >= 2 and creep:IsAncientCreep()) then
                    return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
                end
            end
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsAttacking(bot)
        and PhysicalTarget(target) and (J.IsRoshan(target) or J.IsTormentor(target))
        and J.IsInRange(bot, target, radius) then return BOT_ACTION_DESIRE_HIGH, target:GetLocation() end
    return BOT_ACTION_DESIRE_NONE, nil
end

-- Seeing Red was removed with facets; current Warpath has no active cast.
function X.ConsiderWarpath() return BOT_ACTION_DESIRE_NONE end

return X
