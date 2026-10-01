local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: positions 1 (carry) and 2 (mid); forced other roles use pos 1.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/clinkz')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Strafe, [2] Searing Arrows, [3] Death Pact, [6] Skeleton Walk.
-- Both roles share D2PT's most popular first ten levels and talents; later levels are a legal continuation.
local nAbilityBuildList = {2,3,2,3,3,6,2,2,1,1,6,3,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- -4s Skeleton Walk cooldown
    t15={0,10}, -- +50 attack range
    t20={0,10}, -- +40 Strafe attack speed
    t25={10,0}, -- Searing Arrows multishot
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_faerie_fire', 'item_magic_wand', 'item_branches',
    'item_falcon_blade', 'item_power_treads', 'item_desolator', 'item_aghanims_shard',
    'item_dragon_lance', 'item_lesser_crit', 'item_greater_crit', 'item_hurricane_pike',
}
if sRole == 'pos_2' then
    -- D2PT mid buys Nullifier before BKB.
    for _, item in ipairs({'item_nullifier', 'item_black_king_bar'}) do table.insert(X.sBuyList, item) end
    X.sSellList = {
        'item_hurricane_pike', 'item_magic_wand',
        'item_black_king_bar', 'item_falcon_blade',
    }
else
    for _, item in ipairs({'item_black_king_bar', 'item_sheepstick'}) do table.insert(X.sBuyList, item) end
    X.sSellList = {
        'item_hurricane_pike', 'item_magic_wand',
        'item_sheepstick', 'item_falcon_blade',
    }
end
-- Late upgrades/slot policy beyond the displayed core progression.
for _, item in ipairs({'item_ultimate_scepter_2', 'item_moon_shard'}) do table.insert(X.sBuyList, item) end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Strafe takes level 10, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local Strafe = bot:GetAbilityByName('clinkz_strafe')
local DeathPact = bot:GetAbilityByName('clinkz_death_pact')
local BurningBarrage = bot:GetAbilityByName('clinkz_burning_barrage')
local SkeletonWalk = bot:GetAbilityByName('clinkz_wind_walk')
local SearingArrows = bot:GetAbilityByName('clinkz_searing_arrows')

local function Castable(ability)
    return ability ~= nil and ability:IsFullyCastable() and not ability:IsHidden()
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Protected(unit)
    return unit:HasModifier('modifier_abaddon_borrowed_time')
        or unit:HasModifier('modifier_dazzle_shallow_grave')
        or unit:HasModifier('modifier_oracle_false_promise_timer')
        or unit:HasModifier('modifier_necrolyte_reapers_scythe')
        or unit:HasModifier('modifier_item_blade_mail_reflect')
end

local function Attackable(unit)
    return J.IsValid(unit) and J.CanBeAttacked(unit) and not Protected(unit)
        and not J.IsSuspiciousIllusion(unit)
end

local function WalkReserve()
    local walk = bot:GetAbilityByName('clinkz_wind_walk')
    return walk ~= nil and walk:IsTrained() and walk:GetManaCost() or 0
end

local function FarmMana(ability)
    return bot:GetMana() - ability:GetManaCost() >= WalkReserve()
        and (bot:GetMana() - ability:GetManaCost()) / bot:GetMaxMana() >= 0.25
end

local function OwnSkeleton(unit)
    return J.IsValid(unit) and unit:GetUnitName() == 'npc_dota_clinkz_skeleton_archer'
        and unit:GetPlayerID() == bot:GetPlayerID()
end

function X.UseBarrageInvisibility()
    bot = GetBot()
    if not bot:IsChanneling() or not bot:IsAlive() or bot:IsSilenced() or bot:IsStunned()
        or bot:IsHexed() or bot:IsNightmared() or bot:NumQueuedActions() > 0 then return false end
    local active = bot:GetCurrentActiveAbility()
    local walk = bot:GetAbilityByName('clinkz_wind_walk')
    if active == nil or active:GetName() ~= 'clinkz_burning_barrage' or not Castable(walk)
        or bot:HasModifier('modifier_clinkz_wind_walk') or J.IsRealInvisible(bot) then return false end
    -- Skeleton Walk is immediate and explicitly ignores channels in current Valve KV.
    bot:Action_UseAbility(walk)
    return true
