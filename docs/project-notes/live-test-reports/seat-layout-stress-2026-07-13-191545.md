# Seat Layout Live Stress Test

- Started: 2026-07-13 19:15:45
- Finished: 2026-07-13 19:23:04
- Player counts: 5 through 15
- Result: FAIL
- Failure: Count 13 dead seat 13 did not show the ghost-vote marker.

| Players | Pregame | Lock | Dawn | Lamp | Clockhand/vote | Dead/ghost | Marked | Grimoire |
| ---: | --- | --- | --- | --- | --- | --- | --- | --- |
| 5 | pass | pass | pass | pass | full (5 steps/5 rotations) | pass | pass | pass |
| 6 | pass | pass | pass | pass | full (6 steps/6 rotations) | pass | pass | pass |
| 7 | pass | pass | pass | pass | full (7 steps/7 rotations) | pass | pass | pass |
| 8 | pass | pass | pass | pass | full (8 steps/8 rotations) | pass | pass | pass |
| 9 | pass | pass | pass | pass | full (9 steps/9 rotations) | pass | pass | pass |
| 10 | pass | pass | pass | pass | full (10 steps/10 rotations) | pass | pass | pass |
| 11 | pass | pass | pass | pass | full (11 steps/11 rotations) | pass | pass | pass |
| 12 | pass | pass | pass | pass | full (12 steps/12 rotations) | pass | pass | pass |

## Log Review

- Seat-layout/function errors: 11
- New lag warnings: 0
- Known FancyMenu codec noise: 44

The script removes temporary SeatProbe players and restores the five-player pregame state.
