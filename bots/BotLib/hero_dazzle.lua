local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

if not J.Utils.GameStates.dazzleNothl then J.Utils.GameStates.dazzleNothl = {[bot:GetPlayerID()] = {body = bot}} end
if not J.Utils.GameStates.dazzleNothl[bot:GetPlayerID()] then J.Utils.GameStates.dazzleNothl[bot:GetPlayerID()] = {body = bot} end

-- Updated to 7.41f from D2PT: positions 5 and 4; forced other roles use pos 5.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/dazzle')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Poison Touch, [2] Shallow Grave, [3] Shadow Wave, [6] Nothl Projection.
-- Both roles share D2PT's most popular first ten levels and talents; later levels are a legal continuation.
local nAbilityBuildList = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +200 Poison Touch attack range
    t15={0,10}, -- +45 Shadow Wave heal/damage
    t20={0,10}, -- -3s Shallow Grave cooldown
    t25={10,0}, -- +1 Weave armor reduction/increase
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
-- Both roles follow the same D2PT core; Holy Locket consumes the Magic Wand.
X.sBuyList = {
    'item_tango', 'item_double_branches', 'item_magic_stick', 'item_ward_sentry', 'item_faerie_fire', 'item_blood_grenade',
    'item_magic_wand', 'item_arcane_boots', 'item_holy_locket', 'item_mekansm', 'item_guardian_greaves',
    'item_glimmer_cape', 'item_aghanims_shard', 'item_blink',
    -- Reviewed utility/upgrade continuation, not additional mandatory D2PT core items.
    'item_aether_lens', 'item_aeon_disk', 'item_overwhelming_blink',
}
X.sSellList = {}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Shadow Wave takes level 10, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

	-- print("dazzle minion")
	-- J.Utils.PrintTable(hMinionUnit)
end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local NothlProjection = bot:GetAbilityByName("dazzle_nothl_projection")
local NothlProjectionEnd = bot:GetAbilityByName("dazzle_nothl_projection_end")

local talent3 = bot:GetAbilityByName( sTalentList[3] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local NothlProjectionDesire, NothlProjectionLocation, NothlProjectionEndDesire

local nMP, nHP, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()

	local isPhysicalBody = bot:HasModifier('modifier_dazzle_nothl_projection_physical_body_debuff')
	if not bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff') then
		J.Utils.GameStates.dazzleNothl[bot:GetPlayerID()].body = bot
	end
	if J.CanNotUseAbility( bot ) or bot:IsInvisible() or isPhysicalBody then return end

	-- Re-fetch ability handles each tick
	abilityQ = bot:GetAbilityByName( sAbilityList[1] )
	abilityW = bot:GetAbilityByName( sAbilityList[2] )
	abilityE = bot:GetAbilityByName( sAbilityList[3] )
	NothlProjection = bot:GetAbilityByName("dazzle_nothl_projection")
	NothlProjectionEnd = bot:GetAbilityByName("dazzle_nothl_projection_end")

	-- Cache per-tick variables
	aetherRange = 0
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 225 end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true, abilityW )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end

	-- Heal a dying or Graved ally before spending a tick on offensive spells.
	local urgentHeal
	castEDesire, castETarget, sMotive, urgentHeal = X.ConsiderE()
	if castEDesire > 0 and urgentHeal then
		J.SetQueuePtToINT(bot, true, abilityE)
		bot:ActionQueue_UseAbilityOnEntity(abilityE, castETarget)
		return
	end

	NothlProjectionEndDesire = X.ConsiderNothlProjectionEnd()
	if NothlProjectionEndDesire > 0 then
		bot:ActionQueue_UseAbility(NothlProjectionEnd)
		return
	end

	NothlProjectionDesire, NothlProjectionLocation = X.ConsiderNothlProjection()
	if NothlProjectionDesire > 0 then
		J.SetQueuePtToINT(bot, true, NothlProjection)
		bot:ActionQueue_UseAbilityOnLocation(NothlProjection, NothlProjectionLocation)
		return
	end

	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end


	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end

end

local function CanSupport(unit)
	return J.IsValid(unit) and not unit:IsInvulnerable()
		and not J.IsSuspiciousIllusion(unit)
		and not unit:HasModifier('modifier_dazzle_nothl_projection_soul_debuff')
end

local function SupportHeroes(range)
	local allies = J.GetAlliesNearLoc(bot:GetLocation(), range)
	-- Include self even when the engine's allied-hero query omits the caster.
	for _, ally in pairs(allies) do
		if ally == bot then return allies end
	end
	table.insert(allies, bot)
	return allies
end

