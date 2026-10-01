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

-- Updated to 7.41f from D2PT, positions 4 and 5; other forced roles use pos 5.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/bane')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local nAbilityBuildList = {2,3,2,3,2,6,2,3,3,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Enfeeble cast range reduction
    t15={10,0}, -- Fiend's Grip mana drain
    t20={0,10}, -- Nightmare cooldown
    t25={10,0}, -- Fiend's Grip duration
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_double_branches', 'item_magic_stick', 'item_ward_sentry',
    'item_tango', 'item_faerie_fire', 'item_blood_grenade',
    'item_magic_wand', 'item_arcane_boots', 'item_aether_lens',
}
if sRole == 'pos_4' then
    -- D2PT pos 4 progression prioritizes Blink and Scepter.
    table.insert(X.sBuyList, 'item_blink')
    table.insert(X.sBuyList, 'item_ultimate_scepter')
    table.insert(X.sBuyList, 'item_aghanims_shard')
else
    -- D2PT pos 5 progression includes Shard before Scepter; Blink is 46.9% purchased.
    table.insert(X.sBuyList, 'item_blink')
    table.insert(X.sBuyList, 'item_aghanims_shard')
    table.insert(X.sBuyList, 'item_ultimate_scepter')
end
-- Reviewed utility/upgrade continuation, not additional mandatory D2PT core items.
for _, item in ipairs({
    'item_glimmer_cape', 'item_ultimate_scepter_2', 'item_aeon_disk',
    'item_arcane_blink', 'item_mekansm', 'item_guardian_greaves', 'item_moon_shard',
}) do table.insert(X.sBuyList, item) end
X.sSellList = {'item_ultimate_scepter', 'item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Both roles take Enfeeble at 10, then their first talent at 11.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[


npc_dota_hero_bane


"Ability1"		"bane_enfeeble"
"Ability2"		"bane_brain_sap"
"Ability3"		"bane_nightmare"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"bane_fiends_grip"
"Ability7"		"bane_nightmare_end"


modifier_bane_enfeeble
modifier_bane_nightmare
modifier_bane_nightmare_invulnerable
modifier_bane_fiends_grip
modifier_bane_fiends_grip_self


--]]

local abilityQ = bot:GetAbilityByName(sAbilityList[1])
local abilityW = bot:GetAbilityByName(sAbilityList[2])
local abilityE = bot:GetAbilityByName(sAbilityList[3])
local abilityR = bot:GetAbilityByName(sAbilityList[6])
local sapTalent = bot:GetAbilityByName(sTalentList[8])
local botTarget, nMP, nLV

local function AbilityCastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    return range
end

local function CanTarget(enemy, ability, pierces)
    return J.IsValidHero(enemy) and enemy:CanBeSeen() and not enemy:IsInvulnerable()
        and not J.IsSuspiciousIllusion(enemy) and J.IsInRange(bot, enemy, AbilityCastRange(ability))
        and (pierces or not enemy:IsMagicImmune()) and J.CanCastOnTargetAdvanced(enemy)
        and not enemy:HasModifier('modifier_antimage_counterspell')
        and not enemy:HasModifier('modifier_legion_commander_duel')
        and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
end

local savedAlly, releaseTime
local function ReleaseSavedAlly()
    local ending = bot:GetAbilityByName('bane_nightmare_end')
    if savedAlly == nil or DotaTime() < releaseTime then return false end
    if not savedAlly:HasModifier('modifier_bane_nightmare') then savedAlly = nil; return false end
    if savedAlly:HasModifier('modifier_bane_nightmare_invulnerable') then return false end
    -- End is not an ignore-channel spell; defer it until the current cast/queue finishes.
    if bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility()
        or bot:NumQueuedActions() > 0 then return false end
    -- Nightmare End affects every sleeper; preserve an enemy disable if one remains.
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if J.IsValidHero(enemy) and enemy:HasModifier('modifier_bane_nightmare') then return false end
    end
    if ending ~= nil and ending:IsFullyCastable() then
        bot:Action_UseAbility(ending)
        savedAlly = nil
        return true
    end
    return false
end

local function RememberSave(target, ability)
    if target:GetTeam() == bot:GetTeam() then
        savedAlly = target
        releaseTime = DotaTime() + ability:GetCastPoint()
            + ability:GetSpecialValueFloat('nightmare_invuln_time') + 0.1
    end
end

