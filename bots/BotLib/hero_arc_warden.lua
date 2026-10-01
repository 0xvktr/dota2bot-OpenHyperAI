local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT, position 2 only; forced other roles use this fallback.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/arc_warden')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local nAbilityBuildList = {3,2,3,1,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +200 Health
    t15={10,0}, -- Magnetic Field attack speed
    t20={10,0}, -- Magnetic Field cooldown
    t25={0,10}, -- Runic Infusion attributes
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    -- D2PT opening: Branches and Circlets for early attributes (not upgraded in this build; the inventory
    -- upkeep sells them once they stop mattering), Faerie Fire, Tango. The Observer Ward is left out: only
    -- supports ever place wards (mode_ward_generic), so a core would carry it unused.
    'item_tango', 'item_double_branches', 'item_double_circlet', 'item_faerie_fire', 'item_bottle',
    'item_hand_of_midas', 'item_maelstrom', 'item_mjollnir',
    'item_travel_boots', 'item_orchid', 'item_aghanims_shard',
    'item_yasha', 'item_manta', 'item_bloodthorn', 'item_sheepstick',
    'item_travel_boots_2', 'item_swift_blink',
    -- Late inventory policy: BKB replaces Manta, matching the 55+ minute sample.
    'item_black_king_bar',
    -- Permanent late-game continuation, beyond D2PT's displayed progression.
    'item_ultimate_scepter_2', 'item_moon_shard',
}
X.sSellList = {
    'item_mjollnir', 'item_bottle',
    'item_sheepstick', 'item_hand_of_midas',
    'item_black_king_bar', 'item_manta',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_ranged_carry' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT finishes Flux at 10 and takes the first talent at 11; respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local Flux 			= bot:GetAbilityByName('arc_warden_flux')
local MagneticField = bot:GetAbilityByName('arc_warden_magnetic_field')
local SparkWraith 	= bot:GetAbilityByName('arc_warden_spark_wraith')
local TempestDouble = bot:GetAbilityByName('arc_warden_tempest_double')

local FluxDesire, FluxTarget
local MagneticFieldDesire, MagneticFieldTarget
local SparkWraithDesire, SparkWraithLocation
local TempestDoubleDesire, TempestDoubleLocation

local npcDouble = nil

local botTarget

-- The shared query currently drops every hero when its caller is the Double.
local function NearbyHeroes(unit, range, enemy, mode)
    if unit:HasModifier('modifier_arc_warden_tempest_double') then
        return unit:GetNearbyHeroes(math.min(range, 1600), enemy, mode or BOT_MODE_NONE)
    end
    return J.GetNearbyHeroes(unit, math.min(range, 1600), enemy, mode)
end

local function ClampLocation(location, range)
    local origin = bot:GetLocation()
    local dx, dy = location.x - origin.x, location.y - origin.y
    local distance = math.sqrt(dx * dx + dy * dy)
    if distance > range then return Vector(origin.x + dx * range / distance, origin.y + dy * range / distance, location.z) end
    return location
end

local function WraithClear(location, target, radius)
    for _, creep in pairs(GetUnitList(UNIT_LIST_ENEMY_CREEPS)) do
        if creep ~= target and J.IsValid(creep) and J.CanBeAttacked(creep)
            and GetUnitToLocationDistance(creep, location) <= radius then return false end
    end
    return true
end

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) or J.IsRealInvisible(bot) then return end
    botTarget = J.GetProperTarget(bot)

    local fieldDesire, fieldLocation, defensive = X.ConsiderMagneticField()
    if fieldDesire > 0 and defensive then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbilityOnLocation(MagneticField, fieldLocation)
        return
    end

    -- Slow an isolated target before the Double and attack-speed field follow up.
    FluxDesire, FluxTarget = X.ConsiderFlux()
    if FluxDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(Flux, FluxTarget)
        return
    end
    TempestDoubleDesire, TempestDoubleLocation = X.ConsiderTempestDouble()
    if TempestDoubleDesire > 0 then
        bot:Action_UseAbilityOnLocation(TempestDouble, ClampLocation(TempestDoubleLocation, TempestDouble:GetCastRange()))
        return
    end
    if fieldDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbilityOnLocation(MagneticField, fieldLocation)
        return
    end
    SparkWraithDesire, SparkWraithLocation = X.ConsiderSparkWraith()
    if SparkWraithDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(SparkWraith, SparkWraithLocation)
    end
