---
id: TASK-5
title: Supports pull neutral camps to fix lane equilibrium
status: Needs In-Game Test
assignee:
  - '@claude'
created_date: '2026-09-29 21:29'
updated_date: '2026-10-01 11:20'
labels:
  - laning
dependencies:
  - TASK-32
references:
  - tests/neutral_spawners_741f.lua
  - bots/mode_laning_generic.lua
documentation:
  - backlog/docs/doc-1 - OpenAI-Five-lessons-for-the-bot-scripts.md
priority: high
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Supports never pull. When the lane is pushed toward the enemy tower, a human support pulls a nearby camp onto the allied wave so the neutrals kill it and the lane resets toward our tower. It is a cheap, high-value laning skill. Lane behaviour for most heroes is Valve's default; there is no pull or equilibrium logic in the scripts. Valve's GetLaneFrontLocation gives the wave position; camp positions and spawn boxes come from GetNeutralSpawners() (7.41f snapshot in tests/neutral_spawners_741f.lua); pull timings are on Liquipedia's creep/neutral mechanics pages.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Only the pos 5 support pulls, from its own safe-lane pull camp
- [ ] #2 A pull starts only when the lane front has moved too far from the allied tier 1 tower toward the enemy, at the camp's pull timing
- [ ] #3 No pull when the carry is in combat, the camp is empty or blocked, or the support would be exposed to enemy heroes
- [x] #4 The pulled camp actually aggroes onto the allied creeps in a test game
- [x] #5 The support announces the pull in team chat
- [x] #6 Offline spec covers the equilibrium decision and pull timing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Collect with TASK-32 on both sides (Radiant bot lane, Dire top lane): the pull camp, where the support stands to aggro it, the second it aggroes, the drag point where the neutrals meet the allied wave, and lane-front amounts for a pushed and an even lane.
2. FunLib/lane_pull.lua: per-side pull data (camp matched to the live GetNeutralSpawners entry nearest the recorded spot, aggro point, drag point, pull seconds).
3. Decision: pos 5, laning phase, own safe lane; allied lane front past a threshold away from our T1 (GetLaneFrontAmount); carry not in combat; camp spawned and not blocked; no visible enemy hero near the route; enough time to reach the aggro point before the pull second.
4. Execution: hook a window into mode_roam_generic.lua the way SupportLastHits does (desire + Think), so Valve's default laning stays in charge otherwise. Walk to the aggro point, hit a neutral inside a time window (not an exact second), walk to the drag point, then rejoin the lane. Announce the pull once in team chat.
5. Offline spec for the threshold, timing window and abort cases; then a test game.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
OpenAI Five (doc-1, section 7): the agent acted every ~133 ms and learned that frame-exact timing did not help. Our ability thinks run every ~0.12-0.2 s, so pull timing must use a reached-or-passed window, never an exact second. The Ice Blast release bug (TASK-1) came from exactly this.

2026-09-30 user scope: pos 5 only; trigger is lane equilibrium too far from our T1; carry not in combat; optional team-chat notice. Liquipedia's pre-7.33 stack/pull map shows pulls at xx:14 and xx:44 from the small camps by the safe-lane T1 on both sides; 7.41 timings and positions to be measured with TASK-32. Dump candidates (tests/neutral_spawners_741f.lua): Radiant small camp key 1 at (3978,-5026) and its Dire mirror key 26 at (-3911,4829).

2026-09-30 lobby measurements (TASK-32 pings, melee hero): Radiant camp key 1: hit from about (4090,-5390) at xx:16-17 and xx:46-47, neutrals meet the wave around (3830,-6250), 5.6-6.3 s after the hit. Dire camp key 26: hit from about (-4040,5200) at xx:17-18 and xx:47-48, meet point around (-3840,5930), 2.6-3.7 s after. Equilibrium pings (6225,-4282) and (-6321,4220) mirror each other, so the trigger is symmetric: our wave front closer to the enemy tier 1 than to ours (live GetTower positions). User notes: hitting too early makes the neutrals leash back before the wave sees them; fast neutrals follow quicker; walking through the camp can aggro it early (so the support waits outside the box on the lane side and routes via the drag spot when coming from the base side).
Implemented FunLib/lane_pull.lua (Window/Think state machine: approach, wait, aggro inside a 1.5 s window, drag, done) hooked into mode_roam_generic.lua before SupportLastHits at desire 0.89. Team chat 'Going to pull' once per pull. Aborts: hit window missed, camp empty, enemy hero within 1200 of the support or camp, support hit by a hero, lane partner fighting before the hit, HP under 30% during (50% to start). tests/lane_pull_spec.lua passes (registered in run-builds.cjs). Full run-builds currently stops at an unrelated uncommitted Invoker build (another session).

