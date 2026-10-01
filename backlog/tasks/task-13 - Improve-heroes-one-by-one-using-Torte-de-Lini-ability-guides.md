---
id: TASK-13
title: Improve hero ability logic one hero at a time
status: In Progress
assignee:
  - '@codex'
created_date: '2026-09-29 21:29'
updated_date: '2026-10-01 14:54'
labels:
  - hero
dependencies: []
references:
  - tests/ancient_apparition_combo_spec.lua
  - tools/tdl/fetch.cjs
  - tools/tdl/guides.json
  - tests/valve_ability_check.cjs
  - tests/hero_harness.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
priority: medium
ordinal: 13000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bots play many heroes poorly even with current builds: combos fire in the wrong order, spells are cast in weak situations, and values read from the wrong keys. Guides describe how players use each spell, and Valve's ability data gives the exact mechanics to check the code against.

The process, sources and verification rule are in the hero improvement playbook (doc-2); read it first. This task is the umbrella: create one subtask per hero (`backlog task create -p TASK-13 ...`) when work on that hero starts, using the standard pass from the playbook as its acceptance criteria. Heroes on the WeakHeroes list also get the `weak-hero` label and the "Weak heroes playable" milestone.

Torte de Lini guide tips are available on any machine: `node tools/tdl/fetch.cjs <hero>` downloads the hero's guide(s) from the Steam Workshop and prints the ability and item tips (136 guides, 126 heroes indexed in tools/tdl/guides.json; Spirit Breaker has none). The ability tips lean toward the laning stage, some heroes have two guides that differ mainly in items, and guides written for 7.41b-e are kept because their ability tips still apply. Guide and site text is copyrighted: turn it into logic and short own-words comments, never paste it.

Ancient Apparition was the pilot (TASK-1, TASK-13.1) and shows the shape of a finished hero: an offline spec in tests/, fixes checked against Valve data, then a lobby test.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each reviewed hero's ability logic is checked against its guide tips and verified against Valve's ability data
- [ ] #2 Bugs found are fixed with an offline spec where feasible
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-10-01 handoff state. Done: playbook (doc-2); roster-wide Valve-data check (TASK-23, 43 findings fixed, also covers Rubick's copies); AA rework and follow-up (TASK-1 and TASK-13.1, both awaiting lobby confirmation); Torte de Lini index and fetch script (tools/tdl). All 127 heroes have D2PT 7.41f builds, so hero files are no longer being edited by a migration in parallel.

Next hero: pick one, create a TASK-13.x subtask, then run `node tools/tdl/fetch.cjs <hero>`, read dotacoach /en/heroes/<slug> and /en/heroes/counters/<slug>, and compare both with SkillsComplement() and each ConsiderX() in bots/BotLib/hero_<hero>.lua. Heroes on the WeakHeroes list in bots/hero_selection.lua are the natural first candidates (Chen, Tinker, Pangolier, Tusk, Morphling, Visage, Void Spirit, Ember Spirit, Rubick, Brewmaster, Puck, and the Valve-buggy group). If the hero has a FunLib/rubick_hero/<hero>.lua copy, mirror the fix there. Counter-strategy ideas go to TASK-24, item usage tips to TASK-21. Verify with a spec built on tests/hero_harness.lua (see tests/ancient_apparition_combo_spec.lua), `node tests/valve_ability_check.cjs` and `node tests/run-builds.cjs`, then set the subtask to Needs In-Game Test.

2026-10-01: Dazzle standard pass is TASK-13.2, now Needs In-Game Test. Saves/healing, Wave geometry and Scepter, lane Poison and safe Projection/body exit updated; dedicated spec, Valve check and full build suite pass. Next hero pass remains unstarted; Dazzle lobby checklist is in TASK-13.2.

2026-10-01: Next standard batch completed offline: Abaddon TASK-13.3, Underlord TASK-13.4, Alchemist TASK-13.5, Anti-Mage TASK-13.6 and Arc Warden TASK-13.7 are now Needs In-Game Test with all standard-pass AC checked. Each native hero and applicable Rubick copy reviewed against TDL, dotacoach Strategy/Counter Strategy/full Matchup, pinned Valve KV/localization; source checklists, stale claims, changes and lobby cases recorded in its subtask. Five meaningful specs registered in run-builds; final full suite/Valve check/diff whitespace pass, including existing Dazzle regression. Underlord Gate travel required a narrow Rubick pending-action hook before normal cooldown/silence gating. Item and enemy counterplay findings appended to TASK-21/TASK-24; builds, gifting, generic item/minion/draft tables unchanged. Umbrella remains In Progress for future heroes. No lobby validation performed.

Second standard batch completed: TASK13.8 Axe,13.9 Bane,13.10 Batrider,13.11 Beastmaster and13.12 Brewmaster all have3/3 standard-pass AC checked and are Needs In-Game Test. Source audits include pinned Valve/localization, TDL and dotacoach Strategy/Counter/full Matchup. Native+Rubick behavior updated and six focused hero/Split specs added, plus shared bot-compatible Break regression. Builds/items/talents retained; TASK21/24 findings appended; TASK37 role differentiation untouched. Final node tests/run-builds.cjs exit0:336 Lua files,128 native/21 Rubick Valve checks with zero allowlist findings,127 heroes/253 roles,85 specialized dispatches,58 Rubick cases and272 purchase lists; git diff --check passed. No lobby launched. Brewmaster remains on WeakHeroes and requires separate deep-dive evidence; automated Scepter Split cancellation awaits engine semantics. API audit also corrected prior Abaddon/Alchemist server-only passive-state calls with verified modifier checks.
<!-- SECTION:NOTES:END -->
