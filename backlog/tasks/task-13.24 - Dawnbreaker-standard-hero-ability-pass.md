---
id: TASK-13.24
title: 'Dawnbreaker: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:04'
updated_date: '2026-10-01 17:28'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_dawnbreaker.lua
  - bots/FunLib/rubick_hero/dawnbreaker.lua
  - tests/dawnbreaker_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 64000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Dawnbreaker is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Audit pinned Valve cf0d37a hero KV and English localization, TDL Workshop 2451777397, dotacoach Strategy/Counter Strategy and entire Matchup advice; preserve current D2PT build prefix. 2. Fix native cast priority and legal Solar Guardian ally anchoring, Starbreaker physical combo decisions and Shard escape, Hammer prediction/range/farm, and safe tracked Converge. 3. Add applicable Rubick handlers with actual linked ability checks and a pending Converge hook for root to integrate; do not invent movement/channel controls or obsolete facets. 4. Exercise meaningful native/copy scenarios in hero_harness, Lua 5.2 parse, Valve value/name check and whitespace; root owns shared suite and task finalization. 5. Record sources, stale exclusions, item/counter follow-ups and remaining lobby scenarios.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source audit: pinned dotabuff/d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f scripts/npc/heroes/npc_dota_hero_dawnbreaker.txt and resource/localization/abilities_english.txt; tests/valve/abilities.json; TDL Workshop 2451777397 (position 3, fetched with node tools/tdl/fetch.cjs dawnbreaker); https://dotacoach.gg/en/heroes/dawnbreaker Strategy and Counter Strategy; https://dotacoach.gg/en/heroes/counters/dawnbreaker full Matchup including good-with, good-against, counterheroes, core items and counteritems. Checklist covered Solar global ally saves/initiations and controlled ally setups (Duel/Arena/Black Hole/Chronosphere), Hammer waveclear/chase/cliff escape and actual linked Converge, Starbreaker three attacks/Luminosity interaction and Shard immunity, healing reduction, Break and channel interruption. Valve rules override numerical/advice conflicts. Stale exclusions: retired Gleaming Hammer/Blaze facets and global dawn map reveal; current Break of Dawn is base damage/vision bonus with Scepter healing amplification. Current Scepter description is aura following for 2 seconds after landing, so old evasion/air steering/early land control were not implemented. TDL Arcane Boots disassembly, enemy Solar Crest, guaranteed Daedalus/Luminosity critical stacking and lifesteal classification were not copied. Actual POINT spells are not guarded as reflected UNIT_TARGET spells; current Starbreaker and Solar KV allow immune targets, while Hammer does not.

Implemented native/copy pass: preserved D2PT builds, roles, talent names/order and custom build handling byte-for-byte through MinionThink. Solar saves and controlled/remote fight joins now precede local farming, use a live real allied hero anchor with prediction bounded to the current 350 offset, avoid known unpassable/Chronosphere/Black Hole landings and heavily outnumbered arrivals, reject blocked heal-only trips, and can include invulnerable allies without J.IsValidHero filtering. Exposed channel protection queues BKB then Solar with combined mana, instead of issuing two overwriting immediate actions. Close Starbreaker follows allied control and hits physical/debuff-immune targets, reads all three attacks for lethal only with sufficient remaining stun, uses conservative first-hit estimates otherwise, supports Shard escape without invented movement orders, respects physical protection/Rupture and clustered farm/armor/mana. Hammer uses already-resolved talent range/speed once plus explicit active Lens and unbroken Supremacy; bounded moving predictions use actual projectile travel, guarantee only outgoing-hit damage, handle aligned wave/camp targets and escape direction. Converge requires recorded successful Hammer dispatch and a live linked visible ready ability, waits outbound arrival, stops trusting the stationary position at automatic-return time, verifies a useful midpoint and refuses roots/Rupture/hazards. New Rubick UsePendingConverge hook preserves unrelated channels, casts and queues; root owns registration/dispatcher integration. Missing linked ability or no Hammer history returns safely. Passive Luminosity/Break of Dawn and hidden Land are never fabricated or cast.

Focused verification: tests/dawnbreaker_ability_spec.lua prints exact marker Dawnbreaker ability scenarios passed; native/copy behavioral scenarios cover current physical immunity, sufficiently long versus brief stun for three attacks, close two-hero teamfight control before farm, Shard escape/Rupture, ancient clusters/armor, legal Lens/Supremacy/Break range and once-only resolved talent, moving projectile/regen timing, conditional return damage, aligned versus spread waveclear and Solar mana reserve, global/invulnerable/illusion/blocked-heal anchors, current offset clamp, immune fight joins and outnumbered/hazard refusals, solo recent pressure and BKB combined mana/queue order, real versus missing/historyless/expired Converge, unrelated channels/queues, root/Rupture/passability and native cast order. Lua 5.2 parse and git diff --check passed. Valve checker passed 128 hero files, 27 Rubick copies and 0 allowlisted findings against cf0d37a. Exact native build/MinionThink prefix comparison to HEAD passed. Parent owns final integrated rerun and acceptance/status finalization.

Lobby pending: validate live Hammer GetSpecialValue range/speed talent and item range, projectile prediction and no-history linked Converge grant for Rubick; stationary Hammer auto-return expiry and midpoint geometry on slopes/cliffs; actual Starbreaker attack/Luminosity proc sequencing, sufficient stun duration, Shard immunity and free movement without injecting unverified movement commands; global allied anchor eligibility while banished/invulnerable, predicted offset cast legality, pulse healing versus Ice Blast/Doom, ally Duel/Arena/global initiation saves and landing outside Chronosphere/Black Hole; queued BKB then Solar and interrupts that still pierce BKB; current Scepter following aura/healing amplifier and stolen Solar behavior. No artificial airborne steer, channel cancellation or hidden Land casts were added: retained KV controls are not sufficient evidence of current live mechanics. TASK-21 follow-ups: Soul Ring mana conversion with Luminosity recovery, Echo Sabre/Harpoon/Blink combo item timing, Holy Locket healing, Refresher combined mana, BKB protection around Solar. TASK-24 follow-ups: spacing/kiting Starbreaker, anti-heal and armor, Break against Luminosity, tracking global Solar availability, reliable channel interruptions (including Carapace/Global Silence), and landing response/displacement such as Glimpse. Synergy pick data belongs in matchups; no shared item/minion/draft code or WeakHeroes classification changed.

Final verification after all review repairs (2026-10-01): node tests/run-builds.cjs exited0; all five hero spec exact markers verified, 358 Lua files parsed, pinned Valve audit128 native heroes/27 Rubick copies/0 findings, 127 role tables, 112 specialized dispatches,64 Rubick behavior cases and272 purchase lists. git diff --check passed. All five original build/skill/talent prefixes remain byte-identical to HEAD. New handlers and early hooks are integrated; existing prior-batch scenarios still pass. TASK21/24 observations recorded. No lobby launched; standard pass handed off as Needs In-Game Test with capability limits above.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Dawnbreaker native and dedicated Rubick logic improves global Solar saves, real physical Starbreaker control, predicted Hammer/farming and safe tracked Converge, including pending stolen follow-up. Builds retained. Hero scenarios, final full suite and Valve check pass. Live linkage, Shard movement, invulnerable anchors and Scepter behavior remain lobby checks.
<!-- SECTION:FINAL_SUMMARY:END -->
