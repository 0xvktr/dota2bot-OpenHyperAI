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

-- Updated to 7.41f from D2PT: mid and offlane; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/death_prophet')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Crypt Swarm, [2] Silence, [3] Spirit Siphon, [6] Exorcism.
-- D2PT supplies the first ten levels; later levels are a legal continuation.
local nAbilityBuildList = sRole == 'pos_2'
    and {1,3,3,1,3,6,3,1,1,2,6,2,2,2,6}
    or {1,3,1,3,1,6,1,3,3,2,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +200 Health
    t15={10,0}, -- -2.5s Crypt Swarm cooldown
    t20={0,10}, -- +6 Exorcism spirits
    t25={10,0}, -- Deaths during Exorcism extend its duration by 8s
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_2' then
    X.sBuyList = {
        -- Omit the observed ward: core bots do not run the ward-placement mode.
        'item_tango', 'item_double_branches', 'item_double_branches', 'item_faerie_fire',
        'item_bottle', 'item_magic_wand', 'item_phase_boots', 'item_cyclone',
        'item_blink', 'item_ultimate_scepter', 'item_black_king_bar',
        'item_aghanims_shard', 'item_shivas_guard',
        -- Reviewed late upgrades/utility, not additional mandatory D2PT core.
        'item_ultimate_scepter_2', 'item_wind_waker', 'item_overwhelming_blink', 'item_sheepstick',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand','item_shivas_guard','item_bottle'}
else
    X.sBuyList = {
        'item_tango', 'item_double_branches', 'item_circlet', 'item_circlet', 'item_faerie_fire',
        'item_null_talisman', 'item_magic_wand', 'item_phase_boots', 'item_cyclone',
        'item_kaya_and_sange', 'item_blink', 'item_black_king_bar',
        'item_shivas_guard', 'item_aghanims_shard',
        -- Reviewed late upgrades; Blessing leaves the six persistent core slots intact.
        'item_wind_waker', 'item_ultimate_scepter_2', 'item_overwhelming_blink',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand','item_shivas_guard','item_null_talisman'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Silence at level 10, then the first talent at 11. Preserve custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		local sUnitName = hMinionUnit:GetUnitName()
		if sUnitName ~= "npc_dota_death_prophet_torment"
			and sUnitName ~= "dota_death_prophet_exorcism_spirit"
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

local Swarm = bot:GetAbilityByName('death_prophet_carrion_swarm')
local Silence = bot:GetAbilityByName('death_prophet_silence')
local Siphon = bot:GetAbilityByName('death_prophet_spirit_siphon')
local Exorcism = bot:GetAbilityByName('death_prophet_exorcism')

local function Refresh()
    Swarm = bot:GetAbilityByName('death_prophet_carrion_swarm')
    Silence = bot:GetAbilityByName('death_prophet_silence')
    Siphon = bot:GetAbilityByName('death_prophet_spirit_siphon')
    Exorcism = bot:GetAbilityByName('death_prophet_exorcism')
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:GetName() == 'item_aether_lens' then
            range = range + item:GetSpecialValueInt('cast_range_bonus'); break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit)
end

local function Bound(point, range)
    local offset = point - bot:GetLocation()
    return offset:Length2D() > range and bot:GetLocation() + offset:Normalized() * range or point
end

local function SwarmDelay(unit)
    return Swarm:GetCastPoint() + GetUnitToUnitDistance(bot, unit) / Swarm:GetSpecialValueInt('speed')
end

local function SwarmHit(unit, point)
    if not J.IsValid(unit) or unit:IsInvulnerable() or unit:IsMagicImmune() then return false end
    local offset = J.GetCorrectLoc(unit, SwarmDelay(unit)) - bot:GetLocation()
    local direction = (point - bot:GetLocation()):Normalized()
    local along = offset.x * direction.x + offset.y * direction.y
    local length = Swarm:GetSpecialValueInt('range')
    if along < 0 or along > length then return false end
    local width = Swarm:GetSpecialValueInt('start_radius')
        + (Swarm:GetSpecialValueInt('end_radius') - Swarm:GetSpecialValueInt('start_radius')) * along / length
    return math.abs(offset.x * direction.y - offset.y * direction.x) <= width
end

function X.ConsiderSwarm()
    if not J.CanCastAbility(Swarm) then return BOT_ACTION_DESIRE_NONE end
    local heroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    for _, enemy in pairs(heroes) do
        if Enemy(enemy) and not J.CannotBeKilled(bot, enemy) then
            local point = Bound(J.GetCorrectLoc(enemy, SwarmDelay(enemy)), CastRange(Swarm))
            if SwarmHit(enemy, point) and J.WillKillTarget(enemy, Swarm:GetSpecialValueInt('damage'),
                DAMAGE_TYPE_MAGICAL, SwarmDelay(enemy)) then return BOT_ACTION_DESIRE_HIGH, point, 'lethal' end
        end
    end
    local target = J.GetProperTarget(bot)
    if Enemy(target) and (J.IsGoingOnSomeone(bot) or (J.IsRetreating(bot) and J.IsChasingTarget(target, bot))) then
        local point = Bound(J.GetCorrectLoc(target, SwarmDelay(target)), CastRange(Swarm))
        if SwarmHit(target, point) then return BOT_ACTION_DESIRE_HIGH, point end
    end
    if not J.IsAllowedToSpam(bot, Swarm:GetManaCost()) then return BOT_ACTION_DESIRE_NONE end
    if J.IsInTeamFight(bot, 1200) or J.IsLaning(bot) then
        for _, enemy in pairs(heroes) do
            if Enemy(enemy) then
                local point, count = Bound(J.GetCorrectLoc(enemy, SwarmDelay(enemy)), CastRange(Swarm)), 0
                for _, other in pairs(heroes) do if Enemy(other) and SwarmHit(other, point) then count = count + 1 end end
                if count >= 2 then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    local creeps = bot:GetNearbyLaneCreeps(1200, true)
    if J.IsFarming(bot) then
        for _, creep in pairs(bot:GetNearbyNeutralCreeps(1200)) do table.insert(creeps, creep) end
    end
    if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) then
                local point, hits, kills = Bound(J.GetCorrectLoc(creep, SwarmDelay(creep)), CastRange(Swarm)), 0, 0
                for _, other in pairs(creeps) do
                    if SwarmHit(other, point) then
                        hits = hits + 1
                        if J.WillKillTarget(other, Swarm:GetSpecialValueInt('damage'), DAMAGE_TYPE_MAGICAL,
                            SwarmDelay(other)) then kills = kills + 1 end
                    end
                end
                if (J.IsLaning(bot) and (kills >= 2 or (kills >= 1
                    and string.find(creep:GetUnitName(), 'ranged') ~= nil
                    and SwarmHit(creep, point) and J.WillKillTarget(creep, Swarm:GetSpecialValueInt('damage'),
                        DAMAGE_TYPE_MAGICAL, SwarmDelay(creep)))))
                    or (not J.IsLaning(bot) and hits >= 3) then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target)) or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and J.IsAttacking(bot) then
        local point = Bound(target:GetLocation(), CastRange(Swarm))
        if SwarmHit(target, point) then return BOT_ACTION_DESIRE_HIGH, point end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function SilenceLocation(unit)
    if not Enemy(unit) or unit:IsSilenced() then return nil end
    local delay = Silence:GetCastPoint() + math.min(GetUnitToUnitDistance(bot, unit), CastRange(Silence))
        / Silence:GetSpecialValueInt('projectile_speed')
    local predicted = J.GetCorrectLoc(unit, delay)
    local point = Bound(predicted, CastRange(Silence))
    if (predicted - point):Length2D() <= Silence:GetSpecialValueInt('radius') then return point, delay end
    return nil
