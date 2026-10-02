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
J.IsCore=function() return false end
J.IsTaunted=function() return false end
J.IsRealInvisible=function(u) return u.invisible==true end
J.GetManaAfter=function(cost) return (bot.mana-cost)/1000 end
J.GetHealthAfter=function(cost) return (bot.hp-cost)/bot.maxhp end
J.GetEnemiesNearLoc=function(l,r) local t={};for _,u in pairs(enemies) do if distance(u,l)<=r then t[#t+1]=u end end;return t end
J.GetLocationToLocationDistance=distance
J.HasBreakModifier=function(u) return u.broken==true end
function bot:GetNearbyBarracks() return {} end
function bot:GetNearbyFillers() return {} end
local q=spell('enigma_malefice',600,{damage=100,stun_instances=3})
local w=spell('enigma_demonic_conversion',400,{spawn_count=3})
local e=spell('enigma_midnight_pulse',700,{radius=600,duration=12})
local r=spell('enigma_black_hole',275,{radius=420,damage=200,duration=4,scepter_pct_damage=4,scepter_radius=1000})
local blink=spell('item_blink',1200);local bkb=spell('item_black_king_bar',0)
local lens
function bot:GetItemInSlot(slot) if slot==0 then return lens elseif slot==1 and blink.ready then return blink elseif slot==2 and bkb.ready then return bkb end end
local hero=H.load('npc_dota_hero_enigma','pos_3')
local copy=H.realDofile('bots/FunLib/rubick_hero/enigma.lua')
local function tick(stolen,a) actions={};if stolen then local handled=copy.ConsiderStolenSpell(a); assert(handled==(actions[1]~=nil), "copied dispatcher returns true only after an action") else hero.SkillsComplement() end;return actions[1] end
for _,stolen in ipairs({false,true}) do
 reset();lens=nil;q.ready=true;target=foe(600);target.channel=true
 assert(tick(stolen,q).shape=='unit','timely Malefice interrupt at actual range')
 target.x=601;assert(tick(stolen,q)==nil,'interrupt does not walk or borrow attack padding');target.x=600
 target.blocked=true;assert(tick(stolen,q)==nil,'Malefice respects spell block');target.blocked=false;target.reflected=true
 assert(tick(stolen,q)==nil,'Malefice avoids reflection');target.reflected=false;target.immune=true
 assert(tick(stolen,q)==nil,'Malefice does not pierce debuff immunity')
 reset();e.ready=true;target=foe(650);target.immune=true;bot.mode='GoingOnSomeone';target.blocked=true;target.reflected=true
 assert(tick(stolen,e).shape=='point','Pulse is an area spell piercing immunity, not blocked/reflected')
 target.x=1301;assert(tick(stolen,e)==nil,'Pulse beyond cast radius reach does not execute')
 reset();r.ready=true;target=foe(694,600);target.immune=true;bot.mode='GoingOnSomeone'
 local cast=tick(stolen,r);assert(cast and cast.name==r.name and cast.target.x==275,'Black Hole clamps center to real range and catches within420')
 target.speed=1000;r.values.castpoint=0.3;assert(tick(stolen,r)==nil,'moving target predicted outside catch radius does not fake hit');target.speed=0;r.values.castpoint=0
 target.x=696;assert(tick(stolen,r)==nil,'Black Hole excludes beyond real range+420 even with Scepter pull')
 bot.scepter=true;target.x=900;assert(tick(stolen,r)==nil,'Scepter1000 pull is not a disabling Hole radius')
 target.x=400;target.hp=1200;target.maxhp=4000
 assert(tick(stolen,r),'current Scepter max-health damage justifies high-health solo catch')
 bot.scepter=false;assert(tick(stolen,r)==nil,'base Hole does not invent Scepter damage')
 reset();r.ready=true;bot.mode='InTeamFight';foe(500);foe(550)
 bot.FindAoELocation=function() return {count=2,targetloc=Vector(500,0,0)} end
 assert(tick(stolen,r),'multihero Black Hole verifies actual caught heroes')
 enemies[2].invulnerable=true;assert(tick(stolen,r)==nil,'invulnerable hero does not count toward expensive AoE')
 reset();r.ready=true;target=foe(500,600);bot.mode='GoingOnSomeone';bot.channel=true
 assert(tick(stolen,r)==nil,'preserve channels');bot.channel=false;r.hidden=true
 assert(tick(stolen,r)==nil,'hidden cast cannot execute')
end
reset();lens=nil;q.ready=true;e.ready=true;r.ready=true;target=foe(500);target.channel=true;bot.mode='GoingOnSomeone'
assert(tick(false).name==q.name,'interrupt is not delayed behind Pulse/Hole setup')
reset();blink.ready=true;r.ready=true;bot.mode='InTeamFight';foe(1000);foe(1100)
bot.FindAoELocation=function() return {count=2,targetloc=Vector(1000,0,0)} end
assert(tick(false).name==blink.name,'native discovers live Blink before deciding initiation')
assert(actions[#actions].name==r.name,'Blink initiates Hole at planned landing')
e.ready=true;assert(tick(false).name==blink.name and actions[#actions].name==r.name,'unheld targets receive immediate Blink Hole, not delayed Pulse')
enemies[1].disabled=true;enemies[2].disabled=true
assert(tick(false).name==blink.name and actions[3].name==e.name,'held multihero catch permits Blink Pulse Hole')
blink.ready=false;local nextCast=tick(false);assert(nextCast==nil or nextCast.name~=blink.name,'stale unavailable Blink is cleared next tick')
reset();w.ready=true;bot.hp=260;w.level=4;bot.mode='Pushing'
assert(tick(false)==nil,'Summoning flat health cost cannot leave dangerously low health')
reset();e.ready=true;r.ready=true;target=foe(600,600);bot.mode='GoingOnSomeone'
assert(tick(false).name==r.name,'direct Hole opportunity precedes unrelated Pulse cast')
local previousGate=J.CanNotUseAbility
J.CanNotUseAbility=function() error('unknown spell queried generic gate') end
assert(copy.ConsiderStolenSpell({GetName=function() return 'unknown_spell' end})==nil,'unknown copied spell returns nil before any gates')
J.CanNotUseAbility=previousGate
print('Enigma ability scenarios passed')
