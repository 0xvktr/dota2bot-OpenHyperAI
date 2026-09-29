-- Data-driven validation of every hero migrated to D2PT builds.
-- Discovery: each bots/BotLib/Builds/<hero>.lua is validated; adding a hero needs no test code.
-- Run through `node tests/run-builds.cjs`, which writes .test-tools/build-context.lua
-- (hero list, known item and neutral names, role weights) before starting this script.
local H = dofile('tests/hero_harness.lua')
local ok, CTX = pcall(H.realDofile, '.test-tools/build-context.lua')
if not ok then error('run this through `node tests/run-builds.cjs`: '..tostring(CTX), 0) end
local Pref = H.realDofile('bots/FunLib/hero_build_preferences.lua')

local ROLES = { 'pos_1', 'pos_2', 'pos_3', 'pos_4', 'pos_5' }
-- docs/D2PT_BUILD_UPDATES.md: eligible at >= 50 matches and >= 5% of the hero's role sample;
-- below 20 matches there is too little evidence to migrate at all.
local MIN_ELIGIBLE_MATCHES, MIN_ELIGIBLE_SHARE, MIN_HARD_MATCHES = 50, 0.05, 20

-- Migrated role weight: 30 freshness baseline + D2PT role rating, scaled down for samples under
-- WEIGHT_FULL_SAMPLE matches (see typescript/bots/FunLib/aba_hero_pos_weights.ts).
local WEIGHT_BASELINE, WEIGHT_FULL_SAMPLE = 30, 2000
local function ExpectedWeight(matches, rating)
    local confidence = math.min(1, math.sqrt(matches / WEIGHT_FULL_SAMPLE))
    return math.min(100, math.floor(WEIGHT_BASELINE + rating * confidence + 0.5))
end

