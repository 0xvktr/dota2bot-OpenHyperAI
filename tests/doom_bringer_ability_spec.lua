local H = dofile('tests/hero_harness.lua')
local J, bot = H.J, H.bot
BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH = 0, 0.8
BOT_MODE_NONE, DAMAGE_TYPE_MAGICAL = 0, 2
DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING = 1073741824
bit={band=function(value,flag) return math.floor(value/flag)%2==1 and flag or 0 end}
local v={}; v.__index=v
function Vector(x,y,z) return setmetatable({x=x,y=y or 0,z=z or 0},v) end
function v.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function v.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function v.__mul(a,b) if type(a)=='number' then a,b=b,a end;return Vector(a.x*b,a.y*b,a.z*b) end
function v:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function v:Normalized() local n=self:Length2D();return n==0 and Vector(0,0) or self*(1/n) end
function GetUnitToUnitDistance(a,b) return (a:GetLocation()-b:GetLocation()):Length2D() end
function GetUnitToLocationDistance(a,b) return (a:GetLocation()-b):Length2D() end
local actions,enemies,allies,creeps,items,abilities,slots={},{},{},{},{},{},{}
local function unit(x,y,kind)
    local u={x=x,y=y or 0,kind=kind or 'hero',hp=1000,maxhp=1000,mana=1000,team=3,mods={},mode='',attackRange=150,speed=0}
    function u:GetLocation() return Vector(self.x,self.y) end
    function u:GetTeam() return self.team end
    function u:GetHealth() return self.hp end
    function u:GetMaxHealth() return self.maxhp end
    function u:GetMana() return self.mana end
    function u:GetMaxMana() return self.maxmana or 1000 end
    function u:GetLevel() return self.level or 3 end
    function u:GetUnitName() return self.name or "npc_dota_creep_melee" end
    function u:IsCreep() return self.kind=="creep" end
    function u:IsHero() return self.kind=="hero" end
    function u:IsAncientCreep() return self.ancient==true end
    function u:IsIllusion() return self.illusion==true end
    function u:GetEstimatedDamageToTarget() return self.threat or 100 end
    function u:GetAttackRange() return self.attackRange end
    function u:HasModifier(m) return self.mods[m]==true end
    function u:IsMagicImmune() return self.immune==true end
    function u:IsInvulnerable() return self.invulnerable==true end
    function u:IsRooted() return self.rooted==true end
    function u:IsStunned() return self.stunned==true end
    function u:IsHexed() return self.hexed==true end
    function u:IsNightmared() return self.nightmare==true end
    function u:IsChanneling() return self.channel==true end
    function u:CanBeSeen() return self.visible~=false end
    function u:WasRecentlyDamagedByAnyHero() return self.damaged==true end
    return u
