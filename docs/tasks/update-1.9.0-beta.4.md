# Update Jay's Patch v1.9.0 Beta 4 in place

- Status: `completed`
- Updated: `2026-08-04 20:13 CEST`
- Owner: Sol
- Workflow decision: `use Sol/Luna workflow`
- Workflow reason: `This task changes two player-facing fun features and replaces an existing public package asset and tag in place. A small release and rollback record is worth the documentation cost.`
- `/plan` state: `accepted`

## Outcome

`Give the Rainbow Paint Gun a fully rainbow item name, improve Hot Potato's final-ten-second heartbeat, pass trail and announcement, give the Vizier a descending version of the King's jingle, rewrite the cumulative Beta 4 GitHub description in Jay's voice, and replace the existing Beta 4 package in place.`

## Done when

- [x] Every visible letter in `Rainbow Paint Gun` follows the full seven-colour rainbow cycle.
- [x] Hot Potato stays silent for its first 20 seconds, then plays exactly one heartbeat per second from 10 seconds remaining through 1 second, rising from pitch 0.60 to 1.95 in 0.15 steps.
- [x] Hot Potato passes draw a three-pronged flaming pitchfork and announce the sender and receiver as `<sender> starpassed to <receiver>!`.
- [x] The Vizier entrance uses the King's five-note sound sequence and timing with pitches descending from 1.50 to 0.70.
- [x] The reviewed Beta 4 public package passes its publication gate and replaces the existing GitHub asset, description and tag target without creating Beta 5.

## Scope and boundaries

- In scope: `Rainbow Paint Gun loot-table name, Hot Potato heartbeat timing and pitch, pass trail and announcement, Vizier entrance jingle, focused regression tests, generated metadata and source baseline, cumulative Beta 4 release notes, public package, source commits, existing Beta 4 tag and GitHub release asset`
- Non-goals: `new Paint Gun mechanics, changing the Hot Potato duration, resource-pack art or hosted-pack replacement, live-server deployment or reload, a Beta 5 release, or unrelated diagnostics`
- Must preserve: `all other fun-feature behavior, the existing public Beta 4 URL, stable releases, live data, BOTC-Live-Trace.ps1, tools/capture-botc-client-heap.ps1, and unrelated work`
- Safety constraints: `keep the old public asset and tag target until the replacement source and package are ready; replace only v1.9.0-beta.4; build only through the reviewed package tool; stage explicit intended paths`

## Evidence

- `The Rainbow Paint Gun loot table currently renders the complete name in one light-purple component.`
- `Hot Potato currently lasts 600 ticks and uses four pulse intervals in only the final ten seconds, with pitch bands 1.00, 1.20, 1.45 and 1.75.`
- `The current public release is v1.9.0-beta.4, targets commit 04951bd0, and owns one 73,283,934-byte package asset with SHA-256 6ea6f340aafd098f24f95761376fd976e566b7b288377ae58a52c0e8910b638f.`
- `The only unrelated worktree files are the two known untracked diagnostic scripts.`

## Inference

- `A pitch sequence from 0.60 to 1.95 in 0.15 steps gives the final ten seconds a distinct ascending heartbeat while remaining inside Minecraft's normal 0.5-2.0 audible pitch range.`

## Unknowns

- `In-game musical preference remains subjective; code and tests can prove timing and monotonic pitch, while final listening remains manual.`

## Recommendations

- `Use seven Minecraft text colours in a continuous letter-by-letter cycle and a dedicated Hot Potato heartbeat function so the timing table stays easy to audit.`

## Project-owner decisions

