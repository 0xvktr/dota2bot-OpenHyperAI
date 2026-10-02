-- Actual OD/Sven/CK hero entry points: low-mana decisions must reach items,
-- then cast at the original target only after the hero reconsiders.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
local P = require('bots/FunLib/item_cast_policy')
BOT_MODE_NONE=0; BOT_MODE_LANING=1; BOT_MODE_FARM=2
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; DAMAGE_TYPE_MAGICAL=2; DAMAGE_TYPE_PHYSICAL=1; DAMAGE_TYPE_ALL=4; UNIT_LIST_ENEMY_HEROES=2
local now=100
function DotaTime() return now end
function GetUnitToUnitDistance(_, target) return target.range or 0 end
local Vec={}; Vec.__index=Vec
local function V(x,y) return setmetatable({x=x,y=y,z=0},Vec) end
Vec.__sub=function(a,b) return V(a.x-b.x,a.y-b.y) end
Vec.__add=function(a,b) return V(a.x+b.x,a.y+b.y) end
Vec.__mul=function(a,b) return V(a.x*b,a.y*b) end
function Vec:Normalized() local n=self:Length2D();return V(self.x/n,self.y/n) end
function Vec:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function GetUnitToLocationDistance(_,loc) return loc:Length2D() end
local actions, abilities, enemies = {}, {}, {}
bot.mana=50; bot.maxMana=1000; bot.mode=0; bot.hp=1000
function GetUnitList(kind) assert(kind==UNIT_LIST_ENEMY_HEROES);return enemies end
function bot:NumModifiers() return 0 end
function bot:IsDisarmed() return false end
function bot:HasScepter() return false end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return self.maxMana end
function bot:GetHealth() return self.hp end
function bot:GetMaxHealth() return 1000 end
bot.OriginalGetHealth=bot.GetHealth; bot.OriginalGetMaxHealth=bot.GetMaxHealth
function bot:GetActiveMode() return self.mode end
function bot:GetActiveModeDesire() return 0 end
function bot:GetAttackRange() return 450 end
function bot:GetAttackDamage() return 100 end
function bot:GetAttackTarget() return self.target end
function bot:GetTeam() return 2 end
function bot:GetLevel() return 12 end
function bot:GetLocation() return V(0,0) end
function bot:IsAlive() return true end
function bot:GetNearbyCreeps() return {} end
function bot:GetItemInSlot(slot) return (self.items or {})[slot] end
function bot:GetAbilityByName(name) return abilities[name] end
function bot:HasModifier() return false end
function bot:WasRecentlyDamagedByAnyHero() return self.damaged==true end
function bot:NumQueuedActions() return self.queued or 0 end
for _, method in ipairs({'IsChanneling','IsCastingAbility','IsUsingAbility','IsInvisible','IsMuted',
    'IsSilenced','IsStunned','IsHexed','IsNightmared'}) do
    bot[method]=function(self) return self[method..'Flag'] == true end
