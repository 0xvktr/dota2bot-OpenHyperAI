local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: hard support, offlane and support; skipped roles use pos 5 without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/elder_titan')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Echo Stomp, [2] Astral Spirit, [3] Natural Order, [6] Earth Splitter.
local nAbilityBuildList, nTalentBuildList
if sRole == 'pos_3' then
    -- D2PT offlane delays Earth Splitter past level 10.
    nAbilityBuildList = {2,3,2,3,2,3,2,3,1,1,6,1,1,6,6}
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={0,10}, -- +2.5% Astral Spirit move speed per hero
        t15={10,0}, -- Momentum grants 20% attack speed
        t20={0,10}, -- +30 Astral Spirit hero attack damage
        t25={10,0}, -- 100% cleave
    })
else
    nAbilityBuildList = {2,3,2,1,1,6,1,1,3,3,6,3,2,2,6}
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={10,0}, -- +150 Echo Stomp wake damage threshold
        t15={0,10}, -- +75 Echo Stomp damage
        t20=sRole == 'pos_4' and {0,10} or {10,0}, -- +30 Spirit hero damage / +150 Natural Order radius
        t25=sRole == 'pos_4' and {10,0} or {0,10}, -- 100% cleave / -60s Earth Splitter cooldown
    })
end
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_3' then
    X.sBuyList = {'item_quelling_blade', 'item_tango', 'item_enchanted_mango', 'item_blight_stone',
        'item_phase_boots', 'item_lifesteal', 'item_soul_ring', 'item_mask_of_madness',
        'item_ultimate_scepter', 'item_echo_sabre', 'item_aghanims_shard', 'item_lesser_crit',
        'item_harpoon', 'item_greater_crit',
        -- Bot policy: Blessing and late BKB/Nullifier.
        'item_ultimate_scepter_2', 'item_black_king_bar', 'item_nullifier'}
    X.sSellList = {'item_echo_sabre', 'item_quelling_blade', 'item_lesser_crit', 'item_blight_stone',
        'item_black_king_bar', 'item_soul_ring'}
elseif sRole == 'pos_4' then
    X.sBuyList = {'item_boots', 'item_ward_observer', 'item_ward_sentry', 'item_blood_grenade',
        'item_tranquil_boots', 'item_magic_wand', 'item_soul_ring', 'item_ancient_janggo',
        'item_cyclone', 'item_aghanims_shard', 'item_boots_of_bearing', 'item_ultimate_scepter',
        -- Bot policy: late positioning and natural upgrades.
        'item_force_staff', 'item_ultimate_scepter_2', 'item_wind_waker'}
    X.sSellList = {'item_force_staff', 'item_magic_wand'}
