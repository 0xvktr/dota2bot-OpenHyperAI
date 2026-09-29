local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f: D2PT position 5. Other roles use this forced-pick fallback.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/ancient_apparition')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local tTalentTreeList = {
    t10={10,0}, -- Cold Feet damage
    t15={10,0}, -- Cold Feet break distance
    t20={0,10}, -- Ice Blast Frostbitten duration
    t25={0,10}, -- AoE Cold Feet
}
local nAbilityBuildList = {3,1,2,2,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_double_branches', 'item_magic_stick', 'item_ward_sentry',
    'item_tango', 'item_faerie_fire', 'item_blood_grenade',
    'item_magic_wand', 'item_arcane_boots', 'item_aghanims_shard',
    -- D2PT displayed progression beyond the three majority-purchased core items.
    'item_force_staff', 'item_cyclone', 'item_octarine_core',
    -- Bot late-game continuation: natural upgrades, then permanent consumables.
    'item_wind_waker', 'item_hurricane_pike',
    'item_mekansm', 'item_guardian_greaves',
    'item_ultimate_scepter_2', 'item_moon_shard',
}
X.sSellList = {'item_octarine_core', 'item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Max Cold Feet at 10; take the first talent at 11, preserving custom orders.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end


X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end
end

local ColdFeet          = bot:GetAbilityByName('ancient_apparition_cold_feet')
local IceVortex         = bot:GetAbilityByName('ancient_apparition_ice_vortex')
local ChillingTouch     = bot:GetAbilityByName('ancient_apparition_chilling_touch')
local IceBlast          = bot:GetAbilityByName('ancient_apparition_ice_blast')
local IceBlastRelease   = bot:GetAbilityByName('ancient_apparition_ice_blast_release')

-- Level-25 talent: Cold Feet also curses enemies around the target. Cold Feet stays unit-targeted.
local ColdFeetAoETalent = bot:GetAbilityByName('special_bonus_unique_ancient_apparition_1')

local ColdFeetDesire, ColdFeetTarget
local IceVortexDesire, IceVortextLocation
local ChillingTouchDesire, ChillingTouchTarget
local IceBlastDesire, IceBlastLocation
local IceBlastReleaseDesire

local IceBlastReleaseLocation

-- Where the last Cold Feet target stood when cursed; the stun breaks once it walks break_distance away.
local ColdFeetOrigin = { unit = nil, location = nil, time = -math.huge }

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    IceBlastReleaseDesire = X.ConsiderIceBlastRelease()
    if IceBlastReleaseDesire > 0
    then
        bot:Action_UseAbility(IceBlastRelease)
        return
    end

    IceBlastDesire, IceBlastLocation = X.ConsiderIceBlast()
    if IceBlastDesire > 0
    then
        bot:Action_UseAbilityOnLocation(IceBlast, IceBlastLocation)
        IceBlastReleaseLocation = IceBlastLocation
        return
    end

    -- Combo order: Cold Feet first, then Ice Vortex on the cursed target so it cannot walk out.
    ColdFeetDesire, ColdFeetTarget = X.ConsiderColdFeet()
    if ColdFeetDesire > 0
    then
        if X.HasColdFeetAoE()
        then
            ColdFeetTarget = X.GetBestColdFeetAoETarget(ColdFeetTarget)
        end

        bot:Action_UseAbilityOnEntity(ColdFeet, ColdFeetTarget)
        ColdFeetOrigin = { unit = ColdFeetTarget, location = ColdFeetTarget:GetLocation(), time = DotaTime() }
        return
    end

    IceVortexDesire, IceVortextLocation = X.ConsiderIceVortex()
    if IceVortexDesire > 0
    then
        bot:Action_UseAbilityOnLocation(IceVortex, IceVortextLocation)
        return
    end

    ChillingTouchDesire, ChillingTouchTarget = X.ConsiderChillingTouch()
    if ChillingTouchDesire > 0
    then
        bot:Action_UseAbilityOnEntity(ChillingTouch, ChillingTouchTarget)
        return
    end
end

function X.HasColdFeetAoE()
    return ColdFeetAoETalent ~= nil and ColdFeetAoETalent:IsTrained()
end

-- With the AoE talent, curse the valid enemy in range with the most enemy heroes around it.
function X.GetBestColdFeetAoETarget(hDefault)
    local nCastRange = J.GetProperCastRange(false, bot, ColdFeet:GetCastRange())
    local nRadius = ColdFeet:GetSpecialValueInt('area_of_effect')
    if nRadius <= 0 then return hDefault end

    local hBest, nBestCount = hDefault, #J.GetEnemiesNearLoc(hDefault:GetLocation(), nRadius)
    for _, enemyHero in pairs(J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE))
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            local nCount = #J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)
            if nCount > nBestCount
            then
                hBest, nBestCount = enemyHero, nCount
            end
        end
    end

    return hBest
