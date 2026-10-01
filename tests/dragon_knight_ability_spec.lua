-- Offline native/copy scenarios with observed state and real cast classes.
local H=dofile('tests/hero_harness.lua');local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0;BOT_ACTION_DESIRE_HIGH=1;BOT_MODE_NONE=0
DAMAGE_TYPE_ALL=7;DAMAGE_TYPE_MAGICAL=2;DAMAGE_TYPE_PHYSICAL=1;UNIT_LIST_ENEMY_HEROES=1
local enemies,allies,creeps,neutrals,alliedCreeps,actions,target={},{},{},{},{},{},nil
local Unit={};Unit.__index=Unit
local function unit(x,hp,y) return setmetatable({x=x,y=y or 0,hp=hp or 1000,maxhp=1000,hero=true,mods={},valid=true},Unit) end
function Unit:GetLocation() return Vector(self.x,self.y,0) end
function Unit:GetExtrapolatedLocation(delay) self.lastDelay=delay;return Vector(self.x+(self.speed or 0)*delay,self.y,0) end
function Unit:GetHealth() return self.hp end
function Unit:GetMaxHealth() return self.maxhp end
function Unit:GetHealthRegen() return self.regen or 0 end
function Unit:GetActualIncomingDamage(damage) return damage * (self.resistance and 1-self.resistance or 1) end
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
function Unit:IsBuilding() return self.building==true end
function Unit:IsInvisible() return self.invisible==true end
function Unit:HasModifier(n) return self.mods[n]==true end
function Unit:WasRecentlyDamagedByAnyHero() return self.recent==true end
function Unit:WasRecentlyDamagedByHero(enemy) return enemy.hurtBot==true end
function Unit:GetEstimatedDamageToTarget() return self.power or 100 end
setmetatable(bot,Unit)
function bot:GetAttackRange() return self.attackRange end
function bot:GetAttackDamage() return 100 end
function bot:GetMana() return self.mana end
function bot:HasScepter() return self.scepter==true end
function bot:GetCurrentActiveAbility() return self.current end
function bot:GetNearbyCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:GetNearbyLaneCreeps(_,enemy) return enemy and creeps or alliedCreeps end
local spells={}
local function spell(name,range,values)
 local a={name=name,range=range or 0,values=values or {},ready=false,active=true,trained=true,level=2}
 function a:GetName() return self.name end
 function a:GetCastRange() return self.range end
 function a:GetCastPoint() return self.values.castpoint or 0 end
 function a:GetManaCost() return self.values.mana or 100 end
 function a:GetSpecialValueInt(k) return self.values[k] or 0 end
 function a:GetSpecialValueFloat(k) return self.values[k] or 0 end
 function a:IsTrained() return self.trained end
 function a:GetLevel() return self.level end
 spells[name]=a;return a
