# Hot Potato And Seat Guide

- **Parent goal:** `docs/tasks/buffet-nomination-fixes.md`
- **Owner:** Luna
- **Status:** Ready for Sol review and clean redeploy/reload
- **Updated:** 2026-08-02 00:59:55 +02:00
- **Assignment:** Fix Storyteller Hot Potato throwing, set five-block reach, add escalating heartbeat feedback, and implement daybreak/nomination seat-guide windows with a five-second post-entry tail.

## Accepted Behavior

- The current Storyteller holder must not collide with their own throw ray. Other Storytellers remain trace blockers and invalid recipients.
- Hot Potato uses a nominal five-block reach: 20 quarter-block ray steps.
- The final-ten-second heartbeat uses monotonic interval/pitch bands: timer `151..200` every 16 ticks at 1.00, `101..150` every 12 at 1.20, `51..100` every 8 at 1.45, and `1..50` every 4 at 1.75. The ascending score ranges are the valid Minecraft form of the accepted descending countdown bands.
- Phase 1 starts a daybreak seat-guide window that continues through phase 2. Each phase-3 entry starts a fresh nominations window.
- For each active seated player, the existing private chair ring renders every five ticks until Townsquare entry, then for the 100-tick tail. It stops outside phases 1..3. There are no nominee particles or automatic teleports.

## Allowed Scope

- `Jays-Patch/datapack/data/botc_patch/function/fun/hot_potato/`
- `Jays-Patch/datapack/data/botc_patch/function/seat_guide/`
- Narrow feature-owned initialization in `Jays-Patch/datapack/data/botc_patch/function/load.mcfunction`
- `tools/tests/test-fun-toybox.ps1`
- `tools/tests/test-seat-layouts.ps1`
- This worker journal only; `Jays-Patch/README.md` and `docs/code-library/feature-map.md` remain Sol-owned drafts.

## Evidence

- Initial source inspection proved the collision selector treated the holder as a Storyteller blocker, the range was `80`, and the heartbeat was fixed at a 20-tick/1.25 cadence.
- `shoot.mcfunction` now initializes `botc_fun_hot_range` to `20`; `raycast.mcfunction` excludes only `tag=botc_fun_hot_holder` from the Storyteller collision selector. The unchanged recipient selector still excludes `tag=storyteller`, while other Storytellers remain collision blockers.
- `tick.mcfunction` now has four count/sound/reset triplets using the accepted intervals and pitches. Each sound still executes at the holder and targets `@a[distance=..32]`; cooldowns, immunity, token/head restoration, and the 600-tick explosion timer were not changed.
- The seat guide now uses a global phase-window serial plus per-player window, entry, and tail scores. Phase 1 and every new phase-3 entry increment the serial; phase 2 only updates the phase tracker. A game change or serial mismatch resets the player state. Existing tail ticks decrement before a new entry can seed `100`, so the entry tick receives the complete 100-tick countdown.
- `stop.mcfunction` resets cadence, phase tracking, entry, and tail state outside phases 1..3. The existing eligible-player, active-game, seat-ID, private `force @s`, marker, and five-tick cadence paths remain in use.
- A live startup sync occurred during the first edit and reported `Failed to load function botc_patch:fun/hot_potato/tick`, line 16: `Min cannot be bigger than max`. The source had written invalid descending score ranges such as `200..151`. All four ranges are now ascending, and the focused fun test rejects those four invalid spellings.

## Inference

- The source and focused tests prove the requested code paths and structural invariants. They cannot prove particles, ray hits, or audio timing on a running server.
- The legacy `botc_seat_guide_day` objective remains declared but is no longer consulted. Removing a live scoreboard objective is outside this bounded behavior change and unnecessary for the new window model.

## Recommendation

- Sol should perform a clean source deployment and `/reload` (or the project's normal clean reload route) before any live Hot Potato/seat-guide QA. The prior live parser attempt was against an invalid mid-edit source state, so it is not a successful runtime check of this corrected version.

## Changed Files

- `Jays-Patch/datapack/data/botc_patch/function/fun/hot_potato/shoot.mcfunction`
- `Jays-Patch/datapack/data/botc_patch/function/fun/hot_potato/raycast.mcfunction`
- `Jays-Patch/datapack/data/botc_patch/function/fun/hot_potato/tick.mcfunction`
- `Jays-Patch/datapack/data/botc_patch/function/seat_guide/tick.mcfunction`
- `Jays-Patch/datapack/data/botc_patch/function/seat_guide/player_tick.mcfunction`
- `Jays-Patch/datapack/data/botc_patch/function/seat_guide/start_window.mcfunction` (new)
- `Jays-Patch/datapack/data/botc_patch/function/seat_guide/reset_player.mcfunction` (new)
- `Jays-Patch/datapack/data/botc_patch/function/seat_guide/stop.mcfunction` (new)
- `Jays-Patch/datapack/data/botc_patch/function/load.mcfunction`
- `tools/tests/test-fun-toybox.ps1`
- `tools/tests/test-seat-layouts.ps1`

## Checks

| Check | Result | Evidence |
|---|---|---|
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/tests/test-fun-toybox.ps1` | Pass | `Fun toybox, King item, and itemless targeted Vizier entrance checks passed.` after the ascending-range correction. |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tools/tests/test-seat-layouts.ps1` | Pass | `Symmetric seat-layout checks passed.` after the seat-guide window/tail assertions. |
| `git diff --check` plus no-index whitespace checks for the three new seat-guide functions | Pass | No output. |
| Live startup sync/reload | Failed on superseded intermediate source | Parser error above. A clean redeploy/reload of the corrected source is still required. |

## Decisions And Deviations

- The only adjustment after implementation was translating the accepted countdown bands into valid ascending Minecraft score ranges and adding regression assertions against the invalid descending form. This preserves the exact timer values, intervals, and pitches.
- No Sybillian `ct:` source, runtime world output, shared docs/indexes, protected drafts, nominee effects, or player teleport behavior was edited.

## Current Blocker

None for source implementation. Successful live parser/load and gameplay verification remain with Sol after clean deployment/reload.

## Final Handoff

- **Behavior implemented:** Five-block self-safe Storyteller Hot Potato throws; four escalating holder-centered heartbeat bands; phase-scoped, per-player seat-guide windows with a 100-tick post-Townsquare private ring tail.
- **Checks:** Both required focused suites passed after the parser fix; diff whitespace checks passed.
- **Manual work:** Cleanly deploy/reload the corrected source, then verify a Storyteller holder can pass five blocks without self-collision, other Storytellers still block/refuse, heartbeat tempo/pitch increases across all four bands, and the private ring restarts at nominations and ends 100 ticks after Townsquare entry.
