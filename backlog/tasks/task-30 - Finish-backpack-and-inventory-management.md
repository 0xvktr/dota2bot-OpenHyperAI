---
id: TASK-30
title: Finish backpack and inventory management
status: To Do
assignee: []
created_date: '2026-09-30 15:22'
labels:
  - items
dependencies: []
references:
  - bots/FunLib/inventory_upkeep.lua
  - bots/item_purchase_generic.lua
  - 'https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/51'
priority: low
ordinal: 34000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Upstream feature request 51 lists inventory problems. FunLib/inventory_upkeep.lua now handles consumables stuck in the backpack and sells orphaned starting components, and Moon Shard has a use handler. Still reported: Aegis not picked up with a full inventory; valuable items (boots, key actives) swapped to the backpack for cheaper ones, especially on supports carrying wards and dust; items not completed because components are stuck in the backpack or on the ground. Valve's item_generic mode also handles pickups (and runes), so overriding it is risky.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Aegis is always picked up, making room if needed
- [ ] #2 Boots and key active items are never swapped into the backpack
- [ ] #3 Item builds complete with a full inventory
<!-- AC:END -->
