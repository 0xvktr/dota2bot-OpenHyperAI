---
id: TASK-17
title: Import D2PT matchups with roles and sample counts
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
updated_date: '2026-09-30 15:22'
labels:
  - draft
dependencies: []
references:
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/61'
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

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Upstream issue 61 (original author's comments): human pick and matchup statistics do not transfer fully to bots, because some strong heroes are weak in bot hands (weak list) and bots do not know how to exploit a counter pick. Suggested: exclude weak heroes from recommendations on request and return several weighted options so drafts do not repeat the same heroes.
<!-- SECTION:NOTES:END -->
