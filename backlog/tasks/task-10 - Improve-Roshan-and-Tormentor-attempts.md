---
id: TASK-10
title: Improve Roshan and Tormentor attempts
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
updated_date: '2026-09-29 22:14'
labels:
  - macro
dependencies: []
references:
  - bots/FunLib/objectives.lua
  - bots/FunLib/boss_combat.lua
  - bots/mode_roshan_generic.lua
documentation:
  - backlog/docs/doc-1 - OpenAI-Five-lessons-for-the-bot-scripts.md
priority: medium
ordinal: 10000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Roshan and Tormentor attempts are poorly executed in games. They go through the team planning module (objectives.lua) and boss_combat.lua. The specific failure modes have not been catalogued yet.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Failure modes from test games are recorded in this task before changes are made
- [ ] #2 Bots take Roshan and Tormentor when they have the numbers and vision, and abandon attempts when enemies collapse
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
OpenAI Five (doc-1, sections 5-6): the agents learned never to go near Roshan until its HP was randomised in training, so even a learning system needed help. In its shaped reward, Aegis was weighted like the win itself (5, paid to the whole team). Roshan attempts need explicit value and risk evaluation.
<!-- SECTION:NOTES:END -->
