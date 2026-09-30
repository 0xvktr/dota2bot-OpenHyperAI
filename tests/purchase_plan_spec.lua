-- Purchase planning: Item.GetBasicItems (bots/FunLib/aba_item.lua) and the purchase loop's dedupe,
-- queue, recipe hold and re-plan (bots/item_purchase_generic.lua, extracted by tests/run-builds.cjs),
-- run against Valve's recipes (tests/valve/recipes.json). A recipe bought without its other parts
-- never assembles and wastes a slot for the rest of the game.
package.path = './?.lua;'..package.path
local H = dofile('tests/hero_harness.lua')
local ctx = H.realDofile('.test-tools/purchase-plan-context.lua')
local recipes, costs = ctx.recipes, ctx.costs

local clock = 0
function DotaTime() return clock end
function GetGameMode() return 1 end
function GetItemComponents(name) return recipes[name] and { recipes[name] } or {} end
function GetItemCost(name) return costs[name] or 0 end
function GetItemStockCount() return 5 end
function RandomInt(low) return low end -- Rubick's build rolls at load time
package.loaded['bots/FunLib/aba_global_overrides'] = true
package.loaded['bots/FunLib/aba_role'] = {}
local Item = H.realDofile('bots/FunLib/aba_item.lua')

-- The simulated bot: inventory, backpack and stash as one list of at most 15 items (slots 0-14).
local inv = {}
local sim = {}
function sim:GetItemInSlot(i) local name = inv[i + 1]; return name and { GetName = function() return name end } or nil end
function sim:FindItemSlot(name) for i, n in ipairs(inv) do if n == name then return i - 1 end end; return -1 end
function sim:HasScepter() return false end
function sim:HasModifier() return false end
function sim:GetUnitName() return 'npc_dota_hero_sim' end
local log = {}
local hooks = H.realDofile('.test-tools/purchase-plan-hooks.lua')(sim, {},
    { Deepcopy = function(t) local c = {}; for i, v in ipairs(t) do c[i] = v end; return c end },
    Item, {}, function(line) log[#log + 1] = line end)

local function count(name) local n = 0; for _, v in ipairs(inv) do if v == name then n = n + 1 end end; return n end
local function remove(name) for i, v in ipairs(inv) do if v == name then table.remove(inv, i); return end end end
local function has(list, name) for _, v in ipairs(list) do if v == name then return true end end; return false end
local function sorted(list) local c = {}; for i, v in ipairs(list) do c[i] = v end; table.sort(c); return table.concat(c, ',') end

-- Like the game: an item assembles as soon as all its parts (and a paid recipe) are owned.
local function combine()
    local changed = true
    while changed do
        changed = false
        for result, parts in pairs(recipes) do
            local need = {}
            for _, p in ipairs(parts) do need[p] = (need[p] or 0) + 1 end
            local ok = true
            for p, n in pairs(need) do if count(p) < n then ok = false; break end end
            if ok then
                for _, p in ipairs(parts) do remove(p) end
                inv[#inv + 1] = result
                changed = true
            end
        end
    end
end

-- Used right away; they never block a slot or feed a recipe.
local CONSUMED = { item_tango = true, item_flask = true, item_clarity = true, item_faerie_fire = true,
    item_enchanted_mango = true, item_ward_observer = true, item_ward_sentry = true, item_smoke_of_deceit = true,
    item_dust = true, item_blood_grenade = true, item_tpscroll = true, item_tome_of_knowledge = true,
    item_aghanims_shard = true }

local function addParts(name, set)
    for _, p in ipairs(Item[name] or {}) do
        if not set[p] then set[p] = true; addParts(p, set) end
    end
end

-- Keep 15 slots like the bots do: sell the cheapest item nothing left in the list is built from.
local function makeRoom(remaining)
    while #inv > 15 do
        local needed = {}
        for _, t in ipairs(remaining) do needed[t] = true; addParts(t, needed) end
        local best
        for i, v in ipairs(inv) do
            if not needed[v] and (best == nil or GetItemCost(v) < GetItemCost(inv[best])) then best = i end
        end
        assert(best, 'inventory full of parts: '..table.concat(inv, ','))
        table.remove(inv, best)
    end
end

local function buy(name, remaining)
    inv[#inv + 1] = name
    combine()
    if CONSUMED[name] then remove(name) end
    makeRoom(remaining)
end

local function start(target)
    GetBot = function() return sim end
    sim.currBuyingItemInPurchaseList = target
    sim.currBuyingBasicItem = nil
    hooks.queue(Item.GetBasicItems({ target }))
end

-- The purchase loop for the current target: buy each needed head unless a recipe waits for parts,
-- and plan again (up to three times) when everything was bought but the item is missing.
local function drain(target, remaining)
    local rebuilds = 0
    for _ = 1, 200 do
        clock = clock + 5
        local head = hooks.pop()
        if head == nil then
            if not recipes[target] or count(target) > 0 or rebuilds >= 3 then return end
            rebuilds = rebuilds + 1
            hooks.queue(Item.GetBasicItems({ target }))
        elseif not hooks.recipeWaits(head) then
            buy(head, remaining)
            sim.currBuyingBasicItemList[#sim.currBuyingBasicItemList] = nil
        end
    end
    error('purchase loop did not settle for '..target..' (inventory: '..table.concat(inv, ',')
        ..'; queue: '..table.concat(sim.currBuyingBasicItemList, ',')..')')
end

local function purchase(target, remaining)
    start(target)
    drain(target, remaining)
end

local function plan(target)
    GetBot = function() return sim end
    return Item.GetBasicItems({ target })
end

------------------------------------------------------------------------------------------
-- Owned parts count per copy
------------------------------------------------------------------------------------------
-- Winter Wyvern pos 4 and Mirana open with one Iron Branch and build a Magic Wand (7.41f game:
-- Stick + recipe bought, the second branch never).
inv = { 'item_branches' }
local basic, claimed = plan('item_magic_wand')
assert(sorted(basic) == 'item_branches,item_magic_stick,item_recipe_magic_wand', sorted(basic))
assert(claimed.item_branches == 1, 'the owned branch covers one of the two')
purchase('item_magic_wand', { 'item_magic_wand' })
assert(count('item_magic_wand') == 1 and #inv == 1, 'one owned branch: '..table.concat(inv, ','))

-- Dragon Knight pos 2/3 open with two Gauntlets; the Bracer takes one, the Soul Ring needs two.
inv = { 'item_bracer', 'item_gauntlets' }
basic = plan('item_soul_ring')
assert(sorted(basic) == 'item_gauntlets,item_recipe_soul_ring,item_ring_of_protection', sorted(basic))
purchase('item_soul_ring', { 'item_soul_ring' })
assert(count('item_soul_ring') == 1 and count('item_bracer') == 1 and #inv == 2, table.concat(inv, ','))

-- A finished item in the list is skipped; an owned intermediate item is used, not rebuilt.
inv = { 'item_magic_wand' }
assert(#plan('item_magic_wand') == 0, 'owned target plans nothing')
assert(sorted(plan('item_holy_locket')) == 'item_crown,item_recipe_holy_locket', 'Holy Locket uses the owned Wand')
assert(sim.sLastRepeatItem == nil, 'planning keeps no hidden state between targets')

------------------------------------------------------------------------------------------
-- Parts inside other items are not owned copies
------------------------------------------------------------------------------------------
-- Sange and Yasha holds a Sange, but an Abyssal Blade needs a Sange of its own.
inv = { 'item_sange_and_yasha' }
basic = plan('item_abyssal_blade')
for _, part in ipairs({ 'item_ogre_axe', 'item_recipe_sange', 'item_mithril_hammer', 'item_recipe_basher',
    'item_recipe_abyssal_blade' }) do
    assert(has(basic, part), 'Abyssal Blade next to Sange and Yasha plans '..part)
end
purchase('item_abyssal_blade', { 'item_abyssal_blade' })
assert(count('item_abyssal_blade') == 1 and count('item_sange_and_yasha') == 1 and #inv == 2, table.concat(inv, ','))
-- A loose Sange is used by whichever item comes next.
inv = { 'item_sange' }
assert(not has(plan('item_sange_and_yasha'), 'item_ogre_axe'), 'Sange and Yasha uses the owned Sange')

------------------------------------------------------------------------------------------
-- Recipe hold and re-plan
------------------------------------------------------------------------------------------
-- A branch is lost (sold, dropped) after the plan: the recipe waits and the branch is bought again.
inv = { 'item_magic_stick', 'item_branches', 'item_branches' }
start('item_magic_wand')
assert(sorted(sim.currBuyingBasicItemList) == 'item_recipe_magic_wand', 'only the recipe is missing')
remove('item_branches')
clock = clock + 10
log = {}
assert(hooks.recipeWaits('item_recipe_magic_wand'), 'recipe waits while a branch is missing')
assert(sorted(sim.currBuyingBasicItemList) == 'item_branches,item_recipe_magic_wand', 'the lost branch is queued again')
assert(sim.currBuyingBasicItemList[#sim.currBuyingBasicItemList] == 'item_branches', 'the branch is bought first')
assert(log[1] and log[1]:find('holds item_recipe_magic_wand: missing item_branches'), 'hold is logged')
drain('item_magic_wand', { 'item_magic_wand' })
assert(count('item_magic_wand') == 1 and #inv == 1, table.concat(inv, ','))
-- Parts on the courier: the recipe waits without re-planning.
inv = { 'item_magic_stick', 'item_branches' }
hooks.queue({ 'item_recipe_magic_wand' }, { item_magic_stick = 1, item_branches = 2 })
hooks.transit(200, 0)
clock = clock + 10
assert(hooks.recipeWaits('item_recipe_magic_wand'), 'recipe waits for the courier')
assert(sorted(sim.currBuyingBasicItemList) == 'item_recipe_magic_wand', 'no re-plan while parts are on the way')
-- Parts that never arrive: after three minutes the queue is emptied and the target timed out,
-- so one broken item cannot block the rest of the buy list.
clock = clock + 3 * 60 + 1
log = {}
assert(hooks.recipeWaits('item_recipe_magic_wand'))
assert(#sim.currBuyingBasicItemList == 0 and sim.countInvCheck == math.huge, 'held recipe gives up')
assert(log[1]:find('gives up on item_magic_wand'), 'give-up is logged')
hooks.transit(0, 0)
assert(not hooks.recipeWaits('item_magic_stick'), 'only recipes wait')

------------------------------------------------------------------------------------------
-- Every hero and role: each composite item in the buy list assembles, and no recipe is left over
------------------------------------------------------------------------------------------
local lists, problems = 0, {}
for _, hero in ipairs(ctx.heroes) do
    local seen = {}
    for pos = 1, 5 do
        GetBot = function() return H.bot end
        local X = H.load('npc_dota_hero_'..hero, 'pos_'..pos)
        local key = table.concat(X.sBuyList, ',')
        if not seen[key] then
            seen[key] = true
            lists = lists + 1
            inv = {}
            local list = X.sBuyList
            for i, target in ipairs(list) do
                local remaining = {}
                for j = i, #list do remaining[#remaining + 1] = list[j] end
                purchase(target, remaining)
                local built = count(target) > 0
                for _, v in ipairs(inv) do
                    if recipes[v] and has(recipes[v], target) then built = true end
                end
                if recipes[target] and not built then
                    problems[#problems + 1] = hero..' pos_'..pos..': '..target..' never assembles'
                end
            end
            for _, v in ipairs(inv) do
                if v:find('^item_recipe_') then problems[#problems + 1] = hero..' pos_'..pos..': '..v..' left over' end
            end
        end
    end
end
assert(#problems == 0, #problems..' purchase problems:\n'..table.concat(problems, '\n'))

print('Purchase plan scenarios passed ('..lists..' buy lists)')
