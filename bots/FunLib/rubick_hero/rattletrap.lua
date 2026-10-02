local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local C=require(GetScriptDirectory()..'/FunLib/clockwerk_abilities')
local considers={rattletrap_battery_assault=C.Battery,rattletrap_power_cogs=C.Cogs,rattletrap_rocket_flare=C.Flare,
    rattletrap_hookshot=C.Hook,rattletrap_jetpack=C.Jetpack,rattletrap_jetpack_toggle=C.JetpackToggle,rattletrap_overclocking=C.Overclock}
function X.ConsiderStolenSpell(ability)
    local consider=considers[ability:GetName()]
    if not consider then return nil end
    local bot=GetBot()
    if J.CanNotUseAbility(bot) then return false end
    local desire,point=consider(bot,ability)
    if desire<=0 then return false end
    if point then bot:Action_UseAbilityOnLocation(ability,point) else bot:Action_UseAbility(ability) end
    return true
end
return X
