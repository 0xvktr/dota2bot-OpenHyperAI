---
id: TASK-36
title: Improve small item and spell decisions after Power Treads
status: To Do
assignee: []
created_date: '2026-10-01 09:36'
labels:
  - items
  - hero
  - laning
dependencies: []
references:
  - >-
    https://github.com/0xvktr/dota2bot-OpenHyperAI/commit/183af6b770de1c1b190f51e98b2290c0fe223097
  - 'https://dotacoach.gg/en/items/mask-of-madness'
  - 'https://dotacoach.gg/en/items/soul-ring'
  - 'https://dotacoach.gg/en/items/enchanted-mango'
  - 'https://dotacoach.gg/en/items/magic-wand'
  - bots/ability_item_usage_generic.lua
  - bots/FunLib/inventory_upkeep.lua
  - bots/FunLib/jmz_func.lua
  - bots/BotLib/hero_obsidian_destroyer.lua
documentation:
  - docs/POWER_TREADS.md
priority: medium
type: enhancement
ordinal: 40000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
The user requested one task to hand off five small gameplay improvements identified while implementing Power Treads switching. These are item/spell decision improvements with bounded scope, not a general combat or inventory rewrite. Mask of Madness and protected backpack slots appear to be the smallest and most directly testable opportunities; mana restoration and OD autocast need more intent/resource-policy review.

## Baseline and related work
Power Treads work is committed and pushed as 183af6b770de1c1b190f51e98b2290c0fe223097 on d2pt-7.41f-updates. TASK-34 remains Needs In-Game Test; its shared module is bots/FunLib/power_treads.lua and policy/lobby checklist is docs/POWER_TREADS.md. Existing two-argument J.SetQueuePtToINT calls remain supported, with an optional ability argument for explicit urgency/illusion decisions. The generic executor retains targets and appends prepared item use to the toggle queue; idle Treads switching is evaluated after other items. Preserve these behavior guarantees.

TASK-30 already tracks broad inventory management, including protected boots/key actives, Aegis pickup and full-inventory build completion. This task covers only consumable-swap protection, not the other TASK-30 work. TASK-26 tracks general lane mana reserves; this task covers restoration intent and the specific OD autocast case. Do not close those broader tasks solely on this work. TASK-33 concerns purchasing Magic Wand/Soul Ring components, a different problem from using the items. Existing unrelated lane-pull, ping-recorder and map work may be present in the checkout; inspect status and preserve it.

## Findings to verify against the current checkout
1. Mask of Madness: bots/ability_item_usage_generic.lua, ConsiderItemDesire[item_mask_of_madness], around lines 3527-3561. The predicate includes botName ~= sniper OR botName ~= medusa OR (botName ~= faceless_void AND ultimate:GetCooldown() > 0). A hero cannot be both Sniper and Medusa, so the first two comparisons make it always true. This is a confirmed logic defect, not just a proposed optimization. The outer condition permits combat activation; self-silencing can therefore preempt intended important spells. Also review GetCooldown() versus actual remaining cooldown/readiness: swapping Boolean operators alone may not express the intended policy. Current Drow activation is disabled explicitly; retain/review that existing exception rather than silently enabling it. Current item guide confirms Berserk silences the user.

2. Backpack protection: bots/FunLib/inventory_upkeep.lua, KeepInMain (line 17), PickMainSlot (line 21), SwapInBackpackConsumable (line 53). Only TP scroll and Travel boots are protected; ordinary boots and other key actives can be selected as the cheapest main-slot item. The generic consumable swap has no local combat/damage safety gate. Compare bots/FunLib/lotus_usage.lua: its separate Lotus preparation already protects Treads/important items and avoids combat swaps. Backpack swaps impose a cooldown, so moving a Clarity or Faerie Fire into inventory is not an instant emergency-use technique. Existing swapVerified handles rejected swaps, and the consumable path restores displaced items after use; retain these behaviors.

