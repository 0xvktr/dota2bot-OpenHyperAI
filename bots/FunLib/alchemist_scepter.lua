-- Carry-only late-game Scepter gifts. The engine applies Synth and its bonuses.
local X = {}
local scepter = 'item_ultimate_scepter'

local function IsAlchemist(bot)
    return bot:GetUnitName() == 'npc_dota_hero_alchemist'
end

function X.GetTarget(bot, J)
    local best, bestRole = nil, 4
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if ally ~= bot and J.IsValidHero(ally) and ally:IsAlive()
            and not ally:IsIllusion() and ally:GetTeam() == bot:GetTeam()
            and not ally:HasScepter() and ally:FindItemSlot(scepter) < 0
        then
            local role = J.GetPosition(ally)
            if (role == 2 or role == 3) and role < bestRole then
                best, bestRole = ally, role
            end
        end
    end
    return best
end

-- Called by the purchase loop, using its ordinary component/courier machinery.
function X.UpdatePurchase(bot, J, enabled)
    if not IsAlchemist(bot) then return end
    if bot.alchemistGiftPending then
        local target = bot.alchemistGiftCastTarget
        if target ~= nil and not target:IsNull() and target:HasScepter()
            and bot:FindItemSlot(scepter) < 0
            and #bot.purchaseListInReverseOrder == 0
        then
            bot.alchemistGiftPending = nil
            bot.alchemistGiftCastTarget = nil
        end
        return -- Never queue a second Scepter while the first is being delivered/used.
    end
    if not enabled or J.GetPosition(bot) ~= 1 or #bot.purchaseListInReverseOrder > 0
        or bot.currBuyingItemInPurchaseList ~= nil
        or bot:FindItemSlot(scepter) >= 0
        or bot:GetCourierValue() > 0 or bot:GetStashValue() > 0
        or bot:GetGold() < GetItemCost(scepter) + bot:GetBuybackCost()
    then return end
    -- Completion of the queue alone is insufficient if purchases timed out.
    for _, name in ipairs({'item_radiance','item_black_king_bar','item_assault',
        'item_abyssal_blade','item_swift_blink'}) do
        if bot:FindItemSlot(name) < 0 then return end
    end
    if X.GetTarget(bot, J) == nil then return end
    bot.alchemistGiftPending = true
    table.insert(bot.purchaseListInReverseOrder, scepter)
end

local function Safe(bot, J)
    return not J.IsRetreating(bot) and not J.IsGoingOnSomeone(bot)
        and not bot:WasRecentlyDamagedByAnyHero(5)
        and #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) == 0
end

-- This manages the DONOR Alchemist's inventory, never the recipient's.
-- If his newly purchased physical Scepter is in his backpack, equip it to cast
-- Synth. Temporarily swap out his Radiance only while safe, then restore it.
-- The recipient gets a permanent Scepter buff, not an inventory/backpack item.
function X.Prepare(bot, J)
    if not IsAlchemist(bot) then return end
    local swap = bot.alchemistGiftSwap
    local slot = bot:FindItemSlot(scepter)
    if swap and (slot < 0 or not Safe(bot, J)
        or X.GetTarget(bot, J) == nil) then
        local original = bot:GetItemInSlot(swap.backpack)
        if original ~= nil and original:GetName() == swap.name then
            bot:ActionImmediate_SwapItems(swap.main, swap.backpack)
        end
        bot.alchemistGiftSwap = nil
        return
    end
    if not bot.alchemistGiftPending or slot < 6 or slot > 8
        or not Safe(bot, J) or X.GetTarget(bot, J) == nil then return end
    local main = bot:FindItemSlot('item_radiance')
    for i = 0, 5 do
        if bot:GetItemInSlot(i) == nil then main = i; break end
    end
    if main < 0 or main > 5 then return end
    local original = bot:GetItemInSlot(main)
    if original ~= nil then
        bot.alchemistGiftSwap = {main=main,backpack=slot,name=original:GetName()}
    end
    bot:ActionImmediate_SwapItems(slot, main)
end

function X.Consider(bot, item, J)
    if not IsAlchemist(bot) or not bot.alchemistGiftPending
        or not item:IsFullyCastable() or not Safe(bot, J) then return 0 end
    -- Alchemist's Scepter gift is global; no distance or movement requirement.
    local target = X.GetTarget(bot, J)
    if target == nil then return 0 end
    -- This records an attempt, not success. UpdatePurchase waits for the consumed
    -- item and the recipient's Scepter upgrade before allowing another purchase.
    bot.alchemistGiftCastTarget = target
    return BOT_ACTION_DESIRE_HIGH, target, 'unit', 'Gift Scepter to allied core'
end

return X
