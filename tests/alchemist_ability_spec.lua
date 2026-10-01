local H=dofile('tests/hero_harness.lua')
local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_ACTION_DESIRE_MODERATE=0.5; BOT_MODE_NONE=0; DAMAGE_TYPE_PHYSICAL=1
local now=100
function DotaTime() return now end
local allies,enemies,actions,target={},{},{},nil
local U={};U.__index=U
local function unit(x,hp) return setmetatable({x=x,hp=hp or 1000,mods={},valid=true},U) end
function U:GetHealth() return self.hp end
function U:HasModifier(n) return self.mods[n]~=nil and self.mods[n]~=false end
function U:CanBeSeen() return self.valid end
function U:IsIllusion() return self.illusion==true end
function U:IsInvulnerable() return self.invulnerable==true end
function U:IsMagicImmune() return self.immune==true end
function U:IsStunned() return self.stun==true end
function U:IsRooted() return self.root==true end
function U:IsSilenced() return self.silence==true end
function U:IsChanneling() return self.channel==true end
function U:WasRecentlyDamagedByAnyHero() return self.recent==true end
function U:GetLocation() return {x=self.x,y=0,z=0} end
function U:GetExtrapolatedLocation() return self:GetLocation() end
function U:IsFacingLocation() return true end
function U:GetAttackRange() return 150 end
function U:IsCreep() return self.creep==true end
setmetatable(bot,U)
local names={acid='alchemist_acid_spray',brew='alchemist_unstable_concoction',throw='alchemist_unstable_concoction_throw',rage='alchemist_chemical_rage',potion='alchemist_berserk_potion'}
local abilities={}
for key,name in pairs(names) do
 local a={name=name,key=key,castable=false,hidden=key=='throw',range=key=='acid' and 900 or key=='potion' and 800 or 775,
 values={brew_time=5,brew_explosion=key=='throw' and 7 or 5.5,max_damage=360,radius=500}}
 function a:GetName() return self.name end
 function a:IsFullyCastable() return self.castable end
 function a:IsTrained() return true end
 function a:IsHidden() return self.hidden end
 function a:GetCastRange() return self.range end
 function a:GetCastPoint() return 0.2 end
 function a:GetSpecialValueInt(k) return self.values[k] or 0 end
 function a:GetSpecialValueFloat(k) return self.values[k] or 0 end
 abilities[name]=a
