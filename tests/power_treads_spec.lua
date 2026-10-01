package.path = './?.lua;'..package.path
ATTRIBUTE_STRENGTH = 0; ATTRIBUTE_AGILITY = 1; ATTRIBUTE_INTELLECT = 2
BOT_MODE_NONE = 0; BOT_MODE_RETREAT = 1; BOT_MODE_EVASIVE_MANEUVERS = 2; BOT_MODE_ATTACK = 3
BOT_MODE_DESIRE_MODERATE = 0.5; BOT_ACTION_DESIRE_HIGH = 0.8
BOT_ACTION_DESIRE_NONE = 0
local now = 100
function DotaTime() return now end
local P = require('bots/FunLib/power_treads')
local bot = {}
local function item(name, manaCost)
    local h = { name = name, raw = 0, active = true, manaCost = manaCost or 0 }
    function h:GetName() return self.name end
    function h:GetPowerTreadsStat() return self.raw end
    function h:IsFullyCastable() return self.active end
    function h:GetManaCost() return self.manaCost end
    return h
end
local treads = item('item_power_treads')
function bot:GetItemInSlot(slot) return self.slots[slot] end
function bot:IsAlive() return not self.dead end
for method, field in pairs({ IsMuted='muted', IsStunned='stunned', IsHexed='hexed', IsInvisible='invisible',
    IsNightmared='nightmared', IsChanneling='channeling', IsCastingAbility='casting', IsUsingAbility='using',
    IsSilenced='silenced', IsInvulnerable='invulnerable' }) do
    bot[method] = function(self) return self[field] == true end
end
function bot:HasModifier(name) return self.mods[name] == true end
function bot:GetUnitName() return self.name end
function bot:GetPrimaryAttribute() return self.primary end
function bot:GetMaxHealth() return 1000 + (treads.raw == 0 and 220 or 0) end
function bot:GetHealth() return self.hp * self:GetMaxHealth() end
function bot:GetMaxMana() return 600 + (treads.raw == 1 and 120 or 0) end
function bot:GetMana() return self.mp * self:GetMaxMana() end
function bot:GetActiveMode() return self.mode end
function bot:GetActiveModeDesire() return self.desire end
function bot:GetNearbyTowers() return {} end
function bot:WasRecentlyDamagedByAnyHero() return self.heroDamage end
function bot:WasRecentlyDamagedByTower() return self.towerDamage end
function bot:NumQueuedActions() return #self.queue end
function bot:Action_ClearActions()
    self.clears = self.clears + 1
    self.queue = {}
end
local function apply(action)
    local h, target = action.item, action.target
    if h == treads then treads.raw = (treads.raw + 1) % 3; return end
    bot.mp = math.max(0, bot:GetMana() - h:GetManaCost()) / bot:GetMaxMana()
    if h.restoreMana and (not target or target == bot) then
        bot.mp = math.min(1, bot.mp + h.restoreMana / bot:GetMaxMana())
    end
    if h.restoreHealth and (not target or target == bot) then
        bot.hp = math.min(1, bot.hp + h.restoreHealth / bot:GetMaxHealth())
    end
    if h.channel then bot.channeling = true end
end
for suffix, kind in pairs({ ['']='none', OnEntity='unit', OnLocation='ground', OnTree='tree' }) do
    bot['ActionQueue_UseAbility'..suffix] = function(self, h, target)
        local action = { item=h, target=target, kind=kind, queued=true }
        table.insert(self.actions, action)
        table.insert(self.queue, action)
    end
    bot['Action_UseAbility'..suffix] = function(self, h, target)
        self.queue = {} -- immediate use replaces queued preparation, as in the engine
        local action = { item=h, target=target, kind=kind, queued=false }
        table.insert(self.actions, action)
        apply(action)
    end
end
local function execute()
    while #bot.queue > 0 do
        assert(P.Consider(bot, treads, J) == 0, 'idle logic must not overwrite the pending cast')
        apply(table.remove(bot.queue, 1))
    end
end
local function reset(raw, primary)
    now = now + 10
    for k in pairs(bot) do if type(bot[k]) ~= 'function' then bot[k] = nil end end
    bot.slots = { [0]=treads }; bot.actions = {}; bot.queue = {}; bot.mods = {}
    bot.name = 'npc_dota_hero_antimage'; bot.primary = primary or ATTRIBUTE_AGILITY
    bot.mode = BOT_MODE_NONE; bot.desire = 0; bot.hp = 0.6; bot.mp = 0.5; bot.clears = 0
    treads.raw = raw or 0; treads.active = true
