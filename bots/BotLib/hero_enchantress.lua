local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: offlane and both supports; forced carry/mid use pos 5.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/enchantress')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Impetus, [2] Enchant, [3] Nature's Attendants, [6] Untouchable.
local nAbilityBuildList = sRole == 'pos_3'
    and {1,3,1,3,1,6,1,2,2,2,6,3,3,2,6}
    or {3,2,2,3,2,6,2,3,3,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +5 Enchanted creep armor
    t15={0,10}, -- +30 Enchanted creep attack speed
    t20={10,0}, -- +150 health and +25 damage to Enchanted creeps
    t25={0,10}, -- +6.5% Impetus damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_3' then
    X.sBuyList = {
        'item_tango', 'item_double_branches', 'item_circlet', 'item_circlet', 'item_faerie_fire',
        'item_null_talisman', 'item_magic_wand', 'item_power_treads', 'item_ultimate_scepter',
        -- Prefer the robust Pike progression over the less-played Orchid branch.
        'item_dragon_lance', 'item_blink', 'item_force_staff', 'item_aghanims_shard',
        'item_hurricane_pike', 'item_black_king_bar',
        -- Bot policy: consume Scepter, upgrade Blink, then add late disable/damage.
        'item_ultimate_scepter_2', 'item_swift_blink', 'item_sheepstick', 'item_moon_shard',
    }
    X.sSellList = {'item_hurricane_pike','item_null_talisman','item_black_king_bar','item_magic_wand'}
elseif sRole == 'pos_4' then
    X.sBuyList = {
        'item_tango', 'item_branches', 'item_circlet', 'item_magic_stick',
        'item_ward_observer', 'item_ward_sentry', 'item_blood_grenade',
        'item_magic_wand', 'item_power_treads', 'item_ultimate_scepter',
        'item_dragon_lance', 'item_force_staff', 'item_aghanims_shard', 'item_orchid', 'item_hurricane_pike',
        -- Bot policy: upgrade Orchid, protect attacks, and add late disable within six slots.
        'item_bloodthorn', 'item_black_king_bar', 'item_ultimate_scepter_2', 'item_sheepstick', 'item_moon_shard',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand'}
else
    X.sBuyList = {
        'item_tango', 'item_double_branches', 'item_circlet',
        'item_faerie_fire', 'item_blood_grenade',
        'item_magic_wand', 'item_power_treads', 'item_ultimate_scepter',
        'item_force_staff', 'item_dragon_lance', 'item_aghanims_shard', 'item_hurricane_pike', 'item_witch_blade',
        -- Bot policy: natural upgrade, attack protection, and late disable within six slots.
        'item_revenants_brooch', 'item_black_king_bar', 'item_ultimate_scepter_2', 'item_sheepstick', 'item_moon_shard',
    }
    if sRole == 'pos_5' then table.insert(X.sBuyList, 4, 'item_ward_sentry') end
    X.sSellList = {'item_black_king_bar','item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT takes a basic at level 10, then the first talent; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Impetus           = bot:GetAbilityByName('enchantress_impetus')
local Enchant           = bot:GetAbilityByName('enchantress_enchant')
local NaturesAttendant  = bot:GetAbilityByName('enchantress_natures_attendants')
local Sproink           = bot:GetAbilityByName('enchantress_bunny_hop')
local LittleFriends     = bot:GetAbilityByName('enchantress_little_friends')
-- local Untouchable       = bot:GetAbilityByName('enchantress_untouchable')

local ImpetusDesire
local EnchantDesire, EnchantTarget
local NaturesAttendantDesire
local SproinkDesire
local LittleFriendsDesire, LittleFriendsTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot)
    then
        return
    end

    LittleFriendsDesire, LittleFriendsTarget = X.ConsiderLittleFriends()
    if LittleFriendsDesire > 0
    then
        bot:Action_UseAbilityOnEntity(LittleFriends, LittleFriendsTarget)
        return
    end

    ImpetusDesire = X.ConsiderImpetus()
    if ImpetusDesire > 0
    then
        return
    end

    SproinkDesire = X.ConsiderSproink()
    if SproinkDesire > 0
    then
        bot:Action_UseAbility(Sproink)
        return
    end

    NaturesAttendantDesire = X.ConsiderNaturesAttendant()
    if NaturesAttendantDesire > 0
    then
        bot:Action_UseAbility(NaturesAttendant)
        return
    end

    EnchantDesire, EnchantTarget = X.ConsiderEnchant()
    if EnchantDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Enchant, EnchantTarget)
        return
    end
end

function X.ConsiderImpetus()
    if not Impetus:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nAttackRange = bot:GetAttackRange()
    local nAbilityLevel = Impetus:GetLevel()
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
        then
            if not Impetus:GetAutoCastState()
            then
                Impetus:ToggleAutoCast()
                return BOT_ACTION_DESIRE_HIGH
            else
                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsFarming(bot)
    and nAbilityLevel == 4
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nAttackRange)

        if nNeutralCreeps ~= nil and #nNeutralCreeps >= 1
        and J.IsValid(nNeutralCreeps[1])
        then
            if not Impetus:GetAutoCastState()
            then
                Impetus:ToggleAutoCast()
                return BOT_ACTION_DESIRE_HIGH
            else
                if Impetus:GetAutoCastState()
                and J.GetMP(bot) < 0.25
                then
                    Impetus:ToggleAutoCast()
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            if not Impetus:GetAutoCastState()
            then
                Impetus:ToggleAutoCast()
                return BOT_ACTION_DESIRE_HIGH
            else
                if Impetus:GetAutoCastState()
                and J.GetMP(bot) < 0.25
                then
                    Impetus:ToggleAutoCast()
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            if not Impetus:GetAutoCastState()
            then
                Impetus:ToggleAutoCast()
                return BOT_ACTION_DESIRE_HIGH
            else
                if Impetus:GetAutoCastState()
                and J.GetMP(bot) < 0.25
                then
                    Impetus:ToggleAutoCast()
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if Impetus:GetAutoCastState()
    then
        Impetus:ToggleAutoCast()
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderEnchant()
    if not Enchant:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = Enchant:GetCastRange()
    local nMaxLevel = Enchant:GetSpecialValueInt('level_req')
    local nDamage = Enchant:GetSpecialValueInt('enchant_damage')
    local nDuration = Enchant:GetSpecialValueFloat('slow_duration')
	local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange)
    local botTarget = J.GetProperTarget(bot)

    -- local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    -- for _, enemyHero in pairs(nEnemyHeroes)
    -- do
    --     if J.IsValidHero(enemyHero)
    --     and J.CanCastOnNonMagicImmune(enemyHero)
    --     and J.CanKillTarget(enemyHero, nDamage * nDuration, DAMAGE_TYPE_ALL)
    --     and not J.IsSuspiciousIllusion(enemyHero)
    --     then
    --         return BOT_ACTION_DESIRE_HIGH, enemyHero
    --     end
    -- end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, nCastRange, true, BOT_MODE_NONE)

        if J.IsRetreating(allyHero)
        and J.IsValidHero(nAllyInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
        and not J.IsDisabled(nAllyInRangeEnemy[1])
        then
            if J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 100, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and ((#nInRangeAlly >= #nInRangeEnemy) or (#nInRangeEnemy > #nInRangeAlly and J.WeAreStronger(bot, nCastRange + 100)))
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    local nGoodCreep = {
        "npc_dota_neutral_alpha_wolf",
        "npc_dota_neutral_centaur_khan",
        "npc_dota_neutral_polar_furbolg_ursa_warrior",
        "npc_dota_neutral_dark_troll_warlord",
        "npc_dota_neutral_satyr_hellcaller",
        "npc_dota_neutral_enraged_wildkin",
        "npc_dota_neutral_warpine_raider",
    }

    for _, creep in pairs(nNeutralCreeps)
    do
        if J.IsValid(creep)
        and creep:GetLevel() <= nMaxLevel
        then
            for _, gCreep in pairs(nGoodCreep)
            do
                if creep:GetUnitName() == gCreep
                then
                    return BOT_ACTION_DESIRE_HIGH, creep
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderNaturesAttendant()
    if not NaturesAttendant:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.IsRetreating(bot)
    then
        if J.GetHP(bot) < 0.65
        and bot:DistanceFromFountain() > 800
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSproink()
    if not Sproink:IsTrained()
    or not Sproink:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nAttackRange = bot:GetAttackRange()

    local nAllyHeroes = J.GetNearbyHeroes(bot,nAttackRange + 100, false, BOT_MODE_NONE)
    local nEnemyHeroes = J.GetNearbyHeroes(bot,nAttackRange, true, BOT_MODE_NONE)
    local nImpetusMul = Impetus:GetSpecialValueFloat('value') / 100
    local botTarget = J.GetProperTarget(bot)

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanKillTarget(enemyHero, nImpetusMul * GetUnitToUnitDistance(bot, enemyHero), DAMAGE_TYPE_PURE)
        and bot:IsFacingLocation(enemyHero:GetLocation(), 15)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and bot:IsFacingLocation(botTarget:GetLocation(), 15)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsRetreating(bot)
    then
        if nAllyHeroes ~= nil and nEnemyHeroes ~= nil
        and #nEnemyHeroes > #nAllyHeroes
        and J.IsValidHero(nEnemyHeroes[1])
        and bot:IsFacingLocation(nEnemyHeroes[1]:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nEnemyHeroes[1])
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderLittleFriends()
    if not LittleFriends:IsTrained()
    or not LittleFriends:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = LittleFriends:GetCastRange()
    local nRadius = LittleFriends:GetSpecialValueInt('radius')
    local nDuration = LittleFriends:GetSpecialValueInt('duration')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.GetHP(enemyHero) < 0.33
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_faceless_void_chronosphere')
        then
            bot:SetTarget(enemyHero)
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    if J.IsGoingOnSomeone(bot, 1200)
    then
        if J.IsValidTarget(npcTarget)
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        and #nTargetInRangeEnemy >= 1
        and not J.IsSuspiciousIllusion(npcTarget)
        and not npcTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not npcTarget:HasModifier('modifier_faceless_void_chronosphere')
        then
            local botTarget = J.GetStrongestUnit(nCastRange, bot, true, false, nDuration)
            local nTargetInRangeEnemy = J.GetNearbyHeroes(botTarget, nRadius, true, BOT_MODE_NONE)
            local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 150, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 150, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeEnemy > #nInRangeAlly
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
        end
    end

    if J.IsDoingRoshan(bot)
    then
        local botTarget = bot:GetAttackTarget()

        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X
