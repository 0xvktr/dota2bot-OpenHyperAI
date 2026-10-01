local H=dofile('tests/hero_harness.lua'); local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0; BOT_MODE_LANING=1
DAMAGE_TYPE_PURE=4; DAMAGE_TYPE_PHYSICAL=1; DAMAGE_TYPE_MAGICAL=2; UNIT_LIST_ENEMY_HEROES=1
local enemies,allies,creeps,actions,target={},{},{},{},nil
local manaItem
function bot:GetItemInSlot(slot) return slot==0 and manaItem or nil end
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
 function a:IsNull() return false end
 function a:IsHidden() return self.hidden==true end
 function a:IsPassive() return self.passive==true end
 function a:IsActivated() return true end
 function a:GetCooldownTimeRemaining() return self.cd or (self.castable and 0 or 1) end
 function a:IsFullyCastable() return self.castable and self:GetManaCost()<=bot:GetMana() end
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
 manaItem=nil;bot.ohaManaCastIntent=nil;bot.using=false;bot.team=2
 bot.x=0;bot.hp=1000;bot.maxHp=1000;bot.mods={};bot.valid=true;bot.hero=true;bot.mode=nil;bot.channel=false;bot.invis=false;bot.scepter=false;bot.mana=1000;bot.spam=true;bot.aoe=nil;bot.attacking=false;bot.recent=false;bot.disarmed=false
 for _,a in pairs(abilities) do a.castable=false;a.toggle=false;a.cd=nil end
end

function U:IsRooted() return self.rooted==true end
function U:IsAlive() return self.valid end
function U:IsStunned() return self.stunned==true end
function U:IsHexed() return false end
function U:IsMuted() return false end
function U:IsSilenced() return false end
function U:IsNightmared() return false end
function U:IsUsingAbility() return self.using==true end
function U:GetTeam() return self.team or 3 end
function U:IsCastingAbility() return self.casting==true end
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
local originalReset=reset
reset=function()
 originalReset();bot.rooted=false;bot.stunned=false;bot.casting=false;bot.queued=0;bot.projectile=false;bot.immune=false;bot.tower=false;bot.barracks=false
end

local q=ability('chaos_knight_chaos_bolt',600,{damage_min=180,damage_max=410,chaos_bolt_speed=900,castpoint=0.4})
local w=ability('chaos_knight_reality_rift',750,{pierces_immunity=0})
local r=ability('chaos_knight_phantasm');r.GetManaCost=function() return 300 end
q.GetManaCost=function() return 110 end;w.GetManaCost=function() return 50 end
bot.GetAbilityByName=function(_,n) return ({A1=q,A2=w,A6=r})[n] or abilities[n] end
local hero=H.load('npc_dota_hero_chaos_knight','pos_1');local copy=H.realDofile('bots/FunLib/rubick_hero/chaos_knight.lua')
local function tick(stolen,a) actions={};if stolen then copy.ConsiderStolenSpell(a) else hero.SkillsComplement() end;return actions[1] end
for _,stolen in ipairs({false,true}) do
 reset();q.castable=true;target=unit(600,200);enemies={target}
 assert(tick(stolen,q)==nil,'random maximum damage cannot guarantee kill')
 target.hp=170;target.disabled=true;assert(tick(stolen,q).target==target,'minimum Bolt can kill disabled target')
 assert(bot.killDamage==180 and math.abs(bot.killDelay-(0.4+600/900))<0.001,'minimum roll and projectile delay')
 target.x=601;assert(tick(stolen,q)==nil,'Bolt cannot cast outside actual reach')
 reset();q.castable=true;target=unit(600);target.channel=true;enemies={target}
 assert(tick(stolen,q).target==target,'interrupt channel at Bolt range')
 target.mods={modifier_antimage_counterspell=true};assert(tick(stolen,q)==nil,'avoid reflected Bolt')
 target.mods={modifier_antimage_counterspell_ally=true};assert(tick(stolen,q)==nil,'avoid allied reflected Bolt')
 reset();w.castable=true;target=unit(750);target.immune=true;target.disabled=true;bot.mode='GoingOnSomeone'
 assert(tick(stolen,w)==nil,'base Rift does not pierce immunity')
 w.values.pierces_immunity=1;assert(tick(stolen,w).target==target,'actual Rift talent pierces immunity and follows allied control')
 target.x=751;assert(tick(stolen,w)==nil,'Rift obeys legal range')
 target.x=750;bot.rooted=true;assert(tick(stolen,w)==nil,'root disables Rift')
 bot.rooted=false;target.mods={modifier_antimage_counterspell_ally=true};assert(tick(stolen,w)==nil,'avoid allied reflected Rift')
 w.values.pierces_immunity=0
 reset();w.castable=true;bot.mode='DoingRoshan';bot.attacking=true;target=unit(600);target.hero=false;target.roshan=true
 assert(tick(stolen,w).target==target,'objective Rift supplies selected entity')
 reset();r.castable=true;bot.rooted=true;assert(tick(stolen,r).name==r.name,'Phantasm basic dispel response')
 bot.rooted=false;bot.projectile=true;assert(tick(stolen,r),'reactive Phantasm projectile avoidance')
 reset();r.castable=true;bot.mode='Farming';bot.attacking=true;local ancient=unit(300,2000);ancient.hero=false;ancient.ancient=true;creeps={ancient}
 assert(tick(stolen,r).name==r.name,'Phantasm farms large ancient camp')
 enemies={unit(1000)};assert(tick(stolen,r)==nil,'do not spend farming ultimate near potential fight')
 reset();r.castable=true;q.castable=true;w.castable=true;bot.mode='GoingOnSomeone';target=unit(500);bot.mana=400
 if stolen then assert(tick(true,r)==nil,'Phantasm reserves follow-up mana') else assert(hero.ConsiderR()==0,'native Phantasm reserves follow-up mana') end
 bot.mana=460;assert((stolen and tick(true,r) or hero.ConsiderR())~=nil,'sufficient combo mana permits setup')
