---
id: TASK-26
title: Keep enough mana in lane for a kill instead of harassing dry
status: To Do
assignee: []
created_date: '2026-09-30 15:22'
labels:
  - laning
dependencies: []
references:
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/36'
priority: medium
ordinal: 30000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upstream feature request (issue 36): heroes spend spells to harass in lane so often that they lack mana when a kill appears, and in fights a manaless hero is a giant creep. Suggested rules from the original author: harass less at levels 1-2 unless the target is low; do not spend mana on a target about to hide under its tower; keep a reserve (about 200 mana or 30%) in lane; go back to base when mana is very low and slow to recover. Mana reserves in current code are per hero, inside each ConsiderX.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Laning bots keep a mana reserve for a kill combo and harass only above it
- [ ] #2 Spells are not spent on low-value harass near the enemy tower
- [ ] #3 Heroes with very low mana and slow regen go back to heal instead of staying useless
- [ ] #4 Offline spec covers the reserve decision
<!-- AC:END -->
