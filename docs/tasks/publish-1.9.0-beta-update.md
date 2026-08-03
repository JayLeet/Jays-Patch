# Publish Jay's Patch 1.9.0 beta update

- Status: `complete`
- Updated: `2026-08-03 23:52 CEST`
- Owner: Sol
- Workflow decision: `use Sol/Luna workflow`
- Workflow reason: `The task creates a public package and GitHub release, commits a large dirty worktree, and removes a superseded public beta. A durable release record and rollback boundary are worth the cost.`
- `/plan` state: `accepted`

## Outcome

Publish the reviewed 1.9.0 beta work as a new verified public package and GitHub prerelease, then remove only the beta it supersedes.

## Done when

- [x] The intended 1.9.0 beta source scope is explicit and unrelated files remain untouched.
- [x] The source gate, baseline refresh, public package build, and finished-archive validation pass.
- [x] The release commit and current branch are pushed to `JayLeet/Jays-Patch`.
- [x] The new GitHub prerelease and package asset are publicly available and verified.
- [x] Only the superseded `v1.9.0-beta.1` release/tag is removed after the replacement is proven available.

## Scope and boundaries

- In scope: reviewed 1.9.0 beta source, generated outputs, documentation, tests, public package, Git commit/push, GitHub prerelease replacement.
- Non-goals: publishing a stable 1.9.0 release, changing Sybillian-owned behavior, deploying new live-server changes, or publishing unrelated local/private data.
- Must preserve: live world/data, backups, historical stable releases, unrelated work, private settings, and the `codex/jays-patch-1.9-beta-recovery` branch.
- Safety constraints: use the reviewed package builder; do not delete Beta 1 until the new prerelease is verified; never stage `data/`, backups, private files, or disposable package output unless the repository intentionally tracks it.

## Evidence

- Current branch is `codex/jays-patch-1.9-beta-recovery`, one commit ahead of its remote before this release work.
- GitHub repository is `JayLeet/Jays-Patch`; default branch is `main`.
- GitHub CLI 2.96.0 is installed and authenticated as `JayLeet` with repository access.
- GitHub currently has one prerelease: `Jay's Patch v1.9.0 Beta 1`, tag `v1.9.0-beta.1`.
- `Jays-Patch/README.md` requires `tools/update-source-baseline.ps1` after prerequisite checks and `tools/build-public-package.ps1` for public output.

## Inference

- None affecting the release route. The requested superseding beta is versioned separately so its package, tag, links, and rollback boundary remain unambiguous.

## Unknowns

- None affecting implementation. Release notes will summarize player-visible changes and omit engineering-only validation detail.

## Recommendations

- Publish a distinct `v1.9.0-beta.2` prerelease, verify its asset and metadata, then delete release and tag `v1.9.0-beta.1`.
- Stage only files proven to belong to the accepted 1.9.0 beta work.

## Project-owner decisions

| Decision | Reason | Date |
|---|---|---|
| Update the public package and publish the updated beta to GitHub. | The reviewed beta is visually approved and ready for public testing. | 2026-08-03 |
| Remove the older GitHub beta after replacement. | The updated beta supersedes it. | 2026-08-03 |
| Stay on `codex/jays-patch-1.9-beta-recovery`. | Standing branch requirement for this work. | 2026-08-03 |
| Publish the replacement as `v1.9.0-beta.2`. | A distinct beta version preserves clear package links, release history, and rollback until Beta 1 is deliberately removed. | 2026-08-03 |

## Accepted `/plan`

1. [x] Inspect the complete release diff, existing prerelease/tag/PR, version metadata, packaging rules, and untracked-file scope.
2. [x] Resolve the replacement version and release notes from repository evidence; stop only if a material choice remains.
3. [x] Run the complete non-live source gate, refresh the source baseline, build the public package, and validate its contents and hash.
4. [x] Review and stage only the release scope, commit it tersely, and push the current branch.
5. [x] Publish and verify the new GitHub prerelease and asset, then remove only the superseded Beta 1 release/tag.
6. [x] Record final Git/GitHub/package evidence and any remaining manual work.

## Delivery tracking

- Decision: `use accepted-plan checklist`
- Reason: `The bounded release plan and journal already make the destructive ordering and exact next step restartable; a separate goal would duplicate that state.`

### Active `/goal` (only when used)

`Not used; accepted plan is the delivery checklist.`

## Current progress

