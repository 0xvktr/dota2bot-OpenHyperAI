-- Regression: Culling Blade's kill threshold reads the level-25 damage talent (tier 4, second
-- option = T8), not the level-20 Strength talent (T5) it used to read after the talent rework.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J

local trainedDamage = false
bot.GetAbilityByName = function(_, name)
    if name == 'A6' then
        return { IsFullyCastable = function() return true end, GetLevel = function() return 3 end,
            GetCastRange = function() return 300 end, GetCastPoint = function() return 0.3 end,
            GetManaCost = function() return 100 end }
    end
    return { IsTrained = function() return name == 'T5' or (name == 'T8' and trainedDamage) end,
        GetSpecialValueInt = function() return name == 'T8' and 150 or 15 end }
end
local hp = 460
local enemy = { CanBeSeen = function() return true end, GetHealth = function() return hp end,
    GetHealthRegen = function() return 0 end, IsInvulnerable = function() return false end,
    IsMagicImmune = function() return false end }
J.GetAroundEnemyHeroList = function() return { enemy } end
J.IsValidHero = function() return true end
J.IsHaveAegis = function() return false end
J.Chat = { GetNormName = function() return 'enemy' end }
BOT_ACTION_DESIRE_HIGH = 1; BOT_ACTION_DESIRE_NONE = 0; DAMAGE_TYPE_PURE = 4

local combat = H.load('npc_dota_hero_axe', 'pos_3')
combat.HasSpecialModifier = function() return false end
combat.IsKillBotAntiMage = function() return false end
assert(combat.ConsiderR() == 0, 'the Strength talent must not raise the execution threshold')
trainedDamage = true; hp = 500
local desire, target = combat.ConsiderR()
assert(desire == 1 and target == enemy, 'the trained damage talent raises the threshold')
print('Axe Culling Blade talent scenario passed')
