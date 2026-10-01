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
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: positions 4 and 5; forced other roles use the pos 4 build.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/bounty_hunter')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Shuriken Toss, [2] Jinada, [3] Shadow Walk, [6] Track. Both roles max Toss and
-- Shadow Walk first; D2PT shows only the first ten levels, later levels are a legal continuation.
local nAbilityBuildList = {3,2,1,1,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +0.35s Shuriken Toss slow
    t15={0,10}, -- -30% damage taken in Shadow Walk
    t20={0,10}, -- +190 Shuriken Toss damage
    t25={0,10}, -- Track grants shared vision
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_5' then
    X.sBuyList = {
        -- D2PT's Ward Dispenser is an Observer + Sentry combination and cannot be bought directly.
        'item_boots', 'item_ward_observer', 'item_ward_sentry', 'item_blood_grenade',
        'item_tranquil_boots', 'item_magic_wand',
        'item_ancient_janggo', 'item_cyclone',
        -- Natural Eul's -> Wind Waker upgrade (D2PT, ~38m), then a reviewed continuation.
        'item_aghanims_shard', 'item_boots_of_bearing', 'item_force_staff', 'item_wind_waker',
        'item_ultimate_scepter_2', 'item_moon_shard',
    }
    X.sSellList = {
        'item_force_staff', 'item_magic_wand',
    }
else
    X.sBuyList = {
        -- D2PT's Ward Dispenser is an Observer + Sentry combination and cannot be bought directly.
        'item_boots', 'item_ward_observer', 'item_ward_sentry', 'item_blood_grenade',
        'item_tranquil_boots', 'item_magic_wand',
        'item_urn_of_shadows', 'item_ancient_janggo', 'item_cyclone',
        -- Natural Eul's -> Wind Waker upgrade (D2PT, ~38m), then a reviewed continuation.
        'item_aghanims_shard', 'item_boots_of_bearing', 'item_force_staff', 'item_wind_waker',
        'item_ultimate_scepter_2', 'item_moon_shard',
    }
    X.sSellList = {
        'item_cyclone', 'item_urn_of_shadows',
        'item_force_staff', 'item_magic_wand',
    }
end

if J.Role.IsPvNMode() then X['sBuyList'], X['sSellList'] = { 'PvN_BH' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Both roles max Shadow Walk at 10 and take the first talent at 11. Respect custom builds.
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

local abilityQ = bot:GetAbilityByName(sAbilityList[1])
local abilityW = bot:GetAbilityByName(sAbilityList[2])
local abilityE = bot:GetAbilityByName(sAbilityList[3])
local abilityR = bot:GetAbilityByName(sAbilityList[6])
local FriendlyShadow = bot:GetAbilityByName('bounty_hunter_wind_walk_ally')
local botTarget

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    botTarget = J.GetProperTarget(bot)
    local desire, target = X.ConsiderFriendlyShadow()
    if desire > 0 then bot:ActionQueue_UseAbilityOnEntity(FriendlyShadow, target); return end
    if J.IsRetreating(bot) and X.ConsiderE() > 0 then bot:ActionQueue_UseAbility(abilityE); return end
    -- Track preserves invisibility and amplifies the opening attack and subsequent Toss.
    desire, target = X.ConsiderR()
    if desire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(abilityR, target)
        return
    end
    desire, target = X.ConsiderQ()
    if desire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(abilityQ, target)
        return
    end
    if X.ConsiderE() > 0 then bot:ActionQueue_UseAbility(abilityE); return end
    desire, target = X.ConsiderJinada()
    if desire > 0 then bot:ActionQueue_UseAbilityOnEntity(abilityW, target) end
end

local function AbilityCastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    return range
end

local function Enemy(enemy, immune)
    return J.IsValidHero(enemy) and (immune and J.CanCastOnMagicImmune(enemy) or not immune and J.CanCastOnNonMagicImmune(enemy))
        and not enemy:HasModifier('modifier_antimage_counterspell')
        and not enemy:HasModifier('modifier_antimage_counterspell_ally')
        and J.CanCastOnTargetAdvanced(enemy)
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) then return 0 end
    local range, best, lowest = AbilityCastRange(abilityR), nil, math.huge
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
        if Enemy(enemy, true) and J.IsInRange(bot, enemy, range)
            and not enemy:HasModifier('modifier_bounty_hunter_track')
            and not enemy:HasModifier('modifier_arc_warden_tempest_double') and enemy:GetHealth() < lowest then
            best, lowest = enemy, enemy:GetHealth()
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH, best end
    return 0
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    local range, radius = AbilityCastRange(abilityQ), abilityQ:GetSpecialValueInt('bounce_aoe')
    local damage, delay = abilityQ:GetSpecialValueInt('bonus_damage'), abilityQ:GetCastPoint()
    local speed = abilityQ:GetSpecialValueInt('speed')
    if speed <= 0 then speed = 1000 end
    local candidates, heroes = {}, {}
    for _, enemy in ipairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(enemy, false) then
            heroes[#heroes + 1] = enemy
            if J.IsInRange(bot, enemy, range) then candidates[#candidates + 1] = enemy end
        end
    end
    for _, creep in ipairs(bot:GetNearbyCreeps(math.min(range, 1600), true)) do
        if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and J.CanCastOnTargetAdvanced(creep)
            and not creep:HasModifier('modifier_antimage_counterspell')
            and not creep:HasModifier('modifier_antimage_counterspell_ally') and J.IsInRange(bot, creep, range) then
            candidates[#candidates + 1] = creep
        end
    end
    -- A direct target must reach the desired Tracked hero through actual 1200-unit edges.
    local function reachable(first)
        local visited, distance, queue = {[first]=true}, {[first]=GetUnitToUnitDistance(bot, first)}, {first}
        local index = 1
        while index <= #queue do
            local from = queue[index]; index = index + 1
            for _, enemy in ipairs(heroes) do
                if not visited[enemy] and enemy:HasModifier('modifier_bounty_hunter_track')
                    and J.IsInRange(from, enemy, radius) then
                    visited[enemy] = true
                    distance[enemy] = distance[from] + GetUnitToUnitDistance(from, enemy)
                    queue[#queue + 1] = enemy
                end
            end
        end
        return visited, distance
    end
    local best, bestScore = nil, 0
    for _, first in ipairs(candidates) do
        local visited, distance = reachable(first)
        local score, hits = 0, 0
        for _, enemy in ipairs(heroes) do
            if visited[enemy] then
                hits = hits + 1
                if J.WillMagicKillTarget(bot, enemy, damage, delay + distance[enemy] / speed) then score = score + 20 end
                if J.IsGoingOnSomeone(bot) and enemy == botTarget then score = score + 5 end
                if bot:GetActiveMode() == BOT_MODE_LANING and enemy == botTarget
                    and J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then score = score + 2 end
                if J.IsRetreating(bot) and bot:WasRecentlyDamagedByHero(enemy, 2) then score = score + 5 end
            end
        end
        if hits >= 2 then score = score + hits end
        if score > bestScore then best, bestScore = first, score end
    end
    -- Preserve the Shadow Walk opening attack unless the spell would secure an immediate kill.
    if best and (not bot:IsInvisible() or bestScore >= 20 or J.IsRetreating(bot)) then
        return BOT_ACTION_DESIRE_HIGH, best
    end
    if bot:IsInvisible() then return 0 end
    if bot:GetActiveMode() == BOT_MODE_LANING or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        if J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then
            for _, creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range, 1600), true)) do
                if J.IsValid(creep) and J.IsInRange(bot, creep, range) and J.IsKeyWordUnit('ranged', creep)
                    and not creep:HasModifier('modifier_fountain_glyph')
                    and J.WillKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL, delay + GetUnitToUnitDistance(bot, creep) / speed)
                    and not J.CanKillTarget(creep, bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL) then
                    return BOT_ACTION_DESIRE_HIGH, creep
                end
            end
        end
    end
    return 0
end

function X.ConsiderE()
    if not J.CanCastAbility(abilityE) or bot:IsInvisible()
        or bot:HasModifier('modifier_bounty_hunter_wind_walk') then return 0 end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3)
        and bot:DistanceFromFountain() > 800 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsGoingOnSomeone(bot) and Enemy(botTarget, true) and J.IsInRange(bot, botTarget, 2500)
        and (not J.IsInRange(bot, botTarget, 600) or J.IsChasingTarget(bot, botTarget)) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsInEnemyArea(bot) and bot:GetLevel() >= 7 and bot:GetMana() >= 280
        and #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) == 0
        and #bot:GetNearbyTowers(1600, true) == 0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.ConsiderFriendlyShadow()
    if not J.CanCastAbility(FriendlyShadow) then return 0 end
    local range = AbilityCastRange(FriendlyShadow)
    local allies = J.GetNearbyHeroes(bot, math.min(range, 1600), false, BOT_MODE_NONE)
    -- Save first, so an approaching healthy initiator cannot consume the allied cooldown.
    for _, ally in ipairs(allies) do
        if J.IsValidHero(ally) and ally ~= bot and J.IsInRange(bot, ally, range)
            and not ally:IsInvulnerable() and not J.IsRealInvisible(ally)
            and not ally:HasModifier('modifier_bounty_hunter_wind_walk')
            and J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(3) then
            return BOT_ACTION_DESIRE_HIGH, ally
        end
    end
    for _, ally in ipairs(allies) do
        if J.IsValidHero(ally) and ally ~= bot and J.IsInRange(bot, ally, range)
            and not ally:IsInvulnerable() and not J.IsRealInvisible(ally)
            and not ally:HasModifier('modifier_bounty_hunter_wind_walk') and not J.IsAttacking(ally)
            and J.IsGoingOnSomeone(ally) then return BOT_ACTION_DESIRE_HIGH, ally end
    end
    return 0
end

function X.ConsiderJinada()
    if not J.CanCastAbility(abilityW) or J.HasBreakModifier(bot) or bot:IsDisarmed() or J.IsRetreating(bot) then return 0 end
    if (J.IsGoingOnSomeone(bot) or bot:GetActiveMode() == BOT_MODE_LANING)
        and J.IsValidHero(botTarget) and J.CanCastOnMagicImmune(botTarget)
        and not botTarget:IsAttackImmune() and J.IsInRange(bot, botTarget, bot:GetAttackRange()) then
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    return 0
end

return X