end

function X.ConsiderSilence()
    if not J.CanCastAbility(Silence) then return BOT_ACTION_DESIRE_NONE end
    local heroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    for _, enemy in pairs(heroes) do
        local point = SilenceLocation(enemy)
        if point ~= nil and (enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy)) then
            return BOT_ACTION_DESIRE_HIGH, point, 'interrupt'
        end
    end
    if J.IsInTeamFight(bot, 1200) then
        for _, enemy in pairs(heroes) do
            local point, delay = SilenceLocation(enemy)
            if point ~= nil then
                local count = 0
                for _, other in pairs(heroes) do
                    if Enemy(other) and not other:IsSilenced()
                        and (J.GetCorrectLoc(other, delay) - point):Length2D() <= Silence:GetSpecialValueInt('radius') then count = count + 1 end
                end
                if count >= 2 then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and not J.IsDisabled(target) then
        local point = SilenceLocation(target)
        if point ~= nil then return BOT_ACTION_DESIRE_HIGH, point end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _, enemy in pairs(heroes) do
            if Enemy(enemy) and not J.IsDisabled(enemy) and J.IsChasingTarget(enemy, bot) then
                local point = SilenceLocation(enemy)
                if point ~= nil then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function SiphonTarget(unit)
    return J.IsValid(unit) and unit:GetTeam() ~= bot:GetTeam() and not unit:IsInvulnerable()
        and not unit:IsMagicImmune() and not J.IsSuspiciousIllusion(unit)
        and J.IsInRange(bot, unit, CastRange(Siphon)) and J.CanCastOnTargetAdvanced(unit)
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
        and not unit:HasModifier('modifier_death_prophet_spirit_siphon_slow')
        and not J.CannotBeKilled(bot, unit)
        and unit:GetHealth() > unit:GetActualIncomingDamage(Siphon:GetSpecialValueInt('damage'), DAMAGE_TYPE_MAGICAL)