end
J = {
    IsNotAttackProjectileIncoming = function() return bot.projectile == true end,
    GetNearbyHeroes = function() return bot.enemies or {} end,
    IsItemAvailable = function(name)
        for _, h in pairs(bot.slots) do if h:GetName() == name then return h end end
    end,
    GetEnemyCount = function() return 0 end,
    GetHP = function() return bot.hp end, GetMP = function() return bot.mp end,
    CanCastAbility = function(h) return h ~= nil and h:IsFullyCastable() end,
    GetProperTarget = function() return nil end,
}
local allowTP, recordedTP = true, 0
local FightResponse = {
    CanTeleportTo = function() return allowTP end,
    RecordTeleport = function() recordedTP = recordedTP + 1 end,
}
local X = dofile('.test-tools/power-treads-hooks.lua')(bot, J, P, FightResponse, {
    inventory = { SwapInBackpackConsumable=function() return false end },
    scepter = { Prepare=function() end }, lotus = { Prepare=function() end },
    boss = { ItemDesire=function() return 0 end },
})
X.SetStashItemTimeUpdate = function() end
X.WillBreakInvisible = function() return false end
X.IsItemInStash = function() return false end
local function near(a, b) assert(math.abs(a - b) < 0.001, tostring(a)..' ~= '..tostring(b)) end
local function idle()
    now = now + 1
    local desire, target, castType = P.Consider(bot, treads, J)
    if desire > 0 then X.SetUseItem(treads, target, castType); execute() end
end

