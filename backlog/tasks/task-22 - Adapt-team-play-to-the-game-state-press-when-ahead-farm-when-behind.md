---
id: TASK-22
title: 'Adapt team play to the game state: press when ahead, farm when behind'
status: To Do
assignee: []
created_date: '2026-09-29 22:14'
labels:
  - macro
dependencies: []
references:
  - bots/FunLib/aba_push.lua
  - bots/mode_farm_generic.lua
  - bots/mode_team_roam_generic.lua
documentation:
  - backlog/docs/doc-1 - OpenAI-Five-lessons-for-the-bot-scripts.md
priority: medium
ordinal: 25000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
OpenAI Five's final play style shifted with the game state: it grouped and pressed when clearly ahead and avoided fights to farm when behind, after an earlier fight-everything style that won fast but never recovered from a deficit (backlog doc-1, section 2). Our bots only partly do this: aba_push.lua raises push desire on net worth or level advantage (thresholds 15000/5000 net worth, 2/1 levels), mode_farm_generic.lua checks a 6000 net worth advantage, and nothing tells the team to play safe when behind. OpenAI Five also fell into a trap of grouping as five on one lane and giving up the rest of the map (doc-1, section 3).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 One shared game-state assessment (net worth, levels, alive heroes) is used by push, farm and roam decisions instead of per-module thresholds
- [ ] #2 When clearly behind, bots avoid fights away from their own towers and farm safer areas
- [ ] #3 When clearly ahead, bots group to take objectives while side lanes or jungle keep being farmed
- [ ] #4 Offline spec covers the ahead, even and behind cases
<!-- AC:END -->
