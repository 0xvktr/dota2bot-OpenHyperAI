local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT on 2026-09-27; see Builds/abaddon.lua for samples.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/abaddon')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local isSupport = sRole == 'pos_4' or sRole == 'pos_5'
local tTalentTreeList
local nAbilityBuildList
if isSupport then
    -- D2PT pos 4/5: Shield, then max Coil; Curse at level 10, first talent at 11.
    tTalentTreeList = { t10={10,0}, t15={10,0}, t20={0,10}, t25={10,0} }
    nAbilityBuildList = {2,1,1,2,1,6,1,2,2,3,6,3,3,3,6}
else
    -- D2PT pos 1/3: max Shield, then Curse. Levels after 10 are a legal continuation.
    tTalentTreeList = { t10={0,10}, t15={0,10}, t20={10,0}, t25={0,10} }
    nAbilityBuildList = {2,3,2,3,2,6,2,3,3,1,6,1,1,1,6}
end
local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)
local defaultAbilityBuild = nAbilityBuildList
local defaultTalentBuild = nTalentBuildList
local sRoleItemsBuyList = {}

-- Updated to 7.41f: carry. Components are resolved by the game's recipe API.
sRoleItemsBuyList.pos_1 = {
    'item_tango', 'item_quelling_blade', 'item_branches', 'item_circlet', 'item_magic_stick',
    'item_null_talisman', 'item_magic_wand', 'item_phase_boots',
    'item_radiance', 'item_yasha', 'item_manta', 'item_blink', 'item_orchid', 'item_bloodthorn',
    -- Bot late-game continuation: slot-free upgrades, then finish existing equipment.
    'item_aghanims_shard', 'item_ultimate_scepter_2', 'item_overwhelming_blink',
    'item_basher', 'item_abyssal_blade', 'item_moon_shard',
}
-- Mid skipped: one match. Explicit player overrides use the carry fallback, not a validated mid build.
sRoleItemsBuyList.pos_2 = sRoleItemsBuyList.pos_1

-- Updated to 7.41f: offlane brings Blink forward between Yasha and Manta.
sRoleItemsBuyList.pos_3 = {
    'item_tango', 'item_quelling_blade', 'item_branches', 'item_circlet', 'item_magic_stick',
    'item_null_talisman', 'item_magic_wand', 'item_phase_boots',
    'item_radiance', 'item_yasha', 'item_blink', 'item_manta', 'item_orchid',
    -- Natural Orchid upgrade followed by bot late-game continuation.
    'item_bloodthorn', 'item_aghanims_shard', 'item_ultimate_scepter_2',
    'item_overwhelming_blink', 'item_basher', 'item_abyssal_blade', 'item_moon_shard',
}

-- Updated to 7.41f: most-played position 4 build, including Pavise -> Solar Crest.
sRoleItemsBuyList.pos_4 = {
    'item_tango', 'item_double_branches', 'item_magic_stick', 'item_ward_sentry', 'item_blood_grenade',
    'item_magic_wand', 'item_arcane_boots', 'item_pavise', 'item_holy_locket',
    'item_solar_crest', 'item_mekansm', 'item_guardian_greaves',
    -- Late-game continuation, not additional D2PT core items.
    'item_ultimate_scepter', 'item_aghanims_shard', 'item_ultimate_scepter_2',
    'item_blink', 'item_overwhelming_blink', 'item_moon_shard',
}