-- All nine transitions must reach the intended real attribute in <=2 uses.
local desiredRaw = { [ATTRIBUTE_STRENGTH]=0, [ATTRIBUTE_INTELLECT]=1, [ATTRIBUTE_AGILITY]=2 }
for raw = 0, 2 do
    for attribute, expected in pairs(desiredRaw) do
        reset(raw)
        local count = P.Queue(bot, attribute)
        assert(count <= 2 and #bot.queue == count)
        execute()
        assert(treads.raw == expected and P.Stat(treads) == attribute, 'attribute enum/order regression')
    end
end

-- 300/600 -> INT 360/720 -> cast 100 -> AGI 216.667/600.
reset(0)
local spell = item('antimage_blink', 100)
J.SetQueuePtToINT(bot, false)
bot:ActionQueue_UseAbilityOnLocation(spell, {x=10,y=20})
assert(bot.clears == 1 and #bot.queue == 2 and bot.queue[1].item == treads)
execute()
near(bot:GetMana(), 260)
assert(P.Consider(bot, treads, J) == 0, 'cast settling window must hold INT')
idle()
assert(treads.raw == 2)
near(bot:GetMana(), 216.666667)

-- Wand on INT: switch before restoring, then recover INT at idle: 480/720.
reset(1, ATTRIBUTE_INTELLECT)
local wand = item('item_magic_wand'); wand.restoreMana = 100; wand.restoreHealth = 150
X.SetUseItem(wand, nil, 'none')
assert(#bot.queue == 2 and bot.queue[2].item == wand and bot.queue[2].queued)
execute(); near(bot:GetMana(), 400)
idle(); near(bot:GetMana(), 480)

-- Self Bottle/Lotus and tree Tango retain the selected target after preparation.
for _, name in ipairs({'item_bottle', 'item_enchanted_mango', 'item_famango', 'item_great_famango',
    'item_greater_famango', 'item_flask', 'item_clarity'}) do
    reset(0)
    local h = item(name)
    X.SetUseItem(h, bot, 'unit')
    assert(#bot.queue == 3 and bot.queue[3].target == bot and bot.queue[3].item == h)
    execute(); assert(treads.raw == 2)
end
reset(0)
X.SetUseItem(item('item_tango'), 42, 'tree')
assert(#bot.queue == 3 and bot.queue[3].kind == 'tree' and bot.queue[3].target == 42)
execute()
reset(0)
local ally = { IsChanneling=function() return false end, IsCastingAbility=function() return false end }
X.SetUseItem(item('item_famango'), ally, 'unit')
assert(#bot.actions == 1 and not bot.actions[1].queued and bot.actions[1].target == ally)
reset(0)
X.SetUseItem(item('item_tango'), ally, 'unit')
assert(#bot.actions == 1 and treads.raw == 0, 'Tango sharing must not prepare self restoration')

-- Non-restoring mana items retain unit/ground/tree targeting too.
for _, castType in ipairs({'none', 'unit', 'ground', 'tree'}) do
    reset(2)
    local target = castType == 'unit' and ally or castType == 'tree' and 42 or {x=10,y=20}
    if castType == 'none' then target = nil end
    local h = item('item_test_mana', 100)
    X.SetUseItem(h, target, castType)
    assert(#bot.queue == 3 and bot.queue[3].kind == castType and bot.queue[3].target == target)
    execute(); assert(treads.raw == 1); near(bot:GetMana(), 260)
end

-- TP has preparation before its channel and no automatic toggle afterwards.
reset(2)
local tp = item('item_tpscroll', 75); tp.channel = true
local destination = {x=100,y=200}
X.SetUseItem(tp, destination, 'ground')
assert(recordedTP == 1 and #bot.queue == 3 and bot.queue[3].target == destination)
execute(); now = now + 2
assert(bot.channeling and P.Consider(bot, treads, J) == 0)
J.SetQueuePtToINT(bot, true)
assert(bot.clears == 0, 'hero helper must not clear a live TP channel')
assert(X.SetUseItem(wand, nil, 'none') == false, 'item executor must preserve a channel')
bot.channeling = false; idle(); assert(treads.raw == 2)
reset(2); allowTP = false
assert(X.SetUseItem(tp, destination, 'ground') == false and #bot.actions == 0 and recordedTP == 1)
allowTP = true

-- Existing channels, cast phases and queues are untouched by every helper.
for _, flag in ipairs({'channeling', 'casting', 'using'}) do
    reset(0); bot[flag] = true
    J.SetQueuePtToINT(bot, true); J.SetQueueSwitchPtToINT(bot)
    assert(bot.clears == 0 and #bot.actions == 0 and P.Consider(bot, treads, J) == 0)
end
reset(0); bot.mods.modifier_teleporting = true
J.SetQueuePtToINT(bot, true); assert(bot.clears == 0 and #bot.actions == 0)
reset(0); bot:ActionQueue_UseAbility(spell)
J.SetQueuePtToINT(bot, true)
assert(bot.clears == 0 and #bot.queue == 1 and bot.queue[1].item == spell)
for _, flag in ipairs({'muted', 'stunned', 'hexed', 'nightmared', 'invisible', 'dead'}) do
    reset(0); bot[flag] = true
    assert(P.Queue(bot, ATTRIBUTE_INTELLECT) == 0 and P.Consider(bot, treads, J) == 0)
end
reset(0); bot.slots = { [6]=treads }
assert(P.Find(bot) == nil and P.Queue(bot, ATTRIBUTE_INTELLECT) == 0 and J.IsPTReady(bot, ATTRIBUTE_INTELLECT))
reset(0); treads.active = false
assert(P.Find(bot) == nil and P.Queue(bot, ATTRIBUTE_INTELLECT) == 0)

-- Danger overrides active restoration; casts and emergency items skip toggles.
for _, danger in ipairs({'heroDamage', 'towerDamage', 'projectile', 'lowHP', 'retreat', 'evasive', 'assassinate'}) do
    reset(2); bot.mods.modifier_clarity_potion = true
    if danger == 'lowHP' then bot.hp = 0.2
    elseif danger == 'retreat' then bot.mode = BOT_MODE_RETREAT; bot.desire = 0.8
    elseif danger == 'evasive' then bot.mode = BOT_MODE_EVASIVE_MANEUVERS
    elseif danger == 'assassinate' then bot.mods.modifier_sniper_assassinate = true
    else bot[danger] = true end
    local desire, target, castType = P.Consider(bot, treads, J)
    assert(desire > 0 and castType == 'none')
    X.SetUseItem(treads, target, castType); execute(); assert(treads.raw == 0)
    bot.actions = {}; J.SetQueuePtToINT(bot, true)
    assert(#bot.actions == 0, 'urgent spell preparation must not add actions')
    X.SetUseItem(wand, nil, 'none')
    assert(#bot.actions == 1 and not bot.actions[1].queued, 'urgent Wand must be immediate')
end
reset(0); bot.enemies = {ally}
X.SetUseItem(wand, nil, 'none'); assert(#bot.actions == 1 and not bot.actions[1].queued)
reset(0); bot.silenced = true
X.SetUseItem(item('item_manta', 125), nil, 'none'); assert(#bot.actions == 1 and not bot.actions[1].queued)
reset(0)
X.SetUseItem(item('item_black_king_bar', 50), nil, 'none'); assert(#bot.actions == 1 and not bot.actions[1].queued)
reset(0)
local channelingEnemy = {IsChanneling=function() return true end, IsCastingAbility=function() return false end}
X.SetUseItem(item('item_sheepstick', 100), channelingEnemy, 'unit')
assert(#bot.actions == 1 and not bot.actions[1].queued, 'interrupts must not wait for Treads')

-- Safe ongoing restoration persists without oscillation; threats briefly latch.
for _, modifier in ipairs({'modifier_flask_healing', 'modifier_clarity_potion', 'modifier_tango_heal',
    'modifier_item_urn_heal', 'modifier_item_spirit_vessel_heal', 'modifier_bottle_regeneration'}) do
    reset(0, ATTRIBUTE_STRENGTH); bot.mods[modifier] = true
    idle(); assert(treads.raw == 2); idle(); assert(P.Consider(bot, treads, J) == 0)
    bot.mods[modifier] = nil; idle(); assert(treads.raw == 0)
end
reset(2); bot.heroDamage = true; idle(); bot.heroDamage = false
now = now + 0.3; assert(P.Consider(bot, treads, J) == 0, 'brief danger latch should hold STR')
idle(); assert(treads.raw == 2)

-- Soul Ring still queues before INT and the spell; it cannot cancel channels.
reset(0)
local ring = item('item_soul_ring'); bot.slots[1] = ring
J.SetQueuePtToINT(bot, true); bot:ActionQueue_UseAbility(spell)
assert(#bot.queue == 3 and bot.queue[1].item == ring and bot.queue[2].item == treads and bot.queue[3].item == spell)
execute()

-- Illusions choose offensive stats, universal heroes choose AGI, Medusa survives on INT.
for _, name in ipairs({'naga_siren_mirror_image', 'terrorblade_conjure_image', 'phantom_lancer_doppelwalk'}) do
    reset(1)
    local illusion = item(name, 100)
    J.SetQueuePtToINT(bot, false, illusion); bot:ActionQueue_UseAbility(illusion)
    execute(); assert(treads.raw == 2)
end
reset(1, ATTRIBUTE_STRENGTH)
J.SetQueuePtToINT(bot, false, item('chaos_knight_phantasm', 125)); execute(); assert(treads.raw == 0)
reset(1)
X.SetUseItem(item('item_manta', 125), nil, 'none'); execute(); assert(treads.raw == 2)
reset(1, 3); idle(); assert(treads.raw == 2 and not J.ShouldSwitchPTStat(bot, treads))
reset(2); bot.name = 'npc_dota_hero_medusa'; bot.heroDamage = true
idle(); assert(treads.raw == 1, 'Medusa should increase her Mana Shield pool under threat')
for _, name in ipairs({'antimage_counterspell', 'antimage_counterspell_ally', 'dazzle_shallow_grave',
    'oracle_false_promise', 'oracle_fates_edict', 'omniknight_guardian_angel', 'omniknight_purification',
    'omniknight_martyr', 'legion_commander_press_the_attack'}) do
    reset(0); bot.slots[1] = ring
    J.SetQueuePtToINT(bot, true, item(name, 50))
    assert(#bot.actions == 0 and treads.raw == 0, 'save spells should skip Treads and Soul Ring preparation')
end
reset(0)
J.SetQueuePtToINT(bot, false, item('zero_mana_spell', 0))
assert(#bot.actions == 0, 'explicit zero-mana casts should not prepare INT')

-- Execute the real item decision loop with Treads in the highest-priority slot.
local useWand = true
X.ConsiderItemDesire = {
    item_power_treads = function(h) return P.Consider(bot, h, J) end,
    item_magic_wand = function() return useWand and BOT_ACTION_DESIRE_HIGH or 0, nil, 'none' end,
}
reset(2); bot.hp = 0.2; bot.heroDamage = true
bot.slots = { [5]=treads, [0]=wand }
X.RunItemThink()
assert(#bot.actions == 1 and bot.actions[1].item == wand and not bot.actions[1].queued,
    'slot order must not put a Treads toggle before emergency restoration')
useWand = false
X.RunItemThink()
assert(#bot.actions == 2 and bot.actions[2].item == treads and treads.raw == 0,
    'idle Treads switching should still execute after other items decline')
reset(0); useWand = true; bot.slots = { [5]=treads, [0]=wand }
X.RunItemThink()
assert(#bot.queue == 3 and bot.queue[3].item == wand, 'safe restoration keeps preparation in the selected action queue')
execute(); assert(treads.raw == 2)
reset(0); bot:ActionQueue_UseAbility(spell)
X.RunItemThink()
assert(#bot.actions == 1 and bot.queue[1].item == spell, 'real item loop must preserve pending casts')

print('Power Treads scenarios passed')
