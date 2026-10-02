local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local M=require(GetScriptDirectory()..'/FunLib/shredder_abilities')
local considers={shredder_return_chakram=M.Return,shredder_return_chakram_2=M.Return,shredder_reactive_armor=M.Armor,shredder_whirling_death=M.Whirl,shredder_chakram=M.Chakram,shredder_chakram_2=M.Chakram,shredder_twisted_chakram=M.Chakram,shredder_timber_chain=M.Chain,shredder_flamethrower=M.Flame}
function X.UseSpellsDuringTimberChain() return M.UseDuringChain(GetBot()) end
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName();local consider=considers[name]
    if not consider then return nil end
    local bot=GetBot()
    if X.UseSpellsDuringTimberChain() then return true end
    if J.CanNotUseAbility(bot) then return false end
    local desire,target=consider(bot,ability)
    if desire<=0 then return false end
    if name=='shredder_chakram' or name=='shredder_chakram_2' or name=='shredder_twisted_chakram' or name=='shredder_timber_chain' then bot:Action_UseAbilityOnLocation(ability,target)
        if name~='shredder_timber_chain' and name~='shredder_twisted_chakram' then M.RecordChakram(bot,ability,target) end
    else bot:Action_UseAbility(ability) end
    return true
end
return X
