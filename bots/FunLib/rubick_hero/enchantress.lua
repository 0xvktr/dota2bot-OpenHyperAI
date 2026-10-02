local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local E = require(GetScriptDirectory()..'/FunLib/enchantress_abilities')
function X.ConsiderStolenSpell(ability)
    local spellName = ability:GetName()
    if not ({enchantress_natures_attendants=true, enchantress_bunny_hop=true, enchantress_impetus=true, enchantress_little_friends=true, enchantress_enchant=true})[spellName] then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local name = ability:GetName()
    local desire, target = 0, nil
    if name == 'enchantress_natures_attendants' then desire = E.Heal(bot, ability)
    elseif name == 'enchantress_bunny_hop' then desire = E.Sproink(bot, ability)
    elseif name == 'enchantress_impetus' then E.Impetus(bot, ability); return false
    elseif name == 'enchantress_little_friends' then desire, target = E.LittleFriends(bot, ability)
    elseif name == 'enchantress_enchant' then desire, target = E.Enchant(bot, ability)
    end
    if desire > 0 then
        if target ~= nil then bot:Action_UseAbilityOnEntity(ability, target)
        else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
