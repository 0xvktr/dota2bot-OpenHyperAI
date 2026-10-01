---
id: TASK-35
title: Interactive schematic map for planning bot routes and timings
status: In Progress
assignee:
  - '@claude'
created_date: '2026-10-01 09:30'
updated_date: '2026-10-01 09:36'
labels:
  - tooling
dependencies: []
references:
  - tests/neutral_spawners_741f.lua
  - docs/OBJECTIVE_TESTING.md
priority: medium
ordinal: 39000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Farm routes, stacks, pulls, rotations and ward spots are all easier to plan on a map than in coordinates, and the user wants to draw paths that get converted into bot route data. The installed map's entity file (game/dota/maps/dota.vpk, maps/dota/entities/default_ents.vents_c, readable with the Source2Viewer CLI in .test-tools/resource-reader) holds exact positions for camps, towers, barracks, ancients, runes, lotus pools, twin gates, outposts, creep lane path nodes, Roshan and Tormentor spawners, 2306 trees, and Valve's minimap boundary, so the map can be drawn in true world coordinates without a dump game. First version: schematic only (no terrain grid, no minimap art).
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A script extracts the map geometry from the decompiled entity file into one data file, with camps numbered as in tests/neutral_spawners_741f.lua
- [x] #2 The map page draws camps with numbers, types and spawn boxes, buildings, lanes, runes and objectives in world coordinates at Valve's minimap framing
- [x] #3 Measured pull data (TASK-5) is shown on the map, with room for stack timings
- [ ] #4 The user can draw a path on the map and export it as world coordinates
- [ ] #5 Hovering shows world coordinates
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Extract default_ents.vents with Source2Viewer CLI (scratch), parse entities.
2. tools/map/extract_map.cjs: classes of interest -> docs/map/map_741f.json; camp numbers and spawn boxes merged from the GetNeutralSpawners dump fixture by position.
3. Build a self-contained HTML map (SVG) from that data: layers, hover coordinates, camp labels, pull annotations, path drawing and JSON export.
4. Publish it as a page the user can open; keep the generator in the repo so it can be re-run after map patches.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Decompiled maps/dota/entities/default_ents.vents_c from the installed dota.vpk with the Source2Viewer CLI in .test-tools/resource-reader (output kept in scratch, not the repo). tools/map/extract_map.cjs -> docs/map/map_data.json (40 KB): 28 camps (all matched to the GetNeutralSpawners dump keys and boxes), 22 towers, 12 barracks, ancients, fountains, shops, 6 rune spots, Roshan pits, Tormentors, lotus pools, twin gates, outposts, watchers, the six creep lane paths (path_corner chains), 2306 trees, minimap frame +-9472. Each spawner also carries Valve's pulltype/aggrotype (the measured Radiant pull camp is pulltype 1). docs/map/annotations.json holds measured pulls, stacks (empty) and pings. tools/map/build_map.cjs + map_template.html -> docs/map/bot_route_map.html, published at https://claude.ai/artifact/CjFuAE1jMK8wz5QSZqJaLY. Rendered once in a browser: all layers draw, no console errors. Path drawing/export and hover coordinates are implemented but were not exercised interactively (the preview was a static snapshot); waiting on the user to try them.
<!-- SECTION:NOTES:END -->
