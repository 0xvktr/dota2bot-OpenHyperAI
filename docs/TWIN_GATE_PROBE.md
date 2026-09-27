# Twin Gate engine experiment

The open API report does not prove that every activation path fails. Valve's
July 26, 2023 article explains that a human attack click on a channelable map
entity becomes an ability cast. Whether the ordinary bot `Action_AttackUnit`
order performs the same conversion needs an actual engine test:
https://store.steampowered.com/news/posts/?appids=570&enddate=1691809824

The diagnostic is disabled by default. For a disposable Local Host / Local Dev
Script match, set `TwinGateProbe.Enabled = true` in
`bots/FunLib/objective_settings.lua`. `Team` defaults to `TEAM_RADIANT`; change
it to `TEAM_DIRE` to test that side. Start a fresh match. After game time 0:20,
the lowest-player-ID bot on that team temporarily leaves normal gameplay and
walks to the nearest gate. This is not a normal match or rotation test.

The gate positions come from the installed map build 25329722:
top (-6457.690918, 7599.036621, 256), bottom (6425.52832, -7313.782715, 256).
Map changes may invalidate them; approach timeout is inconclusive.

Watch your selected team's chat for `[GateProbe]`. Messages are spaced two
seconds apart, and the final result is delivered even after the bot resumes
normal play. Keep watching for about 15 seconds after it leaves the gate.
Full messages also remain in the developer console under `[GateProbe`.
The experiment logs:

- Gate handles exposed by `GetUnitList(UNIT_LIST_ALL)`, rescanned nearby.
- Whether `GetAbilityByName('twin_gate_portal_warp')` returns a hero ability.
- One `Action_AttackUnit(gate, false)` order, with normal item/ability callbacks
  suspended for this bot while the probe owns roaming mode.
- Channel-state transitions and arrival near the opposite gate. Channeling
  alone does not count as a successful traversal.

It ends after arrival, danger, 12 seconds without arrival after the order once
not channeling, or a 90-second overall limit. Normal behavior then resumes.
Missing handles and rejected orders are logged separately. No gate is attacked
repeatedly. If a hero warp handle exists, a separate fresh match with
`Method = 'ability_entity'` tests the existing alternative cast form.

Set `Enabled = false` again before ordinary matches. No real engine result has
been collected yet; mocked tests only validate the diagnostic's control flow.
Absence in this unit list does not establish absence from every possible API.

## September 20 live result

User screenshots show Kez exposing two gate handles through `UNIT_LIST_ALL`
and a non-nil hero warp ability handle, with 363 mana at the gate. The single
attack-order test ended without observed channeling or opposite-gate arrival.
This disproves missing handles for this run; it does not rule out ability casts.
The local probe is now configured for `ability_entity`, and additionally logs
the ability's castability, hidden flag, level and remaining cooldown. These flags
are observations, not prerequisites that silently suppress this diagnostic cast.

The next live screenshots show `ability_entity` also ending without observed
channeling/arrival, despite `castable=true`, `hidden=true`, level 1, cooldown 0.
The probe is now configured as `remaining_forms`: one no-target cast, one
location cast at the entrance, and one entity cast targeting the opposite gate.
Each gets a separate 12-second observation period; an active channel is never
interrupted to advance the sequence. The whole experiment has a 120-second
limit. These are diagnostic hypotheses, not known valid targeting forms.
Behavior, target-team/type flags, and cast range are now logged as well.

The first `remaining_forms` run reported behavior 570949833, targetTeam 2,
targetType 0 and castRange 200, then failed in `aba_global_overrides.lua` before
the no-target order reached the engine. The wrapper rejected hidden abilities
and tried to call an unavailable `debug.traceback`. Logging now tolerates the
missing debug library. An active gate probe alone may pass the hidden
`twin_gate_portal_warp` through the no-target wrappers. Other hidden abilities
remain blocked. Repeat `remaining_forms`; this failed run is not evidence
against the no-target cast or the two subsequent forms, which were not tested.

## Completed follow-up: no working invocation observed

After the wrapper fix, user screenshots show Anti-Mage completing all three
remaining forms without an observed channel or opposite-gate arrival:
`ability_none`, `ability_location`, and `ability_exit`. The gate handles and
hero ability were accessible, with 267 mana, `castable=true`, `hidden=true`,
level 1, cooldown 0, behavior 570949833, targetTeam 2, targetType 0, castRange 200.
The final chat result explicitly reports `test complete`, with no wrapper error.

Together with the earlier Kez runs, the tested methods are:

| Order | Observed result |
|---|---|
| Attack entrance gate | No channel or traversal |
| Hero warp ability on entrance gate | No channel or traversal |
| Hero warp ability without target (after wrapper fix) | No channel or traversal |
| Hero warp ability at entrance location | No channel or traversal |
| Hero warp ability on opposite gate | No channel or traversal |

The probe is now disabled for ordinary matches. These observations establish
that the tested invocation paths did not work in these local runs, not that all
possible workarounds are impossible. In particular, missing handles are not the
blocker seen here, and a castable flag does not guarantee order execution.
Production gate routing remains disabled pending new API evidence or a
demonstrated working invocation. No further identical lobby runs are needed.
