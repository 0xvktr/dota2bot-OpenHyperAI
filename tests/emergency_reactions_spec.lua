function GetScriptDirectory() return 'bots' end
BOT_MODE_NONE=0
local friends,enemies,actions={},{},{}
local J={}
package.loaded['bots/FunLib/jmz_func']=J
local U={};U.__index=U
local function unit(x,role,team)
    return setmetatable({x=x,role=role or 4,team=team or 2,mods={},slots={},mana=500,alive=true},U)
end
function U:IsNull() return false end
function U:IsAlive() return self.alive end
function U:CanBeSeen() return not self.unseen end
function U:IsIllusion() return self.illusion==true end
function U:IsInvulnerable() return self.invulnerable==true end
function U:IsAttackImmune() return self.attackImmune==true end
function U:IsDisarmed() return self.disarmed==true end
function U:IsHexed() return self.hexed==true end
function U:IsChanneling() return self.channel==true end
function U:GetTeam() return self.team end
function U:GetLocation() return {x=self.x} end
function U:GetAttackRange() return 500 end
function U:GetCurrentMovementSpeed() return 300 end
function U:HasModifier(n) return self.mods[n]~=nil end
function U:GetModifierByName(n) return self.mods[n] and 0 or -1 end
function U:GetModifierSourceAbility() return self.source end
function U:GetAbilityInSlot(n) return self.slots[n] end
function U:GetAbilityByName() return nil end
function U:GetItemInSlot() return nil end
function U:HasScepter() return self.scepter==true end
function U:Action_AttackUnit(t,once) actions[#actions+1]={shape='attack',target=t,once=once} end
function U:Action_UseAbility(a) actions[#actions+1]={shape='none',ability=a} end
function U:Action_UseAbilityOnEntity(a,t) actions[#actions+1]={shape='unit',ability=a,target=t} end
function U:Action_UseAbilityOnLocation(a,t) actions[#actions+1]={shape='point',ability=a,target=t} end
function GetUnitToUnitDistance(a,b) return math.abs(a.x-b.x) end
J.IsCore=function(u) return u.role<=3 end
J.GetPosition=function(u) return u.role end
J.IsValidHero=function(u) return u and u.alive and not u.unseen and not u.invulnerable end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.IsInEtherealForm=function(u) return u.ethereal==true end
J.CanNotUseAction=function(u) return not u.alive or u.busy or u.channel end
J.CanNotUseAbility=function(u) return J.CanNotUseAction(u) or u.silenced or u.hexed end
J.CanCastOnNonMagicImmune=function(u) return not u.immune end
J.CanCastOnMagicImmune=function() return true end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected end
J.GetModifierTime=function(u,n) return u.mods[n] or 0 end
J.GetNearbyHeroes=function(b,r,enemy)
    local result={};for _,u in ipairs(enemy and enemies or friends) do
        if GetUnitToUnitDistance(b,u)<=r then result[#result+1]=u end
    end;return result
end
local bot=unit(0)
local A={};A.__index=A
local function ability(n,range,values)
    return setmetatable({name=n,range=range or 700,values=values or {},ready=true},A)
end
function A:GetName() return self.name end
function A:IsNull() return false end
function A:GetCaster() return self.caster end
function A:GetCastRange() return self.range end
function A:GetCastPoint() return self.point or 0.2 end
function A:GetManaCost() return self.cost or 100 end
function A:IsUltimate() return self.ultimate==true end
function A:GetSpecialValueInt(k) return self.values[k] or 0 end
A.GetSpecialValueFloat=A.GetSpecialValueInt
J.CanCastAbility=function(a) return a and a.ready and not a.hidden and not a.passive end
local R=dofile('bots/FunLib/emergency_reactions.lua')
local count=0
local function reset() friends,enemies,actions={},{},{};bot=unit(0) end
local function sleeper(x,role,enemySource)
    local u=unit(x,role);u.mods.modifier_bane_nightmare=5
    u.source=ability('bane_nightmare');u.source.caster=unit(1000,4,enemySource==false and 2 or 3)
    friends[#friends+1]=u;return u
end
reset();local core=sleeper(550,1)
assert(R.WakeCore(bot) and actions[1].target==core and actions[1].once,'support force-attacks allied core once')
local support=sleeper(100,5);core.mods={};actions={}
assert(not R.WakeCore(bot),'transferred sleep on support cannot bounce');count=count+1
reset();core=sleeper(200,1,false);assert(not R.WakeCore(bot),'preserve friendly Bane save')
core.source=nil;assert(not R.WakeCore(bot),'unknown source cannot justify sacrificing support');count=count+1
reset();core=sleeper(200,3);local carry=sleeper(500,1)
assert(R.WakeCore(bot) and actions[1].target==carry,'prefer carry over nearer offlaner');count=count+1
for _,state in ipairs({'busy','channel','hexed','disarmed'}) do
    reset();sleeper(200,1);bot[state]=true;assert(not R.WakeCore(bot),'rescue preserves state '..state);count=count+1
end
reset();sleeper(200,1);bot.attackImmune=true;assert(R.WakeCore(bot),'attack immunity does not prevent support attacking');count=count+1
reset();sleeper(200,1);bot.role=1;assert(not R.WakeCore(bot),'core does not sacrifice itself');count=count+1
for _,state in ipairs({'invulnerable','attackImmune','ethereal','illusion'}) do
    reset();core=sleeper(200,1);core[state]=true;assert(not R.WakeCore(bot),'invalid sleeping target '..state);count=count+1
end
reset();core=sleeper(751,1);assert(not R.WakeCore(bot),'do not chase remote sleep');core.x=700;core.mods.modifier_bane_nightmare=0.5
assert(not R.WakeCore(bot),'sleep will expire before reaching attack range');count=count+1
local function tp(x,remaining)
    local u=unit(x,1,3);u.channel=true;u.mods.modifier_teleporting=remaining or 3;enemies[#enemies+1]=u;return u
end
reset();local enemy=tp(600);local hex=ability('lion_voodoo');bot.slots[0]=hex
assert(R.InterruptTeleport(bot) and actions[1].shape=='unit' and actions[1].target==enemy,'unit disable interrupts TP');count=count+1
for _,state in ipairs({'unseen','illusion','invulnerable','blocked','reflected','immune'}) do
    reset();enemy=tp(600);enemy[state]=true;bot.slots[0]=hex;assert(not R.InterruptTeleport(bot),'illegal TP target '..state);count=count+1
end
reset();enemy=tp(600);bot.slots[0]=hex;enemy.channel=false;assert(not R.InterruptTeleport(bot),'modifier alone does not prove TP channel')
enemy.channel=true;enemy.mods={};assert(not R.InterruptTeleport(bot),'other channels stay with hero logic');count=count+1
reset();tp(701);bot.slots[0]=hex;assert(not R.InterruptTeleport(bot),'do not walk to cast after TP ends')
reset();tp(600,0.1);bot.slots[0]=hex;assert(not R.InterruptTeleport(bot),'reject TP ending before cast point');count=count+1
reset();enemy=tp(600,0.7);bot.slots[0]=ability('sven_storm_bolt',700,{bolt_speed=600})
assert(not R.InterruptTeleport(bot),'projectile cannot arrive before TP ends');enemy.mods.modifier_teleporting=2
assert(R.InterruptTeleport(bot),'projectile stun can arrive in time');count=count+1
reset();enemy=tp(600,0.5);bot.slots[0]=ability('lina_light_strike_array',700,{light_strike_array_delay_time=0.5})
assert(not R.InterruptTeleport(bot),'delayed AoE cannot arrive in time');enemy.mods.modifier_teleporting=2
assert(R.InterruptTeleport(bot) and actions[1].shape=='point' and actions[1].target.x==enemy.x,'AoE targets stationary TP location');count=count+1
reset();enemy=tp(200);bot.slots[0]=ability('centaur_hoof_stomp',0,{radius=315})
assert(R.InterruptTeleport(bot) and actions[1].shape=='none','nearby stomp uses no-target cast');enemy.x=316;actions={}
assert(not R.InterruptTeleport(bot),'stomp cannot hit outside radius');count=count+1
reset();enemy=tp(600);enemy.immune=true;local roar=ability('beastmaster_primal_roar');roar.ultimate=true;bot.slots[0]=roar;bot.slots[1]=hex
assert(R.InterruptTeleport(bot) and actions[1].ability==roar,'piercing disable cancels debuff-immune TP');enemy.immune=false;actions={}
assert(R.InterruptTeleport(bot) and actions[1].ability==hex,'prefer basic disable to costly ultimate');count=count+1
reset();tp(600);bot.slots[0]=ability('keeper_of_the_light_will_o_wisp')
assert(not R.InterruptTeleport(bot),'noninterrupting pull is never treated as stun');count=count+1
for _,state in ipairs({'busy','channel','silenced','hexed'}) do
    reset();tp(600);bot.slots[0]=hex;bot[state]=true;assert(not R.InterruptTeleport(bot),'preserve own state '..state);count=count+1
end
reset();tp(600);hex.ready=false;bot.slots[0]=hex;assert(not R.InterruptTeleport(bot),'cooldown or insufficient mana cannot interrupt');hex.ready=true;count=count+1
reset();enemy=tp(600);bot.slots[0]=ability('lich_sinister_gaze')
assert(R.InterruptTeleport(bot) and actions[1].shape=='unit','ordinary Gaze targets a unit');actions={};bot.scepter=true;enemy.blocked=true
assert(R.InterruptTeleport(bot) and actions[1].shape=='point','Scepter Gaze uses point shape and bypasses unit spell block');count=count+1
reset();enemy=tp(600);enemy.blocked=true;bot.slots[0]=ability('earthshaker_fissure')
assert(R.InterruptTeleport(bot) and actions[1].shape=='point','point disable is not blocked by Linkens');count=count+1
reset();enemy=tp(800);bot.slots[0]=hex
function bot:GetItemInSlot(slot) if slot==0 then return ability('item_aether_lens',0,{cast_range_bonus=200}) end end
assert(R.InterruptTeleport(bot),'actual lens bonus extends interrupt range');count=count+1
print(count..' emergency reaction scenarios passed')