3. Soul Ring intent: generic ConsiderItemDesire[item_soul_ring], around line 6552, activates in FARM/LANING with health >50% and mana <50%, even without an identified spell. Separately, J.SetQueueUseSoulRing and J.SetQueuePtToINT in bots/FunLib/jmz_func.lua (around lines 2805 and 2827) already provide pre-cast queuing. Review both paths together: the gap is spontaneous generic use/weak need checking, not absence of a cast helper. Soul Ring mana is temporary and unused mana expires. Preserve health safety, Treads action locks and the existing emergency-save bypass of extra Soul Ring/Treads preparation.

4. Mango/Stick/Wand intent: generic Mango handler around line 2221 consumes whenever mana <150, regardless of useful next action. Stick/Wand handlers around lines 3214/3254 use charge/HP/MP/enemy thresholds. A Mango could enable a valuable spell even above 150 mana, or be wasted below 150 without a worthwhile action. Distinguish cast-enabling restoration from existing emergency healing; Wand charges should not be drained solely for low-value mana top-ups. Important integration issue: IsFullyCastable() is false when mana is insufficient, so existing Consider spell functions may return before expressing intent. Any intent handling must still reject cooldown, untrained/hidden, invalid-target, range and disabled-action cases. Do not indiscriminately make unavailable spells selectable.

5. OD Arcane Orb: bots/BotLib/hero_obsidian_destroyer.lua, SkillsComplement around lines 66-75, turns autocast back on whenever Orb is trained, autocast is off and level >=9. ConsiderArcaneOrb around line 106 then declines manual Orb while autocast is on. This can force spending on ordinary attacks regardless of reserve. Unlike the MoM Boolean defect, this is a policy-improvement candidate; assess current Essence Flux/mana recovery before choosing limits. Focus on preserving mana for Astral Imprisonment/Sanity's Eclipse while retaining valuable Orb attacks and normal farming, rather than redesigning every hero's orb logic.

## Validation and handoff constraints
The PT staged snapshot passed node tests/run-builds.cjs (126 heroes / 250 roles), node tests/run-objectives.cjs and git diff --cached --check. Existing relevant suites: tests/inventory_upkeep_spec.lua, tests/power_treads_spec.cjs/.lua, tests/hero_harness.lua, tests/feedback_spec.lua and tests/valve_ability_check.cjs. Local Lua tools live under git-ignored .test-tools/node_modules; the runners already support them. PT tests exercise real shared helpers, item executor and item loop with a deferred action queue and percentage-preserving resource model; avoid weakening those assertions to accommodate new logic. Test actual decision behavior, not only source-text presence.

Recheck engine/item values against the pinned Valve data and current sources before implementation; line numbers above are navigation hints. Document lobby checks and use Needs In-Game Test when only offline behavior is verified. This task is deliberately To Do and unassigned for the next agent to research and record its own implementation plan; no implementation is requested in this handoff-creation turn.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Mask of Madness respects documented hero-specific important-spell safeguards; regressions expose the previous always-true predicate and preserve valid farming use.
- [ ] #2 Consumable preparation never backpacks protected boots or key actives or removes needed defensive stats in combat; rejected swaps and restoration of displaced items still work.
- [ ] #3 Soul Ring use is justified by a valid useful impending cast with a safe health reserve, rather than only generic health/mana percentages; tests cover missing intent, unusable spells and safe pre-cast execution.
- [ ] #4 Mango and charged Stick/Wand restoration can enable a valid important cast without wasting restoration on invalid or low-value actions; existing emergency healing is preserved.
- [ ] #5 OD Arcane Orb autocast follows a documented mana-reserve policy that preserves important spell availability while allowing valuable Orb attacks and normal farming; current mana recovery is considered.
- [ ] #6 New behavior preserves Power Treads preparation, action locks, target identity, emergency-save timing and channel/queue safety; meaningful offline regressions and existing relevant suites pass.
- [ ] #7 Documentation records the chosen policies, evidence and remaining lobby checks, and identifies the narrow contributions to TASK-30 and TASK-26 without claiming those broader tasks complete.
<!-- AC:END -->
