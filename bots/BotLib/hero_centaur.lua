local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT, position 3 only; forced other roles use this fallback.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/centaur')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Hoof Stomp, [2] Double Edge, [3] Retaliate, [6] Stampede.
-- D2PT shows only the first ten levels; later levels are a legal continuation.
local nAbilityBuildList = {1,2,3,3,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +15 movement speed
    t15={0,10}, -- +10 Strength
    t20={10,0}, -- -25s Stampede cooldown
    t25={10,0}, -- +1s Hoof Stomp duration
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
-- D2PT buys no boots: Horsepower converts Strength into movement speed.
X.sBuyList = {
    'item_tango', 'item_ring_of_protection', 'item_double_gauntlets', 'item_branches',
    'item_helm_of_the_dominator', 'item_magic_wand',
    'item_heart', 'item_blink', 'item_aghanims_shard', 'item_lotus_orb',
    'item_shivas_guard', 'item_black_king_bar',
    -- Late upgrades/slot policy beyond the displayed core progression.
    'item_ultimate_scepter_2', 'item_overwhelming_blink', 'item_moon_shard',
}
X.sSellList = {
    'item_lotus_orb', 'item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Hoof Stomp takes level 10, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local HoofStomp = bot:GetAbilityByName('centaur_hoof_stomp')
local DoubleEdge = bot:GetAbilityByName('centaur_double_edge')
local WorkHorse = bot:GetAbilityByName('centaur_work_horse')
local HitchARide = bot:GetAbilityByName('centaur_mount')
local Stampede = bot:GetAbilityByName('centaur_stampede')

local stompFocus, stompReason

local function CastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function ValidEnemy(unit)
    return J.IsValidTarget(unit) and not unit:IsInvulnerable()
        and not J.IsSuspiciousIllusion(unit)
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end

local function Enemy(unit)
    return ValidEnemy(unit) and J.CanCastOnNonMagicImmune(unit)
end

local function SafeLocation(location)
    return IsLocationPassable(location) and not J.IsLocationInChrono(location)
        and not J.IsLocationInBlackHole(location) and not J.IsLocationInArena(location, 600)
end

local function CanRun(unit)
    return J.IsValidHero(unit) and not unit:IsInvulnerable() and not unit:IsChanneling()
        and not unit:IsRooted() and not unit:IsStunned() and not unit:IsHexed()
        and not unit:IsNightmared() and not unit:HasModifier('modifier_bloodseeker_rupture')
        and not unit:HasModifier('modifier_centaur_stampede')
        and not unit:HasModifier('modifier_centaur_mounted')
end

local function Pursued(unit)
    if not unit:WasRecentlyDamagedByAnyHero(2.5) then return false end
    for _, enemy in pairs(J.GetNearbyHeroes(unit, 700, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and not J.IsDisabled(enemy) and J.IsChasingTarget(enemy, unit) then return true end
    end
    return false
end

function X.UsePendingStomp()
    bot = GetBot()
    if not bot:HasModifier('modifier_centaur_hoof_stomp_windup') then return false end
    if bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsRooted()
        or bot:IsChanneling() or bot:NumQueuedActions() > 0
        or bot:HasModifier('modifier_bloodseeker_rupture') then return true end
    if J.IsRetreating(bot) and stompReason ~= 'interrupt' and stompReason ~= 'lethal' then
        bot:Action_MoveToLocation(J.GetTeamFountain())
        return true
    end
    local target = stompFocus or J.GetProperTarget(bot)
    if Enemy(target) and J.IsInRange(bot, target, 600) then
        local location = J.GetCorrectLoc(target, 0.2)
        if SafeLocation(location) then bot:Action_MoveToLocation(location); return true end
    end
    return true
end

function X.ConsiderHoofStomp()
    if not J.CanCastAbility(HoofStomp) then return BOT_ACTION_DESIRE_NONE end
    local radius = HoofStomp:GetSpecialValueInt('radius')
    local delay = HoofStomp:GetSpecialValueFloat('windup_time') + HoofStomp:GetCastPoint()
    local damage = HoofStomp:GetSpecialValueInt('stomp_damage')
    local target = J.GetProperTarget(bot)
    local enemies = J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if Enemy(enemy) and GetUnitToLocationDistance(bot, J.GetCorrectLoc(enemy, delay)) <= radius then
            if enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy) then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'interrupt'
            end
            if not J.CannotBeKilled(bot, enemy)
                and J.WillKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL, delay) then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'lethal'
            end
        end
    end
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsInRange(bot, target, radius)
        and not J.IsDisabled(target)
        and GetUnitToLocationDistance(bot, J.GetCorrectLoc(target, delay)) <= radius then
        return BOT_ACTION_DESIRE_HIGH, target, 'engage'
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.5) then
        for _, enemy in pairs(enemies) do
            if Enemy(enemy) and not J.IsDisabled(enemy)
                and GetUnitToLocationDistance(bot, J.GetCorrectLoc(enemy, delay)) <= radius then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'retreat'
            end
        end
    end
    if J.IsInTeamFight(bot, 1200) then
        local count, first = 0, nil
        for _, enemy in pairs(enemies) do
            if Enemy(enemy) and not J.IsDisabled(enemy)
                and GetUnitToLocationDistance(bot, J.GetCorrectLoc(enemy, delay)) <= radius then
                count, first = count + 1, enemy
            end
        end
        if count >= 2 then return BOT_ACTION_DESIRE_HIGH, first, 'area control' end
    end
    if J.IsDoingRoshan(bot) and J.IsRoshan(target) and J.CanCastOnNonMagicImmune(target)
        and J.IsInRange(bot, target, radius) and J.IsAttacking(bot) then
        return BOT_ACTION_DESIRE_HIGH, target, 'boss'
    end
    if J.IsFarming(bot) and J.IsAttacking(bot) and J.GetMP(bot) > 0.55
        and #enemies == 0 and #bot:GetNearbyNeutralCreeps(radius) >= 3 then
        return BOT_ACTION_DESIRE_HIGH, nil, 'camp'
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBlinkHoofStomp()
    if not J.CanCastAbility(HoofStomp) or not J.IsGoingOnSomeone(bot)
        or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') then
        return BOT_ACTION_DESIRE_NONE
    end
    local blink
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:IsFullyCastable() and
            (item:GetName() == 'item_blink' or item:GetName() == 'item_overwhelming_blink'
            or item:GetName() == 'item_arcane_blink' or item:GetName() == 'item_swift_blink') then
            blink = item
            break
        end
    end
    local target = J.GetProperTarget(bot)
    if blink == nil or not Enemy(target) or J.IsDisabled(target)
        or bot:GetMana() < blink:GetManaCost() + HoofStomp:GetManaCost() then
        return BOT_ACTION_DESIRE_NONE
    end
    local radius = HoofStomp:GetSpecialValueInt('radius')
    if J.IsInRange(bot, target, radius) then return BOT_ACTION_DESIRE_NONE end
    local range = blink:GetSpecialValueInt('blink_range') + CastRange(blink) - blink:GetCastRange()
    local predicted = J.GetCorrectLoc(target, HoofStomp:GetSpecialValueFloat('windup_time') + 0.1)
    local delta = predicted - bot:GetLocation()
    if delta:Length2D() > range + radius - 50 then return BOT_ACTION_DESIRE_NONE end
    local location = predicted
    if delta:Length2D() > range then location = bot:GetLocation() + delta:Normalized() * range end
    local allies, hasBot = 0, false
    for _, ally in pairs(J.GetAlliesNearLoc(location, 1000)) do
        if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally) then
            allies = allies + 1
            if ally == bot then hasBot = true end
        end
    end
    if not hasBot then allies = allies + 1 end
    if not SafeLocation(location) or allies < #J.GetEnemiesNearLoc(location, 1000) then
        return BOT_ACTION_DESIRE_NONE
    end
    return BOT_ACTION_DESIRE_HIGH, location, target, blink
