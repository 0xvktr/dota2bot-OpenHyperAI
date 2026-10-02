local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local U=require(GetScriptDirectory()..'/FunLib/juggernaut_abilities')
function X.UseHealingWardDuringSlash() return U.WardDuringSlash(bot,bot:GetAbilityByName('juggernaut_healing_ward')) end
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    local consider=({juggernaut_blade_fury=U.Fury,juggernaut_healing_ward=U.Ward,juggernaut_omni_slash=U.Slash,juggernaut_swift_slash=U.Slash})[name]
    if not consider then return nil end
    if name=='juggernaut_healing_ward' and X.UseHealingWardDuringSlash() then return true end
    if J.CanNotUseAbility(bot) then return false end
    local desire,target=consider(bot,ability)
    if desire>0 then
        if name=='juggernaut_healing_ward' then bot:Action_UseAbilityOnLocation(ability,target)
        elseif target then bot:Action_UseAbilityOnEntity(ability,target) else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
