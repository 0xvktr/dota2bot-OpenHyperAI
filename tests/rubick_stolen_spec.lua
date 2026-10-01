-- Real dispatcher/fallback regression scenarios; engine handles and vectors are both Lua tables here.
package.path = './?.lua;'..package.path
BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH, BOT_MODE_NONE = 0, 1, 0
bit = bit or {band=function(a,b)
    local value, place = 0, 1
    while a > 0 and b > 0 do
        if a % 2 == 1 and b % 2 == 1 then value=value+place end
        a,b,place=math.floor(a/2),math.floor(b/2),place*2
    end
    return value
end}
local bot, actions, target, allies, enemies = {}, {}, nil, {}, {}
local blocked, channeling, casting, using, combat = false, false, false, false, true
local silenced, alive, stunned, hexed, nightmared, queued = false, true, false, false, false, false
local specialized, handlerCalls = nil, 0
local function action(shape, ability, value) actions[#actions+1]={shape=shape,ability=ability,target=value} end
function GetScriptDirectory() return 'bots' end
function GetBot() return bot end
function bot:IsSilenced() return silenced end
function bot:IsAlive() return alive end
function bot:IsInvulnerable() return false end
function bot:IsStunned() return stunned end
function bot:IsHexed() return hexed end
function bot:IsNightmared() return nightmared end
function bot:IsChanneling() return channeling end
function bot:IsCastingAbility() return casting end
function bot:IsUsingAbility() return using end
function bot:GetTeam() return 2 end
function bot:GetLocation() return {x=0,y=0,z=0} end
function bot:WasRecentlyDamagedByAnyHero() return false end
function bot:HasModifier() return false end
function bot:Action_UseAbilityOnEntity(a,t) action('unit',a,t) end
function bot:Action_UseAbilityOnLocation(a,t) action('point',a,t) end
function bot:Action_UseAbility(a) action('none',a) end
function GetUnitToLocationDistance(_, location) return math.abs(location.x) end
local aoeResult, usedRadius
function bot:FindAoELocation(_,_,_,_,radius)
    usedRadius=radius
    return aoeResult
end
local function hero(team, x, hp)
    local unit={team=team,x=x,hp=hp or 100,max=100,immune=false,invulnerable=false}
    function unit:GetTeam() return self.team end
    function unit:GetLocation() return {x=self.x,y=0,z=0} end
    function unit:GetHealth() return self.hp end
    function unit:GetMaxHealth() return self.max end
    function unit:IsInvulnerable() return self.invulnerable end
    function unit:IsChanneling() return false end
    function unit:HasModifier() return false end
    return unit
end
local J={
    CanNotUseAbility=function()return blocked or silenced or not alive or stunned or hexed or nightmared or queued end,
    HasQueuedAction=function()return queued end,
    GetProperTarget=function()return target end,
    IsValidHero=function(u)return u~=nil end,
    IsSuspiciousIllusion=function()return false end,
    CanCastOnNonMagicImmune=function(u)return not u.immune end,
    CanCastOnTargetAdvanced=function()return true end,
    IsGoingOnSomeone=function()return combat end,
    IsInTeamFight=function()return false end,
    IsRetreating=function()return false end,
    IsAllowedToSpam=function()return true end,
    IsInRange=function(_,u,r)return math.abs(u.x)<=r end,
    GetNearbyHeroes=function(_,_,enemy)return enemy and enemies or allies end,
}
package.loaded['bots/FunLib/jmz_func']=J
for _,name in ipairs({'abaddon','abyssal_underlord','alchemist','ancient_apparition','antimage','arc_warden',
    'axe','bane','batrider','beastmaster','bloodseeker','bounty_hunter','brewmaster','bristleback',
    'broodmother','centaur','chaos_knight','chen','clinkz','crystal_maiden','rattletrap'}) do
    package.loaded['bots/FunLib/rubick_hero/'..name]={ConsiderStolenSpell=function(ability)
        handlerCalls=handlerCalls+1
        if specialized == true then action('specialized',ability) end
        return specialized
    end}
end
local R=dofile('bots/FunLib/rubick_utility.lua')
local function ability(name, behavior, team, targetType)
    local a={name=name,behavior=behavior,team=team or 2,targetType=targetType or 1,
        range=600,radius=0,ready=true,hidden=false,passive=false,null=false,specials={}}
    function a:IsNull()return self.null end
    function a:IsHidden()return self.hidden end
    function a:IsPassive()return self.passive end
    function a:IsFullyCastable()return self.ready end
    function a:GetName()return self.name end
    function a:GetBehavior()return self.behavior end
    function a:GetTargetType()return self.targetType end
    function a:GetTargetTeam()return self.team end
    function a:GetCastRange()return self.range end
    function a:GetAOERadius()return self.radius end
    function a:GetManaCost()return 100 end
    function a:GetCastPoint()return 0.2 end
    function a:GetSpecialValueInt(key)return self.specials[key] or 0 end
    return a
end
local function reset()
    actions={};handlerCalls=0;specialized=nil
    silenced,alive,stunned,hexed,nightmared,queued=false,true,false,false,false,false
    blocked,channeling,casting,using,combat=false,false,false,false,true
    target=hero(3,500);allies={};enemies={target}
    usedRadius=nil;aoeResult={count=2,targetloc={x=550,y=0,z=0}}
end
local function declined(a,message)
    assert(R.ConsiderStolenSpell(a)==false and #actions==0,message)
end
reset()
for _,state in ipairs({'null','hidden','passive'}) do
    local a=ability('lich_frost_nova',8);a[state]=true;declined(a,'reject '..state)
end
local a=ability('lich_frost_nova',8);a.ready=false;declined(a,'unready before handlers')
declined(ability('rubick_hidden4',8),'linked placeholder');declined(nil,'nil stolen slot');declined(ability('rubick_empty1',8),'empty slot')
assert(handlerCalls==0,'invalid handles must never reach specialized code')
for _,state in ipairs({'channeling','casting','using','blocked'}) do
    reset()
    if state=='channeling' then channeling=true elseif state=='casting' then casting=true
    elseif state=='using' then using=true else blocked=true end
    declined(ability('lich_frost_nova',8),'do not interrupt '..state)
    assert(handlerCalls==0)
end
reset();specialized=true
assert(R.ConsiderStolenSpell(ability('lich_frost_nova',8)) and #actions==1 and handlerCalls==1,
    'stop immediately after specialized cast')
reset();specialized=false
declined(ability('lich_frost_nova',8),'specialized refusal must suppress fallback')
assert(handlerCalls==1)
reset();a=ability('lich_frost_nova',8+32)
assert(R.ConsiderStolenSpell(a) and #actions==1 and actions[1].shape=='unit' and actions[1].target==target,
    'unit-target AoE must use the unit, never its location')
reset();a=ability('lina_light_strike_array',16+32)
assert(R.ConsiderStolenSpell(a) and actions[1].shape=='point' and actions[1].target.x==500,
    'table-valued vector must use point action')
reset();a=ability('lina_light_strike_array',32)
declined(a,'AoE flag alone does not imply a cast shape')
reset();a=ability('lich_frost_nova',8);target.x=601
declined(a,'reported cast range must not receive arbitrary padding')
reset();a=ability('lich_frost_nova',8);a.range=800;target.x=750
assert(R.ConsiderStolenSpell(a),'dynamic range reported by engine is preserved')
reset();a=ability('lina_light_strike_array',16);target.x=601
declined(a,'point location outside actual range')
reset();a=ability('lich_frost_nova',8,1)
declined(a,'enemy intent does not override friendly target team')
reset();a=ability('lich_frost_nova',8,2,2)
declined(a,'hero target rejected by basic-only target mask')
reset();a=ability('lich_frost_nova',8);target.team=2
declined(a,'never point an offensive unit spell at an ally')
reset();target.immune=true;declined(ability('lich_frost_nova',8),'immune enemy')
reset();target.invulnerable=true;declined(ability('lich_frost_nova',8),'invulnerable enemy')
reset();a=ability('queenofpain_scream_of_pain',4);a.range=2000;a.radius=475;target.x=476
declined(a,'no-target radius is distinct from cast range')
target.x=450
assert(R.ConsiderStolenSpell(a) and actions[1].shape=='none','no-target damage reaches an enemy in its radius')
reset();a=ability('queenofpain_scream_of_pain',4);a.specials.area_of_effect=475;target.x=450
assert(R.ConsiderStolenSpell(a) and actions[1].shape=='none','reviewed radius special used when API AoE radius is zero')
reset();combat=false;target=nil
local healthy=hero(2,200,90);local injured=hero(2,400,40);local far=hero(2,700,10)
allies={healthy,injured,far};a=ability('omniknight_purification',8,1)
assert(R.ConsiderStolenSpell(a) and actions[1].target==injured,'heal injured in-range ally; reject distant weaker ally')
reset();a=ability('omniknight_purification',16,1);allies={hero(2,300,20)}
declined(a,'friendly heal does not guess a changed point behavior')
reset();a=ability('omniknight_purification',8,2);allies={hero(2,300,20)}
declined(a,'friendly intent respects enemy-only metadata')
reset();a=ability('ogre_magi_bloodlust',8+4096,1);allies={hero(2,300,100)}
assert(R.ConsiderStolenSpell(a) and actions[1].target==allies[1],'combat buff does not require injured ally')
reset();a=ability('sven_warcry',4,1)
assert(R.ConsiderStolenSpell(a) and actions[1].shape=='none','reviewed self buff uses no-target action')
reset();combat=false;declined(ability('sven_warcry',4,1),'self buff waits for combat')
for _,flag in ipairs({512,4096,1073741824}) do
    reset();declined(ability('lina_light_strike_array',16+flag),'unsafe toggle/autocast/vector fallback')
end
reset();declined(ability('faceless_void_chronosphere',16+32),'unreviewed complex ultimate')
reset();a=ability('enigma_black_hole',16+32+128);a.radius=420
assert(R.ConsiderStolenSpell(a) and actions[1].shape=='point' and usedRadius==420,
    'reviewed channel uses actual effect radius and AoE location')
reset();a=ability('enigma_black_hole',16+128);a.radius=420;aoeResult.count=1
declined(a,'large teamfight channel needs multiple enemies')
reset();a=ability('enigma_black_hole',16+128);a.radius=420;aoeResult.targetloc.x=601
declined(a,'AoE search cannot override maximum cast range')
reset();declined(ability('lina_light_strike_array',16+128),'unreviewed channel behavior')
reset();a=ability('witch_doctor_death_ward',16+128)
assert(R.ConsiderStolenSpell(a) and actions[1].shape=='point','reviewed Death Ward channel remains available')
reset();silenced=true;specialized=true
assert(R.ConsiderStolenSpell(ability('ancient_apparition_ice_blast_release',4)) and #actions==1,
    'reviewed AA release ignores silence')
reset();silenced=true;specialized=true
declined(ability('alchemist_unstable_concoction_throw',8),'silence exception does not extend to other linked spells')
for _,state in ipairs({'dead','stunned','hexed','nightmared','queued','channeling','casting','using'}) do
    reset();silenced=true;specialized=true
    if state=='dead' then alive=false elseif state=='stunned' then stunned=true
    elseif state=='hexed' then hexed=true elseif state=='nightmared' then nightmared=true
    elseif state=='queued' then queued=true elseif state=='channeling' then channeling=true
    elseif state=='casting' then casting=true else using=true end
    declined(ability('ancient_apparition_ice_blast_release',4),'AA silence exemption respects '..state)
end
print('Rubick stolen dispatcher, cast shapes, target masks, radii, support intent and channel safety passed')
