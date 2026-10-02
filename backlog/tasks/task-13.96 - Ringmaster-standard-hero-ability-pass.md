---
id: TASK-13.96
title: 'Ringmaster: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:45'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_ringmaster.lua
  - tests/ringmaster_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_ringmaster.lua
  - bots/FunLib/rubick_hero/ringmaster.lua
  - tests/ringmaster_ability_spec.lua
  - bots/FunLib/ringmaster_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 136000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ringmaster is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Prioritize real Escape Act saves, repair actual Whip channel release, bound projectile and Wheel geometry, respect actual Shard/Scepter and fake-item souvenir availability, and preserve native lane/farm/objective casts.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs ringmaster; https://dotacoach.gg/en/heroes/ringmaster and https://dotacoach.gg/en/heroes/counters/ringmaster (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Full Torte guide 3315134700, correct Ringmaster Strategy/Counter Strategy and all Matchup synergy, gameplay and advanced item cards were read and checked against pinned KV/localization.
- Tame the Beasts: point channel, 700 range, one-second channel, damage 125 to 480 at level four, shrinking 450 to 200 width and exponentially scaling charge; Crack is immediate no-target IGNORE_CHANNEL with zero mana.
- Escape Act: friendly hero unit, 600 range, 0.4 cast point and 120 mana; target becomes untargetable but can still take AoE damage, muted/silenced/disarmed with up to 80 percent magic resistance. Current Scepter gives two charges, explosion and eight radial daggers; target need not have Impalement trained for automatic upgrade effects.
- Impalement: three charges, 50 mana, 2400 point range, 0.3 cast point, 1350 speed and 130 width; impact 65 and four seconds of six percent maximum hero health per second. Current penetration talent passes one target.
- Wheel: point range 1400, minimum travel 700, 1200 speed, 500 mesmerize radius, 0.5 second facing requirement, maximum four-second untriggered timer; explosion damage 600 is delayed, not instant.
- Spotlight: actual visible activated Shard handle, 1500 point range, 275 light radius and three moving beams; current Souvenir pool is Mirror, Tonic, Cushion and Unicycle. Souvenirs are charged fake items with IGNORE_SILENCE and AFFECTED_BY_MUTE.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Added shared decisions and canonical copied handler for the six main/source-linked spells; unknown names return nil before bot lookups or gates.
- Escape Act now precedes offense, checks true range and actual attacker intent, protects human and bot allies without role filters, avoids duplicate Box and harmless low-health saves, and preserves healthy ally channels/TP. Native actions now return after exactly one cast.
- Whip predicts its actual full channel for normal engagements and preserves native ranged-creep, wave, farm and objective casts. Crack requires an observed real actor channel whose active handle equals the recorded source; only channel interrupts or urgent low-health pressure release early. No linear charge-damage fiction is used.
- Impalement uses global visible hero candidates within actual range, cast plus projectile travel prediction and regeneration-aware immediate impact lethal checks; counts real enemy/neutral blockers and actual penetration talent. Delayed bleed is not credited as an instant kill.
- Wheel respects physical minimum and true maximum destination and uses predicted targets/ally disable setups; Spotlight casts at actual enemy attackers and illusions within its real predicted range.
- Souvenir decisions use actual available charges and active handles, correct real attackers, threatened ally Tonic, and safe movement constraints. The unique silence exception preserves mute, Box, Doom, cast/using/channel/queue and disable guards; native normal save decisions keep priority. Legacy Pie/Crystal availability is never presumed.
- Movement guards use the actual pinned English modifier_puck_coiled, replacing an inherited nonexistent Dream Coil modifier name; native and copied negative coverage was rerun.

Rejected or stale source claims
- Excluded old Box target stun and AoE invulnerability claims, old Impalement charge/mana/bleed values, obsolete Souvenir facets and guaranteed unlimited silence casting. Solar Crest self casting and outdated item disassembly advice were not adopted.

Item follow-up observations for TASK-21
- TASK-21: Lens/Blink improve actual Escape range and save timing, Glimmer and Force Staff support escape, Atos setup requires actual projectile timing. No item/build updates.

Enemy counterplay observations for TASK-24
- TASK-24: Box targets remain vulnerable to AoE damage and enemy dispels; none of the main enemy effects pierce debuff immunity. Wheel requires actual facing rather than guaranteed taunt. Souvenirs are muted as fake items even though ordinary silence permits them. No generic counterplay changes.

Lobby validation checklist
- Confirm actual Crack handle readiness/visibility and active Whip source identity during channels, including canceled queued Whip commands; a queued intention alone never permits release.
- Confirm current dynamic Scepter Box charge/explosion behavior, untargetable but AoE-vulnerable ally saves, and human ally channel preservation.
- Confirm Dagger collision hull and one-target penetration against units and neutrals, Wheel minimum travel/collision placement and Spotlight sweep coverage.
- Confirm fake-item Souvenir charge visibility and silence/mute behavior with current pool. Legacy Pie/Crystal source handles are not assumed to be available.

Focused verification
- Fengari: 34 meaningful native/copied scenarios passed, including exact observed release, silence exception constraints and actual Puck coiled movement guard.
- Lua 5.2 native/copied/companion/spec parsing and owned whitespace check passed.

Framework integration
- Native and copied UseTameTheBeastsCrack() verifies exact real active Whip source/channel, legal Crack and recorded aim, returning true only after a direct action.
- Native and copied UseCarnivalSouvenir() runs only for a silenced actor; actual charged fake-item source permits the exception while mute and all other action locks remain blocked.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Ringmaster standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
