---
id: TASK-13.94
title: 'Riki: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:39'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_riki.lua
  - tests/riki_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_riki.lua
  - bots/FunLib/rubick_hero/riki.lua
  - tests/riki_ability_spec.lua
  - bots/FunLib/riki_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 134000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Riki is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use current physical Blink Strike, real Smoke geometry and observed own Tricks channel exception, actual Scepter pocket cast shape, safer escapes and truthful linked spell availability; preserve native farm/objectives and preparation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs riki; https://dotacoach.gg/en/heroes/riki and https://dotacoach.gg/en/heroes/counters/riki (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Full Torte guide 128745244, intended Riki Strategy and Counter Strategy and all Matchup synergy, gameplay and advanced item cards were read and checked against pinned KV and English localization.
- Smoke Screen: point cast, 550 base range, 425 radius, 0.2 cast point, 75 mana and six seconds; explicitly may cast during Tricks. Shard grants armor reduction and blocks friendly targeting.
- Blink Strike: physical attack with 55 bonus damage at level four, 900 base range, 0.3 cast point and 65 mana; pierces debuff immunity, roots prevent the jump, friendly jumps deal no damage. Copied casts require an actual Backstab handle before attributing its damage.
- Tricks: channelled point AoE, 400 base range, 425 radius, two random targets per interval, four intervals with fixed 100 attack damage. Current Scepter raises live cast range by 500 and enables friendly hero/basic-unit pocket casts with extra duration and attacks.
- Cloak and Dagger remains passive; abilities may be useful from invisibility. Legacy Sleeping Dart is in raw KV but absent the active roster, so casts require its actual trained, visible, activated handle.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Added shared native/copied decisions and canonical copied handler; replaced issued-Blink timing suppression with real engine busy/channel state.
- Smoke uses real range plus radius, predicts cast-point movement, interrupts channels and protects threatened human or bot allies. It precedes normal offensive Blink and can operate from natural invisibility.
- Added uniquely exported UseSmokeDuringTricks for native and copied modules. It verifies the real actor Tricks handle equals the active channel and rejects cast animations, unrelated channels, queue and forbidden disable states before directly casting Smoke.
- Blink uses physical damage and actual available unbroken Backstab, pierces debuff immunity, rejects ethereal/attack-immune, blocked, reflected and unsafe targets, and uses actual friendly escape anchors. Root, leash and Rupture movement guards remain in force.
- Tricks uses actual point range and physical targeting; live pocket_riki_enabled permits only friendly nonbuilding/nonward unit casts, otherwise uses point shape. Defensive casts stay bounded and avoid known unsafe arrival.
- Preserved native ranged last hits, neutral farm and objective Blink, added native Tricks neutral farm, and passed actual spell handles to normal item preparation.
- Movement guards use the actual pinned English modifier_puck_coiled, replacing an inherited nonexistent Dream Coil modifier name; native and copied negative coverage was rerun.

Rejected or stale source claims
- Excluded Sleeping Dart purchase assumptions, old Tricks agility scaling, Tricks dispel talent, old Exterminator/facet advantages and old charges-based Blink assumptions. Current raw Tricks range supersedes stale Scepter tooltip wording that still says 400.

Item follow-up observations for TASK-21
- TASK-21: Diffusal/Disperser and Smoke control, Manta outside Dust AoE and BKB help Riki maintain engagement; Aether Lens and Scepter range are actual live values. No item/build updates.

Enemy counterplay observations for TASK-24
- TASK-24: detection, roots/leashes, ethereal saves and armor constrain Riki; Smoke Shard prevents allies targeting the trapped hero but does not mute active items. Current Backstab and fixed Tricks damage should replace outdated agility-only estimates. No generic counterplay changes.

Lobby validation checklist
- Confirm current engine GetCurrentActiveAbility identity and IsChanneling during native/copied Tricks; the Smoke callback deliberately refuses missing or different source handles.
- Confirm dynamic Scepter unit targeting, friendly creep pocket eligibility, source handle visibility/activation while channeling, and no queued item prep interruption.
- Confirm physical Blink forced attack/backstab with evasion and current fixed Tricks attack intervals; copied spells do not presume Cloak, Backstab or Scepter siblings.

Focused verification
- Fengari: 34 meaningful native/copied scenarios passed.
- Lua 5.2 native, copied, companion and spec parsing and owned whitespace checks passed.

Framework integration
- Native and copied modules export UseSmokeDuringTricks(); root integrates before ordinary channel/invulnerability skips. It returns true only after an actual direct Smoke action, false otherwise.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Riki standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
