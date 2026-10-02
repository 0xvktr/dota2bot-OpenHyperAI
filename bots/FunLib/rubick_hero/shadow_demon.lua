local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local M=require(GetScriptDirectory()..'/FunLib/shadow_demon_abilities')
local considers={shadow_demon_disruption=M.Disruption,shadow_demon_demonic_cleanse=M.Cleanse,shadow_demon_shadow_poison_release=M.Release,shadow_demon_demonic_purge=M.Purge,shadow_demon_disseminate=M.Disseminate,shadow_demon_shadow_poison=M.Poison}
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName();local consider=considers[name]
    if not consider then return nil end
    local bot=GetBot();if J.CanNotUseAbility(bot) then return false end
    local desire,target=consider(bot,ability)
    if desire<=0 then return false end
    if name=='shadow_demon_shadow_poison_release' then bot:Action_UseAbility(ability)
    elseif name=='shadow_demon_shadow_poison' then bot:Action_UseAbilityOnLocation(ability,target);M.RecordPoison(bot,ability,target)
    else bot:Action_UseAbilityOnEntity(ability,target) end
    return true
end
return X
