local makeThink = dofile('.test-tools/hero-cast-hooks.lua')
function DotaTime() return 10 end
local function fixture()
    local f = {calls=0, skills=0, highFives=0, invulnerable=true}
    local bot = {frameProcessTime=0.1}
    function bot:IsInvulnerable() return f.invulnerable end
    function bot:IsHero() return true end
    function bot:IsAlive() return true end
    function bot:IsIllusion() return false end
    local build = {SkillsComplement=function() f.skills=f.skills+1 end}
    f.build=build
    f.think=makeThink(bot,build,{Active=function() return f.gate end},
        function() return f.refresh end, {IsNoAbilityIllution=function() return false end},
        {AbilityThink=function() return false end},
        {Think=function() f.highFives=f.highFives+1 end})
    return f
end
for _,name in ipairs({'UseChainsDuringSleight','UseConsume','UseHealingWardDuringSlash','ConsiderEggSunRay','ConsiderPhaseJaunt','ConsiderSnowballContinuation'}) do
    local f=fixture()
    f.build[name]=function() f.calls=f.calls+1;return true end
    f.think()
    assert(f.calls==1 and f.skills==0 and f.highFives==0,'Observed continuation was blocked or followed by another decision')
    f=fixture()
    f.build[name]=function() f.calls=f.calls+1;return false end
    f.think()
    assert(f.calls==1 and f.skills==0,'Inactive hook weakened general invulnerability guard')
    f.invulnerable=false;f.think()
    assert(f.skills==1 and f.highFives==1,'Inactive hook blocked normal ability decisions or High Five upkeep')
    for _,gate in ipairs({'gate','refresh'}) do
        f=fixture();f[gate]=true
        f.build[name]=function() f.calls=f.calls+1;return true end
        f.think()
        assert(f.calls==0 and f.skills==0,'Continuation bypassed framework ownership gate')
    end
end
local f=fixture();f.think();assert(f.skills==0)
f.invulnerable=false;f.think();assert(f.skills==1)
print('Hero cast hook scenarios passed')
