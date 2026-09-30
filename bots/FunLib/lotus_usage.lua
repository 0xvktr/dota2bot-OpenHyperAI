local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local L = {}
local restore = { item_famango = 125, item_great_famango = 400, item_greater_famango = 900 }
local protected = { item_aegis = true, item_rapier = true, item_armlet = true,
    item_black_king_bar = true, item_bloodstone = true, item_gem = true,
    item_cheese = true, item_refresher_shard = true, item_power_treads = true }

local function resourceRatio(h)
    local hp = h:GetHealth() / math.max(1, h:GetMaxHealth())
    local maxMana = h:GetMaxMana()
    local mp = maxMana > 0 and h:GetMana() / maxMana or 1
    return math.min(hp, mp)
end

-- A support keeps its lotus for the cores unless it is itself nearly out of
-- both resources. Heroes without a mana pool only need the health condition.
local function supportCritical(h)
    local maxMana = h:GetMaxMana()
    return h:GetHealth() / math.max(1, h:GetMaxHealth()) < 0.3
        and (maxMana <= 0 or h:GetMana() / maxMana < 0.2)
end

function L.Target(bot, item)
    if not restore[item:GetName()] or bot:DistanceFromFountain() < 1200 then return nil end
    if not J.IsCore(bot) and supportCritical(bot) then return bot end
    local best, lowest = nil, 0.5
    local candidates = { bot }
    for _, h in ipairs(J.GetAlliesNearLoc(bot:GetLocation(), item:GetCastRange())) do
        if h ~= bot then table.insert(candidates, h) end
    end
    for _, h in ipairs(candidates) do
        if J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion() and J.IsCore(h) then
            local ratio = resourceRatio(h)
            if ratio < lowest then best, lowest = h, ratio end
        end
    end
    -- Cores below half health or mana (the holder included, if it is a core)
    -- get the lotus; otherwise save it. All tiers use the same thresholds.
    return best
end

function L.Prepare(bot)
    if J.CanNotUseAction(bot) then return end
    -- Swapping starts the backpack cooldown and can remove defensive stats.
    -- Prepare away from combat; once active, the lotus can be used in combat.
    if bot:WasRecentlyDamagedByAnyHero(4)
        or bot:WasRecentlyDamagedByTower(4) or bot:WasRecentlyDamagedByCreep(4)
        or #J.GetEnemiesNearLoc(bot:GetLocation(), 1200) > 0 then return end
    local swap = bot.ohaLotusSwap
    if swap then
        local item = bot:GetItemInSlot(swap.main)
        if not item or not restore[item:GetName()] or DotaTime() > swap.time + 20 then
            if bot:GetItemInSlot(swap.backpack) == swap.displaced then
                bot:ActionImmediate_SwapItems(swap.main, swap.backpack)
            end
            bot.ohaLotusSwap = nil
            bot.ohaLotusSwapAfter = DotaTime() + 10
        end
        return
    end
    if DotaTime() < (bot.ohaLotusSwapAfter or 0) then return end
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item and restore[item:GetName()] then return end
    end
    for slot = 6, 8 do
        local item = bot:GetItemInSlot(slot)
        if item and L.Target(bot, item) then
            local main, cheapest = nil, math.huge
            for i = 0, 5 do
                local other = bot:GetItemInSlot(i)
                if not other then main = i; break end
                local name = other:GetName()
                if not protected[name] and not string.find(name, 'boots')
                    and GetItemCost(name) < cheapest then
                    main, cheapest = i, GetItemCost(name)
                end
            end
            if main then
                bot.ohaLotusSwap = { main = main, backpack = slot,
                    displaced = bot:GetItemInSlot(main), time = DotaTime() }
                bot:ActionImmediate_SwapItems(slot, main)
            end
            return
        end
    end
end

return L
