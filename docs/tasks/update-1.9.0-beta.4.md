# Update Jay's Patch v1.9.0 Beta 4 in place

- Status: `complete`
- Updated: `2026-08-04 21:10 CEST`
- Owner: Sol
- Workflow decision: `use Sol/Luna workflow`
- Workflow reason: `This task changes two player-facing fun features and replaces an existing public package asset and tag in place. A small release and rollback record is worth the documentation cost.`
- `/plan` state: `accepted`

## Outcome

`Keep the completed Beta 4 changes, correct the Vizier jingle and Hot Potato pitchfork, make release writing focus on what players care about, rewrite every public GitHub release description, and replace the existing Beta 4 package in place again.`

## Done when

- [x] Every visible letter in `Rainbow Paint Gun` follows the full seven-colour rainbow cycle.
- [x] Hot Potato stays silent for its first 20 seconds, then plays exactly one heartbeat per second from 10 seconds remaining through 1 second, rising from pitch 0.60 to 1.95 in 0.15 steps.
- [x] Hot Potato passes keep roughly the first three blocks as a single-flame handle before widening into a three-pronged head, and announce the sender and receiver as `<sender> starpassed to <receiver>!`.
- [x] The Vizier entrance uses the King's opening burst sounds and same level-up finale, with that final cue lowered from the King's pitch 0.70 to 0.50.
- [x] The corrected Beta 4 public package passes its publication gate and replaces the existing GitHub asset and tag target without creating Beta 5.
- [x] Jay's writing guide tells release writers to lead with the fun or useful player result and omit technical details that do not affect play.
- [x] All six public GitHub release descriptions explain their player-facing value in that style while keeping version-specific facts accurate.
- [x] A Modrinth-ready delta contains only the three corrected runtime functions under their `world/datapacks/jays_patch` paths plus short apply instructions.

## Scope and boundaries

- In scope: `Rainbow Paint Gun loot-table name, Hot Potato heartbeat timing and pitch, pass trail and announcement, Vizier entrance jingle, focused regression tests, generated metadata and source baseline, Modrinth hot-sync delta, Jay's canonical writing guide, all six public GitHub release descriptions, cumulative Beta 4 release notes, public package, source commits, existing Beta 4 tag and GitHub release asset`
- Non-goals: `new Paint Gun mechanics, changing the Hot Potato duration, resource-pack art or hosted-pack replacement, live-server deployment or reload, a Beta 5 release, or unrelated diagnostics`
- Must preserve: `all other fun-feature behavior, the existing public Beta 4 URL, stable releases, live data, BOTC-Live-Trace.ps1, tools/capture-botc-client-heap.ps1, and unrelated work`
- Safety constraints: `keep the old public asset and tag target until the replacement source and package are ready; replace only v1.9.0-beta.4; build only through the reviewed package tool; stage explicit intended paths`

## Evidence

- `The Rainbow Paint Gun loot table currently renders the complete name in one light-purple component.`
- `Hot Potato currently lasts 600 ticks and uses four pulse intervals in only the final ten seconds, with pitch bands 1.00, 1.20, 1.45 and 1.75.`
- `The current public release is v1.9.0-beta.4, targets commit 04951bd0, and owns one 73,283,934-byte package asset with SHA-256 6ea6f340aafd098f24f95761376fd976e566b7b288377ae58a52c0e8910b638f.`
- `The only unrelated worktree files are the two known untracked diagnostic scripts.`
- `The published Vizier burst still contains the old didgeridoo at pitch 0.42 and Warden heartbeat at pitch 0.60, which proves the first heard sounds were not changed with the timed jingle.`
- `The published final timed cue is entity.player.levelup at pitch 0.70. Its source sound remains perceptually bright even though 0.70 is the smallest number in that timed sequence.`
- `The published pitchfork starts widening at range scores 15..16, about one block into its roughly five-block trail, so most of the beam is currently the fork head rather than the handle.`

## Inference

