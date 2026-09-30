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

-- Updated to 7.41f from D2PT: pos 5/4; forced cores use pos 5 without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/oracle')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Fortune's End, [2] Fate's Edict, [3] Purifying Flames, [6] False Promise.
local nAbilityBuildList = {1,3,3,2,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, t15={0,10}, t20={0,10}, t25={10,0},
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {'item_double_branches','item_magic_stick','item_tango','item_faerie_fire','item_blood_grenade'}
if sRole == 'pos_4' or sRole == 'pos_5' then table.insert(X.sBuyList,'item_ward_sentry') end
local progression = sRole == 'pos_4' and {
    'item_magic_wand','item_arcane_boots','item_blink','item_aether_lens',
    'item_holy_locket','item_aghanims_shard',
    -- Bot policy: protection and mobility upgrades within six slots.
    'item_glimmer_cape','item_force_staff','item_arcane_blink','item_moon_shard',
} or {
    'item_magic_wand','item_arcane_boots','item_blink','item_glimmer_cape',
    'item_aether_lens','item_aghanims_shard',
    -- Bot policy: consume Scepter before the final six-slot support inventory.
    'item_force_staff','item_ultimate_scepter','item_ultimate_scepter_2',
    'item_arcane_blink','item_sheepstick','item_moon_shard',
}
for _,item in ipairs(progression) do table.insert(X.sBuyList,item) end
X.sSellList = sRole == 'pos_4' and {'item_glimmer_cape','item_magic_wand'}
    or {'item_force_staff','item_magic_wand'}
if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_mage'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X.sBuyList,X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList,nAbilityBuildList,sTalentList,nTalentBuildList)
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
local talent3 = bot:GetAbilityByName( sTalentList[3] )
local abilityD = bot:GetAbilityByName( sAbilityList[4] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget
local castDDesire, castDTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0

function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 250 end
--	if talent3:IsTrained() then aetherRange = aetherRange + talent3:GetSpecialValueInt( "value" ) end

	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return

	end

	castEDesire, castETarget, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end

	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )

		if abilityE:IsFullyCastable()
		then
			bot:ActionQueue_UseAbilityOnEntity( abilityE, castQTarget )
		end

		return
	end
	
	castDDesire, castDTarget, sMotive = X.ConsiderD()
	if ( castDDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityD, castDTarget )
		return
	end

end




function X.ConsiderD()


	if not abilityD:IsTrained()	or not abilityD:IsFullyCastable() then return 0 end

	local nSkillLV = abilityD:GetLevel()
	local nCastRange = 650 + aetherRange
	local nCastPoint = abilityD:GetCastPoint()
	local nManaCost = abilityD:GetManaCost()
	local nDamage = abilityD:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius = 650


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and ( botTarget:GetAttackTarget() ~= nil or bot:GetAttackTarget() ~= nil )
		then			
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "D-Attack"..J.Chat.GetNormName( botTarget )
		end
	end
	

	return BOT_ACTION_DESIRE_NONE


end



function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius = 300
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "Q-Attack"..J.Chat.GetNormName( botTarget )
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + aetherRange
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	if J.IsInTeamFight( bot, 900 ) and #hEnemyList >= 3
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL )
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage
					npcMostDangerousEnemy = npcEnemy
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy, "W-Battle"..J.Chat.GetNormName( npcMostDangerousEnemy )
		end

	end

	--撤退时缴械攻击自己的( 远程 )敌人


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsAttacking( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "W-Attack"..J.Chat.GetNormName( botTarget )
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nSkillLV = abilityE:GetLevel()
	local nCastRange = abilityE:GetCastRange() + aetherRange
	
	if nCastRange >= 1500 then nCastRange = 1500 end
	
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nDamage = abilityE:GetSpecialValueInt( 'damage' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange + 50, true, BOT_MODE_NONE )

	--击杀
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy, "E-击杀"..J.Chat.GetNormName( npcEnemy )
		end
	end

	--治疗队友
	for _, npcAlly in pairs( hAllyList )
	do
		if J.IsValidHero( npcAlly )
			and J.IsInRange( bot, npcAlly, nCastRange )
			and J.CanCastOnNonMagicImmune( npcAlly )
		then
			if npcAlly:GetMagicResist() > 0.42
				and J.GetHP( npcAlly ) < 0.8
				and ( #hEnemyList == 0 or npcAlly:GetHealth() > 999 )
				and J.GetUniqueModifierCount( bot, "modifier_oracle_purifying_flames" ) < 3
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly, "E-治疗"..J.Chat.GetNormName( npcAlly )
			end
		end

		if npcAlly:HasModifier( 'modifier_oracle_false_promise_timer' )
			and J.GetModifierTime( npcAlly, 'modifier_oracle_false_promise_timer' ) > 3.8
			and J.IsInRange( bot, npcAlly, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcAlly, "E-支援抢救"..J.Chat.GetNormName( npcAlly )
		end


	end


	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 50 )
			and J.CanCastOnNonMagicImmune( botTarget )
			and botTarget:GetMagicResist() < 0.6
		then
			local nProjectList = botTarget:GetIncomingTrackingProjectiles()
			for _, p in pairs( nProjectList )
			do
				if not p.is_attack
					and p.ability ~= nil
					and p.ability:GetName() == "oracle_fortunes_end"
					and GetUnitToLocationDistance( botTarget, p.location ) > 330
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget, "E-弹道前进攻"..J.Chat.GetNormName( botTarget )
				end
			end

			if J.WillMagicKillTarget( bot, botTarget, nDamage * 1.6, nCastPoint )
			then
				local nNearTargetAllyList = J.GetAlliesNearLoc( botTarget:GetLocation(), 550 )
				if #nNearTargetAllyList >= 3
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget, "E-击杀前进攻"..J.Chat.GetNormName( botTarget )
				end
			end

		end
	end


	--对线补刀


	--推进
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and #hAllyList <= 2 and nSkillLV >= 3 and J.IsAllowedToSpam( bot, 30 )
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 350, true )
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
				and creep:GetHealth() > nDamage * 0.6
				and not J.IsOtherAllysTarget( creep )
			then
				if J.IsKeyWordUnit( 'ranged', creep )
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "E-补刀远程兵"
				end

				if bot:GetMana() > abilityR:GetManaCost() * 2 and nSkillLV >= 4
					and J.IsKeyWordUnit( 'melee', creep )
					and creep:GetHealth() > nDamage * 0.7
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "E-补刀近战兵"
				end

			end

		end

		if #hAllyList <= 1
		then
			local nCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 150 )
			for _, creep in pairs( nCreeps )
			do
				if J.IsValid( creep )
					and creep:GetHealth() > nDamage * 0.45
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastRange )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "E-补刀野怪"
				end
			end
		end

	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	for _, ally in pairs( hAllyList )
	do
		if J.IsInRange( bot, ally, nCastRange + 50 )
			and ally:WasRecentlyDamagedByAnyHero( 2.0 )
			and J.GetHP( ally ) < 0.55
		then
			if J.IsRetreating( ally )
				and ( ally ~= bot or nHP < 0.25 )
			then
				return BOT_ACTION_DESIRE_HIGH, ally, "R-protect"..J.Chat.GetNormName( ally )
			end

			if J.IsGoingOnSomeone( ally ) and J.GetHP( ally ) < 0.3
			then
				local allyTarget = J.GetProperTarget( ally )
				if J.IsValidHero( allyTarget )
					and J.IsInRange( ally, allyTarget, 600 )
				then
					return BOT_ACTION_DESIRE_HIGH, ally, "R-support"..J.Chat.GetNormName( ally )
				end
			end
			
			if not ally:IsBot()
				and J.GetHP( ally ) <= 0.6
				and ally:GetAttackTarget() ~= nil
				and ally:GetAttackTarget():IsHero()
				and ally:WasRecentlyDamagedByAnyHero( 2.0 )
				and #hEnemyList >= 2
				and ( J.IsGoingOnSomeone( bot ) or J.IsGoingOnSomeone( ally ) )
			then			
				return BOT_ACTION_DESIRE_HIGH, ally, "R-ally"..J.Chat.GetNormName( ally )
			end
				
			
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592..



