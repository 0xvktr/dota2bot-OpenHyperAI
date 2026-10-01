-- Chen native/copy decisions and real Zealot Martyrdom dispatch.
local H=dofile('tests/hero_harness.lua')
local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0;BOT_ACTION_DESIRE_HIGH=1;BOT_MODE_NONE=0
DAMAGE_TYPE_PHYSICAL=1;DAMAGE_TYPE_MAGICAL=2;DAMAGE_TYPE_PURE=4
UNIT_LIST_ALLIES=1;UNIT_LIST_ALLIED_HEROES=2;ABILITY_BEHAVIOR_UNIT_TARGET=8
local enemies,allies,owned,neutrals,creeps,actions={},{},{},{},{},{}
local Unit={};Unit.__index=Unit
local function U(x,name,team)
    return setmetatable({x=x,name=name or 'npc_dota_hero_ally',team=team or 2,hp=1000,maxhp=1000,
        level=3,player=0,mods={},mode='idle',valid=true},Unit)
end
function Unit:GetLocation() return Vector(self.x,0,0) end
function Unit:GetHealth() return self.hp end
function Unit:GetMaxHealth() return self.maxhp end
function Unit:GetUnitName() return self.name end
function Unit:GetTeam() return self.team end
function Unit:GetPlayerID() return self.player end
function Unit:GetLevel() return self.level end
function Unit:IsNull() return not self.valid end
function Unit:IsAlive() return self.hp>0 end
function Unit:IsHero() return self.name:find('hero',1,true)~=nil end
function Unit:IsCreep() return not self:IsHero() end
function Unit:IsAncientCreep() return self.ancient==true end
function Unit:IsIllusion() return self.illusion==true end
function Unit:IsInvulnerable() return self.invulnerable==true end
function Unit:IsMagicImmune() return self.immune==true end
function Unit:IsStunned() return self.stunned==true end
function Unit:IsHexed() return self.hexed==true end
function Unit:IsRooted() return self.rooted==true end
function Unit:IsNightmared() return self.nightmared==true end
function Unit:HasModifier(n) return self.mods[n]==true end
function Unit:WasRecentlyDamagedByAnyHero() return self.recent==true end
function Unit:GetNearbyHeroes(r,enemy)
    local out={};for _,u in ipairs(enemy and enemies or allies) do if math.abs(u.x-self.x)<=r then out[#out+1]=u end end;return out
end
function GetUnitToUnitDistance(a,b) return math.abs(a.x-b.x) end
function GetUnitList(t)
    if t==UNIT_LIST_ALLIED_HEROES then return allies end
    local out={};for _,u in ipairs(allies) do out[#out+1]=u end;for _,u in ipairs(owned) do out[#out+1]=u end;return out
end
setmetatable(bot,Unit)
local spells={}
local function S(name,range,cost,values)
    local s={name=name,range=range,cost=cost,values=values or {},ready=false,level=4}
    function s:GetName() return self.name end
    function s:GetCastRange() return self.range end
    function s:GetCastPoint() return 0.3 end
    function s:GetManaCost() return self.cost end
    function s:IsTrained() return self.level>0 end
    function s:GetLevel() return self.level end
    function s:GetSpecialValueInt(k) return self.values[k] or 0 end
    function s:GetDamageType() return self.damageType or 0 end
    function s:GetBehavior() return ABILITY_BEHAVIOR_UNIT_TARGET end
    spells[name]=s;return s
end
local penitence=S('chen_penitence',800,110,{damage=200})
local persuasion=S('chen_holy_persuasion',600,170,{level_req=6,max_units=4})
local favor=S('chen_divine_favor',1200,75)
local zealot=S('chen_zealot',0,50)
local hog=S('chen_hand_of_god',0,400,{heal_amount=400,does_purge=0,debuff_immune_radius=800})
local martyr=S('chen_martyrdom',500,0,{base_value=25,current_hp_pct=20,heal_factor=50,speed=1000})
local lens
function bot:GetAbilityByName(n) return spells[n] end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:HasScepter() return self.scepter==true end
function bot:HasShard() return self.shard==true end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:GetNearbyCreeps() return creeps end
function bot:Action_UseAbility(a) actions[#actions+1]={ability=a} end
function bot:Action_UseAbilityOnEntity(a,t) actions[#actions+1]={ability=a,target=t} end
J.CanCastAbility=function(a) return a~=nil and a.ready and a.level>0 and bot.mana>=a.cost end
J.CanNotUseAbility=function() return bot.channeling==true end
J.IsItemAvailable=function() return lens end
J.IsValid=function(u) return u~=nil and u.valid and u.hp>0 and not u.invulnerable end
J.IsValidHero=function(u) return J.IsValid(u) and u:IsHero() end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnNonMagicImmune=function(u) return not u.immune and not u.invulnerable end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected and not u.illusion end
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.GetNearbyHeroes=function(u,r,enemy) return u:GetNearbyHeroes(r,enemy) end
J.GetHP=function(u) return u.hp/u.maxhp end
J.GetProperTarget=function(u) return u.target end
J.IsGoingOnSomeone=function(u) return u.mode=='attack' end
J.IsRetreating=function(u) return u.mode=='retreat' end
J.IsLaning=function(u) return u.mode=='lane' end
J.IsFarming=function(u) return u.mode=='farm' end
J.IsPushing=function(u) return u.mode=='push' end
J.IsDefending=function(u) return u.mode=='defend' end
J.IsDoingRoshan=function() return false end
J.IsDoingTormentor=function() return false end
J.IsRoshan=function() return false end
J.IsTormentor=function() return false end
J.IsAttacking=function(u) return u.mode=='attack' end
J.IsInTeamFight=function(u) return u.fight==true end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.HasBreakModifier=function(u) return u.mods.modifier_break==true end
J.CanKillTarget=function(u,d,t) return u.hp<=d*(t==DAMAGE_TYPE_PURE and 1 or u.mitigation or 1) end
J.WillKillTarget=function(u,d,t,delay)
    u.lastKillDelay=delay
    return d*(t==DAMAGE_TYPE_PURE and 1 or u.mitigation or 1)>u.hp+(u.regen or 0)*delay+0.8
end
J.CheckBitfieldFlag=function() return true end
local Hero=H.load('npc_dota_hero_chen','pos_5')
local Copy=H.realDofile('bots/FunLib/rubick_hero/chen.lua')
local function reset()
    enemies,allies,owned,neutrals,creeps,actions={},{},{},{},{},{}
    lens=nil;spells.rubick_arcane_supremacy=nil
    for k,v in pairs(U(0,'npc_dota_hero_chen')) do bot[k]=v end
    bot.mana=1000;bot.scepter=false;bot.shard=false;bot.channeling=false;bot.target=nil;bot.recent=false;bot.fight=false
    allies={bot}
    for _,s in pairs(spells) do s.ready=false;s.level=4 end
    hog.values.does_purge=0
end
local function enemy(x,hp) local u=U(x,'npc_dota_hero_enemy',3);u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function ally(x,hp) local u=U(x);u.hp=hp or 1000;allies[#allies+1]=u;return u end
local function recruit(x,name,level,ancient)
    local u=U(x,name or 'npc_dota_neutral_harpy_storm',4);u.level=level or 3;u.ancient=ancient==true;neutrals[#neutrals+1]=u;return u
end
local function controlled(x,name,ancient,player)
    local u=U(x,name or 'npc_dota_neutral_alpha_wolf');u.mods.modifier_chen_holy_persuasion=true
    u.ancient=ancient==true;u.player=player or 0;owned[#owned+1]=u;return u
end
local function prime(copy,a) if copy then Copy.ConsiderStolenSpell(a);actions={} end end
for _,copy in ipairs({false,true}) do
    local X=copy and Copy or Hero
    local label=copy and 'stolen' or 'native'
    reset();bot.target=enemy(750);bot.mode='attack';prime(copy,penitence);penitence.ready=true
    assert(X.ConsiderPenitence()>0,label..' initiates for army attacks without requiring two attacking heroes')
    bot.target.stunned=true;assert(X.ConsiderPenitence()>0,label..' does not reject allied control')
    bot.target.loc=nil;bot.target.x=850;assert(X.ConsiderPenitence()==0,label..' no fake movement reach')
    lens={GetSpecialValueInt=function() return 225 end};assert(X.ConsiderPenitence()>0,label..' honors active Lens')
    lens=nil;bot.target.x=500
    for _,flag in ipairs({'immune','blocked','reflected','illusion'}) do
        bot.target[flag]=true;assert(X.ConsiderPenitence()==0,label..' excludes '..flag);bot.target[flag]=false
    end
    for _,mod in ipairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally'}) do
        bot.target.mods[mod]=true;assert(X.ConsiderPenitence()==0,label..' rejects '..mod);bot.target.mods[mod]=nil
    end
    reset();bot.target=enemy(1000);bot.mode='attack';S('rubick_arcane_supremacy',0,0,{cast_range=240})
    prime(copy,penitence);penitence.ready=true
    assert(X.ConsiderPenitence()>0,label..' Supremacy extends legal reach')
    bot.mods.modifier_break=true;assert(X.ConsiderPenitence()==0,label..' known Break removes passive range')
    reset();local e=enemy(500,180);e.mitigation=0.2;prime(copy,penitence);penitence.ready=true
    assert(X.ConsiderPenitence()>0,label..' reads current pure damage for kill')
    reset();bot.mode='retreat';e=enemy(600);e.chasing=bot;prime(copy,penitence);penitence.ready=true
    assert(X.ConsiderPenitence()>0,label..' slows escape pursuer regardless relative speed')
    reset();bot.mode='lane';enemy(600);prime(copy,penitence);penitence.ready=true
    assert(X.ConsiderPenitence()>0,label..' lane harassment supports creep pressure')
    reset();local threatened=ally(900,450);threatened.recent=true;bot.mode='retreat';e=enemy(1000);e.chasing=threatened
    prime(copy,favor);favor.ready=true
    local d,t=X.ConsiderDivineFavor();assert(d>0 and t==threatened,label..' Favor saves ally instead of targeting enemy')
    threatened.mods.modifier_chen_divine_favor_armor_buff=true
    assert(X.ConsiderDivineFavor()==0,label..' does not refresh active Favor')
    reset();bot.mode='push';controlled(300);controlled(400);prime(copy,favor);favor.ready=true
    d,t=X.ConsiderDivineFavor();assert(d>0 and t==bot,label..' self Favor protects current army')
    reset();local remote=ally(6000,300);remote.recent=true;remote.invulnerable=true
    prime(copy,hog);hog.ready=true
    assert(X.ConsiderHandOfGod()>0,label..' global heal includes support and invulnerable ally')
    remote.mods.modifier_ice_blast=true;assert(X.ConsiderHandOfGod()==0,label..' refuses only blocked healing target')
    remote.mods={};remote.stunned=true;remote.hp=950;hog.values.does_purge=1
    assert(X.ConsiderHandOfGod()>0,label..' strong dispel saves healthy controlled ally')
    reset();ally(6000,650).recent=true;ally(-6000,650).recent=true;prime(copy,hog);hog.ready=true
    assert(X.ConsiderHandOfGod()>0,label..' heals two globally wounded teammates')
    reset();for i=1,2 do local c=controlled(i*100);c.level=5;c.hp=200;c.recent=true end
    prime(copy,hog);hog.ready=true
    assert(X.ConsiderHandOfGod()>0,label..' global heal can preserve two endangered valuable army creeps')
    owned[2].player=1;assert(X.ConsiderHandOfGod()==0,label..' another player creep does not inflate army heal value')
    reset();bot.scepter=true;ally(300,950).recent=true;ally(500,950).recent=true;prime(copy,hog);hog.ready=true
    assert(X.ConsiderHandOfGod()>0,label..' Scepter can protect threatened nearby allies before near death')
    reset();recruit(550,'npc_dota_neutral_centaur_khan',5);recruit(300,'npc_dota_neutral_harpy_storm',3)
    prime(copy,persuasion);persuasion.ready=true;persuasion.values.level_req=3
    d,t=X.ConsiderHolyPersuasion();assert(d>0 and t.level==3,label..' respects early recruitment level cap')
    t.x=601;assert(X.ConsiderHolyPersuasion()==0,label..' recruitment bounds actual range')
    persuasion.values.level_req=6
    reset();for i=1,4 do controlled(i*50,nil,false,1) end;recruit(400)
    prime(copy,persuasion);persuasion.ready=true
    assert(X.ConsiderHolyPersuasion()>0,label..' another player army does not consume our slots')
    for _,u in ipairs(owned) do u.player=0 end
    assert(X.ConsiderHolyPersuasion()==0,label..' full army never silently kills oldest creep')
    reset();recruit(400,'npc_dota_neutral_black_dragon',6,true);prime(copy,persuasion);persuasion.ready=true
    assert(X.ConsiderHolyPersuasion()==0,label..' no Ancient without Shard')
    bot.shard=true;hog.level=1;assert(X.ConsiderHolyPersuasion()>0,label..' Shard recruits eligible Ancient')
    controlled(100,'npc_dota_neutral_granite_golem',true)
    assert(X.ConsiderHolyPersuasion()==0,label..' Ancient quota follows Hand of God level')
    hog.level=2;assert(X.ConsiderHolyPersuasion()>0,label..' new ultimate level permits second Ancient')
    reset();bot.shard=true;recruit(400,'npc_dota_neutral_black_dragon',6,true)
    local saved=spells.chen_hand_of_god;spells.chen_hand_of_god=nil
    prime(copy,persuasion);persuasion.ready=true
    assert(X.ConsiderHolyPersuasion()==0,label..' no missing linked ultimate dereference')
    recruit(300,'npc_dota_neutral_satyr_trickster',2)
    assert(X.ConsiderHolyPersuasion()>0,label..' spare slots take usable non-whitelisted creeps')
    spells.chen_hand_of_god=saved
    reset();local stolen=U(400,'npc_dota_neutral_alpha_wolf',3);creeps={stolen};prime(copy,persuasion);persuasion.ready=true
    d,t=X.ConsiderHolyPersuasion();assert(d>0 and t==stolen,label..' steals eligible enemy controlled creep')
end
reset();bot.mode='push';controlled(3000);zealot.ready=true
local d,t=Hero.ConsiderZealot();assert(d>0 and t==bot,'current innate recalls distant army')
owned[1].recent=true;assert(Hero.ConsiderZealot()==0,'recently attacked army cannot complete recall')
owned[1].recent=false;enemy(500);assert(Hero.ConsiderZealot()==0,'recall avoids unsafe caster position')
reset();ally(4000,200).recent=true;hog.ready=true;penitence.ready=true;bot.target=enemy(500,150)
Hero.SkillsComplement();assert(actions[1].ability==hog,'emergency global heal precedes lethal Penitence')
bot.channeling=true;actions={};Hero.SkillsComplement();assert(#actions==0,'never interrupts Scepter channel with another spell')
-- Exercise the real shared minion dispatcher, including the generic-fallback guard.
local fallback=0
package.loaded['bots/FunLib/minion_lib/utils']={CanNotUseAbility=function() return false end}
local previousDofile=dofile
dofile=function(path) if path=='bots/FunLib/minion_lib/illusions' then return {Think=function() fallback=fallback+1 end} end;return previousDofile(path) end
local Minion=H.realDofile('bots/FunLib/minion_lib/minion_with_skill.lua')
dofile=previousDofile
local function minion()
    local u=U(0,'npc_dota_chen_zealot');u.abilities={martyr}
    function u:GetAbilityByName() return martyr end
    function u:Action_UseAbilityOnEntity(a,t) actions[#actions+1]={ability=a,target=t} end
    return u
end
reset();martyr.ready=true;local m=minion();local hurt=ally(200,250);hurt.recent=true;enemy(300,100)
Minion.Think(bot,m);assert(#actions==1 and actions[1].target==hurt,'Zealot prioritizes threatened ally heal over enemy sacrifice')
reset();martyr.ready=true;m=minion();enemy(300,900);martyr.damageType=DAMAGE_TYPE_MAGICAL
Minion.Think(bot,m);assert(#actions==0,'healthy Zealot never sacrifices itself for generic poke')
reset();martyr.ready=true;m=minion();local kill=enemy(300,200);martyr.damageType=DAMAGE_TYPE_MAGICAL
Minion.Think(bot,m);assert(#actions==1 and actions[1].target==kill,'Zealot spends current-health damage on safe lethal target')
reset();martyr.ready=true;m=minion();kill=enemy(500,220);kill.regen=20;martyr.damageType=DAMAGE_TYPE_MAGICAL
Minion.Think(bot,m)
assert(#actions==0 and math.abs(kill.lastKillDelay-0.8)<0.001,
    '225 damage cannot sacrifice into 220 HP plus regeneration during cast and projectile travel')
for _,flag in ipairs({'immune','blocked','reflected','illusion'}) do
    reset();martyr.ready=true;m=minion();kill=enemy(300,100);kill[flag]=true
    Minion.Think(bot,m);assert(#actions==0,'Martyrdom never falls through against '..flag)
end
for _,mod in ipairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally','modifier_dazzle_shallow_grave'}) do
    reset();martyr.ready=true;m=minion();kill=enemy(300,100);kill.mods[mod]=true
    Minion.Think(bot,m);assert(#actions==0,'Martyrdom never falls through against '..mod)
end
reset();martyr.ready=true;m=minion();hurt=ally(200,200);hurt.recent=true;hurt.mods.modifier_ice_blast=true;enemy(300,900)
Minion.Think(bot,m);assert(#actions==0,'blocked ally healing does not cause fallback enemy sacrifice')
reset();martyr.ready=true;m=minion();m.hp=100;m.recent=true;bot.mode='attack';bot.target=enemy(300,900)
Minion.Think(bot,m);assert(#actions==1,'dying threatened Zealot can sacrifice toward current combat target')
reset();martyr.ready=true;m=minion();local far=ally(600,200);far.recent=true;enemy(300,900)
Minion.Think(bot,m);assert(#actions==0,'Martyrdom cannot heal beyond actual range')
reset();martyr.ready=true;m=minion();enemy(300,100);martyr.damageType=0
Minion.Think(bot,m);assert(#actions==0,'unknown live damage type cannot invent a lethal sacrifice')
assert(fallback>0,'ordinary move/attack behavior remains available after withholding sacrifice')
print('Chen ability scenarios passed')