-- Updated to 7.41f: position 5. Greaves consolidates the existing boots and Mek.
sRoleItemsBuyList.pos_5 = {
    'item_tango', 'item_double_branches', 'item_magic_stick', 'item_ward_sentry', 'item_blood_grenade',
    'item_magic_wand', 'item_arcane_boots', 'item_holy_locket', 'item_mekansm',
    'item_blink', 'item_ultimate_scepter',
    -- Natural upgrades / bot late-game continuation.
    'item_guardian_greaves', 'item_aghanims_shard', 'item_ultimate_scepter_2',
    'item_overwhelming_blink', 'item_moon_shard',
}
X.sBuyList = sRoleItemsBuyList[sRole] or sRoleItemsBuyList.pos_3
X.sSellList = {
    'item_radiance', 'item_quelling_blade',
    'item_manta', 'item_null_talisman',
    'item_bloodthorn', 'item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Preserve user-provided skill builds. The default support build delays its first talent.
if isSupport and nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end


X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end
end

local MistCoil          = bot:GetAbilityByName( 'abaddon_death_coil' )
local AphoticShield     = bot:GetAbilityByName( 'abaddon_aphotic_shield' )
-- local CurseOfAvernus    = bot:GetAbilityByName( 'abaddon_frostmourne' )
local BorrowedTime = bot:GetAbilityByName('abaddon_borrowed_time')
local CoilTalent = bot:GetAbilityByName(sTalentList[4])

local MistCoilDesire, MistCoilTarget
local AphoticShieldDesire, AphoticShieldTarget

local function AbilityCastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    return range
end

function X.SkillsComplement()
    -- Borrowed Time can be activated through disables, so check it before the normal gate.
    if X.ConsiderBorrowedTime() > 0 then
        bot:Action_UseAbility(BorrowedTime)
        return
    end
    if J.CanNotUseAbility(bot) then return end

    AphoticShieldDesire, AphoticShieldTarget = X.ConsiderAphoticShield()
    if AphoticShieldDesire > 0
    then
        bot:Action_UseAbilityOnEntity(AphoticShield, AphoticShieldTarget)
        return
    end

    MistCoilDesire, MistCoilTarget = X.ConsiderMistCoil()
    if MistCoilDesire > 0 and MistCoilTarget
    then
        bot:Action_UseAbilityOnEntity(MistCoil, MistCoilTarget)
        return
    end
end

function X.ConsiderBorrowedTime()
    if not bot:IsAlive() or bot:IsSilenced() or bot:IsInvulnerable()
    or bot:IsChanneling() or bot:IsUsingAbility() or bot:IsCastingAbility()
    or not BorrowedTime:IsFullyCastable() or bot:HasModifier('modifier_abaddon_borrowed_time') then
        return BOT_ACTION_DESIRE_NONE
    end
    local threatened = bot:WasRecentlyDamagedByAnyHero(2)
    if threatened and (J.HasBreakModifier(bot) or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared())
    and J.GetHP(bot) < 0.65 then return BOT_ACTION_DESIRE_HIGH end
    if threatened and (bot:GetHealth() <= BorrowedTime:GetSpecialValueInt('hp_threshold')
        or J.GetHP(bot) < 0.3) then return BOT_ACTION_DESIRE_HIGH end
    if bot:HasScepter() then
        local range = AbilityCastRange(MistCoil)
        for _, ally in pairs(J.GetNearbyHeroes(bot, range, false, BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and ally ~= bot and J.IsInRange(bot, ally, range)
            and not ally:IsIllusion() and not ally:IsInvulnerable()
            and not ally:HasModifier('modifier_ice_blast') and not ally:HasModifier('modifier_doom_bringer_doom')
            and ally:WasRecentlyDamagedByAnyHero(2) and J.GetHP(ally) < 0.5 then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function CanSupport(unit, range, allowImmune)
    return J.IsValidHero(unit) and J.IsInRange(bot, unit, range)
        and unit:CanBeSeen() and not unit:IsInvulnerable() and not unit:IsIllusion()
        and (allowImmune or not unit:IsMagicImmune())
end

local function HealBlocked(unit)
    return unit:HasModifier('modifier_ice_blast') or unit:HasModifier('modifier_doom_bringer_doom')
end

function X.ConsiderMistCoil()
    if not MistCoil:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end
    local range = AbilityCastRange(MistCoil)
    local damage = MistCoil:GetSpecialValueInt('damage_heal')
    if CoilTalent:IsTrained() then damage = damage + CoilTalent:GetSpecialValueInt('value') end
    -- self_damage is a percentage of the damage/heal, not a flat health cost.
    local cost = damage * MistCoil:GetSpecialValueInt('self_damage') / 100
    local protected = bot:HasModifier('modifier_abaddon_borrowed_time')
    if not protected and bot:GetHealth() <= cost + bot:GetMaxHealth() * 0.15 then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local best, lowest = nil, 1
    for _, ally in pairs(J.GetNearbyHeroes(bot, range, false, BOT_MODE_NONE)) do
        if ally ~= bot and CanSupport(ally, range, true) and not HealBlocked(ally)
        and not ally:HasModifier('modifier_abaddon_borrowed_time')
        and ally:GetMaxHealth() - ally:GetHealth() >= damage * 0.5
        and J.GetHP(ally) < lowest then
            best, lowest = ally, J.GetHP(ally)
        end
    end
    if best ~= nil and (lowest < 0.65 or best:WasRecentlyDamagedByAnyHero(2)) then
        return BOT_ACTION_DESIRE_HIGH, best
    end

    local enemies = J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if J.IsValidHero(enemy) and J.IsInRange(bot, enemy, range)
        and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
        and not enemy:HasModifier('modifier_antimage_counterspell')
        and not J.IsSuspiciousIllusion(enemy) and not J.CannotBeKilled(bot, enemy)
        and not enemy:HasModifier('modifier_templar_assassin_refraction_absorb')
        and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.IsInRange(bot, target, range)
    and J.CanCastOnNonMagicImmune(target) and J.CanCastOnTargetAdvanced(target)
    and not target:HasModifier('modifier_antimage_counterspell')
    and not J.IsSuspiciousIllusion(target) and not J.CannotBeKilled(bot, target)
    and (protected or J.GetHP(bot) > 0.35) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    if best ~= nil and lowest < 0.85 and J.GetMP(bot) > 0.4 then
        return BOT_ACTION_DESIRE_HIGH, best
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValidTarget(target)
    and J.IsInRange(bot, target, range) and J.IsAttacking(bot)
    and J.CanCastOnNonMagicImmune(target) and (protected or J.GetHP(bot) > 0.6) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderAphoticShield()
    if not AphoticShield:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end
    local range = AbilityCastRange(AphoticShield)
    local allies = J.GetNearbyHeroes(bot, range, false, BOT_MODE_NONE)
    local candidates = { bot }
    for _, ally in pairs(allies) do if ally ~= bot then candidates[#candidates + 1] = ally end end
    -- Replacing an existing barrier is worthwhile when it frees a disabled ally.
    for _, ally in pairs(candidates) do
        if CanSupport(ally, range, false)
        and (ally:IsStunned() or ally:IsRooted() or ally:IsHexed() or ally:IsNightmared()
            or (ally:IsSilenced() and not ally:HasModifier('modifier_item_mask_of_madness_berserk')
                and not ally:HasModifier('modifier_doom_bringer_doom')
                and not ally:HasModifier('modifier_riki_smoke_screen')
                and not ally:HasModifier('modifier_disruptor_static_storm'))
            or ally:HasModifier('modifier_dazzle_poison_touch')
            or ally:HasModifier('modifier_bounty_hunter_track')
            or ally:HasModifier('modifier_slardar_amplify_damage')
            or ally:HasModifier('modifier_item_spirit_vessel_damage'))
        and not ally:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not ally:HasModifier('modifier_enigma_black_hole_pull')
        and not ally:HasModifier('modifier_legion_commander_duel')
        and not ally:HasModifier('modifier_axe_berserkers_call') then
            return BOT_ACTION_DESIRE_HIGH, ally
        end
    end
    local best, lowest = nil, 2
    for _, ally in pairs(candidates) do
        if CanSupport(ally, range, false)
        and not ally:HasModifier('modifier_abaddon_aphotic_shield')
        and not ally:HasModifier('modifier_abaddon_borrowed_time') then
            local target = ally:GetAttackTarget()
            local exposed = ally:WasRecentlyDamagedByAnyHero(2)
                or (J.IsGoingOnSomeone(ally) and J.IsValidHero(target) and J.IsInRange(ally, target, 500))
            if exposed and J.GetHP(ally) < lowest then best, lowest = ally, J.GetHP(ally) end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot) then
        local target = J.GetProperTarget(bot)
        if J.IsValidTarget(target) and J.IsInRange(bot, target, 500) and J.IsAttacking(bot) then
            local ally = J.GetAttackableWeakestUnit(bot, range, true, false)
            if CanSupport(ally, range, false) and not ally:HasModifier('modifier_abaddon_aphotic_shield') then
                return BOT_ACTION_DESIRE_HIGH, ally
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

return X
