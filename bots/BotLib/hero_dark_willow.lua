-- Valve-side bot bugs: she uses the override attack/laning modes (Utils.BuggyHeroesDueToValveTooLazy)
-- and stays in hero_selection's WeakHeroes list, so at most one flagged hero is drafted per team.

local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: positions 4 and 5; forced other roles use pos 4.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/dark_willow')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Bramble Maze, [2] Shadow Realm, [3] Cursed Crown, [4] Bedlam (the ultimate; Terrorize levels with it).
-- Both roles share D2PT's most popular first ten levels and talents; later levels are a legal continuation.
local nAbilityBuildList = {1,2,1,3,1,4,1,2,2,2,4,3,3,3,4}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +1s Bedlam duration
    t15={0,10}, -- +30 Bedlam damage
    t20={10,0}, -- -7s Bramble Maze cooldown
    t25={0,10}, -- +2 Bedlam attack targets
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_tango', 'item_branches', 'item_circlet', 'item_magic_stick', 'item_ward_sentry', 'item_blood_grenade',
    'item_magic_wand',
}
if sRole == 'pos_5' then
    -- D2PT pos 5: Tranquils before Urn (36%), then Eul's, Blink, Shard and Force Staff.
    for _, item in ipairs({'item_tranquil_boots', 'item_urn_of_shadows', 'item_cyclone', 'item_blink',
        'item_aghanims_shard', 'item_force_staff',
        -- Reviewed utility/upgrade continuation, not additional mandatory D2PT core items.
        'item_glimmer_cape', 'item_sheepstick', 'item_wind_waker', 'item_overwhelming_blink'}) do table.insert(X.sBuyList, item) end
    X.sSellList = {
        'item_glimmer_cape', 'item_magic_wand',
        'item_sheepstick', 'item_urn_of_shadows',
    }
else
    -- D2PT pos 4: Urn, Tranquils and Essence Distiller (81%) before Eul's, Blink and Shard.
    for _, item in ipairs({'item_urn_of_shadows', 'item_tranquil_boots', 'item_essence_distiller', 'item_cyclone',
        'item_blink', 'item_aghanims_shard',
        -- Reviewed utility/upgrade continuation, not additional mandatory D2PT core items.
        'item_aeon_disk', 'item_sheepstick', 'item_wind_waker', 'item_overwhelming_blink'}) do table.insert(X.sBuyList, item) end
    X.sSellList = {
        'item_aeon_disk', 'item_magic_wand',
        'item_sheepstick', 'item_urn_of_shadows',
    }
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Shadow Realm takes level 10, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local BrambleMaze = bot:GetAbilityByName('dark_willow_bramble_maze')
local ShadowRealm = bot:GetAbilityByName('dark_willow_shadow_realm')
local CurseCrown = bot:GetAbilityByName('dark_willow_cursed_crown')
local Bedlam = bot:GetAbilityByName('dark_willow_bedlam')
local Terrorize = bot:GetAbilityByName('dark_willow_terrorize')

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
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit) and not J.IsSuspiciousIllusion(unit)
end

local function Enemies()
    local result = {}
    for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(unit) then result[#result + 1] = unit end
    end
    return result
end

local function AreaLocation(ability, enemy, radius, delay)
    local location = enemy:GetExtrapolatedLocation(delay)
    local range = CastRange(ability)
    if GetUnitToLocationDistance(bot, location) > range then
        local projected = J.GetLocationTowardDistanceLocation(bot, location, range)
        if J.GetLocationToLocationDistance(location, projected) > radius then
            return nil
        end
        location = projected
    end
    return location
end

local function TerrorDelay(location)
    return Terrorize:GetCastPoint() + GetUnitToLocationDistance(bot, location)
        / Terrorize:GetSpecialValueInt('destination_travel_speed')
end

local function TerrorLocation(enemy)
    return AreaLocation(Terrorize, enemy, Terrorize:GetSpecialValueInt('destination_radius'),
        TerrorDelay(enemy:GetLocation()))
end

local function ClusterLocation(ability, radius, delay)
    local enemies = Enemies()
    local best, bestCount = nil, 1
    for _, enemy in ipairs(enemies) do
        if ability ~= Terrorize or not enemy:HasModifier('modifier_dark_willow_debuff_fear') then
            local castDelay = ability == Terrorize and TerrorDelay(enemy:GetLocation()) or delay
            local location = AreaLocation(ability, enemy, radius, castDelay)
            if location ~= nil then
                local count = 0
                for _, other in ipairs(enemies) do
                    if (ability ~= Terrorize or not other:HasModifier('modifier_dark_willow_debuff_fear'))
                        and J.GetLocationToLocationDistance(other:GetExtrapolatedLocation(castDelay), location) <= radius then
                        count = count + 1
                    end
                end
                if count > bestCount then best, bestCount = location, count end
            end
        end
    end
    return best
end

function X.ConsiderShadowRealm(defensiveOnly)
    if not J.CanCastAbility(ShadowRealm) or bot:HasModifier('modifier_dark_willow_shadow_realm_buff') then return 0 end
    if J.IsProjectileIncoming(bot, 800)
        or J.IsAttackProjectileIncoming(bot, 800) and (J.IsRetreating(bot) or J.GetHP(bot) < 0.45) then
        return BOT_ACTION_DESIRE_HIGH
    end
    local nearby = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE)
    if bot:WasRecentlyDamagedByAnyHero(2) and #nearby > 0
        and (J.IsRetreating(bot) or J.GetHP(bot) < 0.45) then return BOT_ACTION_DESIRE_HIGH end
    if defensiveOnly or bot:IsDisarmed() then return 0 end
    local target = J.GetProperTarget(bot)
    if Enemy(target) and not target:IsAttackImmune()
        and J.IsInRange(bot, target, bot:GetAttackRange() + ShadowRealm:GetSpecialValueInt('attack_range_bonus'))
        and (J.IsGoingOnSomeone(bot) or J.IsLaning(bot) and J.IsAllowedToSpam(bot, ShadowRealm:GetManaCost())) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

