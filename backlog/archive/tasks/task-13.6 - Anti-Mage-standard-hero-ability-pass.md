---
id: TASK-13.6
title: 'Anti-Mage: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 13:29'
updated_date: '2026-10-01 14:05'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_antimage.lua
  - bots/FunLib/rubick_hero/antimage.lua
  - 'https://dotacoach.gg/en/heroes/anti-mage'
  - 'https://dotacoach.gg/en/heroes/counters/anti-mage'
  - tests/antimage_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 45000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Anti-Mage is part of the next standard hero batch after Dazzle. Review current spell decisions and combos against guide strategy and current Valve mechanics, including the dedicated Rubick copy, to address weak or incorrect ability use.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against Valve definitions and localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and Matchup advice; findings and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the hero and applicable Rubick copy, with meaningful offline behavior scenarios
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and task is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Review complete Anti-Mage and Rubick ability decisions against pinned Valve definitions/localization, Torte de Lini tips, and dotacoach Strategy, Counter Strategy and Matchup.
2. Prioritize reactive Counterspell and direct Mana Void; select lethal AoE sources and channel interrupts, then use bounded safe Blink-Void only when direct casting cannot reach.
3. Guard removed/hidden legacy upgrade abilities; mirror applicable fixes for Rubick without changing builds or shared helpers.
4. Add offline scenarios for AoE source selection, channel interrupts, cast priority, rooted/Ruptured and range-safe Blink-Void, legacy absence, and stolen spell decisions; run focused regression and Valve check.
5. Record source checklist, stale advice, cross-task observations and lobby checklist. Wait for parent integration evidence before acceptance/status finalization.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist and review (2026-10-01):
- Reviewed pinned Valve Anti-Mage hero/AbilityDefinitions at cf0d37a32c8df338a7832fd32a282747969e9a5f and current English localization (local /tmp/dazzle-abilities-english.txt). Mana Void uses primary missing mana for all nearby enemies and ministuns the primary; Blink is root-disabled; Counterspell is an immediate targeted-spell reflector. Spell Shield/Mana Thirst definitions and facets are deprecated or absent from active slots. Current Scepter strengthens Mana Break and the next hit after Blink; Counterspell Shard creates a fragment after reflection. Counterspell Ally and Blink Fragment retained definitions do not establish current availability.
- Read Torte de Lini Workshop guide 128960249 (7.41f) via node tools/tdl/fetch.cjs antimage, including ability and item tips. Checklist: lane Mana Break harass, Blink engage/escape/farming, Counterspell against reaction spells, Mana Break/Manta before Void, primary-channel interrupts. Existing farm-mode CouldBlink already handles camp/wave travel, so this pass does not duplicate it in hero ability logic.
- Read https://dotacoach.gg/en/heroes/anti-mage Strategy and Counter Strategy and full https://dotacoach.gg/en/heroes/counters/anti-mage Matchup: gameplay synergy, good/bad opponents, core/advanced item usage and counter items. Checklist: safe farming/split push, opportunistic low-mana snipes, high-max-mana AoE source, targeted-spell reflection, root/silence threats, Manta dispel and Blink-Abyssal-Manta sequence. Rolling matchup win rates were not translated into mechanics or drafting changes.
- Reviewed full SkillsComplement and all Consider functions, MinionThink and Rubick copy. Build, talents, items and shared farm/minion/item/draft helpers remain outside this pass.

Implemented:
- Counterspell reacts before offensive Blink-Void, avoids refreshing its current shell, and no longer suppresses anticipation solely because Assassinate is marked.
- Direct Mana Void precedes Blink, works outside attack/teamfight modes for lethal snipes, and interrupts a channel even when the enemy has full mana.
- Mana Void evaluates every visible valid primary in actual cast range against splash victims; it chooses the most lethal AoE rather than the first directly killable target. A surviving drained primary (including an Aegis holder) can supply lethal splash to nearby enemies. Primary spell shields/reflection and invulnerability, illusion/double, immunity and protected victims are excluded.
- Blink-Void requires both spell costs, no root/Rupture/retreat, balanced nearby numbers, and an in-range/passable landing short of the target with 100 units of Void margin; it never queues Blink for an already reachable Void target.
- Missing or hidden Counterspell Ally and hidden Blink Fragment are safe; dormant Fragment minimum-health selector comparison is corrected. Rubick mirrors direct Void/interrupt/splash and Counterspell/legacy guards. Stolen Blink alone now allows defensive projectile dodges without requiring a Counterspell handle.

