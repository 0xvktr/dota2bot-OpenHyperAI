-- Earth Spirit decisions with actual invulnerable stones, charges, line geometry and linked spell gaps.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0
DAMAGE_TYPE_PHYSICAL=1; DAMAGE_TYPE_MAGICAL=2; UNIT_LIST_ALLIED_HEROES=1; UNIT_LIST_ALLIED_OTHER=2; ATTRIBUTE_STRENGTH=0
local enemies, allies, creeps, neutrals, actions, spells, stones = {}, {}, {}, {}, {}, {}, {}
local now, unsafe, impassable, lens, bkb = 0, false, false, nil, nil
function DotaTime() return now end
local function dist(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
function GetUnitToUnitDistance(a,b) return dist(a:GetLocation(),b:GetLocation()) end
function GetUnitToLocationDistance(a,b) return dist(a:GetLocation(),b) end
function IsLocationPassable() return not impassable end
function GetUnitList(t) return t==UNIT_LIST_ALLIED_OTHER and stones or allies end
local Unit={}; Unit.__index=Unit
local function U(x,y,team)
    return setmetatable({x=x,y=y or 0,team=team or 2,hp=1000,maxhp=1000,mods={},valid=true,
        mode='idle',vx=0,vy=0,hero=true},Unit)
end
function Unit:GetLocation() return Vector(self.x,self.y,0) end
function Unit:GetExtrapolatedLocation(t) return Vector(self.x+self.vx*t,self.y+self.vy*t,0) end
function Unit:GetTeam() return self.team end
function Unit:GetUnitName() return self.name or (self.hero and 'npc_dota_hero_earth_spirit' or 'npc_dota_creep_lane_ranged') end
function Unit:GetPlayerID() return self.player or 0 end
function Unit:IsSilenced() return self.silenced==true end
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
function bot:GetAttributeValue() return self.strength or 100 end
function bot:HasShard() return self.shard==true end
function bot:GetNearbyLaneCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:Action_UseAbilityOnLocation(a,p) actions[#actions+1]={ability=a,location=p} end
function bot:Action_UseAbilityOnEntity(a,u) actions[#actions+1]={ability=a,target=u} end
function bot:Action_UseAbility(a) actions[#actions+1]={ability=a} end
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={ability=a,queued=true} end
function bot:ActionQueue_UseAbilityOnLocation(a,p) actions[#actions+1]={ability=a,location=p,queued=true} end
local function S(name,cost,point,values)
    local s={name=name,cost=cost,point=point,values=values,ready=false,trained=true,range=0,charges=7}
    function s:GetName() return self.name end
    function s:GetCastRange() return self.range end
    function s:GetCurrentCharges() return self.charges end
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
local smash=S('earth_spirit_boulder_smash',100,0,{radius=180,rock_search_aoe=200,rock_damage=320,speed=900,rock_distance=2000})
smash.range=150
local roll=S('earth_spirit_rolling_boulder',50,0,{radius=160,speed=1000,rock_speed=1600,distance=800,rock_distance_multiplier=2,delay=.6,damage=90,damage_str=100})
roll.range=3000
local grip=S('earth_spirit_geomagnetic_grip',75,.1,{radius=180,rock_damage=300,pull_units_per_second=900,cast_range_heroes=700,total_pull_distance=1400})
grip.range=1300
local stone=S('earth_spirit_stone_caller',0,0,{rolling_offset_distance=150})
stone.range=1100
local magnetize=S('earth_spirit_magnetize',100,.2,{cast_radius=350,damage_per_second=135,damage_duration=6,rock_search_radius=600})
magnetize.range=350
local petrify=S('earth_spirit_petrify',150,.2,{ally_cast_range=500,damage=450,duration=2.4})
petrify.range=175
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
J.IsStuck=function(u) return u.stuck==true end
J.GetModifierTime=function(u,n) return u.times and u.times[n] or 0 end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected end
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
    enemies,allies,creeps,neutrals,actions,stones={},{},{},{},{},{}
    now=0;unsafe=false;impassable=false;lens=nil;bkb=nil
    for k in pairs(bot) do if type(bot[k])~='function' then bot[k]=nil end end
    for k,v in pairs(U(0)) do bot[k]=v end
    bot.mana=1000;bot.strength=100;allies={bot}
    spells.rubick_arcane_supremacy=nil
    for _,s in pairs({smash,roll,grip,stone,magnetize,petrify}) do s.ready=false;s.hidden=false;s.trained=true;s.charges=7;spells[s.name]=s end
    grip.values.cast_range_heroes=700
end
local function enemy(x,y,hp) local u=U(x,y,3);u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function ally(x,y,hp) local u=U(x,y);u.hp=hp or 1000;allies[#allies+1]=u;return u end
local function remnant(x,y,player)
    local u=U(x,y);u.hero=false;u.name='npc_dota_earth_spirit_stone';u.invulnerable=true;u.player=player or 0;stones[#stones+1]=u;return u
end
local function creep(x,y,hp) local u=U(x,y,3);u.hero=false;u.hp=hp or 1000;creeps[#creeps+1]=u;return u end
local function load(copy)
    reset()
    return copy and H.realDofile('bots/FunLib/rubick_hero/earth_spirit.lua') or H.load('npc_dota_hero_earth_spirit','pos_2')
end
local function tick(X,copy,a)
    if copy then return X.ConsiderStolenSpell(a) else X.SkillsComplement();return #actions>0 end
end
local MAG='modifier_earth_spirit_magnetize'
for _,copy in ipairs({false,true}) do
    local label=copy and 'copied' or 'native'
    local X=load(copy);roll.ready=true;enemy(600,0,180)
    assert(tick(X,copy,roll) and actions[1].ability==roll,label..' Roll lethal includes current Strength damage')
    X=load(copy);roll.ready=true;local e=enemy(600,0,180);e.regen=20
    assert(not tick(X,copy,roll),label..' delayed Roll lethal respects regeneration')
    X=load(copy);roll.ready=true;bot.mode='attack';bot.target=enemy(1300);spells[stone.name]=nil
    assert(not tick(X,copy,roll),label..' missing linked Stone cannot fabricate extended Roll')
    bot.target.x=650;assert(tick(X,copy,roll) and #actions==1,label..' standalone base Roll remains useful')
    X=load(copy);roll.ready=true;bot.mode='attack';bot.target=enemy(900);spells[stone.name]=nil;lens={GetSpecialValueInt=function() return 225 end}
    assert(not tick(X,copy,roll),label..' cast-range bonuses do not inflate physical Roll travel')
    X=load(copy);roll.ready=true;stone.ready=true;bot.mode='attack';bot.target=enemy(1400)
    assert(tick(X,copy,roll) and #actions==2 and actions[1].ability==stone and actions[2].ability==roll,label..' actual Stone then extended Roll queues in order')
    assert(actions[1].location.x==150 and actions[2].location.x==1400,label..' places Stone in front along chosen Roll path')
    X=load(copy);roll.ready=true;bot.mode='attack';bot.target=enemy(1400);remnant(100)
    assert(tick(X,copy,roll) and #actions==1,label..' existing invulnerable path Stone is reused without a charge')
    X=load(copy);roll.ready=true;bot.mode='attack';bot.target=enemy(1400);remnant(100,300)
    assert(not tick(X,copy,roll),label..' off-axis Stone does not extend Roll')
    X=load(copy);roll.ready=true;remnant(750);e=enemy(1400,0,150);e.regen=25
    assert(not tick(X,copy,roll),label..' far pickup timing includes ordinary travel before faster roll')
    X=load(copy);roll.ready=true;stone.ready=true;bot.mode='attack';bot.target=enemy(1400);enemy(400)
    assert(not tick(X,copy,roll),label..' intervening hero prevents reaching intended Roll target')
    X=load(copy);roll.ready=true;enemy(600).channeling=true;enemies[1].immune=true
    assert(not tick(X,copy,roll),label..' channel predicate cannot bypass immunity guard')
    X=load(copy);roll.ready=true;stone.ready=true;bot.mode='retreat';bot.recent=true;enemy(300)
    assert(tick(X,copy,roll) and actions[2].location.x==-1600,label..' retreat Roll uses true boosted distance toward safety')
    X=load(copy);roll.ready=true;bot.mode='attack';bot.target=enemy(600);bot.rooted=true
    assert(not tick(X,copy,roll),label..' root blocks Roll')
    bot.rooted=false;bot.mods.modifier_bloodseeker_rupture=true
    assert(not tick(X,copy,roll),label..' Rupture blocks Roll movement')
    X=load(copy);roll.ready=true;bot.mode='retreat';enemy(-300)
    assert(not tick(X,copy,roll),label..' escape Roll cannot hit a pursuer in its path')
    X=load(copy);roll.ready=true;bot.mode='retreat';enemy(300);impassable=true
    assert(not tick(X,copy,roll),label..' escape landing must be passable')
    X=load(copy);grip.ready=true;local friend=ally(650,0,300);friend.recent=true;enemy(750)
    assert(tick(X,copy,grip) and actions[1].target==friend,label..' base Grip saves allies without Shard')
    X=load(copy);grip.ready=true;grip.values.cast_range_heroes=1050;friend=ally(1000,0,300);friend.recent=true;enemy(1150)
    assert(tick(X,copy,grip) and actions[1].target==friend,label..' uses resolved Shard ally range once')
    friend.x=1150;actions={};assert(not tick(X,copy,grip),label..' no doubled Shard ally range')
    lens={GetSpecialValueInt=function() return 225 end};assert(tick(X,copy,grip),label..' Lens extends actual ally pull range')
    for _,mod in ipairs({'modifier_legion_commander_duel','modifier_faceless_void_chronosphere_freeze','modifier_enigma_black_hole_pull','modifier_bloodseeker_rupture'}) do
        X=load(copy);grip.ready=true;friend=ally(650,0,300);friend.recent=true;friend.mods[mod]=true;enemy(750)
        assert(not tick(X,copy,grip),label..' pull withheld during '..mod)
    end
    X=load(copy);grip.ready=true;friend=ally(650,0,300);friend.recent=true;enemy(750);enemy(300)
    assert(not tick(X,copy,grip),label..' does not pull an ally into threatened caster')
    X=load(copy);grip.ready=true;remnant(1200);e=enemy(1000,0,282);e.regen=40;e.vx=-400
    assert(not tick(X,copy,grip),label..' moving-away Grip target regeneration includes projected pull travel')
    X=load(copy);grip.ready=true;bot.mode='attack';bot.target=enemy(900);local old=remnant(1100)
    assert(tick(X,copy,grip) and actions[1].target==old,label..' actual invulnerable Stone is pulled through target')
    X=load(copy);grip.ready=true;bot.mode='attack';bot.target=enemy(900);remnant(1100,500)
    assert(not tick(X,copy,grip),label..' nearby off-line remnant does not imply a hit')
    X=load(copy);grip.ready=true;stone.ready=true;bot.mode='attack';bot.target=enemy(900)
    assert(tick(X,copy,grip) and #actions==2 and actions[1].location.x==1000,label..' Grip places a legal stone behind target then pulls')
    X=load(copy);grip.ready=true;stone.ready=true;bot.mode='attack';bot.target=enemy(1150)
    assert(not tick(X,copy,grip),label..' stone creation cannot exceed Stone Caller range even when Grip reaches')
    X=load(copy);grip.ready=true;bot.mode='attack';bot.target=enemy(1000);bot.target.mods.modifier_antimage_counterspell_ally=true;remnant(1100)
    assert(tick(X,copy,grip),label..' pulling friendly Stone is not a reflected enemy unit cast')
    X=load(copy);grip.ready=true;enemy(900).channeling=true;remnant(1100)
    assert(not tick(X,copy,grip),label..' does not claim silence alone interrupts a channel')
    X=load(copy);grip.ready=true;bot.mode='attack';bot.target=enemy(50);remnant(1700);S('rubick_arcane_supremacy',0,0,{cast_range=240});lens={GetSpecialValueInt=function() return 225 end}
    assert(not tick(X,copy,grip),label..' extended Grip respects maximum pull travel and hit radius')
    X=load(copy);smash.ready=true;remnant(-150);e=enemy(900,0,294);e.regen=25
    assert(not tick(X,copy,smash),label..' Smash damage timing starts at actual existing Stone behind caster')
    X=load(copy);smash.ready=true;remnant(100);e=enemy(900,0,290);e.regen=30;e.vx=300
    assert(not tick(X,copy,smash),label..' moving Smash impact includes regeneration until predicted hit')
    X=load(copy);smash.ready=true;remnant(-195);bot.mode='attack';bot.target=enemy(1990)
    assert(not tick(X,copy,smash),label..' actual stone origin bounds final projectile endpoint')
    X=load(copy);smash.ready=true;stone.ready=true;bot.mode='attack';bot.target=enemy(1500)
    assert(tick(X,copy,smash) and #actions==2 and actions[2].location.x==100,label..' remnant Smash aims with legal nearby point instead of walking to far enemy')
    assert(actions[1].location.x==10,label..' new stone is nearest and on firing line')
    X=load(copy);smash.ready=true;bot.mode='attack';bot.target=enemy(1500);remnant(150)
    assert(tick(X,copy,smash) and #actions==1,label..' existing invulnerable stone kick requires no linked Caller')
    X=load(copy);smash.ready=true;bot.mode='attack';bot.target=enemy(1500);remnant(0,199)
    assert(not tick(X,copy,smash),label..' off-axis stone cannot be treated as a long-range projectile hit')
    X=load(copy);smash.ready=true;bot.mode='attack';bot.target=enemy(1500);remnant(50,190);remnant(198)
    assert(not tick(X,copy,smash),label..' cannot select farther aligned stone while closer wrong stone is auto-prioritized')
    X=load(copy);smash.ready=true;bot.mode='retreat';e=enemy(100);e.chasing=bot
    assert(tick(X,copy,smash) and actions[1].target==e,label..' direct enemy kick peels a close pursuer without Stones')
    for _,mod in ipairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally'}) do
        X=load(copy);smash.ready=true;bot.mode='retreat';e=enemy(100);e.chasing=bot;e.mods[mod]=true
        assert(not tick(X,copy,smash),label..' direct unit kick rejects '..mod)
    end
    X=load(copy);smash.ready=true;bot.mode='retreat';e=enemy(180);e.chasing=bot
    assert(not tick(X,copy,smash),label..' unit kick uses true short range')
    X=load(copy);smash.ready=true;stone.ready=true;stone.charges=2;bot.mode='push';creep(500);creep(700);creep(900)
    assert(not tick(X,copy,smash),label..' new farming stone preserves low charge reserve')
    remnant(100);assert(tick(X,copy,smash),label..' existing stone can clear aligned wave without spending charges')
    X=load(copy);smash.ready=true;stone.ready=true;bot.mode='push';creep(800);creep(800,400);creep(800,-400)
    assert(not tick(X,copy,smash),label..' no centroid guess for spread wave')
    X=load(copy);smash.ready=true;stone.ready=true;bot.mode='lane';local c=creep(600,0,200);c.mitigation=.5
    assert(not tick(X,copy,smash),label..' ranged last hit uses actual magical mitigation')
    c.hp=100;assert(tick(X,copy,smash),label..' can secure ranged creep with legal stone Smash')
    X=load(copy);magnetize.ready=true;bot.mode='attack';bot.target=enemy(300);bot.target.immune=true
    assert(tick(X,copy,magnetize) and actions[1].ability==magnetize,label..' Magnetize includes immune enemies')
    magnetize.ready=false;stone.ready=true;bot.mana=30;bot.target.mods[MAG]=true;bot.target.times={[MAG]=1.5};now=5;actions={}
    assert(X.UseMagnetizeStone() and actions[1].ability==stone,label..' own active Magnetize refresh needs only actual Stone mana')
    actions={};assert(not X.UseMagnetizeStone(),label..' refresh throttles engine modifier update latency')
    X=load(copy);stone.ready=true;e=enemy(300);e.mods[MAG]=true;e.times={[MAG]=1.5};now=5
    assert(not X.UseMagnetizeStone(),label..' does not claim another caster Magnetize without own cast history')
    X=load(copy);magnetize.ready=true;bot.mode='attack';bot.target=enemy(300);assert(tick(X,copy,magnetize))
    magnetize.ready=false;stone.ready=true;bot.target.mods[MAG]=true;bot.target.times={[MAG]=1.5};now=5;actions={};remnant(300)
    assert(not X.UseMagnetizeStone(),label..' existing owned refresh remnant avoids a duplicate charge')
    stones={};bot.target.hp=100;assert(not X.UseMagnetizeStone(),label..' avoids refreshing target dying to remaining damage')
    bot.target.hp=1000;spells[stone.name]=nil;assert(not X.UseMagnetizeStone(),label..' no assumed stolen Stone Caller')
    X=load(copy);magnetize.ready=true;bot.mode='attack';bot.target=enemy(300);assert(tick(X,copy,magnetize))
    magnetize.ready=false;stone.ready=true;bot.target.mods[MAG]=true;bot.target.times={[MAG]=1.5};now=5;actions={};bot.channeling=true
    assert(not X.UseMagnetizeStone(),label..' refresh preserves unrelated channel')
    bot.channeling=false;bot.queued=true;assert(not X.UseMagnetizeStone(),label..' refresh preserves existing action queue')
    X=load(copy);magnetize.ready=true;enemy(200).mods[MAG]=true;enemy(250).mods[MAG]=true
    assert(not tick(X,copy,magnetize),label..' fresh Magnetize not wasted on already affected group')
    X=load(copy);petrify.ready=true;friend=ally(450,0,250);friend.recent=true;enemy(600)
    assert(tick(X,copy,petrify) and #actions==1 and actions[1].target==friend,label..' Scepter ally protection has no random uncontrolled kick')
    X=load(copy);petrify.ready=true;bot.mode='attack';bot.target=enemy(170)
    assert(tick(X,copy,petrify) and actions[1].target==bot.target,label..' live Enchant ability captures close enemy')
    X=load(copy);petrify.ready=true;bot.mode='attack';bot.target=enemy(200)
    assert(not tick(X,copy,petrify),label..' enemy Enchant uses true short range')
    for _,mod in ipairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally'}) do
        X=load(copy);petrify.ready=true;bot.mode='attack';bot.target=enemy(170);bot.target.mods[mod]=true
        assert(not tick(X,copy,petrify),label..' Enchant rejects '..mod)
    end
    X=load(copy);petrify.ready=true;bot.hp=200;bot.recent=true;bot.rooted=true;enemy(100);enemy(200)
    assert(tick(X,copy,petrify) and actions[1].target==bot,label..' emergency self Enchant works when rolling is blocked')
end
local X=load(false);roll.ready=true;magnetize.ready=true;grip.ready=true;stone.ready=true;bot.mode='attack';bot.target=enemy(300)
X.SkillsComplement();assert(actions[1].ability==magnetize,'close native Magnetize precedes another nonlethal Roll')
X=load(false);grip.ready=true;roll.ready=true;stone.ready=true;bot.mode='attack';bot.target=enemy(1200)
local f=ally(650,0,250);f.recent=true;enemy(750)
X.SkillsComplement();assert(actions[1].ability==grip and actions[1].target==f,'native ally save precedes distant initiation')
local C=load(true)
assert(C.ConsiderStolenSpell(S('unrelated_spell',0,0,{}))==nil,'unrelated spell stays unhandled')
stone.ready=true;assert(C.ConsiderStolenSpell(stone)==false,'idle Stone Caller never spams remnants')
print('Earth Spirit ability scenarios passed')