else
    X.sBuyList = {'item_boots', 'item_tango',
        'item_tranquil_boots', 'item_magic_wand', 'item_ancient_janggo', 'item_cyclone',
        'item_aghanims_shard', 'item_boots_of_bearing',
        -- Bot policy: Force Staff, Scepter and Wind Waker.
        'item_force_staff', 'item_ultimate_scepter', 'item_ultimate_scepter_2', 'item_wind_waker'}
    X.sSellList = {'item_ultimate_scepter', 'item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT spends level 10 on an ability; first talent comes at 11. Preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

local EchoStomp             = bot:GetAbilityByName('elder_titan_echo_stomp')
local AstralSpirit          = bot:GetAbilityByName('elder_titan_ancestral_spirit')
local MoveAstralSpirit      = bot:GetAbilityByName('elder_titan_move_spirit')
local ReturnAstralSpirit    = bot:GetAbilityByName('elder_titan_return_spirit')
local NaturalOrder          = bot:GetAbilityByName('elder_titan_natural_order')
local EarthSplitter         = bot:GetAbilityByName('elder_titan_earth_splitter')

local botTarget
local nEnemyHeroes, nAllyHeroes

local touchedUnits = { }
bot.theAstralSpirit = nil
local targetTouchUnits = nil

-- Helper: check if enemy is in Chronosphere or Black Hole
local function IsInChronoOrBlackHole(enemy)
	return enemy:HasModifier('modifier_faceless_void_chronosphere_freeze')
		or enemy:HasModifier('modifier_enigma_black_hole_pull')
end

-- Helper: check if enemy is in Chrono/BH with enough remaining duration for combo
local function IsInChronoOrBlackHoleWithDuration(enemy, minDuration)
	local modifiers = {
		'modifier_faceless_void_chronosphere_freeze',
		'modifier_enigma_black_hole_pull',
	}
	for _, modName in pairs(modifiers) do
		local modIdx = enemy:GetModifierByName(modName)
		if modIdx ~= -1 then
			local remaining = enemy:GetModifierRemainingDuration(modIdx)
			if remaining >= minDuration then
				return true
			end
		end
	end
	return false
end

function X.MinionThink(hMinionUnit)
	-- Re-fetch ability handles each tick
	EchoStomp          = bot:GetAbilityByName('elder_titan_echo_stomp')
	ReturnAstralSpirit = bot:GetAbilityByName('elder_titan_return_spirit')

	if J.Utils.IsUnitWithName(hMinionUnit, 'elder_titan_ancestral_spirit') and SpiritShouldBeAvailable() then
        bot.theAstralSpirit = hMinionUnit

		if EchoStomp:IsInAbilityPhase() or bot:IsChanneling() then bot:Action_ClearActions(false); return end
		if bot:IsUsingAbility() or bot:IsCastingAbility() then return end
		if hMinionUnit:IsUsingAbility() or hMinionUnit:IsCastingAbility() then return end

        if ConsiderEchoStomp(bot.theAstralSpirit) > 0 then
            bot:Action_UseAbility(EchoStomp)
            return
        end

		if ConsiderReturnMinion() > 0 then
			bot:Action_UseAbility(ReturnAstralSpirit)
            return
        end
	end

    Minion.MinionThink(hMinionUnit)
end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) or bot:IsCastingAbility() or bot:IsChanneling() then return end

	-- Re-fetch ability handles each tick
	EchoStomp          = bot:GetAbilityByName('elder_titan_echo_stomp')
	AstralSpirit       = bot:GetAbilityByName('elder_titan_ancestral_spirit')
	MoveAstralSpirit   = bot:GetAbilityByName('elder_titan_move_spirit')
	ReturnAstralSpirit = bot:GetAbilityByName('elder_titan_return_spirit')
	NaturalOrder       = bot:GetAbilityByName('elder_titan_natural_order')
	EarthSplitter      = bot:GetAbilityByName('elder_titan_earth_splitter')

	-- Cache per-tick variables
    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)

    botTarget = J.GetProperTarget(bot)

	if ConsiderEchoStomp(bot) > 0 then
		bot:Action_UseAbility(EchoStomp)
		return
	end

    local AstralSpiritDesire, AstralSpiritLocation = ConsiderAstralSpirit()
    if AstralSpiritDesire > 0 then
		J.SetQueuePtToINT(bot, false)
		touchedUnits = { }
        targetTouchUnits = nil
		bot:ActionQueue_UseAbilityOnLocation(AstralSpirit, AstralSpiritLocation)
    end

    local EarthSplitterDesire, EarthSplitterLocation = ConsiderEarthSplitter()
    if EarthSplitterDesire > 0 then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnLocation(EarthSplitter, EarthSplitterLocation)
    end

    local castMoveAstralSpiritDesire, castMoveAstralSpiritLocation = ConsiderMoveAstralSpirit();
	if castMoveAstralSpiritDesire > 0
    then
        bot:Action_UseAbilityOnLocation(MoveAstralSpirit, castMoveAstralSpiritLocation);
        return;
    end
end

function ConsiderAstralSpirit()
	if not AstralSpirit:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    if bot:IsUsingAbility() or bot:IsCastingAbility() then return BOT_ACTION_DESIRE_NONE end
	if bot:HasModifier('modifier_elder_titan_ancestral_spirit_buff') then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = AstralSpirit:GetSpecialValueInt('AbilityCastRange')

	if J.IsValidTarget(botTarget) and (J.IsInTeamFight(bot, 1600) or J.IsGoingOnSomeone(bot) or J.IsPushing(bot))
	then
        if J.IsInRange(bot, botTarget, nCastRange) then
			local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, 500, 0, 0)
			if locationAoE.count >= #nEnemyHeroes - 1 then
                return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
			end
        end
	end
	return BOT_ACTION_DESIRE_NONE
end

function SpiritShouldBeAvailable()
    return not ReturnAstralSpirit:IsHidden() and ReturnAstralSpirit:GetCooldownTimeRemaining() == 0
end

