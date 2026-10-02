local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local function CastRange(ability)
    local bonus = 0
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:GetName() == 'item_aether_lens' then
            bonus = item:GetSpecialValueInt('cast_range_bonus'); break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        bonus = bonus + supremacy:GetSpecialValueInt('cast_range')
    end
    return ability:GetCastRange() + bonus
end

local function Enemy(unit, physical)
    return J.IsValidHero(unit) and J.CanCastOnMagicImmune(unit)
        and (physical and J.CanBeAttacked(unit) and not J.IsInEtherealForm(unit)
            or not physical and J.CanCastOnNonMagicImmune(unit))
end

function X.UseChainsDuringSleight()
    local chains = bot:GetAbilityByName('ember_spirit_searing_chains')
    if not bot:HasModifier('modifier_ember_spirit_sleight_of_fist_caster')
        or not bot:IsAlive() or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed()
        or bot:IsNightmared() or bot:IsChanneling() or bot:IsCastingAbility() or bot:NumQueuedActions() > 0
        or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active')
        or not J.CanCastAbility(chains) then return false end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, chains:GetSpecialValueInt('radius'), true, BOT_MODE_NONE)) do
        if Enemy(enemy, false) and not enemy:IsInvisible() and not J.IsDisabled(enemy) then
            bot:Action_UseAbility(chains); return true
        end
    end
    return false
end

function X.ConsiderStolenSpell(ability)
    local spellName = ability:GetName()
    if not ({ember_spirit_sleight_of_fist=true, ember_spirit_searing_chains=true, ember_spirit_flame_guard=true})[spellName] then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local name = ability:GetName()
    local target = J.GetProperTarget(bot)
    if name == 'ember_spirit_sleight_of_fist' then
        if bot:IsRooted() or bot:IsDisarmed() then return false end
        local range = CastRange(ability)
        local damage = bot:GetAttackDamage() + ability:GetSpecialValueInt('bonus_hero_damage')
        for _, enemy in pairs(J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)) do
            if Enemy(enemy, true) and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_PHYSICAL) then
                bot:Action_UseAbilityOnLocation(ability, enemy:GetLocation()); return true
            end
        end
        if Enemy(target, true) and J.IsInRange(bot, target, range)
            and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot)) then
            bot:Action_UseAbilityOnLocation(ability, target:GetLocation()); return true
        end
    elseif name == 'ember_spirit_searing_chains' then
        local radius = ability:GetSpecialValueInt('radius')
        local damage = ability:GetSpecialValueInt('damage_per_second') * ability:GetSpecialValueFloat('duration')
        local targets = 0
        for _, list in ipairs({J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE), bot:GetNearbyCreeps(radius, true)}) do
            for _, unit in pairs(list) do
                if J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit) and not unit:IsInvisible()
                    and J.IsInRange(bot, unit, radius) then targets = targets + 1 end
            end
        end
        for _, enemy in pairs(J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)) do
            if Enemy(enemy, false) and not enemy:IsInvisible() and not J.IsDisabled(enemy)
                and (enemy:IsChanneling() or targets <= ability:GetSpecialValueInt('unit_count') and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL)
                    or J.IsGoingOnSomeone(bot) or J.IsRetreating(bot)) then
                bot:Action_UseAbility(ability); return true
            end
        end
    elseif name == 'ember_spirit_flame_guard' then
        if bot:HasModifier('modifier_ember_spirit_flame_guard') then return false end
        local radius = ability:GetSpecialValueInt('radius')
        if Enemy(target, false) and J.IsInRange(bot, target, radius) and J.IsGoingOnSomeone(bot)
            or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(bot) < 0.7
            and #J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE) > 0 then
            bot:Action_UseAbility(ability); return true
        end
    end
    return false
end
return X
