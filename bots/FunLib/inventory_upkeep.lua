-- Two inventory chores that the purchase and item-use loops otherwise never do:
--  1. Consumables that land in the backpack (slots 6-8) are inactive and the item-use loop only scans the
--     main slots, so a Clarity delivered by the courier into a full inventory is never used.
--  2. Cheap starting components that nothing left in the buy plan consumes (Iron Branches without a
--     Magic Wand, Circlets without a Bracer...) sit in the inventory forever and push real items into
--     the backpack.
local X = {}

------------------------------------------------------------------------------------------
-- 1. Backpack consumables
------------------------------------------------------------------------------------------
-- Only consumables whose use conditions are simple and safe to check from the backpack.
X.BackpackConsumables = {
    item_clarity = true, item_faerie_fire = true, item_flask = true, item_enchanted_mango = true,
}
-- Never swapped out of the main inventory to make room.
X.KeepInMain = {
    item_tpscroll = true, item_power_treads = true, item_phase_boots = true,
    item_guardian_greaves = true, item_arcane_boots = true, item_tranquil_boots = true,
    item_boots = true, item_boots_of_bearing = true, item_travel_boots = true, item_travel_boots_2 = true,
    item_magic_stick = true, item_magic_wand = true, item_holy_locket = true,
    item_blink = true, item_overwhelming_blink = true, item_swift_blink = true, item_arcane_blink = true,
    item_black_king_bar = true, item_armlet = true, item_bloodstone = true,
    item_force_staff = true, item_hurricane_pike = true, item_glimmer_cape = true,
    item_cyclone = true, item_wind_waker = true, item_lotus_orb = true,
    item_sphere = true, item_mekansm = true, item_satanic = true, item_disperser = true,
    item_aegis = true, item_rapier = true, item_gem = true, item_cheese = true, item_refresher_shard = true,
}
X.SwapCooldown = 6 -- seconds between backpack swaps (Dota also puts swapped items on a short cooldown)

-- An empty main slot, else the cheapest item that is not protected. nil when nothing can be swapped.
function X.PickMainSlot(bot)
    local bestSlot, bestCost
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item == nil then return slot end
        local name = item:GetName()
        if not X.KeepInMain[name] then
            local cost = GetItemCost(name)
            if bestCost == nil or cost < bestCost then bestSlot, bestCost = slot, cost end
        end
    end
    return bestSlot
end

local function findItem(bot, item)
    if item == nil then return nil end
    for slot = 0, 8 do
        if bot:GetItemInSlot(slot) == item then return slot end
    end
end

-- The global swap wrapper can reject an action and returns nil even on success.
local function swapVerified(bot, source, target, now)
    local item = bot:GetItemInSlot(source)
    bot:ActionImmediate_SwapItems(source, target)
    if item == nil or bot:GetItemInSlot(target) ~= item then return false end
    bot.lastBackpackSwapTime = now
    return true
end

