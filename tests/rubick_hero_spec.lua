local H = dofile('tests/hero_harness.lua')
local J = H.J
local bot = H.bot
local SPL = H.realDofile('bots/FunLib/spell_prob_list.lua')

BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH = 0, 0.8
BOT_MODE_NONE, DAMAGE_TYPE_MAGICAL = 0, 2

local vector = {}
vector.__index = vector
function Vector(x, y, z) return setmetatable({x=x,y=y,z=z or 0}, vector) end
function vector.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function vector.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function vector.__mul(a,b)
    if type(a)=='number' then a,b=b,a end
    return Vector(a.x*b,a.y*b,a.z*b)
end
function vector:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function vector:Normalized()
    local length=self:Length2D()
    return length==0 and Vector(0,0,0) or self*(1/length)
end
local function distance(a,b) return (a-b):Length2D() end
function GetUnitToUnitDistance(a,b) return distance(a:GetLocation(),b:GetLocation()) end
function GetUnitToLocationDistance(a,b) return distance(a:GetLocation(),b) end
function GetLocationToLocationDistance(a,b) return distance(a,b) end

local function ability(name, options)
    local a=options or {}
    a.name=name
    function a:GetName() return self.name end
    function a:IsNull() return self.null==true end
    function a:IsHidden() return self.hidden==true end
    function a:IsPassive() return self.passive==true end
    function a:IsTrained() return self.trained~=false end
    function a:IsActivated() return self.activated~=false end
    function a:IsFullyCastable() return self.castable~=false end
    function a:IsUltimate() return self.ultimate==true end
    function a:IsTalent() return self.name:find('^special_bonus_')~=nil end
    function a:GetCooldownTimeRemaining() return self.cooldown or 0 end
    function a:GetAbilityDamage() return self.damage or 0 end
    function a:GetCastRange() return self.range or 625 end
    function a:GetSpecialValueInt(key) return self.values and self.values[key] or 0 end
    a.GetSpecialValueFloat=a.GetSpecialValueInt
    return a
end

local function unit(name, x, y)
    local u={name=name,location=Vector(x or 0,y or 0),modifiers={}}
    function u:GetUnitName() return self.name end
    function u:GetLocation() return self.location end
    function u:IsNull() return false end
    function u:IsHero() return true end
    function u:CanBeSeen() return self.visible~=false end
    function u:IsAlive() return true end
    function u:IsInvulnerable() return self.invulnerable==true end
    function u:IsAttackImmune() return false end
    function u:IsIllusion() return self.illusion==true end
    function u:IsMagicImmune() return self.immune==true end
    function u:IsChanneling() return false end
    function u:IsUsingAbility() return false end
    function u:IsCastingAbility() return false end
    function u:HasModifier(name) return self.modifiers[name]==true end
    function u:GetLevel() return 20 end
    function u:GetHealth() return 1000 end
    function u:GetMaxHealth() return 1000 end
    function u:GetMana() return 1000 end
    function u:GetNearbyHeroes() return {} end
    function u:WasRecentlyDamagedByAnyHero() return false end
    function u:IsFacingLocation() return true end
    return u
end

