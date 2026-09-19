# Objective coordination changes

This is an independent change against the April 2 checkout, not a merge of PR
#166. That PR's diff was inspected for overlap: it adjusts push decisions and
lane selection, but does not change the Lotus/Wisdom or boss-mode files replaced
here. Its hero bans and unrelated laning changes are not included.

## Behavior

- Lotus pools: one nearby bot prepares up to 12 seconds before each three-minute
  spawn. Supports have selection priority; a core can collect if appropriate,
  with lower desire so last-hitting can win. Bots require inventory space and
  avoid unfavorable contests. Repeated inventory increases extend collection;
  three seconds without a pickup, or ten seconds total, ends the visit.
  After 35 seconds past a spawn, bots only inspect a pool within 500 units;
  they do not leave their lane to check an old spawn.
  Lotuses are no longer dropped by cores after minute 30. When restoration is
  useful, a backpack lotus temporarily replaces an eligible inexpensive item
  outside combat. The displaced item returns after consumption or a 20-second
  timeout. The normal backpack activation cooldown still applies. Active
  lotuses can restore the holder or a nearby ally, including humans, in combat.
- Wisdom: a bot support prepares up to 30 seconds before each seven-minute
  spawn, with actual departure based on estimated travel time. Radiant secures
  the top shrine, Dire the bottom. A nearby bot core is the fallback. A human
  only reserves the shrine by physically entering its collection area. A dead,
  endangered, or stalled collector releases the assignment. An enemy shrine
  is only considered after servicing our own, from nearby, with stricter safety.
- Collection progress only counts while the collection mode is actually running
  and the area is uncontested. Leaving the radius, interruption, or nearby
  opponents resets the local timer. No old `Action_PickUpRune` call is used for
  Wisdom Shrines.
- Tormentor: teams can initiate without a human ping. A plan requires four
  healthy participants, including two cores; the local attack also requires two
  cores. Five are preferred when available, with a 20-second assembly grace
  before accepting four. A distant human is never assumed to participate.
- Roshan: uses the same bounded assembly and attack system with at least three
  participants and two cores. The DPS helper now uses team total, not average.
  Default initiation is minute 30, with at least 75% health per participant.
  `objective_settings.lua` exposes an opt-in earlier Ursa attempt (minute 20);
  the specialist must be eligible to participate. This is a conservative
  timing gate, not a complete lineup-specific damage/sustain simulator.
  Calls to evaluate desire no longer announce an attempt. The elected bot only
  announces when executing the plan, once per plan, in team chat. Threatened
  participants cancel the call. Once combat starts, a 35% health threshold
  replaces the starting threshold and the plan gets 90 seconds to execute.
  Attack orders are not repeatedly issued to an already-attacked target, and
  casting/channeling is preserved. Losing combat quorum cancels the attempt.
- Roshan combat: existing hero-specific ability/item logic still runs. A small
  supplement explicitly applies Slardar's Corrosive Haze and Ogre's Bloodlust
  to attackers, uses Drums/Boots of Bearing with three attackers nearby, and
  uses Satanic below 60% health while attacking. Existing examples include
  Ursa's Overpower/Enrage and Alchemist's Acid Spray/Chemical Rage. This is not
  an exhaustive verified list of every spell that affects current Roshan.
- Fight reinforcement: before routine TP destinations, healthy bots consider
  an ongoing fight near a surviving friendly tower, including tier one.
  At least two allies and two visible enemies must be present; the arriving
  hero must bring allied numbers to parity. Nearby danger, a collapsing tower,
  or an unsafe landing blocks the TP. Existing root/channel safety checks remain.
- Push: a numerical opportunity (at least two more allies alive, at most three
  enemies alive) selects one lane for the whole group. Three heroes assemble,
  then the existing creep/building/backdoor micro executes the push. Stragglers
  rejoin teammates. Aegis or a 15% estimated net-worth advantage can also trigger
  a group push after minute 20.
- Regroup: otherwise, after minute 20, scattered bots can assemble around a
  healthy core, including a human pos 1/2, without requiring a ping. The core
  continues acting normally. Regrouping ends when three arrive or after 25 seconds.
- Routine farm/roam desires yield to commitments. Emergency desires, active
  fights, poor health, and base/tower threats retain priority. Boss/push plans
  assembly times out after 60 seconds and backs off rather than spamming calls.

The strategy lives in `bots/FunLib/objectives.lua`. All modified runtime files
are hand-written Lua; no TypeScript build is required for this change.

## Coordinates and timing evidence

Positions were read with ValveResourceFormat Source2Viewer CLI 20.0 from the
installed `game/dota/maps/dota.vpk`, `maps/dota/entities/default_ents.vents`.
Installed Steam build ID: **25329722**. Extraction date: September 17, 2026.
The extracted game assets and reader are ignored local test tools, not repo assets.

