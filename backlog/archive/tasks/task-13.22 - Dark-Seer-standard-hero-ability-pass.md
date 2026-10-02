---
id: TASK-13.22
title: 'Dark Seer: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 16:04'
updated_date: '2026-10-01 16:37'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_dark_seer.lua
  - bots/FunLib/rubick_hero/dark_seer.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 62000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Dark Seer is in the next standard-pass batch after Bloodseeker/Bounty Hunter/Bristleback/Broodmother/Centaur. Review current ability decisions and combos against guide strategy and authoritative mechanics, including applicable Rubick handling. Existing D2PT builds and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile pinned Valve/localization, TDL129331714 and full dotacoach advice; distinguish passive Normal Punch and vector Wall limitations from stale universal/facet tips. 2. Preserve builds; fix Vacuum interrupts, actual-range predicted AoE and safe budgeted initiation/combo, without suppressing standalone spells whenever Blink is ready. Improve legal sustained Ion Shell hosts and prioritized ally Surge saves/chases with roots/Rupture/redundancy guards. 3. Add faithful behavior scenarios, audit actual bot API cast shapes, record source exclusions and lobby limitations; run focused/Valve/full suite and route item/counterplay observations to existing tasks.

Valve flags current Wall as vector-targeted, while the bot API only exposes a single point. Retain the existing point path only when the live behavior does not require vector targeting; otherwise decline unsupported Wall/Wall combos explicitly. Fix independent Vacuum/Blink initiation and stop ready-but-unusable Wall from suppressing those decisions. Record current vector Wall and custom endpoint orientation as pending engine/API validation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01): pinned Valve Dark Seer KV and English localization at cf0d37a32c8df338a7832fd32a282747969e9a5f; tests/valve/abilities.json matches. https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_dark_seer.txt . Vacuum is a 0.4s point cast plus 0.3–0.6s pull before magical damage; full actual radius and legal cast reach matter. Ion Shell targets heroes/creeps on either team and damages surrounding enemies, never its host; allied casts and expiring buffs are distinguished from enemy reflection. Surge is friendly mobility/slow immunity, not a dispel of roots or Rupture. Wall pierces immunity but is vector-targeted; Normal Punch is passive Scepter attack behavior, not an active spell. Existing bot API reference/types expose only single-location orders, with no verified two-endpoint action. No custom game/server-only setter is assumed.
TDL Workshop129331714, offlane /7.41f, fetched with tools/tdl/fetch.cjs. Reviewed all ability/item tips: durable melee wave hosts, mobile melee allies and replicas, Surge escapes, Vacuum setup followed by Wall, and mana/sustain/team-aura timing. Excluded universal attribute commentary, obsolete generic cooldown talent, enemy Solar Crest, stale item recipes and blanket status-resistance claims. Builds/skills/talents remain unchanged.
dotacoach https://dotacoach.gg/en/heroes/dark-seer Strategy/Counter and https://dotacoach.gg/en/heroes/counters/dark-seer full Matchup including gameplay synergies, favorable/unfavorable heroes, core/counter items reviewed. Applied useful frontliner Shell and Surge saves/chases, dangerous-lane creep hosts and clustered Vacuum setups. Reviewed control synergies, sustain/armor/dispels and the value of replica targets. Rejected unsupported Shiva AoE amplification, terrain phasing, and broad BKB/illusion-inheritance claims. Naga Song invulnerability interaction, precise item/passive replication and special cliff placement require engine evidence before coding.

Implementation: actual-range clamped/predicted Vacuum interrupts, conservative lethal timing through completed pull, actual eligible cluster checks, pursuit/retreat control and safe mana-budgeted Blink initiation. Ready Blink/Wall no longer suppress standalone Vacuum; allied identity prevents counting the initiator twice in safety decisions and shouldBlink resets when no coordinated action is selected. Surge saves the threatened legal ally rather than measuring the pursuer against cast range, permits chase/escape from BKB foes and works with an existing Shell; refuses roots/Rupture, channels, duplicate buffs and disabled targets. Shell selects nearby useful frontliners, mobile melee chasers and durable melee creep hosts, can carry wave damage on legal enemy creeps, avoids replacing a long buff and checks actual enemy damage coverage excluding the host. Farm mana preserves trained Surge; self Shell supports neutral clusters and objectives. New dedicated Rubick Dark Seer handler mirrors standalone Vacuum/Shell/Surge; vector Wall explicitly declines instead of unsafe generic fallback. Current Wall/combos are declined while live metadata requires vector targeting; a nonvector point-only compatibility path retains existing point orders and derives pull-to-Wall timing from live values. No claim of a complete current Wall combo or selectable endpoints. Passive Normal Punch is never cast.
Focused evidence: tests/dark_seer_ability_spec.lua emits Dark Seer ability scenarios passed for native/copy, including outer radius and full delay, moving targets, immunity/death protection, mana/identity/range/hazard Blink cases, legal ally save and root/Rupture/BKB cases, expiring Shell, durable/reflecting enemy wave hosts, allied BKB host, objectives, safe farm reserve and current vector Wall refusal. Shared runner/source registration and integrated results are owned by root.

Lobby checklist (pending; no game launched): Dark Seer/Rubick plus melee chaser/Batrider/area-control ally versus BKB/Oracle/Bloodseeker/ranged core. Confirm actual Vacuum prediction, channel interruption and pull-end damage; Blink landing reach and safety. Verify ally BKB Shell, expiring Shell replacements, wave-host lifetimes and owned replica hosts; double-shell lane decisions. Test Surge saves/chases while already Shelled, roots/Rupture and Shard trail/talent area. Validate current Wall single-point engine behavior or obtain a bot API for two endpoints before enabling current vector Wall/combos; verify innate/Punch attack behavior, upgrade linkage, Lens/Supremacy engine range reporting and copied range under Break. Normal Punch aim/minion replica targeting remain broader movement/coordination work. Counter/item inputs routed to TASK21/24; no builds/draft edits.

Integration review restored explicit self-Shell on nearby attacked Roshan/Tormentor and added objective regressions plus trained-Surge farm reserve. The new Rubick handler also queues its own safe Blink -> Vacuum when direct interrupts/lethals do not take priority; native and copy queue scenarios pass without requiring linked Wall. Shared smoke mocks were updated for current APIs; prior hero behavior remains covered in the full suite.

Final review repaired a creep-only API hazard: proactive melee-chase Shell checks hero identity before hero target/mode helpers. Restored Roshan/Tormentor travel Surge with available-spell mana reserves, including a missing-Vacuum Rubick case; current stolen handles refresh before dispatch. Regression assertions cover real creep hosts, objective Shell, travel budgets and missing linked abilities. Focused Dark Seer marker passes.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 after all review repairs; exact markers confirmed for all five new hero specs, 348 Lua files parsed, Valve check 128 native heroes / 22 Rubick copies / 0 allowlisted findings, 127 hero role tables, 90 specialized dispatches, 61 Rubick behavior cases and 272 purchase lists. git diff --check passed. HEAD comparison confirms this hero build/skill/talent prefix unchanged. No lobby launched; standard pass handed off as Needs In-Game Test, with capability limits above. Item/counterplay findings appended to TASK21/24.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Dark Seer native and new dedicated Rubick handler now use predicted/range-bounded Vacuum, safe budgeted Blink, legal Surge saves/travel and useful Ion Shell hosts/objectives. Builds preserved. Focused scenarios, final shared suite and Valve check passed. Current vector Wall is explicitly withheld pending a verified endpoint API; conditional nonvector compatibility remains. Lobby checklist recorded.
<!-- SECTION:FINAL_SUMMARY:END -->