end

local function EdgeDamage()
    return DoubleEdge:GetSpecialValueInt('edge_damage')
        + bot:GetAttributeValue(ATTRIBUTE_STRENGTH) * DoubleEdge:GetSpecialValueInt('strength_damage') / 100
end

-- Double Edge can deliberately use an illusion as the primary for its splash.
local function EdgeAreaTarget(unit)
    return J.IsValid(unit) and not unit:IsInvulnerable() and not unit:IsMagicImmune()
        and not J.HasForbiddenModifier(unit)
end

local function CanEdge(unit)
    return EdgeAreaTarget(unit) and J.IsInRange(bot, unit, CastRange(DoubleEdge))
        and (unit:IsIllusion() or J.CanCastOnTargetAdvanced(unit))
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
        and not unit:HasModifier('modifier_abaddon_borrowed_time')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end

local function HealthyAfterEdge(damage, fraction)
    local selfDamage = bot:GetActualIncomingDamage(damage, DAMAGE_TYPE_MAGICAL)
    return math.max(1, bot:GetHealth() - selfDamage) >= bot:GetMaxHealth() * fraction
end

function X.ConsiderDoubleEdge()
    if not J.CanCastAbility(DoubleEdge) then return BOT_ACTION_DESIRE_NONE end
    local damage, range = EdgeDamage(), CastRange(DoubleEdge)
    local radius = DoubleEdge:GetSpecialValueInt('radius')
    local target = J.GetProperTarget(bot)
    local enemies = J.GetNearbyHeroes(bot, math.min(range + radius, 1600), true, BOT_MODE_NONE)
    local lists = {enemies, bot:GetNearbyLaneCreeps(math.min(range + radius, 1600), true),
        bot:GetNearbyNeutralCreeps(math.min(range + radius, 1600))}
    for _, list in ipairs(lists) do
        for _, primary in pairs(list) do
            if CanEdge(primary) then
                for _, enemy in pairs(enemies) do
                    if Enemy(enemy) and not J.CannotBeKilled(bot, enemy)
                        and J.IsInRange(primary, enemy, radius)
                        and J.WillKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL, DoubleEdge:GetCastPoint())
                        and (HealthyAfterEdge(damage, 0.15)
                            or #J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE) == 1) then
                        -- Self damage is nonlethal; a legal creep can also anchor a hero splash kill.
                        return BOT_ACTION_DESIRE_HIGH, primary
                    end
                end
            end
        end
    end
    if not HealthyAfterEdge(damage, 0.3) then return BOT_ACTION_DESIRE_NONE end
    if (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) and CanEdge(target)
        and not J.IsSuspiciousIllusion(target) then return BOT_ACTION_DESIRE_HIGH, target end
    -- A legal primary target lets the small AoE secure creeps or clear illusions together.
    for _, list in ipairs(lists) do
        for _, center in pairs(list) do
            if CanEdge(center) then
                local hits, kills = 0, 0
                for _, unit in pairs(list) do
                    if EdgeAreaTarget(unit) and J.IsInRange(center, unit, radius) then
                        hits = hits + 1
                        if J.WillKillTarget(unit, damage, DAMAGE_TYPE_MAGICAL, DoubleEdge:GetCastPoint()) then kills = kills + 1 end
                    end
                end
                if (J.IsLaning(bot) and HealthyAfterEdge(damage, 0.5) and kills >= 2)
                    or ((J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
                        and J.IsAttacking(bot) and HealthyAfterEdge(damage, 0.5) and hits >= 2)
                    or (J.IsInTeamFight(bot, 1200) and hits >= 2 and center:IsIllusion()) then
                    return BOT_ACTION_DESIRE_HIGH, center
                end
            end
        end
    end
    if J.IsLaning(bot) and CanEdge(target) and not J.IsSuspiciousIllusion(target)
        and HealthyAfterEdge(damage, 0.65) then return BOT_ACTION_DESIRE_HIGH, target end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target))
        or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and CanEdge(target) and J.IsAttacking(bot) and HealthyAfterEdge(damage, 0.5) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderStampede()
    if not J.CanCastAbility(Stampede) then return BOT_ACTION_DESIRE_NONE end
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if CanRun(ally) and not J.IsSuspiciousIllusion(ally) and Pursued(ally)
            and (J.GetHP(ally) < 0.45 or J.IsRetreating(ally)) then
            return BOT_ACTION_DESIRE_HIGH, true
        end
    end
    if CanRun(bot) and J.IsGoingOnSomeone(bot) then
        local target = J.GetProperTarget(bot)
        if ValidEnemy(target) and J.IsChasingTarget(bot, target) and J.IsInRange(bot, target, 1200)
            and not J.IsInRange(bot, target, 450) and not J.IsDisabled(target)
            and #J.GetAlliesNearLoc(target:GetLocation(), 1200) >= 1
            and (HoofStomp == nil or not HoofStomp:IsFullyCastable()
                or bot:GetMana() >= Stampede:GetManaCost() + HoofStomp:GetManaCost()) then
            return BOT_ACTION_DESIRE_HIGH, false
        end
    end
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        local target = J.GetProperTarget(ally)
        if CanRun(ally) and not J.IsSuspiciousIllusion(ally) and J.IsGoingOnSomeone(ally)
            and ValidEnemy(target) and J.IsChasingTarget(ally, target)
            and J.IsInRange(ally, target, 1000) and not J.IsInRange(ally, target, 400)
            and not J.IsDisabled(target) and J.IsCore(ally)
            and #J.GetNearbyHeroes(ally, 1200, false, BOT_MODE_NONE) >= 2 then
            return BOT_ACTION_DESIRE_HIGH, false
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function RideAlly(range)
    local best, health = nil, 1
    for _, ally in pairs(J.GetAlliesNearLoc(bot:GetLocation(), range)) do
        if J.IsValidHero(ally) and ally ~= bot and J.IsInRange(bot, ally, range)
            and not ally:IsInvulnerable() and not J.IsSuspiciousIllusion(ally)
            and not ally:HasModifier('modifier_arc_warden_tempest_double')
            and not ally:HasModifier('modifier_centaur_mounted')
            and not ally:HasModifier('modifier_necrolyte_reapers_scythe')
            and ally:WasRecentlyDamagedByAnyHero(2.5)
            and ((J.GetHP(ally) < 0.5 and J.GetHP(ally) < health)
                or (best == nil and ally:IsChanneling())) then
            best, health = ally, J.GetHP(ally)
        end
    end
    return best
