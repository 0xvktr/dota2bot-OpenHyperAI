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

-- Updated to 7.41f from D2PT: carry, mid and offlane; forced supports use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/necrolyte')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Death Pulse, [2] Ghost Shroud, [3] Heartstopper Aura, [6] Reaper's Scythe.
local nAbilityBuildList = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +2s Sadist stack duration
    t15={10,0}, -- +60 Death Pulse heal
    t20=sRole=='pos_1' and {0,10} or {10,0}, -- spell area / Heartstopper regen reduction
    t25={10,0}, -- -2.5s Death Pulse cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_1 = {
    'item_magic_wand','item_faerie_fire','item_faerie_fire',
    'item_boots','item_radiance','item_travel_boots','item_aghanims_shard',
    'item_yasha','item_manta','item_heart','item_shivas_guard','item_black_king_bar',
    -- Bot policy: consume Scepter and upgrade travel boots without another permanent slot.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_travel_boots_2','item_moon_shard',
}
sRoleItemsBuyList.pos_2 = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_double_branches','item_double_circlet','item_tango','item_faerie_fire',
    'item_null_talisman','item_magic_wand','item_boots','item_radiance','item_travel_boots',
    'item_aghanims_shard','item_black_king_bar','item_heart','item_shivas_guard',
    -- Bot policy: Scepter/boots upgrades, then a defensive late-game slot.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_travel_boots_2',
    'item_cyclone','item_wind_waker','item_moon_shard',
}
sRoleItemsBuyList.pos_3 = {
    'item_double_branches','item_circlet','item_magic_stick','item_tango',
    'item_magic_wand','item_bracer','item_boots','item_radiance','item_travel_boots',
    'item_aghanims_shard','item_black_king_bar','item_heart','item_shivas_guard',
    -- Bot policy: Scepter/boots upgrades, then a defensive late-game slot.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_travel_boots_2',
    'item_cyclone','item_wind_waker','item_moon_shard',
}
sRoleItemsBuyList.pos_4 = sRoleItemsBuyList.pos_3
sRoleItemsBuyList.pos_5 = sRoleItemsBuyList.pos_3
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {
    'item_radiance','item_null_talisman','item_radiance','item_bracer',
    'item_shivas_guard','item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Observed ability at 10, first talent at 11; preserve custom overrides.
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


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityAS = bot:GetAbilityByName('necrolyte_death_seeker')
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire
local castWDesire
local castWQDesire
local castRDesire, castRTarget
local castASDesire, castASTarget

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList
local botTarget

function X.SkillsComplement()


	if J.CanNotUseAbility(bot) or bot:IsChanneling() then return end
	botTarget = J.GetProperTarget( bot )

	nKeepMana = 400
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )


	castRDesire, castRTarget = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return
	end

	castWDesire = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityW )
		return

	end
	
	castASDesire, castASTarget = X.ConsiderAS()
	if ( castASDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityAS, castASTarget )
		return

	end

	castQDesire = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityQ )
		return

	end

end


local function SpellRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    return range
end

