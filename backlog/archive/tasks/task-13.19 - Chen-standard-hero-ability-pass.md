---
id: TASK-13.19
title: 'Chen: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 16:04'
updated_date: '2026-10-02 15:48'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_chen.lua
  - bots/FunLib/rubick_hero/chen.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/FunLib/rubick_hero/chen.lua
  - bots/BotLib/hero_chen.lua
  - tests/chen_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 59000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Chen is in the next standard-pass batch after Bloodseeker/Bounty Hunter/Bristleback/Broodmother/Centaur. Review current ability decisions and combos against guide strategy and authoritative mechanics, including applicable Rubick handling. Existing D2PT builds and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile pinned Valve/localization with TDL 129081331 and full dotacoach Strategy/Counter/Matchup; current Zealot recall, ally-only Divine Favor, Pure Penitence, Shard ancient quota and Scepter Hand of God channel supersede old Test of Faith/recall tips. Preserve build prefix and weak-hero status.
2. Implement legal/guarded Penitence with kill, lane/army attack and escape opportunities; urgent allied Favor targets only, self-cast army armor, and heal amplification without obsolete recall logic. Expand global Hand of God to endangered allies of any role including invulnerable/banished allies, blocked healing and strong dispel/Scepter contexts; emergency heal remains first.
3. Rebuild ownership-aware recruitment: level/range/team guards, useful creep ranking, fill spare slots, enemy creep steals and Shard ancient limit derived from Hand of God. Avoid automatic oldest-unit replacement; add safe current Zealot recall for distant owned units instead. Mirror stealable decisions with missing linked spells safe. Coordinate any shared Zealot Martyrdom need with root.
4. Add native/copy behavior scenarios, run focused marker/Valve/parse/whitespace, and record source exclusions, item/counterplay follow-ups and fixed-roster lobby checks. Parent runs shared suite/final status; no weak-list removal or deep-dive claim.

5. Root approved narrowly owned minion_with_skill.lua addition for current Zealot Martyrdom. Add explicit threatened-ally heal / safe lethal or desperate enemy sacrifice, suppress generic fallback only for this spell, and test through real Think dispatch while preserving unrelated minion decisions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01): doc2 standard pass; pinned Valve Chen hero KV https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_chen.txt and English abilities localization at the same commit; tests/valve/abilities.json. Zealot unit Ability1 chen_martyrdom independently verified in pinned npc_units.txt (local /tmp/brewmaster-units-valve.txt). Current Penitence is 800-range/non-piercing/Pure (50/100/150/200); Persuasion is 600-range, 3/4/5/6 creep-level cap and 1/2/3/4 unit quota; Shard ancient quota follows Hand of God level. Favor buffs allies with armor/heal amplification; self-cast buffs the army. Zealot is active innate recall, not a passive-only slot: six-second delayed teleport, cancelled by hostile damage. Hand of God heals all allied heroes including hidden/invulnerable allies, plus controlled units; Scepter channels up to six seconds with nearby debuff immunity and stronger HoT; selected level25 talent enables strong dispel.
TDL Workshop 129081331, Position5 / 7.41f https://steamcommunity.com/sharedfiles/filedetails/?id=129081331, fetched node tools/tdl/fetch.cjs chen. Reviewed all ability and item tips. Used aura/control creep recruitment, Penitence attack setup, global heal awareness, Shard ancients and army protection. Excluded old Test of Faith spells, old self Favor recall, ancient recall attributed to Persuasion, removed attack-range benefit, universal hero attributes, and blanket Lotus/Greaves removal of hard disables. Builds remain D2PT-only and unchanged.
dotacoach https://dotacoach.gg/en/heroes/chen: web fetch timed out twice; shell fetched and read full rendered Strategy/Counter Strategy and current ability notes. Applied available army recruitment, lane pressure, global saves, early grouping and safe repositioning. Unsummon advice is current but automatic disposal/replacement remains deferred to avoid destroying useful oldest units without a unit job policy. Counter ideas about camp blocking, early Roshan vision, healing reduction and channel interruption route to TASK24. https://dotacoach.gg/en/heroes/counters/chen: full Matchup allies/core items/good-and-bad matchups/counter items read. Reviewed Meepo/Morph/Lina/Lycan/Centaur/Drow/Tiny attack/control/heal support; enemy summons can be recruited. Army protection against Earthshaker/Sven/Alchemist/KotL AoE and healing reduction matters. Rejected unsupported Morph-replicates-key-creep claim, direct damage-amplification wording for Penitence, and implied immunity to every disable under Scepter.
Implementation: native and Rubick use legal Lens/Supremacy reach and current spell-block/reflection/Counterspell+Ally guards. Penitence recognizes Pure kills, lane aggression, army attack setup, disabled targets and escape slows without requiring two heroes attacking. Recruitment refreshes our own live controlled-unit count, checks cap/level/range/team, prefers useful aura/control units, fills spare slots, steals eligible enemy creeps and permits Shard ancients only within current ultimate-level quota; missing Rubick linked ultimate is safe. Favor targets allies only, protects threatened heroes and self-buffs the army; no obsolete teleport commands. Hand of God prioritizes endangered allies of every role globally (including banished/invulnerable), multiple wounded allies, two endangered high-level owned creeps, strong dispel and useful nearby Scepter protection. Known Ice Blast/Doom heal blocks are excluded as sole healing reason. Current Zealot recalls distant unthreatened units toward a safe caster.
Root approved narrowly scoped minion_with_skill.lua Martyrdom handler: useful threatened ally heal first; current-health damage uses live GetDamageType for safe enemy lethal/desperate value; unknown/NONE damage type does not invent kills. Spell is excluded from generic unit-target fallback so withholding a sacrifice remains meaningful. Existing other-minion behavior is untouched.
Focused verification: tests/chen_ability_spec.lua exact marker Chen ability scenarios passed. Tests exercise native/copy Pure damage, immunity/block/reflection, Counterspell+Ally, real range/Lens/Supremacy/Break, support/invulnerable global healing, blocked heals, strong dispel, Scepter, owned quotas/levels/ancients, ally Favor, native recall/cast priority and the real minion dispatcher for heal/lethal/desperate/no-fallback sacrifice. Lua5.2 parse of native/copy/minion/spec, Valve checker (128 heroes,22 copies,0 allowlisted findings) and whitespace pass. Parent integrates shared runner/status/AC. Chen weak flag retained; no game or deep dive performed.

