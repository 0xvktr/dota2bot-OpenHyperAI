---
id: TASK-28
title: Buy counter items against the enemy lineup
status: To Do
assignee: []
created_date: '2026-09-30 15:22'
labels:
  - items
dependencies: []
references:
  - bots/FunLib/advanced_item_strategy.lua
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/45'
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/25'
priority: low
ordinal: 32000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upstream feature request 45 (and the item-build discussion in issue 25): builds are fixed per hero, so bots never answer the enemy lineup, such as MKB against evasion (PA), detection against Riki, or BKB against disables, and supports and cores do not split counter items by cost. FunLib/advanced_item_strategy.lua (TypeScript-generated) already defines counter lists (evasion, specific heroes such as PA, Riki and Anti-Mage), but nothing calls it, so it is dead code. D2PT builds (TASK-4) must stay the default; counters are adjustments on top.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Bots add or swap in a counter item when the enemy lineup calls for it, cores buying the damage counters and supports the cheap ones
- [ ] #2 Counters never replace a hero's core D2PT items
- [ ] #3 advanced_item_strategy is either wired in via its TypeScript source or removed
<!-- AC:END -->