local function Enemy(enemy)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) or bot:HasModifier('modifier_necrolyte_ghost_shroud') then return 0 end
    local physical, all = 0, 0
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) then
            physical = physical + enemy:GetEstimatedDamageToTarget(false, bot, 2, DAMAGE_TYPE_PHYSICAL)
            all = all + enemy:GetEstimatedDamageToTarget(false, bot, 2, DAMAGE_TYPE_ALL)
        end
    end
    local projectiles = J.GetAttackProjectileDamageByRange(bot, 1600)
    if bot:GetActualIncomingDamage(projectiles, DAMAGE_TYPE_PHYSICAL) >= bot:GetHealth()
        or physical >= bot:GetHealth() * 0.35 and physical >= all * 0.6
        and (J.IsRetreating(bot) or J.GetHP(bot) < 0.6) then return BOT_ACTION_DESIRE_HIGH end
    if not bot:HasModifier('modifier_ice_blast') and J.GetHP(bot) < 0.65
        and all - physical <= physical + bot:GetHealth() * 0.1
        and (bot:GetHealthRegen() >= 30 or J.CanCastAbility(abilityQ)
            and bot:GetMana() >= abilityW:GetManaCost() + abilityQ:GetManaCost()) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) or bot:IsInvisible() then return 0 end
    local radius = abilityQ:GetSpecialValueInt('area_of_effect')
    local heal = abilityQ:GetSpecialValueInt('heal')
    if not bot:HasModifier('modifier_ice_blast') and bot:GetMaxHealth() - bot:GetHealth() >= heal
        and (J.GetHP(bot) < 0.5 or bot:WasRecentlyDamagedByAnyHero(2) or J.IsAllowedToSpam(bot, abilityQ:GetManaCost())) then
        return BOT_ACTION_DESIRE_HIGH
    end
    for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and not ally:HasModifier('modifier_ice_blast') and J.IsInRange(bot, ally, radius)
            and ally:GetMaxHealth() - ally:GetHealth() >= heal
            and (J.GetHP(ally) < 0.4 or ally:WasRecentlyDamagedByAnyHero(2)
                or J.IsAllowedToSpam(bot, abilityQ:GetManaCost())) then return BOT_ACTION_DESIRE_HIGH end
    end
    local damage = abilityQ:GetAbilityDamage()
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, radius)
            and (enemy:HasModifier('modifier_necrolyte_reapers_scythe') or J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL)
                or J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then return BOT_ACTION_DESIRE_HIGH end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot))
        and J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then
        local creeps, kills = bot:GetNearbyCreeps(radius, true), 0
        for _, creep in ipairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep)
                and J.CanKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL) then kills = kills + 1 end
        end
        if kills >= 2 or #creeps >= 3 and not J.IsLaning(bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsValid(botTarget) and (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.CanCastOnNonMagicImmune(botTarget) and J.IsInRange(bot, botTarget, radius)
        and J.IsAttacking(bot) and J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.GetEstDamage(_, enemy, coefficient)
    local delay = abilityR:GetCastPoint() + abilityR:GetSpecialValueFloat('stun_duration')
    local futureHP = math.min(enemy:GetMaxHealth(), enemy:GetHealth() + math.max(0, enemy:GetHealthRegen()) * delay)
    local pulseDamage = 0
    -- Only budget a Pulse that arrives before the Scythe lands and whose mana is reserved.
    if J.CanCastAbility(abilityQ) and bot:GetMana() >= abilityR:GetManaCost() + abilityQ:GetManaCost()
        and J.IsInRange(bot, enemy, abilityQ:GetSpecialValueInt('area_of_effect'))
        and GetUnitToUnitDistance(bot, enemy) / abilityQ:GetSpecialValueInt('projectile_speed')
            + abilityQ:GetCastPoint() < abilityR:GetSpecialValueFloat('stun_duration') then
        pulseDamage = enemy:GetActualIncomingDamage(abilityQ:GetAbilityDamage(), DAMAGE_TYPE_MAGICAL)
    end
    return math.max(0, enemy:GetMaxHealth() - futureHP + pulseDamage) * coefficient
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) then return 0 end
    local range = SpellRange(abilityR)
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
        if Enemy(enemy) and J.IsInRange(bot, enemy, range) and not J.IsHaveAegis(enemy)
            and not enemy:HasModifier('modifier_arc_warden_tempest_double')
            and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
            and not J.CannotBeKilled(bot, enemy) then
            local damage = X.GetEstDamage(bot, enemy, abilityR:GetSpecialValueFloat('damage_per_health'))
            local delay = abilityR:GetCastPoint() + abilityR:GetSpecialValueFloat('stun_duration')
            if J.WillKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL, delay)
                or enemy:IsChanneling() and enemy:HasModifier('modifier_teleporting') then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    return 0
end

function X.ConsiderAS()
    if not J.CanCastAbility(abilityAS) or bot:IsRooted() then return 0 end
    local range = SpellRange(abilityAS)
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        local best, safest = nil, #J.GetNearbyHeroes(bot, 700, true, BOT_MODE_NONE)
        for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), false, BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
                and J.IsInRange(bot, ally, range) and not J.IsInRange(bot, ally, 250) then
                local danger = #J.GetNearbyHeroes(ally, 700, true, BOT_MODE_NONE)
                if danger < safest then best, safest = ally, danger end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    end
    if J.IsGoingOnSomeone(bot) and Enemy(botTarget) and J.IsInRange(bot, botTarget, range)
        and not J.IsInRange(bot, botTarget, 250) and J.GetHP(bot) > 0.35 then
        local allies = J.GetNearbyHeroes(botTarget, 800, false, BOT_MODE_NONE)
        local enemies = J.GetNearbyHeroes(botTarget, 800, true, BOT_MODE_NONE)
        if #allies + 1 >= #enemies then return BOT_ACTION_DESIRE_HIGH, botTarget end
    end
    -- Reposition to a wounded ally for healing; don't jump blindly into a stronger enemy cluster.
    if J.CanCastAbility(abilityQ) and J.GetHP(bot) > 0.4 then
        for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), false, BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
                and not ally:HasModifier('modifier_ice_blast') and J.GetHP(ally) < 0.4
                and J.IsInRange(bot, ally, range)
                and #J.GetNearbyHeroes(ally, 700, true, BOT_MODE_NONE) <= 1 then
                return BOT_ACTION_DESIRE_HIGH, ally
            end
        end
    end
    return 0
end

return X
