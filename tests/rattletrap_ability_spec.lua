local H=dofile('tests/hero_harness.lua'); local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_ACTION_DESIRE_MODERATE=0.5; BOT_ACTION_DESIRE_LOW=0.2
BOT_MODE_NONE=0; DAMAGE_TYPE_MAGICAL=2; DAMAGE_TYPE_PHYSICAL=1; DAMAGE_TYPE_PURE=4; DAMAGE_TYPE_ALL=7
UNIT_LIST_ALLIES=1;UNIT_LIST_ENEMIES=2;UNIT_LIST_ENEMY_HEROES=3;TEAM_RADIANT=2;TEAM_DIRE=3
local enemies,allies,creeps,neutrals,units,actions,target={},{},{},{},{},{},nil
local now=100; function DotaTime() return now end
local U={}; U.__index=U
local function unit(x,hp) return setmetatable({x=x,y=0,hp=hp or 1000,maxhp=1000,valid=true,hero=true,mods={}},U) end
function U:GetLocation() return Vector(self.x,self.y,0) end
function U:GetExtrapolatedLocation(delay) self.delay=delay;return Vector(self.x+(self.speed or 0)*delay,self.y,0) end
function U:GetHealth() return self.hp end
function U:GetMaxHealth() return self.maxhp end
function U:GetTeam() return self.team or TEAM_DIRE end
function U:GetPlayerID() return self.player or 0 end
function U:GetUnitName() return self.name or 'npc_dota_hero_axe' end
function U:IsNull() return not self.valid end
function U:IsAlive() return self.valid and self.hp>0 end
function U:CanBeSeen() return not self.invisible end
function U:IsChanneling() return self.channel==true end
function U:IsCastingAbility() return self.casting==true end
function U:IsUsingAbility() return self.using==true end
function U:NumQueuedActions() return self.queued or 0 end
function U:IsSilenced() return self.silenced==true end
function U:IsStunned() return self.stunned==true end
function U:IsHexed() return self.hexed==true end
function U:IsNightmared() return self.nightmared==true end
function U:IsRooted() return self.rooted==true end
function U:IsDisarmed() return self.disarmed==true end
function U:IsAttackImmune() return self.attackimmune==true end
function U:IsInvulnerable() return self.invulnerable==true end
function U:IsMagicImmune() return self.immune==true end
function U:IsInvisible() return self.invisible==true end
function U:IsIllusion() return self.illusion==true end
function U:HasModifier(n) return self.mods[n]==true end
function U:WasRecentlyDamagedByAnyHero() return self.recent==true end
function U:WasRecentlyDamagedByHero(enemy) return enemy.hurtBot==true end
function U:GetEstimatedDamageToTarget() return self.power or 100 end
function U:GetAttackTarget() return self.attackTarget or target end
function U:GetLevel() return self.level or 6 end
function U:GetCurrentMovementSpeed() return self.movement or 300 end
function U:IsFacingLocation() return self.facing~=false end
function U:DistanceFromFountain() return 2000 end
setmetatable(bot,U)
function bot:GetAttackRange() return self.attackRange or 150 end
function bot:GetAttackDamage() return self.damage or 100 end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return self.maxmana or 1000 end
function bot:HasScepter() return self.scepter==true end
function bot:HasShard() return self.shard==true end
function bot:GetNearbyCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:GetNearbyLaneCreeps(_,enemy) return enemy and creeps or {} end
function bot:GetNearbyTowers() return {} end
function bot:GetCurrentActiveAbility() return self.current end
function bot:FindAoELocation() return {count=0,targetloc=Vector(0,0,0)} end
function bot:SetTarget(t) target=t end
function bot:GetItemInSlot() return nil end
local spells={}
local function spell(name,range,values)
 local a={name=name,range=range or 0,values=values or {},ready=false,active=true,trained=true,level=2,charges=3}
 function a:GetName() return self.name end
 function a:GetCastRange() return self.range end
 function a:GetCastPoint() return self.values.castpoint or 0 end
 function a:GetManaCost() return self.values.mana or 100 end
 function a:GetSpecialValueInt(k) return math.floor(self.values[k] or 0) end
 function a:GetSpecialValueFloat(k) return self.values[k] or 0 end
 function a:IsFullyCastable() return self.ready end
 function a:IsTrained() return self.trained end
 function a:IsNull() return false end
 function a:IsHidden() return self.hidden==true end
 function a:IsActivated() return self.active end
 function a:IsPassive() return self.passive==true end
 function a:GetLevel() return self.level end
 function a:GetCurrentCharges() return self.charges end
 function a:GetCooldownTimeRemaining() return self.cooldown or 0 end
 function a:GetAutoCastState() return self.autocast==true end
 function a:ToggleAutoCast() self.autocast=not self.autocast end
 spells[name]=a;return a
