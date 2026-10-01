local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: positions 5, 4 and 2 (mid, a reviewed exception); forced other roles use pos 5.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/crystal_maiden')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Crystal Nova, [2] Frostbite, [3] Arcane Aura, [6] Freezing Field.
-- D2PT shows only the first ten levels; later levels are a legal continuation.
local nAbilityBuildList, nTalentBuildList
if sRole == 'pos_2' then
    nAbilityBuildList = {1,3,1,2,2,6,2,2,3,3,6,1,1,3,6}
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={0,10}, -- +200 health
        t15={10,0}, -- -4.5s Crystal Nova cooldown
        t20={10,0}, -- +50 Freezing Field damage
        t25={10,0}, -- +300 Crystal Nova damage
    })
else
    nAbilityBuildList = {2,3,2,1,2,6,2,3,3,3,6,1,1,1,6}
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={0,10}, -- +200 health
        t15={0,10}, -- +100 Frostbite cast range
        t20={10,0}, -- +50 Freezing Field damage
        t25={0,10}, -- +1s Frostbite duration
    })
end
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_2' then
    X.sBuyList = {
        'item_tango', 'item_double_branches', 'item_branches', 'item_enchanted_mango', 'item_faerie_fire',
        'item_bottle', 'item_null_talisman', 'item_magic_wand', 'item_power_treads', 'item_blink',
        'item_aghanims_shard', 'item_black_king_bar', 'item_ultimate_scepter', 'item_shivas_guard',
        -- Late upgrades/slot policy beyond the displayed core progression.
        'item_overwhelming_blink', 'item_ultimate_scepter_2', 'item_sheepstick', 'item_moon_shard',
    }
    X.sSellList = {
        'item_ultimate_scepter', 'item_magic_wand',
        'item_shivas_guard', 'item_null_talisman',
        'item_sheepstick', 'item_bottle',
    }
else
    X.sBuyList = {
        'item_tango', 'item_branches', 'item_magic_stick', 'item_ward_sentry',
        'item_enchanted_mango', 'item_enchanted_mango', 'item_blood_grenade',
        'item_magic_wand', 'item_tranquil_boots', 'item_aghanims_shard', 'item_blink',
    }
    if sRole == 'pos_4' then
        -- D2PT pos 4 buys BKB (54%) and Scepter (44%) more often than Glimmer (20%).
        for _, item in ipairs({'item_black_king_bar', 'item_ultimate_scepter', 'item_glimmer_cape'}) do table.insert(X.sBuyList, item) end
    else
        -- D2PT pos 5 buys Glimmer around 25m, before BKB and Scepter.
        for _, item in ipairs({'item_glimmer_cape', 'item_black_king_bar', 'item_ultimate_scepter'}) do table.insert(X.sBuyList, item) end
    end
    -- Reviewed utility/upgrade continuation, not additional mandatory D2PT core items.
    for _, item in ipairs({'item_aeon_disk', 'item_ultimate_scepter_2', 'item_overwhelming_blink'}) do table.insert(X.sBuyList, item) end
    X.sSellList = {'item_aeon_disk', 'item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Every role spends level 10 on an ability, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

local abilityQ=bot:GetAbilityByName(sAbilityList[1])
local abilityW=bot:GetAbilityByName(sAbilityList[2])
local abilityR=bot:GetAbilityByName(sAbilityList[6])
local CrystalClone=bot:GetAbilityByName('crystal_maiden_crystal_clone')

local cloneOrigin, cloneExpires = nil, 0

local function RememberClone()
    cloneOrigin = bot:GetLocation()
    cloneExpires = DotaTime() + CrystalClone:GetSpecialValueInt('clone_duration')
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    return range
end

local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit)
end