end

function X.ConsiderHitchARide()
    if not J.CanCastAbility(HitchARide) or J.GetHP(bot) < 0.3 then return BOT_ACTION_DESIRE_NONE end
    local ally = RideAlly(CastRange(HitchARide))
    if ally ~= nil then return BOT_ACTION_DESIRE_HIGH, ally end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderWorkHorse()
    if not J.CanCastAbility(WorkHorse) or bot:HasModifier('modifier_centaur_cart')
        or bot:HasModifier('modifier_centaur_stampede') then return BOT_ACTION_DESIRE_NONE end
    local mount = bot:GetAbilityByName('centaur_mount')
    local ally = RideAlly(mount ~= nil and CastRange(mount) or 200)
    if ally ~= nil and J.GetHP(bot) >= 0.3 and mount ~= nil
        and mount:GetCooldownTimeRemaining() <= 0
        and bot:GetMana() >= WorkHorse:GetManaCost() + mount:GetManaCost() then
        return BOT_ACTION_DESIRE_HIGH
    end
    if CanRun(bot) then
        if J.IsRetreating(bot) and Pursued(bot) then return BOT_ACTION_DESIRE_HIGH end
        local target = J.GetProperTarget(bot)
        if J.IsGoingOnSomeone(bot) and ValidEnemy(target) and J.IsChasingTarget(bot, target)
            and J.IsInRange(bot, target, 1000) and not J.IsInRange(bot, target, 400)
            and (HoofStomp == nil or not HoofStomp:IsFullyCastable()
                or bot:GetMana() >= WorkHorse:GetManaCost() + HoofStomp:GetManaCost()) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.SkillsComplement()
    if X.UsePendingStomp() then return end
    if J.CanNotUseAbility(bot) then return end
    local stomp, target, reason = X.ConsiderHoofStomp()
    if stomp > 0 and reason == 'interrupt' then
        stompFocus, stompReason = target, reason
        bot:Action_UseAbility(HoofStomp)
        return
    end
    local ride, ally = X.ConsiderHitchARide()
    if ride > 0 then bot:Action_UseAbilityOnEntity(HitchARide, ally); return end
    local stampede, urgent = X.ConsiderStampede()
    if stampede > 0 and urgent then bot:Action_UseAbility(Stampede); return end
    if stomp > 0 then stompFocus, stompReason = target, reason; bot:Action_UseAbility(HoofStomp); return end
    local blinkDesire, location, blinkTarget, blink = X.ConsiderBlinkHoofStomp()
    if blinkDesire > 0 then
        stompFocus, stompReason = blinkTarget, 'engage'
        bot:Action_ClearActions(false)
        bot:ActionQueue_UseAbilityOnLocation(blink, location)
        bot:ActionQueue_UseAbility(HoofStomp)
        return
    end
    if X.ConsiderWorkHorse() > 0 then bot:Action_UseAbility(WorkHorse); return end
    if stampede > 0 then bot:Action_UseAbility(Stampede); return end
    local edge, victim = X.ConsiderDoubleEdge()
    if edge > 0 then bot:Action_UseAbilityOnEntity(DoubleEdge, victim); return end
end

return X
