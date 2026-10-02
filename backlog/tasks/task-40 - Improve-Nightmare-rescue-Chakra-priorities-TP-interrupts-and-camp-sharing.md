---
id: TASK-40
title: 'Improve Nightmare rescue, Chakra priorities, TP interrupts and camp sharing'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 20:56'
updated_date: '2026-10-02 21:13'
labels: []
dependencies: []
ordinal: 170000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Players report missed opportunities to free sleeping cores and stop escape teleports, underused free mana restoration, and bots contesting occupied neutral camps. Research current mechanics and upstream fixes before changing shared behavior.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Supports transfer enemy Nightmare off nearby cores without cancelling their own channels or bouncing sleep among supports.
- [x] #2 Chakra frequently restores useful mana or cooldowns and prioritizes urgent allied needs.
- [x] #3 Visible teleporting enemies receive a prioritized legal interrupt from supported ready abilities.
- [x] #4 Neutral farming skips camps and creeps already farmed by humans or bots without removing occupied camps globally.
- [x] #5 Focused regressions pass and lobby validation steps are documented.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Research mechanics and upstream PRs; add shared emergency reactions and camp ownership checks; improve Chakra priority; run regression suites and document lobby scenarios.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Researched Valve Bane/KOTL data, KOTL guide, and upstream PR #166. Implemented shared Nightmare rescue and curated TP interrupts; useful Chakra mana/cooldown/dispel scoring and earlier priority; camp ownership in TypeScript/generated Lua, farm and roam paths, and all scripted hero attack wrappers. Humans within 700 units conservatively reserve camps. Unknown/conditional interrupt spells retain hero-specific handling. Automated policy checks pass; actual engine timing, transfers and cancellations await lobby testing.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Implemented all four requested behavior changes. Validated with run-builds (595 Lua syntax checks, full hero/build regressions), run-objectives, 36 focused emergency scenarios, 19 camp scenarios including actual farm Think, generic priority/attack-wrapper tests, KOTL native/copied regressions and Valve data-key checks. Research and lobby scenarios are in docs/SMALL_BEHAVIOR_REACTIONS.md. Status remains Needs In-Game Test because this session did not run Dota lobby validation.
<!-- SECTION:FINAL_SUMMARY:END -->
