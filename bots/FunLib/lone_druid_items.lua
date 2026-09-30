local X = {}

local function expand(name, recipes, out)
    if recipes[name] then
        for _, component in ipairs(recipes[name]) do expand(component, recipes, out) end
    else
        out[#out + 1] = name
    end
end

local function recipeNames(name, recipes, out)
    out[name] = true
    for _, component in ipairs(recipes[name] or {}) do recipeNames(component, recipes, out) end
end

function X.BasicItems(name, recipes)
    local out = {}
    expand(name, recipes, out)
    return out
end

local function contains(unit, name)
    if unit == nil or unit:IsNull() then return false end
    for slot = 0, 14 do
        local item = unit:GetItemInSlot(slot)
        if item and item:GetName() == name then return true end
    end
    return false
end

function X.BearTarget(policy, name)
    return policy ~= nil and policy.bearItems[name] == true
end

function X.Complete(hero, bear, policy, name)
    if X.BearTarget(policy, name) then
        return contains(bear, name) or (name == 'item_ultimate_scepter' and bear ~= nil
            and not bear:IsNull() and bear:HasScepter())
    end
    if name == 'item_double_branches' then
        local count = 0
        for slot = 0, 14 do
            local item = hero:GetItemInSlot(slot)
            if item and item:GetName() == 'item_branches' then count = count + 1 end
        end
        return count >= hero.loneDruidOpeningBranches
    end
    return contains(hero, name)
end

function X.OwnedCount(hero, bear, policy, target, name, recipes, dropped)
    local count = 0
    local needed = {}
    recipeNames(target, recipes, needed)
    local function add(item)
        if not needed[item:GetName()] then return end
        for _, component in ipairs(X.BasicItems(item:GetName(), recipes)) do
            if component == name then count = count + 1 end
        end
    end
    for _, unit in ipairs({hero, bear}) do
        if unit ~= nil and not unit:IsNull() then
            for slot = 0, 14 do
                local item = unit:GetItemInSlot(slot)
                if item and (unit == bear or not policy.heroItems[item:GetName()]) then add(item) end
            end
        end
    end
    for _, drop in pairs(dropped or {}) do
        if drop.owner == hero and drop.item and X.IsBearDrop(hero, drop.item) then add(drop.item) end
    end
    return count
end

function X.IsBearDrop(hero, item)
    return hero.loneDruidTransfers ~= nil and hero.loneDruidTransfers[item] == true
end

function X.MissingItems(hero, bear, policy, target, recipes, dropped)
    local missing, used = {}, {}
    for _, name in ipairs(X.BasicItems(target, recipes)) do
        used[name] = (used[name] or 0) + 1
        if used[name] > X.OwnedCount(hero, bear, policy, target, name, recipes, dropped) then
            missing[#missing + 1] = name
        end
    end
    return missing
end

function X.Transfer(hero, bear, policy, recipes, dropped)
    if policy == nil or bear == nil or bear:IsNull() or not hero:IsAlive() or not bear:IsAlive()
        or hero:IsChanneling() or hero:IsUsingAbility() or bear:IsChanneling() or bear:IsUsingAbility()
        or #hero:GetNearbyHeroes(1000, true, BOT_MODE_NONE) > 0
        or #bear:GetNearbyHeroes(1000, true, BOT_MODE_NONE) > 0 then return false end
    hero.loneDruidTransfers = hero.loneDruidTransfers or {}
    for slot = 0, 5 do
        local starter = bear:GetItemInSlot(slot)
        if starter and starter:GetName() == 'item_blight_stone' then
            for backpack = 6, 8 do
                local upgrade = bear:GetItemInSlot(backpack)
                if upgrade and policy.bearItems[upgrade:GetName()] then
                    bear:ActionImmediate_SwapItems(slot, backpack)
                    return true
                end
            end
        end
    end
    if contains(bear, 'item_silver_edge') and (bear:DistanceFromFountain() <= 100
        or bear:DistanceFromSecretShop() <= 100) then
        for slot = 0, 8 do
            local item = bear:GetItemInSlot(slot)
            if item and item:GetName() == 'item_blight_stone' then
                bear:ActionImmediate_SellItem(item)
                return true
            end
        end
    end
    for _, drop in pairs(dropped or {}) do
        if drop.owner == hero and drop.item and X.IsBearDrop(hero, drop.item) then
            local distance = GetUnitToLocationDistance(bear, drop.location)
            if distance <= 100 then bear:Action_PickUpItem(drop.item); return true end
            if distance < 1000 then bear:Action_MoveToLocation(drop.location); return true end
        end
    end
    local empty = false
    for slot = 0, 8 do if bear:GetItemInSlot(slot) == nil then empty = true end end
    if not empty or GetUnitToUnitDistance(hero, bear) >= 400 then return false end
    local target = hero.currBuyingItemInPurchaseList
    local components = {}
    if X.BearTarget(policy, target) then
        for _, base in ipairs(recipes[target] or {}) do
            if recipes[base] and contains(bear, base) then recipeNames(target, recipes, components); break end
        end
    end
    for slot = 0, 8 do
        local item = hero:GetItemInSlot(slot)
        if item then
            local name = item:GetName()
            if policy.bearItems[name] or (components[name] and not policy.heroItems[name]) then
                hero.loneDruidTransfers[item] = true
                hero:Action_DropItem(item, bear:GetLocation())
                return true
            end
        end
    end
    return false
end

function X.UseItems(bear, target, retreating)
    if not bear:IsAlive() or bear:IsChanneling() or bear:IsUsingAbility() then return false end
    local enemies = bear:GetNearbyHeroes(800, true, BOT_MODE_NONE)
    for slot = 0, 5 do
        local item = bear:GetItemInSlot(slot)
        if item and item:IsFullyCastable() then
            local name = item:GetName()
            if name == 'item_black_king_bar' and #enemies > 0 and bear:WasRecentlyDamagedByAnyHero(2)
                and not bear:IsMagicImmune() then
                bear:Action_UseAbility(item); return true
            elseif name == 'item_mjollnir' and #enemies > 0 and bear:GetAttackTarget() ~= nil then
                bear:Action_UseAbilityOnEntity(item, bear); return true
            elseif (name == 'item_invis_sword' or name == 'item_silver_edge') and not bear:IsInvisible()
                and ((retreating and #enemies > 0) or (target and not target:IsNull() and target:IsHero()
                    and target:GetTeam() ~= bear:GetTeam() and GetUnitToUnitDistance(bear, target) > 400
                    and GetUnitToUnitDistance(bear, target) < 1600)) then
                bear:Action_UseAbility(item); return true
            end
        end
    end
    return false
end

return X
