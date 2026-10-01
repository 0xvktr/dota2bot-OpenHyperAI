# Friendly High Fives (TASK-38)

The ordinary bot scripts now attempt to return nearby **allied human** High
Five requests. Bots also have a 25% chance, rolled once per new kill/assist or
completed lane rescue, to offer a High Five near an allied human. They do not
walk toward a player, stop to wait, or send chat messages about the interaction.

## Behavior

- The human must be visible, alive, real and already within **900 units**.
  Enemy players, other bots, illusions and duplicates are not reply targets.
- Replies take priority over initiating. A persistent request is attempted
  once; the bot recognizes its ending even while busy or on cooldown, allowing
  another request from that player later. Attempts are at least 10 seconds
  apart, and the native ability must be castable. A brief reservation prevents
  nearby bots from all answering the same request in the same instant.
- A celebration expires after **15 seconds** and can be offered at most once
  per **90 seconds**. Loading a script with existing kills/assists does not
  cause a celebration. Rescue celebration requires an observed transition
  from assisting/pushing to returning, not an aborted travel attempt.
- Casting, channeling, queued actions, current attacks, retreat/defense, low
  health, recent hero/tower damage, nearby visible or recently seen enemies,
  invisibility and disables suppress the cosmetic action. Illusions, Meepo
  duplicates, Tempest Doubles and Lone Druid bears cannot issue it.
- Hero spell decisions run first. All immediate/queued/pushed spell and item
  cast shapes record their order time; social logic waits at least **0.5
  seconds** afterward, even if the engine has not yet updated casting state.
  Boss-combat casts and Twin Gate diagnostics keep their priority.
- The implementation issues only an instant, no-target cosmetic ability. It
  never queues a High Five or clears/moves the bot's actions. Keeping the
  existing movement order in the live engine remains part of lobby validation.

## Settings

In the active `Customize/general.lua`, with `Customize.Enable = true`:

```lua
Customize.Allow_High_Fives = true -- false disables friendly bot interactions
Customize.Debug_High_Fives = false -- true logs handles and cosmetic attempts
```

The external `game/Customize/general.lua`, when present, takes precedence via
the existing custom loader. Missing High Five settings use the defaults above;
disabling the master customization switch also uses defaults.

## Native ability access and verification limits

The installed Valve data in `.test-tools/valve/scripts/npc/npc_abilities.txt`
defines `plus_high_five` and the older `high_five` as instant, no-target,
zero-mana abilities with a 900-unit acknowledgement range, ten-second request
duration, 60-second initial cooldown and one-second acknowledged cooldown.
The scripts check actual castability rather than assume a cooldown is ready.
The ordinary High Five request modifier is `modifier_plus_high_five_requested`
in the existing FretBots implementation; the older
`modifier_high_five_requested` is also recognized as a compatibility candidate.

**A native Bot API handle and a successful animation are not yet confirmed in
a live lobby.** The helper looks up these two exact names and skips quietly if
neither is exposed and castable. It checks the ability's name, zero mana cost
and zero cast point before issuing an order. Its temporary hidden-ability
permission applies only to the matching handle during this call; unrelated
hidden spells remain blocked. The permission is cleared even if an order fails.

`Debug_High_Fives` logs the first safe handle probe per bot and each attempt.
An `order issued (animation unverified)` message means the Lua call did not
raise an error; it does **not** prove that the engine accepted the cosmetic.
If both handles are nil, ordinary bot support cannot be established by the
offline tests. Record the log before considering another backend.

The existing FretBots kill taunt uses `AddNewModifier` in the server scripting
environment. It is separate from this friendly native-ability behavior and
has not been changed. Its existence does not establish that ordinary bot
scripts can call server modifier APIs.

## Automated checks

```powershell
node tests/high_five_spec.cjs
node tests/run-objectives.cjs
node tests/run-builds.cjs
```

The dedicated suite executes the real policy, action wrappers and generic
ability Think with an engine stub. It covers request lifetimes/cooldowns,
single event rolls, celebration expiry, rescue completion, unavailable handles,
error cleanup, gameplay action precedence and scoped hidden spell protection.
The movement fixture proves that the Lua helper does not issue movement or
clear orders; it cannot prove native animation or movement semantics.

## Lobby checklist

1. Enable debugging and play with an allied ordinary bot within 900 units, in
   a safe area. Raise a High Five. Record the handle probe, request response
   attempt and the actual completed interaction. Repeat with several bots
   nearby and confirm replies are not spammed.
2. Repeat after cooldown/request completion, while the bot is walking its
   existing route. Confirm it continues that route without stopping or moving
   toward you. Test outside 900 units and verify that it does not approach.
3. Repeat while the bot is attacking creeps/heroes, casting, channeling a TP,
   executing a queued combo, retreating or facing nearby enemies. Those actions
   must continue without a cosmetic order replacing them. After the danger
   clears, a still-live request may be answered.
4. Win a fight that grants a bot a kill/assist, or complete a lane rescue, with
   an allied human nearby. Across several events, expect occasional offers
   rather than one every time. Check that old events do not cause offers after
   15 seconds and offers are separated by 90 seconds.
5. Disable the setting and confirm friendly behavior stops. Repeat with
   FretBots disabled to distinguish native bot ability support from server-side
   taunts; record nil/unusable handles rather than claim a successful feature.
6. Check at least two heroes and both teams, including pregame and a game
   where the human's account has no Dota Plus subscription. No entitlement or
   normal/Turbo availability is assumed from the KV definition alone.
