---
id: TASK-11
title: 'Coordinate team fights: initiation order, follow-ups, saves and focus'
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
updated_date: '2026-09-29 22:14'
labels:
  - teamfight
dependencies: []
references:
  - bots/mode_attack_generic.lua
  - bots/FunLib/fight_response.lua
documentation:
  - backlog/docs/doc-1 - OpenAI-Five-lessons-for-the-bot-scripts.md
priority: low
ordinal: 11000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Fight target choice and movement are Valve's default attack mode for most heroes (mode_attack_generic only overrides Valve-buggy heroes); only spells come from each hero's SkillsComplement. Bots do not initiate with the key ult first, chain disables, save the ally actually being focused, or focus one target. fight_response.lua is a start at team-level coordination. Hard to do right; important eventually.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Initiators open with their initiation spell before others commit
- [ ] #2 Follow-up disables chain rather than overlap
- [ ] #3 Save spells target the ally under focus
- [ ] #4 Allies converge on one target in a fight
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
OpenAI Five (doc-1, section 4): unlike humans, the final agent spent long-cooldown spells and consumables readily instead of holding them, and judged low-HP aggression well. Once a fight is on, holding ultimates for a better moment is a real cost.
<!-- SECTION:NOTES:END -->
