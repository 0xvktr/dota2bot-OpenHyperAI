local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local K=require(GetScriptDirectory()..'/FunLib/kez_abilities')
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    local consider=({kez_echo_slash=K.Echo,kez_grappling_claw=K.Claw,kez_kazurai_katana=K.Katana,kez_raptor_dance=K.Raptor,
        kez_falcon_rush=K.Falcon,kez_falcon_rush_ad=K.Falcon,kez_talon_toss=K.Toss,kez_talon_toss_ad=K.Toss,
        kez_shodo_sai=K.Parry,kez_shodo_sai_ad=K.Parry,kez_shodo_sai_parry_cancel=K.Cancel,
        kez_ravens_veil=K.Veil,kez_ravens_veil_ad=K.Veil})[name]
    if not consider then return nil end
    if J.CanNotUseAbility(bot) or J.IsRetreating(bot) and J.IsRealInvisible(bot) then return false end
    local desire,target,kind=consider(bot,ability)
    if desire>0 then
        if kind=='tree' then bot:Action_UseAbilityOnTree(ability,target)
        elseif name=='kez_shodo_sai' or name=='kez_shodo_sai_ad' then bot:Action_UseAbilityOnLocation(ability,target)
        elseif target then bot:Action_UseAbilityOnEntity(ability,target) else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
