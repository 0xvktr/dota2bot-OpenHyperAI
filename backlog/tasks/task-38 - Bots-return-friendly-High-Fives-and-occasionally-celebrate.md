---
id: TASK-38
title: Bots return friendly High Fives and occasionally celebrate
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 18:34'
updated_date: '2026-10-01 18:51'
labels: []
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
  - bots/FunLib/aba_global_overrides.lua
  - bots/FretBots/modifiers/Modifier.lua
  - bots/FunLib/high_five.lua
  - tests/high_five_spec.cjs
documentation:
  - docs/HIGH_FIVES.md
priority: low
type: enhancement
ordinal: 73000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
User wants a small social interaction: bots should return nearby human High Fives and sometimes initiate one after a successful fight or rescue. Existing FretBots behavior only adds a request modifier after killing a human, using server-side access. Ordinary Bot API cosmetic ability access remains unverified in a live lobby; game files define plus_high_five/high_five as instant no-target abilities.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Eligible bots respond to a visible nearby allied human High Five request without moving toward the player or spamming repeated attempts.
- [ ] #2 Bots occasionally initiate near allied humans after a recent kill/assist or completed rescue, with a bounded window and cooldown rather than constant random spam.
- [x] #3 Cosmetics yield to combat, danger, attacks, pending item/spell casts and channels; clones/illusions and unavailable ability handles are safely excluded.
- [x] #4 Hidden ability protection allows only a scoped High Five request and retains existing Twin Gate diagnostics and rejection of unrelated hidden spells.
- [x] #5 A user setting can disable the behavior; offline policy/integration regressions pass and live Bot API availability/animation checks are documented without claiming unverified support.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add a shared social policy for nearby allied human requests and bounded post-kill/assist or post-rescue celebrations, using the pinned instant cosmetic ability names and values. Protect action queues, channels, attacks and danger, preserve normal movement, and fail quietly when no usable handle exists. 2. Wire the low-priority cosmetic check into generic ability think after hero decisions, with a tightly scoped hidden-ability exception and explicit enable/debug settings. 3. Exercise the real policy, hidden wrappers and generic think integration with engine stubs; run existing objective/build suites and document lobby checks and the server-side FretBots distinction.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented the friendly ordinary-Bot-API policy. Reply targets are visible real allied humans within the pinned 900-unit range. Persistent requests are attempted once, with request endings observed during cooldown, ten-second local attempt spacing and a short peer reservation. A single 25% roll after a new kill/assist or an observed assist/push-to-return rescue transition gives a fifteen-second celebration window, with ninety seconds between offers. Bots do not move toward players, wait, chat or queue cosmetic orders. Casting/channel/queue, attacks, retreat/defense, damage, local enemies, invisibility/disables and duplicate/illusion checks take precedence.

Generic AbilityUsageThink runs hero spell decisions first and skips social logic when boss combat acts. Twelve existing immediate/queued/pushed ability cast shapes record order timestamps without changing arguments or results, closing the same-frame gap before engine casting state updates. Only the exact scoped plus_high_five/high_five handle can bypass hidden rejection for the immediate no-target action; permission clears on errors. Twin Gate diagnostic behavior and unrelated hidden spell rejection are retained. Active custom-loader settings include default-on Allow_High_Fives and opt-in Debug_High_Fives. The old server-side FretBots kill-taunt implementation is unchanged.

Verification: node tests/high_five_spec.cjs passed 30 scenarios exercising actual policy, wrappers and generic ability Think; full node tests/run-objectives.cjs and node tests/run-builds.cjs passed (379 Lua syntax files in the latter), including existing hero/item/purchase/lane/TP suites. git diff --check passed. AC 3-5 are verified offline. AC 1-2 remain unchecked until a lobby confirms that native bots receive castable cosmetic handles and complete real responses/offers; engine-stub tests prove decision behavior but cannot prove Bot API cosmetic availability or animation/movement semantics. docs/HIGH_FIVES.md provides settings, limits and lobby steps. If handles are absent or unusable the feature quietly skips; debug output distinguishes a non-throwing order from a verified animation.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added nearby allied-human High Five replies and occasional post-fight/rescue offers, with no detours or queued cosmetic actions. Gameplay decisions, danger, spell/item queues and channels take priority through actual action-state checks and same-frame order tracking. Thirty dedicated scenarios and full objective/build suites passed. Native cosmetic handle availability and completed interaction/movement behavior still require live lobby validation; TASK-38 is Needs In-Game Test.
<!-- SECTION:FINAL_SUMMARY:END -->
