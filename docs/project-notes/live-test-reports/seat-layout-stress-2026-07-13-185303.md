# Seat Layout Live Stress Test

- Started: 2026-07-13 18:53:03
- Finished: 2026-07-13 18:55:00
- Player counts: 5 through 15
- Result: FAIL
- Failure: Count 10 clock arm did not rotate toward seat 10.

| Players | Pregame | Lock | Dawn | Lamp | Clockhand | Vote | Grimoire |
| ---: | --- | --- | --- | --- | --- | --- | --- |
| 5 | pass | pass | pass | pass | pass | completed (max index 5) | sampled at 15 |
| 6 | pass | pass | pass | pass | pass | targeted | sampled at 15 |
| 7 | pass | pass | pass | pass | pass | targeted | sampled at 15 |
| 8 | pass | pass | pass | pass | pass | targeted | sampled at 15 |
| 9 | pass | pass | pass | pass | pass | targeted | sampled at 15 |

## Log Review

- Seat-layout/function errors: 8
- New lag warnings: 0
- Known FancyMenu codec noise: 0

The script removes temporary SeatProbe players and restores the five-player pregame state.
