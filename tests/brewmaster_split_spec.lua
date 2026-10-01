-- Current Earth/Storm/Fire controls, including utility priorities and rebirth survival.
local H=dofile('tests/hero_harness.lua')
local J,bot=H.J,H.bot
BOT_MODE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; DAMAGE_TYPE_ALL=3
local V={}; V.__index=V
function Vector(x,y,z) return setmetatable({x=x,y=y or 0,z=z or 0},V) end
function V.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function V.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function V.__mul(a,n) return Vector(a.x*n,a.y*n,a.z*n) end
function V:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function V:Normalized() return self*(1/self:Length2D()) end
local enemies,allies,creeps,actions,focus={}, {}, {}, {}, nil
local retreat=false
local now=100
function DotaTime() return now end
local function unit(name,x,hp)
    local u={name=name,loc=Vector(x,0),hp=hp or 1000,maxhp=1000,mods={},alive=true,team=3,threat=100,abilities={}}
    function u:GetUnitName() return self.name end
    function u:GetLocation() return self.loc end
    function u:GetTeam() return self.team end
    function u:GetHealth() return self.hp end
    function u:GetMaxHealth() return self.maxhp end
    function u:HasModifier(name) return self.mods[name]==true end
    function u:IsAlive() return self.alive end
    function u:IsNull() return self.null==true end
    function u:CanBeSeen() return self.unseen~=true end
    function u:IsInvulnerable() return self.invulnerable==true end
    function u:IsMagicImmune() return self.immune==true end
    function u:IsAttackImmune() return self.attackimmune==true end
    function u:IsIllusion() return self.illusion==true end
    function u:IsInvisible() return self.invisible==true end
    function u:IsChanneling() return self.channel==true end
    function u:GetEstimatedDamageToTarget() return self.threat end
    function u:GetAbilityByName(name) return self.abilities[name] end
    function u:GetNearbyHeroes(range,enemy)
        local result={}; for _,other in ipairs(enemy and enemies or allies) do
            if GetUnitToUnitDistance(self,other)<=range then result[#result+1]=other end
        end
        return result
    end
    function u:GetNearbyLaneCreeps() return creeps end
    function u:GetNearbyBarracks() return {} end
    function u:GetNearbyTowers() return {} end
    function u:Action_UseAbility(a) actions[#actions+1]={name=a.name,kind='ability'} end
    function u:Action_UseAbilityOnEntity(a,t) actions[#actions+1]={name=a.name,target=t,kind='entity'} end
    function u:Action_UseAbilityOnLocation(a,v) actions[#actions+1]={name=a.name,loc=v,kind='point'} end
    function u:Action_AttackUnit(t) actions[#actions+1]={target=t,kind='attack'} end
    function u:Action_MoveToLocation(v) actions[#actions+1]={loc=v,kind='move'} end
    return u
end
function GetUnitToUnitDistance(a,b) return (a:GetLocation()-b:GetLocation()):Length2D() end
function GetUnitToLocationDistance(a,v) return (a:GetLocation()-v):Length2D() end
local function spell(name,range,radius)
    local a={name=name,range=range,radius=radius,castable=true}
    function a:IsFullyCastable() return self.castable end
    function a:IsHidden() return false end
    function a:GetCastRange() return self.range end
    function a:GetSpecialValueInt(key) if key=='radius' then return self.radius end; error('unexpected special '..key) end
    function a:GetSpecialValueFloat(key) if key=='fade_time' then return 0.6 end; error('unexpected float '..key) end
    return a
end
local boulder=spell('brewmaster_earth_hurl_boulder',800)
local cyclone=spell('brewmaster_storm_cyclone',600)
local dispel=spell('brewmaster_storm_dispel_magic',500,600)
local wind=spell('brewmaster_storm_wind_walk',0)
local earth=unit('npc_dota_brewmaster_earth_1',0)
local storm=unit('npc_dota_brewmaster_storm_1',0)
local fire=unit('npc_dota_brewmaster_fire_1',0)
for _,s in ipairs({earth,storm,fire}) do s.team=2 end
bot.GetLocation=function() return Vector(-5000,0) end
local U={}
U.IsValidUnit=function(u) return u~=nil and not u:IsNull() and u:IsAlive() and u:CanBeSeen() end
U.IsValidTarget=function(u) return U.IsValidUnit(u) and not u:IsInvulnerable() and not u:IsAttackImmune() end
U.IsNotAllowedToAttack=function() return false end
U.IsBusy=function(u) return u.busy==true end
U.CanNotUseAbility=function(u) return u.silenced==true end
U.CantMove=function(u) return u.rooted==true end
U.CantAttack=function(u) return u.disarmed==true end
package.loaded['bots/FunLib/minion_lib/utils']=U
J.GetProperTarget=function() return focus end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.IsDisabled=function(u) return u.disabled==true end
J.IsTaunted=function(u) return u.taunted==true end
J.IsRetreating=function() return retreat end
J.GetTeamFountain=function() return Vector(-10000,0) end
J.GetClosestTeamLane=function() return Vector(2000,0) end
J.GetEnemiesNearLoc=function() return {} end
local split=H.realDofile('bots/FunLib/minion_lib/primal_split.lua')
local function reset()
    enemies,allies,creeps,actions,focus={}, {}, {}, {}, nil
    retreat=false
    now=now+10
    for _,s in ipairs({earth,storm,fire}) do
        s.hp=1000; s.mods={}; s.invisible=false; s.rooted=false; s.silenced=false; s.busy=false; s.disarmed=false
        s.primalSplitWindWalkTime=nil
    end
    for _,a in ipairs({boulder,cyclone,dispel,wind}) do a.castable=true end
    earth.abilities={[boulder.name]=boulder}
    storm.abilities={[cyclone.name]=cyclone,[dispel.name]=dispel,[wind.name]=wind}
end
local function think(s) split.MinionThink(bot,s) end
reset(); focus=unit('focus',250); local channel=unit('channel',500); channel.channel=true; enemies={focus,channel}
local ally=unit('ally',200); ally.team=2; ally.mods.modifier_crystal_maiden_frostbite=true; allies={ally}
think(storm); assert(actions[1].name==cyclone.name and actions[1].target==channel,'Cyclone interrupt precedes Dispel and focus protection')
reset(); channel=unit('channel',700); channel.channel=true; enemies={channel}; wind.castable=false
think(storm); assert(actions[1].kind~='entity','Cyclone does not walk into expanded cast range')
reset(); focus=unit('focus',200); focus.threat=1000; local second=unit('second',400); second.threat=500; enemies={focus,second}
think(storm); assert(actions[1].name==cyclone.name and actions[1].target==second,'Cyclone removes second threat, keeping proper focus available')
for _,field in ipairs({'disabled','immune','blocked','reflected','illusion','invulnerable'}) do
    reset(); focus=unit('focus',200); second=unit('second',400); second[field]=true; enemies={focus,second}; wind.castable=false
    think(storm); assert(actions[1].name~=cyclone.name,'Cyclone rejects '..field)
end
reset(); enemies={unit('real1',250),unit('real2',350)}; cyclone.castable=false; wind.castable=false
think(storm); assert(actions[1].kind=='attack','Dispel not wasted on ordinary real-hero cluster')
reset(); ally=unit('ally',1000); ally.team=2; ally.mods.modifier_orchid_malevolence_debuff=true; allies={ally}
think(storm); assert(actions[1].name==dispel.name and actions[1].loc.x==500,'legal point cast reaches allied basic debuff with radius')
for _,modifier in ipairs({'modifier_ancient_apparition_ice_blast','modifier_stunned','modifier_bane_fiends_grip','modifier_bane_nightmare'}) do
    reset(); ally=unit('ally',200); ally.team=2; ally.mods[modifier]=true; allies={ally}
    think(storm); assert(actions[1].name~=dispel.name,'basic Dispel does not claim to remove '..modifier)
end
reset(); local enemy=unit('shield',1000); enemy.mods.modifier_abaddon_aphotic_shield=true; enemies={enemy}
think(storm); assert(actions[1].name==dispel.name and actions[1].loc.x==500,'Dispel removes a confirmed enemy buff')
reset(); enemy=unit('illusion',300); enemy.illusion=true; enemies={enemy}
think(storm); assert(actions[1].name==dispel.name,'Dispel damages enemy illusions')
reset(); enemy=unit('buff',1150); enemy.mods.modifier_ember_spirit_flame_guard=true; enemies={enemy}; wind.castable=false
think(storm); assert(actions[1].name~=dispel.name,'Dispel cannot reach beyond point range plus radius')
reset(); storm.hp=200; enemies={unit('enemy',300)}
think(storm); assert(actions[1].name==wind.name,'Wind Walk escape despite ready but useless Cyclone/Dispel')
storm.invisible=true; actions={}; think(storm)
assert(actions[1].kind=='move' and actions[1].loc.x==-10000,'do not break survival invisibility with attack')
reset(); enemies={unit('enemy',300)}; focus=enemies[1]
think(storm); assert(actions[1].name==wind.name,'Wind Walk bonus attack when no useful utility cast')
actions={}; wind.castable=false; now=now+0.5; think(storm)
assert(#actions==0,'do not attack before Wind Walk fades into invisibility')
now=now+0.2; storm.invisible=true; think(storm)
assert(actions[1].kind=='attack','offensive Wind Walk resumes attack after fade')
reset(); earth.hp=200; enemies={unit('enemy',300)}; focus=enemies[1]
think(earth); assert(actions[1].kind=='move','low Earth survives before ordinary Boulder')
reset(); earth.hp=200; channel=unit('channel',700); channel.channel=true; enemies={channel}
think(earth); assert(actions[1].name==boulder.name and actions[1].target==channel,'Earth interrupts dangerous channel before retreat')
reset(); channel=unit('channel',900); channel.channel=true; enemies={channel}
think(earth); assert(actions[1].name~=boulder.name,'Boulder only within actual 800 range')
for _,field in ipairs({'disabled','immune','blocked','reflected','invulnerable'}) do
    reset(); focus=unit('focus',300); focus[field]=true; enemies={focus}
    think(earth); assert(actions[1].name~=boulder.name,'Boulder rejects '..field)
end
reset(); focus=unit('focus',300); focus.mods.modifier_antimage_counterspell=true; enemies={focus}
think(earth); assert(actions[1].name~=boulder.name,'explicit current Counterspell guard')
for _,field in ipairs({'attackimmune','invulnerable','unseen'}) do
    reset(); local invalid=unit('invalid',300,100); invalid[field]=true; local valid=unit('valid',400)
    focus=invalid; enemies={invalid,valid}; think(fire)
    assert(actions[1].kind=='attack' and actions[1].target==valid,'attack skips invalid '..field)
end
reset(); focus=unit('ally',200); focus.team=2; enemies={}; think(earth)
assert(actions[1].kind=='move','never attack or stun allied focus')
reset(); focus=unit('focus',300); enemies={focus}; think(fire)
assert(actions[1].kind=='attack' and actions[1].target==focus,'spirits not leashed to hidden original body')
reset(); earth.busy=true; think(earth); assert(#actions==0,'do not overwrite ongoing ability')
print('Brewmaster split scenarios passed')
