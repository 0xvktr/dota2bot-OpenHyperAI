local X = {}
local bot = GetBot()
local bDebugMode = ( 1 == 10 )

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use pos 1.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/kez')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Echo Slash, [2] Grappling Claw, [3] Kazurai Katana, [6] Raptor Dance.
local nAbilityBuildList = {1,3,2,3,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Raptor Dance radius
    t15={10,0}, -- Raptor Dance strike
    t20={0,10}, -- Kazurai Katana damage
    t25={10,0}, -- Echo Slash attack
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_power_treads','item_mage_slayer','item_desolator','item_ultimate_scepter','item_black_king_bar',
    -- Bot policy: late upgrades and continuation.
    'item_ultimate_scepter_2','item_lesser_crit','item_greater_crit','item_blink',
    'item_aghanims_shard','item_satanic','item_swift_blink','item_moon_shard',
}
X.sSellList = {'item_desolator','item_quelling_blade','item_black_king_bar','item_magic_wand','item_blink','item_mage_slayer'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_heavens_halberd", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT takes an ability at 10, then the first talent at 11.
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

npc_dota_hero_kez

[VScript] Ability At Index 0: kez_echo_slash
[VScript] Ability At Index 1: kez_grappling_claw
[VScript] Ability At Index 2: kez_kazurai_katana
[VScript] Ability At Index 3: kez_switch_weapons
[VScript] Ability At Index 4: generic_hidden
[VScript] Ability At Index 5: kez_raptor_dance
[VScript] Ability At Index 6: kez_falcon_rush
[VScript] Ability At Index 7: kez_talon_toss
[VScript] Ability At Index 8: kez_shodo_sai
[VScript] Ability At Index 9: kez_ravens_veil
[VScript] Ability At Index 10: kez_shodo_sai_parry_cancel

--]]

local K = require(GetScriptDirectory()..'/FunLib/kez_abilities')

local SwitchWeapons = bot:GetAbilityByName( 'kez_switch_weapons' )

local EchoSlash = bot:GetAbilityByName( 'kez_echo_slash' )
local GrapplingClaw = bot:GetAbilityByName( 'kez_grappling_claw' )
local KazuraiKatana = bot:GetAbilityByName( 'kez_kazurai_katana' )
local RaptorDance = bot:GetAbilityByName( 'kez_raptor_dance' )

local FalconRush = bot:GetAbilityByName( 'kez_falcon_rush' )
local TalonToss = bot:GetAbilityByName( 'kez_talon_toss' )
local ShodoSai = bot:GetAbilityByName( 'kez_shodo_sai' )
local ShodoSaiParryCancel = bot:GetAbilityByName( 'kez_shodo_sai_parry_cancel' )
local RavensVeil = bot:GetAbilityByName( 'kez_ravens_veil' )

local nKeepMana = 220
local nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive,
castEchoSlashDesire, castGrapplingClawDesire, castGrapplingClawTarget, castRaptorDanceDesire

local FalconRushDesire
local TalonTossDesire, TalonTossTarget
local ShodoSaiDesire, ShodoSaiLocation
local ShodoSaiCancelDesire
local RavensVeilDesire
local hNearbyTowers

local SwitchDisciplineDesire