local function IsThreatened(ally)
	return ally:WasRecentlyDamagedByAnyHero(2.0)
		or #J.GetEnemiesNearLoc(ally:GetLocation(), 600) > 0
end

local function ProjectionLocation(target)
	local offset = target:GetLocation() - bot:GetLocation()
	local distance = offset:Length2D()
	if distance <= NothlProjection:GetCastRange() then return target:GetLocation() end
	return bot:GetLocation() + offset:Normalized() * NothlProjection:GetCastRange()
end

function X.ConsiderNothlProjection()
	if not J.CanCastAbility(NothlProjection)
		or bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff')
		or nHP < 0.35 or bot:WasRecentlyDamagedByAnyHero(2.0)
		or #J.GetNearbyHeroes(bot, 600, true, BOT_MODE_NONE) > 0
		or #bot:GetNearbyTowers(900, true) > 0
	then
		return BOT_ACTION_DESIRE_NONE
	end

	-- Reserve mana and reach for the spell that makes this projection useful.
	local manaAfter = bot:GetMana() - NothlProjection:GetManaCost()
	local canGrave = abilityW:IsFullyCastable() and manaAfter >= abilityW:GetManaCost()
	local canWave = abilityE:IsFullyCastable() and manaAfter >= abilityE:GetManaCost()
	local supportRange = NothlProjection:GetCastRange() + aetherRange
		+ math.max(canGrave and abilityW:GetCastRange() or 0, canWave and abilityE:GetCastRange() or 0)
	for _, ally in pairs(SupportHeroes(math.min(supportRange, NothlProjection:GetSpecialValueInt('leash_start')))) do
		if ally ~= bot and CanSupport(ally) and J.GetHP(ally) < 0.6 and IsThreatened(ally)
			and (canGrave or canWave) then
			return BOT_ACTION_DESIRE_HIGH, ProjectionLocation(ally)
		end
	end

	if (J.IsInTeamFight(bot, 1600) or J.IsGoingOnSomeone(bot))
		and J.IsValidHero(botTarget) and J.CanCastOnNonMagicImmune(botTarget)
		and J.CanCastOnTargetAdvanced(botTarget)
		and abilityQ:IsFullyCastable()
		and manaAfter >= abilityQ:GetManaCost()
		and J.IsInRange(bot, botTarget, NothlProjection:GetCastRange() + abilityQ:GetCastRange() + aetherRange)
	then
		return BOT_ACTION_DESIRE_HIGH, ProjectionLocation(botTarget)
	end
	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderNothlProjectionEnd()
	if not bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff')
		or not J.CanCastAbility(NothlProjectionEnd) then return BOT_ACTION_DESIRE_NONE end

	local body = J.Utils.GameStates.dazzleNothl[bot:GetPlayerID()].body
	if J.IsValid(body)
		and (#J.GetEnemiesNearLoc(body:GetLocation(), 600) > 0
			or (J.GetHP(body) < 0.6 and body:WasRecentlyDamagedByAnyHero(2.0))) then
		return BOT_ACTION_DESIRE_HIGH
	end
	if #hEnemyList == 0 then
		for _, ally in pairs(SupportHeroes(1600)) do
			if CanSupport(ally) and J.GetHP(ally) < 0.6 and IsThreatened(ally) then
				return BOT_ACTION_DESIRE_NONE
			end
		end
		return BOT_ACTION_DESIRE_HIGH
	end
	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nManaCost = abilityQ:GetManaCost()
	local nPerDamage = abilityQ:GetSpecialValueInt( "damage" )

	if talent6:IsTrained() then nPerDamage = nPerDamage + talent6:GetSpecialValueInt( "value" ) end

	local nDuration = abilityQ:GetSpecialValueFloat( "duration" )

	local nDamage = nPerDamage * nDuration

	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = nInRangeEnemyList
	local hCastTarget = nil
	local sCastMotive = nil

	-- Projection supplies the hex; Shard now upgrades Weave healing.
	for _, enemy in pairs(nInRangeEnemyList) do
		if bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff')
			and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
			and enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy, 'Q-projection interrupt'
		end
	end

	--击杀
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage, nDamageType )
		then
			hCastTarget = npcEnemy
			sCastMotive = 'Q-击杀:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	-- Lane harass is worth the mana when Dazzle can follow with attacks.
	if J.IsLaning(bot) and not J.IsRetreating(bot) and nMP > 0.55 then
		for _, enemy in pairs(nInRangeEnemyList) do
			if J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
				and J.IsInRange(bot, enemy, bot:GetAttackRange() + abilityQ:GetSpecialValueInt('attack_range_bonus') + 100) then
				return BOT_ACTION_DESIRE_HIGH, enemy, 'Q-lane harass'
			end
		end
	end

	--团战中对血量最低的敌人使用
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				if ( npcEnemyHealth < npcWeakestEnemyHealth )
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = npcEnemy
				end
			end
		end

		if npcWeakestEnemy ~= nil
			and J.IsInRange( bot, npcWeakestEnemy, nCastRange )
		then
			hCastTarget = npcWeakestEnemy
			sCastMotive = 'Q-团战:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.CanCastOnTargetAdvanced( botTarget )
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHP( botTarget ) < 0.43 or nHP <= 0.4
			then
				hCastTarget = botTarget
				sCastMotive = 'Q-进攻:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-撤退时减速:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	--打野
	if J.IsFarming( bot )
		and nSkillLV >= 3
		and #hAllyList <= 1
		and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		local nCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 200 )

		local targetCreep = J.GetMostHpUnit( nCreeps )

		if J.IsValid( targetCreep )
			and not J.IsRoshan( targetCreep )
			and #nCreeps >= 3
			and bot:IsFacingLocation( targetCreep:GetLocation(), 40 )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 1.88, DAMAGE_TYPE_PHYSICAL )
		then
			hCastTarget = targetCreep
			sCastMotive = 'Q-打野'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--推线
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and nSkillLV >= 3 and DotaTime() > 6 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 300, true )
		local targetCreep = nLaneCreeps[3]

		if #nLaneCreeps >= 4
			and J.IsValid( targetCreep )
			and not targetCreep:HasModifier( "modifier_fountain_glyph" )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 1.88, DAMAGE_TYPE_PHYSICAL )
		then
			hCastTarget = targetCreep
			sCastMotive = 'Q-推线'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan( botTarget )
        and J.CanBeAttacked(botTarget)
        and J.IsInRange( botTarget, bot, nCastRange )
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor( botTarget )
        and J.IsInRange( botTarget, bot, nCastRange )
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end


	--常规
	if ( #hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nSkillLV >= 4 and not J.IsLaning(bot)
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-常规:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end



	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()
	if not abilityW:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
	local range = abilityW:GetCastRange() + aetherRange
	local best, bestScore, motive = nil, -1, nil
	for _, ally in pairs(SupportHeroes(range)) do
		if J.IsValidHero(ally) and CanSupport(ally) and J.IsInRange(bot, ally, range)
			and not ally:HasModifier('modifier_dazzle_shallow_grave') then
			local incoming = 0
			for _, projectile in pairs(ally:GetIncomingTrackingProjectiles()) do
				if projectile.is_attack and J.IsValid(projectile.caster)
					and GetUnitToLocationDistance(ally, projectile.location) < 1600 then
					incoming = incoming + ally:GetActualIncomingDamage(projectile.caster:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL)
				end
			end
			local threatened = IsThreatened(ally)
			local predicted = X.GetEnemyFacingAllyDamage(ally, 1100, abilityW:GetCastPoint() + 0.75)
			local lethal = incoming >= ally:GetHealth() or predicted >= ally:GetHealth()
			if lethal or (J.GetHP(ally) <= 0.3 and threatened) then
				local score = (lethal and 2 or 1) + (1 - J.GetHP(ally))
				if score > bestScore then
					best, bestScore = ally, score
					motive = lethal and 'W-incoming lethal damage' or 'W-low health under threat'
				end
			end
		end
	end
	if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best, motive end
	return BOT_ACTION_DESIRE_NONE
end

local function WaveAmount()
	local amount = abilityE:GetSpecialValueInt('damage')
	if talent3:IsTrained() then amount = amount + talent3:GetSpecialValueInt('value') end
	return amount
end

local function CanHeal(unit)
	return CanSupport(unit) and not unit:HasModifier('modifier_ice_blast')
end

-- All sources near one enemy fit inside the bounce radius. Dazzle heals automatically;
-- only max_targets other units can bounce, even in a large creep or summon pack.
local function WaveSources(enemy, radius)
	local sources, count, selfHit = {}, 0, false
	local units = J.CombineTwoTable(bot:GetNearbyCreeps(1600, false), SupportHeroes(1600))
	local seen = {}
	for _, unit in pairs(units) do
		if not seen[unit] and CanSupport(unit) and J.IsInRange(enemy, unit, radius) then
			seen[unit] = true
			if unit == bot then selfHit = true else count = count + 1 end
			table.insert(sources, unit)
		end
	end
	return sources, math.min(count, abilityE:GetSpecialValueInt('max_targets')) + (selfHit and 1 or 0)
end

function X.ConsiderE()
	if not abilityE:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
	local range = abilityE:GetCastRange() + aetherRange
	local amount = WaveAmount()
	local urgent, routine, urgentScore, routineScore = nil, nil, -1, -1
	for _, ally in pairs(SupportHeroes(range)) do
		if J.IsValidHero(ally) and CanHeal(ally) and J.IsInRange(bot, ally, range) then
			local missing = ally:GetMaxHealth() - ally:GetHealth()
			local hp = J.GetHP(ally)
			local graved = ally:HasModifier('modifier_dazzle_shallow_grave')
			if hp < 0.35 or (graved and hp < 0.6) then
				local score = 1 - hp + (graved and 1 or 0)
				if score > urgentScore then urgent, urgentScore = ally, score end
			elseif hp < 0.75 and missing >= amount
				and (ally:WasRecentlyDamagedByAnyHero(3.0) or J.IsAllowedToSpam(bot, abilityE:GetManaCost())) then
				if 1 - hp > routineScore then routine, routineScore = ally, 1 - hp end
			end
		end
	end
	if urgent ~= nil then return BOT_ACTION_DESIRE_HIGH, urgent, 'E-emergency heal', true end
	if routine ~= nil then return BOT_ACTION_DESIRE_HIGH, routine, 'E-support heal' end

	local radius = abilityE:GetSpecialValueInt('damage_radius')
	for _, enemy in pairs(hEnemyList) do
		if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy) then
			-- Scepter allows the initial Wave to target an enemy directly.
			if bot:HasScepter() and J.IsInRange(bot, enemy, range)
				and J.CanCastOnTargetAdvanced(enemy)
				and (J.CanKillTarget(enemy, amount, DAMAGE_TYPE_PHYSICAL)
					or ((J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200))
						and #J.GetEnemiesNearLoc(enemy:GetLocation(), abilityE:GetSpecialValueInt('bounce_radius')) >= 2
						and J.IsAllowedToSpam(bot, abilityE:GetManaCost()))) then
				return BOT_ACTION_DESIRE_HIGH, enemy, 'E-scepter enemy wave'
			end
			local target = X.GetBestHealTarget(enemy, radius)
			if target ~= nil then
				local damage = X.GetAbilityEMaxDamage(enemy)
				if J.CanKillTarget(enemy, damage, DAMAGE_TYPE_PHYSICAL)
					or ((J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200) or J.IsLaning(bot))
					and damage >= amount * 2 and J.IsAllowedToSpam(bot, abilityE:GetManaCost())) then
					return BOT_ACTION_DESIRE_HIGH, target, 'E-clustered physical damage'
				end
			end
		end
	end

	-- Sustain a pushing wave without spending support mana to farm the lane.
	if (J.IsPushing(bot) or J.IsDefending(bot)) and #hEnemyList == 0
		and J.IsAllowedToSpam(bot, abilityE:GetManaCost()) then
		local creeps = bot:GetNearbyLaneCreeps(range, false)
		local bounce = abilityE:GetSpecialValueInt('bounce_radius')
		for _, creep in pairs(creeps) do
			if CanHeal(creep) and J.IsInRange(bot, creep, range) then
				local count = 0
				for _, other in pairs(creeps) do
					if CanHeal(other) and J.IsInRange(creep, other, bounce)
						and other:GetMaxHealth() - other:GetHealth() >= amount then count = count + 1 end
				end
				if count >= 3 then return BOT_ACTION_DESIRE_HIGH, creep, 'E-pushing wave sustain' end
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE
end

function X.GetBestHealTarget(enemy, radius)
	local sources = WaveSources(enemy, radius)
	local best, missing = nil, -1
	for _, unit in pairs(sources) do
		if J.IsInRange(bot, unit, abilityE:GetCastRange() + aetherRange)
			and unit:GetMaxHealth() - unit:GetHealth() > missing then
			best, missing = unit, unit:GetMaxHealth() - unit:GetHealth()
		end
	end
	return best
end

function X.GetAbilityEMaxDamage(enemy)
	local _, count = WaveSources(enemy, abilityE:GetSpecialValueInt('damage_radius'))
	return count * WaveAmount()
end

function X.GetEnemyFacingAllyDamage(ally, radius, delay)
	local total = 0
	for _, enemy in pairs(J.GetEnemyList(ally, radius)) do
		if enemy:GetAttackTarget() == ally or enemy:IsFacingLocation(ally:GetLocation(), 15) then
			total = total + enemy:GetEstimatedDamageToTarget(false, ally, delay, DAMAGE_TYPE_ALL)
		end
	end
	return total
end

return X