end
bot.GetAbilityByName=function(_,n) return spells[n] end
local function action(a,t,shape) actions[#actions+1]={name=a.name,target=t,shape=shape} end
function bot:Action_UseAbility(a) action(a,nil,'none') end
function bot:Action_UseAbilityOnEntity(a,t) action(a,t,'unit') end
function bot:Action_UseAbilityOnLocation(a,t) action(a,t,'point') end
bot.ActionQueue_UseAbility=bot.Action_UseAbility;bot.ActionQueue_UseAbilityOnEntity=bot.Action_UseAbilityOnEntity
bot.ActionQueue_UseAbilityOnLocation=bot.Action_UseAbilityOnLocation
function bot:Action_ClearActions() actions={} end
function bot:ActionQueue_Delay(t) actions[#actions+1]={shape='delay',time=t} end
local function distance(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
function GetUnitToUnitDistance(a,b) return distance(a,b) end
function GetUnitToLocationDistance(a,b) return distance(a,b) end
function GetUnitList(kind) return kind==UNIT_LIST_ALLIES and units or enemies end
function GetTeam() return TEAM_RADIANT end
local ancient=unit(-10000);function GetAncient() return ancient end
J.IsValid=function(u) return u~=nil and u.valid and not u.invulnerable and u.hp>0 end
J.IsValidTarget=J.IsValid
J.IsValidHero=function(u) return J.IsValid(u) and u.hero end
J.CanCastOnNonMagicImmune=function(u) return J.IsValid(u) and not u.immune and not u.forbidden end
J.CanCastOnMagicImmune=function(u) return J.IsValid(u) and not u.forbidden end
J.IsInEtherealForm=function(u) return u.ethereal==true end
J.CanBeAttacked=function(u) return J.IsValid(u) and not u.attackimmune and not u.ethereal and not u.forbidden end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected end
J.IsInRange=function(a,b,r) return distance(a,b)<=r end
J.GetNearbyHeroes=function(u,r,enemy)
 local result={};for _,v in ipairs(enemy and enemies or allies) do if J.IsInRange(u,v,r) then result[#result+1]=v end end;return result
end
J.GetAroundEnemyHeroList=function(r) return J.GetNearbyHeroes(bot,r,true) end
J.GetAroundAllyHeroList=function(r) return J.GetNearbyHeroes(bot,r,false) end
J.CanCastAbility=function(a) return a~=nil and a.ready and a.active and a.trained and not a.hidden and not a.passive end
J.CanNotUseAbility=function(u) return not u:IsAlive() or u:IsChanneling() or u:IsCastingAbility() or u:IsUsingAbility() or u:NumQueuedActions()>0
 or u:IsSilenced() or u:IsStunned() or u:IsHexed() or u:IsNightmared() or u:IsInvulnerable() end
J.GetHP=function(u) return u.hp/u.maxhp end
J.GetMP=function(u) return u.mana/(u.maxmana or 1000) end
J.GetProperTarget=function() return target end
J.AllowedToSpam=function() return bot.spam~=false end;J.IsAllowedToSpam=J.AllowedToSpam
J.IsItemAvailable=function() return nil end
J.IsDisabled=function(u) return u.disabled==true or u.rooted==true or u.stunned==true end
J.IsCastingUltimateAbility=function(u) return u.ultimate==true end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.WeAreStronger=function() return false end
J.IsAttacking=function() return true end
J.IsStunProjectileIncoming=function() return false end
J.IsRoshan=function(u) return u~=nil and u.roshan==true end
J.IsTormentor=function(u) return u~=nil and u.tormentor==true end
J.GetCorrectLoc=function(u,delay) return u:GetExtrapolatedLocation(delay) end
J.SetQueuePtToINT=function() end
J.SetReportMotive=function() end
J.GetModifierTime=function(u,n) return u.modtimes and u.modtimes[n] or 0 end
J.GetProperCastRange=function(_,_,r) return r end
J.CanKillTarget=function(u,d,k)
 if k==DAMAGE_TYPE_MAGICAL and u.immune or k==DAMAGE_TYPE_PHYSICAL and (u.ethereal or u.attackimmune) then return false end
 return d*(1-(u.resistance or 0))>=u.hp
end
J.Site={GetXUnitsTowardsLocation=function(u,l,r) return Vector(u.x-r,u.y,0) end}
J.GetEscapeLoc=function() return Vector(-10000,0,0) end
for _,mode in ipairs({'GoingOnSomeone','InTeamFight','Retreating','Laning','Farming','Pushing','Defending','DoingRoshan','DoingTormentor'}) do
 J['Is'..mode]=function(u) return u.mode==mode end
end
local function reset()
 enemies,allies,creeps,neutrals,units,actions,target={},{},{},{},{},{},nil
 bot.x=0;bot.y=0;bot.hp=1000;bot.maxhp=1000;bot.valid=true;bot.hero=true;bot.mods={};bot.mode=nil;bot.recent=false;bot.team=TEAM_RADIANT
 bot.channel=false;bot.casting=false;bot.using=false;bot.queued=0;bot.silenced=false;bot.stunned=false;bot.hexed=false;bot.nightmared=false
 bot.disarmed=false;bot.rooted=false;bot.invulnerable=false;bot.immune=false;bot.spam=true;bot.mana=1000;bot.scepter=false;bot.shard=false;bot.invisible=false;bot.current=nil
 for _,a in pairs(spells) do a.ready=false;a.active=true;a.hidden=false;a.trained=true;a.level=2;a.charges=3;a.autocast=false end
 now=now+10
end
local function foe(x,hp) local u=unit(x,hp);enemies[#enemies+1]=u;return u end
local function friend(x,hp) local u=unit(x,hp);u.team=TEAM_RADIANT;allies[#allies+1]=u;return u end

UNIT_LIST_NEUTRAL_CREEPS=4
function GetUnitList(kind) return kind==UNIT_LIST_ALLIES and units or kind==UNIT_LIST_NEUTRAL_CREEPS and neutrals or enemies end
function U:GetHealthRegen() return self.regen or 0 end
function U:GetBoundingRadius() return self.bounding or 24 end
function U:IsBuilding() return self.building==true end
function bot:GetCurrentVisionRange() return 1800 end
J.WillKillTarget=function(u,d,k,delay) return J.CanKillTarget(u,d-(u.regen or 0)*delay-.801,k) end
J.HasBreakModifier=function() return bot.broken==true end
function IsLocationPassable() return not bot.impassable end
J.IsLocHaveTower=function() return bot.tower==true end
J.IsEnemyChronosphereInLocation=function() return bot.chrono==true end
J.IsEnemyBlackHoleInLocation=function() return bot.blackhole==true end
J.IsLocationInArena=function() return bot.arena==true end
J.GetEnemiesNearLoc=function(loc,r) local out={};for _,u in ipairs(enemies) do if distance(loc,u)<=r then out[#out+1]=u end end;return out end
J.GetAlliesNearLoc=function(loc,r) local out={};if distance(loc,bot)<=r then out[#out+1]=bot end;for _,u in ipairs(allies) do if distance(loc,u)<=r then out[#out+1]=u end end;return out end
J.GetTeamFightLocation=function() return bot.fight end
J.GetCurrentRoshanLocation=function() return Vector(7000,0,0) end
J.GetCenterOfUnits=function(list) return list[1]:GetLocation() end
local B=spell('rattletrap_battery_assault',0,{radius=275,overclocking_radius=330,mana=90})
local C=spell('rattletrap_power_cogs',0,{cogs_radius=215,cogs_radius_overclock=330,trigger_distance=185,trigger_distance_overclock=115,mana=90})
local F=spell('rattletrap_rocket_flare',0,{speed=2250,radius=600,damage=200,castpoint=.3,mana=50})
local Hk=spell('rattletrap_hookshot',3000,{speed=6000,latch_radius=125,stun_radius=175,castpoint=.3,mana=150})
local Jp=spell('rattletrap_jetpack',0,{mana=75})
local T=spell('rattletrap_jetpack_toggle')
local O=spell('rattletrap_overclocking',0,{mana=90,rocket_flare_damage_pct=35})
local native=H.load('npc_dota_hero_rattletrap','pos_4')
local copied=H.realDofile('bots/FunLib/rubick_hero/rattletrap.lua')
local count=0
local function fresh()
 reset();bot.broken=false;bot.tower=false;bot.chrono=false;bot.blackhole=false;bot.arena=false;bot.impassable=false;bot.fight=nil
 spells.rattletrap_battery_assault=B;spells.rattletrap_power_cogs=C;spells.rattletrap_hookshot=Hk;spells.rattletrap_overclocking=O
end
local function tick(a,copy)
 if copy then local used=copied.ConsiderStolenSpell(a);assert(used==(#actions>0),'canonical copied action return') else native.SkillsComplement() end
 assert(#actions<=1,'one spell per tick');return actions[1]
end
local function check(label,fn) local ok,err=pcall(fn);assert(ok,label..': '..tostring(err));count=count+1 end
for _,copy in ipairs({false,true}) do
 local pre=copy and 'copied ' or 'native '
 check(pre..'Battery uses current radius and observed upgrade',function() fresh();B.ready=true;bot.mode='GoingOnSomeone';target=foe(300);assert(not tick(B,copy));bot.mods.modifier_rattletrap_overclocking=true;assert(tick(B,copy));actions={};bot.mods.modifier_rattletrap_battery_assault=true;assert(not tick(B,copy)) end)
 check(pre..'Battery rejects immune/invisible enemies',function() fresh();B.ready=true;bot.mode='GoingOnSomeone';target=foe(100);target.immune=true;assert(not tick(B,copy));target.immune=false;target.invisible=true;assert(not tick(B,copy)) end)
 check(pre..'Battery saves any threatened ally',function() fresh();B.ready=true;local ally=friend(250);ally.recent=true;ally.human=true;local u=foe(200);u.attackTarget=ally;assert(tick(B,copy)) end)
 check(pre..'Cogs uses actual own units rather than issuance timer',function() fresh();C.ready=true;bot.mode='GoingOnSomeone';target=foe(180);now=0;assert(tick(C,copy));actions={};local cog=unit(215);cog.name='npc_dota_rattletrap_cog';cog.player=bot:GetPlayerID();units={cog};assert(not tick(C,copy));cog.player=99;assert(tick(C,copy)) end)
 check(pre..'Cogs current upgrade radius and ally trap guard',function() fresh();C.ready=true;bot.mode='GoingOnSomeone';target=foe(290);assert(not tick(C,copy));bot.mods.modifier_rattletrap_overclocking=true;assert(tick(C,copy));actions={};friend(50).recent=true;assert(not tick(C,copy)) end)
 check(pre..'Hook pierces immunity and predicts flight with missing siblings',function() fresh();Hk.ready=true;bot.mode='GoingOnSomeone';target=foe(1200);target.immune=true;target.channel=true;spells.rattletrap_battery_assault=nil;spells.rattletrap_power_cogs=nil;assert(tick(Hk,copy));assert(target.delay>=.5) end)
 check(pre..'Hook exact latch geometry blocks summons and allies',function() fresh();Hk.ready=true;bot.mode='GoingOnSomeone';target=foe(1200);target.channel=true;local summon=foe(600);summon.hero=false;summon.y=140;assert(not tick(Hk,copy));summon.y=180;assert(tick(Hk,copy));actions={};enemies={target};local ally=friend(600);units={ally};assert(not tick(Hk,copy));ally.building=true;assert(tick(Hk,copy)) end)
 check(pre..'Hook rejects overshoot and known unsafe arrival',function() fresh();Hk.ready=true;bot.mode='GoingOnSomeone';target=foe(3000);target.channel=true;target.speed=100;assert(not tick(Hk,copy));target.x=1200;target.speed=0;bot.tower=true;assert(not tick(Hk,copy));bot.tower=false;bot.chrono=true;assert(not tick(Hk,copy)) end)
 check(pre..'Hook retreat requires a real visible safer ally',function() fresh();Hk.ready=true;bot.mode='Retreating';bot.recent=true;assert(not tick(Hk,copy));local ally=friend(-1500);units={ally};assert(tick(Hk,copy));actions={};ally.invisible=true;assert(not tick(Hk,copy)) end)
 check(pre..'Hook root and leash movement guards',function() for _,key in ipairs({'root','modifier_bloodseeker_rupture','modifier_slark_pounce_leash','modifier_puck_coiled'}) do fresh();Hk.ready=true;bot.mode='GoingOnSomeone';target=foe(1200);target.channel=true;if key=='root' then bot.rooted=true else bot.mods[key]=true end;assert(not tick(Hk,copy)) end end)
 check(pre..'Flare has global range and real travel time',function() fresh();F.ready=true;local u=foe(6000,150);u.speed=100;local a=tick(F,copy);assert(a.target.x>6290 and u.delay>2.9);actions={};u.hp=199;u.regen=10;assert(not tick(F,copy)) end)
 check(pre..'Flare observed Overclock damage requires real source',function() fresh();F.ready=true;foe(3000,250);assert(not tick(F,copy));bot.mods.modifier_rattletrap_overclocking=true;assert(tick(F,copy));actions={};spells.rattletrap_overclocking=nil;assert(not tick(F,copy)) end)
 check(pre..'Jetpack respects current active state and movement locks',function() fresh();Jp.ready=true;bot.mode='Retreating';bot.recent=true;foe(300);assert(tick(Jp,copy));actions={};bot.mods.modifier_rattletrap_jetpack=true;assert(not tick(Jp,copy));bot.mods={};bot.rooted=true;assert(not tick(Jp,copy)) end)
 check(pre..'Jetpack toggle requires observed tracker',function() fresh();T.ready=true;bot.mode='GoingOnSomeone';target=foe(100);assert(not tick(T,copy));bot.mods.modifier_rattletrap_jetpack=true;bot.mods.modifier_rattletrap_jetpack_tracker=true;assert(tick(T,copy));actions={};bot.mode='Retreating';bot.recent=true;bot.mods.modifier_rattletrap_jetpack=nil;bot.mods.modifier_slark_pounce_leash=true;assert(not tick(T,copy)) end)
 check(pre..'Overclock only improves an available affordable real cast',function() fresh();O.ready=true;bot.mode='GoingOnSomeone';target=foe(200);spells.rattletrap_battery_assault=nil;spells.rattletrap_power_cogs=nil;spells.rattletrap_hookshot=nil;assert(not tick(O,copy));spells.rattletrap_battery_assault=B;B.ready=true;bot.mana=179;assert(not tick(O,copy) or not copy);actions={};bot.mana=180;assert(tick(O,copy).name==O.name);actions={};bot.mods.modifier_rattletrap_overclocking=true;if copy then assert(not tick(O,copy)) end end)
 check(pre..'normal actor lock and hidden upgrade guard',function() for _,lock in ipairs({'casting','using','channel','queued','silenced','stunned','hexed','nightmared'}) do fresh();F.ready=true;foe(3000,100);bot[lock]=lock=='queued' and 1 or true;assert(not tick(F,copy)) end;fresh();Jp.ready=true;Jp.hidden=true;bot.mode='Retreating';bot.recent=true;foe(100);assert(not tick(Jp,copy)) end)
end
check('unknown copied name never calls GetBot/gates',function() local get=GetBot;GetBot=function() error('unknown bot lookup') end;assert(copied.ConsiderStolenSpell({GetName=function() return 'other_spell' end})==nil);GetBot=get end)
check('native current Tormentor Battery route',function() fresh();B.ready=true;bot.mode='DoingTormentor';target=unit(100);target.hero=false;target.tormentor=true;assert(tick(B,false).name==B.name) end)
check('native proactive Roshan scout and lane Flare preserved',function() fresh();F.ready=true;bot.mode='DoingRoshan';assert(tick(F,false).target.x==7000);fresh();F.ready=true;bot.mode='Pushing';for i=1,4 do local u=unit(600+i*20);u.hero=false;creeps[#creeps+1]=u end;assert(tick(F,false).name==F.name) end)
print('Clockwerk ability scenarios passed: '..count)