function X.SkillsComplement()
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes( bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )
	hNearbyTowers = bot:GetNearbyTowers(800, true);

    -- The engine changes visibility and activation when discipline changes.
    bot.kez_mode = EchoSlash and not EchoSlash:IsHidden() and EchoSlash:IsActivated() and 'katana' or 'sai'
    if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_kez_raptor_dance_immune')
        or J.IsRetreating(bot) and J.IsRealInvisible(bot) then return end
    if K.Veil(bot,RavensVeil,true)>0 then bot:Action_UseAbility(RavensVeil);return end
    local parry,point=K.Parry(bot,ShodoSai)
    if parry>0 then bot:Action_UseAbilityOnLocation(ShodoSai,point);return end
    if K.Raptor(bot,RaptorDance)>0 then J.SetQueuePtToINT(bot,true,RaptorDance);bot:ActionQueue_UseAbility(RaptorDance);return end
    local toss,victim=K.Toss(bot,TalonToss)
    if toss>0 and victim:IsChanneling() then bot:Action_UseAbilityOnEntity(TalonToss,victim);return end

	castEchoSlashDesire, sMotive = X.ConsiderEchoSlash()
	if castEchoSlashDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true, EchoSlash )

		bot:ActionQueue_UseAbility( EchoSlash )
		return
	end

	local sType = nil
	castGrapplingClawDesire, castGrapplingClawTarget, sType, sMotive = X.ConsiderGrapplingClaw()
	if ( castGrapplingClawDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		if sType == 'unit' then
            bot:Action_UseAbilityOnEntity(GrapplingClaw, castGrapplingClawTarget)
            return
        elseif sType == 'tree' then
            bot:Action_UseAbilityOnTree(GrapplingClaw, castGrapplingClawTarget)
            return
        end
		return
	end

    SwitchDisciplineDesire = X.ConsiderSwitchDiscipline()
    if SwitchDisciplineDesire > 0 then
        bot:Action_UseAbility(SwitchWeapons)
        return
    end

	castRaptorDanceDesire, sMotive = X.ConsiderRaptorDance()
	if castRaptorDanceDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true, RaptorDance )

		bot:ActionQueue_UseAbility( RaptorDance )
		return
	end

	FalconRushDesire = X.ConsiderFalconRush()
    if FalconRushDesire > 0 then
        bot:Action_UseAbility(FalconRush)
        return
    end

	RavensVeilDesire = X.ConsiderRavensVeil()
    if RavensVeilDesire > 0 then
        bot:Action_UseAbility(RavensVeil)
        return
    end

    KazuraiKatanaDesire, KazuraiKatanaTarget = X.ConsiderKazuraiKatana()
    if KazuraiKatanaDesire > 0 then
        bot:Action_UseAbilityOnEntity(KazuraiKatana, KazuraiKatanaTarget)
        return
    end

    TalonTossDesire, TalonTossTarget = X.ConsiderTalonToss()
    if TalonTossDesire > 0 then
        J.SetQueuePtToINT(bot, false, TalonToss)
        bot:ActionQueue_UseAbilityOnEntity(TalonToss, TalonTossTarget)
        return
    end

    ShodoSaiCancelDesire = X.ConsiderShodoSaiCancel()
    if ShodoSaiCancelDesire > 0 then
        bot:Action_UseAbility(ShodoSaiParryCancel)
        return
    end

    ShodoSaiDesire, ShodoSaiLocation = X.ConsiderShodoSai()
    if ShodoSaiDesire > 0 then
        bot:Action_UseAbilityOnLocation(ShodoSai, ShodoSaiLocation)
        return
    end
end