end

function X.ConsiderSkeletonWalk()
    if not Castable(SkeletonWalk) or bot:HasModifier('modifier_clinkz_wind_walk')
        or J.IsRealInvisible(bot) then return BOT_ACTION_DESIRE_NONE end
    local target = J.GetProperTarget(bot)
    if J.IsRetreating(bot) and (bot:WasRecentlyDamagedByAnyHero(2)
        or #J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE) > 0) then
        -- Detection may reveal us; the movement bonus remains useful for escape.
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and not J.IsSuspiciousIllusion(target)
        and not Protected(target) and not J.IsInRange(bot, target, bot:GetAttackRange() + 200)
        and J.IsInRange(bot, target, 3000) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsFarming(bot) and bot.farmLocation ~= nil
        and GetUnitToLocationDistance(bot, bot.farmLocation) > 1800 and FarmMana(SkeletonWalk) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsLaning(bot) and J.GetMP(bot) > 0.75
        and bot:DistanceFromFountain() > 100 and bot:DistanceFromFountain() < 6000
        and GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)) > 1600
        and #J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE) == 0 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsDoingRoshan(bot) and GetUnitToLocationDistance(bot, J.GetCurrentRoshanLocation()) > 3000
        or J.IsDoingTormentor(bot) and GetUnitToLocationDistance(bot, J.GetTormentorLocation(GetTeam())) > 3000 then
        return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDeathPact()
    if not Castable(DeathPact) then return BOT_ACTION_DESIRE_NONE, nil end
    local range = CastRange(DeathPact)
    local needsHealing = bot:GetMaxHealth() - bot:GetHealth() >= DeathPact:GetSpecialValueInt('health_gain') * 0.65
        or J.GetHP(bot) < 0.45
    local hasBuff = bot:HasModifier('modifier_clinkz_death_pact')
    if hasBuff and not needsHealing then return BOT_ACTION_DESIRE_NONE, nil end
    if not needsHealing and not FarmMana(DeathPact) then return BOT_ACTION_DESIRE_NONE, nil end
    -- Keep the final spare charge for combat once the ability holds two charges.
    if not needsHealing and DeathPact:GetSpecialValueInt('AbilityCharges') >= 2
        and DeathPact:GetCurrentCharges() <= 1
        and not J.IsGoingOnSomeone(bot) and not J.IsInTeamFight(bot, 1200) then
        return BOT_ACTION_DESIRE_NONE, nil
    end
    local best, score = nil, -math.huge
    local candidates = bot:GetNearbyCreeps(math.min(range, 1600), true)
    for _, unit in pairs(bot:GetNearbyNeutralCreeps(math.min(range, 1600))) do table.insert(candidates, unit) end
    if needsHealing then
        for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
            if OwnSkeleton(unit) then table.insert(candidates, unit) end
        end
    end
    for _, creep in pairs(candidates) do
        local own = OwnSkeleton(creep)
        if J.IsValid(creep) and not creep:IsHero() and not creep:IsAncientCreep()
            and creep:CanBeSeen() and not creep:IsInvulnerable()
            and J.IsInRange(bot, creep, range)
            and (own or creep:GetTeam() ~= bot:GetTeam()
                and creep:GetLevel() <= DeathPact:GetSpecialValueInt('creep_level')
                and J.CanCastOnNonMagicImmune(creep) and J.CanCastOnTargetAdvanced(creep)
                and not creep:HasModifier('modifier_antimage_counterspell')
                and not creep:HasModifier('modifier_antimage_counterspell_ally')) then
            local value = own and -1000 or creep:GetMaxHealth()
            if not own and creep:GetPlayerID() >= 0 then value = value + 2000 end
            if not own and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep)) then value = value + 1000 end
            if value > score then best, score = creep, value end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderStrafe()
    if not Castable(Strafe) or bot:HasModifier('modifier_clinkz_strafe') then return BOT_ACTION_DESIRE_NONE end
    local target = J.GetProperTarget(bot)
    local range = bot:GetAttackRange() + Strafe:GetSpecialValueInt('attack_range_bonus')
    if not bot:IsDisarmed() and Attackable(target) and J.IsInRange(bot, target, range)
        and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)
            or (J.IsPushing(bot) and J.IsValidBuilding(target) and J.IsAttacking(bot))
            or ((J.IsDoingRoshan(bot) and J.IsRoshan(target)
                or J.IsDoingTormentor(bot) and J.IsTormentor(target)) and J.IsAttacking(bot))) then
        return BOT_ACTION_DESIRE_HIGH
    end
    local barrage = bot:GetAbilityByName('clinkz_burning_barrage')
    local base = bot:GetUnitName() == 'npc_dota_hero_rubick' and 550 or 600
    if not bot:IsDisarmed() and Castable(barrage) and J.IsGoingOnSomeone(bot) and Attackable(target)
        and J.IsInRange(bot, target, barrage:GetSpecialValueInt('range')
            + math.max(0, bot:GetAttackRange() - base) + Strafe:GetSpecialValueInt('attack_range_bonus'))
        and bot:GetMana() >= Strafe:GetManaCost() + barrage:GetManaCost() + WalkReserve() then
        return BOT_ACTION_DESIRE_HIGH
    end
    -- The skeleton buff is useful even while Clinkz remains hidden or disarmed.
    for _, skeleton in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if OwnSkeleton(skeleton) and J.IsInRange(bot, skeleton, Strafe:GetSpecialValueInt('strafe_skeleton_radius'))
            and Attackable(skeleton:GetAttackTarget()) then return BOT_ACTION_DESIRE_HIGH end
    end
    if not bot:IsDisarmed() and J.IsAttacking(bot) and FarmMana(Strafe)
        and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and (#bot:GetNearbyNeutralCreeps(range) >= 2 or #bot:GetNearbyLaneCreeps(range, true) >= 4) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

local function CanArrow(unit)
    return Attackable(unit) and J.IsInRange(bot, unit, bot:GetAttackRange())
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
end

function X.ConsiderSearingArrows()
    if SearingArrows == nil or not SearingArrows:IsTrained() or SearingArrows:IsHidden() then
        return BOT_ACTION_DESIRE_NONE, nil
    end
    local target = J.GetProperTarget(bot)
    local valid = not bot:IsDisarmed() and CanArrow(target)
    local combat = valid and J.IsValidHero(target) and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200))
    local sustained = valid and (combat or J.IsPushing(bot) and J.IsValidBuilding(target)
        or J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
    local canSpend = Castable(SearingArrows) and bot:GetMana() - SearingArrows:GetManaCost() >= WalkReserve()
    if sustained and canSpend then
        if not SearingArrows:GetAutoCastState() then SearingArrows:ToggleAutoCast() end
        return BOT_ACTION_DESIRE_NONE, nil
    end
    if SearingArrows:GetAutoCastState() then SearingArrows:ToggleAutoCast() end
    if not Castable(SearingArrows) or bot:IsDisarmed() or J.IsRetreating(bot) then return BOT_ACTION_DESIRE_NONE, nil end
    local damage = bot:GetAttackDamage() + SearingArrows:GetSpecialValueInt('damage_bonus')
    if J.IsLaning(bot) then
        for _, creep in pairs(bot:GetNearbyLaneCreeps(bot:GetAttackRange(), true)) do
            if CanArrow(creep) and J.CanKillTarget(creep, damage, DAMAGE_TYPE_PHYSICAL)
                and not J.CanKillTarget(creep, bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL)
                and FarmMana(SearingArrows) then return BOT_ACTION_DESIRE_HIGH, creep end
        end
        if J.IsValidHero(target) and CanArrow(target) and FarmMana(SearingArrows) then
            return BOT_ACTION_DESIRE_HIGH, target
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

local function BarrageRange()
    -- These are the current base attack ranges of the native hero and Rubick.
    local base = bot:GetUnitName() == 'npc_dota_hero_rubick' and 550 or 600
    return BurningBarrage:GetSpecialValueInt('range') + math.max(0, bot:GetAttackRange() - base)
end

local function LineHits(units, location, range)
    local origin = bot:GetLocation()
    local delta = location - origin
    if delta:Length2D() == 0 then return 0 end
    local dir = delta:Normalized()
    local count = 0
    for _, unit in pairs(units) do
        if J.IsValid(unit) and J.CanBeAttacked(unit) and not Protected(unit) then
            local offset = J.GetCorrectLoc(unit, 0.4) - origin
            local along = offset.x * dir.x + offset.y * dir.y
            local across = math.abs(offset.x * dir.y - offset.y * dir.x)
            if along >= 0 and along <= range and across <= BurningBarrage:GetSpecialValueInt('projectile_width') / 2 then
                count = count + 1
            end
        end
    end
    return count
end

function X.ConsiderBurningBarrage()
    if not Castable(BurningBarrage) or bot:IsDisarmed() or J.IsRetreating(bot) then return BOT_ACTION_DESIRE_NONE, nil end
    local range = BarrageRange()
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Attackable(target) and J.IsInRange(bot, target, range)
        and #J.GetNearbyHeroes(bot, 600, true, BOT_MODE_NONE) <= 1 then
        local location = J.GetCorrectLoc(target, 0.4)
        if LineHits({target}, location, range) > 0 then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if J.IsInTeamFight(bot, 1200) then
        local enemies = J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)
        for _, enemy in pairs(enemies) do
            local location = J.GetCorrectLoc(enemy, 0.4)
            if LineHits(enemies, location, range) >= 2 then return BOT_ACTION_DESIRE_HIGH, location end
        end
    end
    if FarmMana(BurningBarrage) and J.IsAttacking(bot)
        and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then
        local lists = {bot:GetNearbyLaneCreeps(math.min(range, 1600), true)}
        if J.IsFarming(bot) then table.insert(lists, bot:GetNearbyNeutralCreeps(math.min(range, 1600))) end
        for index, units in ipairs(lists) do
            for _, unit in pairs(units) do
                local location = unit:GetLocation()
                if LineHits(units, location, range) >= (index == 1 and 3 or 2) then
                    return BOT_ACTION_DESIRE_HIGH, location
                end
            end
        end
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target)) or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and Attackable(target) and J.IsAttacking(bot) and J.IsInRange(bot, target, range)
        and FarmMana(BurningBarrage) then return BOT_ACTION_DESIRE_HIGH, target:GetLocation() end
    return BOT_ACTION_DESIRE_NONE, nil
