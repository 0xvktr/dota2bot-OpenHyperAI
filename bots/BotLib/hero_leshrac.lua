local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: mid; forced other roles use mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/leshrac')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Split Earth, [2] Diabolic Edict, [3] Lightning Storm, [6] Pulse Nova.
local nAbilityBuildList = {3,2,3,2,2,6,2,3,3,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +1.5 Mana regeneration
    t15={10,0}, -- Pulse Nova grants 10% damage reduction
    t20={0,10}, -- +1 Diabolic Edict target
    t25={0,10}, -- +20 Diabolic Edict explosions
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
-- Omit the observed ward: core bots do not run ward placement.
X.sBuyList = {'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_arcane_boots','item_blink','item_kaya','item_kaya_and_sange',
    'item_black_king_bar','item_veil_of_discord','item_bloodstone','item_shivas_guard','item_aghanims_shard',
    -- Bot policy: natural Blink and consumed Scepter upgrades; six persistent slots.
    'item_overwhelming_blink','item_ultimate_scepter','item_ultimate_scepter_2'}
-- Current Bloodstone consumes Veil; Shiva uses a separate recipe.
X.sSellList = {'item_blink','item_bottle','item_black_king_bar','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Split Earth at 10, first talent at 11; preserve custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local SplitEarth        = bot:GetAbilityByName('leshrac_split_earth')
local DiabolicEdict     = bot:GetAbilityByName('leshrac_diabolic_edict')
local LightningStorm    = bot:GetAbilityByName('leshrac_lightning_storm')
local Nihilism          = bot:GetAbilityByName('leshrac_greater_lightning_storm')
local PulseNova         = bot:GetAbilityByName('leshrac_pulse_nova')

local SplitEarthDesire, SplitEarthLocation
local DiabolicEdictDesire
local LightningStormDesire, LightningStormTarget
local NihilismDesire
local PulseNovaDesire

local botTarget

if bot.edictPushing == nil then bot.edictPushing = false end

local function SpellRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    return range + (lens ~= nil and lens:GetSpecialValueInt('cast_range_bonus') or 0)
end

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    if not bot:HasModifier('modifier_leshrac_diabolic_edict')
    then
        bot.edictPushing = false
    end

    -- Interrupt channels before spending a cast on routine damage or a slow.
    if J.CanCastAbility(SplitEarth) then
        for _, enemy in pairs(J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)) do
            if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
                and not J.IsSuspiciousIllusion(enemy)
                and J.IsInRange(bot, enemy, SpellRange(SplitEarth))
                and enemy:IsChanneling() then
                J.SetQueuePtToINT(bot, true, SplitEarth)
                bot:ActionQueue_UseAbilityOnLocation(SplitEarth,
                    J.GetCorrectLoc(enemy, SplitEarth:GetCastPoint() + SplitEarth:GetSpecialValueFloat('delay')))
                return
            end
        end
    end

    NihilismDesire = X.ConsiderNihilism()
    if NihilismDesire > 0 then
        bot:Action_UseAbility(Nihilism)
        return
    end

    PulseNovaDesire = X.ConsiderPulseNova()
    if PulseNovaDesire > 0
    then
        bot:Action_UseAbility(PulseNova)
        return
    end

    LightningStormDesire, LightningStormTarget = X.ConsiderLightningStorm()
    if LightningStormDesire > 0
    then
        J.SetQueuePtToINT(bot, true, LightningStorm)
        bot:ActionQueue_UseAbilityOnEntity(LightningStorm, LightningStormTarget)
        return
    end

    SplitEarthDesire, SplitEarthLocation = X.ConsiderSplitEarth()
    if SplitEarthDesire > 0
    then
        J.SetQueuePtToINT(bot, true, SplitEarth)
        bot:ActionQueue_UseAbilityOnLocation(SplitEarth, SplitEarthLocation)
        return
    end

    DiabolicEdictDesire = X.ConsiderDiabolicEdict()
    if DiabolicEdictDesire > 0
    then
        J.SetQueuePtToINT(bot, true, DiabolicEdict)
        bot:ActionQueue_UseAbility(DiabolicEdict)
        return
    end

    NihilismDesire = X.ConsiderNihilism()
    if NihilismDesire > 0
    then
        bot:Action_UseAbility(Nihilism)
        return
    end
end

function X.ConsiderSplitEarth()
    if not J.CanCastAbility(SplitEarth)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = SpellRange(SplitEarth)
    local nCastPoint = SplitEarth:GetCastPoint()
    local nRadius = SplitEarth:GetSpecialValueInt('radius')
    local nDelay = SplitEarth:GetSpecialValueFloat('delay')
    local nDamage = SplitEarth:GetAbilityDamage()
    local nManaCost = SplitEarth:GetManaCost()
    local nAbilityLevel = SplitEarth:GetLevel()

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end

            if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                if not J.IsInRange(bot, enemyHero, nCastRange)
                then
                    local loc = J.Site.GetXUnitsTowardsLocation(bot, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint), nCastRange)
                    local nInRangeEnemy = J.GetEnemiesNearLoc(loc, nRadius)
                    if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                    end

                    return BOT_ACTION_DESIRE_HIGH, loc
                end

                local nInRangeEnemy = J.GetEnemiesNearLoc(enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint), nRadius)
                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                end

                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint)
            end
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nDelay, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
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
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        then
            local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if J.IsChasingTarget(bot, botTarget)
                then
                    nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetExtrapolatedLocation(nDelay + nCastPoint), nRadius)
                else
                    nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)
                end

                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    if not J.IsInRange(bot, botTarget, nCastRange)
                    then
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
                        else
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        end
                    end
                end

                if not J.IsInRange(bot, botTarget, nCastRange)
                then
                    if J.IsChasingTarget(bot, botTarget)
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetExtrapolatedLocation(nDelay + nCastPoint), nCastRange)
                    else
                        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
                    end
                else
                    if J.IsChasingTarget(bot, botTarget)
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay + nCastPoint)
                    else
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                    end
                end

            end
        end
    end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint)
                end
            end
        end
	end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)

        if J.IsAttacking(bot)
        then
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nLocationAoE.count >= 3
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nDelay + nCastPoint, 0)
        if nLocationAoE.count >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsLaning(bot)
    and nAbilityLevel >= 2
	then
        local creepList = {}
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		for _, creep in pairs(nEnemyLaneCreeps)
		do
            if J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                table.insert(creepList, creep)
            end
		end

        if J.GetManaAfter(nManaCost) > 0.25
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and #creepList >= 2
        and J.CanBeAttacked(creepList[1])
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and not J.IsDisabled(botTarget)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nAllyInRangeEnemy)
        do
            if J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and J.GetManaAfter(nManaCost) > 0.4
            and allyHero:WasRecentlyDamagedByAnyHero(2)
            and not J.IsSuspiciousIllusion(allyHero)
            then
                if J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and J.IsChasingTarget(enemyHero, allyHero)
                and not J.IsDisabled(enemyHero)
                and not J.IsTaunted(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                and not enemyHero:HasModifier('modifier_leshrac_lightning_storm_slow')
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay + nCastPoint)
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderDiabolicEdict()
    if not J.CanCastAbility(DiabolicEdict)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = DiabolicEdict:GetSpecialValueInt('radius')
    local nManaCost = DiabolicEdict:GetManaCost()

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsFarming(bot)
    and J.GetManaAfter(nManaCost) > 0.35
    and not bot:HasModifier('modifier_leshrac_pulse_nova')
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
        if nNeutralCreeps ~= nil
        and #nNeutralCreeps > 0
        and ((#nNeutralCreeps < 3)
            or (#nNeutralCreeps <= 2 and nNeutralCreeps[1]:IsAncientCreep()))
        then
            return BOT_ACTION_DESIRE_HIGH
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps <= 3
        and #nEnemyLaneCreeps > 0
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsPushing(bot)
    and J.GetManaAfter(nManaCost) > 0.25
    then
        local nEnemyTowers = bot:GetNearbyTowers(nRadius, true)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        if nEnemyTowers ~= nil and #nEnemyTowers >= 1
        and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps <= 2
        then
            bot.edictPushing = true
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderLightningStorm()
    if not J.CanCastAbility(LightningStorm)
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = SpellRange(LightningStorm)
    local nDamage = LightningStorm:GetSpecialValueInt('damage')
    local nJumpDist = LightningStorm:GetSpecialValueInt('radius')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
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

    if J.IsInTeamFight(bot, 1200)
    then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange)
        local target = nil
        local hp = 100000

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            and not enemyHero:HasModifier('modifier_item_sphere_target')
            then
                local nTargetInRangeAlly = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nJumpDist)
                local currHP = enemyHero:GetHealth()

                if nTargetInRangeAlly ~= nil and #nTargetInRangeAlly >= 1
                and currHP < hp
                then
                    hp = currHP
                    target = enemyHero
                end
            end
        end

        if target ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, target
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsChasingTarget(bot, botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

    if J.IsFarming(bot)
    and J.GetMP(bot) > 0.35
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
        if nNeutralCreeps ~= nil
        and ((#nNeutralCreeps >= 2)
            or (#nNeutralCreeps >= 1 and nNeutralCreeps[1]:IsAncientCreep()))
        then
            return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
        end
    end

    if J.IsLaning(bot)
	then
        local creepList = {}
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			-- if J.IsValid(creep)
            -- and J.CanBeAttacked(creep)
			-- and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			-- and creep:GetHealth() <= nDamage
            -- and J.GetMP(bot) > 0.3
			-- then
			-- 	nInRangeEnemy = creep:GetNearbyHeroes(800, false, BOT_MODE_NONE)

			-- 	if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
			-- 	and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) < nInRangeEnemy[1]:GetAttackRange()
			-- 	then
			-- 		return BOT_ACTION_DESIRE_HIGH, creep
			-- 	end
			-- end

            if J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                table.insert(creepList, creep)
            end
		end

        if J.GetMP(bot) > 0.25
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and #creepList >= 2
        and J.CanBeAttacked(creepList[1])
        then
            return BOT_ACTION_DESIRE_HIGH, creepList[1]
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_roshan_spell_block')
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

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nAllyInRangeEnemy)
        do
            if J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and J.GetMP(bot) > 0.45
            and allyHero:WasRecentlyDamagedByAnyHero(1.5)
            and not J.IsSuspiciousIllusion(allyHero)
            then
                if J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and J.IsChasingTarget(enemyHero, allyHero)
                and not J.IsDisabled(enemyHero)
                and not J.IsTaunted(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderPulseNova()
    if PulseNova == nil or not PulseNova:IsTrained() or PulseNova:IsHidden()
        or not PulseNova:IsActivated() then return BOT_ACTION_DESIRE_NONE end
    local on = PulseNova:GetToggleState()
    local radius = PulseNova:GetSpecialValueInt('radius')
    local useful = false
    for _, enemy in pairs(J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and not J.CannotBeKilled(bot, enemy) then useful = true; break end
    end
    local working = (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAttacking(bot)
    if working then
        useful = useful or #bot:GetNearbyLaneCreeps(radius, true) >= 3
            or #bot:GetNearbyNeutralCreeps(radius) >= 2
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsAttacking(bot)
        and J.IsValidTarget(botTarget) and J.IsInRange(bot, botTarget, radius)
        and J.CanCastOnNonMagicImmune(botTarget) then useful = true end
    -- Turning off remains legal below the activation mana cost. Separate thresholds
    -- avoid repeatedly paying the activation cost while nearly out of mana.
    if on then
        return (not useful or J.GetMP(bot) < 0.2) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
    end
    if J.CanCastAbility(PulseNova) and useful and J.GetMP(bot) >= (working and 0.5 or 0.3)
        and bot:GetMana() >= PulseNova:GetManaCost() + PulseNova:GetSpecialValueInt('mana_cost_per_second') * 2 then
        return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderNihilism()
    if not J.CanCastAbility(Nihilism)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = Nihilism:GetSpecialValueInt('radius')
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget) and not J.IsSuspiciousIllusion(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.CannotBeKilled(bot, botTarget)
        and (PulseNova:GetToggleState() or bot:HasModifier('modifier_leshrac_diabolic_edict')) then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsWithoutTarget(bot)
    and J.GetAttackProjectileDamageByRange(bot, 1200) >= bot:GetHealth()
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsRetreating(bot)
	then
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

		if bot:WasRecentlyDamagedByAnyHero(2)
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    return BOT_ACTION_DESIRE_NONE
end

return X