local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local B = {}

local function target(bot)
    local enemy = bot:GetAttackTarget()
    if J.IsDoingRoshan(bot) and J.IsValid(enemy) and J.IsRoshan(enemy)
        and GetUnitToUnitDistance(bot, enemy) <= bot:GetAttackRange() + 150
        and not bot:WasRecentlyDamagedByAnyHero(3)
        and #J.GetEnemiesNearLoc(bot:GetLocation(), 1400) == 0 then return enemy end
end

-- A deliberately small supplement to the existing hero-specific Roshan logic.
-- Only cast on the boss after the group has committed and is actually attacking.
function B.AbilityThink(bot)
    if J.CanNotUseAction(bot) or bot:IsSilenced() then return false end
    local enemy = target(bot)
    if not enemy then return false end
    local ability = bot:GetAbilityByName('slardar_amplify_damage')
    if ability and ability:IsFullyCastable()
        and not enemy:HasModifier('modifier_slardar_amplify_damage')
        and GetUnitToUnitDistance(bot, enemy) <= ability:GetCastRange() then
        bot:Action_UseAbilityOnEntity(ability, enemy)
        return true
    end
    ability = bot:GetAbilityByName('ogre_magi_bloodlust')
    if ability and ability:IsFullyCastable() then
        local best
        for _, h in ipairs(J.GetAlliesNearLoc(bot:GetLocation(), ability:GetCastRange())) do
            if J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion()
                and h:GetAttackTarget() == enemy and not h:HasModifier('modifier_ogre_magi_bloodlust')
                and (not best or h:GetAttackDamage() > best:GetAttackDamage()) then best = h end
        end
        if best then bot:Action_UseAbilityOnEntity(ability, best); return true end
    end
    return false
end

function B.ItemDesire(bot, item)
    if not target(bot) then return BOT_ACTION_DESIRE_NONE end
    local name = item:GetName()
    if name == 'item_satanic' and J.GetHP(bot) < 0.6 then
        return BOT_ACTION_DESIRE_HIGH, bot, 'none', 'Roshan lifesteal'
    end
    if (name == 'item_ancient_janggo' and item:GetCurrentCharges() > 0)
        or name == 'item_boots_of_bearing' then
        local attackers = 0
        for _, h in ipairs(J.GetAlliesNearLoc(bot:GetLocation(), 900)) do
            if J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion()
                and h:GetAttackTarget() == bot:GetAttackTarget() then attackers = attackers + 1 end
        end
        if attackers >= 3 and not bot:HasModifier('modifier_item_ancient_janggo_active') then
            return BOT_ACTION_DESIRE_HIGH, bot, 'none', 'Roshan team attack speed'
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

return B