end

function X.CanColdFeet(hTarget, nCastRange)
    return J.IsValidHero(hTarget)
        and J.CanCastOnNonMagicImmune(hTarget)
        and J.CanCastOnTargetAdvanced(hTarget)
        and J.IsInRange(bot, hTarget, nCastRange)
        and not J.IsSuspiciousIllusion(hTarget)
        and not hTarget:HasModifier('modifier_cold_feet')
        and not hTarget:HasModifier('modifier_necrolyte_reapers_scythe')
end

function X.ConsiderColdFeet()
    if not ColdFeet:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, ColdFeet:GetCastRange())
    local botTarget = J.GetProperTarget(bot)

    -- Follow-up lockdown: a stunned/rooted enemy cannot walk out of the break distance, and the
    -- Cold Feet stun then chains onto the ally's disable.
    if J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot)
    then
        for _, enemyHero in pairs(J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE))
        do
            if X.CanColdFeet(enemyHero, nCastRange)
            and J.IsDisabled(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.5)
        and not allyHero:IsIllusion()
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
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

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_cold_feet')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if (#nInRangeAlly > #nInRangeEnemy
                    or bot:WasRecentlyDamagedByHero(enemyHero, 1.5))
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_cold_feet')
                and not enemyHero:HasModifier('modifier_ice_vortex')
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_cold_feet')
        and not botTarget:HasModifier('modifier_ice_vortex')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_cold_feet')
        and not botTarget:HasModifier('modifier_ice_vortex')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

-- Center the Vortex between the cursed target and where it was cursed, so the pull drags it back
-- toward the Cold Feet origin while the target stays inside the radius.
function X.GetColdFeetVortexLocation(hTarget, nRadius, nCastPoint)
    local vTarget = hTarget:GetExtrapolatedLocation(nCastPoint)
    if ColdFeetOrigin.unit ~= hTarget
    or ColdFeetOrigin.location == nil
    or DotaTime() > ColdFeetOrigin.time + ColdFeet:GetDuration() + 0.5
    then
        return vTarget
    end

    local nToOrigin = J.GetLocationToLocationDistance(vTarget, ColdFeetOrigin.location)
    if nToOrigin < 1 then return vTarget end

    local nOffset = math.min(nToOrigin, nRadius * 0.5)
    return vTarget + (ColdFeetOrigin.location - vTarget):Normalized() * nOffset
end

