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

-- Updated to 7.41f from D2PT: pos 5/3; forced picks use the support build without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/omniknight')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local isCore = sRole == 'pos_3'
-- [1] Purification, [2] Repel (Martyr), [3] Hammer of Purity, [6] Guardian Angel.
local nAbilityBuildList = isCore and {3,1,3,1,3,1,3,1,2,6,6,2,2,2,6}
    or {3,1,1,2,1,6,1,2,2,2,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild(isCore and {
    t10={10,0}, t15={0,10}, t20={10,0}, t25={10,0},
} or {
    t10={0,10}, t15={10,0}, t20={10,0}, t25={0,10},
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if isCore then
    X.sBuyList = {
        'item_double_gauntlets','item_double_branches','item_magic_stick',
        'item_magic_wand','item_soul_ring','item_phase_boots','item_echo_sabre',
        'item_harpoon','item_blink','item_aghanims_shard','item_black_king_bar',
        -- Bot policy: consumed Scepter, armor and late dispel within six slots.
        'item_ultimate_scepter','item_ultimate_scepter_2','item_assault',
        'item_overwhelming_blink','item_nullifier','item_moon_shard',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand','item_ultimate_scepter','item_soul_ring'}
else
    X.sBuyList = {'item_boots','item_blood_grenade'}
    if sRole == 'pos_4' or sRole == 'pos_5' then table.insert(X.sBuyList,'item_ward_sentry') end
    local progression = {
        'item_magic_wand','item_arcane_boots','item_mekansm','item_holy_locket',
        'item_guardian_greaves','item_aghanims_shard','item_ultimate_scepter',
        -- Bot policy: consume Scepter before late mobility, dispel and control.
        'item_ultimate_scepter_2','item_blink','item_lotus_orb','item_sheepstick',
        'item_overwhelming_blink','item_refresher','item_moon_shard',
    }
    for _,item in ipairs(progression) do table.insert(X.sBuyList,item) end
    X.sSellList = {}
end
if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_tank'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X.sBuyList,X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList,nAbilityBuildList,sTalentList,nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X.bDeafaultAbility = false
X.bDeafaultItem = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	-- Re-fetch ability handles each tick for safety
	abilityQ = bot:GetAbilityByName( sAbilityList[1] )
	abilityW = bot:GetAbilityByName( sAbilityList[2] )
	abilityE = bot:GetAbilityByName( sAbilityList[3] )
	abilityR = bot:GetAbilityByName( sAbilityList[6] )

	-- Cache per-tick variables
	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	--计算天赋可能带来的通用变化
	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end


	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true, abilityR )

		bot:ActionQueue_UseAbility( abilityR )
		return
	end


	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true, abilityQ )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if castWDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true, abilityW )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end

	castEDesire, castETarget, sMotive = X.ConsiderE()
	if castEDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:Action_UseAbilityOnEntity( abilityE, castETarget )
		return
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nRadius = abilityQ:GetSpecialValueInt( 'radius' )
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( 'heal' )


	local nDamageType = DAMAGE_TYPE_PURE
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + nRadius )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 + nRadius )

	local nInRangeAllyHeroList = J.GetNearbyHeroes(bot, nCastRange + 350, false, BOT_MODE_NONE )
	local nInRangeAllyCreepList = bot:GetNearbyCreeps( nCastRange + 200, false )

	local hCastTarget = nil
	local sCastMotive = nil


	--击杀低血量敌人
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnMagicImmune( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage , nDamageType )
			and not J.IsSuspiciousIllusion( npcEnemy )
			and not npcEnemy:HasModifier( 'modifier_abaddon_borrowed_time' )
			and not npcEnemy:HasModifier( 'modifier_dazzle_shallow_grave' )
			and not npcEnemy:HasModifier( 'modifier_necrolyte_reapers_scythe' )
			and not npcEnemy:HasModifier( 'modifier_oracle_false_promise_timer' )
		then
			local bestTarget = nil
			local bestTargetHP = 9

			--优先通过治疗队友来击杀
			for _, npcAlly in pairs( nInRangeAllyHeroList )
			do
				if J.IsInRange( npcAlly, npcEnemy, nRadius )
					and J.GetHP( npcAlly ) < bestTargetHP
				then
					bestTarget = npcAlly
					bestTargetHP = J.GetHP( npcAlly )
				end
			end
			if bestTarget ~= nil
			then
				hCastTarget = bestTarget
				sCastMotive = 'Q-击杀1'..J.Chat.GetNormName( npcEnemy )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end

			--通过治疗小兵击杀敌人
			for _, creep in pairs( nInRangeAllyCreepList )
			do
				if J.IsInRange( creep, npcEnemy, nRadius )
					and J.GetHP( creep ) < bestTargetHP
				then
					bestTarget = creep
					bestTargetHP = J.GetHP( creep )
				end
			end
			if bestTarget ~= nil
			then
				hCastTarget = bestTarget
				sCastMotive = 'Q-击杀2'..J.Chat.GetNormName( npcEnemy )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--攻击和撤退
	if J.IsGoingOnSomeone( bot )
		or J.IsRetreating( bot )
	then

		local bestTarget = nil
		local bestAoeCount = 0

		for _, npcAlly in pairs( hAllyList )
		do
			if J.IsInRange( bot, npcAlly, nCastRange )
				and npcAlly:GetMaxHealth() - npcAlly:GetHealth() > nDamage + 50
			then
				local nearbyEnemyList = J.GetNearbyHeroes(npcAlly,  nRadius, true, BOT_MODE_NONE )
				if #nearbyEnemyList > bestAoeCount
				then
					bestAoeCount = #nearbyEnemyList
					bestTarget = npcAlly
				end
			end
		end

		if bestTarget ~= nil
		then
			local nearbyEnemyList = J.GetNearbyHeroes(bot,  nRadius, true, BOT_MODE_NONE)
			for _, npcEnemy in pairs( nearbyEnemyList )
			do
				if J.CanCastOnMagicImmune( npcEnemy )
				then
					hCastTarget = bestTarget
					sCastMotive = 'Q-AOE:'..J.Chat.GetNormName( bestTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end


		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nRadius )
			and J.CanCastOnMagicImmune( botTarget )
			and	bot:GetMaxHealth() - bot:GetHealth() > nDamage
		then
			hCastTarget = bot
			sCastMotive = 'Q-攻击时奶自己'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--奶队友
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and not npcAlly:HasModifier( 'modifier_fountain_aura' )
			and J.IsInRange( bot, npcAlly, nCastRange )
			and ( J.GetHP( npcAlly ) < 0.15
					or ( J.GetHP( npcAlly ) < 0.3 and npcAlly:WasRecentlyDamagedByAnyHero( 3.0 ) ) )
		then
			hCastTarget = npcAlly
			sCastMotive = 'Q-奶队友:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end


	--对线
	if J.IsLaning( bot )
	then
		for _, npcAlly in pairs( nInRangeAllyHeroList )
		do
			if npcAlly:GetMaxHealth() - npcAlly:GetHealth() > nDamage * 1.2
			then
				local nearbyEnemyList = J.GetNearbyHeroes(npcAlly,  nRadius - 20, true, BOT_MODE_NONE )
				if J.IsValidHero( nearbyEnemyList[1] )
					and J.CanCastOnMagicImmune(  nearbyEnemyList[1]  )
				then
					hCastTarget = npcAlly
					sCastMotive = 'Q-对线治疗'..J.Chat.GetNormName( npcAlly )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end


	--推线
	local enemyLaneCreepList = bot:GetNearbyLaneCreeps( 1600, true )
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and #hAllyList <= 3 and #enemyLaneCreepList >= 3
	then
		--以自己为Aoe中心
		local laneCreepList = bot:GetNearbyLaneCreeps( nRadius , true )
		if ( #laneCreepList >= 4 or ( #laneCreepList >= 3 and nMP > 0.82 ) )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			hCastTarget = bot
			sCastMotive = 'Q-带线AOE'..(#laneCreepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end

		--以小兵为中心
		if enemyLaneCreepList[1] ~= nil
			and not enemyLaneCreepList[1]:HasModifier('modifier_fountain_glyph')
		then

			local bestTarget = nil
			local bestAoeCount = 0

			for _, creep in pairs( nInRangeAllyCreepList )
			do
				local creepCount = 0
				for i = 1, #enemyLaneCreepList
				do
					if enemyLaneCreepList[i]:GetHealth() < nDamage
					then
						creepCount = creepCount + 1
					end
				end

				if creepCount > bestAoeCount
				then
					bestTarget = creep
					bestAoeCount = creepCount
				end

			end

			if bestTarget ~= nil and bestAoeCount >= 3
			then
				hCastTarget = bestTarget
				sCastMotive = 'Q-清兵AOE'..(bestAoeCount)
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end


	--打钱
	if J.IsFarming( bot )
		and J.IsAllowedToSpam( bot, nManaCost )
		and ( bot:GetMaxHealth() - bot:GetHealth() > nDamage or nMP > 0.85 )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nRadius - 20 )

		if ( #creepList >= 3 or ( #creepList >= 2 and nMP > 0.88 ) )
		then
			hCastTarget = bot
			sCastMotive = 'Q-打野AOE'..(#creepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
	    end
	end


	--肉山
	if J.IsDoingRoshan( bot ) and bot:GetMana() > 660
	then
		for _, npcAlly in pairs( hAllyList )
		do
			if npcAlly:GetMaxHealth() - npcAlly:GetHealth() > nDamage
			then
				local allyTarget = npcAlly:GetAttackTarget()
				if J.IsRoshan( allyTarget )
					and J.IsInRange( npcAlly, allyTarget, nRadius )
				then
					hCastTarget = npcAlly
					sCastMotive = 'Q-肉山'..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end


	--折磨者
	if J.IsDoingTormentor( bot ) and bot:GetMana() > 660
	then
		for _, npcAlly in pairs( hAllyList )
		do
			if npcAlly:GetMaxHealth() - npcAlly:GetHealth() > nDamage
			then
				local allyTarget = npcAlly:GetAttackTarget()
				if J.IsTormentor( allyTarget )
					and J.IsInRange( npcAlly, allyTarget, nRadius )
				then
					hCastTarget = npcAlly
					sCastMotive = 'Q-折磨者'..J.Chat.GetNormName( hCastTarget )
					return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
				end
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderW()
    if not abilityW:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end

    local nCastRange = abilityW:GetCastRange() + aetherRange
    local nHealHealth = abilityW:GetSpecialValueInt('base_hpregen') * abilityW:GetSpecialValueInt('duration')
    for _, ally in pairs(hAllyList) do
        if J.IsValidHero(ally)
            and J.IsInRange(bot, ally, nCastRange)
            and not ally:IsInvulnerable()
            and not ally:IsIllusion()
            and not ally:HasModifier('modifier_omniknight_martyr')
            and not ally:HasModifier('modifier_fountain_aura')
        then
            if ally:WasRecentlyDamagedByAnyHero(3.0)
                and (J.GetHP(ally) < 0.65 or ally:GetMaxHealth() - ally:GetHealth() >= nHealHealth)
            then
                return BOT_ACTION_DESIRE_HIGH, ally, 'W-Martyr protection'
            end
            if J.IsGoingOnSomeone(ally)
                and J.IsValidHero(J.GetProperTarget(ally))
                and #J.GetNearbyHeroes(ally, 700, true, BOT_MODE_NONE) >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, ally, 'W-Martyr engage'
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nCastRange = abilityE:GetCastRange()
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nSkillLV = abilityE:GetLevel()
	local nDamage = abilityE:GetSpecialValueInt('base_damage')
        + bot:GetAttackDamage() * abilityE:GetSpecialValueInt('bonus_damage') / 100
	local nDamageType = DAMAGE_TYPE_PURE

	local allyList =  J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE )

	local nEnemysHerosInView = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )


	local nEnemysHerosInRange = J.GetNearbyHeroes(bot, nCastRange + 43, true, BOT_MODE_NONE )
	local nEnemysHerosInBonus = J.GetNearbyHeroes(bot, nCastRange + 330, true, BOT_MODE_NONE )

	--击杀
	for _, npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and not J.IsSuspiciousIllusion( npcEnemy )
			and not npcEnemy:HasModifier( 'modifier_abaddon_borrowed_time' )
			and not npcEnemy:HasModifier( 'modifier_dazzle_shallow_grave' )
			and not npcEnemy:HasModifier( 'modifier_item_blade_mail_reflect' )
		then

			if GetUnitToUnitDistance( bot, npcEnemy ) <= nCastRange + 80
				and J.CanKillTarget( npcEnemy, nDamage * 1.18, nDamageType )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end

		end
	end


	--对线期间对敌方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 5
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsSuspiciousIllusion( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_item_blade_mail_reflect' )
				and J.GetHP( npcEnemy ) < 0.6
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end


	--打架时先手
	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.CanCastOnTargetAdvanced( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange + 80 )
			and not J.IsSuspiciousIllusion( npcTarget )
			and not npcTarget:HasModifier( 'modifier_abaddon_borrowed_time' )
			and not npcTarget:HasModifier( 'modifier_dazzle_shallow_grave' )
			and not npcTarget:HasModifier( 'modifier_item_blade_mail_reflect' )
		then
			if nSkillLV >= 3 or nMP > 0.68 or J.GetHP( npcTarget ) < 0.4 or nHP < 0.25
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget
			end
		end
	end

	--撤退时保护自己
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
						or nMP > 0.8
						or GetUnitToUnitDistance( bot, npcEnemy ) <= 400 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:HasModifier( 'modifier_item_blade_mail_reflect' )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	if J.IsFarming( bot )
		and nSkillLV >= 3
		and ( bot:GetAttackDamage() < 200 or nMP > 0.88 )
		and nMP > 0.71 and #hEnemyList == 0
	then
		local nCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 100 )

		local targetCreep = bot:GetAttackTarget()

		if J.IsValid( targetCreep )
			and bot:IsFacingLocation( targetCreep:GetLocation(), 46 )
			and ( #nCreeps >= 2 or GetUnitToUnitDistance( targetCreep, bot ) <= 400 )
			and not J.IsRoshan( targetCreep )
			and not J.IsOtherAllysTarget( targetCreep )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 1.68, DAMAGE_TYPE_PHYSICAL )
			and not J.CanKillTarget( targetCreep, nDamage, nDamageType )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep
		end
	end


	--打肉的时候输出
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 600
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsRoshan( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end

	--折磨者
	if J.IsDoingTormentor( bot )
		and bot:GetMana() >= 600
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsTormentor( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end

	--受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nEnemysHerosInRange >= 1
		and nLV >= 8
	then
		for _, npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and npcEnemy:IsFacingLocation( bot:GetLocation(), 45 )
				and not npcEnemy:HasModifier( 'modifier_item_blade_mail_reflect' )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderR()
    if not abilityR:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end

    local radius = abilityR:GetSpecialValueInt('radius')
    local global = bot:HasScepter()
    local injured, threatened = 0, 0
    for i = 1, #GetTeamPlayers(GetTeam()) do
        local ally = GetTeamMember(i)
        if J.IsValidHero(ally)
            and ally:IsAlive()
            and (global or J.IsInRange(bot, ally, radius))
            and not ally:HasModifier('modifier_omniknight_guardian_angel')
            and ally:WasRecentlyDamagedByAnyHero(3.0)
        then
            local enemies = J.GetNearbyHeroes(ally, 1000, true, BOT_MODE_NONE)
            if #enemies > 0 and J.GetHP(ally) < 0.8 then
                injured = injured + 1
                threatened = math.max(threatened, #enemies)
                if J.GetHP(ally) < 0.4 then
                    return BOT_ACTION_DESIRE_HIGH, nil, 'R-Guardian Angel save'
                end
            end
        end
    end
    if injured >= 2 and threatened >= 2 then
        return BOT_ACTION_DESIRE_HIGH, nil, 'R-Guardian Angel teamfight'
    end
    return BOT_ACTION_DESIRE_NONE
end

return X
