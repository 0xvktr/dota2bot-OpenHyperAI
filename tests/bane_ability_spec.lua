local H=dofile('tests/hero_harness.lua');local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0;BOT_ACTION_DESIRE_HIGH=1;BOT_MODE_NONE=0;DAMAGE_TYPE_PURE=4;DAMAGE_TYPE_PHYSICAL=1;DAMAGE_TYPE_ALL=0;UNIT_LIST_ENEMY_HEROES=1
local enemies,allies,creeps,actions,target={},{},{},{},nil;local now=0
DotaTime=function() return now end
GetUnitList=function() return enemies end
local U={};U.__index=U
local function unit(x,hp) return setmetatable({x=x,hp=hp or 1000,maxHp=1000,mods={},valid=true,team=3},U) end
function U:CanBeSeen() return self.valid end
function U:IsInvulnerable() return self.invul==true end
function U:IsMagicImmune() return self.immune==true end
function U:IsChanneling() return self.channel==true end
function U:IsCastingAbility() return self.casting==true end
function U:IsUsingAbility() return self.using==true end
function U:NumQueuedActions() return self.queue or 0 end
function U:IsDisarmed() return false end
function U:HasModifier(n) return self.mods[n]==true end
function U:GetTeam() return self.team end
function U:GetHealth() return self.hp end
function U:GetMaxHealth() return self.maxHp end
function U:GetAttackDamage() return 100 end
function U:GetEstimatedDamageToTarget() return self.power or 100 end
function U:GetLocation() return {x=self.x,y=0} end
function U:IsInvisible() return false end
function U:WasRecentlyDamagedByAnyHero() return self.recent==true end
setmetatable(bot,U)
local abilities={}
for _,n in ipairs({'bane_enfeeble','bane_brain_sap','bane_nightmare','bane_fiends_grip','bane_nightmare_end'}) do
 local a={name=n,castable=false,range=n=='bane_nightmare' and 700 or 625,radius=0}
 function a:GetName() return self.name end
 function a:IsFullyCastable() return self.castable end
 function a:GetLevel() return 4 end
 function a:GetCastRange() return self.range end
 function a:GetCastPoint() return 0.2 end
 function a:GetManaCost() return 150 end
 function a:GetChannelTime() return 4.75 end
 function a:GetSpecialValueInt(k) return ({brain_sap_damage=300,fiend_grip_damage=70,shard_radius=self.radius})[k] or 0 end
 function a:GetSpecialValueFloat(k) return k=='nightmare_invuln_time' and 1 or 0 end
 abilities[n]=a
