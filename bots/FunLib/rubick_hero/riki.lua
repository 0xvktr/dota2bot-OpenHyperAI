local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local R=require(GetScriptDirectory()..'/FunLib/riki_abilities')
local considers={riki_smoke_screen=R.Smoke,riki_blink_strike=R.Blink,riki_tricks_of_the_trade=R.Tricks,riki_poison_dart=R.Dart}
function X.UseSmokeDuringTricks() return R.SmokeDuringTricks(GetBot()) end
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName();local consider=considers[name]
    if not consider then return nil end
    local bot=GetBot()
    if name=='riki_smoke_screen' and X.UseSmokeDuringTricks() then return true end
    if J.CanNotUseAbility(bot) then return false end
    local desire,target,shape=consider(bot,ability)
    if desire<=0 then return false end
    if shape=='unit' or name=='riki_blink_strike' then bot:Action_UseAbilityOnEntity(ability,target)
    else bot:Action_UseAbilityOnLocation(ability,target) end
    return true
end
return X
