---
id: TASK-13.120
title: 'Skywrath Mage: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:49'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_skywrath_mage.lua
  - tests/skywrath_mage_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_skywrath_mage.lua
  - bots/FunLib/rubick_hero/skywrath_mage.lua
  - tests/skywrath_mage_ability_spec.lua
  - bots/FunLib/skywrath_mage_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 160000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Skywrath Mage is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Correct projectile timing and automatic targeting, actual silence amplification follow-up and controlled distributed Flare placement without assuming copied upgrades or passives.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs skywrath_mage; https://dotacoach.gg/en/heroes/skywrath-mage and https://dotacoach.gg/en/heroes/counters/skywrath-mage (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native decisions, complete Torte guide 286895078, canonical Skywrath Mage Dotacoach Strategy/Counter Strategy and every Matchup synergy, gameplay and advanced item card. Ran guide CLI and verified intended hero pages.
- Pinned KV/localization: Bolt 875 range, 0.1 cast point, 500 speed, 150 base plus actual 1.5 intellect multiplier; live talent raises range and pierces debuff immunity. Shard gives two additional independently selected bolts within 500, not three guaranteed bolts on one enemy.
- Concussive is no-target, actual 1600 launch radius or actual global talent, 800 projectile speed, 300 damage, 250 area and four-second slow. It chooses the closest visible hero and can choose a creep when no hero exists. Spirit Bear acquisition is treated conservatively; Lens does not increase the acquisition special.
- Seal has 700/750/800/850 range, 0.1 cast point, 20/25/30/35 percent magic resistance reduction and 3/4/5/6 silence. It can amplify a disabled or already silenced enemy and is dispellable.
- Flare has 1200 range, 0.1 cast point, 170 area, two-second duration, 0.1 tick and 800/1200/1600 total distributed among actual heroes. It does not damage creep heroes, affects creeps only without heroes and immediately erases illusions. Scepter selects another independent target or field within 500. Current Shield of the Scion is a magical barrier, not old intelligence/armor stacks.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Bolt kills use one actual projectile, live intellect multiplier and full cast/flight delay with regeneration. Runtime pierce talent controls debuff immunity eligibility. Native ranged last hits, farming and objectives remain.
- Concussive explicitly finds the actual nearest visible hero before valuing its impact, rather than treating a list first element or desired farther hero as the engine target. It honors real global acquisition, delays, area spillover and creep fallback. A nearer immune or suspicious target cannot be ignored to manufacture a farther kill.
- Seal applies legal current silence and amplification with unit block/reflection gates. Existing Seal declines; already controlled or silenced enemies remain useful when an actual affordable in-range sibling or observed allied magical cast provides follow-up. Human allies receive local peel parity.
- Flare clamps predicted placement to actual range plus coverage, counts real heroes for damage division, excludes Spirit Bear from that divisor and guards reflected collateral. Lethal estimates use only observed remaining hold or one conservative first tick, with regeneration over that actual damage interval. Actual Atos/root/control setup supports longer commitment; the module does not assume an item command succeeded.
- A meaningful cluster of four actual visible illusions during combat permits the documented instant illusion erasure. Native and copied spells remain independent with null/hidden siblings handled; no passive or extra Scepter/Shard bolt damage is fabricated. Copied returns obey unknown/skip/action contract.

Rejected or stale source claims
- Excluded instant slow Bolt damage, fake Lens acquisition extension, invented guaranteed triple Shard damage, double Scepter damage on one target, assumed full Flare damage on mobile enemies, creep/Spirit Bear Flare tanks, obsolete intelligence/armor facet and guide claims that silence stops Supernova attacks.

Item follow-up observations for TASK-21
- TASK-21: observed Atos/Gleipnir/root setup matters for Flare dwell and actual mana must support Seal follow-up. Existing item builds remain; no generic item prep policy is changed or queued root success assumed. Actual Lens/Supremacy are measured each decision, avoiding stale sold-Lens bonuses.

Enemy counterplay observations for TASK-24
- TASK-24: dispel Seal/root, move out of the 170 field, deny actual automatic Concussive targeting, use physical disruption and reflect/barrier protection. Source claims that Arcane Bolt can simply be disjointed or Spirit Bear tanks a hero Flare are not adopted.

Lobby validation checklist
- Verify exact automatic Concussive acquisition with Spirit Bear, illusions, immunity, fog and global talent; conservative ambiguity currently declines imagined farther-target damage.
- Verify actual remaining Atos/hex/stun duration, Flare tick/distribution including immune heroes and creep-hero exclusion, moving point placement, illusion erasure, extra Scepter field and independent copied Bolt/Seal/Flare handles. No game launched.

Focused verification
66 native/copied focused scenarios passed under Fengari with realistic integer truncation and floating-point special access. Four files parsed as Lua 5.2 and owned diff whitespace checks passed. Scenarios cover true range, global acquisition, nearest target, fog, projectile regeneration, real immunity talent, control overlap, nil siblings, distribution, Spirit Bear, actual hold expiry, reflected collateral, illusion erasure, human peel, native farm/last hits and canonical dispatch.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Skywrath Mage standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
