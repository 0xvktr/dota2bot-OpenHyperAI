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
 function a:GetSpecialValueInt(k) return math.floor(self.values[k] or 0) end
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
local V={};V.__index=V
function V.__add(a,b) return Vector(a.x+b.x,a.y+b.y,0) end
function V.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,0) end
function V.__mul(a,b) return Vector(a.x*b,a.y*b,0) end
function V:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function Vector(x,y,z) return setmetatable({x=x,y=y,z=z},V) end
ATTRIBUTE_INTELLECT=2
function U:GetAttributeValue() return self.int or 100 end
function U:GetCurrentActiveAbility() return self.current end
function U:IsHero() return self.hero end
function U:IsBuilding() return self.building==true end
function GetUnitList(k) if k==UNIT_LIST_ALLIES then return units elseif k==UNIT_LIST_ENEMY_HEROES then return enemies end;local out={};for _,list in ipairs({enemies,creeps,neutrals}) do for _,u in ipairs(list) do out[#out+1]=u end end;return out end
J.HasBreakModifier=function(u) return u.broken==true end
J.WillKillTarget=function(u,d,k,delay) return J.CanKillTarget(u,d-(u.regen or 0)*delay-.801,k) end
local Q=spell('skywrath_mage_arcane_bolt',875,{bolt_damage=150,int_multiplier=1.5,bolt_speed=500,pierce_spell_immunity=0,castpoint=.1,mana=70})
local W=spell('skywrath_mage_concussive_shot',1600,{damage=300,launch_radius=1600,launch_global=0,speed=800,slow_radius=250,mana=95})
local E=spell('skywrath_mage_ancient_seal',850,{castpoint=.1,mana=110})
local R=spell('skywrath_mage_mystic_flare',1200,{radius=170,damage=1600,duration=2,castpoint=.1,mana=800})
local Native=H.load('skywrath_mage','pos_2');local Copy=H.realDofile('bots/FunLib/rubick_hero/skywrath_mage.lua')
local count=0
local function check(label,a,setup,expected,shape)
 for _,copied in ipairs({false,true}) do
  reset();bot.int=100;bot.broken=false;Q.values.pierce_spell_immunity=0;W.values.launch_global=0;bot.GetItemInSlot=function() return nil end
  setup();a.ready=true
  if copied then local used=Copy.ConsiderStolenSpell(a);assert(used==(#actions>0),label..' return') else Native.SkillsComplement() end
  assert(#actions<=1,label..' multiple');assert((#actions>0)==expected,label..' expected '..tostring(expected)..' got '..#actions)
  if shape and expected then assert(actions[1].shape==shape,label..' shape') end
  count=count+1
 end
end
check('bolt base int kill',Q,function() foe(800,290) end,true,'unit')
check('bolt real slow flight regeneration',Q,function() local u=foe(800,290);u.regen=10 end,false)
check('bolt shard not triple damage',Q,function() bot.shard=true;foe(800,600) end,false)
check('bolt actual range',Q,function() target=foe(876);bot.mode='GoingOnSomeone' end,false)
check('bolt current pierce talent',Q,function() target=foe(800);target.immune=true;bot.mode='GoingOnSomeone';Q.values.pierce_spell_immunity=1 end,true)
check('bolt without pierce talent',Q,function() target=foe(800);target.immune=true;bot.mode='GoingOnSomeone' end,false)
check('concussive nearest actual hero',W,function() target=foe(1000);foe(300);bot.mode='GoingOnSomeone' end,false)
check('concussive target closest',W,function() foe(1000);target=foe(300);bot.mode='GoingOnSomeone' end,true,'none')
check('concussive invisible hero ignored',W,function() local u=foe(300);u.invisible=true;target=foe(1000);bot.mode='GoingOnSomeone' end,true)
check('concussive real projectile regeneration',W,function() local u=foe(1500,290);u.regen=10 end,false)
check('concussive no lens acquisition extension',W,function() target=foe(1700);bot.mode='GoingOnSomeone';local lens=spell('item_aether_lens',0,{cast_range_bonus=250});bot.GetItemInSlot=function(_,slot) return slot==0 and lens end end,false)
check('concussive actual global talent',W,function() target=foe(6000);bot.mode='GoingOnSomeone';W.values.launch_global=1 end,true)
check('seal control overlap still amps',E,function() target=foe(800);target.silenced=true;target.stunned=true;bot.mode='GoingOnSomeone';Q.ready=true;bot.mana=1000 end,true,'unit')
check('seal duplicate declined',E,function() target=foe(800);target.mods.modifier_skywrath_mage_ancient_seal=true;bot.mode='GoingOnSomeone' end,false)
check('seal reflected target',E,function() target=foe(800);target.reflected=true;bot.mode='GoingOnSomeone' end,false)
check('human seal peel',E,function() local a=friend(600,300);a.recent=true;local u=foe(800);u.attackTarget=a end,true)
check('flare actual hold',R,function() target=foe(1100);target.mods.modifier_rod_of_atos_debuff=true;target.modtimes={modifier_rod_of_atos_debuff=2};bot.mode='GoingOnSomeone' end,true,'point')
check('flare mobile full damage not guaranteed',R,function() foe(1100,500) end,false)
check('flare only first tick on mobile',R,function() foe(1100,75) end,true)
check('flare remaining hold not full duration',R,function() local u=foe(1100,500);u.mods.modifier_stunned=true;u.modtimes={modifier_stunned=.4} end,false)
check('flare split damage',R,function() local u=foe(1100,1000);u.mods.modifier_stunned=true;u.modtimes={modifier_stunned=2.2};foe(1150,1000) end,false)
check('flare one held hero kill',R,function() local u=foe(1100,1000);u.mods.modifier_stunned=true;u.modtimes={modifier_stunned=2.2} end,true)
check('flare regen entire hold',R,function() local u=foe(1100,1590);u.mods.modifier_stunned=true;u.modtimes={modifier_stunned=2.2};u.regen=10 end,false)
check('flare spirit bear not damage divisor',R,function() local u=foe(1100,1000);u.mods.modifier_stunned=true;u.modtimes={modifier_stunned=2.2};local bear=foe(1150);bear.name='npc_dota_lone_druid_bear' end,true)
check('flare radius plus range bounded',R,function() target=foe(1300);target.mods.modifier_stunned=true;target.modtimes={modifier_stunned=2.2};bot.mode='GoingOnSomeone' end,true,'point')
check('flare beyond actual coverage',R,function() target=foe(1371);target.mods.modifier_stunned=true;target.modtimes={modifier_stunned=2.2};bot.mode='GoingOnSomeone' end,false)
check('flare reflected collateral',R,function() target=foe(1100);target.mods.modifier_stunned=true;target.modtimes={modifier_stunned=2.2};bot.mode='GoingOnSomeone';local u=foe(1150);u.mods.modifier_item_blade_mail_reflect=true end,false)
check('unrelated channel lock',Q,function() bot.channel=true;target=foe(800);bot.mode='GoingOnSomeone' end,false)
check('queued actor lock',R,function() bot.queued=1;foe(1100,75) end,false)
check('documented illusion erasure',R,function() bot.mode='InTeamFight';for i=1,4 do local u=foe(1000+i*10);u.illusion=true end end,true,'point')
check('single illusion not expensive flare',R,function() bot.mode='InTeamFight';local u=foe(1000);u.illusion=true end,false)
reset();W.ready=true;bot.mode='Farming';for i=1,3 do local u=unit(300+i*10);u.hero=false;creeps[#creeps+1]=u end;Native.SkillsComplement();assert(#actions==1 and actions[1].name==W.name);count=count+1
reset();Q.ready=true;bot.mode='Laning';local c=unit(700,290);c.hero=false;c.name='npc_dota_creep_ranged';creeps={c};Native.SkillsComplement();assert(#actions==1 and actions[1].name==Q.name);count=count+1
reset();spells[Q.name]=nil;E.ready=true;target=foe(800);target.silenced=true;bot.mode='GoingOnSomeone';assert(not Copy.ConsiderStolenSpell(E) and #actions==0);spells[Q.name]=Q;count=count+1
local getBot=GetBot;GetBot=function() error('unknown actor lookup') end;assert(Copy.ConsiderStolenSpell(spell('unknown'))==nil);GetBot=getBot;count=count+1
print('Skywrath Mage ability spec passed: '..count..' scenarios')