end

function X.ConsiderSiphon()
    if not J.CanCastAbility(Siphon) then return BOT_ACTION_DESIRE_NONE end
    local healing = J.GetHP(bot) < 0.65 and not bot:HasModifier('modifier_ice_blast')
    local urgent = healing and (bot:WasRecentlyDamagedByAnyHero(2) or J.GetHP(bot) < 0.4)
    local target = J.GetProperTarget(bot)
    local heroes = J.GetNearbyHeroes(bot, math.min(CastRange(Siphon), 1600), true, BOT_MODE_NONE)
    if urgent or J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200) or bot:HasModifier('modifier_death_prophet_exorcism') then
        local best, score = nil, -1
        for _, enemy in pairs(heroes) do
            if SiphonTarget(enemy) then
                local distance = GetUnitToUnitDistance(bot, enemy)
                local value = enemy:GetHealth() - distance + (enemy == target and 500 or 0)
                if value > score then best, score = enemy, value end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best, urgent end
    end
    if healing and (urgent or J.IsLaning(bot) or J.IsFarming(bot)) then
        local units = bot:GetNearbyLaneCreeps(math.min(CastRange(Siphon), 1600), true)
        for _, creep in pairs(bot:GetNearbyNeutralCreeps(math.min(CastRange(Siphon), 1600))) do table.insert(units, creep) end
        local best, health = nil, 0
        for _, creep in pairs(units) do
            if SiphonTarget(creep) and creep:GetHealth() > health then best, health = creep, creep:GetHealth() end
        end
        if best ~= nil and (urgent or Siphon:GetCurrentCharges() > 1) then return BOT_ACTION_DESIRE_HIGH, best, urgent end
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target)) or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and J.IsAttacking(bot) and SiphonTarget(target) and (healing or Siphon:GetCurrentCharges() > 1) then
        return BOT_ACTION_DESIRE_HIGH, target, urgent
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderExorcism()
    if not J.CanCastAbility(Exorcism) or bot:HasModifier('modifier_death_prophet_exorcism')
        or J.GetHP(bot) < 0.35 then return BOT_ACTION_DESIRE_NONE end
    local radius = Exorcism:GetSpecialValueInt('radius')
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnMagicImmune(target)
        and J.CanBeAttacked(target) and J.IsInRange(bot, target, radius)
        and not J.CannotBeKilled(bot, target) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsInTeamFight(bot, 1200) then
        local count = 0
        for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
            if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy) and J.CanBeAttacked(enemy) then count = count + 1 end
        end
        if count >= 2 then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsPushing(bot) and J.IsValidBuilding(target) and J.CanBeAttacked(target)
        and J.IsInRange(bot, target, radius) and J.GetHP(bot) > 0.45
        and target:GetHealth() > bot:GetAttackDamage() * 2
        and not target:HasModifier('modifier_fountain_glyph')
        and not target:HasModifier('modifier_backdoor_protection')
        and not target:HasModifier('modifier_backdoor_protection_active')
        and #bot:GetNearbyLaneCreeps(1000, false) > 0 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsDoingRoshan(bot) and J.IsRoshan(target) and J.CanBeAttacked(target)
        and J.IsAttacking(bot) and J.IsInRange(bot, target, radius) and J.GetHP(bot) > 0.6 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsDoingTormentor(bot) and J.IsTormentor(target) and J.CanBeAttacked(target)
        and J.IsAttacking(bot) and J.IsInRange(bot, target, radius) and J.GetHP(bot) > 0.65
        and #J.GetAlliesNearLoc(target:GetLocation(), 900) >= 3 then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

function X.SkillsComplement()
    Refresh()
    if J.CanNotUseAbility(bot) or J.IsRealInvisible(bot) then return end
    local silence, point, reason = X.ConsiderSilence()
    if silence > 0 and reason == 'interrupt' then bot:Action_UseAbilityOnLocation(Silence, point); return end
    local siphon, unit, urgent = X.ConsiderSiphon()
    if siphon > 0 and urgent then bot:Action_UseAbilityOnEntity(Siphon, unit); return end
    local swarm, wave, motive = X.ConsiderSwarm()
    if swarm > 0 and motive == 'lethal' then bot:Action_UseAbilityOnLocation(Swarm, wave); return end
    if X.ConsiderExorcism() > 0 then bot:Action_UseAbility(Exorcism); return end
    if silence > 0 then bot:Action_UseAbilityOnLocation(Silence, point); return end
    if siphon > 0 then bot:Action_UseAbilityOnEntity(Siphon, unit); return end
    if swarm > 0 then bot:Action_UseAbilityOnLocation(Swarm, wave) end
end
return X
