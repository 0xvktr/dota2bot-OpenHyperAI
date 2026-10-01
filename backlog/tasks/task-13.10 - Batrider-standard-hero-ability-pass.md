---
id: TASK-13.10
title: 'Batrider: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 14:21'
updated_date: '2026-10-01 14:54'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_batrider.lua
  - bots/FunLib/rubick_hero/batrider.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 50000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Batrider is in the next standard-pass batch after Abaddon/Underlord/Alchemist/Anti-Mage/Arc Warden. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing builds and future role differentiation in TASK-37 remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Validate all four active spells and combos against pinned Valve data/localization, TDL 129332354, and dotacoach Strategy/Counter Strategy/full Matchup sections; record current upgrades and stale advice.
2. Correct Lasso actual reach and direct/interrupt priority, safe Blink landing and total combo mana; prevent repeated Lasso and harmful displacement of existing hard control.
3. Add directional predicted Flamebreak, lane Napalm harassment/Shard structure use, and Firefly wave/stack farming; mirror decisions in the stolen-spell handler without changing builds.
4. Add native/stolen behavioral scenarios, run focused spec and Valve checks, and hand shared-suite validation and lobby status to the parent.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Sources reviewed: pinned d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f Batrider KV and abilities_english localization; Torte guide 129332354 (7.41f); https://dotacoach.gg/en/heroes/batrider Strategy/Counter Strategy; https://dotacoach.gg/en/heroes/counters/batrider all synergy, core items, favorable/unfavorable gameplay matchups and counter-item sections. Valve confirms Napalm point cast 600/radius375, two stacks/cast, cap20/Shard unlimited and structure damage; Flamebreak point1300/speed1700/radius400/knockback250; Firefly no-target flying movement and 15s trail; Lasso unit200, pierces immunity, strong-dispel only, Scepter650 secondary grab. Stale TDL Shard attack-during-Lasso/attack Napalm claims and CDR talent rejected: current attack Napalm is level20 talent and Valve explicitly prohibits attacking during Lasso. Do not infer channel interruption from unused Flamebreak stun_duration; TDL says it does not interrupt. Deprecated facet text, old Solar Crest offensive use and generic item numeric claims are not implemented.

Implemented matching native/stolen decisions with preserved build, skill and talent sections. Lasso uses spell range plus cast bonus (no attack-range/movement allowance); directly reachable channels are interrupted before Firefly/Blink, current Counterspell and existing hard-control targets are skipped, and active Lasso cannot trigger another grab/Blink. Blink landing uses the item range, predicts the grab location, checks passability/major AoE hazards, rejects root/Rupture and reserves Lasso plus Blink mana before optional BKB and Firefly. Flamebreak uses one cast point plus projectile travel and directional explosion offsets to pull chase targets closer or push pursuers away; it avoids disrupting existing Lasso/Black Hole/Chronosphere/Duel/Scythe. Napalm lane harassment works without a creep/combat-target condition, point locations stay legal, actual cluster coverage replaces empty centroids, and Shard structure damage is enabled only through the current special value. Firefly now clears stacked camps/waves with level/mana/threat checks and does not refresh an active buff. Flamebreak multi-creep last hits remain bounded to actual AoE coverage. MinionThink remains the existing generic controller because this hero has no special controllable summons.

Offline checks: tests/batrider_ability_spec.lua prints Batrider ability scenarios passed, covering both native and stolen Lasso range/bonuses/immunity/reflection/block/current Counterspell, channel priority, root/Rupture/passability/hazard/moving landing rejection, directional Flamebreak/actual prediction delay/control protection, lane harassment with no selected hero, spread-creep rejection, Shard structure/Glyph guards, and Firefly farm/active buff. Native combo tests cover scarce mana and protection order; stolen Lasso works without a linked Firefly. Lua 5.1 parse for all three files and targeted git diff --check pass. Valve checker passes at pinned cf0d37a: 128 heroes, 21 copies, zero allowlisted findings. Specialized Rubick smoke passed before concurrent Bane changes; latest rerun is blocked by Bane RememberSave GetTeam stub mismatch and was reported to the parent. Shared-suite result and acceptance/status changes belong to the parent.

Lobby checklist (not run): lane Napalm harass and Firefly clear of real stacked camps; Flamebreak chase/retreat knockback direction and slow/projectile timing; native direct channel interrupt before any preparation; exact Lasso reach with/without cast-range items; Blink/BKB/Firefly queue under low mana and moving targets; no Blink while rooted/Ruptured or dragging a Lasso victim; current Linkens/Lotus/Counterspell interactions; Scepter nearest-secondary grab and strong-dispel saves; Shard tower Napalm/Glyph behavior; Rubick Lasso with/without separately stolen Firefly. Actual drag pathing and the physical Flamebreak landing/knockback need live validation.

Final API review: removed unsupported server-only GetCastRangeBonus usage. Legal cast reach uses bot-compatible Aether Lens cast_range_bonus and trained/unbroken Rubick Arcane Supremacy cast_range values. Native/stolen bodies still match. Arena landing safety now supplies a real 600-unit search radius rather than zero. Focused spec, Valve checker and targeted whitespace pass after these corrections. Latest shared specialized Rubick smoke also passes (85 spell dispatches) after the concurrent Bane harness correction.

Bot-API correction integrated with parent shared J.HasBreakModifier: cast-range bonuses now avoid unsupported PassivesDisabled and GetCastRangeBonus server calls. Focused stolen-Lasso scenarios exercise the real Lens/Supremacy bonus and suppress passive bonus under a known Break modifier. Known Break coverage uses the shared documented modifier list; additional conditional sources remain a lobby/future limitation. Focused Batrider marker and Valve checker pass after integration.

Final integrated verification: node tests/run-builds.cjs passed (exit 0): Lua syntax336 files; Valve128 hero files/21 Rubick copies, zero allowlist findings;127 heroes/253 migrated roles;85 specialized Rubick spell dispatches;58 Rubick hero cases;272 purchase lists; all new hero, Split and Break scenarios. git diff --check passed. Sources and lobby checklist recorded; no game run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Batrider standard pass: legal/direct Lasso interrupts, bounded and mana-budgeted Blink combo, directional Flamebreak, current Napalm Shard and farming Firefly. Native/Rubick scenarios and full offline suite passed; ready for lobby.
<!-- SECTION:FINAL_SUMMARY:END -->