function ConsiderMoveAstralSpirit()
    if not MoveAstralSpirit:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    if not SpiritShouldBeAvailable() then return BOT_ACTION_DESIRE_NONE end
    if bot.theAstralSpirit == nil then return BOT_ACTION_DESIRE_NONE end

    if targetTouchUnits == nil then
        local enemyCreeps = bot:GetNearbyCreeps(1600, true);
        targetTouchUnits = J.Utils.CombineTablesUnique(nEnemyHeroes, enemyCreeps)
    end

    if targetTouchUnits ~= nil then
        if #targetTouchUnits >= 1 and #touchedUnits < #targetTouchUnits then
            for i, enemy in pairs(targetTouchUnits)
            do
                if J.IsValid(enemy)
                and (not J.Utils.HasValue(touchedUnits, enemy))
                and J.Utils.GetLocationToLocationDistance(bot.theAstralSpirit:GetLocation(), enemy:GetLocation()) > 30 then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                else
                    table.remove(targetTouchUnits, i)
                    table.insert(touchedUnits, enemy)
                end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function ConsiderEarthSplitter()
	if not EarthSplitter:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    if bot:IsUsingAbility() or bot:IsCastingAbility() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = EarthSplitter:GetCastRange()
    local crack_width = 300
    local crack_time = 3.14

	if J.IsInTeamFight(bot, 1600) or J.IsGoingOnSomeone(bot) or J.IsPushing(bot)
	then
		-- Check for enemies caught in Chronosphere/Black Hole with enough remaining duration
		for _, npcEnemy in pairs(nEnemyHeroes) do
			if J.IsValidHero(npcEnemy)
			and J.CanCastOnNonMagicImmune(npcEnemy)
			and J.IsInRange(bot, npcEnemy, nCastRange)
			and IsInChronoOrBlackHoleWithDuration(npcEnemy, 1.8)
			then
				return BOT_ACTION_DESIRE_VERYHIGH, npcEnemy:GetLocation()
			end
		end

		local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, crack_width, crack_time, 1500)
		local nHeroesInAoE = J.GetHeroesNearLocation(true, locationAoE.targetloc, 800)
        if #nHeroesInAoE >= 3 then
            return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
        end

		-- Require at least 1 core hero when hitting 2+ enemies
		if #nHeroesInAoE >= 2 then
			local bHasCore = false
			for _, enemy in pairs(nHeroesInAoE) do
				if J.IsValidHero(enemy) and J.IsCore(enemy) then
					bHasCore = true
					break
				end
			end
			if bHasCore then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
			end
		end

        if J.IsValidHero( botTarget )
			and #nEnemyHeroes >= #nAllyHeroes
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanKillTarget( botTarget, botTarget:GetMaxHealth() * 0.4, DAMAGE_TYPE_MAGICAL )
		then
            local loc = J.GetCorrectLoc(botTarget, crack_time)
			return BOT_ACTION_DESIRE_HIGH, loc
		end

	end
	return BOT_ACTION_DESIRE_NONE
end

function ConsiderReturnMinion()
    if bot:IsUsingAbility() or bot:IsCastingAbility() then return BOT_ACTION_DESIRE_NONE end

    if targetTouchUnits ~= nil and #touchedUnits >= #targetTouchUnits * 0.7 then
        return BOT_ACTION_DESIRE_HIGH
    end

	return BOT_ACTION_DESIRE_NONE
end

function ConsiderEchoStomp(eveluator)
	if not EchoStomp:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end

	local nRadius = EchoStomp:GetSpecialValueInt("radius");
	local nDamage = EchoStomp:GetSpecialValueInt("stomp_damage");

	if eveluator == nil then eveluator = bot end
	local nInEchoRangeEnemyHeroes = eveluator:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)

	for _, npcEnemy in pairs(nInEchoRangeEnemyHeroes) do
		if npcEnemy:IsChanneling() -- 打断技能
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	-- Only stomp enemies that are disabled, slow, or caught in Chrono/Black Hole
	local nStompableEnemies = 0
	for _, npcEnemy in pairs(nInEchoRangeEnemyHeroes) do
		if J.IsValidHero(npcEnemy)
		and ( J.IsDisabled(npcEnemy)
			or npcEnemy:GetCurrentMovementSpeed() <= 250
			or IsInChronoOrBlackHole(npcEnemy) )
		then
			nStompableEnemies = nStompableEnemies + 1
		end
	end

	if nStompableEnemies >= 3 then
        return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsRetreating(bot)
	then
		for _, npcEnemy in pairs(nInEchoRangeEnemyHeroes) do
			if J.IsValidHero(npcEnemy) and bot:WasRecentlyDamagedByHero(npcEnemy, 2)
			then
				if J.CanCastOnNonMagicImmune(npcEnemy)
				and ( J.IsDisabled(npcEnemy)
					or npcEnemy:GetCurrentMovementSpeed() <= 250
					or IsInChronoOrBlackHole(npcEnemy) )
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

	if J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot) or J.IsPushing(bot) or J.IsDefending(bot)
	then
		if J.IsValidHero(botTarget)
		and J.IsChasingTarget(bot, botTarget)
		and J.IsInRange(eveluator, botTarget, nRadius)
		and ( J.IsDisabled(botTarget)
			or botTarget:GetCurrentMovementSpeed() <= 250
			or IsInChronoOrBlackHole(botTarget) )
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		-- AoE check: only count stompable enemies
		local nAoEStompable = 0
		for _, npcEnemy in pairs(nInEchoRangeEnemyHeroes) do
			if J.IsValidHero(npcEnemy)
			and ( J.IsDisabled(npcEnemy)
				or npcEnemy:GetCurrentMovementSpeed() <= 250
				or IsInChronoOrBlackHole(npcEnemy) )
			then
				nAoEStompable = nAoEStompable + 1
			end
		end
		if nAoEStompable >= 3 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X