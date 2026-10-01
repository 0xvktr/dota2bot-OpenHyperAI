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
local ItemCastPolicy = require(GetScriptDirectory()..'/FunLib/item_cast_policy')
local PowerTreads = require(GetScriptDirectory()..'/FunLib/power_treads')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: positions 3 (offlane) and 1 (carry); forced other roles use pos 3.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/chaos_knight')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Chaos Bolt, [2] Reality Rift, [3] Chaos Strike, [6] Phantasm.
-- Both roles share D2PT's most popular first ten levels; later levels are a legal continuation.
local nAbilityBuildList = {1,2,3,3,3,6,3,2,2,2,6,1,1,1,6}
local nTalentBuildList
if sRole == 'pos_1' then
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={0,10}, -- +30% Chaos Strike lifesteal
        t15={10,0}, -- +10 Strength
        t20={10,0}, -- Reality Rift pierces spell immunity
        t25={0,10}, -- +10% Chaos Strike chance
    })
else
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={0,10}, -- +30% Chaos Strike lifesteal
        t15={10,0}, -- +10 Strength
        t20={10,0}, -- Reality Rift pierces spell immunity
        t25={10,0}, -- -125% Phantasm illusion incoming damage
    })
end
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_1' then
    X.sBuyList = {
        'item_tango', 'item_quelling_blade', 'item_gauntlets', 'item_double_branches', 'item_circlet',
        'item_magic_wand', 'item_power_treads', 'item_armlet', 'item_orchid', 'item_blink',
        'item_aghanims_shard', 'item_manta', 'item_bloodthorn', 'item_black_king_bar',
        -- Late upgrades/slot policy beyond the displayed core progression.
        'item_overwhelming_blink', 'item_ultimate_scepter_2', 'item_moon_shard',
    }
    X.sSellList = {
        'item_manta', 'item_quelling_blade',
        'item_black_king_bar', 'item_magic_wand',
    }
else
    X.sBuyList = {
        'item_tango', 'item_quelling_blade', 'item_gauntlets', 'item_double_branches', 'item_circlet',
        'item_magic_wand', 'item_power_treads', 'item_soul_ring', 'item_armlet', 'item_blink',
        'item_aghanims_shard', 'item_orchid', 'item_bloodthorn', 'item_black_king_bar', 'item_manta',
        -- Late upgrades/slot policy beyond the displayed core progression.
        'item_overwhelming_blink', 'item_ultimate_scepter_2', 'item_moon_shard',
    }
    X.sSellList = {
        'item_orchid', 'item_quelling_blade',
        'item_black_king_bar', 'item_soul_ring',
        'item_manta', 'item_magic_wand',
    }
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Reality Rift takes level 10, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = true
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

local function UseBolt(target, urgent)
    if not abilityQ:IsFullyCastable() then
        return ItemCastPolicy.Request(bot, abilityQ, target, 'unit', function()
            local desire, currentTarget = X.ConsiderQ()
            return desire > 0 and currentTarget == target
        end, J)
    end
    if not urgent then J.SetQueuePtToINT(bot, true, abilityQ) end
    bot:ActionQueue_UseAbilityOnEntity(abilityQ, target)
    return true
end

function X.SkillsComplement()
    ItemCastPolicy.Clear(bot)
    if PowerTreads.ActionLocked(bot) then return end
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    local desire, target = X.ConsiderQ()
    local urgent = desire > 0 and (target:IsChanneling()
        or J.WillMagicKillTarget(bot, target, abilityQ:GetSpecialValueInt('damage_min'),
            abilityQ:GetCastPoint() + GetUnitToUnitDistance(bot, target) / abilityQ:GetSpecialValueInt('chaos_bolt_speed')))
    if urgent then
        if UseBolt(target, true) then return end
        desire = 0
    end
    if X.ConsiderR() > 0 then
        local armlet = J.IsItemAvailable('item_armlet')
        J.SetQueuePtToINT(bot, false, abilityR)
        if armlet ~= nil and armlet:IsFullyCastable() and not armlet:GetToggleState() then
            bot:ActionQueue_UseAbility(armlet)
        end
        bot:ActionQueue_UseAbility(abilityR)
        return
    end
    -- Once in Bolt reach, lock the enemy first; Rift initiates when only its longer reach connects.
    if desire > 0 and UseBolt(target, false) then return end
    desire, target = X.ConsiderW()
    if desire > 0 then
        J.SetQueuePtToINT(bot, false, abilityW)
        bot:ActionQueue_UseAbilityOnEntity(abilityW, target)
    end
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    return range
end

