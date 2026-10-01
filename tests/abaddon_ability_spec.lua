local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0; DAMAGE_TYPE_MAGICAL=2
local allies,enemies,actions,target={},{},{},nil
local U={}; U.__index=U
local function unit(x,hp) return setmetatable({x=x,hp=hp or 1000,maxHp=1000,mods={},valid=true},U) end
function U:GetHealth() return self.hp end
function U:GetMaxHealth() return self.maxHp end
function U:HasModifier(n) return self.mods[n]==true end
function U:CanBeSeen() return self.valid end
function U:IsIllusion() return self.illusion==true end
function U:IsInvulnerable() return self.invulnerable==true end
function U:IsMagicImmune() return self.immune==true end
function U:IsStunned() return self.stun==true end
function U:IsRooted() return self.root==true end
function U:IsSilenced() return self.silence==true end
function U:IsHexed() return self.hex==true end
function U:IsNightmared() return false end
function U:IsAlive() return self.valid end
function U:IsChanneling() return false end
function U:IsUsingAbility() return false end
function U:IsCastingAbility() return false end
function U:HasScepter() return self.scepter==true end
function U:WasRecentlyDamagedByAnyHero() return self.recent==true end
function U:GetAttackTarget() return self.target end
setmetatable(bot,U)
local abilities={}
for _,name in ipairs({'abaddon_death_coil','abaddon_aphotic_shield','abaddon_borrowed_time'}) do
 local a={name=name,castable=false,range=name=='abaddon_death_coil' and 625 or 550}
 function a:GetName() return self.name end
 function a:IsFullyCastable() return self.castable end
 function a:GetCastRange() return self.range end
 function a:GetSpecialValueInt(k) return ({damage_heal=320,self_damage=40,hp_threshold=400})[k] or 0 end
 abilities[name]=a
