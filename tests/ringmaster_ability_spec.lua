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

UNIT_LIST_NEUTRAL_CREEPS=4
function GetUnitList(kind) return kind==UNIT_LIST_ALLIES and units or kind==UNIT_LIST_NEUTRAL_CREEPS and neutrals or enemies end
function U:GetNearbyTowers() return {} end
function U:IsBuilding() return self.building==true end
function U:GetBoundingRadius() return self.bounding or 24 end
function bot:IsMuted() return self.muted==true end
J.HasBreakModifier=function() return bot.broken==true end
J.WillKillTarget=function(u,d,k,delay) return J.CanKillTarget(u,d-(u.regen or 0)*delay-.801,k) end
J.GetEnemiesNearLoc=function(loc,r) local out={};for _,u in ipairs(enemies) do if distance(loc,u)<=r then out[#out+1]=u end end;return out end
local W=spell('ringmaster_tame_the_beasts',700,{end_width=200,start_width=450,damage_min=125,damage_max=480,crack_duration=.2,mana=135})
function W:GetChannelTime() return 1 end
local C=spell('ringmaster_tame_the_beasts_crack')
local B=spell('ringmaster_the_box',600,{mana=120})
local D=spell('ringmaster_impalement',2400,{damage_impact=65,bleed_duration=4,bleed_health_pct=6,dagger_speed=1350,dagger_width=130,dagger_pass_through=0,castpoint=.3,mana=50})
local ULT=spell('ringmaster_wheel',1400,{min_range=700,mesmerize_radius=500,projectile_speed=1200,castpoint=.2,mana=300})
local S=spell('ringmaster_spotlight',1500,{radius=275,castpoint=.5,mana=50})
local mirror=spell('ringmaster_funhouse_mirror');local tonic=spell('ringmaster_strongman_tonic',750)
local cushion=spell('ringmaster_whoopee_cushion');local cycle=spell('ringmaster_summon_unicycle')
local lens=spell('item_aether_lens',0,{cast_range_bonus=225})
local native=H.load('npc_dota_hero_ringmaster','pos_4')
local copied=H.realDofile('bots/FunLib/rubick_hero/ringmaster.lua')
local M=require('bots/FunLib/ringmaster_abilities')
local count=0
local function fresh()
 reset();bot.muted=false;bot.broken=false;bot.GetItemInSlot=function() return nil end
 D.values.dagger_pass_through=0;spells.ringmaster_tame_the_beasts=W
end
local function tick(a,copy)
 if copy then local used=copied.ConsiderStolenSpell(a);assert(used==(#actions>0),'canonical copied return') else native.SkillsComplement() end
 assert(#actions<=1,'one spell per tick');return actions[1]
end
local function check(label,fn) local ok,err=pcall(fn);assert(ok,label..': '..tostring(err));count=count+1 end
for _,copy in ipairs({false,true}) do
 local pre=copy and 'copied ' or 'native '
 check(pre..'Escape saves endangered human allies within actual range',function() fresh();B.ready=true;local ally=friend(600,300);ally.recent=true;ally.human=true;foe(500).attackTarget=ally;assert(tick(B,copy).target==ally);actions={};ally.x=601;assert(not tick(B,copy));bot.GetItemInSlot=function(_,s) return s==0 and lens or nil end;assert(tick(B,copy)) end)
 check(pre..'Escape protects big disables but not healthy channel/TP',function() fresh();B.ready=true;local ally=friend(500);ally.mods.modifier_enigma_black_hole_pull=true;assert(tick(B,copy));fresh();B.ready=true;ally=friend(500,300);ally.recent=true;ally.channel=true;foe(450).attackTarget=ally;assert(not tick(B,copy));ally.channel=false;ally.mods.modifier_teleporting=true;assert(not tick(B,copy)) end)
 check(pre..'Escape does not react to unrelated enemies or duplicate box',function() fresh();B.ready=true;friend(300,300).recent=true;foe(500);assert(not tick(B,copy));allies[1].mods.modifier_ringmaster_the_box_buff=true;enemies[1].attackTarget=allies[1];assert(not tick(B,copy)) end)
 check(pre..'Whip predicts full channel and cannot hit departing target',function() fresh();W.ready=true;bot.mode='GoingOnSomeone';target=foe(900);target.speed=100;assert(not tick(W,copy));target.speed=0;assert(tick(W,copy).target.x==700) end)
 check(pre..'Whip Crack requires actual own channel after an issued intention',function() fresh();W.ready=true;C.ready=true;target=foe(500);target.channel=true;assert(tick(W,copy).name==W.name);actions={};W.ready=false;assert(not tick(C,copy));bot.channel=true;bot.using=true;bot.current=W;assert(tick(C,copy).name==C.name) end)
 check(pre..'Crack rejects foreign active source and missing sibling',function() fresh();W.ready=true;C.ready=true;target=foe(500);target.channel=true;assert(tick(W,copy));actions={};bot.channel=true;bot.current={};assert(not tick(C,copy));bot.current=W;spells.ringmaster_tame_the_beasts=nil;assert(not tick(C,copy)) end)
 check(pre..'Crack keeps unrelated casts queue and disabled actors intact',function() for _,flag in ipairs({'casting','queued','silenced','stunned','hexed','nightmared','modifier_ringmaster_the_box_buff','modifier_doom_bringer_doom','modifier_item_forcestaff_active'}) do fresh();C.ready=true;target=foe(500);target.channel=true;M.RecordWhip(bot,W,target:GetLocation());bot.channel=true;bot.current=W;if flag:find('modifier') then bot.mods[flag]=true else bot[flag]=flag=='queued' and 1 or true end;assert(not tick(C,copy)) end end)
 check(pre..'Dagger has current three charges and impact-only lethal',function() fresh();D.ready=true;foe(2300,100);assert(not tick(D,copy));enemies[1].hp=60;assert(tick(D,copy));actions={};D.charges=0;assert(not tick(D,copy)) end)
 check(pre..'Dagger predicts true flight and target regeneration',function() fresh();D.ready=true;local u=foe(2000,64);u.regen=5;assert(not tick(D,copy));u.hp=40;u.speed=20;assert(tick(D,copy).target.x>2030) end)
 check(pre..'Dagger collision and actual one-target penetration',function() fresh();D.ready=true;bot.mode='GoingOnSomeone';target=foe(2000);local creep=foe(1000);creep.hero=false;assert(not tick(D,copy));D.values.dagger_pass_through=1;assert(tick(D,copy));actions={};foe(1500).hero=false;assert(not tick(D,copy)) end)
 check(pre..'Wheel respects its physical minimum and actual max point range',function() fresh();ULT.ready=true;bot.mode='GoingOnSomeone';target=foe(400);target.disabled=true;local a=tick(ULT,copy);assert(a.target.x==700);fresh();ULT.ready=true;bot.mode='GoingOnSomeone';target=foe(1600);target.disabled=true;target.speed=400;assert(not tick(ULT,copy)) end)
 check(pre..'Spotlight targets actual enemy illusions and bounded prediction',function() fresh();S.ready=true;foe(1400).illusion=true;assert(tick(S,copy));actions={};enemies[1].speed=300;assert(not tick(S,copy)) end)
 check(pre..'Main spells honor actor locks and deactivated upgrades',function() for _,flag in ipairs({'channel','casting','using','queued','silenced','stunned','hexed','nightmared'}) do fresh();D.ready=true;foe(2000,50);bot[flag]=flag=='queued' and 1 or true;assert(not tick(D,copy)) end;fresh();S.ready=true;S.hidden=true;foe(1000).illusion=true;assert(not tick(S,copy));S.hidden=false;S.active=false;assert(not tick(S,copy)) end)
end
check('native save returns before second offensive spell',function() fresh();B.ready=true;D.ready=true;W.ready=true;bot.mode='GoingOnSomeone';target=foe(500);local ally=friend(550,300);ally.recent=true;target.attackTarget=ally;assert(tick(B,false).name==B.name) end)
check('souvenirs documented silence exception rejects mute and other locks',function() fresh();mirror.ready=true;bot.hp=300;bot.silenced=true;foe(300).attackTarget=bot;assert(native.UseCarnivalSouvenir());actions={};bot.muted=true;assert(not native.UseCarnivalSouvenir());bot.muted=false;bot.casting=true;assert(not native.UseCarnivalSouvenir());bot.casting=false;bot.mods.modifier_doom_bringer_doom=true;assert(not native.UseCarnivalSouvenir()) end)
check('actual souvenir charges and hidden handles required',function() fresh();mirror.ready=true;bot.hp=300;bot.silenced=true;foe(300).attackTarget=bot;mirror.charges=0;assert(not copied.UseCarnivalSouvenir());mirror.charges=1;mirror.hidden=true;assert(not copied.UseCarnivalSouvenir());mirror.hidden=false;assert(copied.UseCarnivalSouvenir()) end)
check('tonic protects threatened humans and cushion movement guards',function() fresh();tonic.ready=true;bot.silenced=true;local ally=friend(700,300);ally.recent=true;foe(500).attackTarget=ally;assert(native.UseCarnivalSouvenir() and actions[1].target==ally);fresh();cushion.ready=true;bot.silenced=true;bot.mode='Retreating';bot.recent=true;foe(300).attackTarget=bot;bot.rooted=true;assert(not native.UseCarnivalSouvenir());bot.rooted=false;assert(native.UseCarnivalSouvenir()) end)
check('native ranged creep and objective Dagger remain',function() fresh();D.ready=true;bot.mode='Laning';local creep=unit(500,50);creep.hero=false;creep.name='npc_dota_creep_ranged';creeps={creep};assert(tick(D,false));fresh();D.ready=true;bot.mode='DoingRoshan';target=unit(600);target.hero=false;target.roshan=true;assert(tick(D,false)) end)
check('copied unknown never gets bot or generic gates',function() local saved=GetBot;GetBot=function() error('unknown lookup') end;assert(copied.ConsiderStolenSpell({GetName=function() return 'other_spell' end})==nil);GetBot=saved end)
check('Crack refuses hidden and deactivated linked source',function() for _,flag in ipairs({'hidden','active'}) do fresh();C.ready=true;target=foe(500);target.channel=true;M.RecordWhip(bot,W,target:GetLocation());bot.channel=true;bot.current=W;W[flag]=flag=='hidden';assert(not copied.UseTameTheBeastsCrack()) end end)
check('actual Puck coiled blocks native and copied Cushion movement',function() for _,owner in ipairs({native,copied}) do fresh();cushion.ready=true;bot.silenced=true;bot.mode='Retreating';bot.recent=true;foe(300).attackTarget=bot;bot.mods.modifier_puck_coiled=true;assert(not owner.UseCarnivalSouvenir());bot.mods.modifier_puck_coiled=false;assert(owner.UseCarnivalSouvenir()) end end)
print('Ringmaster ability scenarios passed: '..count)