-- Valve marks Realm immediate and IGNORE_CHANNEL; this emergency cast preserves even a TP.
function X.UseShadowRealmDuringChannel()
    bot = GetBot()
    local realm = bot:GetAbilityByName('dark_willow_shadow_realm')
    if not bot:IsChanneling() or not bot:IsAlive() or bot:IsCastingAbility() or bot:NumQueuedActions() > 0
        or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or not J.CanCastAbility(realm)
        or not J.CheckBitfieldFlag(realm:GetBehavior(), ABILITY_BEHAVIOR_IGNORE_CHANNEL) then return false end
    ShadowRealm = realm
    if X.ConsiderShadowRealm(true) > 0 then bot:Action_UseAbility(realm); return true end
    return false
end

function X.ConsiderCurseCrown()
    if not J.CanCastAbility(CurseCrown) then return 0 end
    local function legal(enemy)
        return Enemy(enemy) and J.IsInRange(bot, enemy, CastRange(CurseCrown))
            and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_antimage_counterspell')
            and not enemy:HasModifier('modifier_antimage_counterspell_ally')
            and not enemy:HasModifier('modifier_dark_willow_cursed_crown')
    end
    local target = J.GetProperTarget(bot)
    if legal(target) and J.IsGoingOnSomeone(bot) then return BOT_ACTION_DESIRE_HIGH, target end
    local best, power = nil, 0
    for _, enemy in ipairs(Enemies()) do
        if legal(enemy) then
            if J.IsRetreating(bot) and bot:WasRecentlyDamagedByHero(enemy, 3) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            for _, ally in ipairs(J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE)) do
                if J.IsValidHero(ally) and not ally:IsIllusion() and J.IsRetreating(ally)
                    and ally:WasRecentlyDamagedByAnyHero(3) and J.IsChasingTarget(enemy, ally) then
                    return BOT_ACTION_DESIRE_HIGH, enemy
                end
            end
            if J.IsInTeamFight(bot, 1200) then
                local value = enemy:GetEstimatedDamageToTarget(false, bot, 4, DAMAGE_TYPE_ALL)
                if value > power then best, power = enemy, value end
            elseif J.IsLaning(bot) and J.IsAllowedToSpam(bot, CurseCrown:GetManaCost()) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return 0
end

function X.ConsiderBrambleMaze()
    if not J.CanCastAbility(BrambleMaze) then return 0 end
    local delay = BrambleMaze:GetCastPoint() + BrambleMaze:GetSpecialValueFloat('initial_creation_delay')
    local radius = BrambleMaze:GetSpecialValueInt('placement_range')
    if J.IsInTeamFight(bot, 1200) or J.IsPushing(bot) or J.IsDefending(bot) then
        local location = ClusterLocation(BrambleMaze, radius, delay)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and not target:HasModifier('modifier_dark_willow_bramble_maze') then
        local location = AreaLocation(BrambleMaze, target, radius, delay)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    for _, enemy in ipairs(Enemies()) do
        if not enemy:HasModifier('modifier_dark_willow_bramble_maze') then
            local need = J.IsRetreating(bot) and bot:WasRecentlyDamagedByHero(enemy, 3)
                or J.IsLaning(bot) and J.IsAllowedToSpam(bot, BrambleMaze:GetManaCost())
            for _, ally in ipairs(J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE)) do
                if J.IsValidHero(ally) and not ally:IsIllusion() and J.IsRetreating(ally)
                    and ally:WasRecentlyDamagedByAnyHero(3) and J.IsChasingTarget(enemy, ally) then need = true end
            end
            if need then
                local location = AreaLocation(BrambleMaze, enemy, radius, delay)
                if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    -- Maze is a zoning pattern, not a reliable immediate channel interrupt or guaranteed nuke.
    return 0
