local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot, abilityQ, abilityW, abilityR, abilitySR, ReelIn
local botTarget, nMP, hEnemyList, aetherRange
local function Refresh()
    bot = GetBot()
    abilityQ = bot:GetAbilityByName('naga_siren_mirror_image')
    abilityW = bot:GetAbilityByName('naga_siren_ensnare')
    abilityR = bot:GetAbilityByName('naga_siren_song_of_the_siren')
    abilitySR = bot:GetAbilityByName('naga_siren_song_of_the_siren_cancel')
    ReelIn = bot:GetAbilityByName('naga_siren_reel_in')
    botTarget = J.GetProperTarget(bot)
    nMP = bot:GetMana() / bot:GetMaxMana()
    hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    aetherRange = 0
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then aetherRange = lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        aetherRange = aetherRange + supremacy:GetSpecialValueInt('cast_range')
    end
end

function X.ConsiderQ()


	if not J.CanCastAbility(abilityQ) then return 0 end
    -- Mirror Image provides a basic dispel even when there is no attack target.
    if bot:IsRooted() or bot:HasModifier('modifier_bounty_hunter_track')
        or bot:HasModifier('modifier_slardar_amplify_damage') then
        return BOT_ACTION_DESIRE_HIGH, bot, 'Mirror dispel'
    end

	local nSkillLV    = abilityQ:GetLevel();
	local nCastRange  = abilityQ:GetCastRange()
	local nCastPoint  = abilityQ:GetCastPoint()
	local nManaCost   = abilityQ:GetManaCost()
	local nDamage     = abilityQ:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( 800 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( 1200 )
	local hCastTarget = nil
	local sCastMotive = nil


	if J.IsInTeamFight( bot, 1000 )
	then
		if #nInBonusEnemyList >= 2
		then
			hCastTarget = nInBonusEnemyList[1]
			sCastMotive = 'Q-团战'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget,sCastMotive
		end
	end


	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, 700 )
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-攻击:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget,sCastMotive
		end
	end


	--对线
	if J.IsLaning( bot )
	then
		local attackTarget = bot:GetAttackTarget()
		if J.IsValidHero( attackTarget )
			and J.IsInRange( bot, attackTarget, 600 )
		then
			hCastTarget = attackTarget
			sCastMotive = 'Q-对线'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end

		if bot:WasRecentlyDamagedByAnyHero( 1.0 )
			and #nInRangeEnemyList >= 1
			and nMP > 0.4
		then
			hCastTarget = bot
			sCastMotive = 'Q-对线防御伤害'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--打钱
	if J.IsFarming( bot )
	then
		local targetCreep = bot:GetAttackTarget()
		if J.IsValid( targetCreep )
			and not targetCreep:HasModifier( 'modifier_fountain_glyph' )
			and J.IsInRange( bot, targetCreep, 500 )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep, "Q-打钱"
		end
	end


	--推线推塔
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 800, true )
		local enemyTowerList = bot:GetNearbyTowers( 800, true )
		local enemyBarrackList = bot:GetNearbyBarracks( 800, true )
		if #laneCreepList >= 1 or #enemyTowerList >= 1 or #enemyBarrackList >= 1
		then
			if botTarget ~= nil
			then
				hCastTarget = botTarget
				sCastMotive = 'Q-推线推塔'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end

		local attackTarget = bot:GetAttackTarget()
		if J.IsValidBuilding( attackTarget )
			and attackTarget:GetTeam() ~= bot:GetTeam()
		then
			hCastTarget = attackTarget
			sCastMotive = 'Q-拆建筑'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end



	--撤退时掩护
	if J.IsRetreating( bot )
		and #nInRangeEnemyList >= 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-撤退时掩护'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--通用的情况
	if nSkillLV >= 4
		and J.IsAllowedToSpam( bot, 80 )
	then
		local enemyCreepList = bot:GetNearbyCreeps(1600, true)
		local enemyTowerList = bot:GetNearbyTowers(1600, true)
		if #enemyCreepList >= 1
			or #enemyTowerList >= 1
			or #hEnemyList >= 1
		then
			hCastTarget = bot
			sCastMotive = 'Q-通用的情况'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan( botTarget )
		and J.IsInRange( botTarget, bot, 800 )
		and J.CanBeAttacked(botTarget)
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
        and J.IsInRange( botTarget, bot, 800 )
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE

end


