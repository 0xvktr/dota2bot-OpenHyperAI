---
id: TASK-13.69
title: 'Muerta: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_muerta.lua
  - tests/muerta_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_muerta.lua
  - bots/FunLib/rubick_hero/muerta.lua
  - tests/muerta_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 109000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Muerta is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Update current spell handles, magical attack opportunities, safe immediate Gunslinger maintenance, Calling zoning, and current Shard usage.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs muerta; https://dotacoach.gg/en/heroes/muerta and https://dotacoach.gg/en/heroes/counters/muerta (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the full native script, Torte guide 2943368068, full Dotacoach Strategy and Counter Strategy cards, full Matchup including synergy and advanced items, pinned Valve KV and localization.
- https://dotacoach.gg/en/heroes/muerta
- https://dotacoach.gg/en/heroes/counters/muerta
- Dead Shot is unit/vector targeted, 1000 range, magical 100–325 damage plus runtime Scepter 125, speed 2000; only the ricochet fears. Calling has 600 center range, 340 revenant orbit and 120 hit radius; center slow does not guarantee immediate silence.
- Gunslinger explicitly ignores silence and invisibility. Veil gives 70–100% base damage, eight seconds duration and projectile disjoint. Spectral Slug is the current Shard ability: 500 range, 225 magical damage, three seconds ethereal and 2500 speed.

Implemented behavior
- Use exact current ability names instead of fragile guide slots and obsolete Parting Shot assumptions.
- Maintain Gunslinger before silence and invisibility gates with full occupied-action and forbidden-state guards.
- Enable Veil against a committed reachable solo target, as physical defense at low health, or for a threatening stun projectile. Offensive casts reject disarm, immunity, protected targets and Blade Mail.
- Estimate Dead Shot damage as magical; preserve direct damage and retreat slow without claiming unimplemented vector fear or channel interruption. Add useful ranged lane last hits.
- Respect actual Calling center range and predicted useful aura reach, removing fake center silence and misspelled cluster count logic.
- Use actual Spectral Slug for lethal damage or physical defense. Offensive ethereal setup requires observed trained Veil, so copied Slug does not protect a target from ordinary physical allies by assuming an absent passive.
- Final audit checks actual Gunslinger handle readiness before an immediate toggle; unavailable handles are not issued.

Rejected or stale source claims
- Reject stale Torte Parting Shot, old Shard lifesteal and total BKB invulnerability descriptions.
- Reject Dotacoach Matchup pure damage, Calling reveal and outdated Shadow Demon Soul Catcher claims. Preserve valid ally setup, positioning and magic resistance advice.

Item follow-up observations for TASK-21
- TASK21: BKB protects attack opportunity but does not grant universal immunity; Pike and Blink solve positioning; current Shard enables Spectral Slug; current Scepter improves the ricochet. Veil converts physical lifesteal into spell lifesteal for attacks.

Enemy counterplay observations for TASK-24
- TASK24: Magic resistance, disarm, silence and mobility reduce her limited magical attack window; Blade Mail discourages offensive burst; physical attacks are ineffective against active Veil.

Lobby validation checklist
- Dead Shot vector ricochet angle and fear-to-Calling combinations require a supported live vector command; this pass conservatively uses direct damage and slow.
- Calling slow and eventual revenant contact are useful, but center placement is not an instant channel interrupt.
- Ofrenda spawn placement needs a dedicated safe respawn policy and is not automatically moved during this standard pass.

Focused verification
- Fengari muerta_ability_spec passed five behavioral groups. No game launched. Parent owns full suite integration.
- Final owned-file audit passed: unknown spells defer, all 17 focused specifications pass, exact range helpers respect actual items and Break, and optional linked handles are guarded.

Framework integration
- Native X.UseGunslinger and copied UseGunslinger before ordinary silence/invisibility gate.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Muerta standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
