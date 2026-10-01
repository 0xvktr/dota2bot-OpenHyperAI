local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local BerserkersCall
local BattleHunger
local CullingBlade

local botTarget

local nMP, hEnemyList, hAllyList

local function AbilityCastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function ValidEnemy(enemy)
    return J.IsValidHero(enemy) and enemy:CanBeSeen() and not enemy:IsInvulnerable()
        and not J.IsSuspiciousIllusion(enemy)
end

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local abilityName = ability:GetName()
    if abilityName ~= 'axe_culling_blade'
    and abilityName ~= 'axe_berserkers_call'
    and abilityName ~= 'axe_battle_hunger' then return nil end

    if J.CanNotUseAbility(bot) then return false end

    nMP = bot:GetMana() / bot:GetMaxMana()
    hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )

    botTarget = J.GetProperTarget(bot)

    if abilityName == 'axe_culling_blade'
    then
        CullingBlade = ability
        CullingBladeDesire, CullingBladeTarget = X.ConsiderCullingBlade()
        if CullingBladeDesire > 0
        then
            bot:Action_UseAbilityOnEntity(CullingBlade, CullingBladeTarget)
            return true
        end
    end

    if abilityName == 'axe_berserkers_call'
    then
        BerserkersCall = ability
        BerserkersCallDesire = X.ConsiderBerserkersCall()
        if BerserkersCallDesire > 0
        then
            bot:Action_UseAbility(BerserkersCall)
            return true
        end
    end

    if abilityName == 'axe_battle_hunger'
    then
        BattleHunger = ability
        BattleHungerDesire, BattleHungerTarget = X.ConsiderBattleHunger()
        if BattleHungerDesire > 0
        then
            bot:Action_UseAbilityOnEntity(BattleHunger, BattleHungerTarget)
            return true
        end
    end
    return false
end

function X.ConsiderBerserkersCall()
    if not BerserkersCall:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local radius = BerserkersCall:GetSpecialValueInt('radius')

    local enemies = J.GetAroundEnemyHeroList(radius)
    for _, enemy in pairs(enemies) do
        if ValidEnemy(enemy) and enemy:IsChanneling() then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsGoingOnSomeone(bot) and ValidEnemy(botTarget)
        and J.IsInRange(bot, botTarget, radius - 30) and not J.IsDisabled(botTarget) then
        -- Call pierces debuff immunity and has no unit-target reflection check.
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsInTeamFight(bot, 1200) or J.IsRetreating(bot) then
        for _, enemy in pairs(enemies) do
            if ValidEnemy(enemy) and not J.IsDisabled(enemy)
                and (not J.IsRetreating(bot) or bot:WasRecentlyDamagedByAnyHero(3)) then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and #hEnemyList == 0 and J.GetHP(bot) > 0.5
        and J.IsAllowedToSpam(bot, BerserkersCall:GetManaCost()) then
        local lanes = bot:GetNearbyLaneCreeps(radius, true)
        local neutrals = bot:GetNearbyNeutralCreeps(radius)
        if (#lanes >= 4 and not lanes[1]:HasModifier('modifier_fountain_glyph'))
            or (J.IsFarming(bot) and #neutrals >= 3) then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsDoingRoshan(bot) and J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, radius) and J.IsAttacking(bot) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBattleHunger()
    if not BattleHunger:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range = AbilityCastRange(BattleHunger)
    local function CanHunger(enemy)
        return ValidEnemy(enemy) and J.IsInRange(bot, enemy, range)
            and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_antimage_counterspell')
            and (BattleHunger:GetSpecialValueInt('should_stack') > 0
                or not enemy:HasModifier('modifier_axe_battle_hunger'))
    end
    if J.IsGoingOnSomeone(bot) and CanHunger(botTarget) then
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    local enemies = J.GetAroundEnemyHeroList(range)
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        for _, enemy in pairs(enemies) do
            if CanHunger(enemy) and not J.IsDisabled(enemy) then return BOT_ACTION_DESIRE_HIGH, enemy end
        end
    end
    if J.IsInTeamFight(bot, 1200) then
        local weakest
        for _, enemy in pairs(enemies) do
            if CanHunger(enemy) and (weakest == nil or enemy:GetHealth() < weakest:GetHealth()) then weakest = enemy end
        end
        if weakest ~= nil then return BOT_ACTION_DESIRE_HIGH, weakest end
    end
    if J.IsLaning(bot) and nMP > 0.5 then
        for _, enemy in pairs(enemies) do
            if CanHunger(enemy) then
                -- A nearby easy last hit would remove Hunger immediately.
                local easyKill = false
                for _, creep in pairs(bot:GetNearbyLaneCreeps(1600, false)) do
                    if J.IsValid(creep) and J.IsInRange(enemy, creep, enemy:GetAttackRange() + 100)
                        and creep:GetHealth() <= enemy:GetAttackDamage() * 1.2 then easyKill = true; break end
                end
                if not easyKill then return BOT_ACTION_DESIRE_HIGH, enemy end
            end
        end
    end
    if J.IsFarming(bot) and BattleHunger:GetLevel() >= 2
        and J.IsAllowedToSpam(bot, BattleHunger:GetManaCost()) then
        local creep = J.GetMostHpUnit(bot:GetNearbyNeutralCreeps(range))
        if J.IsValid(creep) and J.IsInRange(bot, creep, range)
            and J.CanCastOnNonMagicImmune(creep) and not J.IsRoshan(creep)
            and not creep:HasModifier('modifier_axe_battle_hunger')
            and not J.CanKillTarget(creep, bot:GetAttackDamage() * 2.88, DAMAGE_TYPE_PHYSICAL) then
            return BOT_ACTION_DESIRE_HIGH, creep
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(botTarget)
        and J.IsInRange(bot, botTarget, range) and J.IsAttacking(bot)
        and J.CanCastOnNonMagicImmune(botTarget) and J.CanCastOnTargetAdvanced(botTarget)
        and not botTarget:HasModifier('modifier_axe_battle_hunger') then
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCullingBlade()


	if not CullingBlade:IsFullyCastable() then return 0 end

	local nSkillLV = CullingBlade:GetLevel()
	local nCastRange = AbilityCastRange(CullingBlade)

	local nKillDamage = CullingBlade:GetSpecialValueInt('damage')

	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange )

	for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and npcEnemy:CanBeSeen()
			and npcEnemy:GetHealth() + npcEnemy:GetHealthRegen() * 0.8 < nKillDamage
			and not J.IsHaveAegis( npcEnemy )
			and not npcEnemy:IsInvulnerable()
			and not X.HasSpecialModifier( npcEnemy )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

function X.HasSpecialModifier( npcEnemy )

	if npcEnemy:HasModifier( 'modifier_winter_wyvern_winters_curse' )
		or npcEnemy:HasModifier( 'modifier_winter_wyvern_winters_curse_aura' )
		or npcEnemy:HasModifier( 'modifier_antimage_counterspell' )
		or npcEnemy:HasModifier( 'modifier_item_lotus_orb_active' )
		or npcEnemy:HasModifier( 'modifier_item_aeon_disk_buff' )
		or npcEnemy:HasModifier( 'modifier_item_sphere_target' )
		or npcEnemy:HasModifier( 'modifier_illusion' )
		or npcEnemy:HasModifier( 'modifier_arc_warden_tempest_double' )
	then
		return true
	else
		return false
	end

end


return X