Test game 1 (2026-09-30): two pull announcements before 4:00, both failed, none later. (1) Aborted when an enemy illusion hit the carry: illusions counted as heroes and any hero hit on the partner counted as combat. (2) Support circled trees, missed the pull second and left without hitting: it required reaching the computed wait spot within 80 units, and treated neutrals hidden by trees as an empty camp. (3) No later attempts: start was capped at 10 s before the pull with the walk required to fit, so a support standing up a pushed lane never qualified, and any enemy hero within 1200 of the support blocked the start.
Fixes: partner in trouble = under 70% HP and hit by a hero in the last 2 s, or losing 15% max HP within ~3 s; illusions ignored; before leaving, only enemies near the camp count (near the support too once at the camp); start based on route walking time (0.5-4 s of slack, up to 25 s ahead), pulls until 10:00; wait spot checked with IsLocationPassable and moved toward the measured hit spot; arrival radius 150; hit at the pull second even if not arrived; hidden neutrals: walk to the hit spot before calling the camp empty; routes go around the camp box corners, re-planned each think. lane_pull_spec extended to 13 scenarios (illusion, harass vs trouble, far start, late arrival, hidden camp, blocked wait spot, 10:00 cutoff) and passes.

Real tier 1 positions (map entity file): Radiant bot (4860,-6379), Dire bot (6269,-2240), Radiant top (-6336,1856), Dire top (-5275,6036). The user's Radiant equilibrium ping is ~460 units past the tower-distance midpoint and the Dire ping ~270 before it; their average is within ~100 units of the midpoint, so the 'closer to the enemy tier 1' trigger matches the mirrored average the user suggested. lane_pull_spec now uses these tower positions.

Test game 2 (2026-10-01, AA pos 5, Radiant bottom, clips + map paths from the user): (1) 3:40-3:46 the bot circled north of camp 1 near (4400,-4452), walked into the camp at 3:46 and left. Cause: the camp-avoiding waypoint route. From the pushed lane (6044,-3978) it went to the box's NE corner; the SE corner failed IsLocationPassable (trees), the fallback headed west, and a few steps later the NE corner was the best waypoint again, so it oscillated. (2) 4:59 announced, hit the camp at 5:17 from the north spot (a ward gave vision), then ran back: the pull expired at second+1.5 s while the ranged attack was still in flight.
The user's drawn pull: aggro near (4198,-5242), drag straight south to about (4206,-6129); natural approach from a pushed lane is through the gap between camps 1 and 2.
Rewrite of lane_pull.lua: no waypoint routing and no separate wait spot; walk straight to the hit spot with engine pathfinding, timed to arrive at the pull second (walk = straight distance x1.25 / speed; leave when at most 1 s early, skip if more than 1 s late; hold if ahead of schedule). Attack from second-0.3; after the attack order stay committed 3 s for the camp to turn (projectile flight); aggro while walking in counts as the hit; then drag. Radiant spots now hit (4150,-5300), drag (3950,-6220); Dire unchanged. Danger near the support only counts within 900 of the camp. lane_pull_spec rewritten (13 scenarios incl. the pushed-lane approach and the in-flight ranged hit); full run-builds passes.

User clarification (2026-10-01): walking through a camp's spawn box is safe. Neutrals only aggro when a hero runs right through them, i.e. close to the spawner point where they stand (the numbered circle on the route map; its size is a symbol, not a range). The spawn box only matters for blocking the spawn at the minute mark. The straight line from the north gap to the Radiant hit spot (4150,-5300) passes ~250 units east of the spawner point (3978,-5026); if the camp aggroes on the way in, move the hit spot further east.

Test game 3 (2026-10-01): the rewritten pull works. One full pull, one partial (only one lane creep followed), the bot hitting slightly early. Pull seconds moved +1: Radiant xx:17/xx:47, Dire xx:18/xx:48 (Dire still unobserved; 18 is inside the user's measured 17-18 window). lane_pull_spec times are now relative to the configured seconds. Map annotations updated and republished.
<!-- SECTION:NOTES:END -->