end
reset();q.castable=true;w.castable=true;r.castable=true;target=unit(550);target.channel=true;enemies={target};bot.mode='GoingOnSomeone'
assert(tick(false,q).name==q.name,'urgent interrupt precedes Phantasm')
reset();q.castable=true;w.castable=true;r.castable=true;target=unit(700);enemies={target};bot.mode='GoingOnSomeone'
assert(tick(false,r).name==r.name,'Phantasm before committing illusion burst')
r.castable=false;assert(tick(false,w).name==w.name,'Rift initiates beyond Bolt reach')
target.x=400;target.disabled=false;assert(tick(false,q).name==q.name,'Bolt locks enemy once in range')
-- Rebased item policy must preserve a useful low-mana Bolt without issuing an unaffordable cast.
local P=require('bots/FunLib/item_cast_policy')
reset();q.cd=0;bot.mana=20;bot.mode='GoingOnSomeone';target=unit(400);target.channel=true;enemies={target}
local mango=ability('item_enchanted_mango',0,{replenish_amount=100});mango.GetManaCost=function() return 0 end;mango.castable=true;manaItem=mango
assert(tick(false,q)==nil and P.Intent(bot,J).ability==q,'selected low-mana Bolt publishes validated enabling-item intent')
local oldTarget=target;target=unit(450);enemies={target}
assert(P.Intent(bot,J)==nil,'changed actual target invalidates old restoration intent')
target=oldTarget;enemies={target};bot.mana=110;q.castable=true
assert(tick(false,q).target==target and bot.ohaManaCastIntent==nil,'after restoration native reconsiders and casts actual Bolt target')
reset();q.cd=0;bot.mana=100;bot.mode='GoingOnSomeone';target=unit(400);target.channel=true;enemies={target};w.castable=true
assert(tick(false,w).name==w.name and bot.ohaManaCastIntent==nil,'unaffordable Bolt without restoration does not block useful Rift')
reset();q.castable=true;target=unit(400);target.channel=true;enemies={target};bot.queued=1
assert(tick(false,q)==nil,'Power Treads lock preserves existing queued actions')
print('Chaos Knight ability scenarios passed')
