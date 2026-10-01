local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: positions 3 (offlane) and 2 (mid); forced other roles use pos 3.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/brewmaster')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Thunder Clap, [2] Cinder Brew, [3] Drunken Brawler, [6] Primal Split.
-- D2PT shows only the first ten levels; later levels are a legal continuation.
local nAbilityBuildList
if sRole == 'pos_2' then
    nAbilityBuildList = {1,3,1,2,2,6,2,2,1,1,6,3,3,3,6}
else
    nAbilityBuildList = {2,1,2,3,2,6,2,3,3,3,6,1,1,1,6}
end
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +13 Brewlings base damage
    t15={10,0}, -- +600 Brewlings health
    t20={0,10}, -- -12s Primal Split cooldown
    t25={0,10}, -- 1.5x Drunken Brawler stance bonuses
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_2' then
    X.sBuyList = {
        'item_tango', 'item_double_branches', 'item_double_circlet', 'item_bracer', 'item_urn_of_shadows',
        'item_phase_boots', 'item_blink', 'item_vladmir', 'item_ultimate_scepter', 'item_assault',
        -- Reviewed late continuation, not D2PT core.
        'item_aghanims_shard', 'item_ultimate_scepter_2', 'item_overwhelming_blink', 'item_moon_shard',
    }
    X.sSellList = {
        'item_blink', 'item_bracer',
        'item_blink', 'item_circlet',
        'item_assault', 'item_urn_of_shadows',
    }
else
    X.sBuyList = {
        'item_tango', 'item_quelling_blade', 'item_branches', 'item_circlet', 'item_magic_stick', 'item_bracer',
        'item_urn_of_shadows', 'item_magic_wand', 'item_phase_boots', 'item_spirit_vessel', 'item_ultimate_scepter',
        'item_blink', 'item_assault', 'item_refresher',
        -- Reviewed late continuation, not D2PT core.
        'item_aghanims_shard', 'item_ultimate_scepter_2', 'item_overwhelming_blink', 'item_travel_boots',
        'item_moon_shard',
    }
    X.sSellList = {
        'item_phase_boots', 'item_quelling_blade',
        'item_blink', 'item_bracer',
        'item_assault', 'item_magic_wand',
        'item_refresher', 'item_spirit_vessel',
        'item_travel_boots', 'item_phase_boots',
    }
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Level 10 still spends an ability point in both roles, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local ThunderClap = bot:GetAbilityByName('brewmaster_thunder_clap')
local CinderBrew = bot:GetAbilityByName('brewmaster_cinder_brew')
local DrunkenBrawler = bot:GetAbilityByName('brewmaster_drunken_brawler')
local PrimalSplit = bot:GetAbilityByName('brewmaster_primal_split')
local LiquidCourage = bot:GetAbilityByName('brewmaster_liquid_courage')
local pendingBrew
local drunkenBrawlerState = 1

function X.SkillsComplement()
    -- Stance cycling explicitly ignores silence, unlike the other active spells.
    if not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsChanneling() or bot:IsUsingAbility() or bot:IsCastingAbility()
        or bot:NumQueuedActions() > 0 then return end
    if not J.CanNotUseAbility(bot) then
        if X.ConsiderPrimalSplit() > 0 then bot:Action_UseAbility(PrimalSplit); return end
        if X.ConsiderThunderClap(true) > 0 then
            bot:Action_UseAbility(ThunderClap)
            return
        end
        local desire, target = X.ConsiderLiquidCourage()
        if desire > 0 then bot:Action_UseAbilityOnEntity(LiquidCourage, target); return end
        local brew, location = X.ConsiderCinderBrew()
        if brew > 0 then
            -- Use a direct cast so the impact budget is not displaced by a Treads queue.
            pendingBrew = DotaTime() + CinderBrew:GetCastPoint()
                + GetUnitToLocationDistance(bot, location) / CinderBrew:GetSpecialValueInt('projectile_speed') + 0.1
            bot:Action_UseAbilityOnLocation(CinderBrew, location)
            return
        end
        if X.ConsiderThunderClap() > 0 then
            J.SetQueuePtToINT(bot, false)
            bot:ActionQueue_UseAbility(ThunderClap)
            return
        end
    end
    local desire, state = X.ConsiderDrunkenBrawler()
    if desire > 0 and drunkenBrawlerState ~= state then
        bot:Action_UseAbility(DrunkenBrawler)
        drunkenBrawlerState = drunkenBrawlerState % 3 + 1
        return
    end
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit)
    return J.IsValidTarget(unit) and J.CanCastOnNonMagicImmune(unit)
        and not J.IsSuspiciousIllusion(unit)
        and not unit:HasModifier('modifier_abaddon_borrowed_time')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end

