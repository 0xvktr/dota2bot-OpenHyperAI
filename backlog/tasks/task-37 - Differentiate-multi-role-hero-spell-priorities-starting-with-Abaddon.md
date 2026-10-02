---
id: TASK-37
title: 'Differentiate multi-role hero spell priorities, starting with Abaddon'
status: To Do
assignee: []
created_date: '2026-10-01 14:16'
updated_date: '2026-10-02 16:49'
labels:
  - hero
dependencies: []
references:
  - TASK-13
  - bots/BotLib/hero_abaddon.lua
  - tests/abaddon_ability_spec.lua
  - docs/HERO_PASS_REPORT.md#abaddon
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
  - docs/HERO_PASS_TRACKER.md
  - docs/HERO_PASS_REPORT.md
priority: medium
type: enhancement
ordinal: 47000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Multi-role heroes currently share most spell priorities even when their position changes the value of healing, ally protection, self protection and damage. During the Abaddon standard pass discussion, the user suggested differentiating support and carry gameplay and asked to record the idea for later, without implementing it now.

Abaddon is the initial example: support may favor Mist Coil healing, allied Shield protection and reserving mana for saves; carry may favor offensive Coil and self-Shield when they sustain attack pressure. These are preferences to evaluate, not unconditional rules. Urgent saves and dispels should retain priority in either role. A support taking the enemy's attention may need self-Shield, while a carry may gain more from freeing a disabled teammate.

Scope for later: assess role-dependent target preference, mana reserve and offensive cooldown spending, using Abaddon as the first concrete case and identifying other multi-role heroes that would benefit. Keep spell mechanics and safety consistent across roles. Build, talent and skill-order differentiation are already handled separately by D2PT; this idea concerns gameplay decisions. The standard-pass fixes in TASK-13.3 are the baseline.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 An Abaddon role-behavior checklist identifies justified support versus core differences and decisions that remain shared, verified against current hero mechanics and strategy sources
- [ ] #2 Comparable support/core scenarios demonstrate the intended differences in Mist Coil heal-versus-damage preference, Shield ally-versus-self preference and resource preservation
- [ ] #3 Urgent saves/dispels and current combat circumstances can override role preferences, including a threatened support shielding self and a core protecting an ally; cast legality and existing safety guards remain valid
- [ ] #4 Offline behavior scenarios cover role differences and overrides, existing shared checks pass, and a support/core lobby checklist is recorded; other candidate heroes are documented without requiring a roster-wide rollout
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Hero tracking consolidation (2026-10-02): historical TASK-13.x records now live in docs/HERO_PASS_REPORT.md, with old-ID/archive links and current status in docs/HERO_PASS_TRACKER.md. This task retains its independent scope and pending criteria. Lobby validation is coordinated by TASK-13.125.
<!-- SECTION:NOTES:END -->