local function FrostbiteTarget(unit)
    return J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit)
        and J.IsInRange(bot, unit, CastRange(abilityW)) and J.CanCastOnTargetAdvanced(unit)
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
        and not unit:HasModifier('modifier_crystal_maiden_frostbite')
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local enemies = J.GetNearbyHeroes(bot, math.min(CastRange(abilityW), 1600), true, BOT_MODE_NONE)
    local duration = abilityW:GetSpecialValueFloat('duration')
    local damage = abilityW:GetSpecialValueInt('damage_per_second') * duration
    for _, enemy in ipairs(enemies) do
        if FrostbiteTarget(enemy) then
            -- Frostbite is a root: it cancels teleports, not arbitrary spell channels.
            if enemy:IsChanneling() and enemy:HasModifier('modifier_teleporting') then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            if J.WillMagicKillTarget(bot, enemy, damage, abilityW:GetCastPoint() + duration) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and FrostbiteTarget(target) and not J.IsDisabled(target) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    local best, power = nil, 0
    for _, enemy in ipairs(enemies) do
        if FrostbiteTarget(enemy) and not J.IsDisabled(enemy) then
            if J.IsRetreating(bot) and bot:WasRecentlyDamagedByHero(enemy, 3) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            if J.IsInTeamFight(bot, 1200) then
                local value = enemy:GetEstimatedDamageToTarget(false, bot, 3, DAMAGE_TYPE_PHYSICAL)
                if value > power then best, power = enemy, value end
            end
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH, best end
    if J.IsFarming(bot) and #enemies == 0 and J.IsAllowedToSpam(bot, abilityW:GetManaCost()) then
        local strongest = nil
        for _, creep in ipairs(bot:GetNearbyNeutralCreeps(math.min(CastRange(abilityW), 1600))) do
            if FrostbiteTarget(creep) and not creep:IsAncientCreep() and not J.IsOtherAllysTarget(creep)
                and creep:GetHealth() > bot:GetAttackDamage() * 2
                and (strongest == nil or creep:GetHealth() > strongest:GetHealth()) then strongest = creep end
        end
        if strongest then return BOT_ACTION_DESIRE_HIGH, strongest end
    end
    -- Non-ancient summons take four times the hero DPS; do not exclude them with hero-only checks.
    if not J.IsRetreating(bot) then
        for _, creep in ipairs(bot:GetNearbyCreeps(math.min(CastRange(abilityW), 1600), true)) do
            if FrostbiteTarget(creep) and not creep:IsAncientCreep() and creep:IsDominated()
                and creep:GetHealth() > bot:GetAttackDamage() * 2 then return BOT_ACTION_DESIRE_HIGH, creep end
        end
    end
    return 0
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    local range, radius = CastRange(abilityQ), abilityQ:GetSpecialValueInt('radius')
    local delay, damage = abilityQ:GetCastPoint(), abilityQ:GetSpecialValueInt('nova_damage')
    local enemies = J.GetNearbyHeroes(bot, math.min(range + radius, 1600), true, BOT_MODE_NONE)
    if cloneOrigin ~= nil and DotaTime() < cloneExpires and CrystalClone ~= nil
        and damage >= CrystalClone:GetSpecialValueInt('clone_health')
        and GetUnitToLocationDistance(bot, cloneOrigin) <= range then
        for _, enemy in ipairs(enemies) do
            if Enemy(enemy) and GetUnitToLocationDistance(enemy, cloneOrigin) <= CrystalClone:GetSpecialValueInt('frostbite_radius') then
                return BOT_ACTION_DESIRE_HIGH, cloneOrigin
            end
        end
    end
    local function location(enemy)
        if not Enemy(enemy) then return nil end
        local loc = enemy:GetExtrapolatedLocation(delay)
        local distance = GetUnitToLocationDistance(bot, loc)
        if distance > range + radius then return nil end
        if distance > range then loc = J.GetLocationTowardDistanceLocation(bot, loc, range) end
        return loc
    end
    for _, enemy in ipairs(enemies) do
        local loc = location(enemy)
        if loc and J.WillMagicKillTarget(bot, enemy, damage, delay) then return BOT_ACTION_DESIRE_HIGH, loc end
    end
    if J.IsGoingOnSomeone(bot) then
        local loc = location(J.GetProperTarget(bot))
        if loc then return BOT_ACTION_DESIRE_HIGH, loc end
    end
    if J.IsRetreating(bot) then
        for _, enemy in ipairs(enemies) do
            local loc = location(enemy)
            if loc and bot:WasRecentlyDamagedByHero(enemy, 3) then return BOT_ACTION_DESIRE_HIGH, loc end
        end
    end
    if J.IsInTeamFight(bot, 1200) or bot:GetActiveMode() == BOT_MODE_LANING then
        local best, bestCount = nil, 1
        for _, enemy in ipairs(enemies) do
            local loc = location(enemy)
            if loc then
                local count = 0
                for _, other in ipairs(enemies) do
                    if Enemy(other) and GetUnitToLocationDistance(other, loc) <= radius then count = count + 1 end
                end
                if count > bestCount then best, bestCount = loc, count end
            end
        end
        if best and J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH, best end
    end
    if not J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then return 0 end
    if bot:GetActiveMode() == BOT_MODE_LANING then
        for _, creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range + radius, 1600), true)) do
            if J.IsValid(creep) and J.IsKeyWordUnit('ranged', creep)
                and not creep:HasModifier('modifier_fountain_glyph')
                and J.WillMagicKillTarget(bot, creep, damage, delay)
                and GetUnitToLocationDistance(bot, creep:GetLocation()) <= range then
                for _, enemy in ipairs(enemies) do
                    if Enemy(enemy) and GetUnitToLocationDistance(enemy, creep:GetLocation()) <= radius then
                        return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
                    end
                end
            end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and #enemies == 0 then
        local aoe = bot:FindAoELocation(true, false, bot:GetLocation(), range, radius, delay, damage)
        if aoe.count >= 3 and GetUnitToLocationDistance(bot, aoe.targetloc) <= range then
            return BOT_ACTION_DESIRE_HIGH, aoe.targetloc
        end
    end
    return 0
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) or bot:DistanceFromFountain() < 500 then return 0 end
    local radius = abilityR:GetSpecialValueInt('radius')
    local count, controlled = 0, 0
    local target = J.GetProperTarget(bot)
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)) do
        if Enemy(enemy) and GetUnitToLocationDistance(bot, enemy:GetExtrapolatedLocation(1)) <= radius then
            count = count + 1
            if J.IsDisabled(enemy) then controlled = controlled + 1 end
        end
    end
    local protected = bot:IsMagicImmune() or bot:IsInvisible()
        or bot:HasModifier('modifier_item_glimmer_cape_fade') or bot:HasModifier('modifier_item_glimmer_cape')
    if bot:GetHealth() / bot:GetMaxHealth() < 0.35 and not protected then return 0 end
    if J.IsRetreating(bot) and not protected then return 0 end
    local allies = J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE)
    local supported = false
    for _, ally in ipairs(allies) do if ally ~= bot and J.IsValidHero(ally) then supported = true end end
    if count >= 2 and (protected or supported and (controlled > 0 or not bot:WasRecentlyDamagedByAnyHero(2))) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsDisabled(target)
        and J.IsInRange(bot, target, radius) and target:GetHealth() > 300 and (protected or supported) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

