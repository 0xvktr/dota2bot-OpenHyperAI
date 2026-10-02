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
function U:GetAttackRange() return self.attackRange or 150 end
function bot:GetNearbyTrees() return self.trees or {} end
function bot:Action_UseAbilityOnTree(a,t) action(a,t,'tree') end
function GetTreeLocation(id) return ({[1]=Vector(-800,0,0),[2]=Vector(700,0,0),[3]=Vector(-800,900,0)})[id] end
function IsLocationPassable() return true end
J.GetTeamFountain=J.GetEscapeLoc
J.GetEnemiesNearLoc=function(p,r) local out={};for _,e in ipairs(enemies) do if distance(p,e)<=r then out[#out+1]=e end end;return out end
J.GetAlliesNearLoc=function() return allies end
J.HasBreakModifier=function() return false end
J.IsEnemyBlackHoleInLocation=function() return false end
J.IsEnemyChronosphereInLocation=function() return false end
J.IsRealInvisible=function(u) return u.invisible end
J.IsInLaningPhase=function() return false end
J.GetManaAfter=function(cost) return (bot.mana-cost)/1000 end
J.IsThereNonSelfCoreNearby=function() return false end
J.IsRunning=function() return false end
J.IsKeyWordUnit=function(_,u) return u.ranged==true end
function bot:GetAbilityPoints() return 0 end
J.Chat={GetNormName=function() return 'enemy' end}
local switch=spell('kez_switch_weapons',0,{})
local q=spell('kez_echo_slash',0,{katana_distance=800,katana_radius=200,katana_echo_damage=80,echo_hero_damage=40,katana_strikes=2,castpoint=0.2})
local w=spell('kez_grappling_claw',950,{})
local e=spell('kez_kazurai_katana',200,{})
local r=spell('kez_raptor_dance',0,{radius=450,base_damage=70,max_health_damage_pct=2.5,strikes=4,castpoint=1})
local f=spell('kez_falcon_rush',0,{rush_range=525})
local t=spell('kez_talon_toss',750,{damage=120,radius=0})
local p=spell('kez_shodo_sai',0,{parry_duration=1.5})
local c=spell('kez_shodo_sai_parry_cancel',0,{})
local v=spell('kez_ravens_veil',0,{blast_radius=1500})
local hero=dofile('bots/BotLib/hero_kez.lua');local copy=dofile('bots/FunLib/rubick_hero/kez.lua')
local function tick(stolen,a)
 actions={};if stolen then local handled=copy.ConsiderStolenSpell(a);assert(handled==(actions[1]~=nil),'canonical handled result') else hero.SkillsComplement() end
 assert(#actions<=1,'no blind queue or second action');return actions[1]
end
for _,stolen in ipairs({false,true}) do
 reset();r.ready=true;target=foe(300,500);target.maxhp=10000
 assert(tick(stolen,r)==nil,'pure 320 first hit is not fictional percent or attack damage kill')
 target.hp=300;target.immune=true;assert(tick(stolen,r).name==r.name,'correct pure max-health damage pierces immunity')
 reset();r.ready=true;target=foe(300,70);target.speed=300
 assert(tick(stolen,r)==nil,'one second cast predicts target leaving real radius')
 reset();r.ready=true;target=foe(300,1000);bot.mode='GoingOnSomeone';bot.hp=400
 assert(tick(stolen,r).name==r.name,'use Raptor healing in actual circle');bot.mods.modifier_ice_blast=true
 assert(tick(stolen,r)==nil,'Ice Blast suppresses healing-only dance');bot.rooted=true
 assert(tick(stolen,r),'Raptor basic dispel remains useful when rooted')
 reset();t.ready=true;target=foe(700,1000);target.channel=true
 assert(tick(stolen,t).target==target,'physical Toss interrupts single channel with zero splash radius')
 target.immune=true;assert(tick(stolen,t)==nil,'Toss cannot target debuff immunity');target.immune=false;target.ethereal=true
 assert(tick(stolen,t)==nil,'physical Toss cannot hurt ethereal');target.ethereal=false;target.blocked=true
 assert(tick(stolen,t)==nil,'Toss respects spell block');target.blocked=false;target.x=751
 assert(tick(stolen,t)==nil,'Toss exact range excludes old 1200 range')
 reset();e.ready=true;target=foe(190,1000);bot.mode='GoingOnSomeone';target.immune=true
 assert(tick(stolen,e).target==target,'Katana active impales without native passive or fictional stack damage');target.x=210
 assert(tick(stolen,e)==nil,'Katana actual active cast range')
 reset();q.ready=true;target=foe(600,180)
 assert(tick(stolen,q)==nil,'Echo cannot assume delayed second slash kill');target.hp=110
 assert(tick(stolen,q).name==q.name,'Echo actual first attack damage');bot.disarmed=true
 assert(tick(stolen,q)==nil,'Echo requires attacks');bot.disarmed=false;target.x=810
 assert(tick(stolen,q)==nil,'Echo fixed slash reach is not padded')
 reset();f.ready=true;target=foe(500);bot.mode='GoingOnSomeone'
 assert(tick(stolen,f).name==f.name,'Falcon closes actual rush distance');bot.rooted=true
 assert(tick(stolen,f)==nil,'Falcon root forbids rush');bot.rooted=false;bot.mods.modifier_bloodseeker_rupture=true
 assert(tick(stolen,f)==nil,'Falcon does not move under Rupture');bot.mods={modifier_kez_falcon_rush=true}
 assert(tick(stolen,f)==nil,'preserve live Falcon buff')
 reset();p.ready=true;target=foe(400);target.attackRange=600;target.attackTarget=bot
 assert(tick(stolen,p).shape=='point','Parry aims at actual ranged attacker without nearby allies');target.attackTarget=target
 assert(tick(stolen,p)==nil,'do not lock facing against unrelated enemy')
 reset();c.ready=true;bot.mode='Retreating';bot.mods.modifier_kez_shodo_sai_parry=true
 assert(tick(stolen,c).name==c.name,'cancel observed parry when attackers gone');target=foe(200);target.attackTarget=bot
 assert(tick(stolen,c)==nil,'preserve parry against actual attacks');bot.mods={};enemies={}
 assert(tick(stolen,c)==nil,'missing observed parry cannot cancel')
 reset();v.ready=true;target=foe(800);bot.mode='Retreating';bot.recent=true
 assert(tick(stolen,v).name==v.name,'Veil basic dispel and invisibility escape');bot.mods.modifier_kez_ravens_veil_buff=true
 assert(tick(stolen,v)==nil,'live Veil is not refreshed')
 reset();w.ready=true;target=foe(940);bot.mode='GoingOnSomeone'
 assert(tick(stolen,w).shape=='unit','Claw real unit shape');target.reflected=true
 assert(tick(stolen,w)==nil,'Claw respects reflect');target.reflected=false;bot.rooted=true
 assert(tick(stolen,w)==nil,'Claw root forbidden');bot.rooted=false;bot.mods.modifier_bloodseeker_rupture=true
 assert(tick(stolen,w)==nil,'Claw Rupture forbidden')
 reset();w.ready=true;bot.mode='Retreating';bot.recent=true;bot.trees={1,2,3};target=foe(300)
 assert(tick(stolen,w).target==1 and actions[1].shape=='tree','actual baseward 45 degree tree avoids opposite/sideways trees');bot.trees={2,3}
 assert(tick(stolen,w)==nil,'no false radian escape candidate');bot.trees={}
end
reset();q.hidden=true;f.hidden=false;hero.SkillsComplement();assert(bot.kez_mode=='sai','native mode follows engine visibility')
q.hidden=false;f.hidden=true;hero.SkillsComplement();assert(bot.kez_mode=='katana','manual toggles cannot desynchronize mode')
reset();bot.scepter=true;f.ready=true;v.ready=true;switch.ready=true;q.ready=true;w.ready=true;target=foe(500);bot.mode='GoingOnSomeone'
assert(tick(false,f) and #actions==1,'Scepter still observes each ability rather than queuing speculative combo')
local gate=J.CanNotUseAbility;J.CanNotUseAbility=function() error('unknown queried gate') end
assert(copy.ConsiderStolenSpell({GetName=function() return 'unknown_spell' end})==nil);J.CanNotUseAbility=gate
print('Kez ability scenarios passed')