| Objective | X | Y | Z |
|---|---:|---:|---:|
| Radiant Wisdom | -8088 | 768 | 39 |
| Dire Wisdom | 8167 | -1142 | 38 |
| Top Lotus | -7548 | 4209 | 98 |
| Bottom Lotus | 7504 | -4405 | 101 |
| Bottom Tormentor | 7744 | -6208 | 64 |
| Top Tormentor | -7680 | 6336 | 128 |
| Top Roshan marker | -3194 | 2395 | 0 |
| Bottom Roshan marker | 2860 | -2765 | 14 |

`objective_locations.lua` centralizes these values. The old Tormentor positions
were over 1,600 units away from current spawns. Roshan now uses top by day and
bottom by night; Tormentor uses the opposite side. Visible boss handles refine
the selected position while approaching. A side change cancels a stale plan.

Primary timing references:

- [Valve 7.38](https://www.dota2.com/patches/7.38): proximity-based Lotus and
  Wisdom collection; seven-minute Wisdom cycle.
- [Valve 7.39](https://www.dota2.com/patches/7.39): Tormentor's initial spawn
  moved back to 20:00. The scheduler retains 10:00 for Turbo.
- [Valve 7.41](https://www.dota2.com/patches/7.41): Roshan starts top, Tormentor
  starts bottom; contested collection countdowns reverse.

## Automated checks

With native Lua, run `lua tests/objectives_spec.lua` from the repo root.
On this Windows checkout the isolated Node-based runtime is installed:

```powershell
node tests/run-objectives.cjs
```

For a fresh checkout without Lua:

```powershell
npm install --prefix .test-tools --no-package-lock --ignore-scripts fengari-node-cli luaparse
node tests/run-objectives.cjs
```

Tests cover timed assignments, death and timeout reassignment, human carry/mid,
contests, interruption, empty/full pools, actual pickups, boss quorum/attack/
completion, shared push lanes, regrouping, respawns and defense overrides.
The runner also syntax-checks integration files and executes the actual Roshan
DPS function in isolation. Engine calls are mocked; these are not gameplay tests.

## In-game acceptance pass (still required)

Use a Custom Lobby / Local Host / Local Dev Script for both teams, both Unfair.
Load this checkout's `bots` directory into Dota's `scripts/vscripts/bots` path.
This machine's `D:\SteamLibrary\steamapps\common\dota 2 beta\game\dota\scripts\vscripts\bots`
is now a junction to this checkout's `bots` directory. Select **Local Dev Script**
for both teams instead of the Workshop entry. Generated bot names end in
`.OHA-DEV` to identify this fork. The Workshop subscription remains unchanged.

1. Play pos 1 on Radiant. Observe the 2:50-3:10 and 5:50-6:10 Lotus windows:
   one nearby bot should approach, collect or inspect briefly, and return.
2. Observe 6:30-7:15 Wisdom. A support should head to Radiant's top shrine;
   repeat as Dire pos 2 to test the bottom shrine. Kill or interrupt the chosen
   support and verify another eligible bot takes over.
3. Take the Lotus yourself before the bot arrives. Verify it leaves the empty
   pool promptly. Contest a shrine and verify it does not count contested time
   as a successful visit.
4. After minute 20, observe a Tormentor attempt without pinging. Four/five
   healthy teammates should gather before attacks. Stay away as the human;
   bots must either execute with enough bot cores or time out safely.
5. Observe Roshan after minute 30. Look for actual movement and
   attacks, one announcement, and cancellation when enemies approach.
6. Win a fight with three opponents dead. Bots should pick one lane, gather,
   and push using the existing building logic. Enemy respawns and a threatened
   allied base must cause reassessment. Watch for stragglers walking alone.
7. With no immediate objective, move your core along a safe lane after minute
   20. Nearby scattered teammates should regroup instead of all wandering alone.

September 18 feedback regression pass: additionally check a support with six
occupied main slots collecting a lotus, swapping/using it on a depleted human,
and returning the displaced item. Check that cores retain/use lotuses after
minute 30 without a pickup/drop loop. At Roshan, watch sustained attacks and
spell/item use, and approach with an enemy to verify cancellation. For TP,
observe a distant healthy hero during a contested fight at an allied tower.
Wisdom collection succeeded in the first reported match; its assignment rules
are unchanged by this follow-up.

Set `O.Debug = true` near the top of `objectives.lua` before starting a fresh
match to log assignments, plan creation and cancellation reasons as
`[Objectives] ...`. Disable it after testing. Report game time, side, heroes,
nearby enemies, and the last objective log when a behavior fails.

## Limits to verify in a live match

There is no verified ordinary-bot API for pool stock or shrine activation state.
The script therefore records a bounded **serviced/inspected** visit, not an
engine-confirmed empty pool or XP award. A new spawn resets that record. Enemy
collection out of vision cannot be known. Movement travel estimates do not model
terrain, so difficult paths may delay arrivals. Coordinates must be rechecked
after map updates or on alternate maps. Thresholds and mode competition need
live tuning; automated checks cannot establish that either team now wins more
reliably. Boss strength estimation and existing combat/building micro remain
heuristics. Workshop mode will keep running the Workshop copy until you select
the local development script.