function X.ConsiderE()
    if abilityE == nil or not abilityE:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range = AbilityCastRange(abilityE)
    local allies = J.GetAlliesNearLoc(bot:GetLocation(), range)
    table.insert(allies, bot)
    for _, ally in pairs(allies) do
        if J.IsValidHero(ally) and ally:CanBeSeen() and J.IsInRange(bot, ally, range)
            and not ally:IsInvulnerable() and not ally:IsMagicImmune()
            and not J.IsSuspiciousIllusion(ally) and not ally:IsChanneling()
            and not ally:HasModifier('modifier_bane_nightmare')
            and J.GetHP(ally) < 0.35 and J.IsUnitTargetProjectileIncoming(ally, 600) then
            return BOT_ACTION_DESIRE_HIGH, ally, 'Nightmare projectile save'
        end
    end
    local enemies = J.GetAroundEnemyHeroList(range)
    for _, enemy in pairs(enemies) do
        if CanTarget(enemy, abilityE, false) and enemy:IsChanneling() then
            return BOT_ACTION_DESIRE_HIGH, enemy, 'Nightmare interrupt'
        end
    end
    if J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200) then
        local strongest, power = nil, -1
        for _, enemy in pairs(enemies) do
            if CanTarget(enemy, abilityE, false) and enemy ~= botTarget
                and not J.IsDisabled(enemy) and not enemy:IsDisarmed() then
                local damage = enemy:GetEstimatedDamageToTarget(true, bot, 6, DAMAGE_TYPE_ALL)
                if damage > power then strongest, power = enemy, damage end
            end
        end
        -- Sleep a second enemy; leave the kill target available for Grip and allies.
        if strongest ~= nil then return BOT_ACTION_DESIRE_HIGH, strongest, 'Nightmare secondary enemy' end
        if CanTarget(botTarget, abilityE, false) and not J.IsDisabled(botTarget)
            and J.IsChasingTarget(bot, botTarget) and not J.IsInRange(bot, botTarget, 400)
            and (abilityR == nil or not abilityR:IsFullyCastable()
                or not J.IsInRange(bot, botTarget, AbilityCastRange(abilityR))) then
            return BOT_ACTION_DESIRE_HIGH, botTarget, 'Nightmare catch'
        end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        for _, enemy in pairs(enemies) do
            if CanTarget(enemy, abilityE, false) and not J.IsDisabled(enemy) then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'Nightmare retreat'
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderR()
    if abilityR == nil or not abilityR:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local enemies = J.GetAroundEnemyHeroList(AbilityCastRange(abilityR))
    for _, enemy in pairs(enemies) do
        if CanTarget(enemy, abilityR, true) and enemy:IsChanneling() then
            return BOT_ACTION_DESIRE_HIGH, enemy, 'Grip interrupt'
        end
    end
    if J.IsGoingOnSomeone(bot) and CanTarget(botTarget, abilityR, true)
        and not J.IsDisabled(botTarget) and not botTarget:HasModifier('modifier_abaddon_borrowed_time') then
        return BOT_ACTION_DESIRE_HIGH, botTarget, 'Grip kill target'
    end
    if J.IsInTeamFight(bot, 1200) then
        local strongest, power = nil, -1
        for _, enemy in pairs(enemies) do
            if CanTarget(enemy, abilityR, true) and not J.IsDisabled(enemy)
                and not enemy:HasModifier('modifier_abaddon_borrowed_time') then
                local damage = enemy:GetEstimatedDamageToTarget(true, bot, 6, DAMAGE_TYPE_ALL)
                if damage > power then strongest, power = enemy, damage end
            end
        end
        if strongest ~= nil then return BOT_ACTION_DESIRE_HIGH, strongest, 'Grip strongest enemy' end
    end
    -- Kill estimates use the current level/talent channel duration, not a fixed six seconds.
    local damage = abilityR:GetSpecialValueInt('fiend_grip_damage') * abilityR:GetChannelTime()
    for _, enemy in pairs(enemies) do
        if CanTarget(enemy, abilityR, true) and not J.IsDisabled(enemy)
            and not J.CannotBeKilled(bot, enemy) and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_PURE) then
            return BOT_ACTION_DESIRE_HIGH, enemy, 'Grip lethal'
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW()
    if abilityW == nil or not abilityW:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range, damage = AbilityCastRange(abilityW), abilityW:GetSpecialValueInt('brain_sap_damage')
    if sapTalent:IsTrained() then damage = damage + sapTalent:GetSpecialValueInt('value') end
    local enemies = J.GetAroundEnemyHeroList(range)
    local lostHP = bot:GetMaxHealth() - bot:GetHealth()
    for _, enemy in pairs(enemies) do
        if CanTarget(enemy, abilityW, true) and not J.CannotBeKilled(bot, enemy)
            and J.WillKillTarget(enemy, damage, DAMAGE_TYPE_PURE, abilityW:GetCastPoint()) then
            return BOT_ACTION_DESIRE_HIGH, enemy, 'Sap lethal'
        end
    end
    if nLV <= 7 and nMP < 0.72 and lostHP < damage * 0.8 then return BOT_ACTION_DESIRE_NONE end
    if J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)
        or (bot:WasRecentlyDamagedByAnyHero(3) and lostHP >= damage) then
        local best, score = nil, -1
        local radius = abilityW:GetSpecialValueInt('shard_radius')
        for _, enemy in pairs(enemies) do
            if CanTarget(enemy, abilityW, true) and not enemy:HasModifier('modifier_bane_nightmare')
                and not enemy:HasModifier('modifier_abaddon_borrowed_time') then
                local hits, wakes = 1, false
                if radius > 0 then
                    for _, other in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
                        if other ~= enemy and J.IsValidHero(other) and not other:IsInvulnerable()
                            and J.IsInRange(enemy, other, radius) then
                            if other:HasModifier('modifier_bane_nightmare') then wakes = true end
                            if not J.IsSuspiciousIllusion(other) then hits = hits + 1 end
                        end
                    end
                end
                local value = hits * 10000 - enemy:GetHealth()
                if not wakes and value > score then best, score = enemy, value end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best, 'Sap combat sustain' end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)
        or (J.IsRetreating(bot) and #enemies == 0 and not bot:WasRecentlyDamagedByAnyHero(3)))
        and abilityW:GetLevel() >= 3 and J.IsAllowedToSpam(bot, abilityW:GetManaCost()) then
        local creeps = bot:GetNearbyCreeps(range, true)
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and J.IsInRange(bot, creep, range) and not creep:IsInvulnerable()
                and not creep:HasModifier('modifier_fountain_glyph')
                and not J.CanKillTarget(creep, bot:GetAttackDamage() * 1.4, DAMAGE_TYPE_PHYSICAL)
                and (lostHP >= damage or J.WillKillTarget(creep, damage, DAMAGE_TYPE_PURE, abilityW:GetCastPoint())) then
                return BOT_ACTION_DESIRE_HIGH, creep, 'Sap creep sustain'
            end
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(botTarget)
        and J.IsInRange(bot, botTarget, range) and J.IsAttacking(bot)
        and not botTarget:IsInvulnerable() and J.CanCastOnTargetAdvanced(botTarget) then
        return BOT_ACTION_DESIRE_HIGH, botTarget, 'Sap boss'
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderQ()
    if abilityQ == nil or not abilityQ:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    if J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)
        or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3)) then
        local strongest, power = nil, -1
        for _, enemy in pairs(J.GetAroundEnemyHeroList(AbilityCastRange(abilityQ))) do
            if CanTarget(enemy, abilityQ, false) and not enemy:HasModifier('modifier_bane_enfeeble_effect')
                and not J.IsDisabled(enemy) then
                local damage = enemy:GetEstimatedDamageToTarget(true, bot, 6, DAMAGE_TYPE_ALL)
                if damage > power then strongest, power = enemy, damage end
            end
        end
        if strongest ~= nil then return BOT_ACTION_DESIRE_HIGH, strongest, 'Enfeeble strongest enemy' end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.SkillsComplement()
    if ReleaseSavedAlly() then return end
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    botTarget, nMP, nLV = J.GetProperTarget(bot), bot:GetMana() / bot:GetMaxMana(), bot:GetLevel()
    local nightmareDesire, nightmareTarget, nightmareReason = X.ConsiderE()
    if nightmareDesire > 0 and (nightmareReason == 'Nightmare projectile save'
        or nightmareReason == 'Nightmare interrupt') then
        RememberSave(nightmareTarget, abilityE)
        J.SetQueuePtToINT(bot, true)
        bot:ActionQueue_UseAbilityOnEntity(abilityE, nightmareTarget)
        return
    end
    -- Take an immediate Sap kill or emergency heal before committing to a long channel.
    local sapDesire, sapTarget, sapReason = X.ConsiderW()
    if sapDesire > 0 and (sapReason == 'Sap lethal' or J.GetHP(bot) < 0.3) then
        J.SetQueuePtToINT(bot, true)
        bot:ActionQueue_UseAbilityOnEntity(abilityW, sapTarget)
        return
    end
    -- Disable the second enemy first, then Grip; ordinary damage/debuff casts must not delay control.
    for _, spell in ipairs({{abilityE, X.ConsiderE}, {abilityR, X.ConsiderR},
        {abilityW, X.ConsiderW}, {abilityQ, X.ConsiderQ}}) do
        local desire, target = spell[2]()
        if desire > 0 then
            if spell[1] == abilityE then RememberSave(target, abilityE) end
            J.SetQueuePtToINT(bot, true)
            if spell[1] == abilityR then J.SetQueueToInvisible(bot) end
            bot:ActionQueue_UseAbilityOnEntity(spell[1], target)
            return
        end
    end
end

return X
