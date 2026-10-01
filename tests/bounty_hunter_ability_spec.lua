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
local q=ability('bounty_hunter_shuriken_toss',525,{bonus_damage=310,bounce_aoe=1200,speed=1000})
local w=ability('bounty_hunter_jinada',150);local e=ability('bounty_hunter_wind_walk')
local r=ability('bounty_hunter_track',1000);local friendly=ability('bounty_hunter_wind_walk_ally',650)
bot.GetAbilityByName=function(_,n) return ({A1=q,A2=w,A3=e,A6=r})[n] or abilities[n] end
local hero=H.load('npc_dota_hero_bounty_hunter','pos_4'); local copy=H.realDofile('bots/FunLib/rubick_hero/bounty_hunter.lua')
local function tick(stolen,a) actions={};if stolen then copy.ConsiderStolenSpell(a) else hero.SkillsComplement() end;return actions[1] end
for _,stolen in ipairs({false,true}) do
 reset();r.castable=true;local low=unit(500,100);local tracked=unit(700);tracked.mods.modifier_bounty_hunter_track=true;local high=unit(800,800);high.immune=true;enemies={low,tracked,high}
 assert(tick(stolen,r).target==low,'tracked hero must not reset lowest-health selection')
 low.mods.modifier_bounty_hunter_track=true;assert(tick(stolen,r).target==high,'Track pierces immunity')
 high.mods={modifier_antimage_counterspell=true};assert(tick(stolen,r)==nil,'avoid reflected Track')
 high.mods={modifier_antimage_counterspell_ally=true};assert(tick(stolen,r)==nil,'avoid allied reflected Track')
 high.mods={};high.x=1001;assert(tick(stolen,r)==nil,'Track legal range boundary')
 reset();q.castable=true;bot.mode='GoingOnSomeone';target=unit(1600);target.mods.modifier_bounty_hunter_track=true;enemies={target}
 local wrong=unit(-500);wrong.hero=false;local good=unit(500);good.hero=false;creeps={wrong,good}
 assert(tick(stolen,q).target==good,'bounce only through nearby reachable launch unit')
 good.mods={modifier_antimage_counterspell_ally=true};assert(tick(stolen,q)==nil,'avoid ally Counterspell on bounce launch unit')
 good.mods={};target.mods.modifier_antimage_counterspell_ally=true;assert(tick(stolen,q)==nil,'avoid ally Counterspell on tracked bounce recipient')
 target.mods.modifier_antimage_counterspell_ally=nil
 good.x=399;assert(tick(stolen,q)==nil,'no bounce when 1201 gap exceeds radius')
 good.x=526;assert(tick(stolen,q)==nil,'no cast outside direct range')
 reset();q.castable=true;bot.mode='GoingOnSomeone';local first=unit(500);local bridge=unit(1600);target=unit(2700)
 bridge.mods.modifier_bounty_hunter_track=true;target.mods.modifier_bounty_hunter_track=true;enemies={first,bridge,target}
 assert(tick(stolen,q).target==first,'tracked chain can reach beyond initial bounce')
 bridge.mods={};assert(tick(stolen,q)==nil,'untracked intermediate cannot relay bounce')
 reset();q.castable=true;bot.mode='GoingOnSomeone';target=unit(500);enemies={target}
 target.mods.modifier_antimage_counterspell_ally=true;assert(tick(stolen,q)==nil,'avoid ally Counterspell on direct Shuriken target')
 target.mods={};assert(tick(stolen,q).target==target,'direct Shuriken after protection expires')
 reset();q.castable=true;target=unit(500);target.channel=true;enemies={target}
 assert(tick(stolen,q)==nil,'current slow does not falsely interrupt channel')
 target.hp=250;assert(tick(stolen,q).target==target,'lethal Shuriken still punishes channel')
 reset();q.castable=true;bot.invis=true;bot.mode='GoingOnSomeone';target=unit(150);target.mods.modifier_bounty_hunter_track=true;enemies={target}
 assert(tick(stolen,q)==nil,'preserve invisible attack stun on nonlethal Toss')
 target.hp=250;assert(tick(stolen,q),'lethal Toss may break invisibility')
 reset();q.castable=true;bot.mode='Laning';target=unit(500);enemies={target}
 assert(tick(stolen,q).target==target,'lane harass when mana permits')
 bot.spam=false;assert(tick(stolen,q)==nil,'conserve mana instead of lane harass')
 reset();e.castable=true;bot.mode='InEnemyArea';bot.mana=280
 assert(tick(stolen,e).name==e.name,'scouting uses absolute mana not fractional mana')
 bot.invis=true;assert(tick(stolen,e)==nil,'do not refresh active invisibility')
 reset();friendly.castable=true;local init=unit(200);init.mode='GoingOnSomeone';local save=unit(300);save.mode='Retreating';save.recent=true;allies={init,save}
 assert(tick(stolen,friendly).target==save,'Friendly Shadow prioritizes retreat save over initiator')
 save.invis=true;assert(tick(stolen,friendly).target==init,'then help approaching initiator')
 init.attacking=true;assert(tick(stolen,friendly)==nil,'avoid invisibility cast immediately broken by ally attack')
 reset();w.castable=true;bot.mode='Laning';target=unit(150);target.immune=true
 assert(tick(stolen,w).name==w.name,'manual Jinada targets immune lane opponent')
 bot.mods.modifier_break=true;assert(tick(stolen,w)==nil,'break suppresses Jinada priority')
end
reset();bot.invis=true;bot.mode='GoingOnSomeone';target=unit(150);enemies={target};q.castable=true;e.castable=true;r.castable=true;w.castable=true
assert(tick(false,r).name==r.name,'Track before invisible opening')
assert(tick(false,w).name==w.name,'tracked opening uses Jinada attack instead of nonlethal Toss')
print('Bounty Hunter ability scenarios passed')
