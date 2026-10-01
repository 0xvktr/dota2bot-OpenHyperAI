local loadCleanup = dofile('.test-tools/early-item-cleanup.lua')
local now, count = 0, 0
function DotaTime() return now end
local Utils = {}
function Utils.CountBackpackEmptySpace(bot)
    local empty = 0
    for slot = 6, 8 do if bot.slots[slot] == nil then empty = empty + 1 end end
    return empty
end
local function makeBot()
    local b = {slots = {}, sold = {}, distance = 5000, level = 15, networth = 20000}
    function b:Put(slot, name)
        self.slots[slot] = {GetName = function() return name end}
    end
    for slot = 0, 5 do b:Put(slot, 'item_blink') end
    b:Put(6, 'item_magic_wand')
    b:Put(7, 'item_quelling_blade')
    b:Put(8, 'item_magic_stick')
    function b:GetLevel() return self.level end
    function b:GetNetWorth() return self.networth end
    function b:DistanceFromFountain() return self.distance end
    function b:GetItemInSlot(slot) return self.slots[slot] end
    function b:FindItemSlot(name)
        for slot = 0, 15 do
            if self.slots[slot] and self.slots[slot]:GetName() == name then return slot end
        end
        return -1
    end
    function b:ActionImmediate_SellItem(item)
        assert(self.distance <= 300, 'only sell within the existing fountain range')
        if self.rejectSale then return end
        self.sold[#self.sold + 1] = item:GetName()
        for slot = 0, 15 do if self.slots[slot] == item then self.slots[slot] = nil; break end end
    end
    function b:Action_DropItem() error('early-item cleanup must never drop an item') end
    b.cleanup = loadCleanup(b, Utils)
    return b
end
local function tick(b, time) now = time; b.cleanup() end

-- Full inventory, including the reported Wand/Blade/Stick: repeated field checks
-- leave no ground item for the pickup loop to chase and preserve all owned items.
local field = makeBot()
local owned = {field.slots[6], field.slots[7], field.slots[8]}
for _, distance in ipairs({5000, 3000, 2999, 301}) do
    field.distance = distance
    for time = 4, 60, 4 do tick(field, now + 4) end
    for slot = 6, 8 do assert(field.slots[slot] == owned[slot - 5]) end
    assert(#field.sold == 0)
    count = count + 1
end
field.distance = 300
tick(field, now + 4)
assert(#field.sold == 3, 'surplus backpack items are sold on the next fountain visit')
assert(field.slots[6] == nil and field.slots[7] == nil and field.slots[8] == nil)
for slot = 0, 5 do assert(field.slots[slot]:GetName() == 'item_blink') end
count = count + 1

-- Keep every existing eligibility threshold.
for _, options in ipairs({{level = 5}, {networth = 13999}, {emptyBackpack = true}}) do
    local b = makeBot()
    b.distance = 0
    if options.level then b.level = options.level end
    if options.networth then b.networth = options.networth end
    if options.emptyBackpack then b.slots[7], b.slots[8] = nil, nil end
    tick(b, 100)
    assert(#b.sold == 0 and b.slots[6] ~= nil)
    count = count + 1
end
local boundary = makeBot()
boundary.distance, boundary.level, boundary.networth = 0, 6, 14000
boundary.slots[8] = nil -- two backpack items still trigger cleanup
tick(boundary, 0)
tick(boundary, 3)
assert(#boundary.sold == 0, 'no pregame sale and the interval remains strictly greater than 3 seconds')
tick(boundary, 4)
assert(#boundary.sold == 2)
boundary:Put(6, 'item_magic_wand'); boundary:Put(7, 'item_magic_stick')
tick(boundary, 7)
assert(#boundary.sold == 2, 'three seconds is too soon')
tick(boundary, 8)
assert(#boundary.sold == 4)
count = count + 1

-- Useful main inventory items, stash items and other backpack gear remain alone.
local protected = makeBot()
protected.distance = 0
protected:Put(0, 'item_magic_wand')
protected:Put(6, 'item_blink'); protected:Put(7, 'item_black_king_bar'); protected:Put(8, 'item_tpscroll')
protected:Put(9, 'item_quelling_blade')
tick(protected, 100)
assert(#protected.sold == 0)
for slot = 0, 9 do assert(protected.slots[slot]) end
count = count + 1

-- A rejected immediate sale must not fall back to a drop.
local rejected = makeBot()
rejected.distance, rejected.rejectSale = 0, true
tick(rejected, 100)
assert(#rejected.sold == 0 and rejected.slots[6])
rejected.rejectSale = false
tick(rejected, 104)
assert(#rejected.sold == 3)
count = count + 1
print(count .. ' early item cleanup scenarios passed')
