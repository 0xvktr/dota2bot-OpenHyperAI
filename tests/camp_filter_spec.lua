-- Load the complete generated site module with only its engine imports stubbed.
function GetScriptDirectory() return 'bots' end
function GetTeam() return 2 end
function Vector(x, y, z) return {x = x, y = y, z = z} end
function GetUnitList() return {} end
package.loaded['bots/ts_libs/dota/index'] = dofile('bots/ts_libs/dota/enums.lua')
package.loaded['bots/FunLib/utils'] = {
    IsValidCreep = function(u) return u and not u:IsNull() and u:IsAlive() end,
    HasItem = function() return false end,
}
local Site = dofile('bots/FunLib/aba_site.lua')
local count = 0
local camps = {}
for _, team in ipairs({2, 3}) do
    for _, kind in ipairs({'small', 'medium', 'large', 'ancient'}) do
        camps[#camps + 1] = {idx = #camps + 1, team = team, type = kind, location = {distance = 100}}
    end
end
function GetNeutralSpawners() return camps end
local members = {}
function GetTeamPlayers() return #members > 0 and {1} or {} end
function GetTeamMember(id) return members[id] end
function GetUnitToLocationDistance(_, loc) return loc.distance end
local function bot(level, damage)
    return {GetLevel = function() return level end, GetAttackDamage = function() return damage end}
end
local function check(level, damage, allowed)
    local farmer = bot(level, damage)
    local available, size = Site.RefreshCamp(farmer)
    assert(size == 8 and #available == 8, 'refresh must retain camps other heroes can farm')
    local seen = {}
    for _, entry in ipairs(available) do
        local camp = entry.cattr
        local key = camp.team .. ':' .. camp.type
        assert(entry.idx == camp.idx, 'camp wrapper must preserve spawn identity')
        seen[key] = true
        assert(Site.CanFarmCamp(farmer, camp) == (allowed[key] == true), 'eligibility mismatch: ' .. key)
        -- Even the only/nearest camp must be refused when ineligible. This
        -- exercises the same wrapped entries as the farm mode's registry.
        assert((Site.GetClosestNeutralSpwan(farmer, {entry}) ~= nil) == (allowed[key] == true),
            'selection mismatch at level ' .. level .. ', damage ' .. damage .. ': ' .. key)
    end
    assert(seen['2:ancient'] and seen['3:large'])
    count = count + 1
end
local early = {['2:small'] = true, ['2:medium'] = true}
local regular = {['2:small'] = true, ['2:medium'] = true, ['2:large'] = true}
local own = {['2:small'] = true, ['2:medium'] = true, ['2:large'] = true, ['2:ancient'] = true}
local all = {}
for _, c in ipairs(camps) do all[c.team .. ':' .. c.type] = true end
check(1, 120, early)
check(7, 120, early)
check(8, 80, early)
check(8, 81, regular)
check(10, 120, regular)
check(11, 120, regular)
check(12, 120, own)
check(14, 120, own)
check(15, 120, all)
check(25, 80, early)
check(25, 81, all)

-- A low-level refresh cannot hide camps from a stronger farmer using the same list.
local shared = Site.RefreshCamp(bot(3, 60))
local ancient = {idx = 20, cattr = {team = 2, type = 'ancient', location = {distance = 20}}}
shared[#shared + 1] = ancient
assert(Site.GetClosestNeutralSpwan(bot(12, 120), shared) == ancient)
assert(Site.GetClosestNeutralSpwan(bot(3, 60), shared) ~= ancient)
assert(#shared == 9, 'selection must not mutate team availability')
count = count + 1

-- Enemy distance weighting reads cattr, not the wrapper's nonexistent team field.
local allied = {idx = 21, cattr = {team = 2, type = 'large', location = {distance = 100}}}
local enemy = {idx = 22, cattr = {team = 3, type = 'large', location = {distance = 80}}}
assert(Site.GetClosestNeutralSpwan(bot(15, 120), {enemy, allied}) == allied)
enemy.cattr.location.distance = 60
assert(Site.GetClosestNeutralSpwan(bot(15, 120), {enemy, allied}) == enemy)
count = count + 1
assert(Site.GetClosestNeutralSpwan(bot(5, 60), {}) == nil)
assert(Site.GetClosestNeutralSpwan(bot(5, 60), {ancient, enemy}) == nil)
count = count + 1

-- Existing farm-ownership checks still apply to eligible camps.
members[1] = {IsAlive = function() return true end,
    GetActiveMode = function() return package.loaded['bots/ts_libs/dota/index'].BotMode.Farm end}
function GetUnitToLocationDistance(unit, loc) return unit == members[1] and 1 or loc.distance end
assert(Site.GetClosestNeutralSpwan(bot(15, 120), {allied}) == nil)
count = count + 1

-- Camp sharing uses all allied heroes, including humans with no farming mode.
local allies = {}
function GetUnitList() return allies end
function GetUnitToLocationDistance(u, loc) return math.abs(u.x-loc.x) end
local function farmer(x, id, human)
    return {
        x=x, id=id, human=human, alive=true, mode=0,
        GetLevel=function() return 15 end, GetAttackDamage=function() return 120 end,
        IsNull=function() return false end, IsAlive=function(u) return u.alive end,
        CanBeSeen=function() return true end, IsIllusion=function(u) return u.illusion==true end,
        IsBot=function(u) return not u.human end, GetPlayerID=function(u) return u.id end,
        GetActiveMode=function(u) return u.mode end,
        GetAttackTarget=function(u) return u.attack end, GetTarget=function(u) return u.target end,
        GetUnitName=function() return 'npc_dota_hero_axe' end,
    }
end
local f = farmer(1500, 2)
function GetBot() return f end
members={}
local camp1={idx=31,cattr={team=2,type='large',location={x=0}}}
local camp2={idx=32,cattr={team=2,type='large',location={x=3000}}}
local human=farmer(650,0,true);allies={human,f}
assert(Site.IsCampOccupied(f,camp1.cattr.location),'human farther than 700 from bot still owns nearby camp')
assert(Site.GetClosestNeutralSpwan(f,{camp1,camp2})==camp2,'skip human camp and choose available one')
assert(#({camp1,camp2})==2,'camp selection retains occupied camp')
human.x=701;assert(not Site.IsCampOccupied(f,camp1.cattr.location),'human outside camp radius does not reserve it')
human.x=0;human.alive=false;assert(not Site.IsCampOccupied(f,camp1.cattr.location),'dead ally does not reserve')
human.alive=true;human.illusion=true;assert(not Site.IsCampOccupied(f,camp1.cattr.location),'illusion does not reserve')
count=count+1

local function creep(x,team,hp)
    return {x=x,GetLocation=function(u) return {x=u.x} end,IsNull=function() return false end,
        IsAlive=function() return true end,GetTeam=function() return team or 4 end,
        HasModifier=function() return false end,GetHealth=function() return hp or 100 end}
end
local neutral=creep(0);local other=farmer(300,1);allies={f,other}
assert(not Site.IsCampOccupied(f,camp1.cattr.location),'passing bot does not reserve camp')
other.attack=neutral
assert(Site.IsCampOccupied(f,camp1.cattr.location),'attacking bot protects entire camp without a farm mode')
other.attack=nil;other.mode=package.loaded['bots/ts_libs/dota/index'].BotMode.Farm
assert(Site.IsCampOccupied(f,camp1.cattr.location),'farm mode protects attack-interval gaps')
f.attack=neutral
assert(not Site.IsCampOccupied(f,camp1.cattr.location),'arriving nonattacking bot cannot displace existing farmer')
other.attack=neutral
assert(Site.IsCampOccupied(f,camp1.cattr.location),'simultaneous farming elects lower player id')
assert(not Site.IsCampOccupied(other,camp1.cattr.location),'two bots cannot yield to each other forever')
count=count+1

allies={human,f};human.illusion=false;human.x=0;f.attack=nil;f.x=100
local open=creep(3000,4,200);local lane=creep(3000,3,1)
assert(Site.FindFarmNeutralTarget({neutral,open,lane})==open,'selector skips occupied neutral and lane creep')
assert(Site.FindFarmNeutralTarget({neutral})==nil,'first-creep fallback cannot return occupied neutral')
assert(Site.IsNeutralBeingFarmed(f,neutral),'neutral ownership checked at actual creep location')
assert(not Site.IsNeutralBeingFarmed(f,lane),'lane creep is not a neutral camp')
human.x=2000;assert(Site.FindFarmNeutralTarget({neutral})==neutral,'camp is immediately reusable after human leaves')
count=count+1

-- Execute the actual farm Think: the original <=400 distance loophole must
-- yield immediately, clear its stale target and retain team camp availability.
local farmThink=dofile('.test-tools/camp-farm-think.lua')
function DotaTime() return 100 end
function GameTime() return 100 end
local registry={camp1,camp2};local move,clears,attacks=nil,0,0
f.x=100;f._farm_repick_at=1000;human.x=0
function f:GetAttackRange() return 150 end
function f:GetAbilityByName() return nil end
function f:HasModifier() return false end
function f:GetNearbyLaneCreeps() return {} end
function f:GetNearbyNeutralCreeps() return {neutral} end
function f:SetTarget(t) self.target=t end
function f:Action_MoveToLocation(loc) move=loc end
function f:Action_ClearActions() clears=clears+1 end
function f:Action_AttackUnit() attacks=attacks+1 end
local J={Site=Site,Role={availableCampTable=registry},CanNotUseAction=function()return false end,
    Utils={IsBotThinkingMeaningfulAction=function()return false end},CanCastAbility=function()return false end,
    IsValid=function(u)return u~=nil end}
f.target=neutral
assert(farmThink(f,J,camp1,registry,{})==camp2 and move==camp2.cattr.location and f.target==nil and attacks==0,
    'bot already inside human camp reroutes and clears stale target')
assert(#registry==2 and registry[1]==camp1,'yield must not mark occupied camp cleared')
J.Role.availableCampTable={camp1};move=nil;f.target=neutral
assert(farmThink(f,J,camp1,J.Role.availableCampTable,{})==nil and clears==1 and f.target==nil and attacks==0,
    'no free camp stops attack rather than falling through to first neutral')
count=count+1
print(count .. ' camp filter scenarios passed')