end
local lens
bot.GetAbilityByName=function(_,n) return spells[n] end
local function action(a,t,shape) actions[#actions+1]={name=a.name,target=t,shape=shape} end
function bot:Action_UseAbility(a) action(a,nil,'none') end
function bot:Action_UseAbilityOnEntity(a,t) action(a,t,'unit') end
function bot:Action_UseAbilityOnLocation(a,t) action(a,t,'point') end
local function distance(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
function GetUnitToUnitDistance(a,b) return distance(a,b) end
function GetUnitToLocationDistance(a,l) assert(getmetatable(a)==Unit,'location cannot impersonate an engine unit');return distance(a,l) end
function GetUnitList() return enemies end
J.GetLocationToLocationDistance=distance
J.GetLocationTowardDistanceLocation=function(u,l,dist)
 local v=u:GetLocation();local d=distance(v,l);return Vector(v.x+(l.x-v.x)*dist/d,v.y+(l.y-v.y)*dist/d,0)
end
J.IsValid=function(u) return u~=nil and u.valid and not u.invulnerable and not u.building and u.hp>0 end
J.IsValidBuilding=function(u) return u~=nil and u.valid and not u.invulnerable and u.building and u.hp>0 end
J.IsValidHero=function(u) return J.IsValid(u) and u.hero end
J.CanCastOnNonMagicImmune=function(u) return J.IsValid(u) and not u.immune and not u.forbidden end
J.CanCastOnMagicImmune=function(u) return J.IsValid(u) and not u.forbidden end
J.IsInEtherealForm=function(u) return u.ethereal==true or u.mods.modifier_necrolyte_sadist_active==true end
J.CanBeAttacked=function(u) return (J.IsValid(u) or J.IsValidBuilding(u)) and not u.attackimmune and not J.IsInEtherealForm(u) and not u.forbidden end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected end
J.IsInRange=function(a,b,range) return distance(a,b)<=range end
J.GetNearbyHeroes=function(u,range,enemy)
 local result={};for _,v in ipairs(enemy and enemies or allies) do if J.IsInRange(u,v,range) then result[#result+1]=v end end;return result
end
J.CanCastAbility=function(a) return a~=nil and a.ready and a.active and a.trained and not a.hidden and not a.passive end
J.CanNotUseAbility=function(u) return not u:IsAlive() or u:IsChanneling() or u:IsCastingAbility() or u:NumQueuedActions()>0
 or u:IsSilenced() or u:IsStunned() or u:IsHexed() or u:IsNightmared() end
J.CannotBeKilled=function(_,u) return u.protected==true end
J.GetHP=function(u) return u.hp/u.maxhp end
J.GetProperTarget=function() return target end
J.IsAllowedToSpam=function(u) return u.spam~=false end
J.IsItemAvailable=function() return lens end
J.HasBreakModifier=function(u) return u.broken==true end
J.IsDisabled=function(u) return u.disabled==true end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.GetModifierTime=function(u,n) return u.modtimes and u.modtimes[n] or 0 end
J.IsRoshan=function(u) return u.roshan==true end
J.IsTormentor=function(u) return u.tormentor==true end
J.CanKillTarget=function(u,damage,kind)
 if kind==DAMAGE_TYPE_MAGICAL and u.immune or kind==DAMAGE_TYPE_PHYSICAL and (u.ethereal or u.attackimmune) then return false end
 return damage*(u.resistance and 1-u.resistance or 1)>=u.hp
end
for _,mode in ipairs({'GoingOnSomeone','InTeamFight','Retreating','Laning','Farming','Pushing','Defending'}) do
 J['Is'..mode]=function(u) return u.mode==mode end
end
local function reset()
 enemies,allies,creeps,neutrals,alliedCreeps,actions,target={},{},{},{},{},{},nil;lens=nil;spells.rubick_arcane_supremacy=nil
 bot.x=0;bot.y=0;bot.hp=1000;bot.maxhp=1000;bot.valid=true;bot.hero=true;bot.mods={};bot.mode=nil;bot.recent=false
 bot.channel=false;bot.casting=false;bot.queued=0;bot.silenced=false;bot.stunned=false;bot.hexed=false;bot.nightmared=false
 bot.disarmed=false;bot.immune=false;bot.spam=true;bot.broken=false;bot.mana=1000;bot.scepter=false;bot.invisible=false;bot.current=nil
 for _,a in pairs(spells) do a.ready=false;a.active=true;a.hidden=false;a.trained=true;a.level=2 end
end
local function foe(x,hp,y) local u=unit(x,hp,y);enemies[#enemies+1]=u;return u end
local function friend(x,hp) local u=unit(x,hp);allies[#allies+1]=u;return u end
local function creep(x,hp,y) local u=unit(x,hp,y);u.hero=false;return u end

local q=spell('dragon_knight_breathe_fire',1000,{castpoint=0.2,speed=1050,damage=320,start_radius=150,end_radius=250,mana=100})
local w=spell('dragon_knight_dragon_tail',150,{damage=150,projectile_speed=1600,mana=100})
local d=spell('dragon_knight_fireball',600,{castpoint=0.2,radius=275,damage=85,duration=6,mana=80})
local r=spell('dragon_knight_elder_dragon_form',0,{bonus_attack_range=350,bonus_ability_cast_range=350,mana=50})
local hero=H.load('npc_dota_hero_dragon_knight','pos_3')
local copy=H.realDofile('bots/FunLib/rubick_hero/dragon_knight.lua')
local function tick(stolen,a) actions={};if stolen then copy.ConsiderStolenSpell(a) else hero.SkillsComplement() end;return actions[1] end
for _,stolen in ipairs({false,true}) do
 reset();bot.attackRange=150;w.ready=true;target=foe(150);bot.mode='GoingOnSomeone'
 assert(tick(stolen,w).target==target,'Tail has actual human reach')
 target.x=151;assert(tick(stolen,w)==nil,'Tail cannot borrow movement allowance')
 bot.mods.modifier_dragon_knight_dragon_form=true;target.x=500
 assert(tick(stolen,w),'Dragon Form grants 350 cast reach')
 target.x=501;assert(tick(stolen,w)==nil,'Form does not grant obsolete extra Tail reach')
 lens={GetSpecialValueInt=function() return 225 end};target.x=725;assert(tick(stolen,w),'Lens adds real reach');target.x=726;assert(tick(stolen,w)==nil,'Lens boundary')
 lens=nil;target.x=740;local supremacy=spell('rubick_arcane_supremacy',0,{cast_range=240})
 assert(tick(stolen,w),'trained Supremacy extends spell reach');bot.broken=true;assert(tick(stolen,w)==nil,'Break removes passive reach')
 bot.broken=false;supremacy.trained=false;assert(tick(stolen,w)==nil,'untrained passive gives no reach');target.x=100
 for _,flag in ipairs({'immune','blocked','reflected','illusion'}) do target[flag]=true;assert(tick(stolen,w)==nil,'Tail refuses '..flag);target[flag]=false end
 for _,mod in ipairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally'}) do
  target.mods[mod]=true;assert(tick(stolen,w)==nil,'Tail rejects '..mod);target.mods[mod]=nil
 end
 target.ethereal=true;assert(tick(stolen,w),'magical Tail works against ethereal hero');target.ethereal=false
 reset();bot.attackRange=150;w.ready=true;local enemy=foe(100);enemy.channel=true
 assert(tick(stolen,w),'urgent Tail interrupts without aggressive mode')
 if not stolen then q.ready=true;r.ready=true;target=enemy;bot.mode='GoingOnSomeone';assert(tick(stolen,w).name==w.name,'Tail interrupt precedes transform and nuke') end
 reset();bot.attackRange=500;bot.mods.modifier_dragon_knight_dragon_form=true;w.ready=true;enemy=foe(500);enemy.channel=true
 enemy.mods.modifier_teleporting=true;enemy.modtimes={modifier_teleporting=0.2}
 assert(tick(stolen,w)==nil,'projectile Tail does not promise too-late TP interruption')
 enemy.modtimes.modifier_teleporting=0.4;assert(tick(stolen,w),'observed remaining TP time permits Tail')
 reset();bot.attackRange=150;w.ready=true;local ally=friend(120,300);ally.mode='Retreating';ally.recent=true;enemy=foe(130);enemy.chasing=ally
 assert(tick(stolen,w).target==enemy,'Tail protects retreating ally');enemy.disabled=true;assert(tick(stolen,w)==nil,'ordinary Tail avoids disable overlap')
 reset();bot.attackRange=150;q.ready=true;target=foe(1000,250);target.blocked=true;target.reflected=true;target.ethereal=true
 local cast=tick(stolen,q);assert(cast and cast.shape=='point','point Breathe Fire ignores spell reflection and attack immunity')
 target.protected=true;assert(tick(stolen,q)==nil,'death prevention removes false Fire lethal');target.protected=false
 target.hp=310;target.regen=20;assert(tick(stolen,q)==nil,'Fire travel-time regeneration removes false lethal');target.hp=250;target.regen=0
 target.x=1001;assert(tick(stolen,q)==nil,'Breathe Fire respects actual live reach')
 bot.mods.modifier_dragon_knight_dragon_form=true;target.x=1350;assert(tick(stolen,q),'Form also extends Breathe Fire')
 target.x=1351;assert(tick(stolen,q)==nil,'Form Fire range boundary')
 reset();bot.attackRange=150;q.ready=true;bot.mode='GoingOnSomeone';target=foe(700);target.speed=105
 cast=tick(stolen,q);assert(cast and math.abs(cast.target.x-791)<0.001,'Breathe Fire predicts cast point and travel')
 reset();bot.attackRange=150;q.ready=true;bot.mode='InTeamFight';foe(500);foe(800,nil,200)
 assert(tick(stolen,q),'cone includes distant forward cluster');enemies[2].y=400;assert(tick(stolen,q)==nil,'radial proximity cannot substitute for cone geometry')
 reset();bot.attackRange=150;q.ready=true;bot.mode='Farming';creeps={creep(500),creep(700),creep(900)}
 assert(tick(stolen,q),'Fire clears three aligned creeps');creeps[3].y=400;assert(tick(stolen,q)==nil,'outside-cone creep cannot inflate clear')
 reset();bot.attackRange=150;q.ready=true;bot.mode='Laning';creeps={creep(700,250)}
 assert(tick(stolen,q),'Fire secures inaccessible spell last hit');creeps[1].hp=500;assert(tick(stolen,q)==nil,'single healthy creep does not justify Fire')
 reset();bot.attackRange=500;d.ready=true;bot.mode='GoingOnSomeone';target=foe(875);target.disabled=true
 cast=tick(stolen,d);assert(cast and cast.target.x==600 and cast.shape=='point','Fireball clamps cast center while zone reaches edge')
 target.x=876;assert(tick(stolen,d)==nil,'Fireball footprint boundary');bot.mods.modifier_dragon_knight_dragon_form=true;target.x=1225
 assert(tick(stolen,d).target.x==950,'Form extends Fireball cast center as well')
 target.x=600;target.disabled=false;bot.attackRange=150;assert(tick(stolen,d)==nil,'do not claim full persistent damage on escaping edge target')
 target.hp=50;bot.mode=nil;assert(tick(stolen,d)==nil,'DOT is not treated as instant kill')
 reset();bot.attackRange=150;d.ready=true;bot.mode='Farming';local group={creep(400),creep(500)};creeps=group;neutrals=group
 assert(tick(stolen,d)==nil,'merged nearby and neutral handles do not double count');neutrals={group[1],group[2],creep(600)}
 assert(tick(stolen,d),'Fireball clears three distinct camp units');foe(1200);assert(tick(stolen,d)==nil,'farm zone held near enemies')
 reset();bot.attackRange=150;r.ready=true;bot.mode='GoingOnSomeone';target=foe(500)
 assert(tick(stolen,r).shape=='none','Form prepares real extended attack or Tail reach');target.x=501;assert(tick(stolen,r)==nil,'Form does not activate for unreachable chase')
 target.x=400;bot.disarmed=true;assert(tick(stolen,r)==nil,'no offensive Form while disarmed');bot.disarmed=false
 bot.mods.modifier_dragon_knight_dragon_form=true;assert(tick(stolen,r)==nil,'no repeated transform in active Form')
 reset();bot.attackRange=150;r.ready=true;bot.mode='Pushing';target=creep(400);target.building=true
 assert(tick(stolen,r)==nil,'tower pressure needs allied wave, not enemy creeps');alliedCreeps={creep(300)}
 assert(tick(stolen,r),'allied wave permits sustained Form tower pressure')
 reset();bot.attackRange=150;r.ready=true;bot.mode='Farming';neutrals={creep(200),creep(300),creep(400)}
 assert(tick(stolen,r),'higher-level Form can accelerate safe group farm');r.level=1;assert(tick(stolen,r)==nil,'first Form lacks splash farm benefit')
 r.level=2;foe(1000);assert(tick(stolen,r)==nil,'save Form near opponents')
 reset();bot.attackRange=150;q.ready=true;w.ready=true;d.ready=true;r.ready=true;target=foe(100);bot.mode='GoingOnSomeone';bot.channel=true
 for _,a in ipairs({q,w,d,r}) do assert(tick(stolen,a)==nil,'all DK spells preserve unrelated channel') end
 bot.channel=false;bot.queued=1;assert(tick(stolen,q)==nil,'queued actions preserved')
end
assert(copy.ConsiderStolenSpell(spell('unrelated_spell'))==nil,'unsupported spell keeps generic dispatch')
print('Dragon Knight ability scenarios passed')
