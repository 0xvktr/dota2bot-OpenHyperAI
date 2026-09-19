local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local L = {}
local restore = { item_famango = 125, item_great_famango = 400, item_greater_famango = 900 }
local protected = { item_aegis = true, item_rapier = true, item_armlet = true,
    item_black_king_bar = true, item_bloodstone = true, item_gem = true,
    item_cheese = true, item_refresher_shard = true, item_power_treads = true }

function L.Target(bot, item)
    local amount = restore[item:GetName()]
    if not amount or bot:DistanceFromFountain() < 1200 then return nil end
    local best, score = nil, 0
    local candidates = { bot }
    for _, h in ipairs(J.GetAlliesNearLoc(bot:GetLocation(), item:GetCastRange())) do
        if h ~= bot then table.insert(candidates, h) end
    end
    for _, h in ipairs(candidates) do
        if J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion() then
            local hp = h:GetMaxHealth() - h:GetHealth()
            local mp = h:GetMaxMana() - h:GetMana()
            local value = math.min(hp, amount) + math.min(mp, amount)
            -- Instant restoration is useful in combat too. Avoid wasting a large
            -- lotus on a small deficit, except when health is critically low.
            if value >= amount * 0.8 or (J.GetHP(h) < 0.35 and hp > 100) then
                local priority = value / amount + (1 - J.GetHP(h)) * 2
                if priority > score then best, score = h, priority end
            end
        end
    end
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