local failures, notes = {}, {}
local function fail(hero, role, message)
    failures[#failures + 1] = hero..(role and (' '..role) or '')..': '..message
end
local function note(hero, message) notes[#notes + 1] = hero..': '..message end

local function deepEqual(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= 'table' then return a == b end
    for k, v in pairs(a) do if not deepEqual(v, b[k]) then return false end end
    for k in pairs(b) do if a[k] == nil then return false end end
    return true
end

local function sortedKeys(t)
    local keys = {}
    for k in pairs(t or {}) do keys[#keys + 1] = k end
    table.sort(keys)
    return keys
end

local function indexOf(list, value)
    for i, v in ipairs(list) do if v == value then return i end end
end

------------------------------------------------------------------------------------------
-- Skill and talent progression (heroes are loaded with generic names: A1..A6, T1..T8)
------------------------------------------------------------------------------------------
local ABILITY_PICKS, TALENT_COUNT = 15, 8 -- 3 basics x 4 + ultimate x 3; 4 tiers x 2 talents

local function abilitySlot(name) return tonumber(name:match('^A(%d)$')) end
local function talentTier(name)
    local n = tonumber(name:match('^T(%d)$'))
    return n and math.ceil(n / 2)
end

-- Hero level needed for the next point in `name`, given `taken` earlier points in it.
local function requiredLevel(name, taken)
    local slot = abilitySlot(name)
    if slot == 6 then return 6 * (taken + 1) end
    if slot then return 2 * taken + 1 end
    return 5 * talentTier(name) + 5
end

-- Mirrors AbilityLevelUpComplement: the head of the list is learned once the hero level
-- allows it, and one hero level grants one point. A head that is not yet allowed blocks
-- everything behind it, so a legal build never leaves a learnable ability stuck behind it.
-- The second talent of an already-chosen tier is rejected by the engine and costs no point.
local function checkSkillList(list, label, report)
    for i = 1, ABILITY_PICKS + TALENT_COUNT do
        if list[i] == nil then return report('skill list has no entry at level '..i) end
    end
    if list[ABILITY_PICKS + TALENT_COUNT + 1] ~= nil then
        return report('skill list is longer than '..(ABILITY_PICKS + TALENT_COUNT)..' entries')
    end

    local counts, abilityTotal = {}, 0
    for i, name in ipairs(list) do
        counts[name] = (counts[name] or 0) + 1
        local slot = abilitySlot(name)
        if slot then
            if slot ~= 1 and slot ~= 2 and slot ~= 3 and slot ~= 6 then
                return report('level '..i..' levels ability slot '..slot..' (innate/hidden slots cannot be leveled)')
            end
            abilityTotal = abilityTotal + 1
        elseif not talentTier(name) then
            return report('level '..i..' has unexpected entry '..tostring(name))
        end
    end
    for slot = 1, 3 do
        if (counts['A'..slot] or 0) > 4 then return report('A'..slot..' is leveled more than 4 times') end
    end
    if counts.A6 ~= 3 then return report('the ultimate must be leveled exactly 3 times, found '..tostring(counts.A6)) end
    if abilityTotal ~= ABILITY_PICKS then
        return report('expected '..ABILITY_PICKS..' ability points, found '..abilityTotal)
    end
    for n = 1, TALENT_COUNT do
        if counts['T'..n] ~= 1 then return report('talent T'..n..' must appear exactly once') end
    end

    -- Talents first appear in tier order, then the unchosen alternatives in tier order.
    local order = {}
    for _, name in ipairs(list) do
        local tier = talentTier(name)
        if tier then order[#order + 1] = tier end
    end
    for k = 1, TALENT_COUNT do
        local wanted = (k - 1) % 4 + 1
        if order[k] ~= wanted then
            return report('talent picks must go tier 1-4 (then the alternatives); pick '..k..' is tier '..tostring(order[k]))
        end
    end

    local queue, taken, tierTaken, points = {}, {}, {}, 0
    for i, name in ipairs(list) do queue[i] = name end
    for level = 1, 30 do
        points = points + 1
        while queue[1] do
            local head = queue[1]
            local tier = talentTier(head)
            if tier and tierTaken[tier] then
                table.remove(queue, 1)
            elseif points > 0 and requiredLevel(head, taken[head] or 0) <= level then
                table.remove(queue, 1)
                points = points - 1
                taken[head] = (taken[head] or 0) + 1
                if tier then tierTaken[tier] = true end
            else
                break
            end
        end
        if points > 0 and queue[1] then
            local pending = {}
            for j, name in ipairs(queue) do
                if j > 1 and abilitySlot(name) then
                    local held = (taken[name] or 0) + (pending[name] or 0)
                    if requiredLevel(name, held) <= level then
                        return report(string.format('at hero level %d %s (needs level %d) blocks %s, which could be learned now',
                            level, queue[1], requiredLevel(queue[1], taken[queue[1]] or 0), name))
                    end
                    pending[name] = (pending[name] or 0) + 1
                end
            end
        end
        if level == 25 then
            for tier = 1, 4 do
                if not tierTaken[tier] then return report('the tier '..tier..' talent is not learned by level 25') end
            end
            if #queue > 0 and abilitySlot(queue[1] or '') then
                return report('ability points are still unspent at level 25 (next: '..queue[1]..')')
            end
        end
    end
end

------------------------------------------------------------------------------------------
-- Item lists
------------------------------------------------------------------------------------------
-- Items a build may legitimately buy more than once (consumables, wards, stackable starters).
local REPEATABLE = {
    item_tango = true, item_branches = true, item_faerie_fire = true, item_flask = true,
    item_clarity = true, item_enchanted_mango = true, item_ward_observer = true,
    item_ward_sentry = true, item_ward_dispenser = true, item_smoke_of_deceit = true,
    item_dust = true, item_gem = true, item_blood_grenade = true, item_double_branches = true,
    item_infused_raindrop = true, item_tpscroll = true, item_wraith_band = true,
    item_bracer = true, item_null_talisman = true, item_magic_stick = true, item_circlet = true,
}
-- Upgrade chains: the base must be bought before its upgrade when a build contains both.
-- Only well-established recipes belong here; the engine's recipe API stays the authority.
local UPGRADES = {
    item_blink = { 'item_overwhelming_blink', 'item_swift_blink', 'item_arcane_blink' },
    item_orchid = { 'item_bloodthorn' },
    item_basher = { 'item_abyssal_blade' },
    item_force_staff = { 'item_hurricane_pike' },
    item_dragon_lance = { 'item_hurricane_pike' },
    item_cyclone = { 'item_wind_waker' },
    item_mekansm = { 'item_guardian_greaves' },
    item_arcane_boots = { 'item_guardian_greaves' },
    item_ancient_janggo = { 'item_boots_of_bearing' },
    item_maelstrom = { 'item_mjollnir' },
    item_rod_of_atos = { 'item_gungir' },
    item_travel_boots = { 'item_travel_boots_2' },
    item_diffusal_blade = { 'item_disperser' },
    item_urn_of_shadows = { 'item_spirit_vessel' },
    item_yasha = { 'item_manta', 'item_sange_and_yasha' },
    item_sange = { 'item_sange_and_yasha' },
    item_boots = { 'item_tranquil_boots', 'item_phase_boots', 'item_power_treads', 'item_arcane_boots' },
    item_ultimate_scepter = { 'item_ultimate_scepter_2' },
}

-- Starting components need a consumer in the same list, or they sit in the inventory as dead weight
-- (a full inventory then pushes real items into the inactive backpack). Consumers are derived from
-- Valve's recipes (items.txt, transitive), plus this library's item_double_* macros.
local function withMacros(list)
    local out = {}
    for _, name in ipairs(list) do
        out[#out + 1] = name
        out[#out + 1] = name:gsub('^item_', 'item_double_')
    end
    return out
end
local BRANCH_USERS = { 'item_magic_wand', 'item_holy_locket' }
local CIRCLET_USERS = withMacros({ 'item_bracer', 'item_essence_distiller', 'item_null_talisman', 'item_spirit_vessel',
    'item_urn_of_shadows', 'item_wraith_band' })
local GAUNTLET_USERS = withMacros({ 'item_bracer', 'item_soul_ring' })
local SLIPPER_USERS = withMacros({ 'item_wraith_band' })
local MANTLE_USERS = withMacros({ 'item_null_talisman' })
local CONSUMERS = {
    item_branches = BRANCH_USERS, item_double_branches = BRANCH_USERS,
    item_magic_stick = BRANCH_USERS,
    item_circlet = CIRCLET_USERS, item_double_circlet = CIRCLET_USERS,
    item_gauntlets = GAUNTLET_USERS, item_double_gauntlets = GAUNTLET_USERS,
    item_slippers = SLIPPER_USERS, item_double_slippers = SLIPPER_USERS,
    item_mantle = MANTLE_USERS, item_double_mantle = MANTLE_USERS,
}
-- Wards are a support purchase: cores never place them.
local SUPPORT_ONLY = { item_ward_observer = true, item_ward_sentry = true, item_ward_dispenser = true }

local function checkStartingItems(list, pos, report, note)
    local present = {}
    for _, name in ipairs(list) do present[name] = true end
    for _, name in ipairs(list) do
        local users = CONSUMERS[name]
        if users then
            local used = false
            for _, u in ipairs(users) do if present[u] then used = true end end
            -- Early attributes are a fine reason to buy them; the inventory upkeep sells them after minute 8.
            if not used then note('sBuyList buys '..name..' with no consumer in the list (sold by the inventory upkeep)') end
        end
        if SUPPORT_ONLY[name] and pos ~= 'pos_4' and pos ~= 'pos_5' then
            report('sBuyList buys '..name..' for a core role (wards are a support purchase)')
        end
    end
end

-- Real items the game does not sell directly (Valve items.txt: ItemPurchasable 0): they only exist as the
-- combination of other purchasable items, so buying the name fails.
local NOT_PURCHASABLE = {
    item_ward_dispenser = 'buy item_ward_observer and item_ward_sentry; they combine into the dispenser',
}

local function checkItems(list, label, report, allowDuplicates)
    if #list == 0 then return report(label..' is empty') end
    local seen = {}
    for i, name in ipairs(list) do
        if type(name) == 'string' and NOT_PURCHASABLE[name] then
            report(label..' lists '..name..', which cannot be bought directly: '..NOT_PURCHASABLE[name])
        elseif type(name) ~= 'string' or not CTX.items[name] then
            report(label..' has unknown item '..tostring(name)..' at index '..i)
        elseif seen[name] and not REPEATABLE[name] and not allowDuplicates then
            report(label..' buys '..name..' twice (indexes '..seen[name]..' and '..i..')')
        end
        seen[name] = seen[name] or i
    end
    for base, upgrades in pairs(UPGRADES) do
        for _, upgrade in ipairs(upgrades) do
            if seen[base] and seen[upgrade] and seen[base] > seen[upgrade] then
                report(label..' buys '..upgrade..' before its base item '..base)
            end
        end
    end
end

------------------------------------------------------------------------------------------
-- Neutral preferences: data shape, then Select() behavior on the real data
------------------------------------------------------------------------------------------
local function checkNeutralData(meta, role, data, report)
    local profile = data.tier5Profile
    if profile ~= nil and Pref.tier5Profiles[profile] == nil then
        report('unknown tier5Profile '..tostring(profile))
    end
    for _, kind in ipairs({ 'neutral', 'enhancement' }) do
        local tiers = data[kind]
        if type(tiers) ~= 'table' then
            report('missing '..kind..' data')
        else
            for tier, picks in pairs(tiers) do
                if type(tier) ~= 'number' or tier < 1 or tier > 5 or tier ~= math.floor(tier) then
                    report(kind..' has invalid tier key '..tostring(tier))
                elseif tier == 5 and profile == nil then
                    report('tier 5 '..kind..' data needs a tier5Profile (reviewed fallback)')
                else
                    local sum = 0
                    for name, pct in pairs(picks) do
                        local known = kind == 'neutral' and CTX.neutralTiers[name] or CTX.enhancementTiers[name]
                        if type(pct) ~= 'number' or pct <= 0 or pct > 100 then
                            report(kind..' tier '..tier..' '..name..' has invalid pick rate '..tostring(pct))
                        else
                            sum = sum + pct
                        end
                        if known == nil then
                            report(kind..' tier '..tier..' has unknown item '..name)
                        elseif not known[tier] then
                            report(kind..' tier '..tier..' lists '..name..', which does not exist in that tier (retained lower-tier item?)')
                        end
                    end
                    if sum > 100.5 then report(kind..' tier '..tier..' pick rates sum to '..sum) end
                end
            end
        end
    end
end

local function checkSelect(unit, role, data, report)
    local roleNumber = tonumber(role:match('%d'))
    local bot = { GetUnitName = function() return unit end, stats = { role = roleNumber } }
    local profile = data.tier5Profile and Pref.tier5Profiles[data.tier5Profile]
    for _, kind in ipairs({ 'neutral', 'enhancement' }) do
        for tier = 1, 5 do
            local picks = data[kind] and data[kind][tier]
            local ranked = tier == 5 and profile and profile[kind]
            local label = kind..' tier '..tier
            local observed = sortedKeys(picks)
            local function pickOf(name) return picks and picks[name] or 0 end

            if ranked then
                local fit = {}
                for i, name in ipairs(ranked) do fit[name] = #ranked - i + 1 end
                local candidates = {}
                for _, name in ipairs(observed) do candidates[#candidates + 1] = name end
                for _, name in ipairs(ranked) do
                    if not picks or not picks[name] then candidates[#candidates + 1] = name end
                end
                local best, bestPick, bestFit = nil, -1, -1
                for _, name in ipairs(candidates) do
                    if fit[name] and (pickOf(name) > bestPick or (pickOf(name) == bestPick and fit[name] > bestFit)) then
                        best, bestPick, bestFit = name, pickOf(name), fit[name]
                    end
                end
                local got = Pref.Select(bot, kind, tier, candidates)
                if got ~= best then
                    report(label..': Select returned '..tostring(got)..', expected the most-picked reviewed item '..tostring(best))
                end
                if Pref.Select(bot, kind, tier, { 'item_unknown' }) ~= nil then
                    report(label..': an unreviewed offer must fall through to the consumer fallback')
                end
            elseif picks and next(picks) then
                local top = 0
                for _, name in ipairs(observed) do top = math.max(top, pickOf(name)) end
                local candidates = { 'item_unknown' }
                for _, name in ipairs(observed) do candidates[#candidates + 1] = name end
                local got = Pref.Select(bot, kind, tier, candidates)
                if got == nil or pickOf(got) ~= top then
                    report(label..': Select returned '..tostring(got)..' instead of a top pick ('..top..'%)')
                end
                local reversed = {}
                for i = #candidates, 1, -1 do reversed[#reversed + 1] = candidates[i] end
                local again = Pref.Select(bot, kind, tier, reversed)
                if again == nil or pickOf(again) ~= top then
                    report(label..': the result depends on the order of the offered items')
                end
                if Pref.Select(bot, kind, tier, { 'item_unknown' }) ~= nil then
                    report(label..': an item without D2PT data must not be selected')
                end
            end
        end
    end
end

------------------------------------------------------------------------------------------
-- Per hero
------------------------------------------------------------------------------------------
-- Regression: caster suitability must not discard observed enchantments in favor of an
-- unobserved fallback. Timeless still wins when the most-picked option is offered.
do
    local bot = { assignedRole = 'pos_3', GetUnitName = function() return 'npc_dota_hero_dark_seer' end }
    local function select(candidates) return Pref.Select(bot, 'enhancement', 5, candidates) end
    assert(select({'item_enhancement_fleetfooted', 'item_enhancement_vampiric', 'item_enhancement_feverish'})
        == 'item_enhancement_feverish', 'Dark Seer must prefer observed Feverish over the fallback')
    assert(select({'item_enhancement_vampiric', 'item_enhancement_fleetfooted'})
        == 'item_enhancement_vampiric', 'Dark Seer must retain Vampiric as an observed alternative')
    assert(select({'item_enhancement_feverish', 'item_enhancement_timeless'})
        == 'item_enhancement_timeless', 'Dark Seer must still prefer his most-picked enchantment')
    bot.assignedRole = 'pos_2'
    bot.GetUnitName = function() return 'npc_dota_hero_crystal_maiden' end
    assert(select({'item_enhancement_fleetfooted', 'item_enhancement_vampiric'})
        == 'item_enhancement_vampiric', 'Maiden mid must retain her observed Vampiric alternative')
    assert(select({'item_enhancement_unknown'}) == nil, 'unreviewed offers must retain the consumer fallback')
end

local roleCount, heroCount = 0, 0
local summary = {}

for _, hero in ipairs(CTX.heroes) do
    heroCount = heroCount + 1
    local name, unit = hero.name, hero.unit
    local function heroFail(role, message) fail(name, role, message) end
    local meta = require('bots.BotLib.Builds.'..name)
    local weights = CTX.weights[unit]

    if type(meta.patch) ~= 'string' or not meta.patch:match('^%d+%.%d+%a?$') then
        heroFail(nil, 'patch must look like 7.41f, found '..tostring(meta.patch))
    end
    if type(meta.updated) ~= 'string' or not meta.updated:match('^%d%d%d%d%-%d%d%-%d%d$') then
        heroFail(nil, 'updated must be a YYYY-MM-DD date, found '..tostring(meta.updated))
    end
    if not hero.annotated then
        heroFail(nil, 'hero_'..name..'.lua must mention '..tostring(meta.patch)..' (annotate migrated builds with the patch)')
    end
    if weights == nil then
        heroFail(nil, 'no entry in aba_hero_pos_weights for '..unit)
        weights = { 0, 0, 0, 0, 0 }
    end

    -- Roles: eligibility rule and weights.
    local total = 0
    for _, pos in ipairs(ROLES) do
        local r = meta.roles and meta.roles[pos]
        if type(r) ~= 'table' or type(r.matches) ~= 'number' or type(r.winRate) ~= 'number' then
            heroFail(pos, 'needs numeric matches and winRate')
        else
            total = total + r.matches
        end
    end
    local migrated = {}
    local roleLine = {}
    for i, pos in ipairs(ROLES) do
        local r = meta.roles and meta.roles[pos]
        if type(r) == 'table' and type(r.matches) == 'number' and total > 0 then
            local share = r.matches / total
            local weight = weights[i]
            if r.skipped then
                if weight ~= 0 then heroFail(pos, 'is skipped but has weight '..tostring(weight)..' (must be 0)') end
                if r.weight ~= nil then heroFail(pos, 'is skipped but records weight '..tostring(r.weight)) end
                if r.matches >= MIN_ELIGIBLE_MATCHES and share >= MIN_ELIGIBLE_SHARE then
                    note(name, string.format('%s skipped although eligible (%d matches, %.0f%% of the hero)', pos, r.matches, share * 100))
                end
                roleLine[i] = '-'
            else
                migrated[pos] = true
                roleCount = roleCount + 1
                if type(r.weight) ~= 'number' then
                    heroFail(pos, 'migrated role must record its weight')
                elseif r.weight ~= weight then
                    heroFail(pos, 'weight '..tostring(r.weight)..' in Builds differs from aba_hero_pos_weights ('..tostring(weight)..')')
                end
                if type(r.rating) ~= 'number' then
                    heroFail(pos, 'migrated role must record its D2PT role rating')
                elseif type(r.weight) == 'number' and r.weight ~= ExpectedWeight(r.matches, r.rating) then
                    heroFail(pos, string.format('weight %s does not follow the formula: %d matches, rating %s -> %d',
                        tostring(r.weight), r.matches, tostring(r.rating), ExpectedWeight(r.matches, r.rating)))
                end
                if type(weight) ~= 'number' or weight < 1 or weight > 100 then
                    heroFail(pos, 'migrated role needs a weight of 1-100, found '..tostring(weight))
                end
                if r.matches < MIN_HARD_MATCHES then
                    heroFail(pos, 'only '..r.matches..' matches: too little evidence to migrate (minimum '..MIN_HARD_MATCHES..')')
                elseif r.matches < MIN_ELIGIBLE_MATCHES or share < MIN_ELIGIBLE_SHARE then
                    note(name, string.format('%s migrated below the eligibility rule (%d matches, %.1f%% of the hero): needs manual review',
                        pos, r.matches, share * 100))
                end
                roleLine[i] = tostring(weight)
            end
        end
    end
    if not migrated[meta.defaultRole or ''] then
        heroFail(nil, 'defaultRole '..tostring(meta.defaultRole)..' must be a migrated role')
    end
    for pos in pairs(meta.neutrals or {}) do
        if not migrated[pos] then heroFail(pos, 'has neutral data although the role is not migrated') end
    end

    -- Registration: the neutral consumers find this hero's data only through the registry.
    local primary = tonumber((meta.defaultRole or 'pos_0'):match('%d'))
    local registered = Pref.Get({ GetUnitName = function() return unit end, stats = { role = primary } })
    local isRegistered = registered ~= nil and deepEqual(registered, (meta.neutrals or {})[meta.defaultRole])
    if not isRegistered then
        heroFail(nil, 'is not registered in FunLib/hero_build_preferences.lua (or its data differs)')
    end

    for _, pos in ipairs(ROLES) do
        local function report(message) heroFail(pos, message) end
        local ok, built = pcall(H.load, unit, pos)
        if not ok then
            report(tostring(built))
        else
            checkItems(built.sBuyList or {}, 'sBuyList', report)
            if migrated[pos] then
                checkStartingItems(built.sBuyList or {}, pos, report, function(message) note(name, pos..': '..message) end)
            end
            -- sSellList holds (new item, old item to sell) pairs (SetPairedItems); chains may repeat an item.
            local sells = built.sSellList or {}
            if #sells > 0 then checkItems(sells, 'sSellList', report, true) end
            if #sells % 2 ~= 0 then report('sSellList must hold (new item, old item) pairs') end
            for i = 2, #sells, 2 do
                if sells[i - 1] == sells[i] then report('sSellList pair '..(i / 2)..' sells '..sells[i]..' for itself') end
            end
            if not migrated[pos] then
                local r = meta.roles and meta.roles[pos]
                if not built.buildMetadata or not built.buildMetadata.roles[pos].skipped then
                    report('fallback build must expose buildMetadata marking the role skipped')
                end
                if built.neutralPreferences ~= nil then report('skipped role must not carry neutral preferences') end
                if Pref.Get({ GetUnitName = function() return unit end, stats = { role = tonumber(pos:match('%d')) } }) ~= nil then
                    report('skipped role must fall back to the legacy neutral selection')
                end
            else
                local data = (meta.neutrals or {})[pos]
                if data == nil then
                    report('migrated role has no neutral data')
                else
                    if not deepEqual(built.neutralPreferences, data) then report('neutralPreferences differ from Builds data') end
                    checkNeutralData(meta, pos, data, report)
                    -- Without a registration every Select() check would fail for the same reason.
                    if isRegistered then checkSelect(unit, pos, data, report) end
                end
                checkSkillList(built.sSkillList or {}, 'default', function(message) report('default skill list: '..message) end)
                local okCustom, custom = pcall(H.load, unit, pos, { custom = true })
                if not okCustom then
                    report(tostring(custom))
                else
                    checkSkillList(custom.sSkillList or {}, 'custom', function(message) report('custom skill list: '..message) end)
                    if not H.talents or not (custom.sSkillList and indexOf(H.talents, custom.sSkillList[10])) then
                        report('a user-supplied ability build must keep the standard layout (talent at level 10)')
                    end
                end
            end
        end
    end

    summary[#summary + 1] = string.format('%-26s %-6s  weights: %s', name, tostring(meta.patch),
        table.concat({ roleLine[1] or '?', roleLine[2] or '?', roleLine[3] or '?', roleLine[4] or '?', roleLine[5] or '?' }, ' / '))
end

-- Every registered build must have a Builds file (the registry requires it at load time), and
-- every Builds file must be registered; the per-hero registration check above covers the latter.

for _, line in ipairs(summary) do print(line) end
for _, line in ipairs(notes) do print('note: '..line) end
if #failures > 0 then
    for _, line in ipairs(failures) do print('FAIL '..line) end
    error(#failures..' build validation failure(s)', 0)
end
print(string.format('Build validation passed: %d heroes, %d migrated roles', heroCount, roleCount))
