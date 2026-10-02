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
local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/lion')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: hard support/support/mid; forced other roles use hard support.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/lion')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Earth Spike, [2] Hex, [3] Mana Drain, [6] Finger of Death.
local nAbilityBuildList = sRole == 'pos_2'
    and {1,3,1,3,1,6,1,2,3,3,6,2,2,2,6}
    or {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +20 movement speed
    t15=sRole == 'pos_2' and {10,0} or {0,10}, -- Hell and Back amplification / -2s Hex cooldown
    t20=sRole == 'pos_5' and {10,0} or {0,10}, -- Earth Spike cone / +20 Finger damage per kill
    t25=sRole == 'pos_5' and {10,0} or {0,10}, -- +600 Earth Spike range / +250 AoE Hex
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_2' then
    -- Omit the observed ward: core bots do not run ward placement.
    X.sBuyList = {
        'item_double_branches','item_circlet','item_circlet','item_tango','item_faerie_fire',
        'item_magic_wand','item_power_treads','item_blink','item_echo_sabre','item_invis_sword',
        'item_lesser_crit','item_black_king_bar','item_harpoon','item_greater_crit',
        -- Bot policy: natural invisibility/Blink upgrades and consumed Scepter preserve six slots.
        'item_silver_edge','item_ultimate_scepter','item_ultimate_scepter_2','item_overwhelming_blink',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand'}
else
    if sRole == 'pos_4' then
        -- Dispenser's 1+1 charges do not identify ward types; bot policy buys one of each.
        X.sBuyList = {'item_boots','item_ward_observer','item_ward_sentry','item_blood_grenade'}
    else
        X.sBuyList = {'item_double_branches','item_magic_stick','item_tango','item_faerie_fire','item_blood_grenade'}
        if sRole == 'pos_5' then table.insert(X.sBuyList,'item_ward_sentry') end
    end
    local core = {'item_magic_wand','item_tranquil_boots','item_blink','item_glimmer_cape','item_force_staff','item_aether_lens'}
    for _, item in ipairs(core) do table.insert(X.sBuyList,item) end
    if sRole ~= 'pos_4' then table.insert(X.sBuyList,'item_aghanims_shard') end
    -- Bot policy: late Finger upgrades/disable and natural Blink upgrade fit six persistent slots.
    local late = {'item_ultimate_scepter','item_ultimate_scepter_2','item_sheepstick','item_overwhelming_blink'}
    for _, item in ipairs(late) do table.insert(X.sBuyList,item) end
    if sRole == 'pos_4' then table.insert(X.sBuyList,'item_aghanims_shard') end
    X.sSellList = {'item_aether_lens','item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Mana Drain point at 10, then the first talent at 11. Preserve custom progressions.
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

npc_dota_hero_lion

"Ability1"		"lion_impale"
"Ability2"		"lion_voodoo"
"Ability3"		"lion_mana_drain"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"lion_finger_of_death"
"Ability10"		"special_bonus_cast_range_100"
"Ability11"		"special_bonus_attack_damage_90"
"Ability12"		"special_bonus_unique_lion_3"
"Ability13"		"special_bonus_gold_income_25"
"Ability14"		"special_bonus_hp_500"
"Ability15"		"special_bonus_unique_lion"
"Ability16"		"special_bonus_unique_lion_2"
"Ability17"		"special_bonus_unique_lion_4"

modifier_lion_impale
modifier_lion_voodoo
modifier_lion_mana_drain
modifier_lion_finger_of_death_kill_counter
modifier_lion_finger_of_death
modifier_lion_finger_of_death_delay
modifier_lion_arcana_kill_effect

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent4 = bot:GetAbilityByName( sTalentList[4] )
local HexAoETalent = bot:GetAbilityByName('special_bonus_unique_lion_4')

local castQDesire, castQLocation
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local lastCastQTime = -99


function X.SkillsComplement()

	if X.ConsiderStopDrain() > 0
	then
		bot:Action_ClearActions( true )
		return
	end

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
	if aether ~= nil then aetherRange=aether:GetSpecialValueInt('cast_range_bonus') end
--	if talent4:IsTrained() then aetherRange = aetherRange + talent4:GetSpecialValueInt( "value" ) end
	

    local interrupt=SpellDecisions.HexTarget(abilityW)
    if interrupt~=nil then
        J.SetQueuePtToINT(bot,true,abilityW)
        bot:ActionQueue_UseAbilityOnEntity(abilityW,interrupt)
        return
    end
	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true, abilityR )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return

	end


	castQDesire, castQLocation, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true, abilityQ )

		local offset=castQLocation-bot:GetLocation()
        local range=abilityQ:GetCastRange()+aetherRange
        if offset:Length2D()>range then castQLocation=bot:GetLocation()+offset:Normalized()*range end
        bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		lastCastQTime = DotaTime()
		return
	end


	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true, abilityW )

		bot:ActionQueue_UseAbilityOnEntity(abilityW,castWTarget)
		return
	end

	castEDesire, castETarget, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT(bot,false,abilityE)

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end




end

