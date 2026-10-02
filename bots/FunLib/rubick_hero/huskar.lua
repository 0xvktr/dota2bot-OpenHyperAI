local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local H = require(GetScriptDirectory()..'/FunLib/huskar_abilities')
function X.ConsiderStolenSpell(ability)
    local name = ability:GetName()
    local consider = ({huskar_inner_fire=H.Fire, huskar_burning_spear=H.Spears, huskar_life_break=H.Break})[name]
    if not consider then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local desire, target = consider(bot, ability)
    if desire > 0 then
        if target then bot:Action_UseAbilityOnEntity(ability, target) else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