-- considerDesire(name, item) returns the item-use desire for that item (0 = do not use now).
-- Returns true only after a confirmed inventory change. Keep one consumable active at a time.
function X.SwapInBackpackConsumable(bot, considerDesire, now)
    if now < (bot.lastBackpackSwapTime or -math.huge) + X.SwapCooldown then return false end
    local swap = bot.backpackConsumableSwap
    if swap ~= nil then
        local current = bot:GetItemInSlot(swap.main)
        if current == swap.item and now < swap.time + 20
            and considerDesire(current:GetName(), current) > 0 then return false end

        local source = findItem(bot, swap.displaced)
        if source ~= nil and source >= 6 then
            local target = swap.main
            -- Other inventory routines may have filled the slot; never displace their item.
            if current ~= nil and current ~= swap.item then
                target = nil
                for slot = 0, 5 do
                    if bot:GetItemInSlot(slot) == nil then target = slot; break end
                end
            end
            if target == nil or not swapVerified(bot, source, target, now) then return false end
            bot.backpackConsumableSwap = nil
            return true
        end
        -- The displaced item was sold, combined, or already restored elsewhere.
        bot.backpackConsumableSwap = nil
        return false
    end
    -- Restore a previously displaced item above, even during combat. Starting
    -- a new swap can remove defensive stats and starts the backpack cooldown.
    if not bot:IsAlive() or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility()
        or bot:NumQueuedActions() > 0 or bot:HasModifier('modifier_teleporting')
        or bot:WasRecentlyDamagedByAnyHero(4) or bot:WasRecentlyDamagedByTower(4)
        or bot:WasRecentlyDamagedByCreep(4)
        or #bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE) > 0 then return false end
    for slot = 6, 8 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil then
            local name = item:GetName()
            if X.BackpackConsumables[name] and considerDesire(name, item) > 0 then
                local target = X.PickMainSlot(bot)
                if target ~= nil then
                    local displaced = bot:GetItemInSlot(target)
                    if not swapVerified(bot, slot, target, now) then return false end
                    bot.backpackConsumableSwap = {
                        main = target, item = item, displaced = displaced, time = now,
                    }
                    return true
                end
            end
        end
    end
    return false
end

------------------------------------------------------------------------------------------
-- 2. Orphaned starting components
------------------------------------------------------------------------------------------
-- Component -> every item that consumes it, transitively (Valve's items.txt recipes, 7.41f).
-- The item_double_* macros of a consumer count too.
X.ComponentUsers = {
    item_branches = { 'item_magic_wand', 'item_holy_locket' },
    item_circlet = { 'item_bracer', 'item_essence_distiller', 'item_null_talisman', 'item_spirit_vessel',
        'item_urn_of_shadows', 'item_wraith_band' },
    item_gauntlets = { 'item_bracer', 'item_soul_ring' },
    item_slippers = { 'item_wraith_band' },
    item_mantle = { 'item_null_talisman' },
}
X.MinTime = 8 * 60      -- leave the laning-phase inventory alone
X.CheckInterval = 3     -- seconds between sales
X.ShopRange = 200       -- ActionImmediate_SellItem only works near a shop (fountain, side or secret shop)

function X.IsNearShop(bot)
    return bot:DistanceFromFountain() <= X.ShopRange
        or bot:DistanceFromSecretShop() <= X.ShopRange
        or bot:DistanceFromSideShop() <= X.ShopRange
end

local function consumesComponent(name, candidate)
    if name == candidate then return true end
    -- Outfit macros expand into components (and recipes) when they reach the front of the plan.
    if name:find('_outfit$') then return true end
    for _, user in ipairs(X.ComponentUsers[candidate]) do
        if name == user or name == user:gsub('^item_', 'item_double_') then return true end
    end
    return false
end

-- True while the remaining plan still buys the component or something that is built from it.
function X.IsComponentNeeded(bot, candidate)
    for _, name in ipairs(bot.currBuyingBasicItemList or {}) do
        if name == candidate then return true end
    end
    if bot.currBuyingItemInPurchaseList ~= nil and consumesComponent(bot.currBuyingItemInPurchaseList, candidate) then
        return true
    end
    for _, name in ipairs(bot.purchaseListInReverseOrder or {}) do
        if consumesComponent(name, candidate) then return true end
    end
    return false
end

-- Sells at most one orphaned component per interval, only within shop range (unlike the full-inventory
-- cleanup this does not wait for every slot to be taken). Returns true when a sale was issued.
function X.SellDeadComponents(bot, now)
    if now < X.MinTime or now < (bot.lastDeadComponentCheck or -math.huge) + X.CheckInterval then return false end
    if not X.IsNearShop(bot) then return false end
    bot.lastDeadComponentCheck = now
    for slot = 0, 8 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil then
            local name = item:GetName()
            if X.ComponentUsers[name] ~= nil and not X.IsComponentNeeded(bot, name) then
                bot:ActionImmediate_SellItem(item)
                return true
            end
        end
    end
    return false
end

return X
