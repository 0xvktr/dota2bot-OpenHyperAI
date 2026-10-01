-- Beastmaster: legal Roar/Blink decisions, Axes placement, and modern summons.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0
DAMAGE_TYPE_MAGICAL=2; DAMAGE_TYPE_ALL=3
local V={}; V.__index=V
function Vector(x,y,z) return setmetatable({x=x,y=y or 0,z=z or 0},V) end
function V.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function V.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function V.__mul(a,n) return Vector(a.x*n,a.y*n,a.z*n) end
function V:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function V:Normalized() local n=self:Length2D(); return Vector(self.x/n,self.y/n,0) end
local enemies, lanes, neutrals, towers, actions, target={}, {}, {}, {}, {}, nil
local mode, fight, hazard, passable, damage = '', false, false, true, false
local function unit(x,y,hp)
    local u={loc=Vector(x,y),hp=hp or 1000,mods={},valid=true,threat=100,name='enemy'}
    function u:GetLocation() return self.loc end
    function u:GetExtrapolatedLocation(delay) self.delay=delay; return self.predicted or self.loc end
    function u:HasModifier(name) return self.mods[name]==true end
    function u:IsChanneling() return self.channel==true end
    function u:IsFacingLocation() return self.facing~=false end
    function u:GetHealth() return self.hp end
    function u:GetEstimatedDamageToTarget() return self.threat end
    function u:GetUnitName() return self.name end
    function u:IsNull() return false end
    return u
