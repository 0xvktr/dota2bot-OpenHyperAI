# Small item and spell decisions (TASK-36)

The shared `FunLib/item_cast_policy.lua` policy accompanies the existing
Power Treads preparation in [POWER_TREADS.md](POWER_TREADS.md).

## Mask of Madness

The old hero-name OR predicate always evaluated true. In the presence of an
enemy within 1600, reserve Sniper's Assassinate, Medusa's Stone Gaze, and
Faceless Void's Chronosphere or Time Walk when trained, visible, activated
and off cooldown. Use remaining cooldown rather than base cooldown; low
mana does not make a ready spell expendable. Safe farming without nearby
enemies retains the existing attack-target rules. Drow's explicit disable
remains. Other heroes retain the existing policy.

## Backpack consumables

New swaps require no enemy hero within 1200, no hero/tower/creep damage in
four seconds, and no channel, cast, teleport or pending queue. All boots,
Stick/Wand/Locket, Blink upgrades, common defensive actives and important
special items are protected. Use an empty slot first, otherwise the cheapest
unprotected item. A rejected swap starts no cooldown. Restore a displaced
item after use/cancellation/20-second expiry, including during combat;
rejected restoration remains pending for retry, and another inventory routine's
item is never overwritten. This is a narrow contribution to TASK-30; purchase
capacity, Aegis handling and broader inventory coordination remain separate.

## Mana restoration

Hero code selects a useful cast using its ordinary Consider rules, permitting
evaluation when only mana is missing. It then calls `ItemCastPolicy.Request`
with the ability, original target, cast shape, a decision validator, and `J`.
The request is accepted only when a fully castable item in slots 0–5 can
enable that spell with one use. No usable restoration means other spell
decisions continue. The hero casts after restoration on a subsequent think,
using a fresh decision rather than a saved cast order.

Intent expires after 0.35 seconds and is cleared at the next hero evaluation.
Before spending an item, check training, hidden/passive/activation state,
remaining cooldown, mode, live target/range and spell protection, the original
decision, and action locks. Unit intent must target a hero. Mango restores
100 mana; Stick/Wand restore 15 per charge, capped by the current maximum
mana. Restoration must bridge the actual deficit. Low mana alone no longer
spends these items; Stick/Wand retain their health-based emergency and
overflow healing branches, and Holy Locket retains its separate healing path.

Soul Ring uses its live `mana_gain` (170 in the pinned data) and pays 170 real
health. After payment, retain at least 50% real health plus 10% per nearby
enemy, capped at 80%. A selected spell must either become affordable, or, for
an already affordable queued cast, immediately use at least 75% of the ring's
mana without wasting it against a nearly full pool. Missing ability intent,
small casts, cooldowns and unsafe health do not justify the payment. Existing
Soul Ring purchasers that use queued preparation now pass the actual ability;
old two-argument Treads calls still prepare INT but cannot guess a Soul Ring
cast. Ring remains before Treads and the selected spell in that queue.

Low-mana intent is connected to Sven's Storm Hammer, Chaos Knight's Chaos Bolt,
and OD's Astral, Sanity's Eclipse and Objurgation. Other heroes can use this
same API when their Consider decisions are explicitly integrated; this is
not a general ability-bar scan or full TASK-26 lane mana implementation.
Restoration for a selected cast bypasses optional Treads switches to avoid
delaying interrupts and ally saves. Ordinary restoration keeps its existing
Treads preparation. Channels and existing queues are never cleared for this
path, and emergency spell preparation exclusions remain in place.

## OD Arcane Orb

Replace the level-nine permanent autocast with a live reserve. Outside hero
combat, keep mana for a ready Astral. With enemies within 1600, additionally
keep the greater cost of ready Eclipse or Objurgation. Each Orb must leave
that reserve after paying the greater of its API mana cost and its live
`mana_cost_percentage` of current mana (20% in the pinned data).

Autocast enables on useful, attackable targets in attack range: heroes or
creeps that need more than an ordinary hit. It disables below the reserve,
without a useful attack target, or for protected/suspicious targets. Enabling
again requires an extra 5% maximum-mana buffer; staying enabled does not.
Manual Orb casts obey the same reserve. Cooldowns and untrained spells
release their reserve, allowing normal farming even before level nine.

Current Essence Flux is the hidden innate `obsidian_destroyer_equilibrium`,
with a 30% proc chance and separate restoration for spells and Orb attacks.
Neither a future proc nor a historical trained Essence Aura is budgeted as
guaranteed mana. Successful recovery raises actual mana and permits Orb again.

## Evidence and verification

Resource values and current recovery were checked against the same pinned
Valve game-file mirror used by the offline ability/recipe validation:
[items.txt](https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/items.txt)
and [OD definitions](https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_obsidian_destroyer.txt).

Run `node tests/item_cast_policy_spec.cjs`, `node tests/power_treads_spec.cjs`,
`node tests/run-builds.cjs` and `node tests/run-objectives.cjs`. The first suite
executes the real generic item predicates and real OD/Sven/CK entry points;
the Treads suite covers actual shared helpers and final item execution.
Inventory regressions cover all boot families, combat gates, restoration
identity, expiry and rejected-action retry. Valve ability validation checks
names/special keys in the hero integrations.

Lobby checks still required:

1. Verify MoM stays unused with the protected hero spells ready in combat,
   then becomes usable during cooldowns and safe farming.
2. Deliver a Clarity into a full inventory with Treads/Wand/BKB: verify only
   an eligible cheap item moves, no combat swap starts, and restoration retries.
3. With low mana, interrupt with Sven/CK or save/interrupt with OD using an
   active Mango, charged Wand, or safe Soul Ring. Confirm restoration precedes
   a freshly selected cast without optional Treads delay. Move/kill/protect
   the target or begin a channel to confirm the consumable is retained.
4. Check Ring's real health payment and temporary mana expiry; compare safe
   and unsafe health and nearly full mana. Verify small casts do not drain HP.
5. Farm and fight as OD before/after level nine. Observe percentage mana cost,
   autocast disabling at reserve, cooldown-based reserve release, and resumption
   after actual Essence Flux recovery without rapid toggle oscillation.

These checks are engine-dependent; TASK-36 remains Needs In-Game Test until
they are recorded. TASK-30 and TASK-26 are not closed by this work.
