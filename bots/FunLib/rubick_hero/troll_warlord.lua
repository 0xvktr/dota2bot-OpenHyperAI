local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local M=require(GetScriptDirectory()..'/FunLib/troll_warlord_abilities')
local decisions={troll_warlord_switch_stance=M.Stance,troll_warlord_whirling_axes_ranged=M.Ranged,troll_warlord_whirling_axes_melee=M.Melee,troll_warlord_battle_trance=M.Trance}
function X.UseBattleStance()
    local bot=GetBot();if not bot:IsSilenced() and not bot:IsInvisible() then return false end
    return M.UseStance(bot,false)
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName();local consider=decisions[name];if not consider then return nil end
    local bot=GetBot()
    if name=='troll_warlord_switch_stance' then return M.UseStance(bot,false) end
    if J.CanNotUseAbility(bot) then return false end
    local desire,target=consider(bot,a);if desire<=0 then return false end
    if name=='troll_warlord_whirling_axes_ranged' then bot:Action_UseAbilityOnLocation(a,target)
    elseif name=='troll_warlord_battle_trance' then M.CastTrance(bot,a)
    else bot:Action_UseAbility(a) end
    return true
end
return X
