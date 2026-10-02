local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local K=require(GetScriptDirectory()..'/FunLib/keeper_of_the_light_abilities')
local state={}
function X.UseIlluminateRelease() return K.Release(bot,bot:GetAbilityByName('keeper_of_the_light_illuminate_end'),state) end
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    if name=='keeper_of_the_light_illuminate_end' then return X.UseIlluminateRelease() end
    local consider=({keeper_of_the_light_illuminate=K.Illuminate,keeper_of_the_light_blinding_light=K.Blind,
        keeper_of_the_light_chakra_magic=K.Chakra,keeper_of_the_light_radiant_bind=K.Bind,
        keeper_of_the_light_spirit_form=K.Form,keeper_of_the_light_will_o_wisp=K.Wisp})[name]
    if not consider then return nil end
    if X.UseIlluminateRelease() then return true end
    if J.CanNotUseAbility(bot) then return false end
    local desire,target=consider(bot,ability)
    if desire>0 then
        if name=='keeper_of_the_light_spirit_form' then bot:Action_UseAbility(ability)
        elseif name=='keeper_of_the_light_chakra_magic' or name=='keeper_of_the_light_radiant_bind' then bot:Action_UseAbilityOnEntity(ability,target)
        else
            bot:Action_UseAbilityOnLocation(ability,target)
            if name=='keeper_of_the_light_illuminate' then K.Record(bot,ability,target,state);state.target=J.GetProperTarget(bot) end
        end
        return true
    end
    return false
end
return X