function X.ConsiderCrystalClone()
    if not J.CanCastAbility(CrystalClone) then return 0 end
    local distance = CrystalClone:GetSpecialValueInt('hop_distance')
    local radius = CrystalClone:GetSpecialValueInt('frostbite_radius')
    local field = bot:HasModifier('modifier_crystal_maiden_freezing_field')
    if J.IsUnitTargetProjectileIncoming(bot, 800) or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        return BOT_ACTION_DESIRE_HIGH, J.GetLocationTowardDistanceLocation(bot, J.GetTeamFountain(), distance)
    end
    local target = J.GetProperTarget(bot)
    if field and Enemy(target) and not J.IsInRange(bot, target, abilityR ~= nil and abilityR:GetSpecialValueInt('radius') * 0.75 or 600)
        and J.IsInRange(bot, target, 1000) then
        return BOT_ACTION_DESIRE_HIGH, J.GetLocationTowardDistanceLocation(bot, target:GetLocation(), distance)
    end
    if not field and J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsInRange(bot, target, radius)
        and not J.IsDisabled(target) and J.CanCastAbility(bot:GetAbilityByName('crystal_maiden_crystal_nova')) then
        return BOT_ACTION_DESIRE_HIGH, J.GetLocationTowardDistanceLocation(bot, J.GetTeamFountain(), distance)
    end
    return 0
end

local function FieldCanCast()
    if bot:IsChanneling() then
        local active = bot:GetCurrentActiveAbility()
        if active == nil or active:GetName() ~= 'crystal_maiden_freezing_field' then return false end
    end
    return bot:HasModifier('modifier_crystal_maiden_freezing_field') and bot:IsAlive()
        and not bot:IsStunned() and not bot:IsHexed() and not bot:IsSilenced() and not bot:IsNightmared()
end

function X.SkillsComplement()
    local field = FieldCanCast()
    if bot:IsCastingAbility() or bot:NumQueuedActions() > 0 then return end
    if field then
        local desire, location = X.ConsiderCrystalClone()
        if desire > 0 then RememberClone(); bot:Action_UseAbilityOnLocation(CrystalClone, location); return end
        if not bot:HasScepter() then return end
    elseif J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    local desire, target = X.ConsiderW()
    if desire > 0 then
        if field then bot:Action_UseAbilityOnEntity(abilityW, target)
        else bot:ActionQueue_UseAbilityOnEntity(abilityW, target) end
        return
    end
    if not field then
        desire, target = X.ConsiderCrystalClone()
        if desire > 0 then RememberClone(); bot:ActionQueue_UseAbilityOnLocation(CrystalClone, target); return end
    end
    desire, target = X.ConsiderQ()
    if desire > 0 then
        if field then bot:Action_UseAbilityOnLocation(abilityQ, target)
        else bot:ActionQueue_UseAbilityOnLocation(abilityQ, target) end
        return
    end
    if not field and X.ConsiderR() > 0 then
        J.SetQueuePtToINT(bot, false)
        bot:ActionQueue_UseAbility(abilityR)
    end
end

-- Aura is passive; channel-preserving item use belongs to the generic item policy.
function X.ConsiderArcaneAura() return 0 end
function X.ConsiderCombo() return false end
return X
