local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local G = require(GetScriptDirectory()..'/FunLib/grimstroke_abilities')
function X.ConsiderStolenSpell(ability)
    local spellName = ability:GetName()
    if not ({grimstroke_dark_artistry=true, grimstroke_ink_creature=true, grimstroke_spirit_walk=true, grimstroke_soul_chain=true, grimstroke_dark_portrait=true})[spellName] then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local name = ability:GetName()
    local consider = ({grimstroke_dark_artistry = G.Stroke, grimstroke_ink_creature = G.Phantom,
        grimstroke_spirit_walk = G.Swell, grimstroke_soul_chain = G.Bind, grimstroke_dark_portrait = G.Portrait})[name]
    if not consider then return false end
    local desire, target = consider(bot, ability)
    if desire > 0 then
        if name == 'grimstroke_dark_artistry' then bot:Action_UseAbilityOnLocation(ability, target)
        else bot:Action_UseAbilityOnEntity(ability, target) end
        return true
    end
    return false
end
return X
