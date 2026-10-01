-- Centaur windup movement, legal AoE anchors, safe initiation and global saves.
local H = dofile('tests/hero_harness.lua')
local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0
UNIT_LIST_ALLIED_HEROES=1; DAMAGE_TYPE_MAGICAL=2; ATTRIBUTE_STRENGTH=0
local V={}
V.__index=V
function Vector(x,y,z) return setmetatable({x=x,y=y or 0,z=z or 0},V) end
function V.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function V.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function V.__mul(a,b) return Vector(a.x*b,a.y*b,a.z*b) end
function V:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function V:Normalized() local n=self:Length2D(); return n>0 and Vector(self.x/n,self.y/n,self.z/n) or Vector(0,0,0) end
local enemies,allies,lanes,neutrals,actions={},{},{},{},{}
local target,mode,attacking,hazard,passable=nil,'',false,false,true
local abilities={}
local function unit(x,hp,name)
    local u={x=x,hp=hp or 1000,maxhp=1000,name=name or 'npc_dota_hero_enemy',mods={},valid=true,speed=0}
    function u:GetLocation() return Vector(self.x,0,0) end
    function u:GetHealth() return self.hp end
    function u:GetMaxHealth() return self.maxhp end
    function u:GetUnitName() return self.name end
    function u:HasModifier(n) return self.mods[n]==true end
    function u:IsInvulnerable() return self.invulnerable==true end
    function u:IsMagicImmune() return self.immune==true end
    function u:IsIllusion() return self.illusion==true end
    function u:IsChanneling() return self.channel==true end
    function u:IsRooted() return self.rooted==true end
    function u:IsStunned() return self.stunned==true end
    function u:IsHexed() return self.hexed==true end
    function u:IsNightmared() return self.nightmare==true end
    function u:CanBeSeen() return self.visible~=false end
    function u:WasRecentlyDamagedByAnyHero() return self.damaged==true end
    function u:GetActualIncomingDamage(dmg,kind) assert(kind==DAMAGE_TYPE_MAGICAL); return dmg*(self.magic or 1) end
    return u
