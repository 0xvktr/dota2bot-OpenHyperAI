package.path='./?.lua;'..package.path
TEAM_RADIANT=2
UNIT_LIST_ALL=0
function Vector(x,y,z)return {x=x,y=y,z=z}end
local now,bot,other,units
function GetScriptDirectory()return 'bots'end
function DotaTime()return now end
function GetTeam()return 2 end
function GetTeamPlayers()return {1,2}end
function GetTeamMember(i)return i==1 and bot or other end
function GetUnitList()return units end
function GetUnitToLocationDistance(h,v)local p=h:GetLocation();return math.sqrt((p.x-v.x)^2+(p.y-v.y)^2)end
local settings=require('bots/FunLib/objective_settings')
local P=require('bots/FunLib/twin_gate_probe')
local function reset()
    now=20
    settings.TwinGateProbe.Enabled=true
    settings.TwinGateProbe.Method='attack'
    bot={loc=Vector(6425.52832,-7313.782715,256),attacks=0,clears=0,chats={}}
    function bot:ActionImmediate_Chat(text,teamOnly)
        assert(teamOnly==true,'diagnostic must stay in team chat')
        table.insert(self.chats,{text=text,time=now})
    end
    function bot:GetPlayerID()return 1 end
    function bot:IsBot()return true end
    function bot:IsAlive()return true end
    function bot:IsIllusion()return false end
    function bot:GetUnitName()return 'test_hero'end
    function bot:GetLocation()return self.loc end
    function bot:WasRecentlyDamagedByAnyHero()return self.damaged end
    function bot:GetHealth()return 1000 end
    function bot:GetMaxHealth()return 1000 end
    function bot:GetMana()return 500 end
    function bot:IsChanneling()return self.channeling or false end
    function bot:HasModifier()return false end
    function bot:IsUsingAbility()return false end
    function bot:IsCastingAbility()return false end
    function bot:GetAbilityByName()return nil end
    function bot:Action_ClearActions()self.clears=self.clears+1 end
    function bot:Action_AttackUnit(gate)self.attacks=self.attacks+1;self.target=gate end
    function bot:Action_MoveToLocation(loc)self.move=loc end
    other=setmetatable({GetPlayerID=function()return 2 end},{__index=bot})
    units={{IsNull=function()return false end,GetUnitName=function()return 'npc_dota_unit_twin_gate'end,
        GetLocation=function()return Vector(6425.52832,-7313.782715,256)end}}
end
local passed=0
local function test(name,fn)reset();fn();passed=passed+1;print('PASS '..name)end
test('disabled probe does not claim a bot',function()
    settings.TwinGateProbe.Enabled=false;assert(P.Desire(bot)==0);assert(not P.Active(bot));assert(bot.attacks==0)
end)
test('only one team bot is selected',function()
    assert(P.Desire(other)==0);assert(P.Desire(bot)>1)
end)
test('one attack order and no channel interruption',function()
    P.Desire(bot);P.Think(bot);assert(bot.attacks==1)
    now=21;bot.channeling=true;P.Think(bot);now=24;P.Think(bot)
    assert(bot.attacks==1 and bot.clears==1 and P.Active(bot))
    bot.channeling=false;bot.loc=bot.ohaGateProbe.destination;P.Think(bot)
    assert(not P.Active(bot));assert(bot.ohaGateProbe.sawChannel)
end)
test('missing visible gate handle reports without issuing an order',function()
    units={};P.Desire(bot);P.Think(bot);now=24;P.Think(bot)
    assert(bot.attacks==0 and not P.Active(bot))
end)
test('rejected order times out once, without retry spam',function()
    P.Desire(bot);P.Think(bot);now=33;P.Think(bot)
    assert(bot.attacks==1 and not P.Active(bot));assert(P.Desire(bot)==0)
end)
test('channel alone is not treated as arrival',function()
    P.Desire(bot);P.Think(bot);now=21;bot.channeling=true;P.Think(bot)
    now=25;bot.channeling=false;P.Think(bot);assert(P.Active(bot))
end)
test('danger aborts the experiment',function()
    P.Desire(bot);bot.damaged=true;P.Think(bot);assert(not P.Active(bot));assert(bot.attacks==0)
end)
test('optional ability method handles absent ability safely',function()
    settings.TwinGateProbe.Method='ability_entity';P.Desire(bot);P.Think(bot)
    assert(not P.Active(bot));assert(bot.attacks==0)
end)
test('team chat drains final failure after probe ends without a burst',function()
    units={};P.Desire(bot);P.Think(bot)
    assert(#bot.chats==1)
    now=24;P.Think(bot);assert(not P.Active(bot))
    for t=25,40 do now=t;P.Desire(bot) end
    local found=false
    for i,c in ipairs(bot.chats) do
        if string.find(c.text,'order not tested',1,true) then found=true end
        if i>1 then assert(c.time-bot.chats[i-1].time>=2) end
    end
    assert(found,'final diagnostic must reach team chat')
end)
test('entity cast uses the exposed warp handle once and logs its state',function()
    settings.TwinGateProbe.Method='ability_entity'
    local ability={IsFullyCastable=function()return false end,IsHidden=function()return true end,
        GetLevel=function()return 1 end,GetCooldownTimeRemaining=function()return 0 end}
    function bot:GetAbilityByName()return ability end
    function bot:Action_UseAbilityOnEntity(a,target)
        assert(a==ability and target==units[1]);self.casts=(self.casts or 0)+1
    end
    P.Desire(bot);P.Think(bot);now=21;P.Think(bot)
    assert(bot.casts==1 and bot.attacks==0)
    -- Hidden ability castability may be misleading; record it without skipping
    -- the isolated engine experiment solely on that flag.
    for t=22,32 do now=t;P.Desire(bot) end
    local found=false
    for _,c in ipairs(bot.chats)do if string.find(c.text,'warp castable=false',1,true)then found=true end end
    assert(found)
end)
test('remaining cast forms run once each and preserve an active channel',function()
    settings.TwinGateProbe.Method='remaining_forms'
    local ability={IsFullyCastable=function()return true end,IsHidden=function()return true end,
        GetLevel=function()return 1 end,GetCooldownTimeRemaining=function()return 0 end}
    function bot:GetAbilityByName()return ability end
    local calls={}
    function bot:Action_UseAbility(a)assert(a==ability);table.insert(calls,'none')end
    function bot:Action_UseAbilityOnLocation(a,loc)assert(a==ability and loc.x==units[1]:GetLocation().x);table.insert(calls,'location')end
    function bot:Action_UseAbilityOnEntity(a,target)assert(a==ability and target==units[2]);table.insert(calls,'exit')end
    units[2]={IsNull=function()return false end,GetUnitName=function()return 'npc_dota_unit_twin_gate'end,
        GetLocation=function()return Vector(-6457.690918,7599.036621,256)end}
    P.Desire(bot);P.Think(bot);assert(calls[1]=='none')
    now=34;bot.channeling=true;P.Think(bot);assert(#calls==1 and bot.clears==1)
    now=35;bot.channeling=false;P.Think(bot);assert(#calls==1)
    now=36;P.Think(bot);assert(calls[2]=='location')
    now=49;P.Think(bot);now=50;P.Think(bot);assert(calls[3]=='exit')
    now=63;P.Think(bot);assert(not P.Active(bot) and #calls==3)
end)
print(passed..' gate probe scenarios passed')
