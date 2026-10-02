local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local R=require(GetScriptDirectory()..'/FunLib/razor_abilities')
local considers={razor_plasma_field=R.Plasma,razor_static_link=R.Link,razor_eye_of_the_storm=R.Storm}
function X.ConsiderStolenSpell(ability)
    local consider=considers[ability:GetName()]
    if not consider then return nil end
    local bot=GetBot()
    if J.CanNotUseAbility(bot) then return false end
    local desire,target=consider(bot,ability)
    if desire<=0 then return false end
    if target then bot:Action_UseAbilityOnEntity(ability,target) else bot:Action_UseAbility(ability) end
    return true
end
return X