local function CanEnsnare(enemy)
    local sleeping = J.IsValidHero(enemy) and enemy:HasModifier('modifier_naga_siren_song_of_the_siren')
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and (sleeping or J.CanCastOnTargetAdvanced(enemy))
        and (not enemy:IsInvulnerable() or sleeping)
        and (not enemy:IsMagicImmune() or bot:HasScepter())
        and not enemy:HasModifier('modifier_naga_siren_ensnare')
        and J.IsInRange(bot, enemy, abilityW:GetCastRange() + aetherRange)
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local enemies = J.GetNearbyHeroes(bot, math.min(abilityW:GetCastRange() + aetherRange, 1600), true, BOT_MODE_NONE)
    for _, enemy in ipairs(enemies) do
        if CanEnsnare(enemy) and enemy:IsChanneling() then
            return BOT_ACTION_DESIRE_HIGH, enemy, 'Ensnare interrupt'
        end
    end
    if J.IsGoingOnSomeone(bot) and CanEnsnare(botTarget)
        and (not J.IsDisabled(botTarget) or botTarget:HasModifier('modifier_naga_siren_song_of_the_siren')) then
        return BOT_ACTION_DESIRE_HIGH, botTarget, 'Ensnare follow-up'
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        for _, enemy in ipairs(enemies) do
            if CanEnsnare(enemy) and not J.IsDisabled(enemy) and J.IsChasingTarget(enemy, bot) then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'Ensnare escape'
            end
        end
    end
    return 0
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) then return 0 end
    local radius = abilityR ~= nil and abilityR:GetSpecialValueInt('radius') or 1400
    local enemies = J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)
    local affected = 0
    for _, enemy in ipairs(enemies) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and J.CanCastOnNonMagicImmune(enemy) and J.IsInRange(bot, enemy, radius) then
            affected = affected + 1
        end
    end
    if affected == 0 then return 0 end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3)
        and (J.GetHP(bot) < 0.5 or affected >= 2) then return BOT_ACTION_DESIRE_HIGH end
    for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and J.GetHP(ally) < 0.3
            and J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2)
            and not ally:HasModifier('modifier_ice_blast') then return BOT_ACTION_DESIRE_HIGH end
    end
    -- Song makes enemies invulnerable: only set up isolated, distant targets with a nearby ally.
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget) and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, radius) and not J.IsInRange(bot, botTarget, 800)
        and not botTarget:WasRecentlyDamagedByAnyHero(3) then
        local allies = J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)
        if #allies >= 1 and affected <= #allies + 1 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end

function X.ConsiderSR()
    if not J.CanCastAbility(abilitySR) then return 0 end
    local radius = abilityR ~= nil and abilityR:GetSpecialValueInt('radius') or 1400
    local sleeping = {}
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and enemy:HasModifier('modifier_naga_siren_song_of_the_siren') then
            sleeping[#sleeping + 1] = enemy
        end
    end
    -- Keep an escape Song running until its victims leave the aura.
    if #sleeping == 0 then
        if J.GetHP(bot) < 0.8 and not bot:HasModifier('modifier_ice_blast') then return 0 end
        for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and J.GetHP(ally) < 0.8
                and not ally:HasModifier('modifier_ice_blast') then return 0 end
        end
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsRetreating(bot) then return 0 end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget)
        and botTarget:HasModifier('modifier_naga_siren_song_of_the_siren')
        and J.IsInRange(bot, botTarget, 350) then
        local ready = 0
        for _, ally in ipairs(J.GetNearbyHeroes(bot, 600, false, BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and J.IsInRange(ally, botTarget, 600) then ready = ready + 1 end
        end
        if ready >= #sleeping then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end

function X.ConsiderReelIn()
    if not J.CanCastAbility(ReelIn) or J.IsRetreating(bot) or bot:IsChanneling()
        or J.IsInTeamFight(bot, 1400) then return 0 end
    local radius = ReelIn:GetSpecialValueInt('radius')
    local enemies = J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)
    local allies = J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)
    for _, enemy in ipairs(enemies) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and (not enemy:IsMagicImmune() or bot:HasScepter())
            and J.IsInRange(bot, enemy, radius) and not J.IsInRange(bot, enemy, bot:GetAttackRange() + 150)
            and enemy:HasModifier('modifier_naga_siren_ensnare') and #allies + 1 >= #enemies then
            local index = enemy:GetModifierByName('modifier_naga_siren_ensnare')
            if abilityW ~= nil and index >= 0 and enemy:GetModifierSourceAbility(index) == abilityW then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    return 0
end

function X.ConsiderStolenSpell(ability)
    local name = ability:GetName()
    if name ~= 'naga_siren_mirror_image' and name ~= 'naga_siren_ensnare'
        and name ~= 'naga_siren_song_of_the_siren' and name ~= 'naga_siren_song_of_the_siren_cancel'
        and name ~= 'naga_siren_reel_in' and name ~= 'naga_siren_reel_in_ad' then return nil end
    Refresh()
    if J.CanNotUseAbility(bot) or bot:IsChanneling() then return false end
    local desire, target
    if name == 'naga_siren_mirror_image' then abilityQ = ability; desire = X.ConsiderQ()
    elseif name == 'naga_siren_ensnare' then abilityW = ability; desire, target = X.ConsiderW()
    elseif name == 'naga_siren_song_of_the_siren' then abilityR = ability; desire = X.ConsiderR()
    elseif name == 'naga_siren_song_of_the_siren_cancel' then abilitySR = ability; desire = X.ConsiderSR()
    else ReelIn = ability; desire = X.ConsiderReelIn() end
    if desire > 0 then
        if name == 'naga_siren_ensnare' then bot:Action_UseAbilityOnEntity(ability, target)
        else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
