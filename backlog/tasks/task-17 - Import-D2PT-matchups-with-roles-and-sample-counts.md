---
id: TASK-17
title: Import D2PT matchups with roles and sample counts
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
labels:
  - draft
dependencies: []
references:
  - typescript/bots/FunLib/aba_matchups.ts
  - bots/FretBots/matchups_data.lua
priority: low
ordinal: 17000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Drafting uses two sources: static D2PT synergy/counter lists (aba_matchups.ts, refreshed per migrated hero without role restrictions) and Dotabuff numeric counter scores (FretBots/matchups_data.lua, regenerated 2026-09-28). They can disagree. A normalized D2PT import with roles and match counts would unify them.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Draft scoring reads one matchup source with role and sample information
- [ ] #2 Draft scoring specs still pass
<!-- AC:END -->
