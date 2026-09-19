local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local F = {}

function F.TeleportLocation(bot)
    if J.GetHP(bot) < 0.65 or J.GetMP(bot) < 0.3
        or bot:WasRecentlyDamagedByAnyHero(4)
        or #J.GetEnemiesNearLoc(bot:GetLocation(), 1600) > 0 then return nil end
    local best, bestScore = nil, -math.huge
    for _, id in ipairs({ TOWER_TOP_1, TOWER_MID_1, TOWER_BOT_1,
        TOWER_TOP_2, TOWER_MID_2, TOWER_BOT_2, TOWER_TOP_3, TOWER_MID_3, TOWER_BOT_3 }) do
        local tower = GetTower(GetTeam(), id)
        if tower and tower:IsAlive() and J.GetHP(tower) > 0.3
            and GetUnitToUnitDistance(bot, tower) > 3500 then
            local loc = tower:GetLocation()
            local enemies = #J.GetEnemiesNearLoc(loc, 1400)
            local allies, fighting = 0, 0
            for _, h in ipairs(J.GetAlliesNearLoc(loc, 1400)) do
                if J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion() and J.GetHP(h) > 0.3 then
                    allies = allies + 1
                    if h:WasRecentlyDamagedByAnyHero(3) then fighting = fighting + 1 end
                end
            end
            -- Reinforce an actual fight, not an abandoned tower or a lost 1v5.
            if enemies >= 2 and allies >= 2 and fighting > 0 and allies + 1 >= enemies then
                local ancient = GetAncient(GetTeam()):GetLocation()
                local direction = ancient - loc
                local landing = loc + direction:Normalized() * 450
                if #J.GetEnemiesNearLoc(landing, 700) == 0 then
                    local score = allies - enemies + fighting
                    if score > bestScore then best, bestScore = landing, score end
                end
            end
        end
    end
    return best
end

return F
