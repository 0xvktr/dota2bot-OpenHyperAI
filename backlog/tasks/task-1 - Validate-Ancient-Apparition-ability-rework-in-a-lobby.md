---
id: TASK-1
title: Validate Ancient Apparition ability rework in a lobby
status: Needs In-Game Test
assignee: []
created_date: '2026-09-29 21:29'
updated_date: '2026-09-30 13:59'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_ancient_apparition.lua
  - bots/FunLib/rubick_hero/ancient_apparition.lua
  - tests/ancient_apparition_combo_spec.lua
priority: high
ordinal: 1000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
AA's ability logic was reworked from Torte de Lini's guide tips and Valve's 7.41f ability data, and a test game showed some Ice Blasts flying off the map without a release. Offline specs cover the logic, but the combo behaviour and the Release timing can only be confirmed in a real game. AA stays on the WeakHeroes list until this passes.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Every Ice Blast is released near its target, including short-range casts into nearby fights
- [ ] #2 Release still fires when AA is silenced mid-flight
- [ ] #3 Cold Feet opens ganks and Ice Vortex follows on the cursed target
- [ ] #4 Chilling Touch harasses in lane without drawing tower aggro
- [ ] #5 Decision recorded on whether AA leaves the WeakHeroes list in bots/hero_selection.lua
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Done: combo order (Cold Feet before Vortex, Vortex pulls toward the curse origin), AoE Cold Feet talent is special_bonus_unique_ancient_apparition_1 and stays unit-targeted, Ice Blast radius = radius_min + radius_grow * seconds travelled, fight/snipe aiming, Release by tracer progress or flight time (think throttle skipped the old 100-unit window), Release ignores silence, enemy tracers ignored. Rubick's stolen copy got the same Ice Blast fixes.
<!-- SECTION:NOTES:END -->
