---
id: TASK-13.13
title: 'Bloodseeker: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 15:23'
updated_date: '2026-10-01 15:54'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_bloodseeker.lua
  - bots/FunLib/rubick_hero/bloodseeker.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 53000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bloodseeker is in the next standard-pass batch after Axe/Bane/Batrider/Beastmaster/Brewmaster. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing D2PT builds, separate TASK14 build findings and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile pinned Valve/localization, TDL physical/magic guides and dotacoach Strategy/Counter/full Matchup against current self Bloodrage, passive Thirst and Rupture immunity. 2. Fix Rupture legal range and solo/immune target selection, delayed Rite placement/laning/farming precedence, Bloodrage follow-through and Mist toggle state in native and stolen spells; preserve builds. 3. Add behavior scenarios and source exclusions/lobby checklist; root integrates Valve/shared suite and finalizes.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01 standard pass):
- [x] Pinned Valve KV and English localization at cf0d37a32c8df338a7832fd32a282747969e9a5f: https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_bloodseeker.txt ; localization game/dota/pak01_dir/resource/localization/abilities_english.txt in this snapshot. Bloodrage is an immediate self buff, Thirst passive; Rite radius600 with0.3+2.6 seconds delayed pure damage and no immunity piercing; Rupture pierces immunity, current-health initial damage and movement damage, with two Scepter charges and +5 percentage points initial damage. Mist is a live Scepter toggle, radius450, self damage7%/second, three-second cooldown preventing instant switch-off.
- [x] Torte de Lini workshop guides128754907 (magic) and319092835 (physical), both7.41f, fetched through tools/tdl/fetch.cjs. Adopted Rupture before ritual, delayed self amplification, farm buff and pursuit/control rationale. No guide text copied.
- [x] dotacoach Strategy/Counter: https://dotacoach.gg/en/heroes/bloodseeker . Adopted contested ranged-creep ritual, mobility-core Rupture through BKB and need for follow-up against TP escapes; noted reflection/spell block and healing suppression counterplay.
- [x] Complete Matchup including synergy, core items, favorable/unfavorable opponents and counter items: https://dotacoach.gg/en/heroes/counters/bloodseeker . Control from Pudge/Magnus/Willow and forced movement provide ritual/Rupture context; global damage supports Thirst pursuit. Invulnerable movement, saves and sustain limit damage. Reviewed BKB, Mjollnir, Abyssal, Atos/Gleipnir and Refresher recommendations without changing builds.

Source exclusions: Old public ally Bloodrage amplification for Leshrac/Zeus is impossible after7.41 self-only change. Thirst no longer casts or directly supplies healing; healing belongs to Sanguivore. Current Shard adds attack pure damage, not the old attack heal. Bloodrage enemy silence and obsolete facet casting excluded. TDL claim that Blade Mail reflects self Bloodrage drain is unsupported and not encoded. Public Blood Mist/Scepter advice is inconsistent: authoritative Scepter charge/initial damage and retained live Mist KV/localization are separated; Mist only considered when actual activated ability exists. No blanket assumptions about blink/teleport or invulnerable movement Rupture damage.

Implementation: Native and copy now cast Rupture at legal range including immune/disabled targets and solo pursuit, avoid Counterspell/advanced block and duplicate Rupture. Native order is emergency Mist-off, Rupture, Rite, self Bloodrage, optional Mist-on. Rite predicts full2.9-second completion, clamps cast point within reach, uses actual ritual radius, covers Ruptured target choice and retreat path, secures contested ranged creep, and requires explicit push/defend/farm mode with no enemy before unattended clear. Fixed waveclear boolean precedence and removed passive Thirst casts. Bloodrage accelerates sustained farm/objectives without retreat self drain. Mist toggle predicate fixed, eligible enemy/health checks prevent idle drain. Dedicated copies preserve recognized skip vs generic fallback. Range helpers add only active Lens225 and copy trained/unbroken Supremacy, not generic movement allowance. D2PT build/skill/talent prefixes unchanged.

Offline verification: tests/bloodseeker_ability_spec.lua passes marker Bloodseeker ability scenarios passed; includes native/copy solo BKB Rupture, legal boundary/reflection/redundancy, emergency retreat, full-delay ritual/clamp, idle clear regression, contested ranged creep pure damage, Mist on/off/low health, farm/retreat buff and native Rupture->Rite->Bloodrage sequence. git diff --check clean. Root owns Valve/full suite integration and criteria/status.

Lobby checklist: (1) Solo pursuit against BKB Pangolier, allied stun ending into Rupture, repeat charges on second hero; Counterspell/Linkens/Lotus skips. (2) Rupture->Rite->Bloodrage against moving target/TP response; confirm full ritual timing and actual talent/Lens/Supremacy range to rule out engine bonus double-counting. (3) Contested ranged creep and camp/idle clear; inspect AoE search prediction against real enemy immunity/invulnerability. (4) Scepter actual ability availability/Mist toggle three-second lock, critical HP switch-off timing and invulnerable/immune enemies. (5) Stolen self buff and Rite/Rupture parity. No lobby/game launched. Role differentiation/build findings remain separate.

TASK21/24 candidates: BKB before committed right-click damage, Mjollnir Static Charge on active frontliner/creep, Abyssal/Atos interrupt Ruptured TP and keep target in Rite, Refresher reserve mana for several Ruptures; enemy Lotus/Linkens/Counterspell response and invulnerable mobility exceptions. No generic item code modified.

Final targeted-spell review: native and stolen Rupture also reject modifier_antimage_counterspell_ally, matching current allied reflection localization. Both native/copy protection regressions pass; Bloodseeker ability scenarios passed marker confirmed.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 with all five new hero success markers and prior regressions. Lua syntax: 341 files; pinned Valve check: 128 native hero files / 21 Rubick copies / 0 allowlisted findings; builds: 127 heroes / 253 roles; specialized Rubick: 85 dispatches; Rubick hero behavior: 59 cases; purchase planning: 272 buy lists. git diff --check passed. Scripted HEAD comparison confirms all five build/skill/talent prefixes unchanged. Lobby scenarios remain pending; no game launched. Standard pass is ready for in-game testing, with documented engine/capability limits.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated native/stolen Bloodseeker Rupture immunity/range/priority, delayed Rite placement and laning/farming, self Bloodrage and safe Mist toggling; removed passive Thirst commands. Guide/Valve/full dotacoach audit and focused scenarios recorded. Full suite/Valve/diff checks pass; lobby validation pending.
<!-- SECTION:FINAL_SUMMARY:END -->