local function ReserveSplit(ability)
    return PrimalSplit ~= nil and J.CanCastAbility(PrimalSplit)
        and #bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE) > 0
        and bot:GetMana() < ability:GetManaCost() + PrimalSplit:GetManaCost()
end

local function BrewLocation(location, radius)
    local range = CastRange(CinderBrew)
    local distance = GetUnitToLocationDistance(bot, location)
    if distance <= range then return location end
    if distance <= range + radius then
        return J.Site.GetXUnitsTowardsLocation(bot, location, range)
    end
    return nil
end

function X.ConsiderPrimalSplit()
    if not J.CanCastAbility(PrimalSplit) then return BOT_ACTION_DESIRE_NONE end
    local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
    local threats = 0
    for _, enemy in pairs(enemies) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and not enemy:IsInvulnerable() then threats = threats + 1 end
    end
    if threats > 0 and bot:WasRecentlyDamagedByAnyHero(3)
        and (J.GetHP(bot) < 0.35 or (J.IsRetreating(bot) and threats >= 2)) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsInTeamFight(bot, 1200) and threats >= 2 then return BOT_ACTION_DESIRE_HIGH end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidTarget(target)
        and not J.IsSuspiciousIllusion(target) and not target:IsAttackImmune()
        and not target:IsInvulnerable() and J.IsInRange(bot, target, 700)
        and not target:HasModifier('modifier_abaddon_borrowed_time')
        and not J.IsLocationInChrono(target:GetLocation())
        and J.IsCore(target) and J.WeAreStronger(bot, 1200) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderThunderClap(lethalOnly)
    if not J.CanCastAbility(ThunderClap) then return BOT_ACTION_DESIRE_NONE end
    local radius = ThunderClap:GetSpecialValueInt('radius')
    local damage = ThunderClap:GetSpecialValueInt('damage')
    local enemies = bot:GetNearbyHeroes(radius, true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, radius)
            and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL)
            and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_oracle_false_promise_timer')
            and not enemy:HasModifier('modifier_templar_assassin_refraction_absorb') then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    if lethalOnly then return BOT_ACTION_DESIRE_NONE end
    if ReserveSplit(ThunderClap) then return BOT_ACTION_DESIRE_NONE end
    -- Let the barrel arrive before spending the ignition damage.
    if pendingBrew ~= nil and DotaTime() < pendingBrew then return BOT_ACTION_DESIRE_NONE end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsInRange(bot, target, radius) then
        return BOT_ACTION_DESIRE_HIGH
    end
    for _, enemy in pairs(enemies) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, radius)
            and ((J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2))
                or (J.IsLaning(bot) and J.GetMP(bot) > 0.5)) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    local creeps = bot:GetNearbyLaneCreeps(radius, true)
    if J.IsLaning(bot) and J.GetMP(bot) > 0.35 then
        local kills = 0
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and J.CanBeAttacked(creep)
                and J.IsInRange(bot, creep, radius)
                and J.CanKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL) then
                kills = kills + 1
                if #enemies > 0 and (J.IsKeyWordUnit('ranged', creep)
                    or J.IsKeyWordUnit('siege', creep)) then return BOT_ACTION_DESIRE_HIGH end
            end
        end
        if kills >= 2 then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsAttacking(bot) and J.GetMP(bot) > 0.4 then
        if (J.IsPushing(bot) or J.IsDefending(bot)) and #creeps >= 4 then
            return BOT_ACTION_DESIRE_HIGH
        end
        if J.IsFarming(bot) then
            local neutrals = bot:GetNearbyNeutralCreeps(radius)
            if #creeps >= 3 or #neutrals >= 3
                or (#neutrals >= 2 and neutrals[1]:IsAncientCreep()) then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
        if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot))
            and J.IsValid(target) and J.IsInRange(bot, target, radius)
            and J.CanCastOnNonMagicImmune(target) then return BOT_ACTION_DESIRE_HIGH end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCinderBrew()
    if not J.CanCastAbility(CinderBrew) or ReserveSplit(CinderBrew) then
        return BOT_ACTION_DESIRE_NONE, nil
    end
    local radius = CinderBrew:GetSpecialValueInt('radius')
    local range = CastRange(CinderBrew)
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) or J.IsLaning(bot) then
        if Enemy(target) and not target:HasModifier('modifier_brewmaster_cinder_brew')
            and (not J.IsLaning(bot) or J.GetMP(bot) > 0.45) then
            local delay = CinderBrew:GetCastPoint()
                + GetUnitToUnitDistance(bot, target) / CinderBrew:GetSpecialValueInt('projectile_speed')
            local predicted = J.GetCorrectLoc(target, delay)
            local location = BrewLocation(predicted, radius)
            if location ~= nil and GetLocationToLocationDistance(location, predicted) <= radius then
                return BOT_ACTION_DESIRE_HIGH, location
            end
        end
    end
    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
        for _, enemy in pairs(bot:GetNearbyHeroes(math.min(1600, range), true, BOT_MODE_NONE)) do
            if Enemy(enemy) and bot:WasRecentlyDamagedByHero(enemy, 2)
                and J.IsChasingTarget(enemy, bot)
                and not enemy:HasModifier('modifier_brewmaster_cinder_brew') then
                return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
            end
        end
    end
    if J.IsInTeamFight(bot, 1200) or J.IsPushing(bot) or J.IsDefending(bot) then
        local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), range, radius,
            CinderBrew:GetCastPoint(), 0)
        local useful = 0
        for _, enemy in pairs(J.GetEnemiesNearLoc(aoe.targetloc, radius)) do
            if Enemy(enemy) and not enemy:HasModifier('modifier_brewmaster_cinder_brew') then
                useful = useful + 1
            end
        end
        if useful >= 2 and GetUnitToLocationDistance(bot, aoe.targetloc) <= range then
            return BOT_ACTION_DESIRE_HIGH, aoe.targetloc
        end
    end
    if J.IsAttacking(bot) and J.GetMP(bot) > 0.45
        and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then
        local neutrals = bot:GetNearbyNeutralCreeps(math.min(range, 1600))
        local creeps = bot:GetNearbyLaneCreeps(math.min(range, 1600), true)
        for _, list in ipairs({neutrals, creeps}) do
            for _, center in pairs(list) do
                if J.IsValid(center) and J.CanBeAttacked(center) then
                    local count = 0
                    for _, creep in pairs(list) do
                        if J.IsValid(creep) and J.CanBeAttacked(creep)
                            and GetUnitToUnitDistance(center, creep) <= radius then count = count + 1 end
                    end
                    if count >= 3 or (count >= 2 and center:IsAncientCreep()) then
                        return BOT_ACTION_DESIRE_HIGH, center:GetLocation()
                    end
                end
            end
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsAttacking(bot)
        and J.IsValid(target) and J.CanCastOnNonMagicImmune(target)
        and J.IsInRange(bot, target, range) then
        return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDrunkenBrawler()
    if not J.CanCastAbility(DrunkenBrawler) then return BOT_ACTION_DESIRE_NONE end
    for state, name in ipairs({'earth', 'storm', 'fire'}) do
        if bot:HasModifier('modifier_brewmaster_drunken_brawler_' .. name) then
            drunkenBrawlerState = state
        end
    end
    if J.GetHP(bot) < 0.33 and bot:WasRecentlyDamagedByAnyHero(3) then
        return BOT_ACTION_DESIRE_HIGH, 1
    end
    if J.IsRetreating(bot) then return BOT_ACTION_DESIRE_HIGH, 2 end
    if J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH, 3 end
    return BOT_ACTION_DESIRE_HIGH, 2
end

function X.ConsiderLiquidCourage()
    -- The base innate is passive; only the live Shard unit-target version can cast.
    if not J.CanCastAbility(LiquidCourage)
        or not J.CheckBitfieldFlag(LiquidCourage:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
        or ReserveSplit(LiquidCourage) then return BOT_ACTION_DESIRE_NONE, nil end
    local allies = bot:GetNearbyHeroes(CastRange(LiquidCourage), false, BOT_MODE_NONE)
    table.insert(allies, bot)
    local weakest, health = nil, 1
    for _, ally in pairs(allies) do
        if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally)
            and not ally:IsInvulnerable() and not ally:IsChanneling()
            and J.IsInRange(bot, ally, CastRange(LiquidCourage))
            and not ally:HasModifier('modifier_necrolyte_reapers_scythe') then
            local hp = J.GetHP(ally)
            if hp < 0.7 and hp < health and ally:WasRecentlyDamagedByAnyHero(3) then
                weakest, health = ally, hp
            end
        end
    end
    if weakest ~= nil then return BOT_ACTION_DESIRE_HIGH, weakest end
    return BOT_ACTION_DESIRE_NONE, nil
end

return X
