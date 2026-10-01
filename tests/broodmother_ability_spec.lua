-- Tactical Spawn, attack windows, owned web corridors and emergency cast order.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0
UNIT_LIST_ALLIES=1; DAMAGE_TYPE_MAGICAL=2; DAMAGE_TYPE_PHYSICAL=1
local enemies, creeps, neutrals, webs, actions = {}, {}, {}, {}, {}
local target, mode, attacking, damaged, stuck = nil, '', false, false, false
local clock=10
local lens=nil
function DotaTime() return clock end
local function unit(x,hp,name)
    local u={x=x,hp=hp or 1000,name=name or 'npc_dota_hero_enemy',mods={},valid=true,player=0}
    function u:GetLocation() return Vector(self.x,0,0) end
    function u:GetExtrapolatedLocation() return Vector(self.x+(self.prediction or 0),0,0) end
    function u:GetHealth() return self.hp end
    function u:GetUnitName() return self.name end
    function u:GetPlayerID() return self.player end
    function u:HasModifier(name) return self.mods[name]==true end
    function u:GetActualIncomingDamage(damage,kind) return damage*(kind==DAMAGE_TYPE_MAGICAL and (self.magic or 1) or 1) end
    return u
end
function GetUnitToLocationDistance(u,v) return math.abs(u:GetLocation().x-v.x) end
function GetUnitToUnitDistance(a,b) return GetUnitToLocationDistance(a,b:GetLocation()) end
function GetUnitList() return webs end
function bot:GetLocation() return Vector(0,0,0) end
function bot:GetPlayerID() return 0 end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:GetAttackRange() return 175 end
function bot:GetAttackDamage() return 80 end
function bot:IsDisarmed() return self.disarmed==true end
function bot:HasModifier(name) return self.mods[name]==true end
function bot:WasRecentlyDamagedByAnyHero() return damaged end
function bot:GetNearbyLaneCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:FindAoELocation() return {count=0,targetloc=Vector(0,0,0)} end
function bot:Action_UseAbility(a) actions[#actions+1]={name=a.name} end
function bot:Action_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
function bot:Action_UseAbilityOnLocation(a,v) actions[#actions+1]={name=a.name,loc=v} end
local abilities={}
local function ability(name,range,cost,values)
    local a={name=name,range=range,cost=cost,values=values or {},castable=false,hidden=false}
    function a:GetName() return self.name end
    function a:GetCastRange() return self.range end
    function a:GetCastPoint() return 0.4 end
    function a:GetManaCost() return self.cost end
    function a:IsTrained() return true end
    function a:IsFullyCastable() return self.castable end
    function a:IsHidden() return self.hidden end
    function a:GetSpecialValueInt(key) return self.values[key] or 0 end
    abilities[name]=a; return a
end
local hunger=ability('broodmother_insatiable_hunger',0,70)
local web=ability('broodmother_spin_web',1200,40,{radius=1200})
local spawn=ability('broodmother_spawn_spiderlings',900,100,{damage=420})
function bot:GetAbilityByName(name) return abilities[name] end
J.CanNotUseAbility=function() return false end
J.IsItemAvailable=function() return lens end
J.GetProperTarget=function() return target end
J.IsValid=function(u) return u~=nil and u.valid end
J.IsValidTarget=J.IsValid
J.IsValidHero=function(u) return J.IsValid(u) and u.name:find('hero',1,true)~=nil end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnNonMagicImmune=function(u) return not u.immune and not u.invulnerable end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.invulnerable end
J.CanBeAttacked=function(u) return not u.attackImmune and not u.invulnerable end
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.CanKillTarget=function(u,dmg,kind) return u:GetActualIncomingDamage(dmg,kind)>=u.hp end
J.GetNearbyHeroes=function() return enemies end
J.IsDisabled=function(u) return u.disabled==true end
J.IsChasingTarget=function(u) return u.chasing==true end
J.IsInTeamFight=function() return mode=='fight' end
J.IsGoingOnSomeone=function() return mode=='attack' end
J.IsRetreating=function() return mode=='retreat' end
J.IsLaning=function() return mode=='lane' end
J.IsFarming=function() return mode=='farm' end
J.IsPushing=function() return mode=='push' end
J.IsDefending=function() return mode=='defend' end
J.IsDoingRoshan=function() return mode=='roshan' end
J.IsDoingTormentor=function() return mode=='tormentor' end
J.IsRoshan=function(u) return u and u.name=='roshan' end
J.IsTormentor=function(u) return u and u.name=='tormentor' end
J.IsStuck=function() return stuck end
J.IsAttacking=function() return attacking end
J.GetHP=function() return bot.hp end
J.IsKeyWordUnit=function(word,u) return u.name:find(word,1,true)~=nil end
J.IsLocationInChrono=function(v) return v.chrono==true end
J.IsLocationInBlackHole=function(v) return v.blackhole==true end
J.GetCenterOfUnits=function(units) local x=0; for _,u in pairs(units) do x=x+u.x end; return Vector(x/#units,0,0) end
J.GetTeamFountain=function() return Vector(-10000,0,0) end
J.Site={GetXUnitsTowardsLocation=function(u,loc,range) return Vector(-range,0,0) end}
local hero=H.load('npc_dota_hero_broodmother','pos_2')
local rubick=H.realDofile('bots/FunLib/rubick_hero/broodmother.lua')
local function reset()
    enemies,creeps,neutrals,webs,actions={}, {}, {}, {}, {}
    target=nil; mode=''; attacking=false; damaged=false; stuck=false
    lens=nil; abilities.rubick_arcane_supremacy=nil
    bot.mods={}; bot.hp=1; bot.mana=1000; bot.disarmed=false; clock=clock+2
    for _,a in pairs(abilities) do a.castable=false; a.hidden=false end
end
local function check(label,ability,consider,setup,expected)
    reset(); ability.castable=true; setup()
    local desire,result=consider()
    assert((expected==nil and desire==0) or (expected~=nil and desire>0 and (expected==true or result==expected())),label..' native')
    rubick.ConsiderStolenSpell(ability)
    assert((expected==nil and #actions==0) or (expected~=nil and #actions==1),label..' stolen')
    if type(expected)=='function' then assert(actions[1].target==expected(),label..' stolen target') end
end
local victim
check('Spawn slows healthy chase target',spawn,hero.ConsiderSpawnSpiderlings,function()
    mode='attack'; victim=unit(700); target=victim
end,function() return victim end)
check('Spawn follows allied control',spawn,hero.ConsiderSpawnSpiderlings,function()
    mode='attack'; victim=unit(500); victim.disabled=true; target=victim
end,function() return victim end)
for _,flag in ipairs({'immune','blocked','illusion','invulnerable'}) do
    check('Spawn excludes '..flag,spawn,hero.ConsiderSpawnSpiderlings,function()
        victim=unit(500,100); victim[flag]=true; enemies={victim}
    end,nil)
end
check('Spawn excludes current Counterspell',spawn,hero.ConsiderSpawnSpiderlings,function()
    victim=unit(500,100); victim.mods.modifier_antimage_counterspell=true; enemies={victim}
end,nil)
check('Spawn excludes allied Counterspell',spawn,hero.ConsiderSpawnSpiderlings,function()
    victim=unit(500,100); victim.mods.modifier_antimage_counterspell_ally=true; enemies={victim}
end,nil)
check('Spawn true range',spawn,hero.ConsiderSpawnSpiderlings,function()
    victim=unit(901,100); enemies={victim}
end,nil)
check('Spawn uses active Lens reach',spawn,hero.ConsiderSpawnSpiderlings,function()
    victim=unit(1100,100); enemies={victim}
    lens={GetSpecialValueInt=function() return 225 end}
end,function() return victim end)
check('Spawn uses unbroken Arcane Supremacy',spawn,hero.ConsiderSpawnSpiderlings,function()
    victim=unit(1100,100); enemies={victim}
    ability('rubick_arcane_supremacy',0,0,{cast_range=240})
end,function() return victim end)
check('Spawn loses Supremacy reach under Break',spawn,hero.ConsiderSpawnSpiderlings,function()
    victim=unit(1100,100); enemies={victim}
    ability('rubick_arcane_supremacy',0,0,{cast_range=240})
    bot.mods.modifier_break=true
end,nil)
check('Spawn refuses Grave kill',spawn,hero.ConsiderSpawnSpiderlings,function()
    victim=unit(500,100); victim.mods.modifier_dazzle_shallow_grave=true; enemies={victim}
end,nil)
check('Spawn does not refresh active slow for harass',spawn,hero.ConsiderSpawnSpiderlings,function()
    mode='attack'; victim=unit(500); victim.mods.modifier_broodmother_spawn_spiderlings_slow=true; target=victim
end,nil)
check('Spawn can finish slowed target',spawn,hero.ConsiderSpawnSpiderlings,function()
    victim=unit(500,100); victim.mods.modifier_broodmother_spawn_spiderlings_slow=true; enemies={victim}
end,function() return victim end)
check('Spawn slows retreat pursuer',spawn,hero.ConsiderSpawnSpiderlings,function()
    mode='retreat'; damaged=true; victim=unit(600); victim.chasing=true; enemies={victim}
end,function() return victim end)
check('Spawn neutral recruitment beyond immediate nuke',spawn,hero.ConsiderSpawnSpiderlings,function()
    mode='farm'; attacking=true; victim=unit(500,550,'neutral'); target=victim; neutrals={victim}
end,function() return victim end)
check('Spawn farm protects mana reserve',spawn,hero.ConsiderSpawnSpiderlings,function()
    mode='farm'; bot.mana=300; victim=unit(500,200,'neutral'); neutrals={victim}
end,nil)
check('Spawn last hit uses actual magical damage',spawn,hero.ConsiderSpawnSpiderlings,function()
    mode='lane'; victim=unit(500,300,'creep'); victim.magic=0.5; creeps={victim}
end,nil)
check('Spawn combat before available creep',spawn,hero.ConsiderSpawnSpiderlings,function()
    mode='attack'; victim=unit(600); target=victim; creeps={unit(400,100,'creep')}
end,function() return victim end)
check('Hunger healthy controlled target',hunger,hero.ConsiderInsatiableHunger,function()
    mode='attack'; target=unit(250); target.disabled=true
end,true)
check('Hunger lane sustain',hunger,hero.ConsiderInsatiableHunger,function()
    mode='lane'; attacking=true; bot.hp=0.5; target=unit(200,900,'creep')
end,true)
check('Hunger tower damage',hunger,hero.ConsiderInsatiableHunger,function()
    mode='push'; attacking=true; target=unit(200,3000,'tower')
end,true)
check('Hunger disarm',hunger,hero.ConsiderInsatiableHunger,function()
    mode='attack'; target=unit(200); bot.disarmed=true
end,nil)
check('Hunger attack immune target',hunger,hero.ConsiderInsatiableHunger,function()
    mode='attack'; target=unit(200); target.attackImmune=true
end,nil)
check('Hunger no buff refresh',hunger,hero.ConsiderInsatiableHunger,function()
    mode='attack'; target=unit(200); bot.mods.modifier_broodmother_insatiable_hunger=true
end,nil)
local function webCase(label,setup,expectedX)
    reset(); web.castable=true; setup()
    local d,loc=hero.ConsiderSpinWeb()
    assert(expectedX==nil and d==0 or expectedX~=nil and d>0 and loc.x==expectedX,label..' native')
    rubick.ConsiderStolenSpell(web)
    assert(expectedX==nil and #actions==0 or expectedX~=nil and #actions==1 and actions[1].loc.x==expectedX,label..' stolen')
end
webCase('Web lane with small wave',function() mode='lane'; creeps={unit(600,100,'creep')} end,600)
webCase('Web prevents center duplication',function()
    mode='lane'; creeps={unit(600,100,'creep')}; webs={unit(0,100,'npc_dota_broodmother_web')}
end,nil)
webCase('Web extends near existing edge',function()
    mode='attack'; target=unit(1000); webs={unit(0,100,'npc_dota_broodmother_web')}
end,1000)
webCase('Web remote connected placement',function()
    mode='attack'; target=unit(1500); webs={unit(500,100,'npc_dota_broodmother_web')}
end,1500)
webCase('Web rejects remote disconnected cast',function() mode='attack'; target=unit(1500) end,nil)
webCase('Web allied ownership cannot extend remote cast',function()
    mode='attack'; target=unit(1500); local other=unit(500,100,'npc_dota_broodmother_web'); other.player=1; webs={other}
end,nil)
webCase('Web retreat corridor',function() mode='retreat'; damaged=true end,-600)
webCase('Web clears stuck position',function() stuck=true end,0)
reset(); mode='retreat'; damaged=true; web.castable=true; spawn.castable=true
victim=unit(400,100); enemies={victim}; hero.SkillsComplement()
assert(#actions==1 and actions[1].name==web.name,'escape web before lethal spawn')
-- The one-second web throttle must not consume a tick that can activate Hunger.
mode='attack'; target=unit(250); hunger.castable=true; spawn.castable=false; actions={}
hero.SkillsComplement()
assert(#actions==1 and actions[1].name==hunger.name,'web throttle does not starve Hunger')
local retired=ability('broodmother_silken_bola',750,70); retired.castable=true; actions={}
assert(rubick.ConsiderStolenSpell(retired)==nil and #actions==0,'retired Bola has no current dedicated handler')
print('Broodmother ability scenarios passed')