end

local function EnableBarrageArrows()
    local arrows = bot:GetAbilityByName('clinkz_searing_arrows')
    if Castable(arrows) and not arrows:GetAutoCastState()
        and bot:GetMana() >= BurningBarrage:GetManaCost() + WalkReserve()
            + arrows:GetManaCost() * BurningBarrage:GetSpecialValueInt('wave_count') then
        arrows:ToggleAutoCast()
    end
end

function X.ConsiderBurningArmy()
    -- Requires two vector endpoints. Do not replace it with an invalid point cast.
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.SkillsComplement()
    if X.UseBarrageInvisibility() then return end
    if J.CanNotUseAbility(bot) then return end
    if X.ConsiderSkeletonWalk() > 0 then bot:Action_UseAbility(SkeletonWalk); return end
    local pact, creep = X.ConsiderDeathPact()
    if pact > 0 then bot:Action_UseAbilityOnEntity(DeathPact, creep); return end
    if X.ConsiderStrafe() > 0 then bot:Action_UseAbility(Strafe); return end
    local arrows, target = X.ConsiderSearingArrows()
    if arrows > 0 then bot:Action_UseAbilityOnEntity(SearingArrows, target); return end
    local barrage, location = X.ConsiderBurningBarrage()
    if barrage > 0 then EnableBarrageArrows(); bot:Action_UseAbilityOnLocation(BurningBarrage, location); return end
end

return X