end
local b=unit(0,1000,'npc_dota_hero_centaur')
for k,v in pairs(b) do bot[k]=v end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:GetAttributeValue(attribute) assert(attribute==ATTRIBUTE_STRENGTH); return self.strength end
function bot:GetAbilityByName(name) return abilities[name] end
function bot:GetItemInSlot(slot) return slot==0 and self.blink or nil end
function bot:GetNearbyLaneCreeps() return lanes end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:NumQueuedActions() return self.queued or 0 end
function bot:Action_UseAbility(a) actions[#actions+1]={name=a.name} end
function bot:Action_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
function bot:Action_MoveToLocation(v) actions[#actions+1]={name='move',loc=v} end
function bot:Action_ClearActions() end
function bot:ActionQueue_UseAbilityOnLocation(a,v) actions[#actions+1]={name=a.name,loc=v} end
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={name=a.name} end
function GetUnitToUnitDistance(a,b) return (a:GetLocation()-b:GetLocation()):Length2D() end
function GetUnitToLocationDistance(a,v) return (a:GetLocation()-v):Length2D() end
function IsLocationPassable() return passable end
function GetUnitList() return allies end
local function ability(name,range,cost,values,castpoint)
    local a={name=name,range=range,cost=cost,values=values or {},castpoint=castpoint or 0,castable=false,hidden=false,cooldown=0}
    function a:GetName() return self.name end
    function a:GetCastRange() return self.range end
    function a:GetManaCost() return self.cost end
    function a:GetCastPoint() return self.castpoint end
    function a:IsFullyCastable() return self.castable end
    function a:IsHidden() return self.hidden end
    function a:GetCooldownTimeRemaining() return self.cooldown end
    function a:GetSpecialValueInt(k) return self.values[k] or 0 end
    function a:GetSpecialValueFloat(k) return self.values[k] or 0 end
    abilities[name]=a; return a
end
local stomp=ability('centaur_hoof_stomp',0,130,{radius=325,stomp_damage=280,windup_time=0.5})
local edge=ability('centaur_double_edge',175,0,{edge_damage=300,strength_damage=150,radius=220},0.25)
local stampede=ability('centaur_stampede',0,250)
local horse=ability('centaur_work_horse',0,75)
local mount=ability('centaur_mount',200,75)
local blink=ability('item_blink',0,0,{blink_range=1200})
local function nearby(list,u,r,exclude)
    local out={}; for _,other in pairs(list) do
        if other~=exclude and GetUnitToUnitDistance(u,other)<=r then table.insert(out,other) end
    end; return out
end
J.CanNotUseAbility=function(u) return u.channel or u.stunned or u.hexed or u.nightmare or (u.queued or 0)>0 end
J.CanCastAbility=function(a) return a~=nil and a.castable and not a.hidden end
J.IsItemAvailable=function() return nil end
J.GetProperTarget=function(u) return u==bot and target or u.target end
J.IsValid=function(u) return u~=nil and u.valid and u:CanBeSeen() end
J.IsValidHero=function(u) return J.IsValid(u) and u.name:find('hero',1,true)~=nil end
J.IsValidTarget=J.IsValidHero
J.HasForbiddenModifier=function(u) return u.forbidden==true end
J.CanCastOnNonMagicImmune=function(u)
    return not u.immune and not u.invulnerable and not u.illusion and not J.HasForbiddenModifier(u)
end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.illusion end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.IsInRange=function(a,b,r) return b~=nil and GetUnitToUnitDistance(a,b)<=r end
J.IsDisabled=function(u) return u.disabled==true or u.stunned==true end
J.GetCorrectLoc=function(u,delay) return Vector(u.x+u.speed*delay,0,0) end
J.CannotBeKilled=function(_,u) return u.protected==true or u.mods.modifier_dazzle_shallow_grave==true end
J.WillKillTarget=function(u,damage,kind) return u:GetActualIncomingDamage(damage,kind)>=u.hp end
J.GetNearbyHeroes=function(u,r,enemy) return nearby(enemy and enemies or allies,u,r,u) end
J.GetAlliesNearLoc=function(loc,r)
    local out={}; for _,ally in pairs(allies) do if GetUnitToLocationDistance(ally,loc)<=r then table.insert(out,ally) end end; return out
end
J.GetEnemiesNearLoc=function(loc,r)
    local out={}; for _,enemy in pairs(enemies) do if GetUnitToLocationDistance(enemy,loc)<=r then table.insert(out,enemy) end end; return out
end
J.IsLocationInChrono=function() return hazard=='chrono' end
J.IsLocationInBlackHole=function() return hazard=='blackhole' end
J.IsLocationInArena=function() return hazard=='arena' end
J.GetTeamFountain=function() return Vector(-10000,0,0) end
J.IsCastingUltimateAbility=function(u) return u.castingUlt==true end
J.IsGoingOnSomeone=function(u) return u==bot and mode=='attack' or u~=bot and u.mode=='attack' end
J.IsRetreating=function(u) return u==bot and mode=='retreat' or u~=bot and u.mode=='retreat' end
J.IsInTeamFight=function() return mode=='fight' end
J.IsLaning=function() return mode=='lane' end
J.IsFarming=function() return mode=='farm' end
J.IsPushing=function() return mode=='push' end
J.IsDefending=function() return mode=='defend' end
J.IsDoingRoshan=function() return mode=='roshan' end
J.IsDoingTormentor=function() return mode=='tormentor' end
J.IsRoshan=function(u) return u and u.name=='roshan' end
J.IsTormentor=function(u) return u and u.name=='tormentor' end
J.IsAttacking=function() return attacking end
J.IsChasingTarget=function(u,v) return u.chasing==v end
J.IsCore=function(u) return u.core==true end
J.GetHP=function(u) return u.hp/u.maxhp end
J.GetMP=function() return bot.mana/1000 end
local hero=H.load('npc_dota_hero_centaur','pos_3')
local copy=H.realDofile('bots/FunLib/rubick_hero/centaur.lua')
local function reset()
    enemies,allies,lanes,neutrals,actions={}, {bot}, {}, {}, {}
    target=nil; mode=''; attacking=false; hazard=false; passable=true
    bot.mods={}; bot.hp=1000; bot.maxhp=1000; bot.mana=1000; bot.strength=100; bot.magic=1
    bot.channel=false; bot.rooted=false; bot.stunned=false; bot.hexed=false; bot.nightmare=false
    bot.queued=0; bot.blink=nil; bot.damaged=false; bot.chasing=nil
    abilities.centaur_hoof_stomp=stomp; abilities.centaur_mount=mount
    for _,a in pairs(abilities) do a.castable=false; a.hidden=false; a.cooldown=0 end
    blink.cost=0
end
local function cast(module,spell)
    if module==hero then hero.SkillsComplement() else copy.ConsiderStolenSpell(spell) end
end
local victim,ally
for _,module in ipairs({hero,copy}) do
    reset(); stomp.castable=true; victim=unit(325); victim.channel=true; enemies={victim}
    cast(module,stomp); assert(#actions==1 and actions[1].name==stomp.name,'full325 Stomp channel interrupt')
    reset(); stomp.castable=true; victim=unit(320); victim.speed=100; victim.channel=true; enemies={victim}
    cast(module,stomp); assert(#actions==0,'predict target outside radius after .5sec')
    reset(); stomp.castable=true; victim=unit(320); victim.speed=-100; mode='attack'; target=victim; enemies={victim}
    cast(module,stomp); assert(#actions==1,'windup prediction permits entering/safe target')
    reset(); stomp.castable=true; victim=unit(200); victim.channel=true; victim.immune=true; enemies={victim}
    cast(module,stomp); assert(#actions==0,'Stomp immunity exclusion')
    reset(); stomp.castable=true; mode='attack'; blink.castable=true; bot.blink=blink
    victim=unit(1450); target=victim; enemies={victim}; ally=unit(1200,1000,'npc_dota_hero_ally'); allies={bot,ally}
    cast(module,stomp); assert(#actions==2 and actions[1].name==blink.name and actions[1].loc.x<=1200
        and GetUnitToLocationDistance(victim,actions[1].loc)<=325 and actions[2].name==stomp.name,'bounded reachable Blink Stomp')
    for _,flag in ipairs({'rooted','rupture','mana','reach','solo_two','chrono','blackhole','arena','passable'}) do
        reset(); stomp.castable=true; blink.castable=true; bot.blink=blink; mode='attack'
        victim=unit(900); target=victim; enemies={victim}
        if flag=='rooted' then bot.rooted=true
        elseif flag=='rupture' then bot.mods.modifier_bloodseeker_rupture=true
        elseif flag=='mana' then blink.cost=10; bot.mana=139
        elseif flag=='reach' then victim.x=1476
        elseif flag=='solo_two' then enemies={victim,unit(950)}
        elseif flag=='passable' then passable=false
        else hazard=flag end
        cast(module,stomp); assert(#actions==0,'Blink safety '..flag)
    end
    reset(); stomp.castable=true; mode='retreat'; victim=unit(300); victim.channel=true; enemies={victim}
    cast(module,stomp); stomp.castable=false; bot.mods.modifier_centaur_hoof_stomp_windup=true; actions={}
    assert(module.UsePendingStomp() and #actions==1 and actions[1].loc.x==300,'retreat retains interrupt focus during cooldown windup')
    for _,flag in ipairs({'rooted','channel','queued','rupture','stunned','hexed','nightmare'}) do
        actions={}; bot[flag]=true
        if flag=='queued' then bot.queued=1 elseif flag=='rupture' then bot.mods.modifier_bloodseeker_rupture=true end
        assert(module.UsePendingStomp() and #actions==0,'preserve busy/unsafe Stomp windup '..flag)
        bot[flag]=false; bot.queued=0; bot.mods.modifier_bloodseeker_rupture=nil
    end
    reset(); stomp.castable=true; mode='attack'; target=unit(300); enemies={target}; cast(module,stomp)
    actions={}; stomp.castable=false; bot.mods.modifier_centaur_hoof_stomp_windup=true; target.speed=20
    assert(module.UsePendingStomp() and #actions==1 and actions[1].loc.x==304,'move in observed windup after cooldown')
    reset(); edge.castable=true; victim=unit(170,225); victim.magic=0.5; enemies={victim}
    cast(module,edge); assert(#actions==1 and actions[1].target==victim,'Double Edge strength450 and magical mitigation')
    victim.hp=226; actions={}; cast(module,edge); assert(#actions==0,'strength kill threshold exact')
    reset(); edge.castable=true; mode='attack'; target=unit(170); enemies={target}; bot.hp=700; bot.magic=0.75
    cast(module,edge); assert(#actions==1,'self mitigation allows ordinary combat above30percent floor')
    reset(); edge.castable=true; mode='attack'; target=unit(170); enemies={target}; bot.hp=700
    cast(module,edge); assert(#actions==0,'ordinary Edge preserves health floor')
    reset(); edge.castable=true; victim=unit(170,100); enemies={victim}; bot.hp=5
    cast(module,edge); assert(#actions==1,'nonlethal self damage permits lone lethal finish')
    for _,flag in ipairs({'range','counterspell','ally counterspell','block','immune','protected','forbidden','invisible','invulnerable'}) do
        reset(); edge.castable=true; victim=unit(170,100); enemies={victim}
        if flag=='range' then victim.x=176 elseif flag=='counterspell' then victim.mods.modifier_antimage_counterspell=true
        elseif flag=='ally counterspell' then victim.mods.modifier_antimage_counterspell_ally=true
        elseif flag=='block' then victim.blocked=true elseif flag=='immune' then victim.immune=true
        elseif flag=='forbidden' then victim.forbidden=true elseif flag=='invisible' then victim.visible=false
        elseif flag=='invulnerable' then victim.invulnerable=true else victim.protected=true end
        cast(module,edge); assert(#actions==0,'Edge primary safety '..flag)
    end
    reset(); edge.castable=true; victim=unit(350,100); enemies={victim}; local creep=unit(170,800,'creep'); lanes={creep}
    cast(module,edge); assert(#actions==1 and actions[1].target==creep,'legal creep anchors splash hero kill')
    reset(); edge.castable=true; mode='fight'; local illusion=unit(150,800); illusion.illusion=true
    local illusion2=unit(300,800); illusion2.illusion=true; enemies={illusion,illusion2}
    cast(module,edge); assert(#actions==1 and actions[1].target==illusion,'legal illusion primary clears nearby illusion AoE')
    for _,spread in ipairs({false,true}) do
        reset(); edge.castable=true; mode='lane'; local first=unit(150,200,'creep'); local second=unit(spread and 400 or 300,200,'creep')
        lanes={first,second}; cast(module,edge)
        assert(spread and #actions==0 or not spread and #actions==1 and actions[1].target==first,'clustered rather than spread lane last hits')
    end
    reset(); edge.castable=true; mode='farm'; attacking=true; neutrals={unit(150,900,'neutral'),unit(300,900,'neutral')}; bot.hp=949
    cast(module,edge); assert(#actions==0,'farm Edge protects50percent health floor')
    bot.hp=950; actions={}; cast(module,edge); assert(#actions==1,'farm floor exact boundary')
    for _,boss in ipairs({'roshan','tormentor'}) do
        reset(); edge.castable=true; mode=boss; attacking=true; target=unit(170,5000,boss)
        cast(module,edge); assert(#actions==1 and actions[1].target==target,'valid boss entity '..boss)
    end
    reset(); stampede.castable=true; ally=unit(5000,300,'npc_dota_hero_ally'); ally.damaged=true
    victim=unit(5300); victim.chasing=ally; allies={bot,ally}; enemies={victim}
    cast(module,stampede); assert(#actions==1 and actions[1].name==stampede.name,'global remote ally save')
    for _,flag in ipairs({'rooted','rupture','buffed','channel'}) do
        reset(); stampede.castable=true; ally=unit(5000,300,'npc_dota_hero_ally'); ally.damaged=true
        victim=unit(5300); victim.chasing=ally; allies={bot,ally}; enemies={victim}
        if flag=='rupture' then ally.mods.modifier_bloodseeker_rupture=true elseif flag=='buffed' then ally.mods.modifier_centaur_stampede=true
        else ally[flag]=true end
        cast(module,stampede); assert(#actions==0,'Stampede avoids ineffective/unsafe ally '..flag)
    end
    reset(); stampede.castable=true; ally=unit(5000,900,'npc_dota_hero_ally'); ally.mode='attack'; ally.core=true
    victim=unit(5700); victim.immune=true; ally.target=victim; ally.chasing=victim
    allies={bot,ally,unit(5100,900,'npc_dota_hero_backup1'),unit(5200,900,'npc_dota_hero_backup2')}; enemies={victim}
    cast(module,stampede); assert(#actions==1,'global ally chase works against immune target')
    reset(); horse.castable=true; ally=unit(180,200,'npc_dota_hero_ally'); ally.damaged=true; allies={bot,ally}; mount.hidden=true
    bot.mana=149; cast(module,horse); assert(#actions==0,'reserve combined Work Horse and Mount mana')
    bot.mana=150; actions={}; cast(module,horse); assert(#actions==1 and actions[1].name==horse.name,'Work Horse prepares injured ally rescue')
    horse.castable=false; mount.hidden=false; mount.castable=true; actions={}; cast(module,mount)
    assert(#actions==1 and actions[1].target==ally,'Hitch uses injured ally entity')
    for _,flag in ipairs({'passenger','tempest','low_health'}) do
        reset(); mount.castable=true; ally=unit(180,200,'npc_dota_hero_ally'); ally.damaged=true; allies={bot,ally}
        if flag=='passenger' then ally.mods.modifier_centaur_mounted=true
        elseif flag=='tempest' then ally.mods.modifier_arc_warden_tempest_double=true else bot.hp=299 end
        cast(module,mount); assert(#actions==0,'Hitch rescue guard '..flag)
    end
    reset(); mount.castable=true; ally=unit(201,200,'npc_dota_hero_ally'); ally.damaged=true; allies={bot,ally}
    cast(module,mount); assert(#actions==0,'Hitch does not walk into out-of-range rescue')
    reset(); mount.castable=true; ally=unit(180,200,'npc_dota_hero_ally'); ally.damaged=true; ally.rooted=true; allies={bot,ally}
    cast(module,mount); assert(#actions==1 and actions[1].target==ally,'Hitch can rescue a rooted ally that cannot use Stampede')
    reset(); edge.castable=true; mode='attack'; victim=unit(170); target=victim; enemies={victim}
    bot.mods.modifier_centaur_hoof_stomp_windup=true; bot.rooted=true
    cast(module,edge); assert(#actions==0,'pending rooted Stomp retains its tick before another spell')
    reset(); horse.castable=true; mode='attack'; victim=unit(700); victim.immune=true; target=victim; bot.chasing=victim; enemies={victim}
    cast(module,horse); assert(#actions==1,'Work Horse chases immune target')
    reset(); edge.castable=true; mode='attack'; victim=unit(170); target=victim; enemies={victim}; bot.channel=true
    cast(module,edge); assert(#actions==0,'normal channel remains intact')
end
reset(); stomp.castable=true; abilities.centaur_hoof_stomp=nil; victim=unit(300); victim.channel=true; enemies={victim}
copy.ConsiderStolenSpell(stomp); assert(#actions==1 and actions[1].name==stomp.name,'standalone stolen Stomp needs no linked spell')
reset(); stomp.castable=true; edge.castable=true; stampede.castable=true; mount.castable=true
victim=unit(200); victim.channel=true; enemies={victim}; ally=unit(180,200,'npc_dota_hero_ally'); ally.damaged=true
local pursuer=unit(300); pursuer.chasing=ally; enemies={victim,pursuer}; allies={bot,ally}
hero.SkillsComplement(); assert(#actions==1 and actions[1].name==stomp.name,'direct interrupt precedes global save/Hitch/Double Edge')
print('Centaur ability scenarios passed')
