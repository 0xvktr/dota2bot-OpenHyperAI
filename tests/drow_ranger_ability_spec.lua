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

local q=spell('drow_ranger_frost_arrows',625,{damage=30,mana=12})
local w=spell('drow_ranger_wave_of_silence',900,{castpoint=0.25,wave_speed=2000,wave_length=900,wave_width=250,mana=55})
local e=spell('drow_ranger_multishot',0,{arrow_speed=1300,arrow_range_multiplier=1,arrow_range_base=475,arrow_width=90,arrow_angle=50,mana=115})
local d=spell('drow_ranger_glacier',400,{knockback_distance=225,attack_range_bonus=200,mana=50})
local hero=H.load('npc_dota_hero_drow_ranger','pos_1')
local copy=H.realDofile('bots/FunLib/rubick_hero/drow_ranger.lua')
local function tick(stolen,a) actions={};if stolen then copy.ConsiderStolenSpell(a) else hero.SkillsComplement() end;return actions[1] end
for _,stolen in ipairs({false,true}) do
 reset();bot.attackRange=625;q.ready=true;target=foe(625);bot.mode='GoingOnSomeone'
 assert(tick(stolen,q).shape=='unit','manual orb uses attack cast class')
 target.x=626;assert(tick(stolen,q)==nil,'orb cannot borrow movement range or raw spell range')
 lens={GetSpecialValueInt=function() return 225 end};spell('rubick_arcane_supremacy',0,{cast_range=240});assert(tick(stolen,q)==nil,'Lens/Supremacy do not extend attack orb')
 target.x=600;bot.disarmed=true;assert(tick(stolen,q)==nil,'disarm prevents Frost attacks');bot.disarmed=false
 target.immune=true;assert(tick(stolen,q)==nil,'do not spend Frost Arrows into debuff immunity');target.immune=false
 target.ethereal=true;assert(tick(stolen,q)==nil,'orb rejects ethereal targets');target.ethereal=false
 target.illusion=true;assert(tick(stolen,q)==nil,'orb does not prioritize suspicious hero illusion');target.illusion=false
 target.blocked=true;target.reflected=true;assert(tick(stolen,q),'attack orb does not use unit-spell reflection rules')
 bot.attackRange=550;target.x=551;assert(tick(stolen,q)==nil,'stolen orb uses actor attack reach');target.x=550;assert(tick(stolen,q),'actor attack reach boundary')
 reset();bot.attackRange=625;q.ready=true;w.ready=true;bot.mode='GoingOnSomeone';target=foe(600);target.silenced=true
 bot.mana=60;assert(tick(stolen,q)==nil,'reserve mana for live Gust escape');bot.mana=67;assert(tick(stolen,q),'orb spends only above escape reserve')
 reset();bot.attackRange=625;q.ready=true;bot.mode='Laning';creeps={creep(500,125)}
 assert(tick(stolen,q).target==creeps[1],'extra physical orb damage secures last hit');creeps[1].hp=95
 assert(tick(stolen,q)==nil,'ordinary attack last hit does not waste mana');creeps[1].hp=131
 assert(tick(stolen,q)==nil,'orb cannot secure excessive health');creeps[1].hp=125;creeps[1].x=626;assert(tick(stolen,q)==nil,'last hit respects attack reach')
 reset();bot.attackRange=625;q.ready=true;bot.mode='Farming';target=creep(500)
 assert(tick(stolen,q)==nil,'healthy basic farm does not spam single Frost');bot.scepter=true
 assert(tick(stolen,q),'current Scepter stacks can justify durable camp orb')
 target.building=true;target.roshan=false;bot.mode='Pushing';assert(tick(stolen,q)==nil,'Frost is never an orb building cast')
 reset();bot.attackRange=625;w.ready=true;local enemy=foe(900);enemy.channel=true;enemy.blocked=true;enemy.reflected=true
 assert(tick(stolen,w).shape=='point','Gust interrupts ordinary channel as unreflectable point wave')
 enemy.x=901;assert(tick(stolen,w)==nil,'Gust does not fake wave reach');lens={GetSpecialValueInt=function() return 225 end};enemy.x=1125
 assert(tick(stolen,w),'real Lens extends Gust');enemy.x=1126;assert(tick(stolen,w)==nil,'Lens edge boundary')
 lens=nil;enemy.x=900;enemy.immune=true;assert(tick(stolen,w)==nil,'immune channel cannot be silenced');enemy.immune=false
 enemy.mods.modifier_teleporting=true;assert(tick(stolen,w)==nil,'Gust does not claim TP interrupt')
 reset();bot.attackRange=625;w.ready=true;target=foe(600);target.speed=100;bot.mode='GoingOnSomeone'
 local cast=tick(stolen,w);assert(cast and cast.target.x==655,'Gust predicts cast plus wave travel')
 reset();bot.attackRange=625;w.ready=true;local ally=friend(500,300);ally.mode='Retreating';ally.recent=true;enemy=foe(600);enemy.chasing=ally
 assert(tick(stolen,w),'Gust peels for retreating ally')
 reset();bot.attackRange=625;w.ready=true;e.ready=true;d.ready=true;target=foe(200);target.hurtBot=true;bot.mode='GoingOnSomeone'
 if not stolen then assert(tick(stolen,e).name==w.name,'Gust peel precedes channel or hill commitment') end
 reset();bot.attackRange=625;e.ready=true;target=foe(1100);target.immune=true;target.blocked=true;target.reflected=true;bot.mode='GoingOnSomeone'
 assert(tick(stolen,e).shape=='point','physical Multishot reaches attack range plus 475 and pierces immunity')
 target.x=1101;assert(tick(stolen,e)==nil,'Multishot range boundary');lens={GetSpecialValueInt=function() return 225 end};spell('rubick_arcane_supremacy',0,{cast_range=240})
 assert(tick(stolen,e)==nil,'spell range items do not extend Multishot');bot.attackRange=825;target.x=1300
 assert(tick(stolen,e),'increased actor attack range extends Multishot')
 target.ethereal=true;assert(tick(stolen,e)==nil,'physical Multishot rejects ethereal');target.ethereal=false
 target.mods.modifier_winter_wyvern_cold_embrace=true;assert(tick(stolen,e)==nil,'physical protection prevents Multishot damage choice')
 reset();bot.attackRange=625;e.ready=true;bot.mode='GoingOnSomeone';target=foe(800);foe(250)
 assert(tick(stolen,e)==nil,'uncontrolled point-blank threat prevents exposed channel');enemies[2].disabled=true
 assert(tick(stolen,e),'disabled close threat permits channel');enemies[2].disabled=false;bot.immune=true;assert(tick(stolen,e),'caster BKB permits closer channel commitment')
 reset();bot.attackRange=625;e.ready=true;bot.mode='InTeamFight';foe(500);foe(800,nil,250)
 assert(tick(stolen,e),'cone can cover forward physical cluster');enemies[2].y=700;assert(tick(stolen,e)==nil,'sideways hero is not a Multishot cluster hit')
 reset();bot.attackRange=625;e.ready=true;bot.mode='Farming';local group={creep(500),creep(700)};creeps=group;neutrals=group
 assert(tick(stolen,e)==nil,'overlapping camp lists cannot double count');neutrals={group[1],group[2],creep(900)}
 assert(tick(stolen,e),'safe three-unit cone clears farm');foe(1400);assert(tick(stolen,e)==nil,'farm channel withheld near heroes')
 reset();bot.attackRange=625;d.ready=true;bot.mode='GoingOnSomeone';target=foe(825)
 assert(tick(stolen,d).shape=='none','Glacier is self cast and prepares extended attack reach');target.x=826;assert(tick(stolen,d)==nil,'hill does not enable unreachable attack')
 reset();bot.attackRange=625;d.ready=true;bot.mode='Pushing';target=creep(800);target.building=true
 assert(tick(stolen,d)==nil,'siege hill needs friendly creep support');alliedCreeps={creep(500)}
 assert(tick(stolen,d),'Glacier supports safe allied-wave tower siege')
 reset();bot.attackRange=625;d.ready=true;allies={friend(50),friend(100)}
 assert(tick(stolen,d)==nil,'idle allied presence does not waste Glacier')
 reset();bot.attackRange=625;d.ready=true;bot.channel=true;bot.current=e;enemy=foe(200);enemy.chasing=bot
 local X=stolen and copy or hero
 actions={};assert(X.UseGlacierDuringMultishot() and actions[1].shape=='none','observed Multishot permits immediate NO_TARGET defensive hill')
 assert(tick(stolen,d),'ordinary dispatch can use the channel exception')
 bot.current=spell('item_tpscroll');assert(tick(stolen,d)==nil,'TP preserved despite nearby threat')
 actions={};assert(not X.UseGlacierDuringMultishot() and #actions==0,'early helper refuses TP')
 bot.current=nil;assert(tick(stolen,d)==nil,'unknown channel preserved')
 bot.current=e
 for _,flag in ipairs({'casting','silenced','stunned','hexed','nightmared'}) do
  bot[flag]=true;assert(tick(stolen,d)==nil,'channel exception respects '..flag);bot[flag]=false
 end
 bot.queued=1;assert(tick(stolen,d)==nil,'queued channel action preserved');bot.queued=0
 d.hidden=true;assert(tick(stolen,d)==nil,'unavailable linked Glacier never cast');d.hidden=false
 d.active=false;assert(tick(stolen,d)==nil,'inactive Glacier never cast');d.active=true
 bot.channel=false;bot.queued=1;target=foe(500);bot.mode='GoingOnSomeone';q.ready=true;w.ready=true;e.ready=true
 for _,a in ipairs({q,w,e,d}) do assert(tick(stolen,a)==nil,'all ordinary abilities preserve action queue') end
end
assert(copy.ConsiderStolenSpell(spell('unrelated_spell'))==nil,'unsupported spell retains generic dispatch')
print('Drow Ranger ability scenarios passed')
