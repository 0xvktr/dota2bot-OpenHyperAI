local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local M=require(GetScriptDirectory()..'/FunLib/skywrath_mage_abilities')
local decisions={skywrath_mage_ancient_seal=M.Seal,skywrath_mage_mystic_flare=M.Flare,skywrath_mage_concussive_shot=M.Concussive,skywrath_mage_arcane_bolt=M.Bolt}
function X.ConsiderStolenSpell(a)
    local name=a:GetName();local consider=decisions[name];if not consider then return nil end
    local bot=GetBot();if J.CanNotUseAbility(bot) then return false end
    local desire,target=consider(bot,a);if desire<=0 then return false end
    if name=='skywrath_mage_concussive_shot' then bot:Action_UseAbility(a)
    elseif name=='skywrath_mage_mystic_flare' then bot:Action_UseAbilityOnLocation(a,target)
    else bot:Action_UseAbilityOnEntity(a,target) end
    return true
end
return X
