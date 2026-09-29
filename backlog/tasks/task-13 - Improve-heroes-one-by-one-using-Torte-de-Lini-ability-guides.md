---
id: TASK-13
title: Improve heroes one by one using Torte de Lini ability guides
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
labels:
  - hero
dependencies: []
references:
  - tests/ancient_apparition_combo_spec.lua
priority: medium
ordinal: 13000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Torte de Lini guides add per-ability tips and combos. Dota caches the guides the player has opened as KeyValues text in dota 2 beta/game/dota/workshop/steampublic/*.item (88 guides, 81 heroes as of 2026-09-29; heroes without a cached guide need it opened in game first). Their AbilityTooltips/ItemTooltips sections are a checklist for each hero's ConsiderX logic. Guide text is copyrighted: turn it into logic and short own-words comments, never paste it. Ancient Apparition was the pilot.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each reviewed hero's ability logic is checked against its guide tips and verified against Valve's ability data
- [ ] #2 Bugs found are fixed with an offline spec where feasible
<!-- AC:END -->
