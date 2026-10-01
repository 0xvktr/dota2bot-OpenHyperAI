local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local ItemCastPolicy = require(GetScriptDirectory()..'/FunLib/item_cast_policy')
local PowerTreads = require(GetScriptDirectory()..'/FunLib/power_treads')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: mid only; forced other roles use mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/obsidian_destroyer')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Arcane Orb, [2] Astral Imprisonment, [3] Objurgation, [6] Sanity's Eclipse.
local nAbilityBuildList = {2,1,2,3,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +200 mana
    t15={10,0}, -- +0.8% current mana as movement speed
    t20={0,10}, -- -10s Objurgation cooldown
    t25={10,0}, -- -60s Sanity's Eclipse cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
-- Omit the observed opening ward on the core build.
X.sBuyList = {
    'item_mantle','item_double_branches','item_circlet','item_tango','item_faerie_fire',
    'item_null_talisman','item_null_talisman','item_magic_wand','item_power_treads','item_witch_blade',
    'item_force_staff','item_blink','item_dragon_lance','item_hurricane_pike',
    'item_black_king_bar','item_ultimate_scepter',
    -- Bot policy: retain Witch Blade, consume Scepter and add late control within six slots.
    'item_ultimate_scepter_2','item_sheepstick',
    'item_aghanims_shard','item_arcane_blink','item_moon_shard',
}
X.sSellList = {'item_blink','item_null_talisman','item_hurricane_pike','item_null_talisman','item_black_king_bar','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Arcane Orb point at 10, first talent at 11; preserve custom overrides.
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

local ArcaneOrb             = bot:GetAbilityByName('obsidian_destroyer_arcane_orb')
local AstralImprisonment    = bot:GetAbilityByName('obsidian_destroyer_astral_imprisonment')
local SanitysEclipse        = bot:GetAbilityByName('obsidian_destroyer_sanity_eclipse')
local Objurgation           = bot:GetAbilityByName('obsidian_destroyer_objurgation')

local ArcaneOrbDesire, ArcaneOrbTarget
local AstralImprisonmentDesire, AstralImprisonmentTarget
local SanitysEclipseDesire, SanitysEclipseLocation
local ObjurgationDesire

function X.OrbManaReserve()
    local reserve = ItemCastPolicy.Ready(AstralImprisonment) and AstralImprisonment:GetManaCost() or 0
    if #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) > 0 then
        -- Preserve Astral plus the more expensive ready combat spell. Essence
        -- Flux (obsidian_destroyer_equilibrium) is random; no proc is promised.
        local eclipse = ItemCastPolicy.Ready(SanitysEclipse) and SanitysEclipse:GetManaCost() or 0
        local barrier = ItemCastPolicy.Ready(Objurgation) and Objurgation:GetManaCost() or 0
        reserve = reserve + math.max(eclipse, barrier)
    end
    return reserve
end

function X.CanSpendOrb(buffer)
    local cost = math.max(ArcaneOrb:GetManaCost(),
        bot:GetMana() * ArcaneOrb:GetSpecialValueInt('mana_cost_percentage') / 100)
    return ArcaneOrb:IsTrained() and bot:GetMana() - cost >= X.OrbManaReserve() + (buffer or 0)
end

function X.UpdateOrbAutocast()
    if not ArcaneOrb:IsTrained() then return end
    local target = bot:GetAttackTarget()
    local current = ArcaneOrb:GetAutoCastState()
    -- IsValidTarget is hero-only in this repository; IsValid also accepts
    -- creeps so the reserve policy does not silently disable farm autocast.
    local useful = J.IsValid(target) and J.CanBeAttacked(target)
        and J.CanCastOnNonMagicImmune(target)
        and J.IsInRange(bot, target, bot:GetAttackRange() + 50)
        and not J.IsSuspiciousIllusion(target)
        and not target:HasModifier('modifier_abaddon_borrowed_time')
        and not target:HasModifier('modifier_dazzle_shallow_grave')
        and not target:HasModifier('modifier_templar_assassin_refraction_absorb')
        and (target:IsHero() or target:GetHealth() > bot:GetAttackDamage())
    -- Leave cheap last hits to ordinary attacks; allow healthy farm targets.
    -- A small restart buffer prevents toggling at the reserve boundary.
    local desired = useful == true and X.CanSpendOrb(current and 0 or bot:GetMaxMana() * 0.05)
    if current ~= desired then ArcaneOrb:ToggleAutoCast() end
end

local function castOrRequest(ability, target, kind, consider)
    if ability:IsFullyCastable() then
        ItemCastPolicy.Clear(bot)
        if kind == 'unit' then bot:Action_UseAbilityOnEntity(ability, target)
        elseif kind == 'ground' then bot:Action_UseAbilityOnLocation(ability, target)
        else bot:Action_UseAbility(ability) end
        return true
    end
    return ItemCastPolicy.Request(bot, ability, target, kind, function()
        local desire, freshTarget = consider()
        if desire <= 0 then return false end
        if kind == 'ground' then
            return freshTarget ~= nil and GetUnitToLocationDistance(bot, freshTarget) <= ability:GetCastRange()
                and (freshTarget - target):Length2D() < 50
        end
        return kind == 'none' or freshTarget == target
    end, J)
end

function X.SkillsComplement()
    ItemCastPolicy.Clear(bot)
    if PowerTreads.ActionLocked(bot) or J.CanNotUseAbility(bot) then return end
    X.UpdateOrbAutocast()

    ObjurgationDesire = X.ConsiderObjurgation()
    if ObjurgationDesire > 0 and castOrRequest(Objurgation, nil, 'none', X.ConsiderObjurgation)
    then
        return
    end

    SanitysEclipseDesire, SanitysEclipseLocation = X.ConsiderSanitysEclipse()
    if SanitysEclipseDesire > 0 and castOrRequest(SanitysEclipse, SanitysEclipseLocation, 'ground', X.ConsiderSanitysEclipse)
    then
        return
    end

    AstralImprisonmentDesire, AstralImprisonmentTarget = X.ConsiderAstralImprisonment()
    if AstralImprisonmentDesire > 0 and castOrRequest(AstralImprisonment, AstralImprisonmentTarget, 'unit', X.ConsiderAstralImprisonment)
    then
        return
    end

    ArcaneOrbDesire, ArcaneOrbTarget = X.ConsiderArcaneOrb()
    if ArcaneOrbDesire > 0
    then
        bot:Action_UseAbilityOnEntity(ArcaneOrb, ArcaneOrbTarget)
        return
    end
end

function X.ConsiderArcaneOrb()
    if not ArcaneOrb:IsFullyCastable()
    or ArcaneOrb:GetAutoCastState()
    or not X.CanSpendOrb()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nMul = ArcaneOrb:GetSpecialValueInt('mana_pool_damage_pct') / 100
    local nDamage = bot:GetAttackDamage() + bot:GetMana() * nMul
    local nAttackRange = bot:GetAttackRange()
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
        local weakestTarget = J.GetVulnerableWeakestUnit(bot, true, true, nAttackRange)
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)

		if J.IsValidTarget(weakestTarget)
        and J.CanBeAttacked(weakestTarget)
        and J.CanCastOnNonMagicImmune(weakestTarget)
        and J.IsInRange(bot, weakestTarget, nAttackRange)
        and not J.IsSuspiciousIllusion(weakestTarget)
        and not weakestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not weakestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not weakestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not weakestTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nTargetInRangeAlly = J.GetNearbyHeroes(weakestTarget, 800, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, weakestTarget
            end
		end
	end

    -- if J.IsLaning(bot)
	-- then
	-- 	local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nAttackRange + 200, true)

	-- 	for _, creep in pairs(nEnemyLaneCreeps)
	-- 	do
	-- 		if J.IsValid(creep)
	-- 		and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_PURE)
	-- 		then
	-- 			local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

	-- 			if nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
	-- 			then
	-- 				return BOT_ACTION_DESIRE_HIGH, creep
	-- 			end
	-- 		end
	-- 	end
	-- end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderAstralImprisonment()
    if not ItemCastPolicy.CanConsider(bot, AstralImprisonment)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = AstralImprisonment:GetCastRange()
	local nDamage = AstralImprisonment:GetSpecialValueInt('damage')
    local nDuration = AstralImprisonment:GetSpecialValueInt('prison_duration')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

            if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            and nInRangeAlly ~= nil and #nInRangeAlly <= 1
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

	if J.IsInTeamFight(bot, 1200)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if J.IsValidHero(allyHero)
            and not allyHero:IsIllusion()
            and allyHero:WasRecentlyDamagedByAnyHero(1)
            then
                if allyHero:HasModifier('modifier_enigma_black_hole_pull')
                or allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                or allyHero:HasModifier('modifier_legion_commander_duel')
                or allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                or J.GetHP(allyHero) < 0.33
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end
        end

        local strongestTarget = J.GetStrongestUnit(nCastRange + 150, bot, true, false, nDuration)
        if strongestTarget == nil
        then
            strongestTarget = J.GetStrongestUnit(nCastRange + 250, bot, true, true, nDuration)
        end
        if J.IsValidTarget(strongestTarget) then
            local nTargetInRangeAlly = J.GetNearbyHeroes(strongestTarget, 800, false, BOT_MODE_NONE)
            if #nTargetInRangeAlly >= 2 then
                if J.IsInRange(bot, strongestTarget, nCastRange)
                and not J.IsSuspiciousIllusion(strongestTarget)
                and not J.IsDisabled(strongestTarget)
                and not J.IsTaunted(strongestTarget)
                and not strongestTarget:HasModifier('modifier_abaddon_borrowed_time')
                and not strongestTarget:HasModifier('modifier_dazzle_shallow_grave')
                and not strongestTarget:HasModifier('modifier_enigma_black_hole_pull')
                and not strongestTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
                and not strongestTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
                then
                    return BOT_ACTION_DESIRE_HIGH, strongestTarget
                end
            end
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nInRangeAlly = J.GetNearbyHeroes(bot, 1000, false, BOT_MODE_NONE)
            -- 1v1
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)
            if #nInRangeAlly <= 1 and #nTargetInRangeAlly <= 1 then return BOT_ACTION_DESIRE_HIGH, botTarget end

            -- has more then 1 enemy and target has high hp
            if #nTargetInRangeAlly >= 2 and J.GetHP(botTarget) > 0.8 then return BOT_ACTION_DESIRE_HIGH, botTarget end

            local isChasing = J.IsChasingTarget(bot, botTarget)
            -- more ally v less enemy but target not running
            if #nInRangeAlly >= 2 and #nTargetInRangeAlly <= 1 and not isChasing then return BOT_ACTION_DESIRE_NONE, nil end
            if #nInRangeAlly > 2 and #nInRangeAlly > #nTargetInRangeAlly and not isChasing then return BOT_ACTION_DESIRE_NONE, nil end

            -- more ally v less enemy and target running
            if #nInRangeAlly >= #nTargetInRangeAlly and isChasing then return BOT_ACTION_DESIRE_HIGH, botTarget end
            local nInLongRangeAlly = J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_NONE)
            if #nInLongRangeAlly > #nInRangeAlly
            and #nInLongRangeAlly > #nTargetInRangeAlly
            and J.IsRunning(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
		end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
        and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.72 and bot:WasRecentlyDamagedByAnyHero(1.9)))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
        end
    end

    if J.IsLaning(bot)
    and J.IsInLaningPhase()
	then
		if J.GetMP(bot) > 0.65
        then
            local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsAttacking(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and (not enemyHero:IsDisarmed()
                    or not enemyHero:IsStunned()
                    or not enemyHero:IsHexed())
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        then
            if J.GetHP(bot) < 0.2
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end

            local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
            for _, allyHero in pairs(nInRangeAlly)
            do
                if J.IsValidHero(allyHero)
                and J.GetHP(allyHero) < 0.3
                and not allyHero:IsIllusion()
                and not allyHero:HasModifier('modifier_abaddon_borrowed_time')
                and not allyHero:HasModifier('modifier_dazzle_shallow_grave')
                and not allyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, nCastRange, true, BOT_MODE_NONE)

        if J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.6)
        and not allyHero:IsChanneling()
        and not allyHero:IsIllusion()
        and J.GetMP(bot) > 0.31
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], 400)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsRunning(allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSanitysEclipse()
    if not ItemCastPolicy.CanConsider(bot, SanitysEclipse)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = SanitysEclipse:GetCastRange()
	local nMultiplier = SanitysEclipse:GetSpecialValueFloat('damage_multiplier')
    local nBaseDamage = SanitysEclipse:GetSpecialValueFloat('base_damage')

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)

        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidTarget(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
            and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not enemyHero:HasModifier('modifier_legion_commander_duel')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            then
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)
                local nManaDiff = math.abs(bot:GetMana() - enemyHero:GetMana())
                local nDamage = nManaDiff * nMultiplier

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                and J.CanKillTarget(enemyHero, nBaseDamage + nDamage, DAMAGE_TYPE_MAGICAL)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderObjurgation()
    if not ItemCastPolicy.CanConsider(bot, Objurgation)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nBarrierPct = Objurgation:GetSpecialValueFloat('mana_to_barrier') / 100
    local nBarrierFlat = Objurgation:GetSpecialValueFloat('barrier_flat')
    local nBarrier = nBarrierFlat + bot:GetMana() * nBarrierPct

    if J.IsInTeamFight(bot, 1200)
    then
        if J.GetHP(bot) < 0.7
        and bot:WasRecentlyDamagedByAnyHero(2)
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        local nInRangeEnemy = J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        local botTarget = J.GetProperTarget(bot)
        local nInRangeEnemy = J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE)

        if J.IsValidTarget(botTarget)
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.IsInRange(bot, botTarget, bot:GetAttackRange() + 200)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsRetreating(bot)
    then
        if J.GetHP(bot) < 0.5
        and bot:WasRecentlyDamagedByAnyHero(2)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X