end

local function IsFluxIsolated(target)
    local radius = Flux:GetSpecialValueInt('search_radius')
    for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if unit ~= target and J.IsValid(unit) and J.IsInRange(target, unit, radius) then return false end
    end
    for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMY_CREEPS)) do
        if unit ~= target and J.IsValid(unit) and J.IsInRange(target, unit, radius) then return false end
    end
    return true
end

function X.ConsiderFlux()
    if not Flux:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range = Flux:GetCastRange()
    local damage = Flux:GetSpecialValueInt('damage_per_second') * Flux:GetSpecialValueFloat('duration')
    local enemies = NearbyHeroes(bot, range, true, BOT_MODE_NONE)
    local function canFlux(enemy)
        return J.IsValidHero(enemy) and J.IsInRange(bot, enemy, range)
            and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_antimage_counterspell')
            and not J.IsSuspiciousIllusion(enemy)
            and not enemy:HasModifier('modifier_abaddon_borrowed_time')
            and not enemy:HasModifier('modifier_oracle_false_promise_timer')
    end
    for _, enemy in pairs(enemies) do
        -- Nearby friendly units pause damage; slow still works in a pack.
        if canFlux(enemy) and IsFluxIsolated(enemy)
            and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_templar_assassin_refraction_absorb')
            and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    if J.IsRetreating(bot) then
        for _, enemy in pairs(enemies) do
            if canFlux(enemy) and not J.IsDisabled(enemy)
                and (J.IsChasingTarget(enemy, bot) or bot:WasRecentlyDamagedByHero(enemy, 2)) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    if (J.IsGoingOnSomeone(bot) or (J.IsLaning(bot) and J.GetMP(bot) > 0.5))
        and canFlux(botTarget) and IsFluxIsolated(botTarget) then
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    if J.IsInTeamFight(bot, 1200) then
        local best, mostDamage = nil, -1
        for _, enemy in pairs(enemies) do
            if canFlux(enemy) and (IsFluxIsolated(enemy) or J.IsChasingTarget(enemy, bot)) then
                local threat = enemy:GetEstimatedDamageToTarget(false, bot, 3, DAMAGE_TYPE_ALL)
                if threat > mostDamage then best, mostDamage = enemy, threat end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderMagneticField()
    if not MagneticField:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range = MagneticField:GetCastRange()
    local radius = MagneticField:GetSpecialValueInt('radius')
    local allies = J.GetAlliesNearLoc(bot:GetLocation(), range)
    local seen = {}; table.insert(allies, bot)
    for _, ally in pairs(allies) do
        if not seen[ally] and J.IsValidHero(ally) and (not ally:IsIllusion() or ally:HasModifier('modifier_arc_warden_tempest_double'))
            and J.IsInRange(bot, ally, range)
            and not ally:HasModifier('modifier_arc_warden_magnetic_field') then
            seen[ally] = true
            for _, enemy in pairs(NearbyHeroes(ally, 1200, true, BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and enemy:GetAttackTarget() == ally
                    and not J.IsInRange(enemy, ally, radius)
                    and (J.IsRetreating(ally) or J.GetHP(ally) < 0.45) then
                    return BOT_ACTION_DESIRE_HIGH, ally:GetLocation(), true
                end
            end
        end
    end
    -- Both Arc Warden and Rubick can use the current Field to activate a river rune.
    if bot:GetActiveMode() == BOT_MODE_RUNE then
        for _, rune in pairs({RUNE_POWERUP_1, RUNE_POWERUP_2}) do
            local location = GetRuneSpawnLocation(rune)
            if GetRuneStatus(rune) == RUNE_STATUS_AVAILABLE
                and GetUnitToLocationDistance(bot, location) <= range then
                return BOT_ACTION_DESIRE_HIGH, location
            end
        end
    end
    for _, ally in pairs(allies) do
        local attackTarget = ally:GetAttackTarget()
        if J.IsValidHero(ally) and (not ally:IsIllusion() or ally:HasModifier('modifier_arc_warden_tempest_double'))
            and J.IsInRange(bot, ally, range)
            and not ally:HasModifier('modifier_arc_warden_magnetic_field')
            and J.IsValid(attackTarget)
            and J.IsInRange(ally, attackTarget, ally:GetAttackRange() + 50)
            and (J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot)
                or J.IsPushing(bot) or J.IsDefending(bot) or J.IsDoingRoshan(bot)
                or J.IsDoingTormentor(bot) or (J.IsFarming(bot) and J.IsAllowedToSpam(bot, MagneticField:GetManaCost()))) then
            return BOT_ACTION_DESIRE_HIGH, ally:GetLocation()
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSparkWraith()
	if not SparkWraith:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, 0 end

	local nCastRange = SparkWraith:GetCastRange()
	local nRadius = SparkWraith:GetSpecialValueInt('radius')
	local nDamage = SparkWraith:GetSpecialValueInt('spark_damage_base')
	local nCastPoint = SparkWraith:GetCastPoint()
	local nDelay = SparkWraith:GetSpecialValueFloat('base_activation_delay') + nCastPoint

	local nEnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange)
		and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and WraithClear(enemyHero:GetExtrapolatedLocation(nDelay), enemyHero, nRadius)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
			return BOT_ACTION_DESIRE_HIGH, ClampLocation(enemyHero:GetExtrapolatedLocation(nDelay), nCastRange)
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
        and WraithClear(botTarget:GetExtrapolatedLocation(nDelay), botTarget, nRadius)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		and not botTarget:HasModifier('modifier_item_aeon_disk_buff')
		then
			local nInRangeAlly = NearbyHeroes(botTarget, 1600, true, BOT_MODE_NONE)
			local nInRangeEnemy = NearbyHeroes(botTarget, 1600, false, BOT_MODE_NONE)

			if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			then
				if J.IsRunning(botTarget)
				then
					return BOT_ACTION_DESIRE_MODERATE, ClampLocation(botTarget:GetExtrapolatedLocation(nDelay), nCastRange)
				else
					return BOT_ACTION_DESIRE_MODERATE, ClampLocation(botTarget:GetLocation(), nCastRange)
				end
			end
		end

		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nDelay, 0)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
		and J.GetManaAfter(SparkWraith:GetManaCost()) * bot:GetMana() > Flux:GetManaCost() + MagneticField:GetManaCost() + SparkWraith:GetManaCost()
		and not bot:HasModifier('modifier_silencer_curse_of_the_silent')
		then
			local nCreep = J.GetVulnerableUnitNearLoc( bot, false, true, 1600, nRadius, nLocationAoE.targetloc )
			if nCreep == nil
			or bot:HasModifier('modifier_arc_warden_tempest_double')
			then
				return BOT_ACTION_DESIRE_HIGH, ClampLocation(nLocationAoE.targetloc, nCastRange)
			end
		end
	end

	if J.IsRetreating(bot)
	and bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_HIGH
	and not bot:HasModifier('modifier_silencer_curse_of_the_silent')
	then
		local nInRangeEnemy = NearbyHeroes(bot,800, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValid(enemyHero)
			and bot:WasRecentlyDamagedByHero(enemyHero, 1)
			and J.CanCastOnNonMagicImmune(enemyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, ClampLocation(bot:GetLocation(), nCastRange)
			end
		end
	end

	if J.IsPushing(bot)
	or J.IsDefending(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nDelay, 0)
		if nLocationAoE.count > 2
		and not bot:HasModifier('modifier_silencer_curse_of_the_silent')
		then
			if bot:HasModifier('modifier_arc_warden_tempest_double')
			then
				return BOT_ACTION_DESIRE_HIGH, ClampLocation(nLocationAoE.targetloc, nCastRange)
			end

			local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1400, true)
			if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
			then
				if J.GetMP(bot) > 0.62
				then
					return BOT_ACTION_DESIRE_HIGH, ClampLocation(nLocationAoE.targetloc, nCastRange)
				end
			else
				if J.GetMP(bot) > 0.75
				then
					return BOT_ACTION_DESIRE_HIGH, ClampLocation(nLocationAoE.targetloc, nCastRange)
				end
			end
		end
	end

	if J.IsFarming(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nDelay, 0)
		if nLocationAoE.count >= 1
		and not bot:HasModifier('modifier_silencer_curse_of_the_silent')
		then
			if bot:HasModifier('modifier_arc_warden_tempest_double')
			then
				return BOT_ACTION_DESIRE_HIGH, ClampLocation(nLocationAoE.targetloc, nCastRange)
			end

			local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1400, true)
			if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 1
			then
				if J.GetMP(bot) > 0.42
				then
					return BOT_ACTION_DESIRE_HIGH, ClampLocation(nLocationAoE.targetloc, nCastRange)
				end
			else
				if J.GetMP(bot) > 0.55
				then
					return BOT_ACTION_DESIRE_HIGH, ClampLocation(nLocationAoE.targetloc, nCastRange)
				end
			end
		end
	end

	if J.IsLaning(bot)
	and J.IsInLaningPhase()
    and bot:GetLevel() < 7
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if J.IsValid(creep)
            and J.CanBeAttacked(creep)
			and J.IsKeyWordUnit('ranged', creep)
			and J.IsInRange(bot, creep, nCastRange)
            and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
			and botTarget ~= creep
			and not J.IsRunning(creep)
			then
				return BOT_ACTION_DESIRE_HIGH, ClampLocation(creep:GetLocation(), nCastRange)
			end
		end
	end

	if SparkWraith:GetLevel() >= 3
	and J.GetManaAfter(SparkWraith:GetManaCost()) * bot:GetMana() > Flux:GetManaCost() + MagneticField:GetManaCost() + SparkWraith:GetManaCost()
	and not J.IsLaning(bot)
	then
		local nLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nDelay, 0)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, ClampLocation(J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
		end
	end

	if bot:GetLevel() >= 10
	and ((J.GetManaAfter(SparkWraith:GetManaCost()) * bot:GetMana() > Flux:GetManaCost() + MagneticField:GetManaCost() + SparkWraith:GetManaCost())
		or bot:HasModifier('modifier_arc_warden_tempest_double'))
	and DotaTime() > 8 * 60
	then
		local nEnemysHerosCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES)
		local nTargetHero = nil
		local nTargetHeroHealth = 99999
		for _, enemyHero in pairs( nEnemysHerosCanSeen )
		do
			if J.IsValidHero(enemyHero)
			and GetUnitToUnitDistance(bot, enemyHero) <= nCastRange
			and enemyHero:GetHealth() < nTargetHeroHealth
			then
				nTargetHero = enemyHero
				nTargetHeroHealth = enemyHero:GetHealth()
			end
		end

		if nTargetHero ~= nil
		then
			for i = 0, 350, 50
			do
				local nCastLocation = J.GetLocationTowardDistanceLocation(nTargetHero, J.GetEnemyFountain(), 350 - i)
				if GetUnitToLocationDistance(bot, nCastLocation) <= nCastRange
				then
					return BOT_ACTION_DESIRE_HIGH, ClampLocation(nCastLocation, nCastRange)
				end
			end
		end

		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
		then
			local targetCreep = nEnemyLaneCreeps[#nEnemyLaneCreeps]
			if J.IsValid(targetCreep)
			and J.CanBeAttacked(targetCreep)
			then
				local nCastLocation = J.GetFaceTowardDistanceLocation(targetCreep, 375)
				return BOT_ACTION_DESIRE_HIGH, ClampLocation(nCastLocation, nCastRange)
			end
		end

		local nEnemyHeroesInView = NearbyHeroes(bot,1600, true, BOT_MODE_NONE)
		local nEnemyLaneFront = J.GetNearestLaneFrontLocation(bot:GetLocation(), true, nRadius / 2)

		if nEnemyHeroesInView ~= nil and #nEnemyHeroesInView == 0 and nEnemyLaneFront ~= nil
		and GetUnitToLocationDistance(bot, nEnemyLaneFront) <= nCastRange + nRadius
		and GetUnitToLocationDistance(bot, nEnemyLaneFront) >= 800
		then
			local nCastLocation = J.GetLocationTowardDistanceLocation( bot, nEnemyLaneFront, nCastRange )
			if GetUnitToLocationDistance(bot, nEnemyLaneFront) < nCastRange
			then
				nCastLocation = nEnemyLaneFront
			end

			return BOT_ACTION_DESIRE_HIGH, ClampLocation(nCastLocation, nCastRange)
		end
	end

	local nCastLocation = J.GetLocationTowardDistanceLocation(bot, J.GetEnemyFountain(), nCastRange)
	if bot:HasModifier('modifier_arc_warden_tempest_double')
	or (J.GetMP(bot) > 0.92 and bot:GetLevel() > 11 and not IsLocationVisible(nCastLocation))
	or (J.GetMP(bot) > 0.38 and J.GetDistanceFromEnemyFountain(bot) < 4300)
	then
		if IsLocationPassable(nCastLocation)
		and not bot:HasModifier('modifier_silencer_curse_of_the_silent')
		then
			return BOT_ACTION_DESIRE_HIGH, ClampLocation(nCastLocation, nCastRange)
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.GetHP(botTarget) > 0.2
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, ClampLocation(botTarget:GetLocation(), nCastRange)
		end
	end

	if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.GetHP(botTarget) > 0.2
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, ClampLocation(botTarget:GetLocation(), nCastRange)
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderTempestDouble()
	X.UpdateDoubleStatus()

	if not TempestDouble:IsFullyCastable()
        or bot:HasModifier('modifier_arc_warden_tempest_double')
        or (npcDouble ~= nil and npcDouble:IsAlive())
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = TempestDouble:GetCastRange()

	if J.IsDefending(bot) or J.IsPushing(bot) or J.IsFarming(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps( 800, true )
		local nEnemyTowers = bot:GetNearbyTowers( 800, true )
		local nCreeps = bot:GetNearbyCreeps( 800, true )

		if J.IsAttacking(bot)
		then
			if (nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2)
			or (nEnemyTowers ~= nil and #nEnemyTowers >= 1)
			or (nCreeps ~= nil and #nCreeps >= 2)
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local target = nil
		local hp = 0
		local nInRangeEnemy = NearbyHeroes(bot,1200, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidHero(enemyHero)
			and J.IsInRange(bot, enemyHero, nCastRange)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			then
				local currHP = enemyHero:GetHealth()
				if hp < currHP
				then
					hp = currHP
					target = enemyHero
				end
			end
		end

		if target ~= nil
		then
			if J.IsRunning(target)
			then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
			else
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.IsInRange(bot, botTarget, 1600)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = NearbyHeroes(botTarget, 1600, true, BOT_MODE_NONE)
			local nInRangeEnemy = NearbyHeroes(botTarget, 1600, false, BOT_MODE_NONE)

			if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly + 1 >= #nInRangeEnemy
			then
				if botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
				then
					return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
				end

				if J.IsInRange(bot, botTarget, bot:GetAttackRange())
				then
					if J.IsRunning(botTarget)
					then
						return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
					else
						return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
					end
				end

				if not J.IsInRange(bot, botTarget, bot:GetAttackRange())
				then
					return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
				end
			end
		end
	end

	local Midas = J.GetComboItem(bot, 'item_hand_of_midas')
	if Midas ~= nil
	and Midas:IsFullyCastable()
	and bot:DistanceFromFountain() > 600
	then
		local nCreeps = bot:GetNearbyCreeps(1600, true)
		if #nCreeps >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
		and J.IsInRange(bot, botTarget, bot:GetAttackRange())
		and J.GetHP(botTarget) > 0.5
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end

	if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, bot:GetAttackRange())
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.UpdateDoubleStatus()
    npcDouble = nil
    if bot:HasModifier('modifier_arc_warden_tempest_double') then return end
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if J.IsValidHero(ally) and ally:IsAlive() and ally:GetPlayerID() == bot:GetPlayerID()
            and ally:HasModifier('modifier_arc_warden_tempest_double') then
            npcDouble = ally
            return
        end
    end
end


return X