end
for k,value in pairs(unit(0)) do bot[k]=value end
function bot:GetAbilityByName(name) return abilities[name] end
function bot:GetItemInSlot(slot) return items[slot] end
function bot:GetNearbyCreeps() return creeps end
function bot:GetAbilityInSlot(slot) return slots[slot] end
function bot:HasScepter() return self.scepter==true end
function bot:GetAttackPoint() return 0.5 end
function bot:IsDisarmed() return self.disarmed==true end
function bot:Action_UseAbility(a) actions[#actions+1]={name=a.name} end
function bot:FindAoELocation() return self.aoe or {targetloc=Vector(0,0),count=0} end
function bot:Action_UseAbilityOnLocation(a,p) actions[#actions+1]={name=a.name,point=p} end
function bot:Action_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
bot.ActionQueue_UseAbilityOnLocation=bot.Action_UseAbilityOnLocation
bot.ActionQueue_UseAbilityOnEntity=bot.Action_UseAbilityOnEntity
function bot:Action_ClearActions() end
function bot:ActionQueue_Delay(t) actions[#actions+1]={name='delay',duration=t} end
function GetTeam() return bot.team end
function IsLocationPassable() return not bot.impassable end
local function ability(name,range,mana,values,point)
    local a={name=name,range=range,mana=mana,values=values or {},point=point or 0,castable=false,behavior=16}
    function a:GetName() return self.name end
    function a:GetCastRange() return self.range end
    function a:GetManaCost() return self.mana end
    function a:GetCastPoint() return self.point end
    function a:GetSpecialValueInt(key) return self.values[key] or 0 end
    a.GetSpecialValueFloat=a.GetSpecialValueInt
    function a:GetLevel() return self.level or 3 end
    function a:GetBehavior() return self.behavior end
    function a:GetToggleState() return self.toggle==true end
    function a:IsTrained() return self.trained==true end
    function a:IsFullyCastable() return self.castable end
    abilities[name]=a;return a
end
local devour=ability('doom_bringer_devour',300,70,{creep_level=6,can_target_ancient=0},0.3)
local earth=ability('doom_bringer_scorched_earth',666,90,{radius=666,bonus_health_regen=6.66,is_permanent=0},0)
local blade=ability('doom_bringer_infernal_blade',200,35,{burn_damage=66,burn_damage_pct=4.25,burn_duration=4},0)
local doom=ability('doom_bringer_doom',400,250,{duration=16,damage=66,scepter_aura_radius=0},0.5)
local blink=ability('item_blink',0,0,{blink_range=1200})
local lens=ability('item_aether_lens',0,0,{cast_range_bonus=225})
local supremacy=ability('rubick_arcane_supremacy',0,0,{cast_range=240})
local stomp=ability('centaur_khan_war_stomp',0,50,{radius=250},0.4)
local purge=ability('satyr_trickster_purge',350,120,{},0.2)
local lightning=ability('harpy_storm_chain_lightning',900,60,{initial_damage=120},0.3)
local function nearby(list,u,r)
    local out={};for _,other in pairs(list) do if other~=u and GetUnitToUnitDistance(u,other)<=r then out[#out+1]=other end end;return out
end
J.IsValid=function(u) return u~=nil and not u.invalid and u:CanBeSeen() end
J.IsValidHero=function(u) return J.IsValid(u) and u.kind=='hero' end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnNonMagicImmune=function(u) return u:CanBeSeen() and not u.immune and not u.invulnerable and not u.illusion end
J.CanCastOnMagicImmune=function(u) return u:CanBeSeen() and not u.invulnerable and not u.illusion end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked end
J.CanCastAbility=function(a) return a~=nil and a.castable end
J.CanNotUseAbility=function(u) return u.channel or u.using or u.silenced or u.queued or u.stunned or false end
J.GetProperTarget=function(u) return u.target end
J.GetNearbyHeroes=function(u,r,enemy) return nearby(enemy and enemies or allies,u,r) end
J.GetAlliesNearLoc=function(p,r)
    local out={};for _,u in pairs(allies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out
end
J.GetEnemiesNearLoc=function(p,r)
    local out={};for _,u in pairs(enemies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out
end
J.GetCorrectLoc=function(u,delay) return Vector(u.x+u.speed*delay,u.y) end
J.CannotBeKilled=function(_,u) return u.protected==true end
J.WillKillTarget=function(u,damage,kind,delay)
    assert(kind==DAMAGE_TYPE_MAGICAL);bot.killDamage,bot.killDelay=damage,delay
    return damage*(u.magic or 1)>=u.hp+delay*(u.regen or 0)
end
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.IsInTeamFight=function() return bot.fight==true end
J.IsGoingOnSomeone=function(u) return u.mode=='attack' end
J.IsRetreating=function(u) return u.mode=='retreat' end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.IsDisabled=function(u) return u.disabled==true or u.stunned==true end
J.IsLaning=function() return bot.mode=='lane' end
J.IsFarming=function() return bot.mode=='farm' end
J.IsPushing=function() return bot.mode=='push' end
J.IsDefending=function() return bot.mode=='defend' end
J.IsDoingRoshan=function() return bot.mode=='roshan' end
J.IsDoingTormentor=function() return bot.mode=='tormentor' end
J.IsRoshan=function(u) return u~=nil and u.kind=='roshan' end
J.IsTormentor=function(u) return u~=nil and u.kind=='tormentor' end
J.IsAttacking=function(u) return u.attacking==true end
J.IsCore=function(u) return u.core~=false end
J.IsHaveAegis=function(u) return u.aegis==true end
J.CanBeAttacked=function(u) return not u.attackImmune and not u.invulnerable end
J.IsKeyWordUnit=function(word,u) return u:GetUnitName():find(word)~=nil end
J.GetHP=function(u) return u.hp/u.maxhp end
J.IsLocationInChrono=function() return bot.hazard=='chrono' end
J.IsLocationInBlackHole=function() return bot.hazard=='blackhole' end
J.IsLocationInArena=function() return bot.hazard=='arena' end
DAMAGE_TYPE_ALL=7
local native=H.load('npc_dota_hero_doom_bringer','pos_3')
local copy=H.realDofile('bots/FunLib/rubick_hero/doom_bringer.lua')
local function reset()
    actions,enemies,allies,creeps,items,slots={},{},{},{},{},{}
    for k,value in pairs(unit(0)) do bot[k]=value end
    bot.team=2;bot.mode='idle';bot.hp=1000;bot.mana=1000
    bot.fight,bot.channel,bot.using,bot.silenced,bot.queued,bot.stunned,bot.rooted,bot.scepter,bot.attacking=false,false,false,false,false,false,false,false,false
    bot.target,bot.hazard,bot.killDamage,bot.killDelay=nil,nil,nil,nil;bot.disarmed=false
    for _,a in pairs(abilities) do a.castable=false;a.trained=false;a.toggle=false end
    earth.values.is_permanent=0;devour.values.can_target_ancient=0;doom.values.scepter_aura_radius=0
end
local function cast(module,a)
    if module==native then module.SkillsComplement() else module.ConsiderStolenSpell(a) end
end
for _,module in ipairs({native,copy}) do
    reset();devour.castable=true;local creep=unit(299,0,'creep');creep.name='npc_dota_creep_ranged';creeps={creep};cast(module,devour)
    assert(#actions==1 and actions[1].target==creep,'legal lane/neutral Devour')
    for _,flag in ipairs({'range','level','ancient','ally','hero','illusion','invulnerable','immune','boss'}) do
        reset();devour.castable=true;creep=unit(299,0,'creep');creeps={creep}
        if flag=='range' then creep.x=301 elseif flag=='level' then creep.level=7 elseif flag=='ally' then creep.team=2
        elseif flag=='hero' then creep.kind='hero' elseif flag=='boss' then creep.kind='roshan' else creep[flag]=true end
        cast(module,devour);assert(#actions==0,'Devour refuses '..flag)
    end
    reset();devour.castable=true;creep=unit(200,0,'creep');creep.ancient=true;creeps={creep};devour.values.can_target_ancient=1
    cast(module,devour);assert(#actions==1,'live ancient upgrade eligibility')
    reset();devour.castable=true;bot.mode='lane';creep=unit(200,0,'creep');creep.name='npc_dota_creep_ranged';local melee=unit(100,0,'creep');melee.hp=3000;creeps={melee,creep}
    cast(module,devour);assert(actions[1].target==creep,'lane ranged creep prioritized')
    reset();devour.castable=true;creep=unit(200,0,'creep');creep.name='npc_dota_neutral_centaur_khan';melee=unit(100,0,'creep');melee.hp=3000;creeps={melee,creep}
    cast(module,devour);assert(actions[1].target==creep,'pre-fight control creep prioritized')
    reset();blade.castable=true;local enemy=unit(200);enemy.channel=true;enemies={enemy}
    cast(module,blade);assert(#actions==1 and actions[1].target==enemy,'melee channel interrupt')
    enemy.x=201;items[0]=lens;supremacy.trained=true;actions={};cast(module,blade);assert(#actions==0,'attack spell does not gain Lens/Supremacy range')
    enemy.x=190;bot.disarmed=true;cast(module,blade);assert(#actions==0,'disarmed caster cannot interrupt with attack spell')
    reset();blade.castable=true;enemy=unit(190);enemy.hp=400;enemies={enemy};cast(module,blade)
    assert(#actions==1 and bot.killDamage==434 and bot.killDelay==4.5,'full per-second Blade burn and attack delay')
    enemy.hp=430;enemy.regen=10;actions={};cast(module,blade);assert(#actions==0,'regen-aware impact budget')
    for _,flag in ipairs({'immune','attackImmune','protected','blocked','reflection','allyReflection'}) do
        reset();blade.castable=true;enemy=unit(190);enemy.hp=100;enemies={enemy}
        if flag=='reflection' then enemy.mods.modifier_antimage_counterspell=true elseif flag=='allyReflection' then enemy.mods.modifier_antimage_counterspell_ally=true else enemy[flag]=true end
        cast(module,blade);assert(#actions==0,'Blade guard '..flag)
    end
    reset();earth.castable=true;bot.mode='farm';bot.attacking=true;creeps={unit(100,0,'creep'),unit(200,0,'creep'),unit(300,0,'creep')};doom.trained=true;bot.mana=339
    cast(module,earth);assert(#actions==0,'farm reserves Doom mana');bot.mana=340;cast(module,earth);assert(#actions==1,'farm earth uses actual creep list')
    reset();earth.castable=true;bot.mode='retreat';bot.damaged=true;enemy=unit(600);enemy.immune=true;enemy.chasing=bot;enemies={enemy}
    cast(module,earth);assert(#actions==1,'movement escape remains useful vs BKB')
    reset();earth.castable=true;bot.hp=500;doom.trained=true;bot.mana=340;cast(module,earth);assert(#actions==1,'safe sustain')
    for _,mod in ipairs({'modifier_ice_blast','modifier_doom_bringer_doom'}) do
        bot.mods[mod]=true;actions={};cast(module,earth);assert(#actions==0,'blocked sustain alone does not spend mana');bot.mods[mod]=nil
    end
    reset();earth.castable=true;earth.values.is_permanent=1;cast(module,earth);assert(#actions==1,'permanent earth toggles on');earth.toggle=true;actions={};cast(module,earth);assert(#actions==0,'never toggles permanent earth off each tick')
    reset();doom.castable=true;bot.mode='attack';enemy=unit(400);enemy.immune=true;enemy.disabled=true;enemies={enemy};bot.target=enemy
    cast(module,doom);assert(#actions==1 and actions[1].target==enemy,'Doom pierces BKB and can follow short control')
    for _,flag in ipairs({'range','blocked','reflection','allyReflection','already','aura','selfAura','aegis','illusion'}) do
        reset();doom.castable=true;bot.mode='attack';enemy=unit(400);enemies={enemy};bot.target=enemy
        if flag=='range' then enemy.x=401 elseif flag=='reflection' then enemy.mods.modifier_antimage_counterspell=true
        elseif flag=='allyReflection' then enemy.mods.modifier_antimage_counterspell_ally=true
        elseif flag=='already' then enemy.mods.modifier_doom_bringer_doom=true
        elseif flag=='aura' then enemy.mods.modifier_doom_bringer_doom_aura_enemy=true
        elseif flag=='selfAura' then enemy.mods.modifier_doom_bringer_doom_aura_self=true else enemy[flag]=true end
        cast(module,doom);assert(#actions==0,'Doom guard '..flag)
    end
    reset();doom.castable=true;bot.mode='attack';enemy=unit(300);enemy.core=false;enemy.threat=100;local core=unit(350);core.threat=100;enemies={enemy,core};bot.target=enemy
    cast(module,doom);assert(actions[1].target==core,'important threat outranks incidental proper target')
    reset();doom.castable=true;bot.mode='attack';bot.scepter=true;doom.values.scepter_aura_radius=350
    enemy=unit(100);enemy.blocked=true;enemy.immune=true;core=unit(300);core.mods.modifier_antimage_counterspell=true;enemies={enemy,core}
    cast(module,doom);assert(#actions==1 and actions[1].target==bot,'Scepter self aura bypasses enemy targeted protections')
    bot.mods.modifier_doom_bringer_doom_aura_self=true;actions={};cast(module,doom);assert(#actions==0,'existing self aura is not recast after Refresher');bot.mods.modifier_doom_bringer_doom_aura_self=nil
    core.speed=200;actions={};cast(module,doom);assert(#actions==0,'self aura validates predicted coverage')
    reset();doom.castable=true;bot.mode='attack';enemy=unit(850);enemies={enemy};bot.target=enemy;items[0]=blink;blink.castable=true
    cast(module,doom);assert(#actions==2 and actions[1].name==blink.name and actions[2].target==enemy,'bounded Blink Doom queue')
    reset();doom.castable=true;bot.mode='attack';enemy=unit(620);enemies={enemy};bot.target=enemy;items[0]=lens
    cast(module,doom);assert(#actions==1,'Lens cast reach')
    reset();doom.castable=true;bot.mode='attack';enemy=unit(639);enemies={enemy};bot.target=enemy;supremacy.trained=true
    cast(module,doom);assert(#actions==1,'Supremacy cast reach');bot.mods.modifier_break=true;actions={};cast(module,doom);assert(#actions==0,'Break removes range bonus')
    reset();doom.castable=true;bot.mode='attack';enemy=unit(300);enemies={enemy};bot.target=enemy;bot.channel=true;cast(module,doom);assert(#actions==0,'channel preserved')
end
reset();blade.castable=true;doom.castable=true;bot.mode='attack';local enemy=unit(190);enemy.channel=true;enemies={enemy};bot.target=enemy
native.SkillsComplement();assert(actions[1].name==blade.name,'cheap interrupt before long-cooldown Doom')
for _,flag in ipairs({'root','rupture','hazard','mana','outnumber','prediction'}) do
    reset();doom.castable=true;bot.mode='attack';enemy=unit(850);enemies={enemy};bot.target=enemy;items[0]=blink;blink.castable=true
    if flag=='root' then bot.rooted=true elseif flag=='rupture' then bot.mods.modifier_bloodseeker_rupture=true
    elseif flag=='hazard' then bot.hazard='chrono' elseif flag=='mana' then bot.mana=249
    elseif flag=='outnumber' then enemies[2]=unit(900) elseif flag=='prediction' then enemy.speed=3000 end
    native.SkillsComplement();assert(#actions==0,'Blink guard '..flag)
end
reset();stomp.castable=true;slots[3]=stomp;enemy=unit(200);enemy.channel=true;enemies={enemy}
native.SkillsComplement();assert(actions[1].name==stomp.name and actions[1].target==nil,'acquired Stomp actual no-target shape')
doom.castable=true;bot.mode='attack';bot.target=enemy;enemy.x=225;actions={}
native.SkillsComplement();assert(actions[1].name==stomp.name,'acquired channel interruption precedes Doom')
doom.castable=false;bot.mode='idle'
enemy.x=251;actions={};native.SkillsComplement();assert(#actions==0,'Stomp real coverage')
reset();purge.castable=true;slots[3]=purge;enemy=unit(300);enemy.mods.modifier_necrolyte_ghost_shroud_active=true;enemies={enemy};bot.target=enemy
native.SkillsComplement();assert(actions[1].name==purge.name and actions[1].target==enemy,'reviewed Purge dispels Ghost Shroud')
reset();lightning.castable=true;slots[4]=lightning;bot.mode='lane';enemy=unit(800);enemies={enemy};bot.target=enemy;doom.trained=true;bot.mana=309
native.SkillsComplement();assert(#actions==0,'acquired poke reserves Doom');bot.mana=310;native.SkillsComplement();assert(actions[1].name==lightning.name,'reviewed Lightning uses real target shape')
reset();local unknown=ability('unknown_creep_spell',900,0,{});unknown.castable=true;slots[3]=unknown;bot.mode='attack';bot.target=unit(200)
native.SkillsComplement();assert(#actions==0,'unknown acquired effect remains withheld')
print('Doom ability scenarios passed')
