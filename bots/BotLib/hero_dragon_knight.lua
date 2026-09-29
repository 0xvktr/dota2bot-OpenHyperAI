----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: carry, mid and offlane; forced supports use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/dragon_knight')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Breathe Fire, [2] Dragon Tail, [3] Wyrm's Wrath, [6] Elder Dragon Form.
local nAbilityBuildList = sRole == 'pos_2'
    and {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
    or {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10=sRole == 'pos_1' and {0,10} or {10,0}, -- +15 damage (carry), -2s Breathe Fire cooldown (mid/offlane)
    t15={10,0}, -- +300 Health
    t20={10,0}, -- +220 Breathe Fire damage
    t25={10,0}, -- +50% Wyrm's Wrath damage/area
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_1' then
    X.sBuyList = {
        'item_quelling_blade', 'item_gauntlets', 'item_branches', 'item_magic_stick', 'item_tango',
        'item_bracer', 'item_magic_wand', 'item_soul_ring', 'item_power_treads', 'item_radiance',
        'item_blink', 'item_aghanims_shard', 'item_black_king_bar', 'item_octarine_core',
        -- Bot policy: Scepter/Blessing, Shiva and Overwhelming Blink.
        'item_ultimate_scepter', 'item_ultimate_scepter_2', 'item_shivas_guard', 'item_overwhelming_blink',
    }
else
    if sRole == 'pos_2' then
        -- Omit the observed ward: core bots do not run ward placement. Condense double Bracer to one.
        X.sBuyList = {'item_double_gauntlets','item_double_branches','item_branches','item_circlet'}
    else
        X.sBuyList = {'item_double_gauntlets','item_double_branches','item_magic_stick'}
    end
    local core = {
        'item_bracer', 'item_magic_wand', 'item_soul_ring', 'item_power_treads', 'item_blink',
        'item_aghanims_shard', 'item_black_king_bar', 'item_octarine_core', 'item_shivas_guard',
        -- Bot policy: Scepter/Blessing and Overwhelming Blink.
        'item_ultimate_scepter', 'item_ultimate_scepter_2', 'item_overwhelming_blink',
    }
    for _, item in ipairs(core) do table.insert(X.sBuyList, item) end
end
X.sSellList = {
    'item_black_king_bar','item_magic_wand', 'item_octarine_core','item_soul_ring',
    'item_shivas_guard','item_bracer',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Wyrm's Wrath point at 10, then the first talent at 11. Preserve custom progressions.
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

--[[

npc_dota_hero_dragon_knight

"Ability1"		"dragon_knight_breathe_fire"
"Ability2"		"dragon_knight_dragon_tail"
"Ability3"		"dragon_knight_dragon_blood"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"dragon_knight_elder_dragon_form"
"Ability10"		"special_bonus_mp_regen_3"
"Ability11"		"special_bonus_unique_dragon_knight_3"
"Ability12"		"special_bonus_attack_damage_30"
"Ability13"		"special_bonus_hp_350"
"Ability14"		"special_bonus_gold_income_30"
"Ability15"		"special_bonus_strength_25"
"Ability16"		"special_bonus_unique_dragon_knight"
"Ability17"		"special_bonus_unique_dragon_knight_2"

modifier_dragonknight_breathefire_reduction
modifier_dragon_knight_dragon_blood_aura
modifier_dragon_knight_dragon_blood
modifier_dragon_knight_dragon_form
modifier_dragon_knight_corrosive_breath
modifier_dragon_knight_corrosive_breath_dot
modifier_dragon_knight_splash_attack
modifier_dragon_knight_frost_breath
modifier_dragon_knight_frost_breath_slow

--]]
local BreatheFire = bot:GetAbilityByName('dragon_knight_breathe_fire')
local DragonTail = bot:GetAbilityByName('dragon_knight_dragon_tail')
-- local WrymsWrath = bot:GetAbilityByName('dragon_knight_dragon_blood')
local Fireball = bot:GetAbilityByName('dragon_knight_fireball')
local ElderDragonForm = bot:GetAbilityByName('dragon_knight_elder_dragon_form')

local BreatheFireDesire, BreatheFireLocation
local DragonTailDesire, DragonTailTarget
local FireballDesire, FireballLocation
local ElderDragonFormDesire

local bInDragonForm = false
local bAttacking = false
local botTarget, botHP
local nAllyHeroes, nEnemyHeroes

function X.SkillsComplement()
	bot = GetBot()

	if J.CanNotUseAbility(bot) then return end

	BreatheFire = bot:GetAbilityByName('dragon_knight_breathe_fire')
	DragonTail = bot:GetAbilityByName('dragon_knight_dragon_tail')
	Fireball = bot:GetAbilityByName('dragon_knight_fireball')
	ElderDragonForm = bot:GetAbilityByName('dragon_knight_elder_dragon_form')

	bInDragonForm = bot:HasModifier('modifier_dragon_knight_dragon_form')
	bAttacking = J.IsAttacking(bot)
    botHP = J.GetHP(bot)
    botTarget = J.GetProperTarget(bot)
    nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	ElderDragonFormDesire = X.ConsiderElderDragonForm()
	if ElderDragonFormDesire> 0 then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbility(ElderDragonForm)
		return
	end

	BreatheFireDesire, BreatheFireLocation = X.ConsiderBreatheFire()
	if BreatheFireDesire > 0 then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnLocation(BreatheFire, BreatheFireLocation)
		return
	end

	DragonTailDesire, DragonTailTarget = X.ConsiderDragonTail()
	if DragonTailDesire > 0 then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnEntity(DragonTail, DragonTailTarget)
		return
	end

	FireballDesire, FireballLocation = X.ConsiderFireball()
	if FireballDesire > 0 then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnLocation(Fireball, FireballLocation)
		return
	end
end

function X.ConsiderBreatheFire()
	if not J.CanCastAbility(BreatheFire) then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, BreatheFire:GetCastRange())
	local nCastPoint = BreatheFire:GetCastPoint()
	local nRadius = BreatheFire:GetSpecialValueInt('end_radius')
	local nDamage = BreatheFire:GetSpecialValueInt('damage')
	local nSpeed = BreatheFire:GetSpecialValueInt('speed')
	local nManaCost = BreatheFire:GetManaCost()
	local fManaAfter = J.GetManaAfter(nManaCost)
	local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {BreatheFire, DragonTail, Fireball, ElderDragonForm})
	local fManaThreshold2 = J.GetManaThreshold(bot, nManaCost, {DragonTail, ElderDragonForm})

	for _, enemyHero in pairs(nEnemyHeroes) do
		if J.IsValidHero(enemyHero)
		and J.CanBeAttacked(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange + 150)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
		then
			local eta = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
			if J.WillKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL, eta) then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
			end
		end
	end

	if J.IsInTeamFight(bot, 1200) then
		local hTarget = nil
		local hTargetDamage = 0
		for _, enemyHero in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero)
			and J.CanBeAttacked(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange - 150)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
			and not enemyHero:HasModifier('modifier_dragonknight_breathefire_reduction')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			then
				local enemyHeroDamage = enemyHero:GetEstimatedDamageToTarget(false, bot, 3.0, DAMAGE_TYPE_PHYSICAL)
				if enemyHeroDamage > hTargetDamage then
					hTarget = enemyHero
					hTargetDamage = enemyHeroDamage
				end
			end
		end

		if hTarget ~= nil then
			return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(hTarget, nCastPoint)
		end

		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius - 30, 0, 0)
		if nLocationAoE.count >= 2 and fManaAfter > fManaThreshold2 then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
		and J.CanBeAttacked(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange - 150)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_dragonknight_breathefire_reduction')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		then
			if J.CanCastAbility(ElderDragonForm) then
				if fManaAfter > fManaThreshold2 then
					return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, nCastPoint)
				end
			else
				return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, nCastPoint)
			end
		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(4.0) then
		for _, enemyHero in pairs(nEnemyHeroes) do
            if  J.IsValidHero(enemyHero)
            and J.CanBeAttacked(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not enemyHero:IsDisarmed()
			and not enemyHero:HasModifier('modifier_dragonknight_breathefire_reduction')
            then
                if J.IsChasingTarget(enemyHero, bot) or (#nEnemyHeroes > #nAllyHeroes and enemyHero:GetAttackTarget() == bot) then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end

		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange - 100, nRadius, 0, 0)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
		if #nInRangeEnemy >= 2 then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	local nEnemyCreeps = bot:GetNearbyCreeps(Min(nCastRange + 300, 1600), true)

	if J.IsPushing(bot) and bAttacking and #nAllyHeroes <= 2 and fManaAfter > fManaThreshold1 and not bInDragonForm then
		for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 4) then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
	end

	if J.IsDefending(bot) and bAttacking and #nEnemyHeroes == 0 and fManaAfter > fManaThreshold1 and not bInDragonForm then
		for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 4) then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
	end

	if J.IsFarming(bot) and bAttacking and fManaAfter > fManaThreshold2 then
		for _, creep in pairs(nEnemyCreeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep) and not J.IsRunning(creep) then
                local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, 0)
                if (nLocationAoE.count >= 3 and not bInDragonForm)
				or (nLocationAoE.count >= 2 and creep:IsAncientCreep())
				or (nLocationAoE.count >= 2 and fManaAfter > fManaThreshold1)
				then
                    return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
                end
            end
        end
	end

	if J.IsLaning(bot) and not J.IsInLaningPhase() and fManaAfter > fManaThreshold2 then
		for _, creep in ipairs(nEnemyCreeps) do
			if  J.IsValid(creep)
			and J.CanBeAttacked(creep)
			and (string.find(creep:GetUnitName(), 'range') or string.find(creep:GetUnitName(), 'flagbearer') or string.find(creep:GetUnitName(), 'siege'))
			then
				local eta = (GetUnitToUnitDistance(bot, creep) / nSpeed) + nCastPoint
				if J.WillKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL, eta) then
					if (J.IsValidHero(nEnemyHeroes[1]) and J.IsInRange(nEnemyHeroes[1], creep, nRadius) and not J.IsSuspiciousIllusion(nEnemyHeroes[1]))
					or J.IsUnitTargetedByTower(creep, false)
					then
						return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
					end
				end
			end
		end

		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage)
		if nLocationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end
	end

	if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.CanCastOnNonMagicImmune(botTarget)
		and not botTarget:HasModifier('modifier_dragonknight_breathefire_reduction')
        and bAttacking
		and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not botTarget:HasModifier('modifier_dragonknight_breathefire_reduction')
        and bAttacking
		and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	if fManaAfter > fManaThreshold2 and not J.IsLateGame() and bAttacking and not bInDragonForm then
		for _, creep in ipairs(nEnemyCreeps) do
			if J.IsValid(creep)
			and J.CanBeAttacked(creep)
			and not J.IsRunning(creep)
			then
				local nLocationAoE = bot:FindAoELocation(true, false, creep:GetLocation(), 0, nRadius, 0, nDamage)
				if (nLocationAoE.count >= 3) then
					return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderDragonTail()
	if not J.CanCastAbility(DragonTail) then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, DragonTail:GetCastRange())
	local nDamage = DragonTail:GetSpecialValueInt('damage')
	local nSpeed = DragonTail:GetSpecialValueInt('projectile_speed')
	local nManaCost = DragonTail:GetManaCost()
	local fManaAfter = J.GetManaAfter(nManaCost)
	local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {ElderDragonForm})

	for _, enemyHero in pairs(nEnemyHeroes) do
		if J.IsValidHero(enemyHero)
		and J.CanBeAttacked(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange + 300)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			if enemyHero:HasModifier('modifier_teleporting') then
				local fModifierTime = J.GetModifierTime(enemyHero, 'modifier_teleporting')
				if not bInDragonForm then
					local eta = GetUnitToUnitDistance(bot, enemyHero) / bot:GetCurrentMovementSpeed()
					if eta < fModifierTime then
						return BOT_ACTION_DESIRE_HIGH, enemyHero
					end
				else
					local eta = GetUnitToUnitDistance(bot, enemyHero) / nSpeed
					if eta < fModifierTime then
						return BOT_ACTION_DESIRE_HIGH, enemyHero
					end
				end
			elseif enemyHero:IsChanneling() then
				if fManaAfter > fManaThreshold1 then
					return BOT_ACTION_DESIRE_HIGH, enemyHero
				end
			end

			local eta = GetUnitToUnitDistance(bot, enemyHero) / bot:GetCurrentMovementSpeed()
			if bInDragonForm then
				eta = GetUnitToUnitDistance(bot, enemyHero) / nSpeed
			end

			if not J.CanCastAbility(BreatheFire) then
				if J.WillKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL, eta)
				and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
				and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
				and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
				and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero
				end
			end
		end
	end

	if J.IsInTeamFight(bot, 1200) then
		-- fire dragon
		if bInDragonForm and true then
			for _, enemyHero in pairs(nEnemyHeroes) do
				if J.IsValidHero(enemyHero)
				and J.CanBeAttacked(enemyHero)
				and J.IsInRange(bot, enemyHero, nCastRange + 300)
				and J.CanCastOnNonMagicImmune(enemyHero)
				and J.CanCastOnTargetAdvanced(enemyHero)
				and not enemyHero:IsDisarmed()
				and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
				and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
				and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				then
					local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetLocation(), 100)
					if #nInRangeEnemy >= 2 then
						return BOT_ACTION_DESIRE_HIGH, enemyHero
					end
				end
			end
		end

		local hTarget = nil
		local hTargetDamage = 0
		for _, enemyHero in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero)
			and J.CanBeAttacked(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange + 300)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:IsDisarmed()
			and not enemyHero:HasModifier('modifier_dragonknight_breathefire_reduction')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			then
				local enemyHeroDamage = enemyHero:GetEstimatedDamageToTarget(false, bot, 3.0, DAMAGE_TYPE_ALL)
				if enemyHeroDamage > hTargetDamage then
					hTarget = enemyHero
					hTargetDamage = enemyHeroDamage
				end
			end
		end

		if hTarget ~= nil then
			return BOT_ACTION_DESIRE_HIGH, hTarget
		end
	end

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange + 300)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.CanCastOnTargetAdvanced(botTarget)
		and not J.IsDisabled(botTarget)
		and not botTarget:IsDisarmed()
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end


	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
		for _, enemyHero in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange + 300)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
			and not J.IsDisabled(enemyHero)
            and not enemyHero:IsDisarmed()
			and not enemyHero:HasModifier('modifier_dragonknight_breathefire_reduction')
			then
				if J.IsChasingTarget(enemyHero, bot)
				or #nEnemyHeroes > #nAllyHeroes and enemyHero:GetAttackTarget() == bot
				or botHP < 0.5
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero
				end
			end
		end
	end

	if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.CanCastOnTargetAdvanced(botTarget)
		and not botTarget:HasModifier('modifier_dragonknight_breathefire_reduction')
        and bAttacking
		and fManaAfter > 0.4
		and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not botTarget:HasModifier('modifier_dragonknight_breathefire_reduction')
        and bAttacking
		and fManaAfter > 0.4
		and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderFireball()
	if not J.CanCastAbility(Fireball) then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, Fireball:GetCastRange())
    local nRadius = Fireball:GetSpecialValueInt('radius')
	local nManaCost = Fireball:GetManaCost()
	local fManaAfter = J.GetManaAfter(nManaCost)
	local fManaThreshold1 = J.GetManaThreshold(bot, nManaCost, {ElderDragonForm})

    if J.IsInTeamFight(bot, 1200) then
        local vLocation = J.GetAoeEnemyHeroLocation(bot, nCastRange, nRadius, 2)
        if vLocation ~= nil and fManaAfter > fManaThreshold1 then
            return BOT_ACTION_DESIRE_HIGH, vLocation
        end
    end

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidHero(botTarget)
		and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.CanCastOnNonMagicImmune(botTarget)
		and J.GetHP(botTarget) > 0.15
		and not J.IsChasingTarget(bot, botTarget)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		and fManaAfter > fManaThreshold1
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) then
		for _, enemyHero in pairs(nEnemyHeroes) do
			if J.IsValidHero(enemyHero)
			and J.CanBeAttacked(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange - 100)
            and J.CanCastOnNonMagicImmune(enemyHero)
			and J.GetHP(enemyHero) < 0.5
			and not J.IsDisabled(enemyHero)
            and not enemyHero:IsDisarmed()
			and not enemyHero:HasModifier('modifier_dragonknight_breathefire_reduction')
			then
				if (J.IsChasingTarget(enemyHero, bot) and #nEnemyHeroes >= 2) then
					return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
				end

				if (#nEnemyHeroes > #nAllyHeroes and enemyHero:GetAttackTarget() == bot)
				then
					return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + enemyHero:GetLocation()) / 2
				end
			end
		end
	end

	if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.GetHP(botTarget) > 0.4
		and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_dragonknight_breathefire_reduction')
        and bAttacking
		and fManaAfter > 0.5
		and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not botTarget:HasModifier('modifier_dragonknight_breathefire_reduction')
        and bAttacking
		and fManaAfter > 0.5
		and fManaAfter > fManaThreshold1
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderElderDragonForm()
	if not J.CanCastAbility(ElderDragonForm) or botHP < 0.25 then
		return BOT_ACTION_DESIRE_NONE
	end

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
        and J.IsInRange(bot, botTarget, 800)
		and J.CanBeAttacked(botTarget)
		and not J.IsSuspiciousIllusion(botTarget)
		then
			local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
			local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
			if not (#nInRangeAlly >= #nInRangeEnemy + 2) then
				if #nInRangeEnemy >= 2 then
					return BOT_ACTION_DESIRE_HIGH
				else
					if not botTarget:HasModifier('modifier_necrolyte_reapers_scythe') then
						return BOT_ACTION_DESIRE_HIGH
					end
				end
			end
		end
	end

	local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(800, true)

	if J.IsPushing(bot) then
		if J.IsValidBuilding(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.GetHP(botTarget) > 0.2
		and not botTarget:HasModifier('modifier_backdoor_protection')
		and not botTarget:HasModifier('modifier_backdoor_protection_active')
		and not botTarget:HasModifier('modifier_backdoor_protection_in_base')
		and #nEnemyLaneCreeps >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDefending(bot) then
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
		if #nEnemyLaneCreeps >= 6 and #nInRangeEnemy == 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDoingRoshan(bot) and bot:GetNetWorth() < 20000 then
		if J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, 600)
		and J.GetHP(botTarget) > 0.4
        and bAttacking
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDoingTormentor(bot) and bot:GetNetWorth() < 15000 then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, 600)
        and bAttacking
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
