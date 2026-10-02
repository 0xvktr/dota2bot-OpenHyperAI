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

local Q=spell('queenofpain_shadow_strike',600,{mana=115,castpoint=.3,strike_damage=140,aoe_radius=0,generate_scream=0})
local W=spell('queenofpain_blink',1300,{mana=65,castpoint=.33,min_blink_range=200})
local E=spell('queenofpain_scream_of_pain',0,{mana=120,area_of_effect=600,damage=345,damage_reflected_to_self=25})
local R=spell('queenofpain_sonic_wave',700,{mana=550,castpoint=.452,speed=900,distance=900,starting_aoe=100,final_aoe=450,damage=625})
local lens=spell('item_aether_lens',0,{cast_range_bonus=225});local supremacy=spell('rubick_arcane_supremacy',0,{cast_range=240})
spells.rubick_arcane_supremacy=nil
J.HasBreakModifier=function() return bot.broken==true end
function IsLocationPassable() return not bot.impassable end
J.IsStuck=function() return bot.stuck==true end
J.IsLocHaveTower=function() return bot.tower==true end
J.IsEnemyChronosphereInLocation=function() return bot.chrono==true end
J.IsEnemyBlackHoleInLocation=function() return bot.blackhole==true end
J.GetEnemiesNearLoc=function(loc,r) local out={};for _,u in ipairs(enemies) do if distance(loc,u)<=r then out[#out+1]=u end end;return out end
J.GetAlliesNearLoc=function(loc,r) local out={bot};for _,u in ipairs(allies) do if distance(loc,u)<=r then out[#out+1]=u end end;return out end
J.GetMostHpUnit=function(list) return list[1] end
J.IsOtherAllysTarget=function() return false end
J.IsKeyWordUnit=function(k,u) return u.name:find(k)~=nil end
J.WillKillTarget=function(u,d,k,delay) return J.CanKillTarget(u,d-(u.regen or 0)*delay-.801,k) end
J.Chat={GetNormName=function() return 'creep' end}
function U:GetMagicResist() return self.resistance or 0 end
local native=H.load('npc_dota_hero_queenofpain','pos_2')
local copied=H.realDofile('bots/FunLib/rubick_hero/queenofpain.lua')
local count=0
local function fresh()
 reset();bot.broken=false;bot.stuck=false;bot.tower=false;bot.chrono=false;bot.blackhole=false;bot.impassable=false
 bot.GetItemInSlot=function() return nil end
 spells.rubick_arcane_supremacy=nil;spells.queenofpain_shadow_strike=Q;spells.queenofpain_scream_of_pain=E;spells.queenofpain_sonic_wave=R
 Q.values.aoe_radius=0;Q.values.generate_scream=0
end
local function tick(a,copy)
 if copy then local used=copied.ConsiderStolenSpell(a);assert(used==(#actions>0),'copied result must match action') else native.SkillsComplement() end
 assert(#actions<=1,'only one spell');return actions[1]
end
local function check(label,fn) local ok,err=pcall(fn);assert(ok,label..': '..tostring(err));count=count+1 end
for _,copy in ipairs({false,true}) do
 local prefix=copy and 'copied ' or 'native '
 check(prefix..'initial strike cannot count sixteen seconds of damage',function() fresh();Q.ready=true;foe(500,141);assert(not tick(Q,copy));enemies[1].hp=139;assert(tick(Q,copy).shape=='unit') end)
 check(prefix..'real cast range and Lens',function() fresh();Q.ready=true;foe(610,100);assert(not tick(Q,copy));bot.GetItemInSlot=function(_,s) return s==0 and lens or nil end;assert(tick(Q,copy).name==Q.name) end)
 check(prefix..'unit Strike rejects spell block and immunity',function() fresh();Q.ready=true;local u=foe(500,100);u.blocked=true;assert(not tick(Q,copy));u.blocked=false;u.immune=true;assert(not tick(Q,copy)) end)
 check(prefix..'actual Scepter point refresh needs observed sibling',function() fresh();Q.ready=true;Q.values.aoe_radius=300;Q.values.generate_scream=1;local u=foe(500,400);u.mods.modifier_queenofpain_shadow_strike=true;assert(tick(Q,copy).shape=='point');actions={};spells.queenofpain_scream_of_pain=nil;assert(not tick(Q,copy));spells.queenofpain_scream_of_pain=E;E.hidden=true;assert(not tick(Q,copy)) end)
 check(prefix..'Scream health budget counts every real affected hero',function() fresh();E.ready=true;bot.hp=330;bot.mode='InTeamFight';foe(200);foe(300);assert(not tick(E,copy));bot.hp=500;assert(tick(E,copy).name==E.name) end)
 check(prefix..'Scream can secure lethal enemy and ignores immune reflection',function() fresh();E.ready=true;bot.hp=150;local u=foe(200,300);assert(tick(E,copy));actions={};u.hp=1000;u.immune=true;bot.mode='InTeamFight';assert(not tick(E,copy)) end)
 check(prefix..'Sonic uses real pure damage and pierces immunity',function() fresh();R.ready=true;local u=foe(850,626);u.immune=true;assert(not tick(R,copy));u.hp=624;assert(tick(R,copy).name==R.name);assert(u.delay>.452) end)
 check(prefix..'Sonic directional area rejects distant and rear targets',function() fresh();R.ready=true;bot.mode='InTeamFight';foe(700);foe(-200);assert(not tick(R,copy));foe(850);assert(tick(R,copy));fresh();R.ready=true;foe(1000,100);assert(not tick(R,copy)) end)
 check(prefix..'Blink escape is bounded and avoids known hazards',function() fresh();W.ready=true;bot.mode='Retreating';bot.recent=true;local a=tick(W,copy);assert(math.abs(a.target.x)==1300);actions={};bot.tower=true;assert(not tick(W,copy));bot.tower=false;bot.blackhole=true;assert(not tick(W,copy)) end)
 check(prefix..'Blink respects root leash and Rupture',function() for _,guard in ipairs({'root','modifier_bloodseeker_rupture','modifier_slark_pounce_leash','modifier_puck_coiled','modifier_grimstroke_soul_chain'}) do fresh();W.ready=true;bot.mode='Retreating';bot.recent=true;if guard=='root' then bot.rooted=true else bot.mods[guard]=true end;assert(not tick(W,copy)) end end)
 check(prefix..'Blink with missing siblings only escapes',function() fresh();W.ready=true;bot.mode='GoingOnSomeone';target=foe(1000);spells.queenofpain_shadow_strike=nil;spells.queenofpain_scream_of_pain=nil;spells.queenofpain_sonic_wave=nil;assert(not tick(W,copy));bot.mode='Retreating';bot.recent=true;assert(tick(W,copy)) end)
 check(prefix..'normal spell locks and hidden/deactivated guard',function() for _,lock in ipairs({'channel','using','casting','silenced','stunned','hexed','nightmared','queued'}) do fresh();Q.ready=true;foe(100,100);bot[lock]=lock=='queued' and 1 or true;assert(not tick(Q,copy)) end;fresh();Q.ready=true;foe(100,100);Q.active=false;assert(not tick(Q,copy));Q.active=true;Q.hidden=true;assert(not tick(Q,copy)) end)
end
check('copied unknown does not enter generic gates',function() fresh();local gate=J.CanNotUseAbility;J.CanNotUseAbility=function() error('unknown entered gate') end;assert(copied.ConsiderStolenSpell({GetName=function() return 'other_spell' end})==nil);J.CanNotUseAbility=gate end)
check('copied Supremacy honors Break',function() fresh();Q.ready=true;spells.rubick_arcane_supremacy=supremacy;foe(700,100);assert(tick(Q,true));actions={};bot.broken=true;assert(not tick(Q,true)) end)
check('native lane last hit remains available',function() fresh();E.ready=true;bot.mode='Laning';for _,name in ipairs({'ranged','melee'}) do local u=unit(250,100);u.hero=false;u.name='npc_dota_creep_'..name;creeps[#creeps+1]=u end;assert(tick(E,false).name==E.name) end)
check('native objective rejects magical immunity',function() fresh();Q.ready=true;E.ready=true;bot.mode='DoingTormentor';target=unit(100,1000);target.hero=false;target.tormentor=true;target.immune=true;assert(not tick(Q,false));target.immune=false;assert(tick(Q,false)) end)
for _,copy in ipairs({false,true}) do
 check('projectile regeneration rejects false lethals',function() for _,a in ipairs({Q,E,R}) do fresh();a.ready=true;local u=foe(a==R and 850 or 500,a==Q and 139 or a==E and 344 or 624);u.regen=10;assert(not tick(a,copy)) end end)
end
print('Queen of Pain ability scenarios passed: '..count)
