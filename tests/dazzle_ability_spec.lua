-- Dazzle support spell decisions, damage geometry and Projection safety.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE = 0; BOT_ACTION_DESIRE_HIGH = 1; BOT_MODE_NONE = 0; BOT_MODE_RETREAT = 1
DAMAGE_TYPE_PHYSICAL = 1; DAMAGE_TYPE_ALL = 4
UNIT_LIST_ALLIED_HEROES = 1; UNIT_LIST_ENEMY_HEROES = 2; UNIT_LIST_ALLIED_CREEPS = 3

local Vec = {}; Vec.__index = Vec
local function V(x, y) return setmetatable({x=x, y=y or 0, z=0}, Vec) end
Vec.__add = function(a,b) return V(a.x+b.x, a.y+b.y) end
Vec.__sub = function(a,b) return V(a.x-b.x, a.y-b.y) end
Vec.__mul = function(a,b) if type(a)=='number' then a,b=b,a end; return V(a.x*b,a.y*b) end
Vec.__div = function(a,b) return V(a.x/b,a.y/b) end
function Vec:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function Vec:Normalized() local n=self:Length2D(); return n>0 and self/n or V(0) end
function Vector(x,y) return V(x,y) end
function RandomVector() return V(0) end
local function distance(a,b) return (a-b):Length2D() end
function GetUnitToUnitDistance(a,b) return distance(a:GetLocation(),b:GetLocation()) end
function GetUnitToLocationDistance(a,b) return distance(a:GetLocation(),b) end
function DotaTime() return 100 end

local Unit = {}; Unit.__index = Unit
local function unit(x,hp,maxHp)
    return setmetatable({loc=V(x),hp=hp or 1000,maxHp=maxHp or 1000,mods={},projectiles={},
        valid=true,hero=true,mitigation=1,recent=false,attack=100},Unit)
end
function Unit:GetLocation() return self.loc end
function Unit:GetExtrapolatedLocation() return self.loc end
function Unit:GetHealth() return self.hp end
function Unit:GetMaxHealth() return self.maxHp end
function Unit:GetHealthRegen() return 0 end
function Unit:HasModifier(name) return self.mods[name]==true end
function Unit:IsIllusion() return self.illusion==true end
function Unit:IsInvulnerable() return self.invulnerable==true end
function Unit:IsMagicImmune() return self.magicImmune==true end
function Unit:IsAlive() return self.valid end
function Unit:IsNull() return not self.valid end
function Unit:IsHero() return self.hero end
function Unit:CanBeSeen() return self.valid end
function Unit:GetUnitName() return self.hero and 'npc_dota_hero_axe' or 'npc_dota_creep_goodguys_melee' end
function Unit:WasRecentlyDamagedByAnyHero() return self.recent end
function Unit:WasRecentlyDamagedByHero() return self.recent end
function Unit:GetIncomingTrackingProjectiles() return self.projectiles end
function Unit:GetActualIncomingDamage(damage,kind)
    assert(kind==DAMAGE_TYPE_PHYSICAL or kind==DAMAGE_TYPE_ALL, 'physical spells use physical mitigation')
    return damage*self.mitigation
end
function Unit:GetAttackDamage() return self.attack end
function Unit:GetAttackTarget() return self.attackTarget end
function Unit:GetEstimatedDamageToTarget() return self.estimatedDamage or 0 end
function Unit:IsFacingLocation() return true end
function Unit:IsChanneling() return self.channeling==true end
function Unit:GetMagicResist() return 0.25 end