end
local supremacy={trained=false}
function supremacy:IsTrained() return self.trained end
function supremacy:GetSpecialValueInt() return 240 end
local talent={trained=false}
function talent:IsTrained() return self.trained end
function talent:GetSpecialValueInt() return 400 end
bot.GetAbilityByName=function(_,n) return n=='T5' and talent or n=='rubick_arcane_supremacy' and supremacy or abilities[n] end
function bot:Action_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
function bot:Action_UseAbility(a) actions[#actions+1]={name=a.name} end
function bot:Action_UseAbilityOnLocation(a,l) actions[#actions+1]={name=a.name,loc=l} end
function bot:GetNearbyNeutralCreeps() return self.camps or {} end
function bot:GetNearbyLaneCreeps() return {} end
function bot:FindAoELocation() return {count=0,targetloc=self:GetLocation()} end
J.IsValidHero=function(u) return u~=nil and u.valid and not u.creep end
J.IsValidTarget=function(u) return u~=nil and u.valid end
J.IsValid=J.IsValidTarget
J.IsInRange=function(a,b,r) return a and b and math.abs(a.x-b.x)<=r end
J.IsItemAvailable=function() return (bot.bonus or 0)>0 and {} or nil end
J.GetHP=function(u) return u.hp/1000 end
J.GetMP=function(u) return u.mp or 1 end
J.GetNearbyHeroes=function(_,_,enemy) return enemy and enemies or allies end
J.GetProperTarget=function(u) return u==bot and target or u.target end
J.CanNotUseAbility=function() return bot.stun or bot.silence end
J.CanCastOnNonMagicImmune=function(u) return u.valid and not u.immune and not u.invulnerable end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked end
J.IsSuspiciousIllusion=function(u) return u.illusion end
J.CannotBeKilled=function(_,u) return u.protected end
J.CanKillTarget=function(u,d,t) assert(t==DAMAGE_TYPE_PHYSICAL); return u.hp<=d end
J.GetModifierTime=function(u,n) return type(u.mods[n])=='number' and u.mods[n] or 0 end
J.IsGoingOnSomeone=function(u) return u.mode=='attack' end
J.IsRetreating=function(u) return u.mode=='retreat' end
J.IsFarming=function(u) return u.mode=='farm' end
J.IsAttacking=function(u) return u.attacking==true end
J.IsInTeamFight=function() return false end
J.IsDisabled=function(u) return u.stun==true end
J.IsRunning=function() return true end
J.IsDoingRoshan=function() return false end
J.IsDoingTormentor=function() return false end
J.IsDefending=function() return false end
J.IsPushing=function() return false end
J.IsLaning=function() return false end
J.SetQueuePtToINT=function() end
local hero=H.load('npc_dota_hero_alchemist','pos_1')
local stolen=H.realDofile('bots/FunLib/rubick_hero/alchemist.lua')
local function reset()
 allies,enemies,actions,target={},{},{},nil; now=100;talent.trained=false;supremacy.trained=false
 for k,v in pairs(bot) do if type(v)~='function' then bot[k]=nil end end
 for k,v in pairs(unit(0)) do bot[k]=v end
 for _,a in pairs(abilities) do a.castable=false;a.hidden=a.key=='throw' end
end
local function tick(key,rubick)
 actions={}; if rubick then stolen.ConsiderStolenSpell(abilities[names[key]]) else hero.SkillsComplement() end
 return actions[1]
end
for _,rubick in ipairs({false,true}) do
 local function cast(key,u) local a=tick(key,rubick); assert(a and a.name==names[key] and (not u or a.target==u),'expected '..key) end
 local function none(key) assert(tick(key,rubick)==nil,'expected no '..key) end
 reset(); abilities[names.acid].castable=true; bot.mode='attack';target=unit(600);enemies={target}
 cast('acid');target.x=901;none('acid');bot.bonus=100;cast('acid')
 reset(); abilities[names.brew].castable=true;bot.mode='attack';target=unit(400);enemies={target}
 target.mods.modifier_antimage_counterspell=true;none('brew');target.mods={}
 cast('brew'); bot.mods.modifier_alchemist_unstable_concoction=3.5;none('brew');now=102
 abilities[names.brew].castable=false; abilities[names.throw].castable=true;abilities[names.throw].hidden=false
 none('throw') -- At two seconds a healthy target does not prematurely consume the charge.
 bot.mods.modifier_alchemist_unstable_concoction=2.5;now=103;none('throw')
 target.channel=true;cast('throw',target);target.channel=false
 target.hp=250;bot.mods.modifier_alchemist_unstable_concoction=3.5;now=102;none('throw') -- Damage is 144, not 360.
 target.hp=140;cast('throw',target)
 target.mods.modifier_abaddon_aphotic_shield=true;none('throw');target.mods={}
 target.hp=1000;target.x=700;cast('throw',target) -- The target is leaving range.
 target.x=400;bot.mode='retreat';cast('throw',target)
 bot.mode='attack';bot.mods.modifier_alchemist_unstable_concoction=0.5;now=105;cast('throw',target)
 target.immune=true; local real=unit(500); enemies={target,real};cast('throw',real)
 real.illusion=true;none('throw');real.illusion=false;real.blocked=true;none('throw')
 real.mods.modifier_item_sphere_target=true;cast('throw',real)
 real.mods.modifier_antimage_counterspell=true;none('throw')
 real.mods.modifier_antimage_counterspell=nil
 real.mods.modifier_item_lotus_orb_active=true;none('throw');real.mods={}
 real.blocked=false;real.mods.modifier_antimage_counterspell=true;none('throw');real.mods={}
 real.x=776;none('throw');bot.bonus=100;cast('throw',real)
 -- A charged brew is released before starting a Rage transformation.
 if not rubick then abilities[names.rage].castable=true;cast('throw',real) end
 reset();abilities[names.potion].castable=true; local ally=unit(400);allies={ally};ally.stun=true
 none('potion') -- Basic dispel is not a stun save.
 ally.stun=false;ally.silence=true;ally.immune=true;cast('potion',ally)
 if not rubick then
  abilities[names.acid].castable=true;bot.mode='attack';target=unit(600)
  cast('potion',ally);abilities[names.acid].castable=false;bot.mode='idle';target=nil
 end
 ally.mods.modifier_alchemist_berserk_potion=true;none('potion')
 allies={};bot.mods.modifier_item_spirit_vessel_damage=true;cast('potion',bot)
 bot.mods={modifier_medusa_gorgon_grasp_root=true};cast('potion',bot)
 bot.mods={};bot.mode='attack';target=unit(150);cast('potion',bot)
 bot.mode='idle';bot.hp=300;bot.recent=true;bot.mods.modifier_ice_blast=true;none('potion')
 reset();abilities[names.rage].castable=true;bot.mods.modifier_item_spirit_vessel_damage=true;cast('rage')
 bot.mods={};bot.mode='farm';bot.attacking=true;target=unit(100);target.creep=true;bot.camps={unit(100),unit(120),unit(130)}
 cast('rage');bot.mods.modifier_ice_blast=true;none('rage')
end
reset();abilities[names.throw].castable=true;abilities[names.throw].hidden=false
local talented=unit(400,280);enemies={talented};bot.mods.modifier_alchemist_unstable_concoction=3.5
assert(tick('throw',false)==nil,'base two-second damage cannot kill 280 HP')
talent.trained=true;assert(tick('throw',false).target==talented,'native damage talent scales with brew time')
-- Rubick can receive the linked Throw without this module having seen the original brew.
reset();stolen=H.realDofile('bots/FunLib/rubick_hero/alchemist.lua')
abilities[names.throw].castable=true;abilities[names.throw].hidden=false
local inherited=unit(400);enemies={inherited};bot.mods.modifier_alchemist_unstable_concoction=3.5
assert(tick('throw',true)==nil,'inherited Throw respects elapsed modifier time')
bot.mods.modifier_alchemist_unstable_concoction=0.5
assert(tick('throw',true).target==inherited,'inherited Throw releases at deadline')
inherited.x=900;assert(tick('throw',true)==nil,'stolen Throw does not queue a walk beyond cast range')
supremacy.trained=true;assert(tick('throw',true).target==inherited,'stolen Throw includes Arcane Supremacy')
bot.mods.modifier_silver_edge_debuff=true;assert(tick('throw',true)==nil,'break disables passive cast range')
print('Alchemist ability scenarios passed')
