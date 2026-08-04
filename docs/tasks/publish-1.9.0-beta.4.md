# Publish Jay's Patch v1.9.0 Beta 4

- Status: `implementing`
- Updated: `2026-08-04 18:33 CEST`
- Owner: Sol
- Workflow decision: `use Sol/Luna workflow`
- Workflow reason: `This task publishes a versioned public package, Git commit, tag, and GitHub release. A small release and rollback record is worth the documentation cost.`
- `/plan` state: `accepted`

## Outcome

`Publish the completed Greedy ability-text, dialog-tooltip, Wraith text, Paint Gun, resource-pack, and release-process changes as Jay's Patch v1.9.0 Beta 4.`

## Done when

- [ ] The intended release source and Beta 4 metadata are committed and pushed without the unrelated diagnostic scripts.
- [ ] The reviewed package builder and complete non-live publication gate pass.
- [ ] The Beta 4 prerelease and its package are publicly available and independently verified.

## Scope and boundaries

- In scope: `the current completed Jay-owned game changes, generated outputs, documentation, focused tests, source baseline, Beta 4 metadata, public package, commit, push, tag, and GitHub prerelease`
- Non-goals: `the deferred rave-cat idea, new gameplay work, live-server deployment or reload, deleting stable releases, or publishing unrelated diagnostics`
- Must preserve: `live data, backups, stable releases, Beta 3 until Beta 4 is independently verified, BOTC-Live-Trace.ps1, tools/capture-botc-client-heap.ps1, and unrelated work`
- Safety constraints: `build only through the reviewed package tool; stage explicit intended paths; do not publish private server state or diagnostic scripts`

## Evidence

- `The current branch is codex/jays-patch-1.9-beta-recovery and matches its remote before this release work.`
- `GitHub CLI 2.96.0 is authenticated as JayLeet with repository access.`
- `v1.9.0-beta.3 is the current prerelease and Jays-Patch/version.txt contains 1.9.0-beta.3.`
- `The worktree contains the completed feature source plus two untracked diagnostic scripts that the prior release record explicitly excluded.`
- `The reviewed builder runs the full non-live source gate, bundles the exact configured hosted resource pack, produces a reproducible archive, and validates the result.`

## Inference

- `The next distinct prerelease should be v1.9.0-beta.4 so the existing Beta 3 remains an unambiguous rollback point.`

## Unknowns

- `None affecting the planned delivery. The GitHub PR path is expected to remain unavailable because this recovery branch and main have unrelated history; the release can still be published from the pushed branch commit.`

## Recommendations

- `Publish and verify Beta 4 while preserving Beta 3 and every stable release.`

## Project-owner decisions

| Decision | Reason | Date |
|---|---|---|
| `Update and build the public package, then publish it to GitHub.` | `The current completed work has passed manual live review and is ready for a public beta update.` | `2026-08-04` |
| `Do not implement the rave-cat idea in this release.` | `Jay deferred it to conserve usage.` | `2026-08-04` |
| `Remove Beta 3 after Beta 4 is verified.` | `Jay explicitly approved removing the superseded prerelease.` | `2026-08-04` |
| `Use a cumulative Beta 4 release description.` | `The public beta description must retain every feature from the first 1.9 beta and add every later feature and fix through Beta 4.` | `2026-08-04` |

## Accepted `/plan`

1. [x] Audit the complete release diff, update Beta 4 version-owned metadata, and preserve unrelated diagnostics.
2. [x] Run the reviewed public-package builder once, inspect the archive, and record the complete publication gate.
3. [ ] Stage only intended release files, commit, push, publish and independently verify Beta 4, then remove only Beta 3.

## Delivery tracking

- Decision: `use accepted-plan checklist`
- Reason: `The three-step release checklist is bounded and restartable; a separate goal would duplicate it.`

### Active `/goal` (only when used)

`Not used; the accepted plan is the delivery checklist.`

## Current progress

- `Release authority, GitHub authentication, next-version recommendation, and diagnostic-script exclusions are established.`
- `Beta 4 now owns version.txt, the world-template manifest, both public download links, and short public descriptions for the Greedy ability text and Paint Gun commands.`
- `The first baseline-promotion gate passed every suite through generated tool items, then stopped because function-index.md was stale. The index was refreshed through tools/update-code-library.ps1; the baseline was not promoted by the failed run.`
- `The rerun passed every non-live source suite and refreshed the Beta 4 baseline for 3,107 owned files without the unrelated heap-capture diagnostic.`
- `The existing Beta 3 GitHub body contains only its incremental UI cleanup, so Beta 4 needs a cumulative description derived from the current public feature list and the 1.9 beta history.`
- `The reviewed builder produced a 2,643-entry Beta 4 ZIP with a 2,642-file manifest, 73,283,934-byte size, and SHA-256 6ea6f340aafd098f24f95761376fd976e566b7b288377ae58a52c0e8910b638f.`
- `The cumulative GitHub description is recorded in docs/tasks/publish-1.9.0-beta.4-release-notes.md.`
- `The staging audit found that the new Greedy language generator inherited Windows CRLF from ConvertTo-Json. The generator now normalizes that output to LF, its focused generation/check and Buffet suite pass, and the final baseline/package gates pass after the source change.`
- `The final staging audit contains 155 intended files, no whitespace errors, and neither unrelated diagnostic script.`

## Active Luna assignments

| Assignment | Worker journal | Allowed area | State |
|---|---|---|---|
| `None` | `N/A` | `N/A` | `No delegation; release authority remains with Sol.` |

## Verification record

| Check | Result | Evidence |
|---|---|---|
| `gh --version` | `pass` | `GitHub CLI 2.96.0.` |
| `gh auth status` | `pass` | `Authenticated as JayLeet.` |
| `git status -sb` and diff audit | `pass` | `The intended release source is identified; BOTC-Live-Trace.ps1 and tools/capture-botc-client-heap.ps1 remain excluded.` |
| `git diff --check` | `pass` | `No whitespace errors.` |
| `First tools/update-source-baseline.ps1 prerequisite gate` | `fail` | `All preceding suites passed; stale docs/code-library/generated/function-index.md stopped the run before baseline promotion.` |
| `tools/update-code-library.ps1` | `pass` | `Generated code-library indexes refreshed.` |
| `Second tools/update-source-baseline.ps1 prerequisite gate` | `pass` | `Every non-live source suite passed; baseline promoted for 3,107 owned files.` |
| `tools/build-public-package.ps1` | `pass` | `Complete post-baseline source gate and package validation passed; bundled hosted resource-pack SHA-1 4c20eb69b74e8138d55d1ddeb29dc79722335d8d.` |
| `Local package inspection` | `pass` | `Manifest version 1.9.0-beta.4; 2,643 ZIP entries; 73,283,934 bytes; SHA-256 6ea6f340aafd098f24f95761376fd976e566b7b288377ae58a52c0e8910b638f.` |
| `Greedy language LF normalization` | `pass` | `Generated file contains zero CRLF sequences; generator -Check and focused Buffet tests pass.` |
| `Final post-normalization baseline and package gates` | `pass` | `Baseline matches 3,107 owned files; complete source gate, world manifest, hosted-pack and package parity checks pass.` |
| `Final staged-scope audit` | `pass` | `155 intended files; zero excluded diagnostic scripts; git diff --cached --check passes.` |
| `Public asset verification` | `not run` | `Pending publication.` |

## Current blocker

`None.`

## Exact next step

`Commit the intended Beta 4 source and push the recovery branch.`

## Final outcome

`Pending.`
