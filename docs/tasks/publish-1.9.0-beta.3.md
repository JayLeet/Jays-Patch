# Publish Jay's Patch v1.9.0 Beta 3

- Status: `complete`
- Updated: `2026-08-04 10:21 CEST`
- Owner: Sol
- Workflow decision: `use Sol/Luna workflow`
- Workflow reason: `This task changes a public package, Git tag, and GitHub release, then removes the superseded prerelease. A durable release and rollback record is worth the small documentation cost.`
- `/plan` state: `accepted`

## Outcome

`Publish the approved formatting cleanup as Jay's Patch v1.9.0 Beta 3, verify the public package, then remove only Beta 2.`

## Done when

- [x] The intended formatting cleanup and Beta 3 version files are committed and pushed without the unrelated diagnostic scripts.
- [x] The reviewed package builder and complete non-live source gate pass.
- [x] The Beta 3 prerelease and package are publicly available and independently verified.
- [x] Beta 2 is removed only after Beta 3 verification; stable releases remain untouched.

## Scope and boundaries

- In scope: `approved formatting cleanup, generated outputs, regression checks, source baseline, Beta 3 version metadata, public package, commit, push, GitHub prerelease, and Beta 2 cleanup`
- Non-goals: `gameplay changes, live-server deployment or reload, stable-release changes, or publishing unrelated diagnostics`
- Must preserve: `live data, backups, stable releases, BOTC-Live-Trace.ps1, tools/capture-botc-client-heap.ps1, and all unrelated work`
- Safety constraints: `build only through the reviewed package tool; verify Beta 3 before deleting Beta 2; stage explicit intended paths only`

## Evidence

- `The current branch is codex/jays-patch-1.9-beta-recovery and is synchronized with its remote before this release commit.`
- `GitHub CLI 2.96.0 is authenticated as JayLeet with repository access.`
- `v1.9.0-beta.2 is the only current prerelease and targets commit 4b7140088e2b7306018c804e7de754d4c16c8e08.`
- `The formatting cleanup passed focused checks and the complete non-live source gate before release versioning.`
- `BOTC-Live-Trace.ps1 and tools/capture-botc-client-heap.ps1 appeared as unrelated untracked diagnostics and are excluded from release scope.`

## Inference

- `A distinct Beta 3 version is safer than replacing Beta 2 in place because downloads retain an unambiguous version and rollback boundary.`

## Unknowns

- `None affecting delivery.`

## Recommendations

- `Publish and verify Beta 3 first, then delete only the Beta 2 release and tag.`

## Project-owner decisions

| Decision | Reason | Date |
|---|---|---|
| `Publish Beta 3 and remove Beta 2.` | `Keep the small public update versioned and supersede the older prerelease.` | `2026-08-04` |
| `Leave the three audited color choices unchanged.` | `Jay confirmed those colors are intentional and not a concern.` | `2026-08-04` |

## Accepted `/plan`

1. [x] Update version-owned public metadata to Beta 3 and audit the exact release scope.
2. [x] Refresh the source baseline, build and inspect the public package, and run the complete non-live gate.
3. [x] Stage only the intended files, commit, and push the recovery branch.
4. [x] Publish and verify Beta 3, then remove only Beta 2 and record final evidence.

## Delivery tracking

- Decision: `use accepted-plan checklist`
- Reason: `The four-step release checklist and journal provide a clear rollback boundary; a separate goal would duplicate them.`

### Active `/goal` (only when used)

`Not used; the accepted plan is the delivery checklist.`

## Current progress

- `Release authority, version choice, GitHub authentication, existing prerelease, and unrelated-file exclusions are confirmed.`
- `Beta 3 metadata now owns version.txt, the world-template manifest, and both public README download links.`
- `The source baseline was refreshed for 3,024 intended files while the unrelated heap-capture script was held outside the scan and restored unchanged.`
- `The reviewed builder produced a 2,588-entry Beta 3 package with SHA-256 1b025208deefc00c733c962a711d4e9e78f606a6e6ac846da030eecc8b6faf24.`
- `Release commit 620b3cebed23ad6d6ea475589a557894c13d98a4 was pushed to the recovery branch and became the Beta 3 tag target.`
- `The public Beta 3 asset was downloaded into a temporary directory and matched the expected 73,228,393-byte size and SHA-256.`
- `Beta 2 was removed only after Beta 3 verification; stable releases v1.8.0 through v1.5.4 remain published.`

## Active Luna assignments

| Assignment | Worker journal | Allowed area | State |
|---|---|---|---|
| `None` | `N/A` | `N/A` | `No delegation; public release authority remains with Sol.` |

## Verification record

| Check | Result | Evidence |
|---|---|---|
| `gh --version` | `pass` | `GitHub CLI 2.96.0.` |
| `gh auth status` | `pass` | `Authenticated as JayLeet.` |
| `gh release view v1.9.0-beta.2` | `pass` | `Beta 2 is a public prerelease with one verified package asset.` |
| `Pre-baseline tools/tests/test-source-safety.ps1` | `pass` | `Every non-live suite passed with baseline and historical-package checks intentionally skipped.` |
| `tools/update-source-baseline.ps1` | `pass` | `Mandatory source-gate rerun passed; baseline refreshed for 3,024 intended files.` |
| `tools/build-public-package.ps1` | `pass` | `Built Beta 3 with 2,588 entries and the exact hosted resource pack SHA-1 923113b3d4ef3dd6487d038c1e956e2b06b9397b.` |
| `Package inspection` | `pass` | `73,228,393 bytes; manifest 1.9.0-beta.3; SHA-256 1b025208deefc00c733c962a711d4e9e78f606a6e6ac846da030eecc8b6faf24.` |
| `Final tools/tests/test-source-safety.ps1` | `pass` | `Baseline and public-package parity checks both passed with every non-live suite.` |
| `Release commit and branch push` | `pass` | `620b3cebed23ad6d6ea475589a557894c13d98a4 was pushed to codex/jays-patch-1.9-beta-recovery.` |
| `GitHub Beta 3 metadata and tag` | `pass` | `Public prerelease v1.9.0-beta.3 targets the exact release commit.` |
| `GitHub asset download` | `pass` | `Downloaded asset matched 73,228,393 bytes and SHA-256 1b025208deefc00c733c962a711d4e9e78f606a6e6ac846da030eecc8b6faf24.` |
| `Beta 2 cleanup` | `pass` | `The v1.9.0-beta.2 release and remote tag are absent; all stable releases remain.` |
| `Draft pull request` | `unavailable` | `The recovery branch and main still have no common Git history; no risky history rewrite was attempted.` |

## Current blocker

`None affecting the requested release. A normal pull request remains unavailable because the recovery branch and main have no common Git history.`

## Exact next step

`None. Beta 3 is published and verified, and Beta 2 is removed.`

## Final outcome

`Jay's Patch v1.9.0 Beta 3 is publicly available and verified. Beta 2 was removed after replacement verification, stable releases were preserved, unrelated diagnostics remained untracked, and the live server was not mutated.`
