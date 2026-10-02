---
id: TASK-13.114
title: 'Weaver: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:30'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_weaver.lua
  - tests/weaver_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_weaver.lua
  - bots/FunLib/rubick_hero/weaver.lua
  - tests/weaver_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 154000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Weaver is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use actual recorded history for Time Lapse self and allied saves, with stale/death resets and legal current target shape.
- Use real Swarm projectile lines and meaningful Shukuchi movement/damage opportunities.
- Add current active Geminate autocast/manual attack decisions within actual attack reach.
- Mirror independent copied behavior without assuming absent Geminate, Shard effects or innate.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs weaver; https://dotacoach.gg/en/heroes/weaver and https://dotacoach.gg/en/heroes/counters/weaver (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native controller/every consideration, TDL guide 301732264 and complete Dotacoach Strategy/Counter Strategy and Matchup synergy/gameplay, core and counter-item cards. Refreshed through node tools/tdl/fetch.cjs weaver.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Swarm is point cast, range 3000, cast 0.3, twelve beetles, flight speed 750, individual collision radius 100 and spawn spread 300, physical damage 18/23/28/33 at 1.2/1.05/0.9/0.75 intervals for 16 seconds. It does not pierce debuff immunity and beetles require actual attacks to destroy.
- Shukuchi is immediate no-target with IGNORE_CHANNEL, magical damage 100/130/160/190 plus talent, radius 175, fade 0.25, duration four seconds and actual minimum movement override 550 plus talent. The separate speed value 200/230/260/290 is not the movement minimum. Each unit is damaged at most once per cast.
- Geminate is current UNIT_TARGET/AUTOCAST/ATTACK, pierces immunity and is breakable. Cooldown 9/7/5/3, nominal range 425 but actual attack reach governs attacks, bonus 20/35/50/65 on secondary only, delay 0.25 and one extra attack plus talent. Copied handles must be actually available; no assumed attack proc bonus.
- Time Lapse rewinds position, HP and mana five seconds, strong dispels and disjoints projectiles, with cast point 0.3, cooldown 70/55/40 and mana 150/75/0. Current Scepter subtracts ten seconds cooldown and changes targets_allies from zero to one, with actual engine cast range 500 before real bonuses. It restores state rather than ordinary healing, so Ice Blast alone does not reject a useful rewind.
- Current Shard marks Shukuchi-damaged units for 4.6 seconds, then secondary Geminate attack after exit with delay 0.2 and range 1200; current Swarm/Geminate Shard special values are retained as source observations. Controller does not fabricate marks or an absent copied linked attack.
- Rewoven experience innate is removed from active hero layout. Threads of Fate establishes after 1.5 seconds within 700, lasts six seconds, grants 10% damage per hero thread, breaks at 890 plus ten per hero level, briefly slows for 0.4 seconds and lingers five seconds after target death. Copied spells assume none of this absent passive behavior.

Implemented behavior
- Time Lapse uses bounded actual HP/location samples from visible self/allies, collected before local ability locks. It requires a fresh sample near the rewind time adjusted for cast point, a real useful HP recovery or safer past location under actual threat, and a currently safe past destination. Missing, stale, dead or replaced unit histories reset; a fresh warm-up is required.
- Human and bot allies receive equal Scepter save consideration without retreat/core restrictions or an arbitrary caster-health requirement. Actual targets_allies selects self no-target versus Scepter entity cast shape, uses true Lens/Supremacy range, and preserves healthy ally channels.
- Swarm predicts actual projectile arrival and scores narrow lines of current visible non-immune, uninfested targets rather than a circular group center. Current Roshan/Tormentor opportunities respect immunity and actual observed attacks. Swarm does not break an active Shukuchi approach.
- Shukuchi supports real threatened retreat, conservative reachable predicted damage, safe chase, local farm packs and ranged last hits. It respects existing active Shukuchi, dangerous reflection/Carapace and root/leash/Rupture/Coil movement constraints, without promising a projectile disjoint or future Geminate proc.
- Current active Geminate toggles autocast from actual valid attack activity, allows meaningful manual attacks, respects disarm/Break/ethereal/glyph/reflection and actual attack reach. Toggle-off remains possible without mana/cooldown readiness, while hidden/deactivated/absent handles stay inert.
- Copied handlers return nil for unknown spells before any lookups and decline recognized unusable spells. The read-only actual-Time-Lapse observation export supports cooldown and channel-period history without changing action eligibility.

Rejected or stale source claims
- Rejected passive-only Geminate assumptions, Swarm piercing debuff immunity, arbitrary circular Swarm hits, Shukuchi disjointing projectiles, guaranteed distant Shukuchi kills and Time Lapse always restoring HP merely because present HP is low.
- Rejected removed Rewoven experience mechanics, old Nullifier disabling passives/Jingu, guaranteed Maelstrom damage, Time Lapse selecting enemy illusions, and innate synergy advice claiming unsupported direct multipliers.

Item follow-up observations for TASK-21
- TASK-21: Current Scepter saves benefit from true Lens and safe Blink positioning; preserve BKB/silence-dispel readiness for the caster. Actual Shard marks/secondary attacks, Geminate attack procs, Desolator and defensive attack range tools need engine-observed follow-up; no build/generic item edits.

Enemy counterplay observations for TASK-24
- TASK-24: Real silence/stun action gates matter before Time Lapse, history determines whether a rewind helps, and detection makes Shukuchi invisibility unreliable as damage prevention. Respect physical immunity/disarm/Break versus Geminate, beetle attack removal, Carapace/reflection and root/leash/Rupture/Coil movement hazards.

Lobby validation checklist
- No game run. Validate Time Lapse snapshot timing relative to its 0.3 cast, actual Scepter self/entity shape and cast range, death/Aegis/respawn reset behavior and any engine rewind exclusions. Missing snapshots intentionally decline until fresh history is present.
- Validate actual Shukuchi movement and damage tagging, beetle projectile distribution, current Geminate autocast/manual attack semantics, Shard marks and Threads of Fate lifecycle. Standard controller work does not claim a deep engine/lifecycle validation.

Focused verification
- Native/copied Weaver Fengari focused scenarios passed: history warm-up/HP gain/negative rewind/staleness/self and ally death resets, Ice Blast, current Scepter shape/true range/Break/human parity/healthy channel preservation, cooldown/channel observations, Swarm prediction/immunity/non-stacking, Shukuchi local range/regen/reflection/movement guards, Geminate attack range/autocast/Break/toggle-off and absent copied siblings.
- Cooldown toggle-only routing callback positive and hidden/channel negatives pass. Weaver uses documented ToggleAutoCast; Viper was already using it.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.

Framework integration
- Copied ObserveStolenTimeLapseHistory is a read-only export. It first checks actual non-null trained visible activated weaver_time_lapse, clears history if absent, and samples only actual self/eligible nearby allies with no action. Root wires next to Glimpse observation before utility ready/channel gates and native Rubick local gates. Native ObserveTimeLapseHistory runs before local action gate in SkillsComplement.
- ConsiderStolenGeminateAutoCast: exact actual non-null trained visible activated autocast handle, normal J.CanNotUseAbility/queue locks preserved, toggle-only mutation through documented ToggleAutoCast. Root routes before readiness to permit safe cooldown-insensitive OFF; no manual cast or state-gate bypass.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Weaver standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
