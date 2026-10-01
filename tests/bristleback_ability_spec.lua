-- Native/stolen Bristleback: legal reach, physical stacks, priorities and current upgrades.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0; DAMAGE_TYPE_PHYSICAL=1
local Vec={};Vec.__index=Vec
local function V(x,y) return setmetatable({x=x,y=y or 0,z=0},Vec) end
Vec.__sub=function(a,b) return V(a.x-b.x,a.y-b.y) end
Vec.__add=function(a,b) return V(a.x+b.x,a.y+b.y) end
Vec.__mul=function(a,k) return V(a.x*k,a.y*k) end
function Vec:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function Vec:Normalized() local n=self:Length2D();return n>0 and self*(1/n) or V(0) end
function GetUnitToLocationDistance(u,l) return (u.loc-l):Length2D() end
function GetUnitToUnitDistance(a,b) return GetUnitToLocationDistance(a,b.loc) end
local Unit={};Unit.__index=Unit
local function U(x) return setmetatable({loc=V(x),hp=1000,mods={},stacks={},times={},valid=true,physical=1},Unit) end
function Unit:GetLocation() return self.loc end
function Unit:GetExtrapolatedLocation(d) self.lastDelay=d;return self.future or self.loc end
function Unit:GetHealth() return self.hp end
function Unit:GetMaxHealth() return 1000 end
function Unit:HasModifier(n) return self.mods[n]==true end
function Unit:IsInvulnerable() return self.invulnerable==true end
function Unit:IsAttackImmune() return self.attackImmune==true end
function Unit:CanBeSeen() return self.visible~=false end
function Unit:IsCreep() return self.creep==true end
function Unit:IsAncientCreep() return self.ancient==true end
setmetatable(bot,Unit)
local spells,items,enemies,allies,creeps,actions={},{},{},{},{},{}
local target
local function S(name,range,cost,values)
    local s={name=name,range=range,cost=cost,values=values,castable=false,trained=true,passive=false}
    function s:GetName() return self.name end
    function s:GetCastRange() return self.range end
    function s:GetCastPoint() return self.name=='bristleback_hairball' and 0.1 or 0 end
    function s:GetManaCost() return self.cost end
    function s:IsTrained() return self.trained end
    function s:IsPassive() return self.passive end
    function s:GetAutoCastState() return false end
    function s:GetSpecialValueInt(k) return self.values[k] or 0 end
    function s:GetSpecialValueFloat(k) return self.values[k] or 0 end
    spells[name]=s;return s