Fixed-roster lobby checklist (pending): Chen/Rubick + Meepo/Lycan/Lina/Centaur against Anti-Mage/Enchantress/Beastmaster/AA/Earthshaker/Sven. (1) Recruit early low-level Harpy/control unit, fallback aura creep, enemy summon/dominated unit; verify legal target classes, level/ownership counts and fresh acquisition health/mana. Add Shard/ultimate levels1–3 for ancient quotas, verify Zealot does not inadvertently consume persuaded quota through inherited modifiers. Full army is preserved; automatic unsummon/replacement remains a unit-policy follow-up. (2) Penitence Pure nuke/slow with army attacks, BKB/block/Lotus/current Counterspell+Ally, controlled target and legal Lens/Supremacy range; confirm GetCastRange bonus reporting. (3) Favor ally retreat/save and self army armor/heal amplification, never enemy targets. Pinned SpellImmunity says ALLIES_YES but target flags contain NOT_MAGIC_IMMUNE_ALLIES; current decisions conservatively avoid BKB allies pending actual cast confirmation. (4) Global HoG on remote support and banished/invulnerable teammate, Meepo clones, blocked IceBlast/Doom healing, multiple wounded allies and valuable owned creeps. Verify strong dispel removes supported disables. (5) Scepter initial global heal/channel immunity radius/boosted HoT; engine channel state must prevent subsequent spell/minion owner actions interrupting it. BKB preparation belongs to generic item policy. (6) Current Zealot recall with six-second delay, no obsolete Favor teleport; verify owned unit/Chen targeting, hostile-unit damage cancellation and travel-queue interactions. (7) Zealot Martyrdom through normal MinionThink: threatened ally healing, live damage type/masks, blocked/reflected enemy, lethal/desperate sacrifice and healthy-unit preservation. Pinned KV omits offensive damage type; if GetDamageType returns NONE, offensive sacrifice intentionally remains withheld while healing still works. Generic scouting/stacking/body-blocking/split-push job policy and comprehensive army AoE avoidance remain deeper minion work.
Follow-up routing: TASK21 contextual Mekansm/Greaves/Locket and Pipe/Vladmir/Drums/Solar army sustain, Scepter channel BKB protection and healing-amplification sequencing; TASK24 camp blocking/unblocking, early Roshan vision, anti-heal/Crimson/armor/AoE counterplay and interrupting Chen Scepter channel. Any army spread/scout/stack/split-push/disposal policy belongs to generic minion coordination. No build/draft changes or weak-list removal.

Review repair: Martyrdom lethal sacrifice now uses J.WillKillTarget with actual cast point plus projectile travel (live speed, pinned1000 fallback only for absent/nonpositive value), allowing target regeneration and expected incoming attacks before committing the unit. Real minion Think regression: healthy1000HP Zealot produces225 damage, target220HP at500 distance with20HP/s regen survives the0.8-second impact window; no sacrifice or generic fallback occurs. Chen ability scenarios passed, focused Lua5.2 parse and whitespace checks pass. Parent reruns full suite.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 after all review repairs; exact markers confirmed for all five new hero specs, 348 Lua files parsed, Valve check 128 native heroes / 22 Rubick copies / 0 allowlisted findings, 127 hero role tables, 90 specialized dispatches, 61 Rubick behavior cases and 272 purchase lists. git diff --check passed. HEAD comparison confirms this hero build/skill/talent prefix unchanged. No lobby launched; standard pass handed off as Needs In-Game Test, with capability limits above. Item/counterplay findings appended to TASK21/24.

2026-10-02 integration API follow-up: replaced undocumented HasShard() calls with the existing modifier_item_aghanims_shard convention used by this repository. Fixtures use the actual modifier query, retaining shard state scenarios. Focused hero scenarios passed; builds and skill/talent preferences retained. Lobby verification remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Chen native and applicable Rubick spells now use ownership-aware recruitment, current Zealot recall, legal Favor and global heal/dispel priority. Narrow Martyrdom handling preserves units unless a supported heal or safe sacrifice is useful, including projectile-time regeneration. Builds and weak flag retained. Focused scenarios, final shared suite and Valve check passed; army deep dive and lobby validation remain pending.
<!-- SECTION:FINAL_SUMMARY:END -->