function X.ConsiderIceVortex()
    if not IceVortex:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, IceVortex:GetCastRange())
    local nRadius = IceVortex:GetSpecialValueInt('radius')
    local nCastPoint = IceVortex:GetCastPoint()
    local botTarget = J.GetProperTarget(bot)

    -- Cold Feet follow-up: the Vortex slow and pull keep the target inside the break distance, and
    -- its magic resistance reduction amplifies the rest of the combo.
    for _, enemyHero in pairs(J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE))
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and enemyHero:HasModifier('modifier_cold_feet')
        and not enemyHero:HasModifier('modifier_ice_vortex')
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            return BOT_ACTION_DESIRE_HIGH, X.GetColdFeetVortexLocation(enemyHero, nRadius, nCastPoint)
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1 and GetUnitToLocationDistance(bot, nLocationAoE.targetloc) <= nCastRange
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_ice_vortex')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if (#nInRangeAlly > #nInRangeEnemy
                    or bot:WasRecentlyDamagedByHero(enemyHero, 1.5))
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_cold_feet')
                and not enemyHero:HasModifier('modifier_ice_vortex')
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
                end
            end
        end
    end

    if (J.IsDefending(bot) or J.IsPushing(bot))
    and not J.IsThereNonSelfCoreNearby(1000)
	then
		local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 4
        and nLocationAoE.count >= 4 and GetUnitToLocationDistance(bot, nLocationAoE.targetloc) <= nCastRange
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        if nLocationAoE.count >= 2 and GetUnitToLocationDistance(bot, nLocationAoE.targetloc) <= nCastRange
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderChillingTouch()
    if not ChillingTouch:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, ChillingTouch:GetCastRange()) + ChillingTouch:GetSpecialValueInt('attack_range_bonus')
    local nDamage = ChillingTouch:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 50, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    -- Lane harass with the extended attack range, keeping mana for Cold Feet.
    -- Stay out of enemy tower range so hitting a hero does not draw tower aggro.
    if J.IsLaning(bot)
    and J.GetMP(bot) > 0.5
    and #bot:GetNearbyTowers(900, true) == 0
    then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange + 50, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.5)
        and not allyHero:IsIllusion()
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
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

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if (#nInRangeAlly > #nInRangeEnemy
                    or bot:WasRecentlyDamagedByHero(enemyHero, 1.2))
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderIceBlast()
    if not IceBlast:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    -- Global: a fight anywhere on the map, AA's own included. Aim at the enemy whose surroundings the
    -- blast covers best; Frostbite stops their healing for the rest of the fight.
    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    then
        local vBest, nBestCount = X.GetBestIceBlastLocation(J.GetEnemiesNearLoc(nTeamFightLocation, 1400))
        if vBest ~= nil and nBestCount >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, vBest
        end
    end

    -- Snipe: a visible enemy the initial hit drops below the shatter threshold.
    local nDamage = IceBlast:GetAbilityDamage()
    local nKillPct = IceBlast:GetSpecialValueInt('kill_pct') / 100
    local nDamagePerSecond = IceBlast:GetSpecialValueInt('damage_per_second')
    for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnMagicImmune(enemyHero)
        and GetUnitToUnitDistance(bot, enemyHero) <= 4000
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_ice_blast')
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        then
            local nHealthAfter = enemyHero:GetHealth()
                - enemyHero:GetActualIncomingDamage(nDamage + nDamagePerSecond, DAMAGE_TYPE_MAGICAL)
            if nHealthAfter <= enemyHero:GetMaxHealth() * nKillPct
            then
                local nTravel = GetUnitToUnitDistance(bot, enemyHero) / X.GetIceBlastSpeed()
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nTravel)
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.GetIceBlastSpeed()
    local nSpeed = IceBlast:GetSpecialValueInt('speed')
    return nSpeed > 0 and nSpeed or 1500
end

-- The tracer starts at AA and the blast radius grows with its travel time:
-- radius_min + radius_grow * seconds travelled, capped at radius_max.
function X.GetIceBlastRadius(vLocation)
    local nTravel = GetUnitToLocationDistance(bot, vLocation) / X.GetIceBlastSpeed()
    return math.min(IceBlast:GetSpecialValueInt('radius_min') + IceBlast:GetSpecialValueFloat('radius_grow') * nTravel,
                    IceBlast:GetSpecialValueInt('radius_max'))
end

function X.GetBestIceBlastLocation(tEnemies)
    local vBest, nBestCount = nil, 0
    for _, enemyHero in pairs(tEnemies)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnMagicImmune(enemyHero)
        and not enemyHero:HasModifier('modifier_ice_blast')
        then
            local vLocation = enemyHero:GetLocation()
            local nCount = #J.GetEnemiesNearLoc(vLocation, X.GetIceBlastRadius(vLocation))
            if nCount > nBestCount
            then
                vBest, nBestCount = vLocation, nCount
            end
        end
    end

    return vBest, nBestCount
end

function X.ConsiderIceBlastRelease()
    if IceBlastRelease:IsHidden()
    or not IceBlastRelease:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nProjectiles = GetLinearProjectiles()

    for _, p in pairs(nProjectiles)
	do
		if p ~= nil and p.ability:GetName() == "ancient_apparition_ice_blast"
        then
			if IceBlastReleaseLocation ~= nil
            and J.GetLocationToLocationDistance(IceBlastReleaseLocation, p.location) < 100
            then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

return X