local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: position 1 only; forced other roles use the same build.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/bloodseeker')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Bloodrage, [2] Blood Rite, [3] Thirst, [6] Rupture. D2PT shows only the first ten
-- levels (Blood Rite and Bloodrage maxed, one Thirst point); later levels are a legal continuation.
local nAbilityBuildList = {2,3,2,1,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +30 Bloodrage attack speed
    t15={0,10}, -- -0.7% Bloodrage max health DPS
    t20={0,10}, -- +400 Rupture cast range
    t25={10,0}, -- +15% max Thirst move speed
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_tango', 'item_quelling_blade', 'item_branches', 'item_circlet', 'item_magic_stick', 'item_magic_wand',
    'item_phase_boots', 'item_maelstrom', 'item_mjollnir', 'item_black_king_bar', 'item_aghanims_shard',
    'item_basher', 'item_abyssal_blade',
    -- Reviewed late continuation: D2PT's 35-55 minute inventories carry Butterfly and Blink.
    'item_butterfly', 'item_blink', 'item_ultimate_scepter_2', 'item_moon_shard',
}
-- Purchase/sale pairs free early inventory slots as the main build arrives.
X.sSellList = {
    'item_phase_boots', 'item_quelling_blade',
    'item_butterfly', 'item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_melee_carry' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Bloodrage is maxed at 10 and the first talent comes at 11. Respect custom builds.
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
local abilityR = bot:GetAbilityByName(sAbilityList[6])
local BloodMist = bot:GetAbilityByName('bloodseeker_blood_mist')
local botTarget

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    botTarget = J.GetProperTarget(bot)
    -- Stop self damage first. Initiate with Rupture, then place Rite before its delayed detonation.
    if BloodMist ~= nil and BloodMist:GetToggleState() and X.ConsiderBloodMist() > 0 then
        bot:Action_UseAbility(BloodMist)
        return
    end
    local desire, target = X.ConsiderR()
    if desire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnEntity(abilityR, target)
        return
    end
    desire, target = X.ConsiderW()
    if desire > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbilityOnLocation(abilityW, target)
        return
    end
    if X.ConsiderQ() > 0 then bot:ActionQueue_UseAbility(abilityQ); return end
    if X.ConsiderBloodMist() > 0 then bot:Action_UseAbility(BloodMist) end
end

local function AbilityCastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    return range
end

local function ValidEnemy(enemy, immune)
    return J.IsValidHero(enemy) and (immune and J.CanCastOnMagicImmune(enemy) or not immune and J.CanCastOnNonMagicImmune(enemy))
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) then return 0 end
    local range = AbilityCastRange(abilityR)
    local function eligible(enemy)
        return ValidEnemy(enemy, true) and J.IsInRange(bot, enemy, range)
            and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_antimage_counterspell')
            and not enemy:HasModifier('modifier_antimage_counterspell_ally')
            and not enemy:HasModifier('modifier_bloodseeker_rupture')
    end
    if J.IsRetreating(bot) then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
            if eligible(enemy) and bot:WasRecentlyDamagedByHero(enemy, 2) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    if J.IsGoingOnSomeone(bot) and eligible(botTarget) then
        -- Rupture also constrains a disabled enemy once control expires; no two-ally requirement.
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    if J.IsInTeamFight(bot, 1200) then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
            if eligible(enemy) and J.Role.IsCarry(enemy:GetUnitName()) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    return 0
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local range, radius = AbilityCastRange(abilityW), abilityW:GetSpecialValueInt('radius')
    local delay = abilityW:GetCastPoint() + abilityW:GetSpecialValueFloat('delay')
    local damage, mana = abilityW:GetSpecialValueInt('damage'), abilityW:GetManaCost()
    local enemies = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    local function location(enemy)
        if not ValidEnemy(enemy, false) then return nil end
        -- Rupture forces a choice between leaving the ritual and taking movement damage.
        local loc = enemy:HasModifier('modifier_bloodseeker_rupture') and enemy:GetLocation()
            or enemy:GetExtrapolatedLocation(delay)
        local distance = GetUnitToLocationDistance(bot, loc)
        if distance > range + radius then return nil end
        if distance > range then loc = J.GetLocationTowardDistanceLocation(bot, loc, range) end
        return loc
    end
    for _, enemy in ipairs(enemies) do
        local loc = location(enemy)
        if loc and J.WillKillTarget(enemy, damage, DAMAGE_TYPE_PURE, delay) then
            return BOT_ACTION_DESIRE_HIGH, loc
        end
    end
    if J.IsGoingOnSomeone(bot) then
        local loc = location(botTarget)
        if loc then return BOT_ACTION_DESIRE_HIGH, loc end
    end
    if J.IsRetreating(bot) then
        for _, enemy in ipairs(enemies) do
            if ValidEnemy(enemy, false) and J.IsInRange(bot, enemy, radius)
                and bot:WasRecentlyDamagedByHero(enemy, 2) then
                return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
            end
        end
    end
    if J.IsInTeamFight(bot, 1200) then
        local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), range, radius, delay, 0)
        if aoe.count >= 2 and GetUnitToLocationDistance(bot, aoe.targetloc) <= range then
            return BOT_ACTION_DESIRE_HIGH, aoe.targetloc
        end
    end
    if not J.IsAllowedToSpam(bot, mana) then return 0 end
    if bot:GetActiveMode() == BOT_MODE_LANING then
        for _, creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range + radius, 1600), true)) do
            if J.IsValid(creep) and J.IsKeyWordUnit('ranged', creep)
                and not creep:HasModifier('modifier_fountain_glyph')
                and J.WillKillTarget(creep, damage, DAMAGE_TYPE_PURE, delay)
                and GetUnitToLocationDistance(bot, creep:GetLocation()) <= range then
                for _, enemy in ipairs(enemies) do
                    if ValidEnemy(enemy, false) and GetUnitToLocationDistance(enemy, creep:GetLocation()) <= radius then
                        return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
                    end
                end
            end
        end
    end
    if (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot)) and #enemies == 0 then
        local aoe = bot:FindAoELocation(true, false, bot:GetLocation(), range, radius, delay, damage)
        if aoe.count >= 4 and GetUnitToLocationDistance(bot, aoe.targetloc) <= range then
            return BOT_ACTION_DESIRE_HIGH, aoe.targetloc
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(botTarget)
        and J.IsAttacking(bot) and J.IsInRange(bot, botTarget, range) then
        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
    end
    return 0
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) or bot:HasModifier('modifier_bloodseeker_bloodrage') then return 0 end
    if J.IsRetreating(bot) then return 0 end
    if J.IsGoingOnSomeone(bot) and ValidEnemy(botTarget, true) and J.IsInRange(bot, botTarget, 600) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if (J.IsInTeamFight(bot, 1200) or J.IsPushing(bot) or J.IsDefending(bot))
        and #J.GetNearbyHeroes(bot, 600, true, BOT_MODE_NONE) > 0 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsValid(botTarget) and J.IsAttacking(bot)
        and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)
            or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot))
        and bot:GetHealth() / bot:GetMaxHealth() > 0.25
        and not J.CanKillTarget(botTarget, bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

function X.ConsiderBloodMist()
    if not bot:HasScepter() or not J.CanCastAbility(BloodMist) then return 0 end
    local radius = BloodMist:GetSpecialValueInt('radius')
    local hasEnemy = false
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)) do
        if ValidEnemy(enemy, false) and J.IsInRange(bot, enemy, radius) then hasEnemy = true end
    end
    local hp = bot:GetHealth() / bot:GetMaxHealth()
    if BloodMist:GetToggleState() then
        if hp <= 0.25 or not hasEnemy then return BOT_ACTION_DESIRE_HIGH end
    elseif hp > 0.55 and hasEnemy and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

return X