end
local goo=S('bristleback_viscous_nasal_goo',650,24,{stack_limit=6})
local quill=S('bristleback_quill_spray',0,35,{radius=700,quill_base_damage=85,quill_stack_damage=30,max_damage=500})
local burst=S('bristleback_bristleback',0,125,{activation_delay=0.5})
local hair=S('bristleback_hairball',750,60,{radius=700,projectile_speed=1200})
local warpath=S('bristleback_warpath',0,0,{max_stacks=12});warpath.passive=true
local lens=S('item_aether_lens',0,0,{cast_range_bonus=225});spells.item_aether_lens=nil
local supremacy=S('rubick_arcane_supremacy',0,0,{cast_range=240});spells.rubick_arcane_supremacy=nil
function bot:GetAbilityByName(n) return spells[n] end
function bot:GetItemInSlot(i) return items[i] end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:GetAttackDamage() return 100 end
function bot:HasScepter() return self.scepter==true end
function bot:WasRecentlyDamagedByHero() return self.recent==true end
function bot:GetNearbyCreeps(r) local out={};for _,u in ipairs(creeps) do if J.IsInRange(self,u,r) then out[#out+1]=u end end;return out end
bot.GetNearbyLaneCreeps=bot.GetNearbyCreeps
for _,n in ipairs({'Action_UseAbility','Action_UseAbilityOnLocation','Action_UseAbilityOnEntity',
    'ActionQueue_UseAbility','ActionQueue_UseAbilityOnLocation','ActionQueue_UseAbilityOnEntity'}) do
    bot[n]=function(_,a,t) actions[#actions+1]={ability=a,target=t,kind=n} end
end
J.IsValid=function(u) return u~=nil and u.valid==true end
J.IsValidHero=function(u) return J.IsValid(u) and not u.creep end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastAbility=function(a) return a~=nil and a.castable and a.trained and not a.passive and bot.mana>=a.cost end
J.CanNotUseAbility=function() return false end
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.GetNearbyHeroes=function(_,r,enemy)
    local out={};for _,u in ipairs(enemy and enemies or allies) do if J.IsInRange(bot,u,r) then out[#out+1]=u end end;return out
end
J.CanCastOnNonMagicImmune=function(u) return J.IsValid(u) and not u.immune and not u.invulnerable end
J.CanCastOnMagicImmune=function(u) return J.IsValid(u) and not u.invulnerable and not u.illusion end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected end
J.CanKillTarget=function(u,d,t) assert(t==DAMAGE_TYPE_PHYSICAL);return u.hp<=d*u.physical end
J.GetProperTarget=function() return target end
J.GetModifierCount=function(u,n) return u.stacks[n] or 0 end
J.GetModifierTime=function(u,n) return u.times[n] or 0 end
J.HasBreakModifier=function(u) return u.mods.modifier_break==true end
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
J.IsAttacking=function() return true end
J.IsInTeamFight=function() return bot.fight==true end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.IsRealInvisible=function(u) return u.invisible==true end
J.IsDisabled=function(u) return u.disabled==true end
J.SetQueuePtToINT=function() end
local Hero=H.load('npc_dota_hero_bristleback','pos_3')
local Copy=H.realDofile('bots/FunLib/rubick_hero/bristleback.lua')
local function reset()
    items,enemies,allies,creeps,actions={},{},{},{},{}
    target=nil;spells.rubick_arcane_supremacy=nil
    for k,v in pairs(U(0)) do bot[k]=v end
    bot.mana=1000;bot.mode='idle';bot.scepter=false;bot.fight=false;bot.recent=false;bot.chasing=nil
    for _,s in pairs(spells) do s.castable=false;s.trained=true end
end
local function enemy(x) local u=U(x);enemies[#enemies+1]=u;return u end
local function attack(x) bot.mode='attack';target=enemy(x);return target end
local function prime(copy,ability) if copy then Copy.ConsiderStolenSpell(ability);actions={} end end
for _,isCopy in ipairs({false,true}) do
    local X=isCopy and Copy or Hero
    local label=isCopy and 'stolen' or 'native'
    local hairFn=isCopy and X.ConsiderHairBall or X.ConsiderHairball
    reset();attack(700);prime(isCopy,goo);goo.castable=true
    assert(X.ConsiderViscousNasalGoo()==0,label..' Goo does not invent movement cast range')
    items[0]=lens;assert(X.ConsiderViscousNasalGoo()>0,label..' Goo honors active Lens')
    items={};target.loc=V(600);target.immune=true
    assert(X.ConsiderViscousNasalGoo()==0,label..' Goo does not pierce immunity')
    target.immune=false;target.mods.modifier_antimage_counterspell=true
    assert(X.ConsiderViscousNasalGoo()==0,label..' Goo avoids current Counterspell')
    target.mods={};target.blocked=true
    assert(X.ConsiderViscousNasalGoo()==0,label..' Goo respects spell block')
    target.blocked=false;target.stacks.modifier_bristleback_viscous_nasal_goo=6;target.times.modifier_bristleback_viscous_nasal_goo=4
    assert(X.ConsiderViscousNasalGoo()==0,label..' capped fresh Goo does not waste mana')
    target.times.modifier_bristleback_viscous_nasal_goo=1
    assert(X.ConsiderViscousNasalGoo()>0,label..' refreshes capped Goo before it expires')
    bot.mana=50;assert(X.ConsiderViscousNasalGoo()==0,label..' saves mana for Quill')
    reset();bot.mode='retreat';bot.hp=300;local pursuer=enemy(450);pursuer.chasing=bot
    prime(isCopy,goo);goo.castable=true
    assert(X.ConsiderViscousNasalGoo()>0,label..' low health does not suppress escape slow')
    reset();bot.fight=true;enemy(1100);enemy(500);prime(isCopy,goo);goo.castable=true
    local desire,t=X.ConsiderViscousNasalGoo()
    assert(desire>0 and t.loc.x==500,label..' selects in-range enemy instead of first list entry')
    reset();bot.mode='lane';enemy(500);prime(isCopy,goo);goo.castable=true
    assert(X.ConsiderViscousNasalGoo()>0,label..' supports lane armor/slow pressure')
    if isCopy then
        reset();attack(850);spells.rubick_arcane_supremacy=supremacy;prime(true,goo);goo.castable=true
        assert(X.ConsiderViscousNasalGoo()>0,'stolen Goo uses Supremacy')
        bot.mods.modifier_break=true
        assert(X.ConsiderViscousNasalGoo()==0,'known Break removes Supremacy reach')
    end
    reset();attack(690).immune=true;prime(isCopy,quill);quill.castable=true
    assert(X.ConsiderQuillSpray()>0,label..' physical Quill reaches full radius through immunity')
    target.attackImmune=true;assert(X.ConsiderQuillSpray()==0,label..' does not waste Quill on physical immunity')
    reset();bot.fight=true;enemy(1000);prime(isCopy,quill);quill.castable=true
    assert(X.ConsiderQuillSpray()==0,label..' team fight alone cannot justify empty Quill')
    reset();bot.mode='lane';local creep=U(500);creep.creep=true;creep.hp=110;creep.stacks.modifier_bristleback_quill_spray=1;creeps={creep}
    prime(isCopy,quill);quill.castable=true
    assert(X.ConsiderQuillSpray()>0,label..' stacked physical Quill secures last hit')
    creep.physical=0.5;assert(X.ConsiderQuillSpray()==0,label..' armor prevents false last-hit prediction')
    reset();bot.mode='farm';creeps={U(300),U(400)};prime(isCopy,quill);quill.castable=true
    assert(X.ConsiderQuillSpray()>0,label..' Quill farms a real group')
    bot.mana=200;assert(X.ConsiderQuillSpray()==0,label..' farm Quill preserves mana floor')
    reset();attack(1300).immune=true;prime(isCopy,hair);hair.castable=true
    desire,t=hairFn()
    assert(desire>0 and t.x==750,label..' Hairball hits immune target with bounded AoE edge cast')
    assert(math.abs(target.lastDelay-(0.1+750/1200))<0.001,label..' Hairball predicts real travel time')
    target.future=V(1550);assert(hairFn()==0,label..' rejects target predicted outside legal AoE reach')
    reset();bot.fight=true;enemy(500).immune=true;enemy(900).immune=true;prime(isCopy,hair);hair.castable=true
    assert(hairFn()>0,label..' Hairball remains useful against immune group')
    enemies[2].future=V(2000)
    assert(hairFn()==0,label..' does not count enemies escaping the predicted Hairball area')
    reset();attack(650).immune=true;bot.scepter=true;prime(isCopy,burst);burst.castable=true
    assert(X.ConsiderBristleback()>0,label..' current Scepter reaches beyond arbitrary 350 radius')
    bot.chasing=target;assert(X.ConsiderBristleback()==0,label..' avoids locking/slow while chasing fleeing target')
    target.disabled=true;assert(X.ConsiderBristleback()>0,label..' uses allied disable for cone burst')
    bot.mode='retreat';assert(X.ConsiderBristleback()==0,label..' preserves escape against self-slow')
    assert(X.ConsiderWarpath()==0,label..' cannot cast removed Seeing Red')
end
reset();attack(400).hp=50;goo.castable=true;quill.castable=true;hair.castable=true;burst.castable=true;bot.scepter=true
Hero.SkillsComplement()
assert(#actions==1 and actions[1].ability==quill,'lethal Quill wins over debuff setup')
reset();attack(500);goo.castable=true;quill.castable=true;hair.castable=true;burst.castable=true;bot.scepter=true
Hero.SkillsComplement();assert(actions[1].ability==hair,'Hairball setup precedes Scepter')
hair.castable=false;actions={};Hero.SkillsComplement();assert(actions[1].ability==goo,'Goo armor reduction precedes Scepter')
reset();attack(1000);quill.castable=true
assert(Hero.ConsiderQuillSpray()>0,'build Warpath movement before a real fight')
bot.mods.modifier_break=true;assert(Hero.ConsiderQuillSpray()==0,'Break stops pointless stack-building cast')
bot.mods={};bot.stacks.modifier_bristleback_warpath=12;bot.times.modifier_bristleback_warpath=10
assert(Hero.ConsiderQuillSpray()==0,'does not maintain already healthy capped Warpath')
reset();bot.mode='idle';quill.castable=true
assert(Hero.ConsiderQuillSpray()==0,'full mana does not justify empty idle spam feeding Wand')
reset();bot.mode='farm';bot.scepter=true;burst.castable=true;creeps={U(400),U(500)}
for _,u in ipairs(creeps) do u.creep=true;u.ancient=true end
assert(Hero.ConsiderBristleback()>0,'Scepter bursts tightly clustered ancient camp')
creeps[2].loc=V(-500);assert(Hero.ConsiderBristleback()==0,'does not treat spread creeps as one cone')
-- A single stolen Goo works without either linked Quill or passive Warpath.
reset();attack(500);goo.castable=true;local saved=spells.bristleback_quill_spray;spells.bristleback_quill_spray=nil
assert(Copy.ConsiderStolenSpell(goo)==true,'stolen Goo needs no Quill handle');spells.bristleback_quill_spray=saved
print('Bristleback ability scenarios passed')
