---
id: TASK-13.121
title: 'Winter Wyvern: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:55'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_winter_wyvern.lua
  - tests/winter_wyvern_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_winter_wyvern.lua
  - bots/FunLib/rubick_hero/winter_wyvern.lua
  - tests/winter_wyvern_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 161000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Winter Wyvern is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Repair Arctic Burn actual attack range and Scepter toggle readiness, preserving safe cooldown/mana-insensitive OFF.
- Choose a legal non-self Splinter Blast host and predict actual secondary arrivals without damaging the primary.
- Evaluate Cold Embrace physical protection against immobilization and other damage; preserve human/self parity and fractional healing.
- Choose Winter’s Curse from actual surrounding attackers, support urgent single-target channels and avoid already committed ally area disables.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs winter_wyvern; https://dotacoach.gg/en/heroes/winter-wyvern and https://dotacoach.gg/en/heroes/counters/winter-wyvern (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the entire native controller and every consideration, TDL guide 391458050 and complete Dotacoach Strategy/Counter Strategy and Matchup synergy/gameplay and advanced-item cards. Refreshed TDL through tools/tdl/fetch.cjs winter_wyvern.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Arctic Burn no-target, cast point zero, cooldown 29/26/23/20, duration 7/8/9/10, attack range bonus 250/275/300/325 and current-health burn 4/6/8/10% per second with 0.5 ticks. Current Scepter makes it toggle, drains 20 mana per second and adds 25% movement. It does not affect Roshan.
- Splinter Blast targets BOTH teams’ hero/basic units, cannot target self, leaves primary unaffected, true range 1150/cast 0.3, primary speed 1200 with maximum travel time one second, secondary speed 1000, split radius 500 plus talent, damage 80/160/240/320 plus talent. Slow 27/30/33/36 for four seconds.
- Cold Embrace targets allied heroes/creeps through immunity, range 850/900/950/1000, cast 0.3, four seconds, base healing 40/45/50/55 per second plus talent and fractional 1.5/2.5/3.5/4.5% maximum HP per second, physical protection and immobilization. Current Shard reduces cooldown by four and grants 60% attack damage for six seconds after exit; shard_splinter_range is zero.
- Winter’s Curse is enemy-only, range 800/cast 0.3/radius 525, primary pierces immunity while surrounding forced attackers do not. Minimum duration two seconds/max six, additional hero duration 1.5 and creep 0.5; forced attack speed 50/65/80 plus talent. Cursed units reject other enemy damage except the actual caster and its controlled units.
- Current hero layout uses Eldwurm’s Edda, increasing current/max basic ability level and base intelligence when consumed. Its localization scales added-level values by half the prior level difference except mana. Removed Scholar/Dragon Sight/Frozen Blood/Accelerated Learning definitions are not current active layout; copied spells assume none of their effects.

Implemented behavior
- Arctic Burn uses real current attack range, adding its bonus only when not already active. Scepter keeps useful burn or escape flight, reserves mana for an actually present Embrace, and turns off when no useful opportunity or mana remains even during cooldown. Hidden, null, deactivated and untrained handles remain inert.
- Splinter Blast chooses a legal allied human/bot, creep or enemy host distinct from the desired victim. It predicts both projectile stages and checks the actual splash radius, including targets beyond host cast range, regeneration and immunity. Farm counts exclude the unaffected primary and require real local secondary hits.
- Cold Embrace scores actual attack projectiles and observed physical attackers, accounts for other available damage when immobilizing the ally, includes self and human allies equally, avoids already protected/ethereal targets and preserves healthy channels. Ice Blast blocks healing but does not erase a real lethal physical save. Safe recovery needs meaningful missing HP and no local other-damage threat. Float percentage affects save ranking.
- Winter’s Curse interrupts an actual lone low-health immune channel without demanding adjacent heroes. Offensive choices score actual nearby non-immune, non-disarmed, non-disabled forced attackers against the host, rather than the host’s own damage. Urgent escape remains available; existing Chronosphere/Black Hole offensive overlap is avoided.
- Splinter/Burn damage during Curse is considered only when each actual Curse modifier’s documented source ability belongs to this caster. Unknown or foreign ownership declines, and other protected states remain excluded. Copied spells use actual Lens/unbroken Supremacy and optional-handle guards, with unknown dispatch preserved.
- Unknown copied spell names return nil before querying IsNull or any other handle method; the focused unsupported handle throws on extra queries.

Rejected or stale source claims
- Rejected universal stats, current Scholar XP gain, old one-burn-per-cast limitation, Splinter damaging its primary, Cold Embrace blocking magic or pure damage, old Shard Splinter explosion and ally-targeted Winter’s Curse.
- Rejected guaranteed full Curse-duration enemy DPS and immediate teammate damage during Curse; allies must time their follow-up after its protection ends. Edda timing differs between source advice and cached tooltip, so no consumption timing or item controller change is inferred.

Item follow-up observations for TASK-21
- TASK-21: Real Lens helps safe Embrace and legal Splinter host reach; Blink improves Curse placement and escape tools reduce risky Embrace immobilization. Current Scepter toggle drains real mana and preserves an actually present save’s reserve. Current Shard is an exit attack buff rather than a blast. Edda choice/consumption remains a separate item-policy observation; builds and generic items untouched.

Enemy counterplay observations for TASK-24
- TASK-24: Magic/pure threats can punish Cold Embrace, while physical attacks are prevented. Debuff immunity protects secondary Curse attackers and burn/Blast victims, but not the Curse primary. Spread beyond actual 525 Curse and 500 Splinter radius; protect against reflection/spell block and observe caster-owned Curse damage exceptions.

Lobby validation checklist
- No game run. Validate Splinter primary maximum travel timing, secondary splash/movement and allied host legality, current Arctic flight modifier/toggle drain and Lens/Supremacy interaction.
- Validate Cold Embrace physical protection and fractional healing under mixed damage, current Shard exit buff, actual Curse modifier source attribution and forced-attacker immunity/duration. Standard pass does not claim deep engine lifecycle validation or an Edda item controller.

Focused verification
- Native/copied Fengari scenarios passed: legal allied/enemy Blast hosts, unaffected sole target, actual cast and splash boundaries, travel prediction/regen/immunity/farm counts, source-owned versus foreign Curse damage, human/self Embrace range and channels, mixed/physical/ethereal/Ice Blast threats, fractional 4.5% save ranking, lone immune Curse interrupt, actual attackers versus host DPS, disabled/disarmed/immune attackers, escape/area overlap, current Arctic attack range, active bonus non-duplication and cooldown/mana OFF, Lens/Supremacy/Break, queue/hidden/null/absent copied handles and unknown dispatch.
- Lua 5.2 native/copied/spec parse and owned diff whitespace check passed. Focused fixtures truncate Int and preserve Float.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.
- Integration follow-up passed actual shared rubick_unknown_handlers_spec.lua for all 92 handlers and Winter Wyvern focused scenarios; Lua 5.2 parse and owned diff check remain clean.

Framework integration
- ConsiderStolenArcticBurnToggle checks exact actual valid trained visible activated Arctic Burn and Scepter before Refresh, retains normal J.CanNotUseAbility and NumQueuedActions locks, and issues only a considered no-target toggle. Root routes before readiness to preserve safe cooldown/mana-insensitive OFF. No invulnerability or disable bypass.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Winter Wyvern standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
