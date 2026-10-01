---
id: TASK-19
title: Keep early lane-defense TPs on supports without abandoning their cores
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-09-29 21:43'
updated_date: '2026-10-01 18:00'
labels:
  - laning
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
  - bots/FunLib/fight_response.lua
  - bots/FunLib/lane_rotation.lua
  - bots/FunLib/early_lane_defense.lua
  - bots/BotLib/hero_furion.lua
documentation:
  - docs/EARLY_LANE_DEFENSE.md
priority: high
type: bug
ordinal: 19000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Mid bots use TP scrolls very early, sometimes before 2:00, apparently to save or defend allies. A pos 2 should hold mid in the early game, not spend the TP and lose lane time. Two candidate paths: the help-ally TP branch in ConsiderItemDesire item_tpscroll (BOT_MODE_DEFEND_ALLY), which gates on J.Role.CanBeSupport(botName), a hero check rather than a position check, so many mid heroes pass; and the defend-tower TP from fight_response.lua / lane_rotation.lua added in a21e86d, which also starts laning-phase rotations. Which one fires still needs confirming (the TP cast motive shows which branch fired).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Before 10:00 normal / 8:00 Turbo, pos 1/2/3 do not TP away from their assigned lane for ally rescues or outer-tower reinforcements; support-capable hero names do not bypass position checks.
- [x] #2 Own-lane returns/defense, danger escapes and base defense remain available; local combat and post-cutoff behavior are preserved, with pos 2 gank/rune policy left to TASK-20.
- [x] #3 Early cross-lane rescues are support-only, prioritize a pressured carry near an allied tower, and allow pos 5 to rescue pos 3 at lower priority only while the home core is safe.
- [x] #4 The same eligibility rules protect the legacy ally/tower TP paths, proactive reinforcements and final TP execution including Prophet requests, retaining lost-fight/landing-safety and redundant-arrival checks.
- [x] #5 Meaningful offline regressions cover all positions, both teams and cutoffs, home-lane safety, own-lane/base/escape exceptions and final cast revalidation; relevant existing suites pass and remaining lobby checks are documented.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add a shared early lane-defense policy based on actual positions, assigned lane, pressured core targets and home-core safety. Use a hard 10-minute normal / 8-minute Turbo cutoff, separate from the extended laning heuristic.
2. Apply the policy to proactive tower rescue selection, legacy defend-ally/defend-tower decisions and final TP validation (including Prophet), while preserving own-lane returns, escapes, base defense, local fights and existing lost-fight/arrival safeguards.
3. Rank carry rescues before offlane rescues, protect supports from abandoning unsafe partners, and retain bounded return-to-lane behavior after rescue. Do not implement pos 2 ganks/rune rotations from TASK-20.
4. Add real-policy and actual item-branch/cast regressions across roles, teams, threat/home states and time boundaries. Run existing objective/build suites and document guidance, chosen thresholds and live lobby checks.

5. Refine home-core safety using the existing pull harassment distinction: tolerate a single ordinary hero hit above the 70% health floor; block observed loss of at least 15% max HP within roughly three seconds. Preserve the conservative TP health floor, tower/retreat/numerical danger checks and no home-core mana requirement. Add selection and channel regressions for harmless pokes versus meaningful pressure, and refresh docs and verification notes.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
User expanded TASK-19 on 2026-10-01 to cover observed pos 2 and pos 3 safelane rescue TPs: early cores should remain in lane, pos 4 is the primary carry-rescue candidate, pos 5 may rescue pos 3 with lower priority, and both supports must leave a safe home core. Pos 2 ganks/rotations remain in TASK-20. The previous criterion preserving every other position unchanged is superseded by this explicit request.

Implemented the shared actual-position policy with hard 10:00 normal / 8:00 Turbo cutoffs. Foreign carry rescue uses pos 4, offlane rescue uses pos 5, and defensive mid counter-dives rank below carry rescue. Home partners need at least 70% HP, no hero/tower damage for four seconds, no retreat and no numerical disadvantage after departure; recent enemy sightings count. Unknown/dead partner safety does not authorize departure. Legacy ally/tower branches, proactive selection, teamfight reinforcement at contested allied towers, final scroll casts and external/native Prophet casts share the policy. Unsafe home pressure can cancel a defensive channel and prevents extending a rescue for an optional push. Local defense, own-lane returns, base defense, escapes and post-cutoff behavior are retained; offensive mid gank/rune policy remains TASK-20.

Verification: node tests/early_lane_defense_spec.cjs passed 37 real-policy/item/Prophet scenarios; node tests/run-objectives.cjs passed the new suite plus 42 objective, 25 feedback, 20 rotation, 11 gate-probe and 14 support-last-hit scenarios and cast/wrapper regressions; node tests/run-builds.cjs passed syntax for 343 files and all existing build/hero/item/purchase suites. git diff --check passed. Acceptance criteria are verified offline; live lobby behavior is not yet verified. docs/EARLY_LANE_DEFENSE.md records strategy sources, heuristic limits and normal/Turbo lobby scenarios.

Harassment refinement after user feedback: removed the blanket four-second hero-damage veto for the home core. Ordinary pokes at or above 70% HP no longer block selection, final execution, the defensive channel or the optional bounded post-rescue push. Home-core mana is not checked. Added the existing lane_pull rapid-loss heuristic: an observed loss of at least 15% max HP within approximately three seconds signals danger. The TP health floor remains 70% even without recent damage (stricter than a nearby pull); tower damage, retreat and numerical disadvantage still block departure. This supersedes the earlier no-hero-damage requirement. Pull behavior itself is unchanged.

Refinement verification: run-objectives passed 41 targeted early-defense scenarios and 21 rotation scenarios, including healthy harass/low home mana, rapid versus gradual HP loss, and no channel/push cancellation for one ordinary poke. Full run-builds including the existing lane-pull suite passed; git diff --check passed. Updated docs explain the remaining conservative health and numerical rules and HP-sample limitations. Live lobby verification remains pending.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Early cores keep their lanes during defensive TP decisions; supports rescue pressured cores only when their own partner is safe, with carry priority. Healthy home-core harassment is tolerated; rapid HP loss and concrete danger still prevent departure. All TP paths including Prophet revalidate eligibility while retaining fight-safety and return behavior. Verified by 41 targeted scenarios, 21 rotation scenarios and full objective/build suites; ready for live lobby validation.
<!-- SECTION:FINAL_SUMMARY:END -->
