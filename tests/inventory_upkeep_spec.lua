-- Backpack consumable swaps and orphaned-component sales (bots/FunLib/inventory_upkeep.lua).
package.path = './?.lua;'..package.path
BOT_MODE_NONE = 0
local Upkeep = dofile('bots/FunLib/inventory_upkeep.lua')

local costs = { item_clarity = 50, item_tango = 90, item_magic_wand = 450, item_blink = 2250, item_bottle = 675,
    item_tpscroll = 50, item_branches = 50, item_circlet = 155, item_gauntlets = 140, item_bracer = 200,
    item_travel_boots = 2500, item_phase_boots = 1500, item_black_king_bar = 4050 }
function GetItemCost(name) return costs[name] or 1000 end

-- A bot whose slots 0-8 hold the named items.
local function makeBot(slots)
    -- Distances to the fountain / secret shop / side shop; default: standing in the fountain.
    local bot = { swaps = {}, sold = {}, slots = slots, dist = { fountain = 0, secret = 5000, side = 5000 } }
    function bot:DistanceFromFountain() return self.dist.fountain end
    function bot:DistanceFromSecretShop() return self.dist.secret end
    function bot:DistanceFromSideShop() return self.dist.side end
    function bot:IsAlive() return true end
    function bot:IsChanneling() return self.channeling == true end
    function bot:IsCastingAbility() return false end
    function bot:IsUsingAbility() return false end
    function bot:NumQueuedActions() return self.queued or 0 end
    function bot:HasModifier() return self.teleporting == true end
    function bot:WasRecentlyDamagedByAnyHero() return self.heroDamage == true end
    function bot:WasRecentlyDamagedByTower() return self.towerDamage == true end
    function bot:WasRecentlyDamagedByCreep() return self.creepDamage == true end
    function bot:GetNearbyHeroes() return self.enemies or {} end
    local function item(name, slot) return { GetName = function() return name end, slot = slot } end
    function bot:GetItemInSlot(i)
        if type(self.slots[i]) == 'string' then self.slots[i] = item(self.slots[i], i) end
        return self.slots[i]
    end
    function bot:ActionImmediate_SwapItems(a, b)
        if self.rejectSwap then return end
        self.swaps[#self.swaps + 1] = { a, b }
        local first, second = self:GetItemInSlot(a), self:GetItemInSlot(b)
        self.slots[a], self.slots[b] = second, first
        if first then first.slot = b end
        if second then second.slot = a end
        -- Like the real wrapper, successful swaps also return nil.
    end
    function bot:ActionImmediate_SellItem(it)
        self.sold[#self.sold + 1] = it:GetName()
        self.slots[it.slot] = nil -- a sold item leaves the inventory
    end
    return bot
end
local function want(desire) return function() return desire end end

------------------------------------------------------------------------------------------
-- Backpack consumables
------------------------------------------------------------------------------------------
-- Axe's case: full main inventory, Clarity stuck in the backpack, mana low.
local axe = makeBot({ [0] = 'item_bottle', 'item_magic_wand', 'item_blink', 'item_phase_boots', 'item_black_king_bar',
    'item_tango', [6] = 'item_clarity' })
assert(Upkeep.SwapInBackpackConsumable(axe, want(1), 100), 'a wanted backpack Clarity must be swapped in')
assert(axe.swaps[1][1] == 6 and axe.swaps[1][2] == 5, 'swaps with the cheapest main item (Tango)')
assert(not Upkeep.SwapInBackpackConsumable(axe, want(1), 103), 'swaps are rate limited')
assert(not Upkeep.SwapInBackpackConsumable(axe, want(1), 107), 'leave the active consumable available for use')
axe.slots[5] = nil -- consume the Clarity
axe.rejectSwap = true
assert(not Upkeep.SwapInBackpackConsumable(axe, want(1), 108), 'rejected restoration is not success')
assert(axe.backpackConsumableSwap and axe.lastBackpackSwapTime == 100, 'retain restoration for retry')
axe.rejectSwap = false
assert(Upkeep.SwapInBackpackConsumable(axe, want(1), 112), 'retry restoration after rejection')
assert(axe:GetItemInSlot(5):GetName() == 'item_tango' and axe:GetItemInSlot(6) == nil)
assert(axe.backpackConsumableSwap == nil)

local rejected = makeBot({ [0] = 'item_blink', [6] = 'item_clarity' })
rejected.rejectSwap = true
assert(not Upkeep.SwapInBackpackConsumable(rejected, want(1), 100))
assert(rejected.lastBackpackSwapTime == nil and rejected.backpackConsumableSwap == nil)
rejected.rejectSwap = false
assert(Upkeep.SwapInBackpackConsumable(rejected, want(1), 101), 'rejection must not start a cooldown')

local competing = makeBot({ [0] = 'item_bracer', 'item_blink', 'item_blink', 'item_blink',
    'item_blink', 'item_blink', [6] = 'item_clarity', [7] = 'item_flask' })
assert(Upkeep.SwapInBackpackConsumable(competing, want(1), 100))
assert(not Upkeep.SwapInBackpackConsumable(competing, want(1), 112), 'do not rotate another consumable over the first')
assert(competing:GetItemInSlot(0):GetName() == 'item_clarity')
assert(Upkeep.SwapInBackpackConsumable(competing, want(0), 113), 'restore equipment when use is cancelled')
assert(competing:GetItemInSlot(0):GetName() == 'item_bracer')

local changed = makeBot({ [0] = 'item_bracer', 'item_blink', 'item_blink', 'item_blink',
    'item_blink', 'item_blink', [6] = 'item_clarity' })
assert(Upkeep.SwapInBackpackConsumable(changed, want(1), 100))
changed.slots[0] = 'item_black_king_bar'
assert(not Upkeep.SwapInBackpackConsumable(changed, want(0), 112), 'do not overwrite a newly occupied slot')
changed.slots[3] = nil
assert(Upkeep.SwapInBackpackConsumable(changed, want(0), 113))
assert(changed:GetItemInSlot(0):GetName() == 'item_black_king_bar')
assert(changed:GetItemInSlot(3):GetName() == 'item_bracer', 'restore into another empty slot')

local expired = makeBot({ [0] = 'item_bracer', 'item_blink', 'item_blink', 'item_blink',
    'item_blink', 'item_blink', [6] = 'item_clarity' })
assert(Upkeep.SwapInBackpackConsumable(expired, want(1), 100))
assert(Upkeep.SwapInBackpackConsumable(expired, want(1), 121), 'restore if a desired consumable never gets used')
assert(expired:GetItemInSlot(0):GetName() == 'item_bracer')

local sold = makeBot({ [0] = 'item_bracer', 'item_blink', 'item_blink', 'item_blink',
    'item_blink', 'item_blink', [6] = 'item_clarity' })
assert(Upkeep.SwapInBackpackConsumable(sold, want(1), 100))
sold.slots[0], sold.slots[6] = nil, nil -- consumption plus sale or combination of displaced item
assert(not Upkeep.SwapInBackpackConsumable(sold, want(0), 112))
assert(sold.backpackConsumableSwap == nil, 'forget a displaced item that no longer exists')

local empty = makeBot({ [0] = 'item_blink', [3] = 'item_magic_wand', [6] = 'item_clarity' })
assert(Upkeep.SwapInBackpackConsumable(empty, want(1), 100))
assert(empty.swaps[1][2] == 1, 'an empty main slot is used before displacing an item')

local idle = makeBot({ [0] = 'item_blink', [6] = 'item_clarity' })
assert(not Upkeep.SwapInBackpackConsumable(idle, want(0), 100), 'no swap without a use desire')
assert(#idle.swaps == 0)

local notConsumable = makeBot({ [0] = 'item_blink', [6] = 'item_bottle' })
assert(not Upkeep.SwapInBackpackConsumable(notConsumable, want(1), 100), 'only known consumables are rotated in')

local inMain = makeBot({ [0] = 'item_clarity', [1] = 'item_blink' })
assert(not Upkeep.SwapInBackpackConsumable(inMain, want(1), 100), 'nothing to do when it is already in a main slot')

local protected = makeBot({ [0] = 'item_travel_boots', [1] = 'item_travel_boots', [2] = 'item_travel_boots',
    [3] = 'item_travel_boots', [4] = 'item_travel_boots', [5] = 'item_travel_boots', [6] = 'item_clarity' })
assert(not Upkeep.SwapInBackpackConsumable(protected, want(1), 100), 'protected items are never displaced')

for _, name in ipairs({ 'item_boots', 'item_phase_boots', 'item_power_treads', 'item_arcane_boots',
    'item_tranquil_boots', 'item_guardian_greaves', 'item_boots_of_bearing', 'item_travel_boots',
    'item_travel_boots_2', 'item_magic_wand', 'item_black_king_bar', 'item_force_staff', 'item_armlet' }) do
    local full = makeBot({ [0]=name, name, name, name, name, name, [6]='item_clarity' })
    assert(not Upkeep.SwapInBackpackConsumable(full, want(1), 100), 'must keep '..name)
end
for _, field in ipairs({ 'heroDamage', 'towerDamage', 'creepDamage', 'channeling', 'teleporting' }) do
    local fighting = makeBot({ [0]='item_bracer', [6]='item_clarity' })
    fighting[field] = true
    assert(not Upkeep.SwapInBackpackConsumable(fighting, want(1), 100), field..' prevents new swaps')
    assert(fighting.lastBackpackSwapTime == nil)
    fighting[field] = false
    assert(Upkeep.SwapInBackpackConsumable(fighting, want(1), 101), 'retry when safe')
end
local enemies = makeBot({ [0]='item_bracer', 'item_blink', 'item_blink', 'item_blink',
    'item_blink', 'item_blink', [6]='item_clarity' })
enemies.enemies = { {} }
assert(not Upkeep.SwapInBackpackConsumable(enemies, want(1), 100), 'nearby enemy prevents losing defensive stats')
enemies.enemies = {}; enemies.queued = 1
assert(not Upkeep.SwapInBackpackConsumable(enemies, want(1), 100), 'pending combo prevents new swap')
enemies.queued = 0
assert(Upkeep.SwapInBackpackConsumable(enemies, want(1), 100))
enemies.heroDamage = true; enemies.slots[0] = nil
assert(Upkeep.SwapInBackpackConsumable(enemies, want(0), 107), 'restore displaced stats even during combat')
assert(enemies:GetItemInSlot(0):GetName() == 'item_bracer')

local seen
local lookup = makeBot({ [0] = 'item_blink', [6] = 'item_clarity' })
Upkeep.SwapInBackpackConsumable(lookup, function(name, hItem) seen = { name, hItem:GetName() }; return 0 end, 100)
assert(seen and seen[1] == 'item_clarity' and seen[2] == 'item_clarity', 'the callback receives the name and the item')

------------------------------------------------------------------------------------------
-- Orphaned starting components
------------------------------------------------------------------------------------------
local function arc(remaining, extra)
    local bot = makeBot({ [0] = 'item_bottle', 'item_circlet', 'item_circlet', 'item_blink', [6] = 'item_branches', 'item_branches' })
    bot.purchaseListInReverseOrder = remaining
    for k, v in pairs(extra or {}) do bot[k] = v end
    return bot
end

-- Arc Warden's case: 20 minutes in, Branches and Circlets that nothing left in the plan uses.
local bot = arc({ 'item_moon_shard', 'item_ultimate_scepter_2', 'item_black_king_bar', 'item_travel_boots_2' })
assert(not Upkeep.SellDeadComponents(bot, 300), 'the laning-phase inventory is left alone')
assert(Upkeep.SellDeadComponents(bot, 1200), 'orphaned components are sold')
assert(bot.sold[1] == 'item_circlet', 'in slot order')
assert(not Upkeep.SellDeadComponents(bot, 1201), 'one sale per interval')
assert(Upkeep.SellDeadComponents(bot, 1204) and bot.sold[2] == 'item_circlet')
assert(Upkeep.SellDeadComponents(bot, 1208) and bot.sold[3] == 'item_branches')
assert(Upkeep.SellDeadComponents(bot, 1212) and bot.sold[4] == 'item_branches')
assert(not Upkeep.SellDeadComponents(bot, 1216), 'real items are never sold')

-- ActionImmediate_SellItem only works near a shop: nothing is attempted in the field.
local field = arc({ 'item_moon_shard' })
field.dist = { fountain = 3000, secret = 4000, side = 2500 }
assert(not Upkeep.SellDeadComponents(field, 1200), 'no sale attempts away from every shop')
assert(#field.sold == 0)
field.dist = { fountain = 3000, secret = 4000, side = 150 }
assert(Upkeep.SellDeadComponents(field, 1200) and #field.sold == 1, 'a side shop counts')
field.dist = { fountain = 3000, secret = 120, side = 2500 }
assert(Upkeep.SellDeadComponents(field, 1204), 'a secret shop counts')
field.dist = { fountain = 0, secret = 4000, side = 2500 }
assert(Upkeep.SellDeadComponents(field, 1208), 'the fountain counts')
for _, name in ipairs(bot.sold) do assert(name == 'item_circlet' or name == 'item_branches') end

-- Anything left in the plan that consumes a component keeps it (macros included).
local wand = arc({ 'item_magic_wand' })
wand.slots = { [0] = 'item_branches', [1] = 'item_branches', [2] = 'item_magic_stick' }
assert(not Upkeep.SellDeadComponents(wand, 1200), 'Branches are kept for a planned Magic Wand')
local bracer = arc({ 'item_double_bracer' })
bracer.slots = { [0] = 'item_circlet', [1] = 'item_gauntlets' }
assert(not Upkeep.SellDeadComponents(bracer, 1200), 'Circlet and Gauntlets are kept for a planned (double) Bracer')
local urn = arc({ 'item_spirit_vessel' })
urn.slots = { [0] = 'item_circlet' }
assert(not Upkeep.SellDeadComponents(urn, 1200), 'transitive consumers count (Circlet -> Urn -> Spirit Vessel)')
local soul = arc({ 'item_soul_ring' })
soul.slots = { [0] = 'item_gauntlets', [1] = 'item_gauntlets' }
assert(not Upkeep.SellDeadComponents(soul, 1200), 'Gauntlets are kept for a planned Soul Ring')

-- Outfit macros, components still being bought and the item in progress are all conservative keeps.
local outfit = arc({ 'item_tank_outfit' })
assert(not Upkeep.SellDeadComponents(outfit, 1200), 'an outfit macro may still expand into these components')
local basic = arc({}, { currBuyingBasicItemList = { 'item_circlet' } })
basic.slots = { [0] = 'item_circlet' }
assert(not Upkeep.SellDeadComponents(basic, 1200), 'a component still on the basic-item list is kept')
local building = arc({}, { currBuyingItemInPurchaseList = 'item_wraith_band' })
building.slots = { [0] = 'item_circlet', [1] = 'item_slippers' }
assert(not Upkeep.SellDeadComponents(building, 1200), 'the item currently being built keeps its components')

-- Once the consumer is built, its leftover component is orphaned again.
local built = arc({ 'item_moon_shard' })
built.slots = { [0] = 'item_bracer', [1] = 'item_gauntlets' }
assert(Upkeep.SellDeadComponents(built, 1200) and built.sold[1] == 'item_gauntlets')
assert(#built.sold == 1)

print('Inventory upkeep scenarios passed')
