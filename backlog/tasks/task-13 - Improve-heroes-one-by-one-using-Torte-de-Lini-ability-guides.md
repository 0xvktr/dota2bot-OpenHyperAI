---
id: TASK-13
title: Improve hero ability logic one hero at a time
status: To Do
assignee: []
created_date: '2026-09-29 21:29'
updated_date: '2026-09-30 13:59'
labels:
  - hero
dependencies: []
references:
  - tests/ancient_apparition_combo_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
priority: medium
ordinal: 13000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bots play many heroes poorly even with current builds: combos fire in the wrong order, spells are cast in weak situations, and values read from the wrong keys. Guides describe how players use each spell, and Valve's ability data gives the exact mechanics to check the code against.

The process, sources and verification rule are in the hero improvement playbook (doc-2). This task is the umbrella: create one subtask per hero (`backlog task create -p TASK-13 ...`) when work on that hero starts, using the standard pass from the playbook as its acceptance criteria. Heroes on the WeakHeroes list also get the `weak-hero` label and the "Weak heroes playable" milestone.

Torte de Lini guides are cached locally as KeyValues text in `dota 2 beta/game/dota/workshop/steampublic/*.item` (88 guides, 81 heroes as of 2026-09-29; others need the guide opened in game first). Guide and site text is copyrighted: turn it into logic and short own-words comments, never paste it. Ancient Apparition was the pilot (TASK-1).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each reviewed hero's ability logic is checked against its guide tips and verified against Valve's ability data
- [ ] #2 Bugs found are fixed with an offline spec where feasible
<!-- AC:END -->
