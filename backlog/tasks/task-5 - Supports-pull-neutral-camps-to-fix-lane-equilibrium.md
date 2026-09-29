---
id: TASK-5
title: Supports pull neutral camps to fix lane equilibrium
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
updated_date: '2026-09-29 22:14'
labels:
  - laning
dependencies: []
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
- [ ] #1 Pos 4/5 pull the nearest suitable camp onto the allied wave when the lane front is past equilibrium toward the enemy
- [ ] #2 No pull when the camp is empty or blocked, or when the support would be exposed to enemy heroes
- [ ] #3 The pulled camp actually aggroes onto the allied creeps in a test game
- [ ] #4 Offline spec covers the equilibrium decision and pull timing
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
OpenAI Five (doc-1, section 7): the agent acted every ~133 ms and learned that frame-exact timing did not help. Our ability thinks run every ~0.12-0.2 s, so pull timing must use a reached-or-passed window, never an exact second. The Ice Blast release bug (TASK-1) came from exactly this.
<!-- SECTION:NOTES:END -->
