-- Native/copy Willow behavior with real cast classes, legal range and observed state.
local H=dofile('tests/hero_harness.lua');local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0;BOT_ACTION_DESIRE_HIGH=1;BOT_MODE_NONE=0
DAMAGE_TYPE_ALL=7;UNIT_LIST_ENEMY_HEROES=1;ABILITY_BEHAVIOR_IGNORE_CHANNEL=128
local enemies,allies,creeps,neutrals,actions,target={},{},{},{},{},nil
local Unit={};Unit.__index=Unit
local function unit(x,hp) return setmetatable({x=x,hp=hp or 1000,maxhp=1000,hero=true,mods={},valid=true},Unit) end
function Unit:GetLocation() return Vector(self.x,0,0) end
function Unit:GetExtrapolatedLocation(delay) self.lastDelay=delay;return Vector(self.x+(self.speed or 0)*delay,0,0) end
function Unit:GetHealth() return self.hp end
function Unit:GetMaxHealth() return self.maxhp end
function Unit:IsAlive() return self.valid and self.hp>0 end
function Unit:IsChanneling() return self.channel==true end
function Unit:IsCastingAbility() return self.casting==true end
function Unit:NumQueuedActions() return self.queued or 0 end
function Unit:IsSilenced() return self.silenced==true end
function Unit:IsStunned() return self.stunned==true end
function Unit:IsHexed() return self.hexed==true end
function Unit:IsNightmared() return self.nightmared==true end
function Unit:IsDisarmed() return self.disarmed==true end
function Unit:IsAttackImmune() return self.attackimmune==true end
function Unit:IsMagicImmune() return self.immune==true end
function Unit:IsIllusion() return self.illusion==true end
function Unit:HasModifier(n) return self.mods[n]==true end
function Unit:WasRecentlyDamagedByAnyHero() return self.recent==true end
function Unit:WasRecentlyDamagedByHero(enemy) return enemy.hurtBot==true end
function Unit:GetEstimatedDamageToTarget() return self.power or 100 end
setmetatable(bot,Unit)
function bot:GetAttackRange() return 475 end
function bot:GetMana() return 1000 end
function bot:GetNearbyCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
local spells={}
local function spell(name,range,values)
 local a={name=name,range=range or 0,values=values or {},ready=false,active=true,trained=true,behavior=0}
 function a:GetName() return self.name end
 function a:GetCastRange() return self.range end
 function a:GetCastPoint() return self.values.castpoint or 0 end
 function a:GetManaCost() return self.values.mana or 100 end
 function a:GetSpecialValueInt(k) return self.values[k] or 0 end
 function a:GetSpecialValueFloat(k) return self.values[k] or 0 end
 function a:IsTrained() return self.trained end
 function a:GetBehavior() return self.behavior end
 spells[name]=a;return a
