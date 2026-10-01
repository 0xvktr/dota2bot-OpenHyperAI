---
id: TASK-13
title: Improve hero ability logic one hero at a time
status: In Progress
assignee:
  - '@codex'
created_date: '2026-09-29 21:29'
updated_date: '2026-10-01 18:12'
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

Third standard batch completed offline: Bloodseeker TASK-13.13, Bounty Hunter TASK-13.14, Bristleback TASK-13.15, Broodmother TASK-13.16 and Centaur TASK-13.17 each have 3/3 standard-pass criteria checked and are Needs In-Game Test. Audits cover pinned Valve/localization, TDL and full dotacoach Strategy/Counter/Matchup, with stale claims, item/counterplay inputs and lobby checklists recorded. Native and applicable Rubick behavior improved; five focused specs registered. Rubick has a narrow pending-Stomp movement hook preserving observed windup after cooldown. Final full suite exited 0: 341 Lua files, 128 native/21 copy Valve checks with zero allowlisted findings, 127 heroes/253 roles, 85 specialized dispatches, 59 Rubick cases and 272 purchase lists. Diff whitespace and all five unchanged build/skill/talent prefixes verified. TASK21/24 observations appended; TASK14 builds and TASK37 role differentiation untouched. No lobby launched. Broodmother vector-target Snare requires a proven bot endpoint API; Bristleback Scepter facing and live stolen upgrade/range semantics have explicit lobby cases. Umbrella remains In Progress for subsequent heroes.

Fourth standard batch completed offline: Chaos Knight TASK13.18, Chen TASK13.19, Clinkz TASK13.20, Crystal Maiden TASK13.21 and Dark Seer TASK13.22 have 3/3 standard-pass AC checked and are Needs In-Game Test. Audits include pinned Valve/localization, TDL and dotacoach Strategy/Counter/full Matchup, stale exclusions and lobby scenarios. Native/applicable Rubick fixes and five meaningful specs integrated, plus dedicated Dark Seer copy and narrow observed CM Field / Clinkz Barrage channel exceptions. Chen has narrowly controlled Martyrdom minion handling, retains weak flag/milestone and still requires an army deep dive. Final full suite exit0: 348 Lua files, 128 native/22 copy Valve checks with no findings, 127 heroes/253 roles, 90 dispatches, 61 Rubick cases and 272 purchase lists. Whitespace and all five build/skill/talent prefixes verified. TASK21/24 findings appended; builds and role differentiation unchanged. No lobby launched. Current vector Wall and Burning Army remain withheld until endpoint API/engine evidence exists. Parent remains In Progress for the remaining roster.

Fifth standard batch completed offline: Dark Willow TASK13.23, Dawnbreaker TASK13.24, Death Prophet TASK13.25, Disruptor TASK13.26 and Doom TASK13.27 have3/3 standard-pass criteria checked and are Needs In-Game Test. Source audits include pinned Valve/localization, TDL and full dotacoach Strategy/Counter/Matchup with stale exclusions/lobby scenarios. Native and five new dedicated Rubick handlers integrated. Narrow channel-safe Realm and pending Converge hooks preserve generic gates, and Glimpse observes visible history across cooldown gates. Doom enables reviewed acquired Stomp/Purge/Lightning rather than unknown effects. Final suite exited0 after final Starbreaker teamfight repair:358 Lua files,128 native/27 copy Valve checks with zero findings,127 heroes/253 roles,112 dispatches,64 Rubick cases and272 purchase lists. Whitespace and byte-identical build/skill/talent prefixes verified. TASK21/24 findings recorded; builds/role differentiation unchanged. Dark Willow retains weak/buggy flags and awaits separate deep-dive/lobby evidence; no game launched. Current vector Fence is withheld pending endpoint API, while charged Realm attack policy, actual copied linkage/range and other engine boundaries are documented. Parent remains In Progress for subsequent roster passes.

Sixth standard batch completed offline: Dragon Knight TASK13.28, Drow Ranger TASK13.29, Earth Spirit TASK13.30, Earthshaker TASK13.31 and Elder Titan TASK13.32 each have3/3 standard-pass criteria checked and are Needs In-Game Test. Source audits include pinned Valve/localization, TDL and full dotacoach Strategy/Counter/Matchup with stale exclusions and lobby boundaries. Native and five dedicated Rubick handlers improved; narrow observed Glacier/Multishot, Magnetize Stone refresh and owned Astral Spirit/minion routing integrated. Independent review fixed short-TP Stomp timing, persisted Spirit touches and physical-immunity lethal estimates; final Roll/Smash/Grip/Echo timing and linkage scenarios added. Final suite exited0:368 Lua files,128 native/32 copy Valve checks with zero findings,127 heroes/253 roles,133 dispatches,68 Rubick cases and272 purchase lists. All five build/skill/talent prefixes unchanged; whitespace clean. TASK21/24 inputs recorded; role differentiation/draft work unchanged. No WeakHeroes flags changed or lobby launched. Engine-only copied grants, movement/upgrade details and Elder Titan alt-cast swap remain documented lobby checks. Parent remains In Progress for remaining roster; no new commit/push in this batch.

Commit/push integration (2026-10-01): remote main advanced through6616fcb item policy and3c1501b early lane-defense. Rebase preserves both remote commits and all20 hero passes. BB Hairball/ordinary Quill retain selected ability handles for item/Treads policy. CK retains remote Clear/action lock and useful low-mana Chaos Bolt consideration, validated restoration in urgent/ordinary branches, and ability-aware normal Bolt/Rift/Phantasm prep; urgent Bolt retains immediate priority, and failed restoration allows other spells. Faithful CK tests cover enabling Mango, changed target, post-restoration reconsideration, no-item Rift fallback and queued lock. Independent merged review passed. Combined node tests/run-builds.cjs and node tests/run-objectives.cjs both exited0;375 Lua files,128 native/32 copy Valve checks with zero findings,133 copied dispatches,68 Rubick cases and272 purchase lists, plus remote item-policy and lane-defense/objective regressions. No game launched.
<!-- SECTION:NOTES:END -->
