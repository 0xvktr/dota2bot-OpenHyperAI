---
id: TASK-21.1
title: 'Save items: pick the threatened ally and the right moment'
status: To Do
assignee: []
created_date: '2026-09-29 22:03'
updated_date: '2026-09-29 22:14'
labels:
  - teamfight
dependencies: []
documentation:
  - backlog/docs/doc-1 - OpenAI-Five-lessons-for-the-bot-scripts.md
parent_task_id: TASK-21
priority: medium
ordinal: 22000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Glimmer Cape, Force Staff, Hurricane Pike, Ghost Scepter, Eul's Scepter, Wind Waker, Lotus Orb and similar. Humans save the ally who is being focused or disabled, at the moment the burst or stun lands, and Force Staff also pulls an ally out of a gank or away from a chasing melee hero. Current handlers use HP thresholds and the first valid ally in range.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Saves go to the ally under focus or disable rather than the first ally in range
- [ ] #2 Saves are timed to incoming burst, disables or chasers, not just low HP
- [ ] #3 Force Staff and Hurricane Pike push allies away from the threat, not toward it
- [ ] #4 Offline specs cover target choice for each item
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
OpenAI Five's reward (doc-1, section 5) values HP on a concave curve: the last part of a hero's HP is worth the most (at 20% HP about 40% of the value remains). Saves should weigh how close the ally is to dying, not just a flat HP threshold.
<!-- SECTION:NOTES:END -->
