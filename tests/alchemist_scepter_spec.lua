-- Alchemist's Aghanim's Scepter gifting: opt-in rules and the purchase/cast state machine.
local H = dofile('tests/hero_harness.lua')
local J, bot = H.J, H.bot
local unit = 'npc_dota_hero_alchemist'

-- Only the migrated carry build opts into gifts, and a user's custom item build never does.
assert(H.load(unit, 'pos_1').enableScepterGifts, 'the default carry build enables gifts')
for _, role in ipairs({ 'pos_2', 'pos_3', 'pos_4', 'pos_5' }) do
    assert(not H.load(unit, role).enableScepterGifts, role..' must not gift')
end
local originalInit = J.SetUserHeroInit
J.SetUserHeroInit = function(a, t, items, s) return a, t, { 'item_radiance' }, s end
assert(not H.load(unit, 'pos_1').enableScepterGifts, 'custom builds must not opt into gifts')
J.SetUserHeroInit = originalInit

local Gift = H.realDofile('bots/FunLib/alchemist_scepter.lua')
local function ally(role)
    return {
        role = role, scepter = false, alive = true, illusion = false, team = 2,
        IsNull = function() return false end, IsAlive = function(self) return self.alive end,
        IsIllusion = function(self) return self.illusion end, GetTeam = function(self) return self.team end,
        HasScepter = function(self) return self.scepter end, FindItemSlot = function() return -1 end,
    }
end
local mid, off, support = ally(2), ally(3), ally(5)
local allies = { support, off, mid }
UNIT_LIST_ALLIED_HEROES = 1; BOT_MODE_NONE = 0; BOT_ACTION_DESIRE_HIGH = 0.8
function GetUnitList() return allies end
-- Deliberately fail if global gifting accidentally becomes range-limited again.
function GetUnitToUnitDistance() error('Scepter gifts must not check distance') end
function GetItemCost() return 4200 end
J.IsValidHero = function(a) return a ~= nil end
J.GetPosition = function(a) return a.role end
local danger = false
J.IsRetreating = function() return false end
J.IsGoingOnSomeone = function() return false end
J.GetNearbyHeroes = function() return danger and { mid } or {} end
bot.WasRecentlyDamagedByAnyHero = function() return false end
bot.role = 1
bot.GetTeam = function() return 2 end
bot.GetGold = function() return 7000 end
bot.GetBuybackCost = function() return 2000 end
bot.GetCourierValue = function() return 0 end
bot.GetStashValue = function() return 0 end
bot.HasScepter = function() return true end
local inventory = {}
local function item(name) return { GetName = function() return name end, IsFullyCastable = function() return true end } end
for i, name in ipairs({ 'item_radiance', 'item_black_king_bar', 'item_assault', 'item_abyssal_blade', 'item_swift_blink', 'item_travel_boots_2' }) do
    inventory[i - 1] = item(name)
end
bot.FindItemSlot = function(_, name) for slot, it in pairs(inventory) do if it:GetName() == name then return slot end end return -1 end
bot.GetItemInSlot = function(_, slot) return inventory[slot] end
bot.ActionImmediate_SwapItems = function(_, a, c) inventory[a], inventory[c] = inventory[c], inventory[a] end
bot.purchaseListInReverseOrder = { 'item_swift_blink' }
Gift.UpdatePurchase(bot, J, true)
assert(not bot.alchemistGiftPending, 'personal build must finish first')
bot.purchaseListInReverseOrder = {}
bot.GetGold = function() return 6100 end
Gift.UpdatePurchase(bot, J, true)
assert(not bot.alchemistGiftPending, 'reserve buyback gold')
bot.GetGold = function() return 7000 end
Gift.UpdatePurchase(bot, J, false)
assert(not bot.alchemistGiftPending)
assert(Gift.GetTarget(bot, J) == mid, 'prefer position 2 globally')
mid.illusion = true
assert(Gift.GetTarget(bot, J) == off)
mid.illusion = false; mid.alive = false
assert(Gift.GetTarget(bot, J) == off)
mid.alive = true; mid.team = 3
assert(Gift.GetTarget(bot, J) == off)
mid.team = 2
Gift.UpdatePurchase(bot, J, true)
assert(bot.alchemistGiftPending and #bot.purchaseListInReverseOrder == 1)
Gift.UpdatePurchase(bot, J, true)
assert(#bot.purchaseListInReverseOrder == 1, 'one gift at a time')
local aghs = item('item_ultimate_scepter')
inventory[6] = aghs
bot.purchaseListInReverseOrder = {}
danger = true
Gift.Prepare(bot, J)
assert(inventory[6] == aghs and Gift.Consider(bot, aghs, J) == 0)
danger = false
Gift.Prepare(bot, J)
assert(inventory[0] == aghs and inventory[6]:GetName() == 'item_radiance')
danger = true
Gift.Prepare(bot, J)
assert(inventory[0]:GetName() == 'item_radiance' and inventory[6] == aghs, 'restore combat inventory when danger returns')
danger = false
Gift.Prepare(bot, J)
local desire, target, cast = Gift.Consider(bot, aghs, J)
assert(desire > 0 and target == mid and cast == 'unit')
Gift.UpdatePurchase(bot, J, true)
assert(bot.alchemistGiftPending, 'issuing an action is not success')
-- Engine confirms consumption and upgrade.
inventory[0] = nil; mid.scepter = true
Gift.Prepare(bot, J)
assert(inventory[0]:GetName() == 'item_radiance' and inventory[6] == nil)
Gift.UpdatePurchase(bot, J, true)
assert(not bot.alchemistGiftPending)
assert(Gift.GetTarget(bot, J) == off)
Gift.UpdatePurchase(bot, J, true)
assert(bot.alchemistGiftPending and #bot.purchaseListInReverseOrder == 1)
off.scepter = true
assert(Gift.GetTarget(bot, J) == nil, 'do not gift supports or duplicate existing upgrades')
print('Alchemist Scepter gift scenarios passed')