end
local q=spell('dark_willow_bramble_maze',1000,{castpoint=0.3,initial_creation_delay=0.3,placement_range=500})
local w=spell('dark_willow_shadow_realm',0,{attack_range_bonus=600,max_damage_duration=3,duration=5})
w.behavior=ABILITY_BEHAVIOR_IGNORE_CHANNEL
local e=spell('dark_willow_cursed_crown',700,{castpoint=0.2,delay=4,stun_radius=360})
local d=spell('dark_willow_bedlam',0,{attack_radius=300,roaming_radius=200,target_count=1,roaming_duration=5.5})
local r=spell('dark_willow_terrorize',1200,{castpoint=1,destination_radius=450,destination_travel_speed=2000})
local lens
bot.GetAbilityByName=function(_,n) return ({A1=q,A2=w,A3=e,A4=r,A6=d})[n] or spells[n] end
local function action(a,t,shape) actions[#actions+1]={name=a.name,target=t,shape=shape} end
function bot:Action_UseAbility(a) action(a,nil,'none') end
function bot:Action_UseAbilityOnEntity(a,t) action(a,t,'unit') end
function bot:Action_UseAbilityOnLocation(a,t) action(a,t,'point') end
function GetUnitToUnitDistance(a,b) return math.abs(a.x-b.x) end
function GetUnitToLocationDistance(a,l) assert(getmetatable(a)==Unit,'engine unit handles cannot be synthetic locations');return math.abs(a.x-l.x) end
function GetUnitList() return enemies end
J.GetLocationToLocationDistance=function(a,b) return math.abs(a.x-b.x) end
J.GetLocationTowardDistanceLocation=function(u,l,dist) return Vector(u.x+(l.x>=u.x and dist or -dist),0,0) end
J.IsValid=function(u) return u~=nil and u.valid and not u.invulnerable and u.hp>0 end
J.IsValidHero=function(u) return J.IsValid(u) and u.hero end
J.CanCastOnNonMagicImmune=function(u) return J.IsValid(u) and not u.immune end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected end
J.IsInRange=function(a,b,range) return GetUnitToUnitDistance(a,b)<=range end
J.GetNearbyHeroes=function(u,range,enemy)
 local result={};for _,v in ipairs(enemy and enemies or allies) do if J.IsInRange(u,v,range) then result[#result+1]=v end end;return result
end
J.CanCastAbility=function(a) return a~=nil and a.ready and a.active and a.trained and not a.hidden and not a.passive end
J.CanNotUseAbility=function(u) return not u:IsAlive() or u:IsChanneling() or u:IsCastingAbility() or u:NumQueuedActions()>0
 or u:IsSilenced() or u:IsStunned() or u:IsHexed() or u:IsNightmared() end
J.CheckBitfieldFlag=function(value,flag) return math.floor(value/flag)%2==1 end
J.GetHP=function(u) return u.hp/u.maxhp end
J.IsProjectileIncoming=function(u) return u.projectile==true end
J.IsAttackProjectileIncoming=function(u) return u.attackProjectile==true end
J.GetProperTarget=function() return target end
J.IsAllowedToSpam=function(u) return u.spam~=false end
J.IsItemAvailable=function() return lens end
J.HasBreakModifier=function(u) return u.broken==true end
J.IsDisabled=function(u) return u.disabled==true end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.GetModifierTime=function(u,n) return u.modtimes and u.modtimes[n] or 0 end
for _,mode in ipairs({'GoingOnSomeone','InTeamFight','Retreating','Laning','Farming','Pushing','Defending'}) do
 J['Is'..mode]=function(u) return u.mode==mode end
end
local hero=H.load('npc_dota_hero_dark_willow','pos_4')
local copy=H.realDofile('bots/FunLib/rubick_hero/dark_willow.lua')
local function reset()
 enemies,allies,creeps,neutrals,actions,target={},{},{},{},{},nil;lens=nil;spells.rubick_arcane_supremacy=nil
 bot.x=0;bot.hp=1000;bot.maxhp=1000;bot.valid=true;bot.hero=true;bot.mods={};bot.mode=nil;bot.recent=false
 bot.channel=false;bot.casting=false;bot.queued=0;bot.silenced=false;bot.stunned=false;bot.hexed=false;bot.nightmared=false
 bot.disarmed=false;bot.immune=false;bot.projectile=false;bot.attackProjectile=false;bot.spam=true;bot.broken=false
 for _,a in pairs(spells) do a.ready=false;a.active=true;a.hidden=false end
 w.behavior=ABILITY_BEHAVIOR_IGNORE_CHANNEL
end
local function foe(x,hp) local u=unit(x,hp);enemies[#enemies+1]=u;return u end
local function friend(x,hp) local u=unit(x,hp);allies[#allies+1]=u;return u end
local function tick(stolen,a) actions={};if stolen then copy.ConsiderStolenSpell(a) else hero.SkillsComplement() end;return actions[1] end
for _,stolen in ipairs({false,true}) do
 reset();e.ready=true;target=foe(700);target.disabled=true;bot.mode='GoingOnSomeone'
 assert(tick(stolen,e).target==target,'Crown starts delayed follow-up on an already controlled target')
 target.x=701;assert(tick(stolen,e)==nil,'Crown never uses fake movement range')
 lens={};assert(tick(stolen,e),'Lens grants real Crown reach')
 lens=nil;target.x=940;local supremacy=spell('rubick_arcane_supremacy',0,{cast_range=240})
 assert(tick(stolen,e),'trained Supremacy grants range');bot.broken=true;assert(tick(stolen,e)==nil,'Break removes passive range')
 bot.broken=false;supremacy.trained=false;assert(tick(stolen,e)==nil,'untrained Supremacy has no range');target.x=600
 for _,flag in ipairs({'immune','blocked','reflected','illusion'}) do
  target[flag]=true;assert(tick(stolen,e)==nil,'Crown refuses '..flag);target[flag]=false
 end
 for _,mod in ipairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally','modifier_dark_willow_cursed_crown'}) do
  target.mods[mod]=true;assert(tick(stolen,e)==nil,'Crown refuses '..mod);target.mods[mod]=nil
 end
 reset();q.ready=true;target=foe(700);target.speed=100;bot.mode='GoingOnSomeone'
 local cast=tick(stolen,q);assert(cast.shape=='point' and cast.target.x==760,'Maze predicts cast plus growth delay')
 target.x=1400;target.speed=0;cast=tick(stolen,q);assert(cast.target.x==1000,'Maze edge zoning keeps center within legal range')
 target.x=1501;assert(tick(stolen,q)==nil,'Maze avoids targets outside placement footprint')
 reset();q.ready=true;e.ready=true;local channel=foe(600);channel.channel=true
 assert(tick(stolen,q)==nil and tick(stolen,e)==nil,'root and four-second Crown are not immediate channel interrupts')
 reset();q.ready=true;bot.mode='InTeamFight';foe(400);foe(600)
 assert(tick(stolen,q).shape=='point','Maze zones grouped opponents')
 reset();w.ready=true;bot.projectile=true
 assert(tick(stolen,w).shape=='none','Realm disjoints projectile before unrelated actions')
 bot.mods.modifier_dark_willow_shadow_realm_buff=true;assert(tick(stolen,w)==nil,'do not recast active Realm')
 reset();w.ready=true;bot.attackProjectile=true
 assert(tick(stolen,w)==nil,'a harmless lane attack does not spend defensive Realm')
 bot.hp=300;assert(tick(stolen,w),'Realm disjoints dangerous ranged attack at low health')
 reset();w.ready=true;bot.mode='GoingOnSomeone';target=foe(1075)
 assert(tick(stolen,w),'Realm prepares offensive hit at extended attack reach')
 target.x=1076;assert(tick(stolen,w)==nil,'Realm does not pretend its attack can reach farther')
 target.x=600;bot.disarmed=true;assert(tick(stolen,w)==nil,'disarmed caster cannot prepare offensive Realm attack')
 bot.projectile=true;assert(tick(stolen,w),'defensive Realm still works while disarmed')
 reset();w.ready=true;bot.mode='Retreating';bot.recent=true;foe(700)
 assert(tick(stolen,w),'Realm protects recent retreat')
 reset();d.ready=true;target=foe(300);bot.mode='GoingOnSomeone'
 cast=tick(stolen,d);assert(cast and cast.shape=='none' and cast.target==nil,'Bedlam casts on self using damage reach despite zero cast range')
 target.x=500;target.disabled=true;assert(tick(stolen,d),'Bedlam can exploit orbit edge against controlled isolated target')
 target.x=501;assert(tick(stolen,d)==nil,'Bedlam does not chase beyond orbit plus attack radius')
 target.x=400;target.disabled=false;assert(tick(stolen,d)==nil,'moving edge target does not justify Bedlam commit')
 target.x=200;creeps={unit(100),unit(200),unit(250)};assert(tick(stolen,d)==nil,'creep clutter prevents claiming isolated Bedlam burst')
 creeps={};bot.hp=300;assert(tick(stolen,d)==nil,'low exposed health avoids offensive Bedlam commit')
 bot.mods.modifier_dark_willow_shadow_realm_buff=true;assert(tick(stolen,d),'Realm protects close Bedlam commitment')
 d.active=false;assert(tick(stolen,d)==nil,'live activation prevents unavailable linked Bedlam')
 reset();d.ready=true;bot.mode='Farming';neutrals={unit(100),unit(200),unit(400)}
 assert(tick(stolen,d),'Bedlam efficiently farms nearby group without heroes')
 local two={neutrals[1],neutrals[2]};neutrals=two;creeps=two
 assert(tick(stolen,d)==nil,'overlapping nearby-creep and neutral lists never double-count camp')
 neutrals[#neutrals+1]=unit(400);creeps={}
 assert(tick(stolen,d),'three distinct neutrals justify farming Bedlam')
 foe(1200);assert(tick(stolen,d)==nil,'do not spend farming Bedlam near enemy heroes')
 reset();r.ready=true;channel=foe(1000);channel.channel=true;channel.speed=100;channel.blocked=true;channel.reflected=true
 cast=tick(stolen,r);assert(cast and cast.target.x==1150,'Terrorize predicts actual cast and flight for point channel interruption')
 assert(math.abs(channel.lastDelay-1.5)<0.0001,'Terrorize honors one-second cast plus flight')
 channel.mods.modifier_teleporting=true;channel.modtimes={modifier_teleporting=0.5};assert(tick(stolen,r)==nil,'Terrorize does not claim a too-late TP interrupt')
 channel.modtimes.modifier_teleporting=2;assert(tick(stolen,r),'Terrorize can catch TP with sufficient observed remaining time')
 bot.mods.modifier_dark_willow_bedlam=true;assert(tick(stolen,r)==nil,'observed Bedlam excludes Terrorize')
 reset();r.ready=true;bot.mode='InTeamFight';foe(1300);foe(1400)
 cast=tick(stolen,r);assert(cast and cast.target.x==1200,'cluster Fear uses real radius and legal cast center')
 enemies[2].immune=true;assert(tick(stolen,r)==nil,'immune hero cannot inflate Fear cluster')
 enemies[2].immune=false;for _,u in ipairs(enemies) do u.mods.modifier_dark_willow_debuff_fear=true end
 assert(tick(stolen,r)==nil,'do not waste Fear on already feared cluster')
 reset();r.ready=true;local saved=friend(500,300);saved.mode='Retreating';saved.recent=true;channel=foe(700);channel.chasing=saved
 assert(tick(stolen,r),'Terrorize can save any retreating ally against one pursuer')
 saved.valid=false;assert(tick(stolen,r)==nil,'invalid ally is not a save trigger')
 reset();r.ready=true;d.ready=true;bot.mode='GoingOnSomeone';target=foe(200);foe(400)
 if not stolen then assert(tick(stolen,r).name==r.name,'useful team Fear precedes committing Jex to Bedlam') end
 reset();w.ready=true;bot.channel=true;bot.projectile=true
 local X=stolen and copy or hero
 actions={};assert(X.UseShadowRealmDuringChannel() and #actions==1 and actions[1].shape=='none','explicit IGNORE_CHANNEL Realm is immediate and TP-safe')
 w.behavior=0;actions={};assert(not X.UseShadowRealmDuringChannel() and #actions==0,'missing live IGNORE_CHANNEL refuses channel exception')
 assert(tick(stolen,w)==nil,'normal dispatch also preserves channel when flag is absent')
 w.behavior=ABILITY_BEHAVIOR_IGNORE_CHANNEL
 for _,flag in ipairs({'casting','silenced','stunned','hexed','nightmared'}) do
  bot[flag]=true;actions={};assert(not X.UseShadowRealmDuringChannel() and #actions==0,'channel helper preserves '..flag);bot[flag]=false
 end
 bot.queued=1;actions={};assert(not X.UseShadowRealmDuringChannel() and #actions==0,'channel helper preserves queued action')
 bot.queued=0;bot.valid=false;assert(not X.UseShadowRealmDuringChannel(),'channel helper refuses dead caster')
end
reset();w.ready=true;q.ready=true;e.ready=true;d.ready=true;r.ready=true;bot.projectile=true;bot.mode='GoingOnSomeone';target=foe(200);foe(400)
hero.SkillsComplement();assert(#actions==1 and actions[1].name==w.name,'native dispatch issues only emergency Realm')
reset();w.ready=true;q.ready=true;e.ready=true;d.ready=true;bot.mode='GoingOnSomeone';target=foe(200)
hero.SkillsComplement();assert(#actions==1 and actions[1].name==e.name,'Crown begins four-second setup before burst')
e.ready=false;actions={};hero.SkillsComplement();assert(#actions==1 and actions[1].name==q.name,'Maze follows Crown setup')
q.ready=false;actions={};hero.SkillsComplement();assert(#actions==1 and actions[1].name==w.name,'Realm begins offensive charge before Bedlam')
w.ready=false;actions={};hero.SkillsComplement();assert(#actions==1 and actions[1].name==d.name,'Bedlam follows available setup without phantom startup timer')
reset();e.ready=true;bot.channel=true;target=foe(200);bot.mode='GoingOnSomeone';assert(tick(true,e)==nil,'stolen non-Realm spell never interrupts TP')
reset();d.ready=true;bot.mode='GoingOnSomeone';target=foe(200)
local saved=spells.dark_willow_terrorize;spells.dark_willow_terrorize=nil
assert(tick(true,d),'stolen Bedlam tolerates missing linked Terrorize handle');spells.dark_willow_terrorize=saved
print('Dark Willow ability scenarios passed')
