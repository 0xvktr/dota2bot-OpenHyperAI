local H=dofile('tests/hero_harness.lua'); local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0; BOT_MODE_LANING=1
DAMAGE_TYPE_PURE=4; DAMAGE_TYPE_PHYSICAL=1; DAMAGE_TYPE_MAGICAL=2; UNIT_LIST_ENEMY_HEROES=1
local enemies,allies,creeps,actions,target={},{},{},{},nil
local U={};U.__index=U
local function unit(x,hp) return setmetatable({x=x,hp=hp or 1000,maxHp=1000,mods={},valid=true,hero=true},U) end
function U:CanBeSeen() return self.valid end
function U:IsInvulnerable() return self.invul==true end
function U:IsMagicImmune() return self.immune==true end
function U:IsAttackImmune() return self.attackImmune==true end
function U:IsDisarmed() return self.disarmed==true end
function U:IsInvisible() return self.invis==true end
function U:IsChanneling() return self.channel==true end
function U:HasModifier(n) return self.mods[n]==true end
function U:GetHealth() return self.hp end
function U:GetMaxHealth() return self.maxHp end
function U:GetLocation() return {x=self.x,y=0} end
function U:GetExtrapolatedLocation(d) self.predictionDelay=d;return {x=self.x+(self.speed or 0)*d,y=0} end
function U:GetUnitName() return self.ranged and 'npc_dota_creep_ranged' or 'npc_dota_hero_pangolier' end
function U:WasRecentlyDamagedByAnyHero() return self.recent==true end
function U:WasRecentlyDamagedByHero(e) return e.recent==true end
function U:DistanceFromFountain() return 2000 end
setmetatable(bot,U)
function bot:GetLevel() return 20 end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:GetAttackRange() return 150 end
function bot:GetAttackDamage() return 100 end
function bot:GetActiveMode() return self.mode=='Laning' and BOT_MODE_LANING or BOT_MODE_NONE end
function bot:HasScepter() return self.scepter==true end
function bot:GetNearbyCreeps() return creeps end
function bot:GetNearbyLaneCreeps() return creeps end
function bot:GetNearbyTowers() return {} end
function bot:FindAoELocation(_,heroes,_,r,radius,delay,damage) self.aoeDelay=delay;return self.aoe or {count=0,targetloc={x=0,y=0}} end
local function record(a,t,queued)
 actions[#actions+1]={name=a.name,target=t,queued=queued==true}
 if a.name=='bloodseeker_rupture' then t.mods.modifier_bloodseeker_rupture=true end
 if a.name=='bounty_hunter_track' then t.mods.modifier_bounty_hunter_track=true end
end
bot.ActionQueue_UseAbilityOnEntity=function(_,a,t) record(a,t,true) end
bot.Action_UseAbilityOnEntity=function(_,a,t) record(a,t,false) end
bot.ActionQueue_UseAbilityOnLocation=bot.ActionQueue_UseAbilityOnEntity
bot.Action_UseAbilityOnLocation=bot.Action_UseAbilityOnEntity
bot.ActionQueue_UseAbility=function(_,a) record(a) end
bot.Action_UseAbility=bot.ActionQueue_UseAbility
GetUnitToUnitDistance=function(a,b) return math.abs(a.x-b.x) end
GetUnitToLocationDistance=function(a,l) return math.abs(a.x-l.x) end
GetUnitList=function() return enemies end
J.IsValid=function(u) return u~=nil and u.valid end; J.IsValidHero=function(u) return J.IsValid(u) and u.hero end
J.IsInRange=function(a,b,r) return math.abs(a.x-b.x)<=r end
J.GetNearbyHeroes=function(u,r,enemy)
 local list={}; for _,e in ipairs(enemy and enemies or allies) do if J.IsInRange(u,e,r) then list[#list+1]=e end end;return list
end
J.CanCastOnMagicImmune=function(u) return J.IsValid(u) and not u.invul and not u.illusion end
J.CanCastOnNonMagicImmune=function(u) return J.CanCastOnMagicImmune(u) and not u.immune end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked end
J.CanCastAbility=function(a) return a~=nil and a.castable and not a.passive and not a.hidden end
J.IsItemAvailable=function() return nil end
J.CanNotUseAbility=function() return bot.channel==true end
J.GetProperTarget=function() return target end
J.WillKillTarget=function(u,d,t,delay) bot.killType=t;bot.killDelay=delay;return u.hp<=d end
J.WillMagicKillTarget=function(_,u,d,delay) bot.killDelay=delay;return u.hp<=d*(u.resist and 0.75 or 1) end
J.CanKillTarget=function(u,d) return u.hp<=d end
J.IsAllowedToSpam=function() return bot.spam~=false end
J.IsAttacking=function(u) return u.attacking==true end
J.IsRealInvisible=function(u) return u.invis==true end
J.IsChasingTarget=function() return true end
J.IsKeyWordUnit=function(_,u) return u.ranged==true end
J.SetQueuePtToINT=function() end
J.Role.IsCarry=function() return true end
J.GetLocationTowardDistanceLocation=function(u,l,d) return {x=u.x+(l.x>=u.x and d or -d),y=0} end
for _,n in ipairs({'GoingOnSomeone','InTeamFight','Retreating','Farming','Pushing','Defending','DoingRoshan','DoingTormentor','InEnemyArea'}) do
 J['Is'..n]=function(u) return u.mode==n end
end
local abilities={}
local function ability(name,range,values)
 local a={name=name,range=range or 0,values=values or {},castable=false}
 function a:GetName() return self.name end
 function a:GetCastRange() return self.range end
 function a:GetCastPoint() return self.values.castpoint or 0.3 end
 function a:GetManaCost() return 100 end
 function a:GetSpecialValueInt(k) return self.values[k] or 0 end
 function a:GetSpecialValueFloat(k) return self.values[k] or 0 end
 function a:GetToggleState() return self.toggle==true end
 function a:IsTrained() return not self.passive end
 abilities[name]=a;return a
end
local function reset()
 enemies,allies,creeps,actions,target={},{},{},{},nil
 bot.x=0;bot.hp=1000;bot.maxHp=1000;bot.mods={};bot.valid=true;bot.hero=true;bot.mode=nil;bot.channel=false;bot.invis=false;bot.scepter=false;bot.mana=1000;bot.spam=true;bot.aoe=nil;bot.attacking=false;bot.recent=false;bot.disarmed=false
 for _,a in pairs(abilities) do a.castable=false;a.toggle=false end
end

function U:IsRooted() return self.rooted==true end
function U:IsAlive() return self.valid end
function U:IsStunned() return self.stunned==true end
function U:IsHexed() return false end
function U:IsSilenced() return false end
function U:IsNightmared() return false end
function U:IsCastingAbility() return self.casting==true end
function U:GetCurrentActiveAbility() return self.activeAbility end
function U:NumQueuedActions() return self.queued or 0 end
function U:IsAncientCreep() return self.ancient==true end
function U:IsDominated() return self.dominated==true end
function U:GetEstimatedDamageToTarget() return self.power or 100 end
function bot:GetNearbyNeutralCreeps() return creeps end
function bot:GetNearbyBarracks() return self.barracks and {unit(300)} or {} end
function bot:GetNearbyTowers() return self.tower and {unit(500)} or {} end
J.IsDisabled=function(u) return u.disabled==true or u.mods.modifier_crystal_maiden_frostbite==true end
J.IsUnitTargetProjectileIncoming=function(u) return u.projectile==true end
J.IsOtherAllysTarget=function(u) return u.allyTarget==true end
J.IsRoshan=function(u) return J.IsValid(u) and u.roshan==true end
J.IsTormentor=function(u) return J.IsValid(u) and u.tormentor==true end
J.GetTeamFountain=function() return {x=-5000,y=0} end
J.WillMagicKillTarget=function(_,u,d,delay) bot.killDelay=delay;bot.killDamage=d;return u.hp+(u.regen or 0)*delay<=d*(u.resist and 0.75 or 1) end
local now=0;DotaTime=function() return now end
local originalReset=reset
reset=function()
 now=now+10;originalReset();bot.activeAbility=nil;bot.rooted=false;bot.stunned=false;bot.casting=false;bot.queued=0;bot.projectile=false;bot.immune=false;bot.tower=false;bot.barracks=false
end

local q=ability('crystal_maiden_crystal_nova',700,{radius=425,nova_damage=260})
local w=ability('crystal_maiden_frostbite',600,{damage_per_second=100,duration=3,creep_multiplier=4})
local r=ability('crystal_maiden_freezing_field',0,{radius=810})
local clone=ability('crystal_maiden_crystal_clone',-1,{hop_distance=275,frostbite_radius=450,clone_duration=5,clone_health=150})
local aura=ability('crystal_maiden_brilliance_aura');aura.passive=true
local teleport=ability('item_tpscroll')
bot.GetAbilityByName=function(_,n) return ({A1=q,A2=w,A3=aura,A4=clone,A6=r})[n] or abilities[n] end
local hero=H.load('npc_dota_hero_crystal_maiden','pos_5');local copy=H.realDofile('bots/FunLib/rubick_hero/crystal_maiden.lua')
local function tick(stolen,a) actions={};if stolen then copy.ConsiderStolenSpell(a) else hero.SkillsComplement() end;return actions[1] end
for _,stolen in ipairs({false,true}) do
 reset();w.castable=true;target=unit(600,250);target.regen=20;enemies={target}
 assert(tick(stolen,w)==nil,'Frostbite full duration is not instant lethal damage')
 assert(bot.killDamage==300 and math.abs(bot.killDelay-3.3)<0.001,'Frostbite actual DPS duration and cast time')
 target.regen=0;assert(tick(stolen,w).target==target,'Frostbite lethal after full DOT')
 target.x=601;assert(tick(stolen,w)==nil,'Frostbite does not borrow attack reach')
 reset();w.castable=true;target=unit(600);target.channel=true;enemies={target}
 assert(tick(stolen,w)==nil,'root does not interrupt arbitrary channel')
 target.mods.modifier_teleporting=true;assert(tick(stolen,w).target==target,'root interrupts teleport')
 target.mods={modifier_teleporting=true,modifier_antimage_counterspell=true};assert(tick(stolen,w)==nil,'avoid reflected Frostbite')
 target.mods={modifier_teleporting=true,modifier_antimage_counterspell_ally=true};assert(tick(stolen,w)==nil,'avoid allied reflected Frostbite')
 reset();q.castable=true;target=unit(1100);bot.mode='GoingOnSomeone';enemies={target}
 assert(tick(stolen,q).target.x==700,'Nova edge cast clamps to700 legal reach')
 target.x=1126;assert(tick(stolen,q)==nil,'reject target beyond Nova edge')
 reset();w.castable=true;bot.mode='Farming';local small=unit(200,500);small.hero=false;local large=unit(600,1500);large.hero=false;creeps={small,large}
 assert(tick(stolen,w).target==large,'Frostbite picks high-health non-ancient neutral')
 large.ancient=true;assert(tick(stolen,w).target==small,'ancient excluded from quadruple-damage farming')
 small.allyTarget=true;assert(tick(stolen,w)==nil,'do not steal allied neutral target')
 reset();w.castable=true;local summon=unit(600,900);summon.hero=false;summon.dominated=true;creeps={summon}
 assert(tick(stolen,w).target==summon,'Frostbite controls enemy summon')
 reset();r.castable=true;enemies={unit(790),unit(800)};bot.mode='InTeamFight';local ally=unit(400);allies={ally}
 assert(tick(stolen,r).name==r.name,'supported Field uses full810 radius')
 bot.recent=true;assert(tick(stolen,r)==nil,'avoid exposed channel while actively focused')
 bot.immune=true;assert(tick(stolen,r),'protected Field can commit')
 bot.immune=false;bot.hp=300;assert(tick(stolen,r)==nil,'critical exposed HP suppresses Field')
 reset();q.castable=true;clone.castable=true;target=unit(450);enemies={target};bot.mode='GoingOnSomeone'
 assert(tick(stolen,clone).name==clone.name,'Clone creates root setup')
 clone.castable=false;bot.x=-275
 assert(tick(stolen,q).target.x==0,'Nova detonates known clone origin rather than missing it at enemy center')
 now=now+6;assert(tick(stolen,q).target.x==425,'expired clone cannot redirect Nova')
 reset();q.castable=true;w.castable=true;clone.castable=true;r.castable=true;bot.channel=true;bot.projectile=true
 assert(tick(stolen,clone)==nil,'Clone must not disturb ordinary channel such as TP')
 bot.mods.modifier_crystal_maiden_freezing_field=true;bot.scepter=true;bot.activeAbility=teleport
 assert(tick(stolen,clone)==nil and tick(stolen,w)==nil and tick(stolen,q)==nil,'Field modifier must not override separate TP channel')
 bot.activeAbility=nil
 assert(tick(stolen,clone)==nil,'unknown overlapping channel must also be preserved')
 bot.activeAbility=r;bot.scepter=false
 assert(tick(stolen,clone).target.x==-275,'Clone may disjoint toward safety during active Field')
 clone.castable=false;bot.projectile=false;target=unit(500);enemies={target};bot.mode='GoingOnSomeone'
 assert(tick(stolen,w)==nil,'ordinary spells preserve unsceptered Field')
 bot.scepter=true;local cast=tick(stolen,w)
 assert(cast.name==w.name and not cast.queued,'Scepter Frostbite issues immediately during Field')
 w.castable=false;cast=tick(stolen,q)
 assert(cast.name==q.name and not cast.queued,'Scepter Nova issues immediately during Field')
 w.castable=true
 bot.queued=1;assert(tick(stolen,w)==nil,'do not multiply queued casts during Field')
 bot.queued=0;bot.casting=true;assert(tick(stolen,w)==nil,'respect spell already being cast during Field')
end
reset();q.castable=true;w.castable=true;target=unit(500);bot.mode='GoingOnSomeone';enemies={target}
local ordinary=tick(false,w);assert(ordinary.name==w.name and ordinary.queued,'ordinary Frostbite retains queued action')
w.castable=false;ordinary=tick(false,q);assert(ordinary.name==q.name and ordinary.queued,'ordinary Nova retains queued action')
reset();q.castable=true;w.castable=true;target=unit(1000);bot.mode='GoingOnSomeone';enemies={target}
assert(tick(false,q).name==q.name,'Nova initiates outside Frostbite reach')
reset();aura.castable=true;assert(tick(false,aura)==nil,'never cast passive Aura')
reset();clone.castable=true;bot.channel=true;bot.projectile=true
assert(copy.UseFreezingFieldSpell()==false,'early Rubick hook refuses TP channel')
bot.mods.modifier_crystal_maiden_freezing_field=true;bot.scepter=true;bot.activeAbility=teleport;actions={}
assert(copy.UseFreezingFieldSpell()==false and #actions==0,'early hook preserves separate TP despite active Field modifier')
bot.activeAbility=nil
assert(copy.UseFreezingFieldSpell()==false and #actions==0,'early hook preserves unknown overlapping channel')
bot.activeAbility=r;bot.scepter=false
assert(copy.UseFreezingFieldSpell()==true and #actions==1 and actions[1].name==clone.name,'early hook casts only allowed Clone during Field')
reset();bot.mods.modifier_crystal_maiden_freezing_field=true;bot.channel=true;bot.activeAbility=r;bot.scepter=true;w.castable=true;target=unit(500);enemies={target};bot.mode='GoingOnSomeone'
assert(copy.UseFreezingFieldSpell()==true and actions[1].name==w.name,'early hook uses live Scepter permitted spell')
bot.stunned=true;actions={};assert(copy.UseFreezingFieldSpell()==false and #actions==0,'early hook refuses interrupted caster')
print('Crystal Maiden ability scenarios passed')