end
for _, method in ipairs({'Action_UseAbility','Action_UseAbilityOnEntity','Action_UseAbilityOnLocation',
    'ActionQueue_UseAbility','ActionQueue_UseAbilityOnEntity'}) do
    bot[method]=function(_, ability, target) actions[#actions+1]={ability=ability,target=target} end
end
local function ability(name,cost)
    local a={name=name,cost=cost or 150,cd=0,trained=true,auto=false,specials={},toggles=0}
    function a:GetManaCost() return self.cost end
    function a:GetCastRange() return 650 end
    function a:GetCastPoint() return 0.3 end
    function a:GetLevel() return 4 end
    function a:GetName() return self.name end
    function a:GetCooldownTimeRemaining() return self.cd end
    function a:IsNull() return false end
    function a:IsTrained() return self.trained end
    function a:IsHidden() return false end
    function a:IsActivated() return true end
    function a:IsPassive() return false end
    function a:IsFullyCastable() return self.trained and self.cd==0 and self.cost<=bot.mana end
    function a:GetAutoCastState() return self.auto end
    function a:ToggleAutoCast() self.auto=not self.auto; self.toggles=self.toggles+1 end
    function a:GetSpecialValueInt(key) return self.specials[key] or 0 end
    a.GetSpecialValueFloat=a.GetSpecialValueInt
    abilities[name]=a
    return a
end
local target={range=400,hp=1000,hero=true,channel=true,team=3,mods={}}
function target:IsNull() return false end
function target:IsMagicImmune() return self.immune==true end
function target:IsInvulnerable() return false end
function target:GetMaxMana() return 500 end
function target:GetEstimatedDamageToTarget(_,_,_,kind) return bot.damaged and 500 or 0 end
function target:IsAlive() return true end
function target:IsHero() return self.hero end
function target:IsChanneling() return self.channel end
function target:GetTeam() return self.team end
function target:GetHealth() return self.hp end
function target:GetMana() return 0 end
function target:GetActualIncomingDamage(damage) return damage end
function target:GetAttackRange() return 450 end
function target:GetLocation() return V(self.range,0) end
function target:IsFacingLocation() return true end
function target:HasModifier(name) return self.mods[name] == true end
function target:IsIllusion() return false end
J.CanNotUseAbility=function() return false end
J.GetProperTarget=function() return bot.target end
J.GetNearbyHeroes=function(_,_,enemy) return enemy and enemies or {bot} end
J.GetEnemyCount=function() return #enemies end
J.IsValidHero=function(t) return t ~= nil and t.hero == true end
J.IsValidTarget=J.IsValidHero; J.IsValid=function(t) return t ~= nil end
J.CanBeAttacked=function(t) return not t.immune end
J.CanCastOnNonMagicImmune=J.CanBeAttacked
J.CanCastOnTargetAdvanced=function(t) return not t.shield end
J.IsSuspiciousIllusion=function(t) return t.illusion == true end
J.IsInRange=function(a,t,range) return (t.range or a.range or 0) <= range end
J.IsDisabled=function() return false end
J.CanKillTarget=function() return false end
J.IsUnitTargetProjectileIncoming=function() return false end
J.CannotBeKilled=function() return false end
J.WillKillTarget=function(t,d) return t.hp<d end
J.GetCorrectLoc=function(t) return t:GetLocation() end
J.IsCastingUltimateAbility=function() return false end
J.IsInTeamFight=function() return false end
J.IsGoingOnSomeone=function() return false end
J.IsRetreating=function() return false end
J.IsLaning=function() return false end
J.IsDoingTormentor=function() return false end
J.IsDoingRoshan=function() return false end
J.IsAttacking=function() return true end
J.GetHP=function(t) return (t.hp or 1000)/1000 end
J.IsItemAvailable=function() return nil end
J.SetQueuePtToINT=function() end
J.ConsiderForMkbDisassembleMask=function() end
J.CombineTwoTable=function(a,b)
    local out={}; for _,t in ipairs(a) do out[#out+1]=t end; for _,t in ipairs(b) do out[#out+1]=t end; return out
end

local orb=ability('obsidian_destroyer_arcane_orb',0); orb.specials.mana_cost_percentage=20
local astral=ability('obsidian_destroyer_astral_imprisonment',150)
local ult=ability('obsidian_destroyer_sanity_eclipse',300)
local barrier=ability('obsidian_destroyer_objurgation',175);barrier.specials.barrier_flat=300;barrier.specials.mana_to_barrier=12
bot.items = { [0]=ability('item_enchanted_mango',0) }
local od=H.load('npc_dota_hero_obsidian_destroyer','pos_2')
bot.target=target; enemies={target}
od.SkillsComplement()
assert(#actions==0 and bot.ohaManaCastIntent.ability==astral, 'low mana must still select interrupt Astral')
assert(P.Intent(bot,J).target==target, 'intent preserves target identity')
target.channel=false; astral.cd=10
assert(P.Intent(bot,J)==nil, 'cooldown cancels old intent')
astral.cd=0; target.channel=true; bot.mana=150
od.SkillsComplement()
assert(#actions==1 and actions[1].ability==astral and actions[1].target==target, 'reconsidered cast after restoration')
local mango = bot.items[0]
local ring = ability('item_soul_ring',0); ring.specials.mana_gain=170
bot.items[0]=ring; bot.mana=50; actions={}
J.IsGoingOnSomeone=function() return true end
bot.damaged=true
od.SkillsComplement()
assert(#actions==0 and P.Intent(bot,J).ability==barrier, 'actual defensive barrier requests Soul Ring for mana')
assert(P.RestoreDesire(bot,ring,J)>0, 'safe health permits Soul Ring for the selected barrier')
bot.mana=175; od.SkillsComplement()
assert(#actions==1 and actions[1].ability==barrier, 'barrier is cast after mana restoration')
bot.damaged=false
J.IsGoingOnSomeone=function() return false end
bot.items[0]=mango
local considerBarrier=od.ConsiderObjurgation
od.ConsiderObjurgation=function() return 0 end
J.IsGoingOnSomeone=function() return true end
J.CanKillTarget=function(t,damage) return t.hp < damage end
target.hp=80; bot.mana=200; actions={}
ult.specials.base_damage=200; ult.specials.damage_multiplier=0.4;ult.specials.radius=500
od.SkillsComplement()
assert(#actions==0 and P.Intent(bot,J).ability==ult, 'real lethal Eclipse requests ground-cast restoration')
target.range=800
assert(P.RestoreDesire(bot,mango,J)==0, 'ground target out of range cancels restoration')
target.range=400; bot.mana=300
od.SkillsComplement(); assert(#actions==1 and actions[1].ability==ult, 'lethal Eclipse casts after restoration')
od.ConsiderObjurgation=considerBarrier; target.hp=1000
J.IsGoingOnSomeone=function() return false end
J.CanKillTarget=function() return false end
actions={}; bot.queued=1; bot.mana=800
od.SkillsComplement(); assert(#actions==0, 'pending queue cannot be replaced'); bot.queued=0
bot.IsChannelingFlag=true; od.SkillsComplement(); assert(#actions==0); bot.IsChannelingFlag=false

-- OD switches both ways, uses a percentage cost, and never relies on a proc.
assert(od.OrbManaReserve()==450, 'Astral plus expensive ready combat spell')
bot.mana=800; od.UpdateOrbAutocast(); assert(orb.auto, 'valuable hero attacks above reserve')
bot.mana=500; od.UpdateOrbAutocast(); assert(not orb.auto, 'reserve stops autocast despite high level')
assert(not od.CanSpendOrb(), 'manual Orb obeys the same reserve')
ult.cd=10; assert(od.OrbManaReserve()==325, 'cooldown releases ult reserve but keeps barrier')
barrier.cd=10; assert(od.OrbManaReserve()==150)
bot.mana=300; od.UpdateOrbAutocast(); assert(orb.auto, 'ready costs adapt after cooldowns')
enemies={}; ult.cd=0; barrier.cd=0
target.hero=false
bot.mana=400; od.UpdateOrbAutocast(); assert(orb.auto, 'normal farming keeps only ready Astral reserve')
target.hp=80; od.UpdateOrbAutocast(); assert(not orb.auto, 'ordinary last hit needs no Orb')
target.hp=1000; bot.mana=200; od.UpdateOrbAutocast(); assert(not orb.auto, 'restart buffer avoids threshold chatter')
bot.mana=300; od.UpdateOrbAutocast(); assert(orb.auto)
target.mods.modifier_dazzle_shallow_grave=true; od.UpdateOrbAutocast(); assert(not orb.auto)
target.mods={}; target.illusion=true; od.UpdateOrbAutocast(); assert(not orb.auto); target.illusion=false
target.immune=true; od.UpdateOrbAutocast(); assert(not orb.auto, 'immune target is not a valuable Orb'); target.immune=false
target.range=600; od.UpdateOrbAutocast(); assert(not orb.auto); target.range=400
target.hero=true; enemies={target}; target.channel=true; bot.mana=50

-- Shared low-mana integration also runs the real Sven / CK interrupt decision.
local q=ability('A1',150); ability('A2',50); ability('A3',50); ability('A6',100)
for _, hero in ipairs({'sven','chaos_knight'}) do
    local build=H.load('npc_dota_hero_'..hero,'pos_1')
    build.ConsiderR=function() return 0 end
    build.ConsiderE=function() return 0 end
    build.ConsiderW=function() return 0 end
    build.SvenConsiderTarget=function() end
    actions={}; bot.mana=50; q.cd=0
    build.SkillsComplement()
    assert(#actions==0 and P.Intent(bot,J).ability==q, hero..' publishes affordable restoration intent')
    bot.mana=150; build.SkillsComplement()
    assert(#actions==1 and actions[1].ability==q and actions[1].target==target, hero..' retains validated stun target')
    if hero=='sven' then
        bot.items={}; actions={}; bot.mana=50
        build.ConsiderE=function() return 1 end
        build.SkillsComplement()
        assert(#actions==1 and actions[1].ability==abilities.A3 and bot.ohaManaCastIntent==nil,
            'unaffordable stun without restoration must not block Warcry')
        bot.items={[0]=mango}
    end
    actions={}; bot.IsChannelingFlag=true; build.SkillsComplement()
    assert(#actions==0, hero..' must keep channel'); bot.IsChannelingFlag=false
end
print('Hero item policy scenarios passed')
