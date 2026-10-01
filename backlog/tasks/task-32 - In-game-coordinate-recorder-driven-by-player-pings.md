---
id: TASK-32
title: In-game coordinate recorder driven by player pings
status: In Progress
assignee:
  - '@claude'
created_date: '2026-09-30 17:39'
updated_date: '2026-09-30 18:34'
labels:
  - tooling
dependencies: []
references:
  - bots/FunLib/debug_dumps.lua
  - bots/ability_item_usage_generic.lua
priority: high
ordinal: 36000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pulls (TASK-5) and stacks (TASK-6) need current map positions and timings that no data source has for the post-7.33 map: where to stand to aggro a camp, where to drag it, where the wave meets it, and at what second. The user can collect these in a lobby by pinging spots, if a bot echoes each ping's coordinates and context back to the console log and team chat. Also useful for later map work (ward spots, rune spots).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Each ping by a human teammate is logged once with an index, game time, ping location and the human hero's location
- [x] #2 The log line includes the nearest neutral camp (and whether the ping is inside its spawn box) and each lane's front amount
- [x] #3 The same summary is echoed in team chat so the player sees it in game
- [ ] #4 Disabled by default and switched on by one flag; no effect on normal games
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Add a ping recorder to FunLib/debug_dumps.lua (poll the human's most recent ping from the first bot, as the spawner dump does).
2. Output via OhaRawPrint (OHA_DUMP|pin lines) and team chat.
3. Hook it next to the spawner dump in ItemUsageThink.
4. Offline spec with mocked pings; then the user collects pull/stack spots in a lobby.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Implemented D.RecordPings in FunLib/debug_dumps.lua, called from ItemUsageThink after the spawner dump. The team's first bot polls each human teammate's GetMostRecentPing and logs every new ping once: OHA_DUMP|pin|n|time|ping x,y|hero x,y|danger|nearest camp (key, type, team, distance to spawn box)|lane front amounts. The same summary goes to team chat. Stale pings from before the first check are skipped; an error disables the recorder and is logged once. Chat commands were not used: item usage already installs a chat callback for bot replies, and a second callback might replace it. tests/ping_recorder_spec.lua (in run-builds.cjs) passes. PingRecorderEnabled is true for the collection game; switch it off afterwards (AC 4).

Verified in the 2026-09-30 lobby: pins logged with index, time, ping and hero positions, nearest camp with box distance, and lane fronts (see TASK-5 notes); the team-chat echo was sent (the log shows the chat text passing through CLocalize). Recorder left enabled for the stacking measurements (TASK-6); switch D.PingRecorderEnabled off afterwards.
<!-- SECTION:NOTES:END -->
