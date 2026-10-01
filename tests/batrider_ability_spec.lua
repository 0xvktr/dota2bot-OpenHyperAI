-- Batrider cast reach, initiation budget, directional knockback and farm/Shard use.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_HIGH=1; BOT_ACTION_DESIRE_NONE=0; BOT_MODE_NONE=0; DAMAGE_TYPE_MAGICAL=2
local Vec={};Vec.__index=Vec
local function V(x,y) return setmetatable({x=x,y=y or 0,z=0},Vec) end
Vec.__sub=function(a,b) return V(a.x-b.x,a.y-b.y) end
Vec.__add=function(a,b) return V(a.x+b.x,a.y+b.y) end
Vec.__mul=function(a,k) return V(a.x*k,a.y*k) end
function Vec:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function Vec:Normalized() local n=self:Length2D();return n>0 and self*(1/n) or V(0) end
local function dist(a,b) return (a-b):Length2D() end
function GetUnitToLocationDistance(u,v) return dist(u:GetLocation(),v) end
function GetUnitToUnitDistance(a,b) return dist(a:GetLocation(),b:GetLocation()) end
local passable,hazard,arena=true,false,false
function IsLocationPassable() return passable end
local Unit={};Unit.__index=Unit
local function U(x,enemy) return setmetatable({loc=V(x),enemy=enemy,valid=true,hp=1000,mods={},mode='idle'},Unit) end
function Unit:GetLocation() return self.loc end
function Unit:GetExtrapolatedLocation(delay) self.lastDelay=delay;return self.future or self.loc end
function Unit:GetHealth() return self.hp end
function Unit:GetMaxHealth() return 1000 end
function Unit:HasModifier(name) return self.mods[name]==true end
function Unit:IsChanneling() return self.channel==true end
function Unit:IsFacingLocation() return self.facing~=false end
function Unit:IsBuilding() return self.building==true end
function Unit:WasRecentlyDamagedByAnyHero() return self.recent==true end
setmetatable(bot,Unit)
local spells,items,enemies,allies,creeps,neutrals,actions={},{},{},{},{},{},{}
local target
local function Spell(name,range,cost,values)
    local s={name=name,range=range,cost=cost,values=values or {},castable=false,level=4}
    function s:GetName() return self.name end
    function s:GetCastRange() return self.range end
    function s:GetCastPoint() return self.name=='batrider_flamebreak' and 0.2 or 0.3 end
    function s:GetManaCost() return self.cost end
    function s:GetLevel() return self.level end
    function s:IsHidden() return false end
    function s:IsTrained() return true end
    function s:IsFullyCastable() return self.castable and bot.mana>=self.cost end
    function s:GetSpecialValueInt(key) return self.values[key] or 0 end
    function s:GetSpecialValueFloat(key) return self.values[key] or 0 end
    spells[name]=s;return s