- `A pitch sequence from 0.60 to 1.95 in 0.15 steps gives the final ten seconds a distinct ascending heartbeat while remaining inside Minecraft's normal 0.5-2.0 audible pitch range.`
- `Keeping the King's level-up finale at Minecraft's minimum pitch 0.50 preserves the matching jingle while making the final cue as low as that sound can play.`

## Unknowns

- `In-game musical preference remains subjective; code and tests can prove timing and monotonic pitch, while final listening remains manual.`

## Recommendations

- `Use seven Minecraft text colours in a continuous letter-by-letter cycle and a dedicated Hot Potato heartbeat function so the timing table stays easy to audit.`
- `Copy the King's two opening playsounds into the Vizier burst, keep its level-up finale at pitch 0.50, and delay the pitchfork's side tines until the last two blocks.`

## Project-owner decisions

| Decision | Reason | Date |
|---|---|---|
| `Implement all three requested changes immediately and publish them.` | `Requested by Jay.` | `2026-08-04` |
| `Update Beta 4 in place instead of creating Beta 5.` | `Jay explicitly wants the existing public beta replaced as though it had always contained the corrections.` | `2026-08-04` |
| `Use Jay's writing guide for the public GitHub description.` | `Requested by Jay.` | `2026-08-04` |
| `Start the Hot Potato heartbeat only at 10 seconds remaining.` | `Jay corrected the earlier all-round timing before implementation.` | `2026-08-04` |
| `Use a flaming pitchfork pass trail and the literal message <sender> starpassed to <receiver>!.` | `Jay clarified that starpassed is the verb, not a star separator.` | `2026-08-04` |
| `Give the Vizier the King's jingle with descending pitch.` | `Requested by Jay before the public replacement was published.` | `2026-08-04` |
| `Replace the remaining old Vizier opening sounds and make the last note audibly lowest.` | `Jay's in-game test found the opening and finale still sounded wrong.` | `2026-08-04` |
| `Lengthen the Hot Potato pitchfork handle.` | `Jay's in-game test showed the fork head begins too early to read as a pitchfork.` | `2026-08-04` |
| `Make release notes focus on what players care about instead of how features work.` | `Jay explicitly wants the fun or useful result to lead, using Paint Guns as the example.` | `2026-08-04` |
| `Apply the player-value rule to every existing GitHub release description.` | `Requested by Jay.` | `2026-08-04` |
| `Create a small Modrinth delta for the current code correction.` | `Jay wants to apply the three runtime files quickly without uploading the full package.` | `2026-08-04` |
| `Keep the Vizier's King-style level-up finale and only lower its pitch.` | `Jay clarified that changing the final sound itself was not intended.` | `2026-08-04` |

## Accepted `/plan`

1. [x] Replace the remaining old Vizier opening sounds, keep the King-style finale at pitch 0.50, lengthen the pitchfork handle and update focused checks.
2. [x] Rewrite the canonical writing rule, Beta 4 notes and all six GitHub release descriptions around player value.
3. [x] Refresh the source baseline, then rebuild and inspect Beta 4 through the reviewed publication gate.
4. [x] Commit and push the correction, replace the existing Beta 4 asset and tag target, update every release description, verify the public result, and record release evidence.

## Delivery tracking

- Decision: `use accepted-plan checklist`
- Reason: `The three-step in-place update is bounded and restartable; a separate goal would duplicate it.`

### Active `/goal` (only when used)

`Not used; the accepted plan is the delivery checklist.`

## Current progress