local function fixture()
    local f={now=1000,actions={},enemies={},allies={},roll=100,randomCalls=0,
        stolenCasts={},nativeCalls=0,mode='idle'}
    local native={
        rubick_telekinesis=ability('rubick_telekinesis',{range=625,values={max_land_distance=375}}),
        rubick_telekinesis_land=ability('rubick_telekinesis_land',{hidden=true,values={radius=999}}),
        rubick_fade_bolt=ability('rubick_fade_bolt',{values={damage=325,radius=440}}),
        rubick_spell_steal=ability('rubick_spell_steal',{range=1000,castable=false}),
        special_bonus_unique_rubick_8=ability('special_bonus_unique_rubick_8',{values={value=300}}),
    }
    f.native=native
    f.slots={[3]=ability('rubick_empty1',{passive=true}),[4]=ability('rubick_empty2',{passive=true})}
    function DotaTime() return f.now end
    function RandomInt(low,high)
        if low==1 and high==1 then return 1 end -- Single default build selection.
        assert(low==1 and high==100,'Replacement must use one 1..100 probability scale')
        f.randomCalls=f.randomCalls+1
        return f.roll
    end
    function bot:GetAbilityByName(name) return native[name] or ability(name,{castable=false}) end
    function bot:GetAbilityInSlot(slot) return f.slots[slot] end
    function bot:GetLocation() return Vector(0,0,0) end
    function bot:HasScepter() return f.scepter==true end
    function bot:HasShard() return f.shard==true end
    function bot:IsAlive() return true end
    function bot:IsChanneling() return f.channeling==true end
    function bot:IsUsingAbility() return f.using==true end
    function bot:IsCastingAbility() return f.casting==true end
    function bot:IsSilenced() return f.silenced==true end
    function bot:IsStunned() return false end
    function bot:IsHexed() return false end
    function bot:IsNightmared() return false end
    function bot:HasModifier() return false end
    function bot:GetNearbyHeroes(_,enemy) return enemy and f.enemies or f.allies end
    function bot:WasRecentlyDamagedByAnyHero() return false end
    function bot:IsAttacking() return false end
    function bot:Action_UseAbility(a) f.actions[#f.actions+1]={name=a:GetName()} end
    function bot:Action_UseAbilityOnEntity(a,target)
        f.actions[#f.actions+1]={name=a:GetName(),target=target}
    end
    function bot:Action_UseAbilityOnLocation(a,location)
        f.actions[#f.actions+1]={name=a:GetName(),location=location}
    end
    bot.teleTarget=nil
    for _,flag in ipairs({'isChannelLand','isSaveUltLand','isEngagingLand','isRetreatLand','isSaveAllyLand'}) do
        bot[flag]=nil
    end
    J.CanNotUseAbility=function()
        return f.channeling or f.queued or f.casting or f.using or f.silenced or false
    end
    J.HasQueuedAction=function() return f.queued==true end
    J.CanCastAbility=function(a)
        return a~=nil and not a:IsNull() and not a:IsHidden() and not a:IsPassive()
            and a:IsTrained() and a:IsActivated() and a:IsFullyCastable()
    end
    J.GetProperTarget=function() return f.target end
    J.GetProperCastRange=function(_,_,range) return range end
    J.GetHP=function() return f.hp or 1 end
    J.IsRetreating=function() return f.mode=='retreat' end
    J.IsGoingOnSomeone=function() return f.mode=='fight' end
    J.IsValidHero=function(u)
        return u~=nil and u:CanBeSeen() and not u:IsInvulnerable() and not u:IsNull()
    end
    J.IsValidTarget=J.IsValidHero
    J.IsValid=J.IsValidHero
    J.CanCastOnNonMagicImmune=function(u) return not u:IsMagicImmune() end
    J.CanCastOnMagicImmune=function() return true end
    J.CanCastOnTargetAdvanced=function(u) return not u.blocked end
    J.IsSuspiciousIllusion=function(u) return u.illusion==true end
    J.IsMeepoClone=function(u) return u.clone==true end
    J.IsCastingUltimateAbility=function() return false end
    J.IsDisabled=function() return false end
    J.IsTaunted=function() return false end
    J.IsCore=function() return true end
    J.IsDoingRoshan=function() return false end
    J.GetNearbyHeroes=function(_,_,enemy) return enemy and f.enemies or f.allies end
    J.GetAlliesNearLoc=function() return f.allies end
    J.GetEnemiesNearLoc=function() return f.enemies end
    J.IsInRange=function(a,b,range) return GetUnitToUnitDistance(a,b)<=range end
    J.GetEnemyFountain=function() return Vector(10000,0,0) end
    J.GetTeamFountain=function() return Vector(-10000,0,0) end
    J.GetXUnitsTowardsLocation2=function(origin,target,range)
        return origin+(target-origin):Normalized()*range
    end
    J.Site={GetXUnitsTowardsLocation=function(u,target,range)
        return J.GetXUnitsTowardsLocation2(u:GetLocation(),target,range)
    end}
    local R={UsePendingGate=function()
        if not f.pendingGate or f.queued then return false end
        bot:Action_UseAbilityOnEntity(ability('abyssal_underlord_portal_warp'),f.pendingGate)
        return true
    end,ConsiderStolenSpell=function(a)
        if a==nil or a:IsNull() or a:IsHidden() or a:IsPassive() or not a:IsFullyCastable()
            or f.queued then return false end
        if f.stolenCasts[a:GetName()] then bot:Action_UseAbility(a);return true end
        return false
    end}
    local previousDofile=dofile
    dofile=function(path)
        if path=='bots/FunLib/rubick_utility' then return R end
        if path=='bots/FunLib/spell_prob_list' then return SPL end
        return previousDofile(path)
    end
    local X=H.load('npc_dota_hero_rubick','pos_4')
    dofile=previousDofile
    f.X=X
    f.actual={land=X.ConsiderTelekinesisLand,lift=X.ConsiderTelekinesis,steal=X.ConsiderSpellSteal}
    local function noNative() f.nativeCalls=f.nativeCalls+1;return 0,nil end
    X.ConsiderTelekinesis=noNative
    X.ConsiderTelekinesisLand=function()return 0,nil end
    X.ConsiderFadeBolt=noNative
    function f:tick() self.X.SkillsComplement() end
    function f:prepareSteal()
        self.native.rubick_spell_steal.castable=true
        self.enemies={unit('npc_dota_hero_lina',500,0)}
    end
    function f:stealCount()
        local count=0
        for _,a in ipairs(self.actions) do if a.name=='rubick_spell_steal' then count=count+1 end end
        return count
    end
    return f
end

local count=0
local function check(name,run)
    local ok,message=pcall(run)
    assert(ok,name..': '..tostring(message))
    count=count+1
end

check('Stop after first stolen cast',function()
    local f=fixture()
    f.slots[3]=ability('abaddon_death_coil')
    f.slots[4]=ability('abaddon_aphotic_shield')
    f.stolenCasts.abaddon_death_coil=true
    f.stolenCasts.abaddon_aphotic_shield=true
    f:prepareSteal()
    f:tick()
    assert(#f.actions==1 and f.actions[1].name=='abaddon_death_coil','Stolen cast was overwritten')
    assert(f.nativeCalls==0,'Native consideration continued after stolen cast')
end)

for _,gate in ipairs({'channeling','queued','casting','using'}) do
    check('Preserve '..gate,function()
        local f=fixture()
        f[gate]=true;f.hp=0.2;f.mode='retreat'
        f.slots[3]=ability('abaddon_death_coil')
        f.stolenCasts.abaddon_death_coil=true
        f:prepareSteal()
        f:tick()
        assert(#f.actions==0 and f.nativeCalls==0,'Interrupted '..gate)
    end)
end

check('Pending Gate precedes cooldown slots and silence',function()
    local f=fixture()
    f.silenced=true;f.pendingGate={}
    f.slots[3]=ability('abyssal_underlord_dark_portal');f.slots[3].castable=false
    f:tick()
    assert(#f.actions==1 and f.actions[1].name=='abyssal_underlord_portal_warp')
    assert(f.nativeCalls==0,'Gate entry must precede normal native decisions')
end)

check('Missing stolen slots',function()
    local f=fixture()
    f.slots[3],f.slots[4]=nil,nil
    f:tick()
    assert(#f.actions==0,'Missing slots produced an action')
end)

check('Second stolen spell can cast when first declines',function()
    local f=fixture()
    f.slots[3]=ability('abaddon_death_coil')
    f.slots[4]=ability('abaddon_aphotic_shield')
    f.stolenCasts.abaddon_aphotic_shield=true
    f:tick()
    assert(#f.actions==1 and f.actions[1].name=='abaddon_aphotic_shield','First slot swallowed second cast')
end)

for _,slot in ipairs({7,8,19,20,21}) do
    check('Linked stolen spell at slot '..slot,function()
        local f=fixture()
        f.slots[slot]=ability('ancient_apparition_ice_blast_release')
        f.slots[3]=ability('abaddon_death_coil')
        f.stolenCasts.ancient_apparition_ice_blast_release=true
        f.stolenCasts.abaddon_death_coil=true
        f:prepareSteal()
        f:tick()
        assert(#f.actions==1 and f.actions[1].name=='ancient_apparition_ice_blast_release',
            'Linked helper was skipped or overwritten')
    end)
end

check('Silenced linked release only',function()
    local f=fixture()
    f.silenced=true
    f.slots[7]=ability('abaddon_death_coil')
    f.slots[8]=ability('ancient_apparition_ice_blast_release')
    f.stolenCasts.abaddon_death_coil=true
    f.stolenCasts.ancient_apparition_ice_blast_release=true
    f:tick()
    assert(#f.actions==1 and f.actions[1].name=='ancient_apparition_ice_blast_release',
        'Silence exception skipped release or cast ordinary helper')
    assert(f.nativeCalls==0,'Native spell considered while silenced')
end)

check('Land before stolen spells and stealing',function()
    local f=fixture()
    f.native.rubick_telekinesis_land.hidden=false
    f.X.ConsiderTelekinesisLand=function()return 0.8,Vector(100,0,0)end
    f.slots[3]=ability('abaddon_death_coil')
    f.stolenCasts.abaddon_death_coil=true
    f:prepareSteal()
    f:tick()
    assert(#f.actions==1 and f.actions[1].name=='rubick_telekinesis_land','Native Land lost priority')
end)

for _,talent in ipairs({false,true}) do
    check('Land distance independent of damage talent',function()
        local f=fixture()
        f.native.rubick_telekinesis_land.hidden=false
        f.native.special_bonus_unique_rubick_8.trained=talent
        bot.teleTarget=unit('npc_dota_hero_lina',1000,0)
        bot.isRetreatLand=true
        local desire,location=f.actual.land()
        assert(desire>0 and math.abs(location.x-1375)<0.001 and math.abs(location.y)<0.001,
            'Land must use lifted target origin and max_land_distance, not radius/damage talent')
    end)
end

check('Land toward a distant desired point is clamped',function()
    local f=fixture()
    f.native.rubick_telekinesis_land.hidden=false
    bot.teleTarget=unit('npc_dota_hero_lina',1000,0)
    bot.isEngagingLand=true
    local desire,location=f.actual.land()
    assert(desire>0 and math.abs(location.x-625)<0.001,'Engage Land exceeds 375 throw distance')
end)

check('Shard distance comes from engine special',function()
    local f=fixture()
    f.shard=true
    f.native.rubick_telekinesis.values.max_land_distance=600
    f.native.rubick_telekinesis_land.hidden=false
    bot.teleTarget=unit('npc_dota_hero_lina',1000,0)
    bot.isRetreatLand=true
    local desire,location=f.actual.land()
    assert(desire>0 and math.abs(location.x-1600)<0.001,'Shard distance is missing or applied twice')
end)

check('Coincident landing points remain finite',function()
    local f=fixture()
    f.native.rubick_telekinesis_land.hidden=false
    bot.teleTarget=unit('npc_dota_hero_lina',0,0)
    bot.isEngagingLand=true
    local desire,location=f.actual.land()
    assert(desire>0 and location.x==location.x and location.y==location.y,'Coincident Land produced NaN')
end)

for _,case in ipairs({{shard=false,x=500,cast=false},{shard=true,x=626,cast=false},{shard=true,x=625,cast=true}}) do
    check('Shard ally save and exact lift range',function()
        local f=fixture()
        f.shard=case.shard;f.mode='fight'
        local ally=unit('npc_dota_hero_sven',case.x,0)
        ally.modifiers.modifier_enigma_black_hole_pull=true
        f.allies={ally}
        f.X.ConsiderTelekinesis=f.actual.lift
        f:tick()
        assert((#f.actions>0)==case.cast,'Ally lift ignored Shard/range eligibility')
        if case.cast then assert(f.actions[1].name=='rubick_telekinesis' and f.actions[1].target==ally) end
    end)
end

for _,case in ipairs({{name='bane_fiends_grip',roll=1,cast=false},
    {name='batrider_flaming_lasso',roll=10,cast=true},
    {name='batrider_flaming_lasso',roll=11,cast=false},
    {name='antimage_blink',roll=50,cast=true},
    {name='antimage_blink',roll=51,cast=false},
    {name='bounty_hunter_track',roll=100,cast=true}}) do
    check('Named replacement probability '..case.name,function()
        local f=fixture()
        f.slots[3]=ability(case.name,{castable=false,cooldown=20})
        f.roll=case.roll
        f:prepareSteal()
        f:tick()
        assert((f:stealCount()>0)==case.cast,'Wrong named/probability replacement decision')
    end)
end

for _,empty in ipairs({'missing','placeholder','hidden','passive'}) do
    check('Fill '..empty..' slot despite protected Scepter spell',function()
        local f=fixture()
        f.scepter=true
        f.slots[3]=ability('bane_fiends_grip',{ultimate=true})
        if empty=='missing' then
            f.slots[4]=nil
        else
            f.slots[4]=ability(empty=='placeholder' and 'rubick_empty2' or 'helper',
                {hidden=empty=='hidden',passive=empty=='passive' or empty=='placeholder'})
        end
        f:prepareSteal()
        f:tick()
        assert(f:stealCount()==1,'Protected other slot prevented filling '..empty)
    end)
end

check('Both occupied Scepter slots must be replaceable',function()
    local f=fixture()
    f.scepter=true
    f.slots[3]=ability('bane_fiends_grip',{castable=false,cooldown=20})
    f.slots[4]=ability('bounty_hunter_track',{castable=false,cooldown=20})
    f.roll=1
    f:prepareSteal()
    f:tick()
    assert(f:stealCount()==0,'Scepter steal could discard protected zero-weight slot')
end)

check('Both eligible Scepter slots allow replacement',function()
    local f=fixture()
    f.scepter=true
    f.slots[3]=ability('antimage_blink',{castable=false,cooldown=20})
    f.slots[4]=ability('bounty_hunter_track',{castable=false,cooldown=20})
    f.roll=50
    f:prepareSteal()
    f:tick()
    assert(f:stealCount()==1,'Both eligible slots should permit Scepter steal')
end)

check('Ready strong spell is protected until cooldown exceeds threshold',function()
    local f=fixture()
    f.slots[3]=ability('bounty_hunter_track',{damage=280,cooldown=4})
    f:prepareSteal()
    f:tick()
    assert(f:stealCount()==0,'Ready 280-damage spell was discarded')
    f.slots[3].cooldown=5
    f:tick()
    assert(f:stealCount()==1,'Cooldown threshold never releases strong spell')
end)

check('Recent ready ultimate protection expires at 60 seconds',function()
    local f=fixture()
    f:prepareSteal()
    f:tick()
    assert(f:stealCount()==1,'Initial empty steal failed')
    f.slots[3]=ability('alchemist_chemical_rage',{ultimate=true})
    f.now=f.now+59
    f:tick()
    assert(f:stealCount()==1,'Recent ready ultimate was discarded')
    f.now=f.now+1;f.roll=90
    f:tick()
    assert(f:stealCount()==2,'60-second ultimate protection did not expire')
end)

check('Spell Steal stays in cast range and accepts magic-immune enemies',function()
    local f=fixture()
    f:prepareSteal()
    local enemy=f.enemies[1]
    enemy.location=Vector(1001,0,0)
    f:tick()
    assert(f:stealCount()==0,'Out-of-range Spell Steal issued a walking cast')
    enemy.location=Vector(1000,0,0);enemy.immune=true
    f:tick()
    assert(f:stealCount()==1,'Spell Steal incorrectly rejects magic immunity')
end)

for _,name in ipairs({'ancient_apparition_ice_blast_release','alchemist_unstable_concoction_throw'}) do
    for _,slot in ipairs({7,8,19,20,21}) do
        check('Retain pending '..name..' at slot '..slot,function()
            local f=fixture()
            f.slots[slot]=ability(name)
            f:prepareSteal()
            f:tick()
            assert(#f.actions==0,'Pending linked spell was discarded before handler chose to cast')
        end)
    end
    for _,state in ipairs({'hidden','unready'}) do
        check('Inactive '..name..' does not block stealing',function()
            local f=fixture()
            f.slots[7]=ability(name,{hidden=state=='hidden',castable=state~='unready'})
            f:prepareSteal()
            f:tick()
            assert(f:stealCount()==1,'Inactive linked helper prevented replacing/filling spell')
        end)
    end
end

local landFlags={'isChannelLand','isSaveUltLand','isEngagingLand','isRetreatLand','isSaveAllyLand'}
local function staleFlags()
    for _,flag in ipairs(landFlags) do bot[flag]=true end
end
local function onlyFlag(expected)
    for _,flag in ipairs(landFlags) do
        assert(bot[flag]==(flag==expected),'Stale Land intent survived: '..flag)
    end
end

check('Fresh ally save replaces all previous Land intents',function()
    local f=fixture()
    f.mode='fight';f.shard=true
    local ally=unit('npc_dota_hero_sven',500,0)
    ally.modifiers.modifier_enigma_black_hole_pull=true
    f.allies={ally}
    staleFlags()
    f.X.ConsiderTelekinesis=f.actual.lift
    f:tick()
    assert(#f.actions==1 and f.actions[1].name=='rubick_telekinesis' and f.actions[1].target==ally)
    onlyFlag('isSaveUltLand')
end)

check('Fresh engage replaces all previous Land intents',function()
    local f=fixture()
    f.mode='fight'
    f.target=unit('npc_dota_hero_lina',500,0)
    f.enemies={f.target};f.allies={unit('npc_dota_hero_sven',100,0)}
    staleFlags()
    f.X.ConsiderTelekinesis=f.actual.lift
    f:tick()
    assert(#f.actions==1 and f.actions[1].name=='rubick_telekinesis' and f.actions[1].target==f.target)
    onlyFlag('isEngagingLand')
end)

check('Castable lift with no target clears previous Land intents',function()
    local f=fixture()
    staleFlags()
    assert(f.actual.lift()==0,'Targetless lift produced a cast')
    onlyFlag(nil)
end)

for _,gate in ipairs({'hidden','castable'}) do
    check('Unavailable lift preserves pending Land intent',function()
        local f=fixture()
        f.native.rubick_telekinesis[gate]=gate=='hidden'
        staleFlags()
        assert(f.actual.lift()==0,'Unavailable lift produced a cast')
        for _,flag in ipairs(landFlags) do assert(bot[flag]==true,'Unavailable lift cleared '..flag) end
    end)
end

check('Null stolen handle is treated as an empty slot',function()
    local f=fixture()
    f.slots[3]=ability('bane_fiends_grip',{null=true,ultimate=true})
    f:prepareSteal()
    f:tick()
    assert(f:stealCount()==1,'Null handle prevented filling spell slot')
end)

print('Rubick hero behavior checks passed: '..count..' cases.')
