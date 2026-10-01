-- Current attack orbs, invis-preserving buffs/heal, directional Barrage and cloak.
local H=dofile('tests/hero_harness.lua')
local bot,J=H.bot,H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0
UNIT_LIST_ALLIES=1; DAMAGE_TYPE_PHYSICAL=1
local V={}; V.__index=V
function Vector(x,y,z) return setmetatable({x=x,y=y or 0,z=z or 0},V) end
function V.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function V.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function V.__mul(a,b) return Vector(a.x*b,a.y*b,a.z*b) end
function V:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function V:Normalized() local n=self:Length2D(); return n>0 and Vector(self.x/n,self.y/n,self.z/n) or Vector(0,0,0) end
local enemies,creeps,neutrals,summons,actions={},{},{},{},{}
local target,mode,attacking=nil,'',false
local abilities={}
local function unit(x,hp,name,y)
    local u={x=x,y=y or 0,hp=hp or 1000,maxhp=1000,name=name or 'npc_dota_hero_enemy',mods={},valid=true,player=-1,team=3,level=1}
    function u:GetLocation() return Vector(self.x,self.y,0) end
    function u:GetHealth() return self.hp end
    function u:GetMaxHealth() return self.maxhp end
    function u:GetUnitName() return self.name end
    function u:GetPlayerID() return self.player end
    function u:GetTeam() return self.team end
    function u:GetLevel() return self.level end
    function u:IsHero() return self.name:find('hero',1,true)~=nil end
    function u:IsAncientCreep() return self.ancient==true end
    function u:HasModifier(n) return self.mods[n]==true end
    function u:CanBeSeen() return self.visible~=false end
    function u:IsInvulnerable() return self.invulnerable==true end
    function u:GetAttackTarget() return self.attackTarget end
    function u:GetActualIncomingDamage(dmg,kind) assert(kind==DAMAGE_TYPE_PHYSICAL); return dmg*(self.armor or 1) end
    return u
