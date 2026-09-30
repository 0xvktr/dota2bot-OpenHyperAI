---
id: TASK-27
title: Dodge area spells and spread out against team-wipe ultimates
status: To Do
assignee: []
created_date: '2026-09-30 15:22'
updated_date: '2026-09-30 15:23'
labels:
  - teamfight
dependencies: []
references:
  - bots/mode_team_roam_generic.lua
  - bots/FunLib/utils.lua
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/41'
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/47'
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/48'
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/55'
priority: medium
ordinal: 31000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upstream feature requests 41, 47, 48 and 55. Bots stand in lasting area spells (Upheaval, Dark Seer's Wall, Sand Storm, Macropyre) and bunch up against Black Hole, Echo Slam, Ravage, Chronosphere and bouncing ultimates (Lich, Winter Wyvern), and do not dodge skillshots. Valve's GetAvoidanceZones is broken, and modifiers alone do not show where an area is (and some spells, such as Sprout, apply none); reacting to modifiers only makes bots step in and out of the area. Sprout trees are also missing from the tree API, so bots trapped in them do not know they are stuck. Current workarounds: a laning-phase Upheaval retreat in mode_team_roam_generic.lua and a few Dark Seer/Sand King modifier checks.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Bots leave or path around known lasting area spells instead of stepping in and out
- [ ] #2 Bots keep spacing when the enemy has team-wipe ultimates, without breaking up fights
- [ ] #3 Bots detect being trapped (for example by Sprout) and use an escape
- [ ] #4 Offline specs cover area detection and spacing
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Scope split with TASK-24: TASK-24 collects single-spell counterplay rules (walk out of Cold Feet, no heals while Frostbitten, entries from hero passes). This task covers area spells (lasting zones, team-wipe ultimates), spacing, and escaping traps such as Sprout. Put new per-spell reactions in TASK-24.
<!-- SECTION:NOTES:END -->