end
local talent={IsTrained=function() return false end}
bot.GetAbilityByName=function(_,n) return ({A1=abilities.bane_enfeeble,A2=abilities.bane_brain_sap,A3=abilities.bane_nightmare,A6=abilities.bane_fiends_grip})[n] or abilities[n] or (n:sub(1,1)=='T' and talent or nil) end
function bot:GetLevel() return 20 end
function bot:GetMana() return 1000 end
function bot:GetMaxMana() return 1000 end
function bot:GetNearbyCreeps() return creeps end
function bot:ActionQueue_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u};if a.name=='bane_nightmare' then u.mods.modifier_bane_nightmare=true end end
function bot:Action_UseAbility(a) actions[#actions+1]={name=a.name} end
J.IsValid=function(u) return u~=nil and u.valid end;J.IsValidHero=J.IsValid
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.IsInRange=function(a,b,r) return a and b and math.abs(a.x-b.x)<=r end
J.GetAroundEnemyHeroList=function(r) local l={};for _,e in ipairs(enemies) do if J.IsInRange(bot,e,r) then l[#l+1]=e end end;return l end
J.GetAlliesNearLoc=function() local l={};for _,a in ipairs(allies) do l[#l+1]=a end;return l end
J.GetProperTarget=function() return target end;J.GetHP=function(u) return u.hp/u.maxHp end;J.GetMP=function() return 1 end
J.IsItemAvailable=function() return nil end;J.CanNotUseAbility=function() return bot.channel or bot.mods.modifier_bane_nightmare end
J.IsDisabled=function(u) return u.disabled or u.mods.modifier_bane_nightmare or u.mods.modifier_bane_fiends_grip end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked end
J.IsUnitTargetProjectileIncoming=function(u) return u.projectile==true end
J.CannotBeKilled=function(_,u) return u.protected==true end
J.CanKillTarget=function(u,d,t) return u.hp<=d end
J.WillKillTarget=function(u,d,t) assert(t==DAMAGE_TYPE_PURE,'Sap must estimate pure damage');return u.hp<=d end
J.SetQueuePtToINT=function() end;J.SetQueueToInvisible=function() end
for _,n in ipairs({'GoingOnSomeone','InTeamFight','Retreating','Farming','Pushing','Defending'}) do J['Is'..n]=function() return bot.mode==n end end
J.IsDoingRoshan=function() return false end;J.IsDoingTormentor=function() return false end;J.IsAttacking=function() return true end
J.IsChasingTarget=function() return true end;J.IsAllowedToSpam=function() return true end
local hero=H.load('npc_dota_hero_bane','pos_5');local stolen=H.realDofile('bots/FunLib/rubick_hero/bane.lua')
local function reset()
 now=now+10;enemies,allies,creeps,actions,target={},{},{},{},nil
 bot.valid=true;bot.x=0;bot.hp=1000;bot.maxHp=1000;bot.mods={};bot.team=2;bot.mode=nil;bot.channel=false;bot.recent=false;bot.projectile=false;bot.casting=false;bot.using=false;bot.queue=0
 for _,a in pairs(abilities) do a.castable=false;a.radius=0 end
end
local function tick(copy,n) actions={};if copy then stolen.ConsiderStolenSpell(abilities[n]) else hero.SkillsComplement() end;return actions[1] end
local sap,sleep,grip,q='bane_brain_sap','bane_nightmare','bane_fiends_grip','bane_enfeeble'
for _,copy in ipairs({false,true}) do
 reset();target=unit(600,250);target.immune=true;enemies={target};abilities[sap].castable=true
 assert(tick(copy,sap).target==target,'pure Sap kills through immunity')
 target.x=626;assert(tick(copy,sap)==nil,'Sap cannot cast outside legal reach')
 target.x=600;target.mods.modifier_antimage_counterspell=true;assert(tick(copy,sap)==nil,'avoid reflected Sap')
 reset();target=unit(600);target.immune=true;target.channel=true;enemies={target};abilities[grip].castable=true
 assert(tick(copy,grip).target==target,'Grip interrupts immune channel')
 target.channel=false;target.hp=400;assert(tick(copy,grip)==nil,'rank one Grip duration is 4.75, not fixed6')
 target.hp=300;assert(tick(copy,grip),'actual-duration lethal Grip')
 reset();target=unit(500);enemies={target};bot.mode='GoingOnSomeone';abilities[sleep].castable=true
 local second=unit(600);second.power=300;enemies={target,second}
 assert(tick(copy,sleep).target==second,'sleep the second enemy instead of kill target')
 reset();local ally=unit(300,200);ally.team=2;ally.projectile=true;allies={ally};abilities[sleep].castable=true
 assert(tick(copy,sleep).target==ally,'projectile save uses allied invulnerability')
 abilities.bane_nightmare_end.castable=true;now=now+0.5;assert(tick(copy,sleep)==nil,'preserve first invulnerable second')
 now=now+0.9;assert(tick(copy,sleep).name=='bane_nightmare_end','release ally after invulnerability')
 reset();local delayed=unit(300,200);delayed.team=2;delayed.projectile=true;allies={delayed};abilities[sleep].castable=true
 assert(tick(copy,sleep).target==delayed,'prepare delayed Nightmare save')
 delayed.projectile=false;abilities.bane_nightmare_end.castable=true;now=now+2
 delayed.mods.modifier_bane_nightmare_invulnerable=true
 assert(tick(copy,sleep)==nil,'elapsed enqueue timer cannot end active invulnerability')
 delayed.mods.modifier_bane_nightmare_invulnerable=nil
 assert(tick(copy,sleep).name=='bane_nightmare_end','release after actual invulnerability expires')
 for _,condition in ipairs({'channel','casting','using','queue'}) do
  reset();local saved=unit(300,200);saved.team=2;saved.projectile=true;allies={saved};abilities[sleep].castable=true
  assert(tick(copy,sleep).target==saved,'prepare ally save before ongoing cast')
  saved.projectile=false;abilities.bane_nightmare_end.castable=true;now=now+1.4
  if condition=='queue' then bot.queue=1 else bot[condition]=true end
  assert(tick(copy,sleep)==nil,'defer End during '..condition)
  assert(saved.mods.modifier_bane_nightmare,'saved ally remains asleep while cast completes')
  bot.channel=false;bot.casting=false;bot.using=false;bot.queue=0
  assert(tick(copy,sleep).name=='bane_nightmare_end','release after current cast completes')
 end
 reset();bot.hp=200;bot.projectile=true;abilities[sleep].castable=true
 assert(tick(copy,sleep).target==bot,'self Nightmare save')
 bot.projectile=false;abilities.bane_nightmare_end.castable=true;now=now+1.4
 assert(tick(copy,sleep).name=='bane_nightmare_end','self Nightmare wake remains allowed before normal gate')
 reset();target=unit(100);local isolated=unit(625);local clustered=unit(600);enemies={target,isolated,clustered};bot.mode='InTeamFight';abilities[sap].castable=true;abilities[sap].radius=100
 assert(tick(copy,sap).target~=target,'Shard chooses cluster over isolated hero')
 isolated.mods.modifier_bane_nightmare=true;assert(tick(copy,sap).target==target,'preserve secondary enemy sleep from Sap splash')
 reset();target=unit(400);enemies={target};target.mods.modifier_antimage_counterspell=true;bot.mode='GoingOnSomeone';abilities[q].castable=true
 assert(tick(copy,q)==nil,'avoid reflected Enfeeble')
 target.mods={modifier_bane_enfeeble_effect=true};assert(tick(copy,q)==nil,'current Enfeeble effect prevents redundant cast')
 target.mods={};assert(tick(copy,q).target==target,'cast Enfeeble after effect expires')
end
reset();target=unit(600);enemies={target};bot.mode='GoingOnSomeone'
for _,a in pairs(abilities) do a.castable=true end
assert(tick(false,grip).name==grip,'Grip takes priority over nonlethal Sap and Enfeeble')
bot.channel=true;assert(tick(false,grip)==nil,'preserve native Grip channel')
reset();target=unit(200);local second=unit(300);enemies={target,second};bot.mode='GoingOnSomeone'
for _,a in pairs(abilities) do a.castable=true end
assert(tick(false,sleep).target==second,'native sleeps second hero first')
assert(tick(false,grip).name==grip and actions[1].target==target,'native follows sleep with Grip on kill target')
reset();target=unit(300,250);enemies={target};bot.mode='GoingOnSomeone'
abilities[sap].castable=true;abilities[grip].castable=true
assert(tick(false,sap).name==sap,'immediate Sap kill avoids unnecessary long Grip')
print('Bane ability scenarios passed')
