local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local R             = dofile( GetScriptDirectory()..'/FunLib/rubick_utility' )
local SPL           = dofile( GetScriptDirectory()..'/FunLib/spell_prob_list' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: support/hard support/mid; forced carry/offlane use support.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/rubick')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Telekinesis, [2] Fade Bolt, [3] Arcane Supremacy, [6] Spell Steal.
local nAbilityBuildList = {2,1,2,3,2,6,2,3,3,3,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +200 Health
    t15={0,10}, -- -40% Stolen Spells Mana Cost
    t20={10,0}, -- Telekinesis Landing Deals 300 Damage
    t25={10,0}, -- +40% Spell Amp For Stolen Spells
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_2' then
    -- Omit the observed ward: core bots do not place wards.
    X.sBuyList = {
        'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
        'item_bottle','item_magic_wand','item_power_treads','item_phylactery','item_kaya',
        'item_blink','item_ultimate_scepter','item_aghanims_shard','item_yasha_and_kaya',
        -- Bot policy: survival, natural upgrades and consumed Scepter keep six major slots.
        'item_black_king_bar','item_angels_demise','item_ultimate_scepter_2','item_octarine_core','item_arcane_blink',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand','item_ultimate_scepter','item_bottle'}
else
    X.sBuyList = {'item_double_branches','item_magic_stick','item_tango','item_faerie_fire','item_blood_grenade'}
    if sRole == 'pos_4' then
        -- Observed dispenser charges do not identify ward types; bot policy buys one of each.
        table.insert(X.sBuyList,'item_ward_observer')
        table.insert(X.sBuyList,'item_ward_sentry')
    elseif sRole == 'pos_5' then
        table.insert(X.sBuyList,'item_ward_sentry')
    end
    local core = {'item_magic_wand'}
    if sRole ~= 'pos_5' then
        table.insert(core,'item_urn_of_shadows')
    end
    table.insert(core,'item_arcane_boots')
    if sRole ~= 'pos_5' then table.insert(core,'item_essence_distiller') end
    local progression = {'item_blink','item_aether_lens','item_aghanims_shard','item_glimmer_cape','item_ultimate_scepter'}
    for _, item in ipairs(progression) do table.insert(core,item) end
    -- Bot policy: a late disable, consumed Scepter and Blink/Eul upgrades fit six major slots.
    local late = {'item_ultimate_scepter_2','item_cyclone'}
    if sRole == 'pos_5' then table.insert(late,'item_octarine_core') end
    table.insert(late,'item_wind_waker')
    table.insert(late,'item_arcane_blink')
    for _, item in ipairs(late) do table.insert(core,item) end
    for _, item in ipairs(core) do table.insert(X.sBuyList,item) end
    X.sSellList = {'item_ultimate_scepter','item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end
nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'])
X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Fourth Arcane Supremacy point at 10, first talent at 11; preserve custom progressions.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Telekinesis       = bot:GetAbilityByName('rubick_telekinesis')
local TelekinesisLand   = bot:GetAbilityByName('rubick_telekinesis_land')
local FadeBolt          = bot:GetAbilityByName('rubick_fade_bolt')
local StolenSpell1      = bot:GetAbilityByName('rubick_empty1')
local StolenSpell2      = bot:GetAbilityByName('rubick_empty2')
local SpellSteal        = bot:GetAbilityByName('rubick_spell_steal')

local TelekinesisDesire, TelekinesisTarget
local TelekinesisLandDesire, TelekinesisLandLocation
local FadeBoltDesire, FadeBoltTarget
local SpellStealDesire, SpellStealTarget

local botTarget
local lastTimeStealSpell = -90

if bot.shouldBlink == nil then bot.shouldBlink = false end

local linkedSlots = {7,8,19,20,21}
local function considerLinkedSpells(releaseOnly)
    for _, slot in ipairs(linkedSlots) do
        local ability = bot:GetAbilityInSlot(slot)
        if ability ~= nil and (not releaseOnly or ability:GetName() == 'ancient_apparition_ice_blast_release')
            and R.ConsiderStolenSpell(ability)
        then
            return true
        end
    end
    return false
end

function X.SkillsComplement()
    if bot:IsChanneling() or bot:IsUsingAbility() or bot:IsCastingAbility() then return end
    if J.CanNotUseAbility(bot) then
        -- Ice Blast Release ignores silence; other stolen spells retain the normal cast gate.
        if bot:IsSilenced() and not J.HasQueuedAction(bot) then considerLinkedSpells(true) end
        return
    end

    botTarget = J.GetProperTarget(bot)
    StolenSpell1 = bot:GetAbilityInSlot(3)
    StolenSpell2 = bot:GetAbilityInSlot(4)

    TelekinesisLandDesire, TelekinesisLandLocation = X.ConsiderTelekinesisLand()
    if TelekinesisLandDesire > 0 then
        bot:Action_UseAbilityOnLocation(TelekinesisLand, TelekinesisLandLocation)
        bot.isChannelLand, bot.isSaveUltLand, bot.isEngagingLand = false, false, false
        bot.isRetreatLand, bot.isSaveAllyLand = false, false
        return
    end
    if considerLinkedSpells(false) or X.ConsiderStolenSpell1() or X.ConsiderStolenSpell2() then return end

    -- Consider stealing after using the spells already available.
    SpellStealDesire, SpellStealTarget = X.ConsiderSpellSteal()
    if SpellStealDesire > 0
    then
        bot:Action_UseAbilityOnEntity(SpellSteal, SpellStealTarget)
        lastTimeStealSpell = DotaTime()
        return
    end

    TelekinesisDesire, TelekinesisTarget = X.ConsiderTelekinesis()
    if TelekinesisDesire > 0
    then
        bot.teleTarget = TelekinesisTarget
        bot:Action_UseAbilityOnEntity(Telekinesis, TelekinesisTarget)
        return
    end

    FadeBoltDesire, FadeBoltTarget = X.ConsiderFadeBolt()
    if FadeBoltDesire > 0
    then
        bot:Action_UseAbilityOnEntity(FadeBolt, FadeBoltTarget)
        return
    end
end

function X.ConsiderTelekinesis()
    if Telekinesis:IsHidden()
    or not Telekinesis:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    bot.isChannelLand, bot.isSaveUltLand, bot.isEngagingLand = false, false, false
    bot.isRetreatLand, bot.isSaveAllyLand = false, false
    local nCastRange = Telekinesis:GetCastRange()

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 300, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                bot.isChannelLand = true
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if J.IsValidHero(allyHero)
            and bot:HasShard()
            and J.IsInRange(bot, allyHero, nCastRange)
            and J.IsCore(allyHero)
            and not J.IsSuspiciousIllusion(allyHero)
            and not allyHero:IsInvulnerable()
            and not allyHero:IsAttackImmune()
            and not allyHero:HasModifier('modifier_furion_sprout_damage')
            and not allyHero:HasModifier('modifier_legion_commander_duel')
            and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                if allyHero:HasModifier('modifier_enigma_black_hole_pull')
                or allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
                then
                    bot.isSaveUltLand = true
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end
        end

		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_furion_sprout_damage')
        and not botTarget:HasModifier('modifier_legion_commander_duel')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            nInRangeAlly =  J.GetAlliesNearLoc(botTarget:GetLocation(), 1200)
            nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            and not (#nInRangeEnemy == 0 and #nInRangeAlly >= #nInRangeEnemy + 2)
            then
                bot.isEngagingLand = true
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
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not enemyHero:HasModifier('modifier_furion_sprout_damage')
			then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and (#nTargetInRangeAlly > #nInRangeAlly
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    bot.isRetreatLand = true
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
			end
		end
	end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and not allyHero:IsIllusion()
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_furion_sprout_damage')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                bot.isSaveAllyLand = true
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

	if J.IsDoingRoshan(bot)
	then
        -- Remove Spell Block
		if J.IsRoshan(botTarget)
        and J.CanCastOnMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and botTarget:HasModifier('modifier_roshan_spell_block')
		then
			return BOT_ACTION_DESIRE_LOW, botTarget
		end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderTelekinesisLand()
    if TelekinesisLand:IsHidden()
    or not TelekinesisLand:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    if not J.IsValid(bot.teleTarget) then return BOT_ACTION_DESIRE_NONE, nil end
    local nDistance = Telekinesis:GetSpecialValueInt('max_land_distance')
    local function landingTowards(location)
        local distance = GetUnitToLocationDistance(bot.teleTarget, location)
        if distance <= nDistance then return location end
        return J.Site.GetXUnitsTowardsLocation(bot.teleTarget, location, nDistance)
    end

    local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
    local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

    if J.IsValidHero(botTarget)
    and not J.IsSuspiciousIllusion(botTarget)
    then
        nInRangeAlly = J.GetAlliesNearLoc(botTarget:GetLocation(), 1200)
        nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)
    end

    if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
    and J.IsValid(bot.teleTarget)
    then
        if bot.isChannelLand ~= nil
        and bot.isChannelLand == true
        then
            if #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, landingTowards(bot:GetLocation())
            end

            if #nInRangeEnemy > #nInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, landingTowards(J.GetEnemyFountain())
            end
        end

        if bot.isSaveUltLand ~= nil
        and bot.isSaveUltLand == true
        then
            return BOT_ACTION_DESIRE_HIGH, landingTowards(J.GetTeamFountain())
        end

        if bot.isEngagingLand ~= nil
        and bot.isEngagingLand == true
        then
            return BOT_ACTION_DESIRE_HIGH, landingTowards(bot:GetLocation())
        end

        if bot.isRetreatLand ~= nil
        and bot.isRetreatLand == true
        then
            return BOT_ACTION_DESIRE_HIGH, landingTowards(J.GetEnemyFountain())
        end

        if bot.isSaveAllyLand ~= nil
        and bot.isSaveAllyLand == true
        then
            return BOT_ACTION_DESIRE_HIGH, landingTowards(J.GetEnemyFountain())
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderFadeBolt()
    if not FadeBolt:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, FadeBolt:GetCastRange())
    local nDamage = FadeBolt:GetSpecialValueInt('damage')
    local nRadius = FadeBolt:GetSpecialValueInt('radius')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_rubick_telekinesis')
        then
            if J.IsInEtherealForm(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
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
            and J.IsAttacking(nAllyInRangeEnemy[1])
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_rubick_telekinesis')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
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
            and not enemyHero:HasModifier('modifier_rubick_telekinesis')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                local nTargetInRangeAlly = J.GetEnemiesNearLoc(enemyHero:GetLocation(), nRadius)
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
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_rubick_telekinesis')
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
            and J.IsAttacking(enemyHero)
            and not J.IsInRange(bot, enemyHero, 300)
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

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
        end
    end

    if J.IsLaning(bot)
    and not J.IsThereNonSelfCoreNearby(800)
	then
        local creepList = {}
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if J.IsValid(creep)
            and J.CanBeAttacked(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
            and J.GetMP(bot) > 0.3
			then
				if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) < 500
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end

            if J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                table.insert(creepList, creep)
            end
		end

        if J.GetMP(bot) > 0.3
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
        and J.IsInRange(bot, botTarget, nCastRange)
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

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderStolenSpell1()
    return R.ConsiderStolenSpell(StolenSpell1)
end

function X.ConsiderStolenSpell2()
    return R.ConsiderStolenSpell(StolenSpell2)
end

local function hasStolenSpell(ability)
    return ability ~= nil and not ability:IsNull() and ability:GetName() ~= 'rubick_empty1'
        and ability:GetName() ~= 'rubick_empty2' and not ability:IsHidden() and not ability:IsPassive()
end

local function canReplaceSpell(ability)
    if not hasStolenSpell(ability) then return true end
    if DotaTime() - lastTimeStealSpell < 60 and ability:IsFullyCastable() and ability:IsUltimate() then return false end
    if ability:GetCooldownTimeRemaining() < 5 and ability:GetAbilityDamage() >= 280 then return false end
    return SPL.GetSpellReplaceWeight(ability:GetName()) * 100 >= RandomInt(1,100)
end

function X.ConsiderSpellSteal()
    if not SpellSteal:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end
    -- Keep pending projectile release/brew throws until their linked handler finishes.
    for _, slot in ipairs(linkedSlots) do
        local ability = bot:GetAbilityInSlot(slot)
        if ability ~= nil and not ability:IsNull() and not ability:IsHidden() and ability:IsFullyCastable()
            and (ability:GetName() == 'ancient_apparition_ice_blast_release'
                or ability:GetName() == 'alchemist_unstable_concoction_throw')
        then
            return BOT_ACTION_DESIRE_NONE, nil
        end
    end

    local hasFirst, hasSecond = hasStolenSpell(StolenSpell1), hasStolenSpell(StolenSpell2)
    if bot:HasScepter() then
        -- Fill an empty slot; with two retained spells, protect both until eviction order is verified.
        if hasFirst and hasSecond and (not canReplaceSpell(StolenSpell1) or not canReplaceSpell(StolenSpell2)) then
            return BOT_ACTION_DESIRE_NONE, nil
        end
    elseif not canReplaceSpell(StolenSpell1) then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = SpellSteal:GetCastRange()
    for _, enemyHero in pairs(J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange)) do
        if J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsMeepoClone(enemyHero)
            and (enemyHero:IsUsingAbility() or enemyHero:IsCastingAbility()
                or J.IsCastingUltimateAbility(enemyHero) or enemyHero:GetLevel() > 10)
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

return X
