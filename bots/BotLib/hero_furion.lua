local FurionAbilities = require(GetScriptDirectory()..'/FunLib/furion_abilities')
local pendingCall
local FightResponse = require(GetScriptDirectory()..'/FunLib/fight_response')
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: all five positions.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/furion')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Sprout, [2] Teleportation, [3] Nature's Call, [6] Wrath of Nature.
local nAbilityBuildList = {3,1,3,2,3,6,3,2,2,2,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10=sRole == 'pos_4' and {10,0} or {0,10}, -- +25 Wrath base damage / -10s Nature's Call cooldown
    t15={0,10}, -- +50 Treant movement speed
    t20={0,10}, -- -20s Wrath of Nature cooldown
    t25=(sRole == 'pos_1' or sRole == 'pos_2') and {0,10} or {10,0}, -- No Teleport cooldown / 3x Treant health and damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_1' or sRole == 'pos_2' then
    if sRole == 'pos_1' then
        X.sBuyList = {'item_magic_wand','item_faerie_fire','item_faerie_fire'}
    else
        -- Omit the observed ward: core bots do not run ward placement.
        X.sBuyList = {'item_double_branches','item_circlet','item_circlet','item_tango','item_faerie_fire','item_magic_wand'}
    end
    local core = {'item_power_treads','item_maelstrom','item_mjollnir','item_dragon_lance','item_hurricane_pike','item_black_king_bar',
        -- Popular damage/sustain continuation; six persistent slots after selling the Wand.
        'item_lesser_crit','item_greater_crit','item_satanic','item_aghanims_shard',
        -- Bot policy: consumed late upgrades.
        'item_ultimate_scepter','item_ultimate_scepter_2','item_moon_shard'}
    for _, item in ipairs(core) do table.insert(X.sBuyList, item) end
    X.sSellList = {'item_black_king_bar','item_magic_wand'}
elseif sRole == 'pos_3' then
    X.sBuyList = {'item_double_branches','item_circlet','item_circlet','item_tango','item_faerie_fire',
        'item_magic_wand','item_power_treads','item_orchid','item_aghanims_shard','item_black_king_bar',
        'item_dragon_lance','item_hurricane_pike','item_bloodthorn',
        -- Bot policy: global control and a late disable; no second farming-item path.
        'item_ultimate_scepter','item_ultimate_scepter_2','item_sheepstick'}
    X.sSellList = {'item_black_king_bar','item_magic_wand'}
elseif sRole == 'pos_4' then
    X.sBuyList = {'item_branches','item_circlet','item_magic_stick','item_tango','item_ward_observer','item_ward_sentry','item_blood_grenade',
        'item_urn_of_shadows','item_magic_wand','item_spirit_vessel','item_power_treads','item_aghanims_shard','item_orchid','item_ultimate_scepter',
        -- Bot policy: defensive utility plus natural Orchid/Scepter upgrades.
        'item_force_staff','item_glimmer_cape','item_ultimate_scepter_2','item_bloodthorn','item_black_king_bar'}
    X.sSellList = {'item_ultimate_scepter','item_magic_wand'}
else
    X.sBuyList = {'item_double_branches','item_circlet','item_ward_sentry','item_tango','item_faerie_fire','item_blood_grenade',
        'item_urn_of_shadows','item_magic_wand','item_spirit_vessel',
        -- Bot policy: early mobility from the observed Treads option, then the source support core.
        'item_power_treads','item_aghanims_shard','item_ultimate_scepter',
        -- Bot policy: practical defensive utility and consumed Scepter upgrade.
        'item_force_staff','item_glimmer_cape','item_ultimate_scepter_2','item_lotus_orb'}
    X.sSellList = {'item_ultimate_scepter','item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Teleportation point at 10, then the first talent at 11. Preserve custom progressions.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

-- Re-fetch ability handles each tick for safety (Aghs upgrades, etc.)
local Sprout, Teleportation, NaturesCall, CurseOfTheOldGrowth, WrathOfNature

local function RefreshAbilities()
    Sprout              = bot:GetAbilityByName('furion_sprout')
    Teleportation       = bot:GetAbilityByName('furion_teleportation')
    NaturesCall         = bot:GetAbilityByName('furion_force_of_nature')
    CurseOfTheOldGrowth = bot:GetAbilityByName('furion_curse_of_the_forest')
    WrathOfNature       = bot:GetAbilityByName('furion_wrath_of_nature')
end

-- Cached per-tick variables
local botTarget, botHP, nAllyHeroes, nEnemyHeroes, bAttacking

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    RefreshAbilities()
    botTarget = J.GetProperTarget(bot)
    botHP = J.GetHP(bot)
    nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
    bAttacking = J.IsAttacking(bot)

    -- External TP request
    if not bot:IsRooted()
    and bot.useProphetTP
    and bot.ProphetTPLocation ~= nil
    and J.CanCastAbility(Teleportation)
    and FurionAbilities.SourceTeleportSafe(bot)
    then
        if not FurionAbilities.TeleportSafe(bot,bot.ProphetTPLocation)
            or not FightResponse.CanTeleportTo(bot, bot.ProphetTPLocation, bot.ProphetTPPurpose) then
            bot.useProphetTP = false
            bot.ProphetTPPurpose = nil
            return
        end
        FightResponse.RecordTeleport(bot, bot.ProphetTPLocation, bot.ProphetTPPurpose)
        bot:Action_UseAbilityOnLocation(Teleportation, bot.ProphetTPLocation)
        bot.useProphetTP = false
        bot.ProphetTPPurpose = nil
        return
    end

    local tpDesire, tpLoc, tpPurpose = X.ConsiderTeleportation()
    if tpDesire > 0 and FurionAbilities.TeleportSafe(bot,tpLoc) and FightResponse.CanTeleportTo(bot, tpLoc, tpPurpose) then
        FightResponse.RecordTeleport(bot, tpLoc, tpPurpose)
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(Teleportation, tpLoc)
        bot.useProphetTP = false
        return
    end

    local wonDesire, wonTarget = X.ConsiderWrathOfNature()
    if wonDesire > 0 then bot:Action_UseAbilityOnEntity(WrathOfNature, wonTarget); return end
    if pendingCall then
        local pending = pendingCall
        if DotaTime() > pending.expires or bot:GetActiveMode() ~= pending.mode or J.IsRetreating(bot) then pendingCall = nil
        elseif DotaTime() >= pending.ready and J.CanCastAbility(NaturesCall) then
            local point = FurionAbilities.CallPoint(bot, NaturesCall, pending.location)
            if point then pendingCall = nil; bot:Action_UseAbilityOnLocation(NaturesCall, point); return end
        end
    end
    local scDesire, _, scLoc = X.ConsiderSproutCall()
    if scDesire > 0 then
        pendingCall = {location=scLoc, ready=DotaTime()+Sprout:GetCastPoint(), expires=DotaTime()+2, mode=bot:GetActiveMode()}
        bot:Action_UseAbilityOnLocation(Sprout, scLoc); return
    end

    local sproutDesire, sproutTarget = X.ConsiderSprout()
    if sproutDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(Sprout, sproutTarget)
        return
    end

    local ncDesire, ncLoc = X.ConsiderNaturesCall()
    if ncDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(NaturesCall, ncLoc)
        return
    end

    local curseDesire = X.ConsiderCurseOfTheOldGrowth()
    if curseDesire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbility(CurseOfTheOldGrowth)
        return
    end


end

function X.ConsiderSprout() return FurionAbilities.Sprout(bot, Sprout) end

function X.ConsiderTeleportation()
    if not J.CanCastAbility(Teleportation) or not FurionAbilities.SourceTeleportSafe(bot) then return BOT_ACTION_DESIRE_NONE, 0 end

    local nChannelTime = Teleportation:GetCastPoint()
    local nMoveSpeed = bot:GetCurrentMovementSpeed()

    -- Projectile interrupt check: don't TP if stun is incoming
    if J.IsStunProjectileIncoming and J.IsStunProjectileIncoming(bot, 1200) then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    -- Stuck
    if J.IsStuck(bot) then
        return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain()
    end

    -- Teamfight TP
    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    and (not J.IsCore(bot) or not J.IsInLaningPhase() or bot:GetNetWorth() > 3500) then
        local dist = GetUnitToLocationDistance(bot, nTeamFightLocation)
        local walkTime = dist / nMoveSpeed
        if walkTime > nChannelTime + 2 then
            local allies = J.GetAlliesNearLoc(nTeamFightLocation, 1200)
            if allies ~= nil and #allies >= 1 and J.IsValidHero(allies[#allies]) then
                return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(allies[#allies], nChannelTime), 'fight'
            end
        end
    end

    -- Ally gank TP
    for i = 1, #GetTeamPlayers(GetTeam()) do
        local allyHero = GetTeamMember(i)
        if J.IsValidHero(allyHero)
        and J.IsGoingOnSomeone(allyHero)
        and not allyHero:IsIllusion()
        and (not J.IsCore(bot) or not J.IsInLaningPhase() or bot:GetNetWorth() > 3500) then
            local dist = GetUnitToUnitDistance(bot, allyHero)
            local walkTime = dist / nMoveSpeed
            if walkTime > nChannelTime + 2 then
                local allyTarget = allyHero:GetAttackTarget()
                if J.IsValidTarget(allyTarget)
                and J.IsInRange(allyHero, allyTarget, 800)
                and J.GetHP(allyHero) > 0.25
                and not J.IsSuspiciousIllusion(allyTarget) then
                    local nTargetAllies = allyTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE)
                    local nAllyAllies = allyHero:GetNearbyHeroes(800, false, BOT_MODE_NONE)
                    if nAllyAllies and nTargetAllies
                    and #nAllyAllies + 1 >= #nTargetAllies
                    and not J.IsLocationInChrono(J.GetCorrectLoc(allyHero, nChannelTime)) then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(allyHero, nChannelTime)
                    end
                end
            end
        end
    end

    -- Retreat TP: only when no one can interrupt
    if J.IsRetreating(bot)
    and not J.IsRealInvisible(bot)
    and bot:WasRecentlyDamagedByAnyHero(4)
    and bot:GetActiveModeDesire() > 0.75
    and bot:GetLevel() >= 6 then
        if #nEnemyHeroes == 0 then  -- safe to channel
            local fTimeToFountain = GetUnitToLocationDistance(bot, J.GetTeamFountain()) / nMoveSpeed
            if fTimeToFountain > nChannelTime + 1 then
                return BOT_ACTION_DESIRE_HIGH, J.GetTeamFountain()
            end
        end
    end

    -- Push TP: TP to lane front when pushing and far away
    if J.IsPushing(bot) and not bAttacking and #nEnemyHeroes == 0 then
        local nLane = bot:GetAssignedLane()
        if nLane ~= nil and nLane > 0 then
            local pushLoc = GetLaneFrontLocation(GetTeam(), nLane, 0)
            local dist = GetUnitToLocationDistance(bot, pushLoc)
            local walkTime = dist / nMoveSpeed
            if walkTime > nChannelTime * 2 and IsLocationPassable(pushLoc) then
                return BOT_ACTION_DESIRE_MODERATE, pushLoc
            end
        end
    end

    -- Defend TP: TP behind the front line
    if J.IsDefending(bot) and #nEnemyHeroes == 0 then
        local nDefendLane, _ = J.GetMostDefendLaneDesire()
        if nDefendLane ~= nil then
            local defendLoc = GetLaneFrontLocation(GetTeam(), nDefendLane, -1000)
            local dist = GetUnitToLocationDistance(bot, defendLoc)
            local walkTime = dist / nMoveSpeed
            if walkTime > nChannelTime * 2 and IsLocationPassable(defendLoc) then
                return BOT_ACTION_DESIRE_MODERATE, defendLoc, 'defense'
            end
        end
    end

    -- Roshan/Tormentor TP
    if J.IsDoingRoshan(bot) then
        local loc = J.GetCurrentRoshanLocation()
        local allies = J.GetAlliesNearLoc(loc, 700)
        local dist = GetUnitToLocationDistance(bot, loc)
        if allies and #allies >= 2 and dist / nMoveSpeed > nChannelTime + 1 then
            return BOT_ACTION_DESIRE_HIGH, loc
        end
    end

    if J.IsDoingTormentor(bot) then
        local loc = J.GetTormentorLocation(GetTeam())
        local allies = J.GetAlliesNearLoc(loc, 700)
        local dist = GetUnitToLocationDistance(bot, loc)
        if allies and #allies >= 2 and dist / nMoveSpeed > nChannelTime + 1 then
            return BOT_ACTION_DESIRE_HIGH, loc
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderNaturesCall() return FurionAbilities.Call(bot, NaturesCall) end
function X.ConsiderWrathOfNature() return FurionAbilities.Wrath(bot, WrathOfNature) end
function X.ConsiderCurseOfTheOldGrowth() return FurionAbilities.Curse(bot, CurseOfTheOldGrowth) end

-- Sprout + Nature's Call combo: create trees then convert to treants
function X.CanDoSproutCall()
    return J.CanCastAbility(Sprout) and J.CanCastAbility(NaturesCall)
        and J.GetMP(bot) > 0.5
end

function X.ConsiderSproutCall()
    if not X.CanDoSproutCall() or pendingCall or J.IsRetreating(bot)
        or #nEnemyHeroes > 0 or FurionAbilities.CallPoint(bot, NaturesCall) ~= nil then return 0,nil,nil end
    if not (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot) or J.IsLaning(bot)) then return 0,nil,nil end
    local useful = #bot:GetNearbyLaneCreeps(900,true) >= 2 or #bot:GetNearbyNeutralCreeps(900) >= 2
    if not useful then return 0,nil,nil end
    local point = J.IsValid(botTarget) and botTarget:GetLocation()
        or J.Site.GetXUnitsTowardsLocation(bot, J.GetEscapeLoc(), 350)
    local range = math.min(FurionAbilities.Range(bot,Sprout), FurionAbilities.Range(bot,NaturesCall))
    if GetUnitToLocationDistance(bot,point) > range
        or GetUnitToLocationDistance(bot,point) < Sprout:GetSpecialValueInt('sprout_damage_radius') + 50 then return 0,nil,nil end
    local mana = Sprout:GetManaCost() + NaturesCall:GetManaCost()
    if J.CanCastAbility(Teleportation) then mana = mana + Teleportation:GetManaCost() end
    if bot:GetMana() < mana then return 0,nil,nil end
    return BOT_ACTION_DESIRE_HIGH,nil,point
end

return X