end
local supremacy={trained=false}
function supremacy:IsTrained() return self.trained end
function supremacy:GetSpecialValueInt() return 240 end
local talent={trained=false}
function talent:IsTrained() return self.trained end
function talent:GetSpecialValueInt() return 35 end
bot.GetAbilityByName=function(_,n) return n=='T4' and talent or n=='rubick_arcane_supremacy' and supremacy or abilities[n] end
function bot:Action_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
function bot:Action_UseAbility(a) actions[#actions+1]={name=a.name} end
J.IsValidHero=function(u) return u~=nil and u.valid end
J.IsValidTarget=J.IsValidHero
J.IsInRange=function(a,b,r) return a and b and math.abs(a.x-b.x)<=r end
J.IsItemAvailable=function() return (bot.bonus or 0)>0 and {} or nil end
J.GetHP=function(u) return u.hp/u.maxHp end
J.GetMP=function() return 1 end
J.GetNearbyHeroes=function(_,_,enemy) return enemy and enemies or allies end
J.GetProperTarget=function() return target end
J.CanNotUseAbility=function() return bot.stun or bot.silence or bot.hex end
J.CanCastOnNonMagicImmune=function(u) return u.valid and not u.immune and not u.invulnerable end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked end
J.IsSuspiciousIllusion=function(u) return u.illusion end
J.CannotBeKilled=function(_,u) return u.protected end
J.CanKillTarget=function(u,d,t) assert(t==DAMAGE_TYPE_MAGICAL); return u.hp<=d end
J.IsGoingOnSomeone=function(u) return u.attack==true end
J.IsDoingRoshan=function() return false end
J.IsDoingTormentor=function() return false end
local hero=H.load('npc_dota_hero_abaddon','pos_5')
local stolen=H.realDofile('bots/FunLib/rubick_hero/abaddon.lua')
local function reset()
 talent.trained=false;supremacy.trained=false
 allies,enemies,actions,target={},{},{},nil
 for k,v in pairs(bot) do if type(v)~='function' then bot[k]=nil end end
 for k,v in pairs(unit(0)) do bot[k]=v end
 for _,a in pairs(abilities) do a.castable=false end
end
local function tick(a)
 actions={}; if a then stolen.ConsiderStolenSpell(abilities[a]) else hero.SkillsComplement() end
 return actions[1]
end
local coil,shield,ult='abaddon_death_coil','abaddon_aphotic_shield','abaddon_borrowed_time'
for _,rubick in ipairs({false,true}) do
 local function cast(spell,u) local a=tick(rubick and spell or nil); assert(a and a.name==spell and (not u or a.target==u),'expected '..spell) end
 local function none(spell) assert(tick(rubick and spell or nil)==nil,'expected no cast') end
 reset(); abilities[coil].castable=true; local ally=unit(300,300); ally.immune=true; allies={ally}
 target=unit(400,100); enemies={target}; bot.attack=true
 cast(coil,ally) -- Healing an immune ally wins over damage.
 ally.mods.modifier_ice_blast=true; cast(coil,target)
 target.mods.modifier_antimage_counterspell=true;none(coil);target.mods={}
 target.immune=true; none(coil)
 target.immune=false; target.x=626; none(coil); bot.bonus=100; cast(coil,target)
 bot.bonus=0; target.x=400; bot.hp=278; none(coil) -- 128 self cost + 150 reserve.
 bot.mods.modifier_abaddon_borrowed_time=true; cast(coil,target)
 bot.mods={}; bot.hp=1000; allies={}; target.hp=400; bot.attack=false; none(coil) -- no stale Shard attack kill.
 reset(); abilities[shield].castable=true; ally=unit(300); allies={ally}; ally.stun=true
 ally.mods.modifier_abaddon_aphotic_shield=true; cast(shield,ally) -- Dispel may replace existing Shield.
 ally.immune=true; none(shield); ally.immune=false; ally.x=551; none(shield)
 ally.x=300; ally.stun=false; ally.silence=true; cast(shield,ally)
 ally.mods.modifier_faceless_void_chronosphere_freeze=true; none(shield)
 ally.mods={modifier_dazzle_poison_touch=true};ally.silence=false;cast(shield,ally)
 ally.mods={}; ally.recent=true; ally.mods.modifier_item_solar_crest_armor_addition=true
 cast(shield,ally) -- Different barriers can coexist.
end
reset();abilities[coil].castable=true;target=unit(400,340);enemies={target};talent.trained=true
assert(tick().target==target,'native Coil damage talent counts toward kills')
bot.hp=290;assert(tick()==nil,'native Coil talent increases self cost to 142')
reset(); abilities[ult].castable=true; bot.hp=600; bot.recent=true; bot.mods.modifier_silver_edge_debuff=true
assert(tick().name==ult,'manual ultimate handles break above passive threshold')
bot.mods.modifier_silver_edge_debuff=false; bot.stun=true; assert(tick().name==ult,'manual ultimate bypasses stunned-caster gate')
bot.silence=true; assert(tick()==nil,'silence prevents manual ultimate')
reset(); abilities[ult].castable=true; bot.scepter=true; local ally=unit(600,400); ally.recent=true; allies={ally}
assert(tick().name==ult,'Scepter protects a threatened ally while Abaddon is healthy')
ally.x=626; assert(tick()==nil,'Scepter uses Coil range'); ally.x=600; ally.mods.modifier_ice_blast=true
assert(tick()==nil,'do not spend Scepter ultimate on blocked healing alone')
reset();abilities[coil].castable=true;target=unit(800,100);enemies={target}
assert(tick(coil)==nil,'stolen Coil cannot use a movement allowance as range')
supremacy.trained=true;assert(tick(coil).target==target,'stolen Coil includes Arcane Supremacy')
bot.mods.modifier_silver_edge_debuff=true;assert(tick(coil)==nil,'break disables passive cast range')
print('Abaddon ability scenarios passed')
