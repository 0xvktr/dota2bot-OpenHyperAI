local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local M=require(GetScriptDirectory()..'/FunLib/skeleton_king_abilities')
local decisions={skeleton_king_hellfire_blast=M.Blast,skeleton_king_bone_guard=M.Guard,skeleton_king_reincarnation=M.Reincarnate}
function X.ConsiderStolenSpell(a)
    local name=a:GetName();local consider=decisions[name];if not consider then return nil end
    local bot=GetBot();if J.CanNotUseAbility(bot) then return false end
    local desire,target=consider(bot,a);if desire<=0 then return false end
    if name=='skeleton_king_bone_guard' then bot:Action_UseAbility(a) else bot:Action_UseAbilityOnEntity(a,target) end
    return true
end
return X