- Release workflow, GitHub authentication, repository identity, current branch, and existing prerelease were confirmed.
- The complete dirty scope contains project source, generated outputs, tests, current documentation, and 1.9 beta task records only; ignored live data, backups, private settings, and disposable package output remain outside Git.
- `Jays-Patch/version.txt`, the public README links, and the world-template manifest now identify `1.9.0-beta.2`.
- The pre-baseline complete non-live source gate passed all suites.
- The baseline updater reran the full non-live gate and refreshed 3,024 owned-file hashes for Beta 2.
- The reviewed builder produced `Jays-Patch/dist/Jay's Patch v1.9.0-beta.2.zip` with 2,588 archive entries and SHA-256 `4b8c4780d5abce42554e91b0b5a982ebd390f7d0bffd443c052d33a553104ed6`.
- The old local Beta 1 package was preserved under `backups/release-tests` before the disposable `dist` output was replaced.
- The final baseline-and-package-enabled source gate passed every suite.
- Release commit `4b7140088e2b7306018c804e7de754d4c16c8e08` was pushed to `codex/jays-patch-1.9-beta-recovery`.
- GitHub prerelease `v1.9.0-beta.2` was published at `https://github.com/JayLeet/Jays-Patch/releases/tag/v1.9.0-beta.2`.
- GitHub reports the package asset as uploaded with SHA-256 `4b8c4780d5abce42554e91b0b5a982ebd390f7d0bffd443c052d33a553104ed6`; a clean download matched that hash and the expected 73,227,501-byte size.
- The superseded `v1.9.0-beta.1` release and tag were removed only after Beta 2 passed public metadata, tag-target, size, and downloaded-hash verification.
- Stable releases `v1.8.0`, `v1.7.0`, `v1.6.1`, `v1.6.0`, and `v1.5.4` remain published.
- GitHub could not create a draft pull request because this recovery branch and `main` have no common Git history. Rewriting the published release branch solely to create a PR was rejected as unnecessary risk.

## Active Luna assignments

| Assignment | Worker journal | Allowed area | State |
|---|---|---|---|
| None | N/A | N/A | No delegation; release authority remains with Sol. |

## Verification record

| Check | Result | Evidence |
|---|---|---|
| `gh --version` | pass | GitHub CLI 2.96.0. |
| `gh auth status` | pass | Authenticated as `JayLeet`. |
| `gh repo view --json nameWithOwner,defaultBranchRef,url` | pass | `JayLeet/Jays-Patch`, default branch `main`. |
| `gh release list --limit 20` | pass | Beta 1 is the only current prerelease. |
| `gh pr list --head codex/jays-patch-1.9-beta-recovery --state all` | pass | No existing pull request uses this branch. |
| Dirty-scope audit | pass | Tracked/untracked changes stay under project instructions, docs, Jay-owned source/generated output, and tools; no `data/`, backups, private settings, or `dist` output is tracked. |
| Pre-baseline source gate with baseline/package checks skipped | pass | Every non-live suite passed, including generators, Draft model, Buffet, Grimoire, Wraith, Boomdandy, command budget, world manifest, config hygiene, and ownership. |
| `tools/update-source-baseline.ps1` | pass | Safety gate reran and baseline now covers 3,024 owned Beta 2 files. |
| `tools/build-public-package.ps1` | pass | Built Beta 2 with the exact hosted resource-pack SHA-1 `923113b3d4ef3dd6487d038c1e956e2b06b9397b`; archive validation passed. |
| Package inspection | pass | 73,227,501 bytes; 2,588 archive entries; manifest version `1.9.0-beta.2`; SHA-256 `4b8c4780d5abce42554e91b0b5a982ebd390f7d0bffd443c052d33a553104ed6`. |
| Final `tools/tests/test-source-safety.ps1` | pass | Baseline and public-package parity checks both enabled; every non-live suite passed. |
| `git diff --check` | pass | No whitespace errors before staging. |
| Release commit and branch push | pass | Commit `4b7140088e2b7306018c804e7de754d4c16c8e08` matches the remote recovery branch and the Beta 2 tag target. |
| GitHub Beta 2 metadata | pass | Public prerelease title, tag, exact target commit, asset name, and 73,227,501-byte size match the release plan. |
| GitHub asset download | pass | Downloaded asset SHA-256 matched `4b8c4780d5abce42554e91b0b5a982ebd390f7d0bffd443c052d33a553104ed6`. |
| Beta 1 cleanup | pass | Both the `v1.9.0-beta.1` release and remote tag are absent; stable releases remain. |
| Draft pull request | unavailable | GitHub rejected creation because the recovery branch has no common history with `main`; no history rewrite was attempted. |

## Current blocker

`None affecting the requested package and release. A normal pull request cannot be opened from this recovery branch because it has no common history with main.`

## Exact next step

`None. The requested public Beta 2 package and GitHub release replacement are complete.`

## Final outcome

`Jay's Patch v1.9.0 Beta 2 is published and verified. Beta 1 was removed after replacement verification, stable releases were preserved, and the live server was not mutated by this release workflow.`
