---
id: TASK-13.32
title: 'Elder Titan: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:35'
updated_date: '2026-10-02 15:48'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_elder_titan.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/FunLib/rubick_hero/elder_titan.lua
  - bots/BotLib/hero_elder_titan.lua
  - tests/elder_titan_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 72000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Elder Titan is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Audit pinned Valve/localization, TDL 143016376 and complete dotacoach Strategy/Counter/Matchup; preserve build prefix. Fix self-cancelled Stomp channels, actual spirit ownership/touches, single-action spell priority, delayed linear Splitter with split damage and true sleep duration. Add equivalent stolen spell decisions requiring actual linked spirit handles, focused scenario coverage, shared integration and offline checks. Record engine-only spirit/Shard details for lobby validation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Sources: pinned d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f Elder Titan KV and abilities_english; Torte de Lini workshop 143016376 (offlane 7.41f); https://dotacoach.gg/en/heroes/elder-titan Strategy/Counter Strategy and https://dotacoach.gg/en/heroes/counters/elder-titan full Matchup. Checklist: actual owned Spirit touches before returning combat buffs; preserve synchronized Stomp channel; live cast+channel prediction and real Spirit Stomp handle; passive Natural Order/Momentum never cast; actual remaining sleep before Splitter, delayed line geometry and half physical/half magical mitigated max-health damage; farm Spirit with combo mana reserve; one spell action per tick; copied abilities require actual linked handles. Implemented native and dedicated copied decisions, narrow Rubick Spirit controller/minion routing, focused positive/negative scenarios. No build/talent/skill changes.
Source exclusions: TDL first-two-level Stomp guarantee fails against current 2/2.8s sleep and Splitter 0.4+2.7182s impact. Spirit speed is live observed speed (KV900), not site's hero-speed formula. Base armor/resistance reduction is not removal of all bonus defenses. Discard deprecated facets/Tip the Scales, enemy Solar Crest, passive-breaking Nullifier claim, incorrect Hoodwink/Dark Seer paragraph, Naga matchup contradiction and numerical aura-item claims. No site paragraph copied.
Lobby checklist: native and stolen Spirit spawning/owner ID, linked Move/Return visibility and Spirit Stomp acquisition; exact split crack timing/width along travel and Rubick range effects; no-Spirit Stomp damage components (offline only counts proven physical damage); Scepter return buff actual debuff immunity/strong dispel timing; active Shard alt-cast endpoint/root behavior (automation deliberately skips active swap until verified); minion callback during Stomp and TP; Spirit actual touch observation/return timing and stale handles. Generic attack wake policy, camp-stack scheduling/Twin Portals, item actives and draft matchups remain separate work. No lobby launched.

Independent cross-review corrections: remaining TP duration must exceed full Stomp cast/channel delay; accumulated observed touches remain useful after enemies leave Spirit-near observations; ethereal/Guardian Angel/Cold Embrace zero the physical part of lethal estimates while retaining useful control decisions. Added faithful native/copy negative and positive scenarios. Supplied isolated stolen handle is authoritative; real linked Spirit/Stomp handles, visibility/ownership and Spirit-own channels remain guarded. First integrated suite exited0; final suite is repeated after final Earth Spirit timing checks.

Final integrated verification: node tests/run-builds.cjs exited0 after all final reviews/corrections. Exact five hero markers passed;368 Lua files parse,128 native/32 Rubick Valve checks with zero findings,127 heroes/253 roles,133 specialized dispatches,68 Rubick native behavior cases and272 purchase lists. All five native build/skill/talent prefixes remain byte-identical with HEAD; git diff --check passed. Shared dispatcher registers all five dedicated handlers; narrow observed Drow Glacier, Earth Spirit Magnetize Stone and owned Elder Titan Spirit/minion hooks are covered. TASK21/24 source-derived observations recorded. No engine lobby launched; remaining capability boundaries are in each task checklist.

2026-10-02 integration API follow-up: replaced undocumented HasShard() calls with the existing modifier_item_aghanims_shard convention used by this repository. Fixtures use the actual modifier query, retaining shard state scenarios. Focused hero scenarios passed; builds and skill/talent preferences retained. Lobby verification remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Elder Titan: preserved synchronized channels, real owned Spirit control/touches, full-delay Stomp/TP logic, delayed linear mixed-damage Splitter and linked-copy safety. Native/copy specs, final integrated suite, pinned Valve validation, unchanged build prefixes and whitespace pass. Source audits and lobby limits recorded; ready for in-game test.
<!-- SECTION:FINAL_SUMMARY:END -->
