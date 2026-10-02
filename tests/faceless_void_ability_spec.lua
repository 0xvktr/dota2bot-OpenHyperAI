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
 function a:GetSpecialValueInt(k) return self.values[k] or 0 end
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
J.IsStuck=function() return false end
J.IsUnitTargetProjectileIncoming=function() return false end
J.IsWillBeCastUnitTargetSpell=function() return false end
J.IsLocationInArena=function() return false end
J.IsLocationInChrono=function() return false end
J.IsLocationInBlackHole=function() return false end
J.GetLocationToLocationDistance=distance
J.HasBreakModifier=function(u) return u.broken==true end
J.IsInLaningPhase=function() return false end
function IsLocationPassable() return true end
function bot:GetSecondsPerAttack() return 1 end
function U:GetAbilityInSlot(slot) return self.spells and self.spells[slot] or nil end
J.GetEnemiesNearLoc=function(l,r) local t={};for _,u in pairs(enemies) do if distance(u,l)<=r then t[#t+1]=u end end;return t end
J.GetAlliesNearLoc=function(l,r) local t={bot};for _,u in pairs(allies) do if u~=bot and distance(u,l)<=r then t[#t+1]=u end end;return t end
local q=spell('faceless_void_time_walk',0,{range=800,speed=3000,backtrack_duration=2,mana=40})
local w=spell('faceless_void_time_dilation',0,{radius=700,damage_per_stack=10})
local r=spell('faceless_void_chronosphere',500,{radius=500,duration=4.75,mana=275})
local d=spell('faceless_void_time_walk_reverse',0,{mana=0})
local lock=spell('faceless_void_time_lock',0);lock.passive=true
local hero=H.load('npc_dota_hero_faceless_void','pos_1')
local copy=H.realDofile('bots/FunLib/rubick_hero/faceless_void.lua')
local function tick(stolen,a) actions={};if stolen then local handled=copy.ConsiderStolenSpell(a); assert(handled==(actions[1]~=nil), "copied dispatcher returns true only after an action") else hero.SkillsComplement() end;return actions[1] end
for _,stolen in ipairs({false,true}) do
 reset();w.ready=true;target=foe(600);bot.mode='GoingOnSomeone';target.spells={}
 assert(tick(stolen,w).shape=='none','current Dilation base stack still gives purposeful chase slow')
 target.immune=true;assert(tick(stolen,w)==nil,'Dilation rejects immune targets');target.immune=false
 target.mods.modifier_faceless_void_time_dilation=true;assert(tick(stolen,w)==nil,'do not refresh live Dilation');target.mods={}
 target.x=701;assert(tick(stolen,w)==nil,'Dilation radius is not spell cast range')
 reset();w.ready=true;target=foe(600);target.spells={[0]=spell('test_spell',0)};target.spells[0].cooldown=5
 assert(tick(stolen,w)==nil,'enemy cooldowns are not available and cannot justify idle Dilation')
 bot.mode='InTeamFight';assert(tick(stolen,w),'base-stack Dilation remains useful in active fights')
 reset();r.ready=true;target=foe(950,300);bot.mode='GoingOnSomeone'
 local cast=tick(stolen,r);assert(cast and cast.name==r.name and cast.target.x==500,'Chrono bounds center while reaching edge target')
 target.x=1001;assert(tick(stolen,r)==nil,'Chrono cannot exceed real cast+radius')
 target.x=600;local ally=friend(500);assert(tick(stolen,r)==nil,'avoid freezing an important allied hero')
 ally.name='npc_dota_hero_faceless_void';assert(tick(stolen,r),'allied Void is naturally exempt')
 target.name='npc_dota_hero_faceless_void';assert(tick(stolen,r)==nil,'enemy Void cannot be controlled by stolen Chrono')
 reset();r.ready=true;bot.mode='GoingOnSomeone';target=foe(600,900)
 assert(tick(stolen,r)==nil,'solo damage uses attack cycle time rather than integer attack speed')
 target.hp=300;bot.disarmed=true;assert(tick(stolen,r)==nil,'solo Chrono needs actual actor attacks');bot.disarmed=false
 target.ethereal=true;assert(tick(stolen,r)==nil,'solo physical plan does not kill ethereal target')
 reset();q.ready=true;q.level=1;bot.mode='GoingOnSomeone';target=foe(700);allies={bot}
 assert(tick(stolen,q)==nil,'early Walk is not spent on unprotected healthy chase')
 bot.scepter=true;spells.faceless_void_time_lock=nil;assert(tick(stolen,q)==nil,'copied Scepter does not assume missing Time Lock')
 spells.faceless_void_time_lock=lock;assert(tick(stolen,q).name==q.name,'known current Time Lock permits upgraded approach')
 reset();q.ready=true;r.ready=true;bot.mana=300;tick(stolen,q)
 now=now+0.5;bot.hp=500;bot.recent=true
 assert(tick(stolen,q).name==q.name,'observed substantial recent damage makes Walk urgent')
 bot.rooted=true;assert(tick(stolen,q)==nil,'Walk is root-disabled')
 reset();q.ready=true;d.ready=false;bot.mode='Retreating';bot.recent=true;foe(100)
 local walk=tick(stolen,q);assert(walk and walk.name==q.name,'retreat Walk starts from real old location')
 bot.x=walk.target.x;now=now+0.6;q.ready=false;d.ready=true
 assert(tick(stolen,d)==nil,'do not reverse a successful escape into old danger')
 reset();q.ready=true;q.level=4;target=foe(700);bot.mode='GoingOnSomeone';allies={bot}
 local approach=tick(stolen,q);assert(approach and approach.name==q.name,'ordinary late approach records origin')
 bot.x=approach.target.x;now=now+0.6;q.ready=false;d.ready=true;bot.mode='Retreating'
 assert(tick(stolen,d).name==d.name,'reverse returns from danger to observed safe original position')
 reset();d.ready=true;bot.mode='Retreating';now=now+5
 assert(tick(stolen,d)==nil,'expired or unobserved reverse origin does not execute')
 reset();q.ready=true;bot.channel=true;bot.mode='Retreating';bot.recent=true
 assert(tick(stolen,q)==nil,'preserve channels');bot.channel=false;q.hidden=true
 assert(tick(stolen,q)==nil,'hidden Walk is not usable')
end
reset();q.ready=true;r.ready=true;w.ready=true;target=foe(600,300);bot.mode='GoingOnSomeone';allies={bot}
assert(tick(false).name==r.name,'ready Chrono catch precedes normal Walk and Dilation')
reset();q.ready=true;r.ready=true;bot.mana=300;tick(false)
now=now+0.5;bot.hp=500;bot.recent=true
assert(tick(false).name==q.name,'emergency Walk may spend ultimate-reserved mana')
local previousGate=J.CanNotUseAbility
J.CanNotUseAbility=function() error('unknown spell queried generic gate') end
assert(copy.ConsiderStolenSpell({GetName=function() return 'unknown_spell' end})==nil,'unknown copied spell returns nil before any gates')
J.CanNotUseAbility=previousGate
print('Faceless Void ability scenarios passed')
