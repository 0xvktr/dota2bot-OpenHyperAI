local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local M=require(GetScriptDirectory()..'/FunLib/shadow_shaman_abilities')
local considers={shadow_shaman_voodoo=M.Hex,shadow_shaman_mass_serpent_ward=M.Wards,shadow_shaman_urnaconda=M.Urnaconda,shadow_shaman_ether_shock=M.Shock,shadow_shaman_shackles=M.Shackles}
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName();local consider=considers[name]
    if not consider then return nil end
    local bot=GetBot();if J.CanNotUseAbility(bot) then return false end
    local desire,target=consider(bot,ability)
    if desire<=0 then return false end
    if name=='shadow_shaman_mass_serpent_ward' or name=='shadow_shaman_urnaconda' then bot:Action_UseAbilityOnLocation(ability,target) else bot:Action_UseAbilityOnEntity(ability,target) end
    return true
end
return X