function X.ConsiderEchoSlash()
	if not J.CanCastAbility(EchoSlash) then
        return BOT_ACTION_DESIRE_NONE
    end

    local nDistance = EchoSlash:GetSpecialValueInt('katana_distance')
    local nRadius = EchoSlash:GetSpecialValueInt('katana_radius')
    local nManaAfter = J.GetManaAfter(EchoSlash:GetManaCost())

    if bot:IsDisarmed() then return 0 end
    local combat=K.Echo(bot,EchoSlash)
    if combat>0 then return combat end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    and not J.IsThereNonSelfCoreNearby(1200)
    and nManaAfter > 0.4
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nDistance, true)
        if J.IsValid(nEnemyLaneCreeps[1])
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        and not J.IsRunning(nEnemyLaneCreeps[1])
        then
            local nLocationAoE = bot:FindAoELocation(true, false, nEnemyLaneCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
            if nLocationAoE.count >= 4 and bot:IsFacingLocation(nLocationAoE.targetloc, 20) then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsFarming(bot)
    and not J.IsThereNonSelfCoreNearby(1200)
    and nManaAfter > 0.3
    then
        local nCreeps = bot:GetNearbyCreeps(nDistance, true)
        if J.IsValid(nCreeps[1])
        and J.CanBeAttacked(nCreeps[1])
        and not J.IsRunning(nCreeps[1])
        then
            local nLocationAoE = bot:FindAoELocation(true, false, nCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
            if (nLocationAoE.count >= 2 or (nLocationAoE.count >= 2 and nCreeps[1]:IsAncientCreep()))
            and bot:IsFacingLocation(nLocationAoE.targetloc, 20)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsLaning(bot)
    and not J.IsThereNonSelfCoreNearby(1200)
    then
        if hEnemyList[1] ~= nil and J.IsInRange(bot, hEnemyList[1], nDistance - 100)
        and bot:IsFacingLocation(hEnemyList[1]:GetLocation(), 8)
        and nManaAfter > 0.5
        then
            return BOT_ACTION_DESIRE_HIGH
        end
        local nCreeps = bot:GetNearbyCreeps(nDistance, true)
        if J.IsValid(nCreeps[1])
        and J.CanBeAttacked(nCreeps[1])
        and not J.IsRunning(nCreeps[1])
        then
            local nLocationAoE = bot:FindAoELocation(true, false, nCreeps[1]:GetLocation(), 0, nRadius, 0, 0)
            if nLocationAoE.count >= 5
            and bot:IsFacingLocation(nLocationAoE.targetloc, 15)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingRoshan(bot) then
        if J.IsRoshan(botTarget)
        and J.CanBeAttacked(botTarget)
        and bot:IsFacingLocation(botTarget:GetLocation(), 20)
        and J.IsInRange(bot, botTarget, nDistance)
        and J.IsAttacking(bot)
        and nManaAfter > 0.25
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot) then
        if J.IsTormentor(botTarget)
        and J.CanBeAttacked(botTarget)
        and bot:IsFacingLocation(botTarget:GetLocation(), 20)
        and J.IsInRange(bot, botTarget, nDistance)
        and J.IsAttacking(bot)
        and nManaAfter > 0.25
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderGrapplingClaw()
    return K.Claw(bot,GrapplingClaw)
end

function X.ConsiderRaptorDance()
    return K.Raptor(bot,RaptorDance)
end

function X.ConsiderKazuraiKatana()
    return K.Katana(bot,KazuraiKatana)
end

function X.ConsiderFalconRush()
    if not J.CanCastAbility(FalconRush) or bot:IsDisarmed() or bot:IsRooted()
        or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_slark_pounce_leash')
        or bot:HasModifier('modifier_puck_coiled') or bot:HasModifier('modifier_kez_falcon_rush') then return 0 end
    local combat=K.Falcon(bot,FalconRush);if combat>0 then return combat end
    local nRushRange=FalconRush:GetSpecialValueInt('rush_range')
    local nManaAfter=J.GetManaAfter(FalconRush:GetManaCost())
    local nDistance=bot:GetAttackRange()

    if J.IsFarming(bot)
    and not J.IsThereNonSelfCoreNearby(1200)
    and nManaAfter > 0.4
    then
        local nCreeps = bot:GetNearbyCreeps(nDistance, true)
        if #nCreeps >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingRoshan(bot) then
        if J.IsRoshan(botTarget)
        and J.CanBeAttacked(botTarget)
        and bot:IsFacingLocation(botTarget:GetLocation(), 15)
        and J.IsInRange(bot, botTarget, nRushRange)
        and J.IsAttacking(bot)
        and nManaAfter > 0.25
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot) then
        if J.IsTormentor(botTarget)
        and J.CanBeAttacked(botTarget)
        and bot:IsFacingLocation(botTarget:GetLocation(), 15)
        and J.IsInRange(bot, botTarget, nRushRange)
        and J.IsAttacking(bot)
        and nManaAfter > 0.25
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTalonToss()
    if not J.CanCastAbility(TalonToss) or bot:IsDisarmed() then return 0,nil end
    local desire,target=K.Toss(bot,TalonToss);if desire>0 then return desire,target end
    local nCastRange=K.Range(bot,TalonToss)
    local nDamage=TalonToss:GetSpecialValueInt('damage')

    if J.IsLaning(bot)
	and J.GetManaAfter(TalonToss:GetManaCost()) > 0.3
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		for _, creep in pairs(nEnemyLaneCreeps) do
			if  J.IsValid(creep)
			and J.CanBeAttacked(creep)
			and not J.IsInRange(bot, creep, bot:GetAttackRange() * 2.5)
			and J.IsKeyWordUnit('ranged', creep)
			and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_PHYSICAL)
			then
				if J.IsValidHero(hEnemyList[1])
				and not J.IsSuspiciousIllusion(hEnemyList[1])
				and J.IsInRange(creep, hEnemyList[1], 550)
				then
                    return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderShodoSai()
    return K.Parry(bot,ShodoSai)
end

function X.ConsiderShodoSaiCancel()
    return K.Cancel(bot,ShodoSaiParryCancel)
end

function X.ConsiderRavensVeil()
    return K.Veil(bot,RavensVeil)
end

function X.ConsiderSwitchDiscipline()
    if not J.CanCastAbility(SwitchWeapons) or bot:GetAbilityPoints()>0
        or bot:HasModifier('modifier_kez_shodo_sai_parry') or bot:HasModifier('modifier_kez_ravens_veil_buff') then return 0 end
    local function ready(ability) return ability and ability:IsTrained() and ability:IsFullyCastable() end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        if bot.kez_mode=='sai' and ready(GrapplingClaw) and not bot:IsRooted()
            and K.RetreatTarget(bot,K.Range(bot,GrapplingClaw)) then return BOT_ACTION_DESIRE_HIGH end
        if bot.kez_mode=='katana' and ready(RavensVeil) then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget) and J.IsInRange(bot,botTarget,950) then
        if bot.kez_mode=='katana' and not ready(EchoSlash) and not ready(GrapplingClaw)
            and (ready(FalconRush) or ready(TalonToss)) then return BOT_ACTION_DESIRE_HIGH end
        if bot.kez_mode=='sai' and not ready(FalconRush) and not ready(TalonToss)
            and (ready(EchoSlash) or ready(GrapplingClaw) or ready(RaptorDance)) then return BOT_ACTION_DESIRE_HIGH end
    end
    if (J.IsFarming(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and bot.kez_mode=='sai'
        and not bot:HasModifier('modifier_kez_falcon_rush') and ready(EchoSlash) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.GetBestRetreatGrapplingTarget(range) return K.RetreatTarget(bot,range) end
return X
