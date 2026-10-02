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
function U:IsHero() return self.hero end
function U:GetNearbyTowers() return {} end
function U:GetModifierByName(name) if self.mods[name] then self.lastModifier=name;return 1 end;return -1 end
function U:GetModifierSourceAbility(index) return self.cleanseSource or self.sources and self.sources[self.lastModifier] end
function U:NumModifiers() return self.cleanseSource and 1 or 0 end
function U:GetModifierStackCount(index) return self.stacks and self.stacks[self.lastModifier] or 0 end
function U:GetModifierRemainingDuration(index) return self.times and self.times[self.lastModifier] or 10 end
J.HasBreakModifier=function() return bot.broken==true end
J.WillKillTarget=function(u,d,k,delay) return J.CanKillTarget(u,d-(u.regen or 0)*delay-.801,k) end
J.GetEnemiesNearLoc=function(loc,r) local out={};for _,u in ipairs(enemies) do if distance(loc,u)<=r then out[#out+1]=u end end;return out end
local D=spell('shadow_demon_disruption',675,{disruption_duration=2.75,castpoint=.3,mana=120})
local A=spell('shadow_demon_disseminate',925,{radius=675,reflection_pct=40,castpoint=.3,mana=100})
local P=spell('shadow_demon_shadow_poison',1500,{speed=1200,radius=200,hit_damage=60,stack_damage=60,max_multiply_stacks=5,bonus_stack_damage=60,castpoint=.25,mana=40})
local R=spell('shadow_demon_shadow_poison_release',0,{castpoint=.3,mana=0})
local ULT=spell('shadow_demon_demonic_purge',800,{purge_damage=600,castpoint=.3,mana=200})
function ULT:GetDuration() return 5 end
local C=spell('shadow_demon_demonic_cleanse',800,{purge_damage=450,castpoint=.3,mana=150})
local lens=spell('item_aether_lens',0,{cast_range_bonus=225})
local native=H.load('npc_dota_hero_shadow_demon','pos_5')
local copied=H.realDofile('bots/FunLib/rubick_hero/shadow_demon.lua')
local M=require('bots/FunLib/shadow_demon_abilities')
local count=0
local function fresh() reset();bot.broken=false;bot.GetItemInSlot=function() return nil end;P.cooldown=0;spells.shadow_demon_shadow_poison=P;units={} end
local function ally(x,hp) local u=friend(x,hp);units[#units+1]=u;return u end
local function mark(u,n,time,source) u.mods.modifier_shadow_demon_shadow_poison=true;u.sources={modifier_shadow_demon_shadow_poison=source or P};u.stacks={modifier_shadow_demon_shadow_poison=n};u.times={modifier_shadow_demon_shadow_poison=time or 10} end
local function tick(a,copy) if copy then local used=copied.ConsiderStolenSpell(a);assert(used==(#actions>0),'canonical copied return') else native.SkillsComplement() end;assert(#actions<=1,'one action per tick');return actions[1] end
local function check(label,fn) local ok,err=pcall(fn);assert(ok,label..': '..tostring(err));count=count+1 end
for _,copy in ipairs({false,true}) do
 local pre=copy and 'copied ' or 'native '
 check(pre..'Disruption save human allies at exact range with actual Lens',function() fresh();D.ready=true;local u=ally(675,300);u.recent=true;foe(500).attackTarget=u;assert(tick(D,copy).target==u);actions={};u.x=676;assert(not tick(D,copy));bot.GetItemInSlot=function(_,s) return s==0 and lens or nil end;assert(tick(D,copy)) end)
 check(pre..'Disruption rejects immune allies and healthy channel interruption',function() fresh();D.ready=true;local u=ally(600,300);u.recent=true;u.immune=true;foe(500).attackTarget=u;assert(not tick(D,copy));u.immune=false;u.channel=true;assert(not tick(D,copy));u.mods.modifier_legion_commander_duel=true;assert(tick(D,copy)) end)
 check(pre..'Disruption interrupts enemies without casting through Linken',function() fresh();D.ready=true;foe(600).channel=true;assert(tick(D,copy));actions={};enemies[1].blocked=true;assert(not tick(D,copy)) end)
 check(pre..'Cleanse needs live Shard handle and does not promise stun dispel',function() fresh();C.ready=true;local u=ally(700);u.stunned=true;assert(not tick(C,copy));u.stunned=false;u.silenced=true;assert(tick(C,copy).target==u);actions={};C.hidden=true;assert(not tick(C,copy));C.hidden=false;C.active=false;assert(not tick(C,copy)) end)
 check(pre..'Cleanse works on immune allies but not Doom and Hex alone',function() fresh();C.ready=true;local u=ally(700);u.immune=true;u.rooted=true;assert(tick(C,copy));actions={};u.mods.modifier_doom_bringer_doom=true;assert(not tick(C,copy));u.mods={};u.rooted=false;u.hexed=true;assert(not tick(C,copy)) end)
 check(pre..'Disseminate supports attacked human frontline with real nearby enemies',function() fresh();A.ready=true;local u=ally(800);u.human=true;foe(900).attackTarget=u;foe(1000);assert(tick(A,copy).target==u);actions={};u.mods.modifier_shadow_demon_disseminate=true;assert(not tick(A,copy)) end)
 check(pre..'Poison predicts full flight and respects exact max range',function() fresh();P.ready=true;bot.mode='GoingOnSomeone';target=foe(1200);target.speed=100;assert(tick(P,copy).target.x==1325);actions={};target.x=1450;assert(not tick(P,copy)) end)
 check(pre..'Poison impact kill excludes stacked damage and regeneration',function() fresh();P.ready=true;local u=foe(1000,100);assert(not tick(P,copy));u.hp=59;u.regen=5;assert(not tick(P,copy));u.hp=40;assert(tick(P,copy)) end)
 check(pre..'Release accurate exponential formula and extra stacks',function() fresh();R.ready=true;local u=foe(400,250);mark(u,3);assert(not tick(R,copy));u.hp=230;assert(tick(R,copy));actions={};u.hp=1100;mark(u,7);assert(tick(R,copy));assert(not J.WillKillTarget(u,1080,DAMAGE_TYPE_MAGICAL,.3)) end)
 check(pre..'Release checks own source and never assumes missing Poison sibling',function() fresh();R.ready=true;local u=foe(400,100);mark(u,5,10,{});assert(not tick(R,copy));mark(u,5);spells.shadow_demon_shadow_poison=nil;assert(not tick(R,copy));spells.shadow_demon_shadow_poison=P;P.hidden=true;assert(not tick(R,copy)) end)
 check(pre..'Release global range and impending natural expiry',function() fresh();R.ready=true;local u=foe(5000,1000);mark(u,2,.4);assert(tick(R,copy));actions={};u.times.modifier_shadow_demon_shadow_poison=2;assert(not tick(R,copy)) end)
 check(pre..'Release holds a confirmed own pending impact but rejects canceled intent',function() fresh();R.ready=true;local u=foe(1200,2000);mark(u,5);M.RecordPoison(bot,P,u:GetLocation());P.cooldown=2;assert(not tick(R,copy));P.cooldown=0;assert(tick(R,copy));actions={};P.cooldown=2;now=now+2;assert(tick(R,copy)) end)
 check(pre..'Purge uses delayed damage with regen and actual debuff immune cast',function() fresh();ULT.ready=true;local u=foe(700,590);u.regen=10;assert(not tick(ULT,copy));u.hp=500;assert(tick(ULT,copy));actions={};u.immune=true;bot.mode='GoingOnSomeone';target=u;assert(tick(ULT,copy)) end)
 check(pre..'Purge avoids own duplicated effect but permits foreign source',function() fresh();ULT.ready=true;bot.mode='GoingOnSomeone';target=foe(700);target.mods.modifier_shadow_demon_purge_slow=true;target.sources={modifier_shadow_demon_purge_slow=ULT};assert(not tick(ULT,copy));target.sources.modifier_shadow_demon_purge_slow={};assert(tick(ULT,copy)) end)
 check(pre..'Documented own Disruption accepts Poison and Purge but not unrelated invulnerability',function() fresh();P.ready=true;bot.mode='GoingOnSomeone';target=foe(700);target.invulnerable=true;target.mods.modifier_shadow_demon_disruption=true;target.sources={modifier_shadow_demon_disruption=D};assert(tick(P,copy));actions={};P.ready=false;ULT.ready=true;assert(tick(ULT,copy));actions={};target.sources.modifier_shadow_demon_disruption={IsNull=function() return false end,GetName=function() return 'other_spell' end};assert(not tick(ULT,copy)) end)
 check(pre..'Normal locks remain and upgrades are not silently assumed',function() for _,flag in ipairs({'channel','casting','using','queued','silenced','stunned','hexed','nightmared'}) do fresh();P.ready=true;bot.mode='GoingOnSomeone';target=foe(600);bot[flag]=flag=='queued' and 1 or true;assert(not tick(P,copy)) end end)
end
check('native save precedes enemy interrupt and Poison spam',function() fresh();D.ready=true;P.ready=true;bot.mode='GoingOnSomeone';target=foe(600);target.channel=true;local u=ally(650);u.mods.modifier_enigma_black_hole_pull=true;assert(tick(D,false).target==u) end)
check('native Release precedes Poison when lethal and farm remains',function() fresh();R.ready=true;P.ready=true;bot.mode='GoingOnSomeone';target=foe(700,100);mark(target,3);assert(tick(R,false).name==R.name);fresh();P.ready=true;bot.mode='Defending';for i=1,3 do local u=unit(300+i*20);u.hero=false;creeps[#creeps+1]=u end;assert(tick(P,false)) end)
check('copied unknown returns before any bot lookup',function() local saved=GetBot;GetBot=function() error('unknown') end;assert(copied.ConsiderStolenSpell({GetName=function() return 'other_spell' end})==nil);GetBot=saved end)
check('Cleanse observed source avoids own active refresh but not another caster',function() fresh();C.ready=true;local u=ally(700);u.silenced=true;u.cleanseSource=C;assert(not tick(C,false));u.cleanseSource={};assert(tick(C,false)) end)
print('Shadow Demon ability scenarios passed: '..count)
