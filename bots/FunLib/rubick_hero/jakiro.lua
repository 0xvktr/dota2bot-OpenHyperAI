local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local K = require(GetScriptDirectory()..'/FunLib/jakiro_abilities')
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    local kind=({jakiro_dual_breath='breath',jakiro_ice_path='ice',jakiro_macropyre='macro',jakiro_liquid_fire='fire',jakiro_liquid_ice='frost'})[name]
    if not kind then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local desire,target
    if kind=='fire' or kind=='frost' then desire,target=K.Liquid(bot,ability,kind=='frost')
    else desire,target=K.Line(bot,ability,kind) end
    if desire>0 then
        if kind=='fire' or kind=='frost' then bot:Action_UseAbilityOnEntity(ability,target)
        else bot:Action_UseAbilityOnLocation(ability,target) end
        return true
    end
    return false
end
return X
