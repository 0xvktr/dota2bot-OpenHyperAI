local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: offlane; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/night_stalker')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Void, [2] Crippling Fear, [3] Midnight Feast, [6] Dark Ascension.
local nAbilityBuildList = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- -1s Void cooldown
    t15={10,0}, -- Hunter status resistance
    t20={10,0}, -- +15 Strength
    t25={10,0}, -- -35s Dark Ascension cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_gauntlets','item_double_branches','item_circlet','item_tango',
    'item_double_bracer','item_magic_wand','item_phase_boots','item_echo_sabre','item_blink',
    'item_black_king_bar','item_aghanims_shard','item_harpoon','item_nullifier',
    -- Bot policy: consumed Scepter, lockdown and mobility within six slots.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_basher','item_abyssal_blade',
    'item_overwhelming_blink','item_moon_shard',
}
X.sSellList = {
    'item_blink','item_quelling_blade',
    'item_black_king_bar','item_bracer',
    'item_harpoon','item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_mid'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Void              = bot:GetAbilityByName('night_stalker_void')
local CripplingFear     = bot:GetAbilityByName('night_stalker_crippling_fear')
local MidnightFeast  = bot:GetAbilityByName('night_stalker_midnight_feast')
local DarkAscension     = bot:GetAbilityByName('night_stalker_darkness')

local VoidDesire, VoidTarget
local CripplingFearDesire
local MidnightFeastDesire, MidnightFeastTarget
local DarkAscensionDesire

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) or bot:IsChanneling() then return end

    -- Silence immediate escape/channel threats before spending a cast on the ultimate.
    CripplingFearDesire = X.ConsiderCripplingFear()
    if CripplingFearDesire > 0 then bot:Action_UseAbility(CripplingFear); return end
    VoidDesire, VoidTarget = X.ConsiderVoid()
    if VoidDesire > 0 and VoidTarget:IsChanneling() and X.IsNight() then
        bot:Action_UseAbilityOnEntity(Void, VoidTarget); return
    end
    DarkAscensionDesire = X.ConsiderDarkAscension()
    if DarkAscensionDesire > 0 then bot:Action_UseAbility(DarkAscension); return end

    VoidDesire, VoidTarget = X.ConsiderVoid()
    if VoidDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Void, VoidTarget)

        return
    end

    MidnightFeastDesire, MidnightFeastTarget = X.ConsiderMidnightFeast()
    if MidnightFeastDesire > 0
    then
        bot:Action_UseAbilityOnEntity(MidnightFeast, MidnightFeastTarget)
        return
    end
end

function X.IsNight()
    local time = GetTimeOfDay()
    return time < 0.25 or time > 0.75 or bot:HasModifier('modifier_night_stalker_darkness')
end
local function SpellRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
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

return X