- `The previous Beta 4 replacement is published, but Jay's in-game test exposed two remaining Vizier audio problems and a pitchfork proportion problem. The correction is now reopened before another in-place replacement.`
- `The bounded Vizier audio and pitchfork proportion corrections are implemented and pass the focused fun-toybox check.`
- `The canonical writing guide and Beta 4 source notes now lead with the experience players care about. All six existing GitHub descriptions and tagged feature boundaries have been inspected for the external rewrite.`
- `Player-first replacement descriptions are prepared for v1.5.4, v1.6.0, v1.6.1, v1.7.0, v1.8.0 and v1.9.0-beta.4.`
- `Jays-Patch/dist/modrinth-delta-beta4-jingle-pitchfork contains the Vizier burst, Vizier timed jingle and Hot Potato raycast at their server-relative paths, plus HOW TO APPLY.txt.`
- `Jay clarified that the Vizier finale must keep the King's entity.player.levelup sound. The source, focused guard and Modrinth delta now use that sound at pitch 0.50 and explicitly reject the temporary bell substitution.`

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
| `Post-release in-game review` | `fail` | `Jay heard the old Vizier opening, found the level-up finale too bright, and found the Hot Potato pitchfork handle too short.` |
| `Focused correction check` | `pass` | `tools/tests/test-fun-toybox.ps1 and git diff --check passed with the corrected opening burst, King-style entity.player.levelup finale at pitch 0.50, an explicit no-bell guard and delayed pitchfork tines.` |
| `Player-first release-note review` | `pass` | `All six proposed descriptions were checked for their tagged feature boundaries and for removal of implementation-focused language such as light sampling, display storage, cleanup state, validation and hashes.` |
| `Modrinth delta parity` | `pass` | `The three copied runtime functions match their source SHA-256 hashes exactly; the folder contains only those functions and HOW TO APPLY.txt.` |
| `Corrected public-package gate` | `pass` | `The full publication gate passed against the refreshed 3,108-file source baseline and built Jay's Patch v1.9.0-beta.4.zip.` |
| `Corrected archive inspection` | `superseded` | `The 73,284,390-byte archive with SHA-256 7cc3dc5e359ba157d808c7a8423994d5f11e8a4c4f7d6cf3c5c3ba8e2444c590 used a bell finale. Jay clarified that the King-style level-up sound must remain, so this asset will be replaced again.` |
| `Final corrected public-package gate` | `pass` | `The full source and publication gates passed against the refreshed 3,108-file baseline and rebuilt Jay's Patch v1.9.0-beta.4.zip.` |
| `Final corrected archive inspection` | `pass` | `The 73,284,403-byte archive has SHA-256 5d72eec60ca4be0c80132e5a05f1973443f594fc576e244bfc855b8d1b5de210 and 2,644 entries. Direct inspection proved the King opening sounds, entity.player.levelup finale at pitch 0.50, absence of the substituted bell and old Vizier opening, and the lengthened pitchfork handle bands.` |
| `Final correction source publication` | `pass` | `Commit 89774dc44d69c5b1f643aa2766f9c0f4478d5c45 was pushed to codex/jays-patch-1.9-beta-recovery.` |
| `Final public Beta 4 replacement` | `pass` | `The existing v1.9.0-beta.4 release and tag now target 89774dc44d69c5b1f643aa2766f9c0f4478d5c45. The release remains a prerelease with exactly one asset named Jay.s.Patch.v1.9.0-beta.4.zip at 73,284,403 bytes and GitHub digest sha256:5d72eec60ca4be0c80132e5a05f1973443f594fc576e244bfc855b8d1b5de210.` |
| `Final independent public download` | `pass` | `A fresh GitHub download matched 73,284,403 bytes and SHA-256 5d72eec60ca4be0c80132e5a05f1973443f594fc576e244bfc855b8d1b5de210. Its archived Vizier tick uses entity.player.levelup at pitch 0.50 and contains no timer-10 bell substitution.` |
| `Final Modrinth delta parity` | `pass` | `The refreshed Vizier tick in the four-file delta matches source SHA-256 4a32c1c02d9e89fdb4d24456f57ea65710553522efb148870d9fb8d52e619840.` |

## Current blocker

`None.`

## Exact next step

`None; delivery and verification are complete.`

## Final outcome

`Beta 4 was corrected in place without creating Beta 5. The Vizier now keeps the King's level-up finale at pitch 0.50, the longer-handled Hot Potato pitchfork and player-first release descriptions remain published, and the refreshed Modrinth delta is ready to copy.`
