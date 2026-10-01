# Early lane-defense teleports (TASK-19)

Before **10:00 in normal games / 8:00 in Turbo**, pos 1/2/3 cannot teleport
away from their assigned lane to rescue an ally or reinforce an allied outer
tower. Eligibility uses `J.GetPosition`, not a hero's possible support roles.
Returning to the assigned lane, defending locally, escaping danger and defending
the base remain available. Pos 2 offensive ganks and rune rotations belong to
TASK-20 and are not changed here.

## Support selection

- Pos 4 can rescue a pressured carry on another lane. Carry rescue takes
  priority over a mid counter-dive.
- Pos 5 can rescue a pressured offlaner on another lane, below carry and mid
  priority. Its carry must be safe before departure.
- Either support can counter a mid dive when its own lane partner is safe.
- Assigned-lane returns/defense remain available to every position, including
  a pos 5 returning to its carry or a pos 4 returning to its offlaner.

The policy follows assigned lanes rather than fixed Radiant/Dire map sides.
Both supports need a known, alive core partner on their assigned lane. Each
partner must have at least **70% HP**, have taken no tower damage in the
last **4 seconds**, and not be retreating. Ordinary hero harassment is tolerated
at or above the health floor; an observed loss of at least **15% of max HP in
roughly 3 seconds** counts as serious pressure, following the existing pull
logic's rapid-loss heuristic. The partner's mana does not gate a rescue.
Enemies within 1,000 units cannot
outnumber healthy allies remaining within 1,200 units after the support leaves.
Recent enemy sightings (under 5 seconds old) also count. Unknown partner safety
does not authorize a departure; a healthy core alone against two heroes is not
considered safe.

A rescue needs a real core within **1,600 units of an allied outer tower** and
an enemy within 1,200 units of that core. The core must either:

- have taken hero damage within 3 seconds and be below 65% HP or face at least
  two enemies; or
- be below 40% HP with a nearby enemy.

Routine harassment of a healthy core by one opponent does not qualify. The
proactive selector also requires an ally actively taking hero damage, an
arriving bot with at least 65% HP / 30% mana, and no nearby combat at its current
location. During the early window it can consider a solo offlaner against one
or two enemies; later it keeps the existing two-allies/two-enemies minimum.

Existing tower-health, surviving-defender, lost-fight cooldown, safe landing
and pending-arrival checks still apply. Rescues at foreign creep destinations
without a nearby live allied outer tower cannot bypass the policy. Base tower
and Ancient defense retain their exception.

## Execution and return

`early_lane_defense.lua` supplies the policy to `fight_response.lua`, the
legacy defend-ally/defend-tower item branches, and the final TP-scroll and
Nature's Prophet cast boundaries. The selected purpose travels with the action.
Teamfight reinforcements into a contested allied outer tower use the same
defense restrictions; unrelated offensive destinations keep their old rules.
If the home core becomes unsafe while a defensive TP channels, the channel can
be canceled. Unrelated spell channels are not canceled by this policy.

After rescue, the existing bounded rotation returns the support home. A newly
unsafe home core also prevents extending the visit for an optional tower push.
The hard cutoff is separate from `J.IsInLaningPhase`, which can extend laning
past ten minutes based on net worth.

## Strategy references and limits

The support author's [lane-partner and rotation guide](https://www.dotafire.com/dota-2/guide/how-to-become-the-best-support-you-can-be-26948)
recommends leaving when a carry can survive alone and choosing exposed enemies
for rotations. A player-written [support guide](https://steamcommunity.com/sharedfiles/filedetails/?id=211882174)
describes saving teleports for tower dives and helping other lanes. These are
historical strategy references; their old item details are not used.

Neither establishes a universal eight/ten-minute cutoff or these numeric
thresholds. The cutoff and conservative safety checks implement the requested
early-laning behavior and should be tuned from lobby observations. This is a
local pressure heuristic, not a prediction of every matchup, spell or creep
wave. HP-drop detection needs a recent sample; the first observation cannot
reconstruct damage already taken. Unlike a nearby pull, a TP keeps a firm 70%
home-health floor even without recent damage, because returning takes longer.
The numerical guard can also prevent departure from a seemingly stable 1v2.

## Verification

Run from the repository root with the existing `.test-tools` dependencies:

```powershell
node tests/early_lane_defense_spec.cjs
node tests/run-objectives.cjs
node tests/run-builds.cjs
```

The dedicated suite runs the real policy, item TP decision/cast functions and
Prophet TP decision/execution functions with an engine stub. It covers all
positions, both teams, numeric last-seen IDs, home safety, carry priority,
exceptions, cutoff boundaries and eligibility changes before casting/channeling.
The objective suite also covers lost defenses, redundant arrivals and bounded
lane returns. These are offline checks; live Dota lobby behavior remains to be
verified.

Lobby checklist for normal and Turbo, on both teams:

1. Pressure pos 1 plus pos 5 near their tier one before the cutoff. Pos 2/3
   should keep their lanes; a healthy pos 4 with a safe offlaner can respond.
   Ordinary pokes while the offlaner remains above 70% HP should not block or
   cancel the rescue. Rapid HP loss, retreat or being left against two nearby
   opponents should keep pos 4 home.
2. With a safe carry, dive the solo offlaner near its allied tower. Pos 5 can
   respond; repeat with the carry losing HP rapidly or below 70% HP and confirm
   it stays instead.
3. Check a single harmless harass hit and pressure far from a surviving allied
   tower. Neither should cause an early cross-lane defensive TP.
4. Confirm core returns to their own lane after respawning, local defense,
   low-health fountain escapes, base defense, and behavior after 10:00/8:00.
5. Repeat using core and support Nature's Prophet. Change home-lane pressure
   after a support request is selected and during its channel; check rejection
   or cancellation without interrupting unrelated spell channels.
6. After a successful rescue, confirm the support returns home once combat
   ends, especially when its partner becomes unsafe. Check that doomed towers
   and already-sufficient arrivals do not attract another responder.

With item motive reporting enabled, distinguish `Reinforce fight at allied
tower`, `Return to lane after rescue`, and the legacy defend-ally/tower motives
when recording a surprising TP. Include game time, assigned position/lane,
home-partner HP/damage, destination tower and visible/last-seen enemy counts.
