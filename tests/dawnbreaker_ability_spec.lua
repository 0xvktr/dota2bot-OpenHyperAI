-- Current native/copied spells, legal ally anchors, and real pending Hammer recall.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0
DAMAGE_TYPE_PHYSICAL=1; DAMAGE_TYPE_MAGICAL=2; UNIT_LIST_ALLIED_HEROES=1
local enemies, allies, creeps, neutrals, actions, spells = {}, {}, {}, {}, {}, {}
local now, unsafe, impassable, lens, bkb = 0, false, false, nil, nil
function DotaTime() return now end
local function dist(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
function GetUnitToUnitDistance(a,b) return dist(a:GetLocation(),b:GetLocation()) end
function GetUnitToLocationDistance(a,b) return dist(a:GetLocation(),b) end
function IsLocationPassable() return not impassable end
function GetUnitList() return allies end
local Unit={}; Unit.__index=Unit
local function U(x,y,team)
    return setmetatable({x=x,y=y or 0,team=team or 2,hp=1000,maxhp=1000,mods={},valid=true,
        mode='idle',vx=0,vy=0,hero=true},Unit)
end
function Unit:GetLocation() return Vector(self.x,self.y,0) end
function Unit:GetExtrapolatedLocation(t) return Vector(self.x+self.vx*t,self.y+self.vy*t,0) end
function Unit:GetTeam() return self.team end
function Unit:IsNull() return not self.valid end
function Unit:IsAlive() return self.hp>0 end
function Unit:IsHero() return self.hero end
function Unit:IsIllusion() return self.illusion==true end
function Unit:IsInvulnerable() return self.invulnerable==true end
function Unit:IsMagicImmune() return self.immune==true end
function Unit:IsAttackImmune() return self.attackImmune==true end
function Unit:IsStunned() return self.stunned==true end
function Unit:IsRooted() return self.rooted==true end
function Unit:IsDisarmed() return self.disarmed==true end
function Unit:IsChanneling() return self.channeling==true end
function Unit:IsCastingAbility() return self.casting==true end
function Unit:IsUsingAbility() return self.using==true end
function Unit:HasModifier(n) return self.mods[n]==true end
function Unit:WasRecentlyDamagedByAnyHero() return self.recent==true end
function Unit:IsAncientCreep() return self.ancient==true end
function Unit:GetNearbyHeroes(r,enemy)
    local out={}
    for _,u in ipairs(allies) do if (u.team~=self.team)==enemy and dist(u:GetLocation(),self:GetLocation())<=r then out[#out+1]=u end end
    for _,u in ipairs(enemies) do if (u.team~=self.team)==enemy and dist(u:GetLocation(),self:GetLocation())<=r then out[#out+1]=u end end
    return out
end
setmetatable(bot,Unit)
function bot:GetAbilityByName(n) return spells[n] end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:GetAttackDamage() return 100 end
function bot:HasShard() return self.shard==true end
function bot:GetNearbyLaneCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:Action_UseAbilityOnLocation(a,p) actions[#actions+1]={ability=a,location=p} end
function bot:Action_UseAbility(a) actions[#actions+1]={ability=a} end
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={ability=a,queued=true} end
function bot:ActionQueue_UseAbilityOnLocation(a,p) actions[#actions+1]={ability=a,location=p,queued=true} end
local function S(name,cost,point,values)
    local s={name=name,cost=cost,point=point,values=values,ready=false,trained=true}
    function s:GetName() return self.name end
    function s:IsNull() return false end
    function s:IsHidden() return self.hidden==true end
    function s:IsFullyCastable() return self.ready and bot.mana>=self.cost end
    function s:IsTrained() return self.trained end
    function s:GetManaCost() return self.cost end
    function s:GetCastPoint() return self.point end
    function s:GetChannelTime() return 1.7 end
    function s:GetSpecialValueInt(k) return self.values[k] or 0 end
    function s:GetSpecialValueFloat(k) return self.values[k] or 0 end
    spells[name]=s; return s
end
local star=S('dawnbreaker_fire_wreath',110,.1,{swipe_radius=300,duration=1.1,movement_speed=215,total_attacks=3,swipe_damage=70,smash_damage=70})
local hammer=S('dawnbreaker_celestial_hammer',130,.2,{range=1300,projectile_speed=1600,projectile_radius=200,hammer_damage=140,pause_duration=2})
local converge=S('dawnbreaker_converge',0,0,{})
local solar=S('dawnbreaker_solar_guardian',200,.1,{radius=500,max_offset_distance=350,airtime_duration=.8})
J.CanCastAbility=function(a) return a~=nil and a.trained and not a.hidden and a:IsFullyCastable() end
J.CanNotUseAbility=function(u) return u.channeling or u.casting or u.using or u.queued or u.silenced end
J.IsItemAvailable=function(n) if n=='item_aether_lens' then return lens elseif n=='item_black_king_bar' then return bkb end end
J.IsValid=function(u) return u~=nil and u.valid and u.hp>0 and not u.invulnerable end
J.IsValidHero=function(u) return J.IsValid(u) and u.hero end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnNonMagicImmune=function(u) return not u.immune end
J.GetNearbyHeroes=function(u,r,e) return u:GetNearbyHeroes(r,e) end
J.GetProperTarget=function(u) return u.target end
J.GetHP=function(u) return u.hp/u.maxhp end
J.IsGoingOnSomeone=function(u) return u.mode=='attack' end
J.IsRetreating=function(u) return u.mode=='retreat' end
J.IsFarming=function(u) return u.mode=='farm' end
J.IsPushing=function(u) return u.mode=='push' end
J.IsDefending=function(u) return u.mode=='defend' end
J.IsLaning=function(u) return u.mode=='lane' end
J.GetRemainStunTime=function(u) return u.stunTime or 0 end
J.IsInTeamFight=function(u) return u.fight==true end
J.IsDisabled=function(u) return u.disabled==true end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.GetEscapeLoc=function() return Vector(-10000,0,0) end
J.IsLocationInChrono=function() return unsafe end
J.IsLocationInBlackHole=function() return false end
J.HasBreakModifier=function(u) return u.mods.modifier_break==true end
J.WillKillTarget=function(u,d,t,delay)
    u.killDelay=delay
    return d*(u.mitigation or 1)>u.hp+(u.regen or 0)*delay+.8
end
local function reset()
    enemies,allies,creeps,neutrals,actions={}, {}, {}, {}, {}
    now=0;unsafe=false;impassable=false;lens=nil;bkb=nil
    for k in pairs(bot) do if type(bot[k])~='function' then bot[k]=nil end end
    for k,v in pairs(U(0)) do bot[k]=v end
    bot.mana=1000;allies={bot};bot.shard=false
    spells.rubick_arcane_supremacy=nil
    for _,s in pairs({star,hammer,converge,solar}) do s.ready=false;s.hidden=false;s.trained=true;spells[s.name]=s end
    hammer.values.range=1300;hammer.values.projectile_speed=1600
end
local function enemy(x,y,hp) local u=U(x,y,3);u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function ally(x,y,hp) local u=U(x,y);u.hp=hp or 1000;allies[#allies+1]=u;return u end
local function creep(x,y,hp) local u=U(x,y,3);u.hero=false;u.hp=hp or 1000;creeps[#creeps+1]=u;return u end
local function load(copy)
    reset()
    return copy and H.realDofile('bots/FunLib/rubick_hero/dawnbreaker.lua') or H.load('npc_dota_hero_dawnbreaker','pos_3')
end
local function tick(X,copy,a)
    if copy then return X.ConsiderStolenSpell(a) else X.SkillsComplement();return #actions>0 end
end
for _,copy in ipairs({false,true}) do
    local label=copy and 'copy' or 'native'
    local X=load(copy);star.ready=true;bot.mode='attack';bot.target=enemy(220);bot.target.immune=true;bot.target.disabled=true
    assert(tick(X,copy,star) and actions[1].ability==star,label..' physical Starbreaker follows allied control through debuff immunity')
    X=load(copy);star.ready=true;local e=enemy(220,0,400);e.disabled=true;e.stunned=true;e.stunTime=2
    assert(tick(X,copy,star),label..' full three-attack combo finishes stationary controlled target')
    assert(math.abs(e.killDelay-1.2)<0.0001,label..' full combo estimate includes completion time')
    X=load(copy);star.ready=true;e=enemy(220,0,400);e.stunned=true;e.stunTime=.2
    assert(not tick(X,copy,star),label..' brief stun cannot guarantee all three attacks')
    X=load(copy);star.ready=true;enemy(220,0,400)
    assert(not tick(X,copy,star),label..' does not assume all three attacks kill a freely moving idle target')
    X=load(copy);star.ready=true;bot.mode='push';bot.fight=true;enemy(220);enemy(250,50);creep(100);creep(140);creep(180)
    assert(tick(X,copy,star) and actions[1].location.x>=220,label..' real close teamfight cluster takes priority over wave farming')
    X=load(copy);star.ready=true;bot.mode='attack';bot.target=enemy(220);bot.target.attackImmune=true
    assert(not tick(X,copy,star),label..' respects physical attack immunity')
    X=load(copy);star.ready=true;bot.mode='retreat';bot.recent=true;bot.shard=true;enemy(600)
    assert(tick(X,copy,star) and actions[1].location.x<0,label..' Shard escape casts toward safety')
    X=load(copy);star.ready=true;bot.mode='retreat';bot.recent=true;bot.shard=true;bot.mods.modifier_bloodseeker_rupture=true;enemy(200).chasing=bot
    assert(not tick(X,copy,star),label..' forced Starbreaker escape is withheld during Rupture')
    X=load(copy);star.ready=true;bot.mode='farm';local a=creep(100);local b=creep(150);a.ancient=true;b.ancient=true;neutrals={a,b}
    assert(tick(X,copy,star),label..' farms a real two-ancient cluster')
    X=load(copy);star.ready=true;bot.mode='lane';a=creep(100,0,130);a.mitigation=.4
    assert(not tick(X,copy,star),label..' lane last hit respects armor')
    X=load(copy);hammer.ready=true;bot.mode='attack';bot.target=enemy(900);bot.target.mods.modifier_antimage_counterspell_ally=true
    assert(tick(X,copy,hammer),label..' point-target Hammer is not blocked by unit-target reflection')
    X=load(copy);hammer.ready=true;bot.mode='attack';bot.target=enemy(1400)
    assert(not tick(X,copy,hammer),label..' Hammer never uses fake movement range')
    lens={GetSpecialValueInt=function() return 225 end};assert(tick(X,copy,hammer),label..' active Lens extends legal Hammer reach')
    X=load(copy);hammer.ready=true;bot.mode='attack';bot.target=enemy(1500)
    S('rubick_arcane_supremacy',0,0,{cast_range=240})
    assert(tick(X,copy,hammer),label..' unbroken Supremacy extends Hammer range')
    actions={};bot.mods.modifier_break=true
    assert(not tick(X,copy,hammer),label..' known Break removes passive range')
    X=load(copy);hammer.ready=true;bot.mode='attack';bot.target=enemy(2500);hammer.values.range=2340;hammer.values.projectile_speed=2880
    assert(not tick(X,copy,hammer),label..' does not apply resolved talent twice')
    bot.target.x=2200;assert(tick(X,copy,hammer),label..' uses resolved range talent once')
    X=load(copy);hammer.ready=true;bot.mode='attack';bot.target=enemy(1200);bot.target.vx=400
    assert(not tick(X,copy,hammer),label..' moving prediction cannot exceed legal range')
    X=load(copy);hammer.ready=true;local near=enemy(800,0,135);near.regen=20
    assert(not tick(X,copy,hammer),label..' projectile delay excludes regenerating near-threshold lethal')
    X=load(copy);hammer.ready=true;near=enemy(1000,0,120.5);near.vx=200;near.regen=20
    assert(not tick(X,copy,hammer),label..' moving lethal estimate uses actual predicted projectile travel')
    X=load(copy);hammer.ready=true;enemy(800,0,220)
    assert(not tick(X,copy,hammer),label..' does not guarantee return strike or burn damage')
    X=load(copy);hammer.ready=true;bot.mode='push';creep(500,0);creep(800,20);creep(1000,-30)
    assert(tick(X,copy,hammer),label..' waveclear uses real aligned projectile targets')
    X=load(copy);hammer.ready=true;bot.mode='push';creep(800,0);creep(800,450);creep(800,-450)
    assert(not tick(X,copy,hammer),label..' rejects spread wave centroid guesses')
    X=load(copy);hammer.ready=true;bot.mode='push';bot.mana=300;creep(500);creep(700);creep(900)
    assert(not tick(X,copy,hammer),label..' waveclear reserves Solar mana')
    X=load(copy);solar.ready=true;local remote=ally(5000,0,350);remote.recent=true;remote.invulnerable=true;remote.vx=400;enemy(5600)
    assert(tick(X,copy,solar),label..' saves remote invulnerable allied anchor')
    assert(dist(remote:GetLocation(),actions[1].location)<=350.001,label..' predicts inside current legal ally offset')
    X=load(copy);solar.ready=true;remote=ally(5000,0,350);remote.recent=true;remote.mods.modifier_ice_blast=true;enemy(5050)
    assert(not tick(X,copy,solar),label..' refuses a heal-only trip when healing is blocked')
    X=load(copy);solar.ready=true;remote=ally(5000,0,350);remote.recent=true;remote.illusion=true;enemy(5050)
    assert(not tick(X,copy,solar),label..' excludes illusion Solar anchor')
    X=load(copy);solar.ready=true;remote=ally(5000);remote.mode='attack';enemy(5050).immune=true;enemy(5100).immune=true
    assert(tick(X,copy,solar),label..' joins ally initiation even against immune enemies')
    X=load(copy);solar.ready=true;remote=ally(5000);remote.mode='attack';for i=1,5 do enemy(5000+i*30) end
    assert(not tick(X,copy,solar),label..' avoids landing alone into five heroes')
    X=load(copy);solar.ready=true;remote=ally(5000,0,350);remote.recent=true;enemy(5050);unsafe=true
    assert(not tick(X,copy,solar),label..' refuses hazardous landing')
    X=load(copy);solar.ready=true;remote=ally(5000,0,350);remote.recent=true;enemy(5050);enemy(100);bot.recent=true
    assert(not tick(X,copy,solar),label..' recent solo caster pressure also requires channel protection')
    X=load(copy);solar.ready=true;remote=ally(5000,0,350);remote.recent=true;enemy(5050);enemy(100);enemy(200)
    assert(not tick(X,copy,solar),label..' does not start exposed global channel without protection')
    bkb=S('item_black_king_bar',50,0,{});bkb.ready=true;bot.mana=230
    assert(not tick(X,copy,solar),label..' BKB cannot consume required Solar mana')
    bot.mana=1000;assert(tick(X,copy,solar),label..' protected global cast succeeds')
    assert(#actions==2 and actions[1].ability==bkb and actions[1].queued and actions[2].ability==solar and actions[2].queued,
        label..' BKB and Solar are sequential queued actions')
    X=load(copy);hammer.ready=true;bot.mode='attack';bot.target=enemy(1000);assert(tick(X,copy,hammer))
    actions={};hammer.ready=false;converge.ready=true;now=1
    assert(tick(X,copy,hammer) and actions[1].ability==converge,label..' real Hammer history enables linked cooldown recall')
    X=load(copy);hammer.ready=true;bot.mode='attack';bot.target=enemy(1000);assert(tick(X,copy,hammer))
    actions={};hammer.ready=false;converge.ready=true;now=3
    assert(not tick(X,copy,hammer),label..' does not recall toward obsolete stationary point after automatic return starts')
    X=load(copy);converge.ready=true;bot.mode='attack';bot.target=enemy(1000)
    assert(not tick(X,copy,converge),label..' never invents Hammer destination without history')
    X=load(copy);hammer.ready=true;bot.mode='retreat';bot.recent=true;enemy(300);assert(tick(X,copy,hammer))
    assert(actions[1].location.x<0,label..' retreat Hammer aims toward escape')
    hammer.ready=false;converge.ready=true;now=1.5;actions={};bot.rooted=true
    assert(not tick(X,copy,hammer),label..' rooted recall withheld')
    bot.rooted=false;bot.mods.modifier_bloodseeker_rupture=true
    assert(not tick(X,copy,hammer),label..' Rupture recall withheld')
    bot.mods={};impassable=true;assert(not tick(X,copy,hammer),label..' impassable recall withheld')
    impassable=false;converge.hidden=true;assert(not tick(X,copy,hammer),label..' hidden linked recall withheld')
    converge.hidden=false;spells[converge.name]=nil;assert(not tick(X,copy,hammer),label..' absent Rubick linked recall safe')
    spells[converge.name]=converge;bot.channeling=true;assert(not tick(X,copy,hammer),label..' unrelated channels preserved')
    bot.channeling=false;bot.queued=true;assert(not tick(X,copy,hammer),label..' existing queue preserved')
    bot.queued=false;now=10;assert(not tick(X,copy,hammer),label..' expired Hammer position never reused')
end
local X=load(false);solar.ready=true;hammer.ready=true;star.ready=true;bot.mode='farm';creep(100);creep(140);creep(180)
local remote=ally(5000,0,350);remote.recent=true;enemy(5050)
X.SkillsComplement();assert(actions[1].ability==solar,'native Solar save precedes farming')
X=load(false);hammer.ready=true;star.ready=true;bot.mode='attack';bot.target=enemy(250)
X.SkillsComplement();assert(actions[1].ability==star,'native close combo precedes throwing away Hammer')
local C=load(true)
assert(C.ConsiderStolenSpell(S('unrelated_spell',0,0,{}))==nil,'unrelated spell remains unhandled')
print('Dawnbreaker ability scenarios passed')