setmetatable(bot,Unit)
local enemies,allies,creeps,enemyCreeps,actions,towers = {},{},{},{},{},{}
local target,mode,fight,spam,lens = nil,'idle',false,false,false
local checkedDamage = nil
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:GetLevel() return 10 end
function bot:GetAttackRange() return 550 end
function bot:GetCurrentMovementSpeed() return 300 end
function bot:IsInvisible() return false end
function bot:IsAttacking() return false end
function bot:HasScepter() return self.scepter==true end
function bot:GetActiveMode() return mode=='retreat' and BOT_MODE_RETREAT or BOT_MODE_NONE end
function bot:GetNearbyTowers() return towers end
function bot:GetNearbyLaneCreeps(_,enemy) return enemy and enemyCreeps or creeps end
function bot:GetNearbyCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return {} end
function bot:ActionQueue_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
function bot:ActionQueue_UseAbilityOnLocation(a,v) actions[#actions+1]={name=a.name,loc=v} end
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={name=a.name} end

local abilities = {}
local function ability(name,range,cost,values)
    local a={name=name,range=range,cost=cost,values=values or {},castable=false,trained=true,level=1}
    function a:IsFullyCastable() return self.castable end
    function a:IsTrained() return self.trained end
    function a:IsHidden() return false end
    function a:IsActivated() return true end
    function a:IsPassive() return false end
    function a:IsNull() return false end
    function a:GetLevel() return self.level end
    function a:GetCastRange() return self.range end
    function a:GetCastPoint() return 0.3 end
    function a:GetManaCost() return self.cost end
    function a:GetAbilityDamage() return self.values.damage or 0 end
    function a:GetSpecialValueInt(key) return math.floor(self.values[key] or 0) end
    function a:GetSpecialValueFloat(key) return self.values[key] or 0 end
    abilities[name]=a; return a
end
ability('A1',600,110,{damage=20,duration=3.5,attack_range_bonus=200})
ability('A2',550,90,{duration=4})
ability('A3',800,90,{damage=85,damage_radius=185,bounce_radius=475,max_targets=3,tooltip_max_targets_inc_dazzle=4})
ability('dazzle_nothl_projection',450,100,{leash_start=1600,min_duration=5,max_duration=12})
ability('dazzle_nothl_projection_end',0,0)
for _,name in ipairs({'A4','A5','A6','T1','T2','T3','T4','T5','T6','T7','T8'}) do ability(name,600,100) end
abilities.T3.values.value=45; abilities.T4.values.value=5; abilities.T6.values.value=75
bot.GetAbilityByName=function(_,name) return abilities[name] end

local function nearby(list,loc,range)
    local out={}; for _,u in ipairs(list) do if u.valid and distance(u.loc,loc)<=range then out[#out+1]=u end end
    return out
end
J.Chat={GetNormName=function(u) return u:GetUnitName() end}
J.CanNotUseAbility=function() return false end
J.IsValid=function(u) return u~=nil and u.valid end
J.IsValidHero=function(u) return J.IsValid(u) and u.hero end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.IsValidTarget=J.IsValid
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.GetHP=function(u) return u.hp/u.maxHp end
J.GetMP=function(u) return u.mana/1000 end
J.GetProperTarget=function() return target end
J.GetNearbyHeroes=function(u,r,enemy) return nearby(enemy and enemies or allies,u.loc,r) end
J.GetAlliesNearLoc=function(loc,r) return nearby(allies,loc,r) end
J.GetEnemiesNearLoc=function(loc,r) return nearby(enemies,loc,r) end
J.GetAroundEnemyHeroList=function(r) return nearby(enemies,bot.loc,r) end
J.GetEnemyList=function(u,r) return nearby(enemies,u.loc,r) end
J.GetEnemyCount=function(u,r) return #nearby(enemies,u.loc,r) end
J.IsInTeamFight=function() return fight end
J.IsGoingOnSomeone=function() return mode=='attack' end
J.IsRetreating=function() return mode=='retreat' end
J.IsLaning=function() return mode=='lane' end
J.IsPushing=function() return mode=='push' end
J.IsDefending=function() return false end
J.IsFarming=function() return false end
J.IsDoingRoshan=function() return false end
J.IsDoingTormentor=function() return false end
J.IsRoshan=function() return false end
J.IsTormentor=function() return false end
J.IsAttacking=function() return false end
J.IsChasingTarget=function() return false end
J.CannotBeKilled=function() return false end
J.IsAllowedToSpam=function() return spam end
J.IsItemAvailable=function() return lens and {} or nil end
J.CanCastAbility=function(a) return a~=nil and a.castable end
J.CanCastOnNonMagicImmune=function(u) return J.IsValid(u) and not u.magicImmune and not u.invulnerable end
J.CanCastOnMagicImmune=function(u) return J.IsValid(u) and not u.invulnerable end
J.CanCastOnTargetAdvanced=function(u) return J.IsValid(u) and not u.invulnerable end
J.CanBeAttacked=J.CanCastOnTargetAdvanced
J.CanKillTarget=function(u,dmg) checkedDamage=dmg; return dmg*u.mitigation>=u.hp end
J.SetReportMotive=function() end
J.SetQueuePtToINT=function() end
J.CombineTwoTable=function(a,b) local out={}; for _,u in ipairs(a) do out[#out+1]=u end; for _,u in ipairs(b) do out[#out+1]=u end; return out end
J.GetLeastHpUnit=function(list) local best=nil; for _,u in ipairs(list) do if not best or u.hp<best.hp then best=u end end; return best end
J.GetMostHpUnit=function() return nil end
J.GetUnitAllyCountAroundEnemyTarget=function(u,r) return #nearby(allies,u.loc,r)+#nearby(creeps,u.loc,r) end
J.GetAttackProjectileDamageByRange=function(u) local n=0; for _,p in ipairs(u.projectiles) do if p.is_attack then n=n+p.caster:GetAttackDamage() end end; return n end
J.GetLocationToLocationDistance=distance
function GetUnitList(kind) return kind==UNIT_LIST_ENEMY_HEROES and enemies or kind==UNIT_LIST_ALLIED_CREEPS and creeps or allies end

local Dazzle=H.load('npc_dota_hero_dazzle','pos_5')
local function reset()
    enemies,allies,creeps,enemyCreeps,actions,towers={},{},{},{},{},{}
    target,mode,fight,spam,lens=nil,'idle',false,false,false; checkedDamage=nil
    for k,v in pairs(unit(0)) do bot[k]=v end
    bot.mana=1000
    bot.scepter=false
    for name,a in pairs(abilities) do a.castable=false; a.trained=not name:match('^T'); a.level=1 end
    J.Utils.GameStates.dazzleNothl[bot:GetPlayerID()].body=bot
end
local function tick() actions={}; Dazzle.SkillsComplement(); return actions[1] end
local function cast(name,u) local a=tick(); assert(a and a.name==name and (not u or a.target==u),'expected '..name); return a end
local function noCast() assert(tick()==nil,'expected no ability cast') end

-- Saves take precedence over offensive Poison Touch and routine healing.
reset(); abilities.A1.castable=true; abilities.A2.castable=true; abilities.A3.castable=true
local ally=unit(300,200); ally.recent=true; allies={ally}; target=unit(500); enemies={target}; mode='attack'
cast('A2',ally)
abilities.A2.castable=false; ally.mods.modifier_dazzle_shallow_grave=true; ally.hp=450
cast('A3',ally)

-- Self is a save candidate even when GetAlliesNearLoc excludes the caster.
reset(); abilities.A2.castable=true; bot.hp=200; bot.recent=true; enemies={unit(400)}
cast('A2',bot)

-- Projectiles are checked at any HP and use physical damage after armor.
reset(); abilities.A2.castable=true; ally=unit(300,600); allies={ally}
local attacker=unit(500); attacker.attack=700
ally.projectiles={{is_attack=true,caster=attacker,location=V(350)}}
cast('A2',ally)
ally.mitigation=0.5; noCast()
local threatened=unit(200,200); threatened.recent=true; allies={threatened,ally}; ally.mitigation=1
cast('A2',ally)

-- Existing protection, illusions and untargetable souls are never Grave candidates.
reset(); abilities.A2.castable=true; ally=unit(300,100); ally.recent=true; allies={ally}; enemies={unit(500)}
for _,excluded in ipairs({'grave','illusion','soul','invulnerable'}) do
    ally.mods={}; ally.illusion=false; ally.invulnerable=false
    if excluded=='grave' then ally.mods.modifier_dazzle_shallow_grave=true
    elseif excluded=='soul' then ally.mods.modifier_dazzle_nothl_projection_soul_debuff=true
    elseif excluded=='illusion' then ally.illusion=true else ally.invulnerable=true end
    noCast()
end
ally.mods={}; ally.illusion=false; ally.invulnerable=false; ally.loc=V(551); noCast()
lens=true; cast('A2',ally)

-- Routine Wave heals meaningful missing health; Ice Blast blocks heal-only use.
reset(); abilities.A3.castable=true; ally=unit(300,700); allies={ally}; spam=true
cast('A3',ally)
ally.mods.modifier_ice_blast=true; noCast()
ally.hp=200; noCast()
ally.mods={}; ally.hp=950; noCast()

-- Offensive Wave must originate at a reachable ally, and only uses the real damage radius.
reset(); abilities.A3.castable=true; mode='attack'; target=unit(980,50); enemies={target}
ally=unit(801); allies={ally}; noCast()
assert(Dazzle.GetBestHealTarget(target,185)==nil,'Wave cannot chase an unreachable cluster')
ally.loc=V(800); cast('A3',ally)
target.loc=V(986); noCast()

-- Damage is capped by affected targets, and the tier-15 Wave talent adds 45 rather than duration.
reset(); abilities.A3.castable=true; target=unit(700,400); enemies={target}
for i=1,8 do local c=unit(700+i); c.hero=false; creeps[#creeps+1]=c end
noCast()
assert(Dazzle.GetAbilityEMaxDamage(target)==3*85,'three other Wave targets contribute damage when Dazzle is outside the radius')
creeps={creeps[1]}; target.hp=110; abilities.T4.trained=true; noCast()
abilities.T3.trained=true; cast('A3',creeps[1])

-- The caster is healed automatically and contributes a damage source without another ally.
reset(); abilities.A3.castable=true; target=unit(150,80); enemies={target}
cast('A3',bot)
assert(Dazzle.GetAbilityEMaxDamage(target)==85,'Dazzle contributes one automatic Wave damage source')

-- Scepter unlocks enemy-targeted physical Wave; ordinary Wave needs an allied source.
reset(); abilities.A3.castable=true; target=unit(700,50); enemies={target}
noCast()
bot.scepter=true; cast('A3',target)
target.magicImmune=true; cast('A3',target)
target.loc=V(801); noCast()
target.loc=V(700); target.hp=1000; mode='attack'; spam=true
enemies={target,unit(950)}; cast('A3',target)
enemies[2].loc=V(1200); noCast()
ally=unit(300,200); allies={ally}; cast('A3',ally)

-- Poison's short level-1 duration retains its fractional seconds in kill estimates.
reset(); abilities.A1.castable=true; target=unit(500,65); enemies={target}
cast('A1',target)
assert(checkedDamage==70,'Poison uses 20 DPS for 3.5 seconds')
target.loc=V(601); noCast()

-- Lane harass needs mana and attack follow-up reach; retreat still slows a pursuer.
reset(); abilities.A1.castable=true; mode='lane'; target=unit(500); enemies={target}
bot.mana=600; cast('A1',target)
bot.mana=540; noCast()
mode='retreat'; bot.recent=true; cast('A1',target)
mode='lane'; bot.recent=false; bot.mana=600; bot.GetAttackRange=function() return 100 end; noCast()
abilities.A1.level=4; noCast()
bot.GetAttackRange=function() return 550 end
reset(); abilities.A1.castable=true; mode='lane'; enemyCreeps={unit(300),unit(350),unit(400)}
noCast()

-- Empowered Poison interrupts channels before choosing a damage kill.
reset(); abilities.A1.castable=true; bot.mods.modifier_dazzle_nothl_projection_soul_debuff=true
local low=unit(300,50); local channel=unit(500); channel.channeling=true; enemies={low,channel}
cast('A1',channel)

-- Projection protects an engaged support ally and clamps the destination to actual cast range.
reset(); abilities.dazzle_nothl_projection.castable=true; abilities.A3.castable=true
ally=unit(1100,500); ally.recent=true; allies={ally}; enemies={unit(1150)}
local projection=cast('dazzle_nothl_projection')
assert(distance(bot.loc,projection.loc)<=450,'Projection cast point is clamped to actual range')
enemies[#enemies+1]=unit(599); noCast()
enemies={unit(1150)}; towers={unit(800)}; noCast()
towers={}; bot.mana=180; noCast()
bot.mana=1000; abilities.A3.castable=false; abilities.A2.castable=true; noCast()
ally.loc=V(990); cast('dazzle_nothl_projection')

-- Offensive Projection reserves Poison's actual mana, even if a cheaper Grave is ready.
reset(); abilities.dazzle_nothl_projection.castable=true; abilities.A1.castable=true; abilities.A2.castable=true
target=unit(900); enemies={target}; mode='attack'; bot.mana=200; noCast()
bot.mana=210; cast('dazzle_nothl_projection')

-- End Projection guards stale body handles and returns when the physical body is threatened.
reset(); abilities.dazzle_nothl_projection_end.castable=true
bot.mods.modifier_dazzle_nothl_projection_soul_debuff=true
J.Utils.GameStates.dazzleNothl[bot:GetPlayerID()].body=nil
tick() -- An invalid body must never be dereferenced.
local body=unit(2000,500); body.recent=true
J.Utils.GameStates.dazzleNothl[bot:GetPlayerID()].body=body
enemies={unit(900)}
cast('dazzle_nothl_projection_end')
body.hp=1000; body.recent=false; enemies={unit(900),unit(1900)}
cast('dazzle_nothl_projection_end')

-- Continue useful healing when no enemies are near the soul but a nearby wounded ally is threatened.
reset(); abilities.dazzle_nothl_projection_end.castable=true
bot.mods.modifier_dazzle_nothl_projection_soul_debuff=true
J.Utils.GameStates.dazzleNothl[bot:GetPlayerID()].body=unit(-1000)
ally=unit(700,500); ally.recent=true; allies={ally}
noCast()
bot.mods={}; noCast()

-- The immobile physical body records its handle but issues no ability action.
reset(); abilities.A2.castable=true; bot.hp=200; bot.recent=true; enemies={unit(400)}
bot.mods.modifier_dazzle_nothl_projection_physical_body_debuff=true
noCast()
assert(J.Utils.GameStates.dazzleNothl[bot:GetPlayerID()].body==bot,'physical body is retained for the soul')

print('Dazzle ability scenarios passed')
