local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local M=require(GetScriptDirectory()..'/FunLib/silencer_abilities')
local considers={silencer_global_silence=M.Global,silencer_curse_of_the_silent=M.Curse,silencer_last_word=M.Word,silencer_glaives_of_wisdom=M.Glaives}
function X.ConsiderStolenSpell(a)
    local name=a:GetName();local consider=considers[name];if not consider then return nil end
    local bot=GetBot();if J.CanNotUseAbility(bot) then return false end
    local desire,target,point=consider(bot,a);if desire<=0 then return false end
    if name=='silencer_global_silence' then bot:Action_UseAbility(a)
    elseif name=='silencer_curse_of_the_silent' or point then bot:Action_UseAbilityOnLocation(a,target)
    else bot:Action_UseAbilityOnEntity(a,target) end
    return true
end
return X
