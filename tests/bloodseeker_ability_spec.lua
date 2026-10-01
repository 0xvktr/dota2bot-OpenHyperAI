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
local function record(a,t)
 actions[#actions+1]={name=a.name,target=t}
 if a.name=='bloodseeker_rupture' then t.mods.modifier_bloodseeker_rupture=true end
 if a.name=='bounty_hunter_track' then t.mods.modifier_bounty_hunter_track=true end
end
bot.ActionQueue_UseAbilityOnEntity=function(_,a,t) record(a,t) end
bot.Action_UseAbilityOnEntity=bot.ActionQueue_UseAbilityOnEntity
bot.ActionQueue_UseAbilityOnLocation=bot.ActionQueue_UseAbilityOnEntity
bot.Action_UseAbilityOnLocation=bot.ActionQueue_UseAbilityOnEntity
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
local q=ability('bloodseeker_bloodrage'); local w=ability('bloodseeker_blood_bath',1500,{radius=600,delay=2.6,damage=265})
local r=ability('bloodseeker_rupture',800,{castpoint=0.4});local mist=ability('bloodseeker_blood_mist',0,{radius=450})
local thirst=ability('bloodseeker_thirst');thirst.passive=true
bot.GetAbilityByName=function(_,n) return ({A1=q,A2=w,A3=thirst,A6=r})[n] or abilities[n] end
local hero=H.load('npc_dota_hero_bloodseeker','pos_1'); local copy=H.realDofile('bots/FunLib/rubick_hero/bloodseeker.lua')
local function tick(stolen,a) actions={};if stolen then copy.ConsiderStolenSpell(a) else hero.SkillsComplement() end;return actions[1] end
for _,stolen in ipairs({false,true}) do
 reset();target=unit(800);target.immune=true;target.disabled=true;enemies={target};bot.mode='GoingOnSomeone';r.castable=true
 assert(tick(stolen,r).target==target,'solo Rupture pierces immunity and permits ally control follow-through')
 target.mods={};target.x=801;assert(tick(stolen,r)==nil,'Rupture respects actual cast reach')
 target.x=800;target.mods.modifier_antimage_counterspell=true;assert(tick(stolen,r)==nil,'avoid Counterspell')
 target.mods={modifier_antimage_counterspell_ally=true};assert(tick(stolen,r)==nil,'avoid ally Counterspell reflection')
 target.mods={modifier_bloodseeker_rupture=true};assert(tick(stolen,r)==nil,'preserve charge on already Ruptured hero')
 reset();local enemy=unit(700);enemy.immune=true;enemy.recent=true;enemies={enemy};bot.mode='Retreating';r.castable=true
 assert(tick(stolen,r).target==enemy,'retreat Rupture stops immune pursuer')
 reset();target=unit(1400);target.speed=100;enemies={target};bot.mode='GoingOnSomeone';w.castable=true
 local act=tick(stolen,w);assert(act.target.x==1500,'Rite point clamped to legal range')
 assert(math.abs(target.predictionDelay-2.9)<0.001,'predict full cast plus detonation delay')
 target.speed=300;assert(tick(stolen,w)==nil,'reject predicted target beyond ritual edge')
 target.mods.modifier_bloodseeker_rupture=true;assert(tick(stolen,w).target.x==1400,'Rite covers stationary Rupture choice')
 reset();w.castable=true;bot.aoe={count=4,targetloc={x=500,y=0}}
 assert(tick(stolen,w)==nil,'idle mode must not waveclear through precedence bug')
 bot.mode='Pushing';assert(tick(stolen,w),'push mode permits clear')
 enemies={unit(1000)};assert(tick(stolen,w)==nil,'nearby enemy blocks unattended waveclear')
 reset();w.castable=true;bot.mode='Laning';local creep=unit(900,200);creep.hero=false;creep.ranged=true;creeps={creep};enemies={unit(1000)}
 assert(tick(stolen,w).target.x==900,'lane ranged creep plus contesting hero')
 assert(bot.killType==DAMAGE_TYPE_PURE,'Rite lethal check uses pure damage')
 reset();bot.scepter=true;bot.mode='GoingOnSomeone';target=unit(400);enemies={target};mist.castable=true
 assert(tick(stolen,mist).name==mist.name,'inactive Mist turns on near combat hero')
 mist.toggle=true;assert(tick(stolen,mist)==nil,'active Mist stays on near eligible enemy')
 bot.hp=200;assert(tick(stolen,mist),'critical HP stops Mist')
 reset();q.castable=true;bot.mode='Farming';bot.attacking=true;target=unit(200);target.hero=false
 assert(tick(stolen,q).name==q.name,'Bloodrage accelerates sustained farm')
 bot.mode='Retreating';assert(tick(stolen,q)==nil,'avoid self-drain when escaping')
end
reset();target=unit(500);enemies={target};bot.mode='GoingOnSomeone';q.castable=true;w.castable=true;r.castable=true
assert(tick(false,r).name==r.name,'native initiates Rupture first')
assert(tick(false,w).name==w.name,'native places Rite before self buff')
w.castable=false;assert(tick(false,q).name==q.name,'then buffs before Rite detonation')
thirst.castable=true;q.castable=false;assert(tick(false,thirst)==nil,'never issue passive Thirst cast')
print('Bloodseeker ability scenarios passed')