end
local b=unit(0,1000,'npc_dota_hero_clinkz'); for k,v in pairs(b) do bot[k]=v end
bot.team=2;bot.player=0
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:GetAttackRange() return self.attackRange end
function bot:GetAttackDamage() return 100 end
function bot:IsDisarmed() return self.disarmed==true end
function bot:IsChanneling() return self.channel==true end
function bot:IsAlive() return self.alive end
function bot:IsSilenced() return self.silenced==true end
function bot:IsStunned() return self.stunned==true end
function bot:IsHexed() return self.hexed==true end
function bot:IsNightmared() return self.nightmare==true end
function bot:NumQueuedActions() return self.queued or 0 end
function bot:GetCurrentActiveAbility() return self.active end
function bot:GetAbilityByName(n) return abilities[n] end
function bot:WasRecentlyDamagedByAnyHero() return self.damaged==true end
function bot:GetNearbyCreeps() return creeps end
function bot:GetNearbyLaneCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:DistanceFromFountain() return 7000 end
function bot:GetAssignedLane() return 2 end
function bot:Action_UseAbility(a) actions[#actions+1]={name=a.name} end
function bot:Action_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
function bot:Action_UseAbilityOnLocation(a,v) actions[#actions+1]={name=a.name,loc=v} end
function GetTeam() return 2 end
function GetLaneFrontLocation() return Vector(0,0,0) end
function GetUnitList() return summons end
function GetUnitToUnitDistance(a,b) return (a:GetLocation()-b:GetLocation()):Length2D() end
function GetUnitToLocationDistance(a,v) return (a:GetLocation()-v):Length2D() end
local function ability(name,range,cost,values)
    local a={name=name,range=range,cost=cost,values=values or {},castable=false,hidden=false,trained=true,auto=false,charges=2}
    function a:GetName() return self.name end
    function a:GetCastRange() return self.range end
    function a:GetManaCost() return self.cost end
    function a:GetSpecialValueInt(n) return self.values[n] or 0 end
    function a:IsFullyCastable() return self.castable end
    function a:IsHidden() return self.hidden end
    function a:IsTrained() return self.trained end
    function a:GetAutoCastState() return self.auto end
    function a:ToggleAutoCast() self.auto=not self.auto end
    function a:GetCurrentCharges() return self.charges end
    abilities[name]=a; return a
end
local strafe=ability('clinkz_strafe',1200,90,{attack_range_bonus=200,strafe_skeleton_radius=1200})
local pact=ability('clinkz_death_pact',700,50,{health_gain=400,creep_level=6,AbilityCharges=2})
local barrage=ability('clinkz_burning_barrage',0,40,{range=850,projectile_width=200,wave_count=6})
local walk=ability('clinkz_wind_walk',0,130)
local arrows=ability('clinkz_searing_arrows',600,10,{damage_bonus=65})
J.CanNotUseAbility=function(u) return u.channel or not u.alive or u.silenced or u.stunned or u.hexed or u.nightmare or u.queued>0 end
J.IsItemAvailable=function() return bot.lens end
J.GetProperTarget=function() return target end
J.IsValid=function(u) return u~=nil and u.valid end
J.IsValidHero=function(u) return J.IsValid(u) and u:IsHero() end
J.IsValidBuilding=function(u) return J.IsValid(u) and u.name:find('tower',1,true)~=nil end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanBeAttacked=function(u) return J.IsValid(u) and not u.attackImmune and not u.invulnerable end
J.CanCastOnNonMagicImmune=function(u) return not u.immune and not u.invulnerable end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.illusion end
J.IsInRange=function(a,b,r) return b~=nil and GetUnitToUnitDistance(a,b)<=r end
J.CanKillTarget=function(u,dmg,kind) return u:GetActualIncomingDamage(dmg,kind)>=u.hp end
J.GetNearbyHeroes=function(u,r,enemy)
    local out={};if enemy then for _,e in pairs(enemies) do if GetUnitToUnitDistance(u,e)<=r then table.insert(out,e) end end end;return out
end
J.GetCorrectLoc=function(u) return Vector(u.x+(u.predictX or 0),u.y,0) end
J.GetMP=function() return bot.mana/1000 end
J.GetHP=function(u) return u.hp/u.maxhp end
J.IsRealInvisible=function(u) return u.invisible==true end
J.IsAttacking=function() return attacking end
J.IsInTeamFight=function() return mode=='fight' end
for method,value in pairs({IsGoingOnSomeone='attack',IsRetreating='retreat',IsLaning='lane',IsPushing='push',
    IsDefending='defend',IsFarming='farm',IsDoingRoshan='roshan',IsDoingTormentor='tormentor'}) do
    J[method]=function() return mode==value end
end
J.IsRoshan=function(u) return u and u.name=='roshan' end
J.IsTormentor=function(u) return u and u.name=='tormentor' end
J.GetCurrentRoshanLocation=function() return Vector(5000,0,0) end
J.GetTormentorLocation=function() return Vector(5000,0,0) end
J.IsKeyWordUnit=function(word,u) return u.name:find(word,1,true)~=nil end
local hero=H.load('npc_dota_hero_clinkz','pos_1')
local copy=H.realDofile('bots/FunLib/rubick_hero/clinkz.lua')
local function reset()
    enemies,creeps,neutrals,summons,actions={},{},{},{},{}
    target=nil; mode=''; attacking=false; bot.mods={};bot.hp=1000;bot.maxhp=1000;bot.mana=1000
    bot.attackRange=600;bot.disarmed=false;bot.invisible=false;bot.channel=false;bot.alive=true
    bot.silenced=false;bot.stunned=false;bot.hexed=false;bot.nightmare=false;bot.queued=0;bot.active=nil;bot.damaged=false;bot.farmLocation=nil;bot.lens=nil
    for _,a in pairs(abilities) do a.castable=false;a.hidden=false;a.trained=true;a.auto=false;a.charges=2 end
    walk.trained=false; pact.values.AbilityCharges=2
    abilities.clinkz_wind_walk=walk;abilities.clinkz_strafe=strafe;abilities.clinkz_burning_barrage=barrage;abilities.clinkz_searing_arrows=arrows
end
local function cast(module,spell)
    if module==hero then hero.SkillsComplement() else copy.ConsiderStolenSpell(spell) end
end
local victim,creep,skeleton
for _,module in ipairs({hero,copy}) do
    reset(); strafe.castable=true;mode='attack';target=unit(790);target.immune=true;enemies={target}
    cast(module,strafe);assert(#actions==1 and actions[1].name==strafe.name,'Strafe adds200range and follows controlled/immune foes')
    reset(); strafe.castable=true;mode='attack';target=unit(801);enemies={target}
    cast(module,strafe);assert(#actions==0,'Strafe does not waste shortbuff outside extended attackrange')
    reset(); strafe.castable=true;mode='attack';target=unit(500);bot.mods.modifier_clinkz_strafe=true
    cast(module,strafe);assert(#actions==0,'Strafe preserves existingbuff')
    reset(); strafe.castable=true;mode='attack';target=unit(790);bot.mods.modifier_clinkz_wind_walk=true;bot.invisible=true
    cast(module,strafe);assert(#actions==1,'Strafe invisible setup before attack')
    reset(); strafe.castable=true;bot.disarmed=true;skeleton=unit(900,100,'npc_dota_clinkz_skeleton_archer');skeleton.player=0;skeleton.team=2;skeleton.attackTarget=unit(1000);summons={skeleton}
    cast(module,strafe);assert(#actions==1,'Strafe supports owned fighting skeleton while disarmed')
    skeleton.player=1;actions={};cast(module,strafe);assert(#actions==0,'another player skeleton does not drive buff')
    reset(); strafe.castable=true;barrage.castable=true;walk.trained=true;mode='attack';target=unit(1000);enemies={target}
    if module==hero then cast(module,strafe) else copy.ConsiderStolenSpell(strafe) end
    assert(#actions==1 and actions[1].name==strafe.name,'Strafe extends pendingBarrage reach')
    reset(); pact.castable=true;creep=unit(500,300,'ranged_creep');creep.level=5;creeps={creep};mode='lane'
    cast(module,pact);assert(#actions==1 and actions[1].target==creep,'Pact lane creep without irrelevant ally requirement')
    for _,flag in ipairs({'level','ancient','immune','block','range','counterspell','counterspell_ally','ally'}) do
        reset();pact.castable=true;creep=unit(500,300,'siege_creep');creeps={creep}
        if flag=='level' then creep.level=7 elseif flag=='ancient' then creep.ancient=true
        elseif flag=='immune' then creep.immune=true elseif flag=='block' then creep.blocked=true
        elseif flag=='range' then creep.x=701 elseif flag=='ally' then creep.team=2
        else creep.mods['modifier_antimage_'..flag]=true end
        cast(module,pact);assert(#actions==0,'Pact eligibility '..flag)
    end
    reset();pact.castable=true;bot.mods.modifier_clinkz_death_pact=true;creep=unit(500,500,'neutral');neutrals={creep}
    cast(module,pact);assert(#actions==0,'Pact does not refresh healthy existingbuff')
    bot.hp=500;actions={};cast(module,pact);assert(#actions==1,'Pact can heal with existingbuff')
    reset();pact.castable=true;pact.charges=1;creep=unit(500,500,'neutral');neutrals={creep};mode='farm'
    cast(module,pact);assert(#actions==0,'Pact keeps final charge while farming')
    bot.hp=500;actions={};cast(module,pact);assert(#actions==1,'urgenthealing can spend reservedcharge')
    reset();pact.castable=true;pact.charges=1;mode='attack';creep=unit(500,500,'neutral');neutrals={creep}
    cast(module,pact);assert(#actions==1,'reserved Pact charge is available for combat preparation')
    reset();pact.castable=true;walk.trained=true;bot.mana=150;creep=unit(500,500,'neutral');neutrals={creep}
    cast(module,pact);assert(#actions==0,'healthy Pact preparation protects Walk mana')
    reset();pact.castable=true;bot.hp=300;skeleton=unit(500,100,'npc_dota_clinkz_skeleton_archer');skeleton.team=2;skeleton.player=0;summons={skeleton};bot.invisible=true;bot.mods.modifier_clinkz_wind_walk=true
    cast(module,pact);assert(#actions==1 and actions[1].target==skeleton,'Pact heals from own skeleton without breakinginvis')
    skeleton.player=1;actions={};cast(module,pact);assert(#actions==0,'Pact never consumes anotherplayer skeleton')
    reset();pact.castable=true;bot.hp=300;skeleton=unit(500,100,'npc_dota_clinkz_skeleton_archer');skeleton.team=2;skeleton.player=0;summons={skeleton};creep=unit(600,900,'neutral');neutrals={creep}
    cast(module,pact);assert(#actions==1 and actions[1].target==creep,'Pact preserves skeleton when eligibleenemy exists')
    reset();arrows.castable=true;mode='lane';target=unit(600);target.immune=true
    cast(module,arrows);assert(#actions==1 and actions[1].target==target,'manual lane Arrow pierces immunity atactual attackrange')
    target.x=601;bot.lens={GetSpecialValueInt=function() return 225 end};actions={};cast(module,arrows)
    assert(#actions==0,'Lens does not inflate Arrow attackrange')
    for _,flag in ipairs({'counterspell','counterspell_ally','disarmed','attackImmune'}) do
        reset();arrows.castable=true;mode='lane';target=unit(500)
        if flag=='disarmed' then bot.disarmed=true elseif flag=='attackImmune' then target.attackImmune=true
        else target.mods['modifier_antimage_'..flag]=true end
        cast(module,arrows);assert(#actions==0,'Arrow safeguard '..flag)
    end
    reset();arrows.castable=true;mode='lane';creep=unit(500,120,'ranged_creep');creeps={creep}
    cast(module,arrows);assert(#actions==1 and actions[1].target==creep,'Arrow secures kill needing extra65damage')
    creep.armor=0.5;actions={};cast(module,arrows);assert(#actions==0,'Arrow last-hit uses mitigated attack plusbonus')
    reset();arrows.castable=true;mode='attack';target=unit(600);target.immune=true
    cast(module,arrows);assert(#actions==0 and arrows.auto,'sustained combat togglesautocast without resettingattack')
    bot.mana=5;actions={};cast(module,arrows);assert(not arrows.auto and #actions==0,'autocast turns off below abilitymana')
    for _,boss in ipairs({'tower','roshan','tormentor'}) do
        reset();arrows.castable=true;mode=boss=='tower' and 'push' or boss;target=unit(550,5000,boss);attacking=true
        cast(module,arrows);assert(arrows.auto,'Arrows enabled for building/boss '..boss)
    end
    reset();barrage.castable=true;arrows.castable=true;walk.trained=true;mode='farm';attacking=true
    creeps={unit(300,500,'creep'),unit(600,500,'creep'),unit(840,500,'creep')}
    cast(module,barrage);assert(#actions==1 and actions[1].name==barrage.name and arrows.auto,'Barrage directional850 line and Arrow preparation')
    reset();barrage.castable=true;mode='farm';attacking=true
    creeps={unit(400,500,'creep',-300),unit(400,500,'creep',0),unit(400,500,'creep',300)}
    cast(module,barrage);assert(#actions==0,'spread wave cannot satisfy directionalline with merecenter')
    reset();barrage.castable=true;mode='attack';target=unit(1000);target.immune=true;enemies={target};bot.attackRange=800
    cast(module,barrage);assert(#actions==1,'Barrage gets bonusattackrange and pierces immunity')
    bot.attackRange=600;actions={};cast(module,barrage);assert(#actions==0,'Barrage excludes targetbeyond actual length')
    reset();barrage.castable=true;mode='attack';target=unit(600);target.attackImmune=true;enemies={target}
    cast(module,barrage);assert(#actions==0,'Barrage excludes attackimmune focus')
    reset();walk.castable=true;walk.trained=true;mode='retreat';bot.damaged=true;bot.mods.modifier_item_dustofappearance=true
    cast(module,walk);assert(#actions==1 and actions[1].name==walk.name,'Walk escape retains movement utilityunder detection')
    bot.mods.modifier_clinkz_wind_walk=true;actions={};cast(module,walk);assert(#actions==0,'Walk doesnot refreshinvis')
    reset();walk.castable=true;walk.trained=true;mode='attack';target=unit(900);enemies={target}
    cast(module,walk);assert(#actions==1,'Walk approaches gank outside attacksetup range')
    reset();walk.castable=true;walk.trained=true;bot.channel=true;bot.active=barrage
    assert(module.UseBarrageInvisibility() and #actions==1 and actions[1].name==walk.name,'immediate Walk cloaks ongoingBarrage')
    for _,flag in ipairs({'otherchannel','queued','silenced','stunned','hexed','nightmare','dead','hidden','invisible'}) do
        reset();walk.castable=true;bot.channel=true;bot.active=barrage
        if flag=='otherchannel' then bot.active={GetName=function() return 'item_tpscroll' end}
        elseif flag=='queued' then bot.queued=1 elseif flag=='dead' then bot.alive=false
        elseif flag=='hidden' then walk.hidden=true elseif flag=='invisible' then bot.invisible=true else bot[flag]=true end
        assert(not module.UseBarrageInvisibility() and #actions==0,'Barrage cloak guard '..flag)
    end
    reset();barrage.castable=true;bot.channel=true;bot.active={GetName=function() return 'item_tpscroll' end};mode='farm';attacking=true
    creeps={unit(300,500,'creep'),unit(600,500,'creep'),unit(840,500,'creep')};cast(module,barrage)
    assert(#actions==0,'normal channel preserved')
end
reset();walk.castable=true;strafe.castable=true;arrows.castable=true;pact.castable=true;mode='retreat';bot.damaged=true;bot.hp=300;creeps={unit(300,500,'creep')}
hero.SkillsComplement();assert(#actions==1 and actions[1].name==walk.name,'escape before healing/setup/offense')
reset();pact.castable=true;strafe.castable=true;arrows.castable=true;mode='attack';target=unit(500);creeps={unit(300,500,'creep')};bot.hp=300
hero.SkillsComplement();assert(#actions==1 and actions[1].name==pact.name,'Pact sustain before offensive setup')
reset();strafe.castable=true;arrows.castable=true;mode='attack';target=unit(500)
hero.SkillsComplement();assert(#actions==1 and actions[1].name==strafe.name,'Strafe not starved by repeatedzeroCD orbs')
local army=ability('clinkz_burning_army',600,150);army.castable=true;actions={}
assert(copy.ConsiderStolenSpell(army)==false and #actions==0,'unverified vectorArmy remains recognizedskip')
local tar=ability('clinkz_tar_bomb',1000,60);tar.castable=true
assert(copy.ConsiderStolenSpell(tar)==false and #actions==0,'retired Tar Bomb remainsrecognizedskip')
print('Clinkz ability scenarios passed')