end
local napalm=Spell('batrider_sticky_napalm',600,22,{radius=375,building_damage_pct=0})
local flame=Spell('batrider_flamebreak',1300,110,{speed=1700,explosion_radius=400,damage_impact=100})
local fire=Spell('batrider_firefly',0,100)
local lasso=Spell('batrider_flaming_lasso',200,175,{duration=3.25})
local blink=Spell('item_blink',1200,0,{blink_range=1200})
local bkb=Spell('item_black_king_bar',0,75)
local lens=Spell('item_aether_lens',0,0,{cast_range_bonus=225})
local supremacy=Spell('rubick_arcane_supremacy',0,0,{cast_range=240})
spells.rubick_arcane_supremacy=nil
function bot:GetAbilityByName(name) return spells[name] end
function bot:GetItemInSlot(slot) return items[slot] end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:IsRooted() return self.rooted==true end
function bot:IsMagicImmune() return self.immune==true end
function bot:GetNearbyLaneCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:Action_ClearActions() actions={} end
function bot:ActionQueue_Delay() end
for _,name in ipairs({'Action_UseAbility','Action_UseAbilityOnEntity','Action_UseAbilityOnLocation',
    'ActionQueue_UseAbility','ActionQueue_UseAbilityOnEntity','ActionQueue_UseAbilityOnLocation'}) do
    bot[name]=function(_,a,t) actions[#actions+1]={name=a.name,target=t,kind=name} end
end
local function near(list,loc,range)
    local out={};for _,u in ipairs(list) do if dist(u.loc,loc)<=range then out[#out+1]=u end end;return out
end
J.GetNearbyHeroes=function(u,r,enemy)
    return near((u.enemy and not enemy or not u.enemy and enemy) and enemies or allies,u.loc,r)
end
J.IsValid=function(u) return u~=nil and u.valid==true end
J.IsValidHero=function(u) return J.IsValid(u) and not u.building and not u.creep end
J.IsValidTarget=J.IsValid
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnNonMagicImmune=function(u) return J.IsValid(u) and not u.immune end
J.CanCastOnMagicImmune=J.IsValid
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected end
J.IsTaunted=function(u) return u.taunted==true end
J.IsDisabled=function(u) return u.disabled==true end
J.IsRunning=function(u) return u.running~=false end
J.GetMP=function(u) return u.mana/1000 end
J.IsInRange=function(a,b,r) return dist(a.loc,b.loc)<=r end
J.GetProperTarget=function() return target end
J.CanNotUseAbility=function() return false end
J.IsItemAvailable=function(name)
    for _,item in pairs(items) do if item.name==name then return item end end
    return nil
end
J.CanKillTarget=function(u,damage) return u.hp<=damage end
J.IsStuck=function(u) return u.stuck==true end
J.HasBreakModifier=function(u) return u:HasModifier('modifier_break') end
J.IsGoingOnSomeone=function(u) return u.mode=='attack' end
J.IsRetreating=function(u) return u.mode=='retreat' end
J.IsLaning=function(u) return u.mode=='lane' end
J.IsFarming=function(u) return u.mode=='farm' end
J.IsPushing=function(u) return u.mode=='push' end
J.IsDefending=function(u) return u.mode=='defend' end
J.IsDoingRoshan=function() return false end
J.IsDoingTormentor=function() return false end
J.IsAttacking=function() return true end
J.IsLocationInChrono=function() return hazard end
J.IsLocationInBlackHole=function() return false end
J.IsLocationInArena=function(_,r) assert(r==600,'Arena query needs a real safety radius');return arena end
J.GetStrongestUnit=function() return enemies[1] end
local Hero=H.load('npc_dota_hero_batrider','pos_3')
local Copy=H.realDofile('bots/FunLib/rubick_hero/batrider.lua')
local function reset()
    enemies,allies,creeps,neutrals,items,actions={},{},{},{},{},{}
    target=nil;passable,hazard,arena=true,false,false;spells.rubick_arcane_supremacy=nil
    for k,v in pairs(U(0,false)) do bot[k]=v end
    bot.mana=1000;bot.rooted=false;bot.immune=false;bot.stuck=false;bot.recent=false;blink.values.blink_range=1200
    for _,s in pairs(spells) do s.castable=false;s.level=4 end
    napalm.values.building_damage_pct=0
end
local function enemy(x) local u=U(x,true);enemies[#enemies+1]=u;return u end
local function attack(x) target=enemy(x);bot.mode='attack';allies={bot};return target end
local function prime(copy,spell)
    if copy then Copy.ConsiderStolenSpell(spell);actions={} end
end
for _,isCopy in ipairs({false,true}) do
    local X=isCopy and Copy or Hero
    local label=isCopy and 'Rubick' or 'native'
    reset();attack(550);prime(isCopy,lasso);lasso.castable=true
    assert(X.ConsiderFlamingLasso()==0,label..' cannot add attack range to Lasso reach')
    reset();attack(350);items[2]=lens;prime(isCopy,lasso);lasso.castable=true
    assert(X.ConsiderFlamingLasso()>0,label..' honors actual cast range bonus')
    reset();attack(180).immune=true;prime(isCopy,lasso);lasso.castable=true
    assert(X.ConsiderFlamingLasso()>0,label..' Lasso pierces debuff immunity')
    target.blocked=true;assert(X.ConsiderFlamingLasso()==0,label..' does not feed spell block')
    target.blocked=false;target.reflected=true;assert(X.ConsiderFlamingLasso()==0,label..' does not reflect its own Lasso')
    if isCopy then
        reset();attack(430);spells.rubick_arcane_supremacy=supremacy;prime(true,lasso);lasso.castable=true
        assert(X.ConsiderFlamingLasso()>0,'Rubick reaches target with trained Arcane Supremacy')
        bot.mods.modifier_break=true
        assert(X.ConsiderFlamingLasso()==0,'Rubick does not overestimate passive cast bonus during known Break')
    end
    reset();target=enemy(180);target.channel=true;prime(isCopy,lasso);lasso.castable=true
    assert(X.ConsiderFlamingLasso()>0,label..' interrupts a channel outside attack mode')
    for _,mod in ipairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally',
        'modifier_batrider_flaming_lasso','modifier_enigma_black_hole_pull','modifier_abaddon_borrowed_time'}) do
        reset();attack(180).mods[mod]=true;prime(isCopy,lasso);lasso.castable=true
        assert(X.ConsiderFlamingLasso()==0,label..' avoids '..mod)
    end
    reset();attack(1000);items[0]=blink;blink.castable=true;prime(isCopy,lasso);lasso.castable=true
    assert(X.ConsiderBlinkLasso()>0,label..' selects a reachable Blink grab')
    bot.rooted=true;assert(X.ConsiderBlinkLasso()==0,label..' cannot Blink while rooted')
    bot.rooted=false;bot.mods.modifier_bloodseeker_rupture=true
    assert(X.ConsiderBlinkLasso()==0,label..' does not Blink through Rupture')
    bot.mods={};passable=false;assert(X.ConsiderBlinkLasso()==0,label..' avoids impassable landing')
    passable=true;hazard=true;assert(X.ConsiderBlinkLasso()==0,label..' avoids Chronosphere')
    hazard=false;arena=true;assert(X.ConsiderBlinkLasso()==0,label..' avoids Arena');arena=false;target.future=V(1500);assert(X.ConsiderBlinkLasso()==0,label..' rejects movement beyond Blink plus Lasso reach')
    reset();attack(180);items[0]=blink;blink.castable=true;prime(isCopy,lasso);lasso.castable=true
    assert(X.ConsiderBlinkLasso()==0,label..' does not waste Blink on a direct grab')
    reset();attack(700);prime(isCopy,flame);flame.castable=true
    local desire,location=X.ConsiderFlamebreak()
    assert(desire>0 and location.x>target.loc.x,label..' explosion behind enemy pushes toward Batrider')
    assert(math.abs(target.lastDelay-(0.2+700/1700))<0.001,label..' uses cast point once plus projectile travel')
    target.mods.modifier_batrider_flaming_lasso=true
    assert(X.ConsiderFlamebreak()==0,label..' does not displace active Lasso')
    reset();bot.mode='retreat';bot.recent=true;target=enemy(400);prime(isCopy,flame);flame.castable=true
    desire,location=X.ConsiderFlamebreak()
    assert(desire>0 and location.x<target.loc.x,label..' explosion before pursuer pushes away')
    reset();attack(1200).future=V(1350);prime(isCopy,flame);flame.castable=true
    desire,location=X.ConsiderFlamebreak()
    assert(desire>0 and location.x<=1300,label..' bounds point cast while covering predicted target')
    reset();bot.mode='lane';enemy(400);prime(isCopy,napalm);napalm.castable=true
    assert(X.ConsiderStickyNapalm()>0,label..' lane harassment works without a proper combat target')
    reset();bot.mode='lane';creeps={U(500),U(700)};creeps[1].hp=70;creeps[2].hp=70
    prime(isCopy,flame);flame.castable=true
    assert(X.ConsiderFlamebreak()>0,label..' secures two creeps in real explosion radius')
    creeps[2].loc=V(-700)
    assert(X.ConsiderFlamebreak()==0,label..' does not average spread last hits into an empty explosion')
    reset();bot.mode='lane';creeps={U(300),U(400),U(500)}
    prime(isCopy,napalm);napalm.castable=true
    assert(X.ConsiderStickyNapalm()>0,label..' retains lane wave Napalm when no hero is available')
    reset();bot.mode='farm';creeps={U(500),U(-500),U(950)}
    prime(isCopy,napalm);napalm.castable=true
    assert(X.ConsiderStickyNapalm()==0,label..' farm Napalm needs actual clustered coverage')
    reset();bot.mode='lane';target=enemy(850);prime(isCopy,napalm);napalm.castable=true
    desire,location=X.ConsiderStickyNapalm()
    assert(desire>0 and math.abs(location.x-600)<0.001,label..' harasses lone lane hero using AoE edge without creep condition')
    reset();bot.mode='push';target=U(800,true);target.building=true;prime(isCopy,napalm);napalm.castable=true
    assert(X.ConsiderStickyNapalm()==0,label..' no structure Napalm without upgrade')
    napalm.values.building_damage_pct=20
    assert(X.ConsiderStickyNapalm()>0,label..' uses current Shard structure damage')
    target.mods.modifier_fountain_glyph=true
    assert(X.ConsiderStickyNapalm()==0,label..' does not waste structure cast under Glyph')
    reset();bot.mode='farm';neutrals={U(100),U(200),U(300)};prime(isCopy,fire);fire.castable=true
    assert(X.ConsiderFirefly()>0,label..' burns a stacked camp')
    fire.level=1;assert(X.ConsiderFirefly()==0,label..' keeps weak early Firefly for fights')
    fire.level=4;bot.mods.modifier_batrider_firefly=true
    assert(X.ConsiderFirefly()==0,label..' does not refresh active Firefly')
end
-- Native combo reserves Lasso mana before optional preparation spells.
reset();attack(1000);items[0],items[1]=blink,bkb;blink.castable=true;bkb.castable=true
lasso.castable=true;fire.castable=true;bot.mana=175
Hero.SkillsComplement()
assert(#actions==2 and actions[1].name=='item_blink' and actions[2].name=='batrider_flaming_lasso','minimal combo preserves Lasso mana')
reset();attack(1000);items[0],items[1]=blink,bkb;blink.castable=true;bkb.castable=true
lasso.castable=true;fire.castable=true;bot.mana=250
Hero.SkillsComplement()
assert(#actions==3 and actions[1].name=='item_black_king_bar' and actions[3].name=='batrider_flaming_lasso','BKB priority preserves Lasso and skips unaffordable Firefly')
reset();attack(1000);items[0],items[1]=blink,bkb;blink.castable=true;bkb.castable=true
lasso.castable=true;fire.castable=true;Hero.SkillsComplement()
assert(#actions==4 and actions[1].name=='item_black_king_bar' and actions[2].name=='batrider_firefly'
    and actions[3].name=='item_blink' and actions[4].name=='batrider_flaming_lasso','protected preparation precedes Blink grab')
reset();attack(180).channel=true;items[0]=blink;blink.castable=true;lasso.castable=true;fire.castable=true
Hero.SkillsComplement()
assert(#actions==1 and actions[1].name=='batrider_flaming_lasso','channel Lasso precedes Firefly and Blink')
-- Stolen Lasso works when the linked Firefly was not stolen, with the same mana budget.
reset();attack(1000);items[0]=blink;blink.castable=true;lasso.castable=true;bot.mana=175
local saved=spells.batrider_firefly;spells.batrider_firefly=nil
assert(Copy.ConsiderStolenSpell(lasso)==true and #actions==2,'stolen Blink Lasso needs no Firefly handle')
spells.batrider_firefly=saved
print('Batrider ability scenarios passed')