local function CanTarget(enemy, ability, immune)
    return J.IsValid(enemy) and J.IsInRange(bot, enemy, CastRange(ability))
        and (immune and J.CanCastOnMagicImmune(enemy) or not immune and J.CanCastOnNonMagicImmune(enemy))
        and J.CanCastOnTargetAdvanced(enemy)
        and not enemy:HasModifier('modifier_antimage_counterspell')
        and not enemy:HasModifier('modifier_antimage_counterspell_ally')
end

function X.ConsiderQ()
    if abilityQ == nil or not ItemCastPolicy.CanConsider(bot, abilityQ) then return 0 end
    local enemies = J.GetNearbyHeroes(bot, math.min(CastRange(abilityQ), 1600), true, BOT_MODE_NONE)
    local damage = abilityQ:GetSpecialValueInt('damage_min')
    for _, enemy in ipairs(enemies) do
        if CanTarget(enemy, abilityQ, false) then
            local delay = abilityQ:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / abilityQ:GetSpecialValueInt('chaos_bolt_speed')
            -- Only the minimum random roll can guarantee a kill.
            if enemy:IsChanneling() or J.WillMagicKillTarget(bot, enemy, damage, delay) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and CanTarget(target, abilityQ, false)
        and not J.IsDisabled(target) then return BOT_ACTION_DESIRE_HIGH, target end
    local best, power = nil, 0
    for _, enemy in ipairs(enemies) do
        if CanTarget(enemy, abilityQ, false) and not J.IsDisabled(enemy) then
            if J.IsRetreating(bot) and bot:WasRecentlyDamagedByHero(enemy, 3) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            if J.IsInTeamFight(bot, 1200) then
                local value = enemy:GetEstimatedDamageToTarget(false, bot, 3, DAMAGE_TYPE_ALL)
                if value > power then best, power = enemy, value end
            end
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH, best end
    return 0
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) or bot:IsRooted() then return 0 end
    local target = J.GetProperTarget(bot)
    local talent = bot:GetAbilityByName('special_bonus_unique_chaos_knight')
    local immune = abilityW:GetSpecialValueInt('pierces_immunity') == 1 or talent ~= nil and talent:IsTrained()
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and CanTarget(target, abilityW, immune)
        and not target:IsAttackImmune()
        and (not J.IsInRange(bot, target, bot:GetAttackRange())
            or not target:HasModifier('modifier_chaos_knight_reality_rift')) then
        -- Pull allied-controlled targets as well: the armor debuff benefits the illusion burst.
        return BOT_ACTION_DESIRE_HIGH, target
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target)
        and (J.IsRoshan(target) or J.IsTormentor(target)) and J.IsAttacking(bot)
        and CanTarget(target, abilityW, immune) then return BOT_ACTION_DESIRE_HIGH, target end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) == 0
        and J.IsAllowedToSpam(bot, abilityW:GetManaCost()) then
        for _, creep in ipairs(bot:GetNearbyLaneCreeps(math.min(CastRange(abilityW), 1600), true)) do
            if CanTarget(creep, abilityW, immune) and J.IsKeyWordUnit('ranged', creep)
                and not creep:HasModifier('modifier_fountain_glyph')
                and not J.IsInRange(bot, creep, 350) then return BOT_ACTION_DESIRE_HIGH, creep end
        end
    end
    return 0
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) or bot:DistanceFromFountain() < 500 then return 0 end
    if bot:IsRooted() or bot:HasModifier('modifier_item_dustofappearance')
        or J.IsUnitTargetProjectileIncoming(bot, 800) then return BOT_ACTION_DESIRE_HIGH end
    local target = J.GetProperTarget(bot)
    local enemies = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE)
    local reserve = 0
    for _, name in ipairs({'chaos_knight_chaos_bolt','chaos_knight_reality_rift'}) do
        local spell = bot:GetAbilityByName(name)
        if J.CanCastAbility(spell) then reserve = reserve + spell:GetManaCost() end
    end
    if bot:GetMana() - abilityR:GetManaCost() < reserve then return 0 end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanCastOnMagicImmune(target)
        and J.IsInRange(bot, target, 1000) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsInTeamFight(bot, 1200) and #enemies >= 2 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsRetreating(bot) and #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if #enemies == 0 and J.IsFarming(bot) and J.IsAttacking(bot) then
        local creeps = bot:GetNearbyNeutralCreeps(700)
        for _, creep in ipairs(creeps) do
            if J.IsValid(creep) and (creep:IsAncientCreep() or #creeps >= 3)
                and creep:GetHealth() > bot:GetAttackDamage() * 3 then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if J.IsPushing(bot) and #bot:GetNearbyLaneCreeps(1000, false) >= 2
        and (#bot:GetNearbyTowers(700, true) > 0 or #bot:GetNearbyBarracks(500, true) > 0) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target)
        and (J.IsRoshan(target) or J.IsTormentor(target)) and J.IsAttacking(bot)
        and J.IsInRange(bot, target, 700) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

return X
