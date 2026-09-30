---
id: TASK-13.1
title: >-
  Ancient Apparition: Ice Blast target priority, creep-safe harass and Shard
  stun
status: To Do
assignee: []
created_date: '2026-09-30 13:59'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_ancient_apparition.lua
  - tests/ancient_apparition_combo_spec.lua
  - 'https://dotacoach.gg/en/heroes/ancient-apparition'
  - 'https://dotacoach.gg/en/heroes/counters/ancient-apparition'
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
type: enhancement
ordinal: 28000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Deep-dive follow-up to the AA rework (TASK-1). A second review against dotacoach's hero and counters pages and a video on Ice Blast mechanics (2026-09-30) found three gaps. Fights are aimed only by how many heroes the blast hits, but its main value is healing prevention and the shatter threshold, which matter most against heroes that rely on healing or have large HP pools (Huskar, Alchemist, Necrophos, Io, Bristleback, Morphling, Leshrac, Troll). The lane harass added in the rework avoids enemy towers but can still draw lane-creep aggro. With Aghanim's Shard, Ice Blast's explosion stuns for 50% of Cold Feet's stun, which the fight logic does not value yet (Cold Feet already follows onto stunned enemies).

Some source claims are doubtful and must be checked against Valve data before use: dotacoach says Wind Waker dispels Ice Blast (Valve marks it not dispellable) and that Abaddon can die during Borrowed Time under Ice Blast.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 In fights, Ice Blast prefers heroes that rely on healing or have large HP pools when the number of heroes hit is equal or close
- [ ] #2 Chilling Touch lane harass is skipped when the attack would draw enemy lane-creep aggro
- [ ] #3 With Aghanim's Shard, Ice Blast is valued as an AoE stun in close fights and Cold Feet follows on the stunned enemies
- [ ] #4 Source claims used by the new logic are confirmed against Valve ability data
- [ ] #5 Offline specs cover the new decisions
<!-- AC:END -->
