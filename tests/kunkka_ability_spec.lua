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
 for _,a in pairs(spells) do a.ready=false;a.active=true;a.hidden=false;a.trained=true;a.level=2;a.charges=3;a.autocast=false;a.cooldown=0 end
 now=now+10
end
local function foe(x,hp) local u=unit(x,hp);enemies[#enemies+1]=u;return u end
local function friend(x,hp) local u=unit(x,hp);u.team=TEAM_RADIANT;allies[#allies+1]=u;return u end
function U:GetAttackRange() return self.attackRange or 150 end
J.GetDistance=distance
J.HasBreakModifier=function(u) return u.broken==true end
J.IsRealInvisible=function(u) return u.invisible end
local q=spell('kunkka_torrent',1300,{radius=250,delay=1.6,torrent_damage=180,castpoint=0.4,mana=90})
local w=spell('kunkka_tidebringer',150,{cleave_starting_width=150,cleave_ending_width=550,cleave_distance=775,damage_bonus=70,cleave_damage=150,mana=0})
local e=spell('kunkka_x_marks_the_spot',700,{duration=3,allied_duration=6,castpoint=0.4,mana=50})
function U:GetModifierByName(name) return self.mods[name] and 0 or -1 end
function U:GetModifierSourceAbility() return self.modsource or e end
local back=spell('kunkka_return',0,{castpoint=0.2,mana=0})
local r=spell('kunkka_ghostship',1000,{tooltip_delay=3.1,ghostship_width=450,ghostship_distance=2000,damage=475,castpoint=0.3,mana=175})
local wave=spell('kunkka_tidal_wave',1050,{speed=700,radius=750,damage=180,castpoint=0.2,mana=75})
function r:GetAbilityDamage() return self.values.damage end
local hero=dofile('bots/BotLib/hero_kunkka.lua');local copy=dofile('bots/FunLib/rubick_hero/kunkka.lua')
local function tick(stolen,a)
 actions={};if stolen then local handled=copy.ConsiderStolenSpell(a);assert(handled==(actions[1]~=nil),'canonical handled result') else hero.SkillsComplement() end
 assert(#actions<=1,'casts observed one step at a time');return actions[1]
end
for _,stolen in ipairs({false,true}) do
 reset();e.ready=true;target=foe(650);bot.mode='GoingOnSomeone'
 assert(tick(stolen,e).target==target,'independent X applies real control');e.ready=false;back.ready=true
 assert(tick(stolen,back)==nil,'Return cannot assume cast X succeeded');target.mods.modifier_kunkka_x_marks_the_spot=true;target.channel=true
 assert(tick(stolen,back).name==back.name,'observed own X returns channeler');target.channel=false;target.mods={}
 assert(tick(stolen,back)==nil,'no invented repeated Return')
 reset();e.ready=true;target=foe(701);bot.mode='GoingOnSomeone'
 assert(tick(stolen,e)==nil,'X excludes outside actual range');target.x=650;target.blocked=true
 assert(tick(stolen,e)==nil,'X respects spell block');target.blocked=false;target.reflected=true
 assert(tick(stolen,e)==nil,'X respects reflect');target.reflected=false;target.immune=true
 assert(tick(stolen,e)==nil,'X cannot target debuff immunity')
 reset();q.ready=true;target=foe(700);target.speed=100;bot.mode='GoingOnSomeone'
 local a=tick(stolen,q);assert(a and a.target.x==900 and target.delay==2,'Torrent uses complete 2 second cast and delay prediction');target.x=1200
 assert(tick(stolen,q)==nil,'predicted point outside true range excluded');target.x=700;target.immune=true
 assert(tick(stolen,q)==nil,'Torrent cannot affect immunity')
 reset();r.ready=true;target=foe(900);target.speed=100;bot.mode='GoingOnSomeone'
 assert(tick(stolen,r)==nil,'Ghostship 3.4 second prediction excludes target beyond range')
 target.speed=0;bot.mode='InTeamFight';foe(950)
 assert(tick(stolen,r).shape=='point','Ghostship controls grouped heroes with true radius');for _,enemy in pairs(enemies) do enemy.immune=true end
 assert(tick(stolen,r)==nil,'no Boat only for immune targets')
 reset();r.ready=true;target=foe(800);local ally=friend(0,300);ally.recent=true
 assert(tick(stolen,r),'Ghostship actual path gives wounded ally Rum without three enemies');ally.x=0;ally.y=1000
 assert(tick(stolen,r)==nil,'ally outside actual path does not justify protection');ally.y=0;ally.mods.modifier_kunkka_ghost_ship_damage_absorb=true
 assert(tick(stolen,r)==nil,'do not justify Boat by already protected ally')
 reset();w.ready=true;target=foe(700);local creep=unit(140);creep.hero=false;creeps={creep};bot.mode='GoingOnSomeone'
 assert(tick(stolen,w).target==creep,'Tidebringer cleaves hero through actual in-range creep');target.y=700
 assert(tick(stolen,w)==nil,'Tidebringer excludes hero beside cleave direction');target.y=0;creep.x=180
 assert(tick(stolen,w)==nil,'no fake 200 attack reach');creep.x=140;bot.disarmed=true
 assert(tick(stolen,w)==nil,'Tidebringer requires attacks');bot.disarmed=false;bot.broken=true
 assert(tick(stolen,w)==nil,'Tidebringer respects Break');bot.broken=false;creep.ethereal=true
 assert(tick(stolen,w)==nil,'cleave primary must be physically attackable')
 reset();wave.ready=true;target=foe(600);target.attackTarget=bot;bot.mode='Retreating'
 assert(tick(stolen,wave).target.x>0,'Tidal Wave pushes pursuer away rather than toward fountain');target.immune=true
 assert(tick(stolen,wave)==nil,'Wave excludes immunity');target.immune=false;target.x=1100
 assert(tick(stolen,wave)==nil,'Wave actual range boundary')
end
for _,stolen in ipairs({false,true}) do
 reset();target=foe(300);bot.mode='GoingOnSomeone';e.ready=true
 assert(tick(stolen,e).name==e.name);e.ready=false;back.ready=true;q.ready=true;r.ready=true
 if not stolen then assert(tick(false,q)==nil,'pending mark does not launch blind combo') end
 target.x=500;target.mods.modifier_kunkka_x_marks_the_spot=true;now=now+0.5
 assert(tick(stolen,r).target.x==500,'Boat anchors to observed mark rather than guessed pre-cast location');r.ready=false;r.cooldown=80;now=now+0.3
 assert(tick(stolen,q).target.x==500,'Torrent aims at observed mark');q.ready=false;q.cooldown=14;target.x=900;now=now+0.4
 assert(tick(stolen,back)==nil,'Return does not use old fixed timer or prematurely pull')
 now=now+1.3;assert(tick(stolen,back).name==back.name,'Return lands just before actual recorded Torrent impact')
 target.mods={};assert(tick(stolen,back)==nil,'returned state cleared')
 reset();target=foe(300);bot.mode='GoingOnSomeone';e.ready=true;tick(stolen,e);e.ready=false;back.ready=true
 target.mods.modifier_kunkka_x_marks_the_spot=true;target.channel=true;bot.channel=true
 assert(tick(stolen,back)==nil,'pending combo never cancels unrelated channel');bot.channel=false;target.mods={};now=now+2
 assert(tick(stolen,back)==nil,'lost or stale mark cannot return')
end
reset();target=foe(300);bot.mode='GoingOnSomeone';e.ready=true;tick(true,e);e.ready=false
 target.mods.modifier_kunkka_x_marks_the_spot=true;q.ready=true;tick(true,q);back.ready=true
 now=now+1.7;assert(tick(true,back)==nil,'canceled Torrent with no observed cooldown cannot trigger timed Return')
 for _,stolen in ipairs({false,true}) do
 reset();target=foe(300);bot.mode='GoingOnSomeone';e.ready=true;tick(stolen,e);e.ready=false;back.ready=true
 target.mods.modifier_kunkka_x_marks_the_spot=true;target.channel=true
 target.modsource=spell('foreign_kunkka_x',700,{})
 assert(tick(stolen,back)==nil,'canceled own X cannot adopt another Kunkka modifier')
end
local gate=J.CanNotUseAbility;J.CanNotUseAbility=function() error('unknown queried gate') end
assert(copy.ConsiderStolenSpell({GetName=function() return 'unknown_spell' end})==nil);J.CanNotUseAbility=gate
print('Kunkka ability scenarios passed')