end

function X.ConsiderBedlam()
    if not J.CanCastAbility(Bedlam) or bot:HasModifier('modifier_dark_willow_bedlam') then return 0 end
    local close = Bedlam:GetSpecialValueInt('attack_radius')
    local reach = close + Bedlam:GetSpecialValueInt('roaming_radius')
    local target = J.GetProperTarget(bot)
    local protected = bot:HasModifier('modifier_dark_willow_shadow_realm_buff') or bot:IsMagicImmune()
    if J.IsGoingOnSomeone(bot) and Enemy(target)
        and not target:HasModifier('modifier_abaddon_borrowed_time')
        and not target:HasModifier('modifier_dark_willow_debuff_fear')
        and J.IsInRange(bot, target, reach)
        and (J.IsInRange(bot, target, close) or J.IsDisabled(target))
        and (J.GetHP(bot) >= 0.4 or protected)
        and #bot:GetNearbyCreeps(reach, true) <= Bedlam:GetSpecialValueInt('target_count') then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsInTeamFight(bot, 1200) and (J.GetHP(bot) >= 0.4 or protected) then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, close, true, BOT_MODE_NONE)) do
            if Enemy(enemy) and not enemy:HasModifier('modifier_abaddon_borrowed_time')
                and not enemy:HasModifier('modifier_dark_willow_debuff_fear') then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) == 0
        and J.IsAllowedToSpam(bot, Bedlam:GetManaCost()) then
        local count, seen = 0, {}
        for _, creep in ipairs(bot:GetNearbyCreeps(reach, true)) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and J.IsInRange(bot, creep, reach) then count = count + 1; seen[creep] = true end
        end
        for _, creep in ipairs(bot:GetNearbyNeutralCreeps(reach)) do
            if not seen[creep] and J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and J.IsInRange(bot, creep, reach) then count = count + 1 end
        end
        if count >= 3 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end

function X.ConsiderTerrorize()
    if not J.CanCastAbility(Terrorize) or bot:HasModifier('modifier_dark_willow_bedlam') then return 0 end
    for _, enemy in ipairs(Enemies()) do
        if not enemy:HasModifier('modifier_dark_willow_debuff_fear') and enemy:IsChanneling() then
            local location = TerrorLocation(enemy)
            if location ~= nil and (not enemy:HasModifier('modifier_teleporting')
                or J.GetModifierTime(enemy, 'modifier_teleporting') > TerrorDelay(location)) then
                return BOT_ACTION_DESIRE_HIGH, location
            end
        end
    end
    if J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot) or J.IsDefending(bot)
        or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        local location = ClusterLocation(Terrorize, Terrorize:GetSpecialValueInt('destination_radius'), 0)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    for _, enemy in ipairs(Enemies()) do
        if not enemy:HasModifier('modifier_dark_willow_debuff_fear') then
            local need = J.IsRetreating(bot) and bot:WasRecentlyDamagedByHero(enemy, 3)
            for _, ally in ipairs(J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE)) do
                if J.IsValidHero(ally) and not ally:IsIllusion() and J.IsRetreating(ally)
                    and ally:WasRecentlyDamagedByAnyHero(3) and J.IsChasingTarget(enemy, ally) then need = true end
            end
            if need then
                local location = TerrorLocation(enemy)
                if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    return 0
end

function X.SkillsComplement()
    bot = GetBot()
    if X.UseShadowRealmDuringChannel() then return end
    if J.CanNotUseAbility(bot) then return end
    if X.ConsiderShadowRealm(true) > 0 then bot:Action_UseAbility(ShadowRealm); return end
    local desire, location = X.ConsiderTerrorize()
    if desire > 0 then bot:Action_UseAbilityOnLocation(Terrorize, location); return end
    local target
    desire, target = X.ConsiderCurseCrown()
    if desire > 0 then bot:Action_UseAbilityOnEntity(CurseCrown, target); return end
    desire, location = X.ConsiderBrambleMaze()
    if desire > 0 then bot:Action_UseAbilityOnLocation(BrambleMaze, location); return end
    if X.ConsiderShadowRealm() > 0 then bot:Action_UseAbility(ShadowRealm); return end
    if X.ConsiderBedlam() > 0 then bot:Action_UseAbility(Bedlam) end
end

return X