function X.ConsiderStopDrain()
    local active=bot:GetCurrentActiveAbility()
    if bot:IsChanneling() and active~=nil and active:GetName()=='lion_mana_drain'
        and J.IsRetreating(bot) and (bot:WasRecentlyDamagedByAnyHero(2)
            or #J.GetNearbyHeroes(bot,600,true,BOT_MODE_NONE)>0) then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

function X.IsAbilityEChanneling()
    local active=bot:GetCurrentActiveAbility()
    return bot:IsChanneling() and active~=nil and active:GetName()=='lion_mana_drain'
end

function X.ConsiderQ()


	if not J.CanCastAbility(abilityQ) then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nRadius	 = abilityQ:GetSpecialValueInt( "width" )
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt('damage')
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	local nInBonusEnemyList = J.GetNearbyHeroes(bot, nCastRange + 200, true, BOT_MODE_NONE )

	local nTargetLocation = nil

	--击杀
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, 5.0 )
		then
			nTargetLocation = npcEnemy:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-击杀'..J.Chat.GetNormName( npcEnemy )
		end
	end

	--Aoe
	local nCanHurtEnemyAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius + 10, 0, 0 )
	if nCanHurtEnemyAoE.count >= 3
	then
		nTargetLocation = nCanHurtEnemyAoE.targetloc
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-Aoe:'..( nCanHurtEnemyAoE.count )
	end

	--团战
	if J.IsInTeamFight( bot, 1200 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius + 20, 2 )
		if nAoeLoc ~= nil
		then
			nTargetLocation = nAoeLoc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-团控'
		end
	end


	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 300 )
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHP( botTarget ) < 0.5
			then
				local nDelayTime = nCastPoint + GetUnitToUnitDistance( bot, botTarget )/1600
				nTargetLocation = SpellDecisions.SpikePoint(abilityQ,botTarget)
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-攻击:'..J.Chat.GetNormName( botTarget )
				end
			end
		end
	end


	--撤退
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) or bot:GetActiveModeDesire() > 0.7 )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				nTargetLocation = npcEnemy:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-撤退:'..J.Chat.GetNormName( npcEnemy )
			end
		end
	end


	--Farm
	if J.IsFarming( bot )
		and nSkillLV >= 2
		and J.GetManaAfter( nManaCost ) > 0.3
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps( nCastRange )
		if #nNeutralCreeps >= 3
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0, 0 )
			if locationAoE.count >= 2
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q-打钱:"..locationAoE.count
			end
		end
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange, true )
		if #nLaneCreeps >= 3
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0, 0 )
			if locationAoE.count >= 3
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q-Farm:"..locationAoE.count
			end
		end
	end


	--Push
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and nSkillLV >= 4 and DotaTime() > 9 * 60
		and #hAllyList <= 2 and #hEnemyList == 0
		and not bot:HasScepter()
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1300, true )
		if #laneCreepList >= 5
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 90, 0, 0 )
			if locationAoEHurt.count >= 3
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "Q-推线"..locationAoEHurt.count
			end
		end
	end


	--Roshan
	if J.IsDoingRoshan( bot )
		and J.GetManaAfter( nManaCost ) > 0.3
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
		then
			nTargetLocation = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end
	end

	if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), ''
		end
	end

	--常规
	if ( #hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero( 3.0 ) )
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 15
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy ) 
				and J.IsInRange( bot, npcEnemy, nCastRange )
			then
				nTargetLocation = npcEnemy:GetLocation()
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, 'Q-常规'
			end
		end
	end

	--Farming: use Earth Spike on neutral creeps
	if J.IsFarming( bot )
		and J.GetManaAfter( nManaCost ) > 0.3
		and nSkillLV >= 2
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps( nCastRange )
		if nNeutralCreeps ~= nil and #nNeutralCreeps >= 3
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0, 0 )
			if locationAoE.count >= 3
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc, 'Q-Farm neutrals'
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()
    local target=SpellDecisions.HexTarget(abilityW)
    return target~=nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE,target
end

function X.ConsiderE()
    local target=SpellDecisions.DrainTarget(abilityE)
    return target~=nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE,target
end

function X.ConsiderR()
    local target=SpellDecisions.FingerTarget(abilityR)
    return target~=nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE,target
end

function X.GetAbilityRDamageBonus()

	-- The engine special includes the current damage-per-kill talent.
	local nDamageBonus = abilityR:GetSpecialValueInt('damage_per_kill')
	local sModifierName = "modifier_lion_finger_of_death_kill_counter"
	local nModifierCount = J.GetModifierCount( bot, sModifierName )
	

	return nModifierCount * nDamageBonus

end


function X.CanCastAbilityROnTarget( nTarget )

	if J.CanCastOnTargetAdvanced( nTarget )
		and not nTarget:HasModifier( "modifier_arc_warden_tempest_double" )
		and not J.IsHaveAegis( nTarget )
	then
		return J.CanCastOnNonMagicImmune( nTarget )
	end

	return false

end


function X.IsOtherAbilityFullyCastable()

	return abilityQ:IsFullyCastable() or abilityW:IsFullyCastable() or abilityR:IsFullyCastable()

end


function X.MayKillTarget( nTarget )

	if nTarget:HasModifier( "modifier_lion_finger_of_death" )
	then
		return true
	end

	local nDamageToTarget = bot:GetEstimatedDamageToTarget( true, botTarget, 9.0, DAMAGE_TYPE_PHYSICAL )
	if J.CanKillTarget( botTarget, nDamageToTarget, DAMAGE_TYPE_PHYSICAL )
	then
		return true
	end

	return false

end

return X
-- dota2jmz@163.com QQ:2462331592..