| Decision | Reason | Date |
|---|---|---|
| `Implement all three requested changes immediately and publish them.` | `Requested by Jay.` | `2026-08-04` |
| `Update Beta 4 in place instead of creating Beta 5.` | `Jay explicitly wants the existing public beta replaced as though it had always contained the corrections.` | `2026-08-04` |
| `Use Jay's writing guide for the public GitHub description.` | `Requested by Jay.` | `2026-08-04` |
| `Start the Hot Potato heartbeat only at 10 seconds remaining.` | `Jay corrected the earlier all-round timing before implementation.` | `2026-08-04` |
| `Use a flaming pitchfork pass trail and the literal message <sender> starpassed to <receiver>!.` | `Jay clarified that starpassed is the verb, not a star separator.` | `2026-08-04` |
| `Give the Vizier the King's jingle with descending pitch.` | `Requested by Jay before the public replacement was published.` | `2026-08-04` |

## Accepted `/plan`

1. [x] Implement the rainbow item name, final-ten-second ascending heartbeat, flaming pitchfork pass trail, sender-to-receiver announcement, descending Vizier jingle and revised cumulative Beta 4 notes.
2. [x] Run focused checks, refresh generated metadata and baseline, then build and inspect Beta 4 through the reviewed publication gate.
3. [x] Commit and push the source, replace the existing Beta 4 asset and tag target, verify the public result, and record release evidence.

## Delivery tracking

- Decision: `use accepted-plan checklist`
- Reason: `The three-step in-place update is bounded and restartable; a separate goal would duplicate it.`

### Active `/goal` (only when used)

`Not used; the accepted plan is the delivery checklist.`

## Current progress

- `The requested item-name, Hot Potato and Vizier changes are implemented. The cumulative public description is updated, and the existing Beta 4 asset and tag now point to the reviewed replacement without creating Beta 5.`

## Active Luna assignments

| Assignment | Worker journal | Allowed area | State |
|---|---|---|---|
| `None` | `N/A` | `N/A` | `No delegation; implementation and in-place release authority remain with Sol.` |

## Verification record

| Check | Result | Evidence |
|---|---|---|
| `gh --version` and `gh auth status` | `pass` | `GitHub CLI 2.96.0 is authenticated as JayLeet.` |
| `Focused fun-toybox checks` | `pass` | `tools/tests/test-fun-toybox.ps1 passed after the Hot Potato, item-name and Vizier-jingle changes; git diff --check and the obsolete fun_hot_pulse source scan also passed.` |
| `Known-good source baseline refresh` | `pass` | `The publication checks passed after the Vizier change and Jays-Patch/source-baseline.json was refreshed for 3,108 owned files.` |
| `Reviewed public-package builder` | `pass` | `The final staged package passed the full publication gate after every requested change and was built as Jay's Patch v1.9.0-beta.4.zip.` |
| `Built archive inspection` | `pass` | `73,284,401 bytes; SHA-256 94867f2ee2fe32c11ddda809b28442216815abd0ada7ab12122c0375791afe82; 2,644 entries; manifest version 1.9.0-beta.4; rainbow name, ten heartbeats, starpass text, six pitchfork-tine commands and all five descending Vizier cues verified inside the ZIP.` |
| `Source publication` | `pass` | `Commit cfe2cc7798cd4881b2ed11ea3e21d4f3cc264f45 was pushed to codex/jays-patch-1.9-beta-recovery.` |
| `Public Beta 4 replacement verification` | `pass` | `The existing v1.9.0-beta.4 release and tag target cfe2cc7798cd4881b2ed11ea3e21d4f3cc264f45. It has exactly one asset, Jay.s.Patch.v1.9.0-beta.4.zip, at 73,284,401 bytes with GitHub digest sha256:94867f2ee2fe32c11ddda809b28442216815abd0ada7ab12122c0375791afe82.` |
| `Independent public download verification` | `pass` | `A fresh download from the GitHub release matched 73,284,401 bytes and SHA-256 94867f2ee2fe32c11ddda809b28442216815abd0ada7ab12122c0375791afe82.` |

## Current blocker

`None.`

## Exact next step

`None; delivery and public verification are complete.`

## Final outcome

`Jay's Patch 1.9.0 Beta 4 was updated in place at https://github.com/JayLeet/Jays-Patch/releases/tag/v1.9.0-beta.4. No Beta 5 or second release asset was created.`
