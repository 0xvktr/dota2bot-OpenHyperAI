---
id: TASK-13.56
title: 'Largo: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_largo.lua
  - tests/largo_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_largo.lua
  - bots/FunLib/rubick_hero/largo.lua
  - tests/largo_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 96000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Largo is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Prioritize safe basic-dispel saves and delayed Frogstomp interrupts, improve useful Croak recipients, and replace random songs with guarded deterministic beat decisions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs largo; https://dotacoach.gg/en/heroes/largo and https://dotacoach.gg/en/heroes/counters/largo (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all 699 native lines, Torte guide 3625076233 (no ability or item tips), full correctly identified Dotacoach Strategy and Counter Strategy cards, full Matchup and advanced item notes, pinned Valve KV and localization.
- https://dotacoach.gg/en/heroes/largo
- https://dotacoach.gg/en/heroes/counters/largo
- Catchy Lick is a basic dispel, range 700, magical damage 85–340 and ally pull 375. Frogstomp center range 800, radius 350, delay 0.5 and 0.1 second ministuns. Croak range 800 and eligible spell-damage distance 2000.
- Rhapsody is an immediate toggle ignoring silence, invisibility and channels, with one second beats and 0.4 second grace. Runtime double_song permits two songs with Scepter. Songs themselves do not ignore silence. Encore is breakable; copied spells do not assume it.

Implemented behavior
- Prioritize safe Lick saves before Croak. Dispel known basic-removable debuffs on self or allies, reject the old stun-dispel claim, and pull endangered allies only when every visible nearby threat becomes farther away. Avoid disrupting allied channels.
- Use true Lens and trained Supremacy ranges. Predict Frogstomp at its real delay, clamp centers and prioritize channel opportunities before damage buffs. Preserve contextual native farming and objective decisions.
- Choose a real spell-damage ally within actual Croak range without duplicating its buff, or native self when an observed independent spell combo is available.
- Replace random Scepter song selection and even-second shutdown with deterministic healing, escape and damage priorities. Ice Blast excludes ineffective healing.
- Track the first observed active mode, maintain the next one-second beat, deduplicate each beat, and double strum only when actual runtime double_song and mana allow it.
- Use a narrow active-mode exit helper while silenced or without useful recipients, preserving every other forbidden state and occupied action. Copied Rhapsody requires actual linked song handles.
- Final audit guards missing ally targets before the real chase API and checks actual Rhapsody handle readiness before ending the mode.

Rejected or stale source claims
- Torte guide has no tips; no advice was fabricated.
- Basic dispel does not remove generic stuns. Croak does not amplify ordinary unqualified physical attacks. Scepter damage requires Bullbelly Blitz rather than automatically appearing on every song.

Item follow-up observations for TASK-21
- TASK21: Shard Encore repeats actual eligible item/ability buffs on Largo; Lotus and Glimmer have valid support synergy. Holy Locket and Greaves improve healing. Scepter permits two tunes and actual Bullbelly double-strum damage.

Enemy counterplay observations for TASK-24
- TASK24: Silence and mana burn prevent song value. Vessel, Skadi and Ice Blast reduce healing. Nullifier continuously removes beneficial buffs; basic Lick alone cannot permanently defeat its repeated dispel.

Lobby validation checklist
- Beat phase is anchored to the first observed active modifier; verify the engine activation offset and two queued immediate songs inside the 0.4 second grace window.
- No unsupported rune targeting or vector commands were added.
- Copied Rhapsody begins only with actual linked song handles; verify their level and activation transitions in the engine.

Focused verification
- Fengari largo_ability_spec passed six behavioral groups. No game launched. Parent owns full suite integration.
- Final owned-file audit passed: unknown spells defer, all 17 focused specifications pass, exact range helpers respect actual items and Break, and optional linked handles are guarded.

Framework integration
- Native X.UseRhapsodyOff and copied UseRhapsodyOff before the ordinary silence gate; helper bypasses silence only for ending observed active mode.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Largo standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