end
function GetUnitToUnitDistance(a,b) return (a:GetLocation()-b:GetLocation()):Length2D() end
function GetUnitToLocationDistance(a,v) return (a:GetLocation()-v):Length2D() end
function IsLocationPassable() return passable end
function bot:GetLocation() return Vector(0,0) end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:GetItemInSlot(i) if i==0 then return self.blink elseif i==1 then return self.bkb end end
function bot:HasModifier(name) return self.mods[name]==true end
function bot:IsRooted() return self.rooted end
function bot:IsMagicImmune() return false end
function bot:WasRecentlyDamagedByAnyHero() return damage end
function bot:GetNearbyLaneCreeps() return lanes end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:GetNearbyTowers() return towers end
function bot:SetTarget(u) self.focus=u end
function bot:FindAoELocation() return self.aoe or {count=0,targetloc=Vector(0,0)} end
function bot:Action_ClearActions() end
function bot:ActionQueue_Delay() end
for _,name in ipairs({'Action_UseAbility','Action_UseAbilityOnEntity','Action_UseAbilityOnLocation',
    'ActionQueue_UseAbility','ActionQueue_UseAbilityOnEntity','ActionQueue_UseAbilityOnLocation'}) do
    bot[name]=function(_,a,u) actions[#actions+1]={name=a.name,arg=u,action=name} end
end
local abilities={}
local function ability(name,range,cost,values)
    local a={name=name,range=range,cost=cost,values=values or {},castable=false,trained=true}
    function a:GetName() return self.name end
    function a:IsFullyCastable() return self.castable end
    function a:IsHidden() return self.hidden==true end
    function a:IsTrained() return self.trained end
    function a:GetCastRange() return self.range end
    function a:GetManaCost() return self.cost end
    function a:GetCastPoint() return 0.3 end
    function a:GetSpecialValueInt(k) return self.values[k] or 0 end
    function a:GetSpecialValueFloat(k) return self.values[k] or 0 end
    abilities[name]=a; return a
end
local roar=ability('beastmaster_primal_roar',600,150,{damage=300,duration=3.5})
local axes=ability('beastmaster_wild_axes',1500,65,{radius=175,axe_damage=160,min_throw_duration=0.4,max_throw_duration=1})
local boar=ability('beastmaster_summon_razorback',0,60)
local hawk=ability('beastmaster_summon_raptor',0,50,{attack_radius=500})
local blink=ability('item_blink',0,0,{blink_range=1200})
local bkb=ability('item_black_king_bar',0,50)
local lens=ability('item_aether_lens',0,0,{cast_range_bonus=250})
local supremacy=ability('rubick_arcane_supremacy',0,0,{cast_range=100})
abilities.rubick_arcane_supremacy=nil
function bot:GetAbilityByName(name) return abilities[name] end
J.CanNotUseAbility=function() return false end
J.GetProperTarget=function() return target end
J.HasBreakModifier=function(u) return u.broken==true end
J.IsItemAvailable=function(name) if name=='item_aether_lens' then return bot.lens end end
J.IsValid=function(u) return u~=nil and u.valid end
J.IsValidHero=J.IsValid; J.IsValidTarget=J.IsValid
J.CanCastOnNonMagicImmune=function(u) return not u.immune and not u.invulnerable end
J.CanCastOnMagicImmune=function(u) return not u.invulnerable end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.reflected end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.IsDisabled=function(u) return u.disabled==true end
J.IsTaunted=function(u) return u.taunted==true end
J.IsInRange=function(a,b,r) return b~=nil and GetUnitToUnitDistance(a,b)<=r end
J.CanKillTarget=function(u,n) return not u.immune and u.hp<=n*(u.mitigation or 1) end
J.IsCastingUltimateAbility=function(u) return u.castingUlt==true end
J.IsHaveAegis=function(u) return u.aegis==true end
J.IsLocationInChrono=function() return hazard end
J.IsLocationInBlackHole=function() return false end
J.GetNearbyHeroes=function(u,r,enemy)
    if u~=bot then return u.defenders or {} end
    if not enemy then return bot.allies or {} end
    local list={}; for _,e in pairs(enemies) do if GetUnitToUnitDistance(bot,e)<=r then list[#list+1]=e end end
    return list
end
J.IsInTeamFight=function() return fight end
J.IsAttacking=function() return true end
for method,value in pairs({IsGoingOnSomeone='attack',IsRetreating='retreat',IsLaning='lane',IsPushing='push',
    IsDefending='defend',IsFarming='farm',IsDoingRoshan='roshan',IsDoingTormentor='tormentor'}) do
    J[method]=function() return mode==value end
end
J.IsRoshan=function(u) return u and u.name=='roshan' end
J.IsTormentor=function(u) return u and u.name=='tormentor' end
local minionCalls=0
local normalDofile=dofile
dofile=function(path)
    if path=='bots/FunLib/aba_minion' then return {MinionThink=function() minionCalls=minionCalls+1 end} end
    return normalDofile(path)
end
local hero=H.load('npc_dota_hero_beastmaster','pos_3')
dofile=normalDofile
local copy=H.realDofile('bots/FunLib/rubick_hero/beastmaster.lua')
local function reset()
    enemies,lanes,neutrals,towers,actions,target={}, {}, {}, {}, {}, nil
    mode,fight,hazard,passable,damage='',false,false,true,false
    bot.mana=1000; bot.mods={}; bot.rooted=false; bot.blink=nil; bot.bkb=nil; bot.lens=nil; bot.broken=false
    bot.allies={}; bot.aoe=nil; bot.focus=nil; blink.cost=0
    for _,a in pairs(abilities) do a.castable=false; a.hidden=false end
    abilities.beastmaster_wild_axes=axes
    abilities.rubick_arcane_supremacy=nil
end
local function cast(module,spell)
    if module==hero then hero.SkillsComplement() else copy.ConsiderStolenSpell(spell) end
end
for _,module in ipairs({hero,copy}) do
    reset(); roar.castable=true; blink.castable=true; bot.blink=blink; mode='attack'
    target=unit(400,0); target.immune=true; enemies={target}
    cast(module,roar)
    assert(#actions==1 and actions[1].name==roar.name and actions[1].arg==target,'direct BKB-piercing Roar before Blink')
    reset(); roar.castable=true; target=unit(550,0); target.channel=true; enemies={target}
    cast(module,roar); assert(#actions==1,'interrupt a non-ultimate channel in every mode')
    reset(); roar.castable=true; target=unit(650,0); target.channel=true; enemies={target}
    cast(module,roar); assert(#actions==0,'legal cast range, not movement allowance')
    reset(); roar.castable=true; bot.lens=lens; abilities.rubick_arcane_supremacy=supremacy
    target=unit(900,0); target.channel=true; enemies={target}
    cast(module,roar); assert(#actions==1,'legal Lens and active Arcane Supremacy range bonuses')
    actions={}; bot.broken=true; cast(module,roar)
    assert(#actions==0,'broken Arcane Supremacy supplies no bonus range')
    for _,modifier in ipairs({'modifier_antimage_counterspell'}) do
        reset(); roar.castable=true; target=unit(500,0); target.channel=true; target.mods[modifier]=true; enemies={target}
        cast(module,roar); assert(#actions==0,'do not cast into Counterspell')
    end
    for _,field in ipairs({'blocked','reflected','illusion','invulnerable'}) do
        reset(); roar.castable=true; target=unit(500,0); target.channel=true; target[field]=true; enemies={target}
        cast(module,roar); assert(#actions==0,'reject spell block/reflection and invalid primary targets')
    end
    reset(); mode='retreat'; damage=true; roar.castable=true; target=unit(400,0); enemies={target}
    cast(module,roar); assert(#actions==1,'retreat Roar stops a pursuer')
    reset(); mode='attack'; roar.castable=true; blink.castable=true; bot.blink=blink
    target=unit(1600,0); target.immune=true; enemies={target}
    cast(module,roar)
    assert(#actions==2 and actions[1].name==blink.name and actions[1].arg.x<1200
        and GetUnitToLocationDistance(target,actions[1].arg)<600 and actions[2].arg==target,'bounded Blink into Roar range, including BKB targets')
    reset(); mode='attack'; roar.castable=true; blink.castable=true; bot.blink=blink; bot.mana=150; blink.cost=50
    target=unit(1000,0); enemies={target}; cast(module,roar)
    assert(#actions==0,'reserve Blink and Roar mana together')
    reset(); mode='attack'; roar.castable=true; blink.castable=true; bot.blink=blink; bkb.castable=true; bot.bkb=bkb; bot.mana=150
    target=unit(1000,0); enemies={target}; cast(module,roar)
    assert(#actions==2 and actions[1].name==blink.name,'skip optional BKB when it would consume Roar mana')
    actions={}; bot.mana=200; cast(module,roar)
    assert(#actions==3 and actions[1].name==bkb.name,'use BKB when full combo is affordable')
    for _,condition in ipairs({'root','rupture','hazard','impassable','outnumbered','mana'}) do
        reset(); mode='attack'; roar.castable=true; blink.castable=true; bot.blink=blink
        target=unit(1000,0); enemies={target}
        if condition=='root' then bot.rooted=true elseif condition=='rupture' then bot.mods.modifier_bloodseeker_rupture=true
        elseif condition=='hazard' then hazard=true elseif condition=='impassable' then passable=false
        elseif condition=='outnumbered' then target.defenders={unit(900,0)} else bot.mana=149 end
        cast(module,roar); assert(#actions==0,'reject unsafe Blink: '..condition)
    end
    reset(); mode='attack'; axes.castable=true; target=unit(1450,0); target.predicted=Vector(1600,0); enemies={target}
    cast(module,axes); assert(#actions==1 and actions[1].arg.x==1500 and target.delay>0.7,'predict Axes travel and clamp edge cast')
    reset(); mode='attack'; axes.castable=true; target=unit(1450,0); target.predicted=Vector(1850,0); enemies={target}
    cast(module,axes); assert(#actions==0,'reject predicted position beyond legal endpoint plus axe radius')
    target.hp=100; local reachable=unit(600,0,100); enemies={target,reachable}; actions={}
    cast(module,axes); assert(#actions==1 and actions[1].arg.x==600,'unreachable kill prediction does not hide another reachable kill')
    reset(); mode='attack'; axes.castable=true; target=unit(250,0); target.disabled=true; enemies={target}
    cast(module,axes); assert(#actions==1 and actions[1].arg.x==250,'Axes stay on disabled close target')
    reset(); mode='farm'; axes.castable=true; neutrals={unit(-350,0),unit(-380,20)}
    bot.aoe={count=3,targetloc=Vector(650,0)}
    cast(module,axes); assert(#actions==1 and actions[1].arg.x<0,'farm Axes use actual camp, not unrelated lane AoE')
    reset(); mode='lane'; axes.castable=true; lanes={unit(300,0,140),unit(-300,0,140)}
    cast(module,axes); assert(#actions==0,'do not assume spread last hits fit one impact area')
    reset(); mode='lane'; axes.castable=true; target=unit(800,0); enemies={target}
    cast(module,axes); assert(#actions==1,'lane harass applies Axes damage amplification')
    reset(); mode='lane'; axes.castable=true; bot.mana=200; target=unit(800,0); enemies={target}
    cast(module,axes); assert(#actions==0,'lane spell preserves combat mana')
    reset(); mode='attack'; boar.castable=true; target=unit(100,0); enemies={target}
    cast(module,boar); assert(#actions==1 and actions[1].name==boar.name,'summon Razorback in melee fight too')
    reset(); mode='attack'; hawk.castable=true; target=unit(475,0); target.disabled=true; enemies={target}
    cast(module,hawk); assert(#actions==1 and actions[1].name==hawk.name,'Raptors persist after existing short disable ends')
    reset(); mode='farm'; hawk.castable=true; neutrals={unit(200,0)}
    cast(module,hawk); assert(#actions==1,'Raptors contribute sustained camp damage')
end
reset(); roar.castable=true; abilities.beastmaster_wild_axes=nil; target=unit(500,0,200); enemies={target}
assert(copy.ConsiderStolenSpell(roar)==true and #actions==1,'stolen Roar works without stolen Axes')
local hawkUnit=unit(0,0); hawkUnit.name='npc_dota_beastmaster_hawk_1'
hero.MinionThink(hawkUnit); assert(minionCalls==0,'autonomous Raptors receive no minion orders')
local boarUnit=unit(0,0); boarUnit.name='npc_dota_beastmaster_boar_1'
hero.MinionThink(boarUnit); assert(minionCalls==1,'Razorbacks retain normal minion control')
print('Beastmaster ability scenarios passed')
