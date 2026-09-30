local U = dofile('bots/FunLib/invoker_utility.lua')
local state
local item = {
    GetName=function() return 'item_meteor_hammer' end, IsFullyCastable=function() return true end,
    GetCastRange=function() return 600 end, GetChannelTime=function() return 2 end,
    GetCastPoint=function() return 0 end, GetSpecialValueFloat=function() return 0.5 end,
    GetSpecialValueInt=function() return 400 end, GetManaCost=function() return 75 end,
}
local target = {HasModifier=function(_, m) return m == 'modifier_crystal_maiden_frostbite' end,
    GetLocation=function() return 'target' end}
local bot = {
    IsChanneling=function() return state.channel end, IsUsingAbility=function() return false end,
    IsMuted=function() return false end, IsInvisible=function() return false end,
    NumQueuedActions=function() return state.queued or 0 end,
    WasRecentlyDamagedByAnyHero=function() return state.hurt end,
    GetItemInSlot=function(_, slot) if slot == state.slot then return item end end,
    GetMana=function() return state.mana end, GetLocation=function() return 'bot' end,
    GetNearbyTowers=function() return {} end,
    FindAoELocation=function() return {count=state.creeps,targetloc='wave'} end,
    Action_UseAbilityOnLocation=function(_, used, loc) assert(used == item); state.cast=loc end,
}
local J = {
    GetHP=function() return 1 end, GetNearbyHeroes=function() return state.enemies end,
    GetProperTarget=function() return target end, IsGoingOnSomeone=function() return state.fight end,
    IsValidHero=function() return true end, CanCastOnNonMagicImmune=function() return true end,
    IsSuspiciousIllusion=function() return false end, IsInRange=function() return true end,
    GetModifierTime=function() return state.disable end, IsPushing=function() return false end,
    IsFarming=function() return not state.fight end, IsDefending=function() return false end,
}
local function reset() state={slot=0,mana=500,creeps=3,enemies={},disable=3} end
reset(); assert(U.TryMeteorHammer(bot,J) and state.cast=='wave', 'safe farming cast')
reset(); state.channel=true; assert(not U.TryMeteorHammer(bot,J), 'do not interrupt channel')
reset(); state.queued=1; assert(not U.TryMeteorHammer(bot,J), 'do not interrupt combo queue')
reset(); state.hurt=true; assert(not U.TryMeteorHammer(bot,J), 'do not channel while taking damage')
reset(); state.slot=6; assert(not U.TryMeteorHammer(bot,J), 'backpack item cannot cast')
reset(); state.mana=100; assert(not U.TryMeteorHammer(bot,J), 'preserve escape/combo mana')
reset(); state.enemies={target}; assert(not U.TryMeteorHammer(bot,J), 'do not farm beside an enemy')
reset(); state.fight=true; state.enemies={target}; assert(U.TryMeteorHammer(bot,J) and state.cast=='target', 'long disable setup')
reset(); state.fight=true; state.enemies={target}; state.disable=1; assert(not U.TryMeteorHammer(bot,J), 'short disable will expire before impact')
reset(); state.fight=true; state.enemies={target,target}; assert(not U.TryMeteorHammer(bot,J), 'other enemies can interrupt')
print('Invoker Meteor Hammer scenarios passed')