Stale/rejected advice:
- TDL still exposes old passive Spell Shield, Fragment scouting/farming and Counterspell Ally saves. Its Scepter lower-Blink-cooldown claim conflicts with current Valve values; only empowered Mana Break is used as current strategy. Deprecated Mana Thirst/facet values are not used. TDL says the Void ministun affects everyone hit, while current localization identifies the primary; interrupts are selected on the primary only.
- TDL Nullifier text describes Windrun/Jingu as passive abilities; do not infer break/passive disable from it. dotacoach Underlord Shard Firestorm-on-AM synergy needs verification in the Underlord pass before implementation. Generic item and enemy counterplay observations sent to parent for TASK-21/TASK-24; no item handler/draft changes here.

Focused verification:
- tests/antimage_ability_spec.lua emits Anti-Mage ability decisions passed. Scenarios exercise splash source surviving, multi-kill source ranking, full-mana channel interrupt, cast-range boundary, spell block/reflection, illusions, immunity/protected victims and radius, Aegis primary splash, direct Void/Counterspell cast priority, bounded Blink landing, root/Rupture/retreat/mana/number/passability guards, absent legacy ally ability, hidden Fragment and Rubick equivalents/dodge.
- Focused Lua 5.2 parser check passed for the hero, Rubick copy and new spec. node tests/valve_ability_check.cjs passed (128 heroes, 21 Rubick copies, 0 allowlisted findings, cf0d37a).
- Parent owns registering the spec in tests/run-builds.cjs and shared integration suite. Awaiting its result before AC/status finalization.

Lobby checklist:
1. Drained high-max-mana tank survives Void while adjacent weak supports die; confirm primary choice and damage radius with level/talent changes.
2. Interrupt TP or channel on full-mana hero without expecting AoE ministuns; compare directly lethal alternate source.
3. Confirm incoming targeted spell causes Counterspell before Blink-Void and shield activation timing after Treads queue.
4. Confirm no Blink-Void while rooted/Ruptured/retreating or outnumbered; near maximum reach confirm no walking after Blink and sensible landing on terrain/trees.
5. Confirm current Scepter empowers next attack, Shard reflected fragment behavior and legacy ability hidden/absent state in live 7.41f; this pass does not manually cast legacy Fragment.
6. Rubick: stolen Mana Void kills via splash/interrupts; stolen Blink alone dodges and retains proper upgraded cast range.
Limitations: no lobby run in this environment; conservative damage estimate uses current special values and incoming mitigation, without extra spell amplification/health regeneration prediction. Movement after snapshot can change splash coverage and combo reach.

Underlord follow-up now verifies the current Shard ally-targeted Firestorm mechanic referenced by the Anti-Mage synergy advice. Other reviewed setups include Magnus Empower/farm and lockdown, Shadow Demon Mana Break illusions/cleansing, Lion mana drain/control and Underlord map defense/arrival. Draft matchup tables remain unchanged.

Final batch verification passed on the integrated state: node tests/run-builds.cjs (exit0 and all success markers), including all five new specs, Dazzle regression, Lua syntax for327 files,127 heroes/253 migrated roles,84 specialized Rubick dispatches,58 Rubick hero cases,272 purchase lists and all remaining shared scenarios. The suite includes node tests/valve_ability_check.cjs:128 hero files,21 Rubick copies,0 allowlisted findings at cf0d37a. git diff --check passed. Build/talent/skill-order data and Alchemist gifting were preserved. Offline acceptance is complete; lobby checklist remains outstanding and no live game was run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Prioritized Counterspell and direct Mana Void, selected splash sources and channel interrupts, bounded safe Blink-Void and guarded inactive legacy spells. Mirrored applicable Rubick behavior. Dedicated spec and full shared build/Valve suite pass; recorded live spell/upgrade/landing checks remain.
<!-- SECTION:FINAL_SUMMARY:END -->
