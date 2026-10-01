# Power Treads switching

The implementation is shared by `FunLib/power_treads.lua`, the existing
`J.SetQueuePtToINT` hero helper and `X.SetUseItem` in the generic item executor.
TASK-34 contains the recovered research and source links.

Switching preserves current health and mana percentages. Casting a fixed-cost
spell with a larger mana pool consumes a smaller fraction of that pool;
receiving fixed restoration with a smaller pool restores a larger fraction.
For example, 300/600 mana becomes 360/720 on INT. Spending 100 and returning to
AGI leaves about 216.7/600 rather than 200/600. These calculations assume the
current +120 maximum mana from Treads and do not justify INT for every form of
passive regeneration or percentage-based expenditure.

## Policy

- Prepare INT before casts that use the existing shared helper and before
  ordinary mana-costing item use, including TP. Keep switches before the cast
  in the same action queue. There is no queued switch back after a channel.
- Prepare AGI before safe self use of Stick/Wand, Bottle, Mango, Healing Lotus
  tiers, Salve, Clarity and Tango. Giving these to an ally does not toggle the
  caster's Treads. Keep AGI during ongoing Salve, Clarity, Tango, Bottle,
  Urn and Vessel restoration when no enemy hero is within 1000 range.
- Retreat with significant desire, evasion, low health, recent hero/tower
  damage, an incoming spell projectile or Assassinate takes priority over
  restoration. Prefer STR; Medusa prefers INT for Mana Shield. The danger
  setting persists briefly after the trigger disappears to avoid oscillation.
- Otherwise use the primary attribute. Universal heroes use AGI because
  attribute-derived attack damage is equal and AGI adds attack speed.
- Naga Mirror Image, Terrorblade Conjure Image, Chaos Knight Phantasm,
  Phantom Lancer Doppelganger and Manta prepare the offensive setting when
  safe. Counterspell, Shallow Grave, False Promise/Fate's Edict, Omniknight's
  saves, Press the Attack, explicit defensive/team-save items, item interrupts
  against a target casting/channeling, silenced item users and actions under
  threat bypass additional preparation.
- Never switch while channeling, casting, using another ability, teleporting,
  muted, disabled, invisible or while another action queue is pending. Share
  the switch timestamp and a short cast settling window between ability and
  item logic; only record an idle switch when the action is actually issued.
  Evaluate idle Treads switching after other item decisions so inventory slot
  order cannot put it ahead of an emergency item.

The item API's existing mapping is retained: `GetPowerTreadsStat()` returns
0/1/2 for STR/INT/AGI, while hero attribute enums are STR/AGI/INT. The toggle
cycle is STR -> INT -> AGI -> STR. Keep this conversion in the shared module.

New hero cast code should pass the ability as the optional third argument:

```lua
J.SetQueuePtToINT(bot, false, ability)
bot:ActionQueue_UseAbilityOnLocation(ability, location)
```

The third argument lets the policy skip zero-mana/urgent casts or select an
illusion setting. Existing two-argument calls retain their INT preparation
when safe. Direct hero casts that do not use this helper are not automatically
rewritten. Soul Ring retains the existing order: ring, Treads, spell.

## Verification

Run `node tests/power_treads_spec.cjs` for simulated resource accounting and
action ordering using the real shared helpers and item executor. It also runs
from `node tests/run-builds.cjs`. `node tests/run-objectives.cjs` checks existing
TP gating and other shared behavior.

Lobby verification is still required for engine scheduling and API values:

1. Observe all three Treads settings and the raw API values. From STR and AGI,
   cast an ordinary spell through a shared helper and verify INT is selected
   before mana is spent, then the default returns after the cast finishes.
2. Use Wand/Bottle/Lotus/Tango while safe; verify AGI precedes self restoration,
   ongoing restoration holds AGI, and feeding an ally does not toggle the giver.
3. Repeat restoration under damage/retreat. Verify the restoration or escape
   executes immediately and survival takes priority once no cast is pending.
4. TP and cast a long channel (for example Bane's Fiend's Grip). Verify Treads
   never interrupt it and do not revert during the cast point/channel.
5. Create Naga/Terrorblade/PL/CK illusions and Manta illusions. Verify their
   offensive setting at creation. Check Counterspell timing under a projectile.
6. Check a universal hero's AGI default and Medusa's INT survival setting;
   repeat with Treads in the backpack or cooling down after a swap.
