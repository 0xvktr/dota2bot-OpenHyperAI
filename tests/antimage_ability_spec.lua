-- Anti-Mage spell order, Mana Void splash/interrupts, and Blink safety.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0
BOT_MODE_DESIRE_HIGH=0.7; DAMAGE_TYPE_MAGICAL=2; UNIT_LIST_ENEMY_HEROES=2
local enemies, actions, target, retreat, incoming, passable = {}, {}, nil, false, false, true
local function unit(x,hp,mana,maxMana)
    local u={x=x,hp=hp or 1000,mana=mana or 0,maxMana=maxMana or 1000,mods={},valid=true}
    function u:GetLocation() return Vector(self.x,0,0) end
    function u:GetExtrapolatedLocation() return self:GetLocation() end
    function u:GetHealth() return self.hp end
    function u:GetMaxMana() return self.maxMana end
    function u:GetMana() return self.mana end
    function u:HasModifier(name) return self.mods[name]==true end
    function u:IsChanneling() return self.channel==true end
    function u:IsMagicImmune() return self.immune==true end
    function u:IsAttackImmune() return false end
    function u:GetActualIncomingDamage(dmg,kind) assert(kind==DAMAGE_TYPE_MAGICAL); return dmg*(self.mitigation or 1) end
    return u
end
function GetUnitToUnitDistance(a,b) return math.abs(a:GetLocation().x-b:GetLocation().x) end
function GetUnitList() return enemies end
function IsLocationPassable() return passable end
function bot:GetLocation() return Vector(0,0,0) end
function bot:HasModifier(name) return self.mods[name]==true end
function bot:IsRooted() return self.rooted==true end
function bot:IsMagicImmune() return false end
function bot:GetMana() return self.mana end
function bot:GetAttackPoint() return 0.3 end
function bot:GetAttackRange() return 150 end
function bot:HasScepter() return self.scepter==true end
function bot:SetTarget(u) target=u end
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={name=a.name} end
function bot:ActionQueue_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
function bot:ActionQueue_UseAbilityOnLocation(a,v) actions[#actions+1]={name=a.name,loc=v} end
function bot:ActionQueue_Delay() end
function bot:Action_UseAbilityOnLocation(a,v) actions[#actions+1]={name=a.name,loc=v} end
local abilities={}
local function ability(name,range,cost,values)
    local a={name=name,range=range,cost=cost,values=values or {},castable=false,hidden=false}
    function a:GetName() return self.name end
    function a:IsFullyCastable() return self.castable end
    function a:IsTrained() return true end
    function a:IsHidden() return self.hidden end
    function a:GetCastRange() return self.range end
    function a:GetCastPoint() return 0.4 end
    function a:GetManaCost() return self.cost end
    function a:GetSpecialValueInt(key) return self.values[key] or 0 end
    function a:GetSpecialValueFloat(key) return self.values[key] or 0 end
    abilities[name]=a; return a
end
local blink=ability('antimage_blink',1100,45,{AbilityCastRange=1100})
local void=ability('antimage_mana_void',600,200,{mana_void_aoe_radius=500,mana_void_damage_per_mana=1})
local counter=ability('antimage_counterspell',0,50)
-- Removed Counterspell Ally is intentionally absent.
local fragment=ability('antimage_mana_overload',0,50)
function bot:GetAbilityByName(name) return abilities[name] end
J.CanNotUseAbility=function() return false end
J.GetProperTarget=function() return target end
J.IsValidHero=function(u) return u~=nil and u.valid end
J.IsValidTarget=J.IsValidHero
J.CanCastOnNonMagicImmune=function(u) return not u.immune and not u.invulnerable end
J.CanCastOnMagicImmune=function(u) return not u.invulnerable end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.invulnerable end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.IsHaveAegis=function(u) return u.aegis==true end
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.CanKillTarget=function(u,dmg,kind) return u:GetActualIncomingDamage(dmg,kind)>=u.hp end
J.GetNearbyHeroes=function(u,r,enemy)
    -- Calls around an enemy invert perspective: true means Anti-Mage's allies.
    if u~=bot then return enemy and (u.allies or {bot}) or (u.defenders or {u}) end
    return enemy and enemies or {bot}
end
J.GetEnemiesNearLoc=function() return enemies end
J.IsGoingOnSomeone=function() return false end
J.IsRetreating=function() return retreat end
J.IsLaning=function() return false end
J.IsPushing=function() return false end
J.IsDoingRoshan=function() return false end
J.IsDoingTormentor=function() return false end
J.IsStuck=function() return false end
J.IsStunProjectileIncoming=function() return incoming end
J.IsUnitTargetProjectileIncoming=function() return incoming end
J.IsWillBeCastUnitTargetSpell=function() return false end
J.SetQueuePtToINT=function() end
J.GetTeamFountain=function() return Vector(-10000,0,0) end
J.GetProperCastRange=function(_,_,range) return range end
J.Site={GetXUnitsTowardsLocation=function(u,loc,r)
    return Vector(u:GetLocation().x+(loc.x>=u:GetLocation().x and r or -r),0,0)
end}
local hero=H.load('npc_dota_hero_antimage','pos_1')
local rubick=H.realDofile('bots/FunLib/rubick_hero/antimage.lua')
local function reset()
    enemies,actions,target={}, {},nil
    retreat,incoming,passable=false,false,true
    bot.mods={}; bot.rooted=false; bot.mana=1000; bot.scepter=false
    for _,a in pairs(abilities) do a.castable=false; a.hidden=false end
    void.castable=true
end
local function desire(fn) return select(1,fn()) end
local function checkVoid(label,setup,expected)
    reset(); setup()
    local d,u=hero.ConsiderManaVoid()
    assert((expected==nil and d==0) or (d>0 and u==expected()),label..' hero')
    actions={}; rubick.ConsiderStolenSpell(void)
    assert((expected==nil and #actions==0) or (#actions==1 and actions[1].target==expected()),label..' Rubick')
end
local source,victim
checkVoid('high-mana source kills adjacent victim while surviving',function()
    source=unit(400,2000,0,1200); victim=unit(700,500,900,1000); enemies={victim,source}
end,function() return source end)
checkVoid('maximizes splash kills rather than list order',function()
    local single=unit(-500,100,0,200)
    source=unit(400,2000,0,1000); victim=unit(850,600,900,1000)
    local other=unit(800,650,1000,1000); enemies={single,source,victim,other}
end,function() return source end)
checkVoid('interrupts full-mana channel',function()
    source=unit(400,2000,1000,1000); source.channel=true; enemies={source}
end,function() return source end)
checkVoid('refuses spell-blocked primary',function()
    source=unit(400,100,0,1000); source.blocked=true; enemies={source}
end,nil)
checkVoid('refuses protected splash kills',function()
    source=unit(400,2000,0,1000); victim=unit(700,100,1000,1000)
    victim.mods.modifier_dazzle_shallow_grave=true; enemies={source,victim}
end,nil)
checkVoid('does not walk to out-of-range source',function()
    source=unit(601,100,0,1000); enemies={source}
end,nil)
checkVoid('does not treat illusions as damage sources',function()
    source=unit(400,100,0,1000); source.illusion=true; enemies={source}
end,nil)
checkVoid('refuses reflected primary',function()
    source=unit(400,100,0,1000); source.mods.modifier_antimage_counterspell=true; enemies={source}
end,nil)
checkVoid('ignores immune splash victim',function()
    source=unit(400,2000,0,1000); victim=unit(700,100,1000,1000); victim.immune=true; enemies={source,victim}
end,nil)
checkVoid('splash only counts actual radius',function()
    source=unit(400,2000,0,1000); victim=unit(901,100,1000,1000); enemies={source,victim}
end,nil)
checkVoid('Aegis source can still kill splash victim',function()
    source=unit(400,2000,0,1000); source.aegis=true; victim=unit(700,100,1000,1000); enemies={source,victim}
end,function() return source end)
checkVoid('full-mana non-channel does not waste Void',function()
    source=unit(400,100,1000,1000); enemies={source}
end,nil)
reset(); source=unit(450,100,0,1000); enemies={source}; blink.castable=true
hero.SkillsComplement()
assert(#actions==1 and actions[1].name==void.name,'direct Void before Blink')
reset(); source=unit(900,100,0,1000); enemies={source}; blink.castable=true; counter.castable=true; incoming=true
hero.SkillsComplement()
assert(#actions==1 and actions[1].name==counter.name,'incoming Counterspell before offensive combo')
reset(); source=unit(1590,100,0,1000); enemies={source}; blink.castable=true
local d,loc,u=hero.ConsiderBlinkVoid()
assert(d>0 and u==source and loc.x<=1100 and math.abs(source.x-loc.x)<600,'bounded Blink ends in Void range')
bot.rooted=true; assert(desire(hero.ConsiderBlinkVoid)==0,'root disables combo')
bot.rooted=false; bot.mods.modifier_bloodseeker_rupture=true
assert(desire(hero.ConsiderBlinkVoid)==0,'Rupture rejects offensive combo')
bot.mods={}; retreat=true; assert(desire(hero.ConsiderBlinkVoid)==0,'retreat rejects offensive combo')
retreat=false; bot.mana=244; assert(desire(hero.ConsiderBlinkVoid)==0,'reserve mana for entire combo')
bot.mana=1000; source.x=1701; assert(desire(hero.ConsiderBlinkVoid)==0,'reject unreachable combo')
source.x=900; source.defenders={source,unit(950)}
assert(desire(hero.ConsiderBlinkVoid)==0,'reject outnumbered combo')
source.defenders=nil; passable=false; assert(desire(hero.ConsiderBlinkVoid)==0,'reject impassable landing')
passable=true; source.x=450; assert(desire(hero.ConsiderBlinkVoid)==0,'never Blink for direct Void')
reset(); void.castable=false; hero.SkillsComplement()
assert(#actions==0 and desire(hero.ConsiderCounterSpellAlly)==0,'missing legacy ally ability is safe')
fragment.castable=true; fragment.hidden=true; bot.scepter=true
assert(desire(hero.ConsiderBlinkFragment)==0,'hidden Fragment remains inactive')
rubick.ConsiderStolenSpell(fragment)
assert(#actions==0,'Rubick hidden Fragment remains inactive')
reset(); counter.castable=true; incoming=true; bot.mods.modifier_antimage_counterspell=true
assert(desire(hero.ConsiderCounterSpell)==0,'do not refresh existing shield')
-- Rubick can Blink-dodge with Blink stolen alone, without Counterspell in another slot.
reset(); void.castable=false; blink.castable=true; incoming=true
rubick.ConsiderStolenSpell(blink)
assert(#actions==1 and actions[1].name==blink.name,'stolen Blink dodge without Counterspell')
print('Anti-Mage ability decisions passed')
