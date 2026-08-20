# Publish Jay's Patch v1.9.0 Stable

- Status: `complete`
- Updated: `2026-08-21 00:28 CEST`
- Owner: Sol
- Workflow decision: `use Sol/Luna workflow`
- Workflow reason: `This task changes the default-branch model, stable version identity, generated public package, Git tag, GitHub release, and branch retention. A durable release and rollback record is worth the journal cost.`
- `/plan` state: `accepted`

## Outcome

`Promote the complete 1.9.0 Beta 4 recovery source to stable Jay's Patch v1.9.0, make that source tree main, publish and verify the stable package, and remove only branches proven redundant afterward.`

## Done when

- [ ] `The maintained source, public documentation, manifests, and package identify the release as 1.9.0 without claiming Sybillian's unfinished public Djinn sheet is Jay's beta limitation.`
- [ ] `The complete reviewed source tree becomes main through a history-preserving merge; no force push or unrelated local work is used.`
- [ ] `The v1.9.0 GitHub release and package are published and independently verified before redundant branches are removed.`

## Scope and boundaries

- In scope: `stable version metadata, maintained documentation, generated indexes and baselines, reviewed package build, source-history join, main PR/merge, v1.9.0 tag and GitHub release, and redundant remote/local branch audit`
- Non-goals: `implementing Sybillian's public Djinn sheet, changing gameplay, mutating or reloading the live server, deleting older stable releases, or publishing unrelated dirty-worktree files`
- Must preserve: `the current package-only main history, complete recovery-source history, existing tags and releases, live data, private files, and unrelated dirty work in the original checkout`
- Safety constraints: `work in an isolated worktree; build only through the reviewed package tool; use explicit staging; do not delete a branch until its tip is reachable from new main or a retained tag`

## Evidence

- `origin/codex/jays-patch-1.9-beta-recovery is 22541cbf and contains the complete maintained source, tests, builders, and the YAWP fix.`
- `origin/main is 07ff1439 and contains the generated public package; the two histories currently have no merge base.`
- `Jays-Patch/version.txt and public download links identify 1.9.0-beta.4; v1.9.0-beta.4 is the current GitHub prerelease and v1.8.0 is the current stable release.`
- `The maintained README and feature map call public Djinn-sheet presentation a beta limitation, while Jay decided that upstream feature belongs to Sybillian and should not block this stable release.`
- `The original checkout contains unrelated modified, deleted, and untracked files and will remain untouched.`

## Inference

- `A history-preserving merge that keeps the recovery source tree can make future main-based development conventional without losing the earlier package-only main commits.`

## Unknowns

- `None affecting implementation. Branch deletion remains conditional on the final reachability audit.`

## Recommendations

- `Publish stable v1.9.0 from the reviewed source tree, retain the Beta 4 release as a rollback point, and remove only branch refs made redundant by the new main.`

## Project-owner decisions

| Decision | Reason | Date |
|---|---|---|
| `Make the complete beta recovery source the new main and promote 1.9.0 to stable.` | `The beta is ready to become the official release and future work should continue from main.` | `2026-08-20` |
| `Remove Jay's documented public Djinn-sheet beta limitation without implementing that upstream feature.` | `Sybillian owns and is working on the Djinn-sheet presentation.` | `2026-08-20` |

## Accepted `/plan`

1. [x] `Update stable version metadata and remove the upstream Djinn limitation wording in maintained source.`
2. [x] `Refresh generated documentation and baselines, then run focused checks and the reviewed stable package build.`
3. [x] `Join the package and source histories, merge the complete source tree to main, publish and independently verify v1.9.0, then prune only proven-redundant branches.`

## Delivery tracking

- Decision: `use accepted-plan checklist`
- Reason: `The three ordered release slices are bounded and restartable; a separate goal would duplicate the accepted plan.`

### Active `/goal` (only when used)

`Not used; accepted plan is the delivery checklist.`

## Current progress

- `Created clean isolated branch codex/promote-1.9.0-stable from the current remote recovery tip.`
- `Audited remote branches, prior Beta 4 release records, current stable/prerelease state, version owners, and the unrelated-history boundary.`
- `Changed the maintained version and public download links to 1.9.0, removed current Djinn-sheet beta-limitation wording, and updated the Buffet design/feature status to stable.`
- `Refreshed the 75-file world-template manifest and prepared cumulative stable release notes.`
- `The complete source-baseline promotion gate passed and refreshed the known-good 1.9.0 baseline for 3,110 owned files.`
- `The reviewed builder produced the stable 73,285,230-byte package with SHA-256 afed592ce8c99777c0ac670d9e4871c59a9bacb08e27fa250f4a7c8122334747, 2,646 ZIP entries, and a 2,645-file version 1.9.0 manifest.`
- `The staging tree contains no 1.9.0 beta version or Djinn-sheet beta-limitation wording.`
- `Stable source commit c1f96e8 was created from the reviewed nine-file release scope.`
- `A history-preserving ours-strategy merge joined origin/main 07ff1439 as the second parent while retaining the exact stable source tree.`
- `PR #11 merged the exact stable source tree to main at 4d75780e without force-pushing or dropping either history.`
- `GitHub release v1.9.0 is public, marked stable, targets the exact main commit, and owns one independently downloaded package matching the reviewed local SHA-256 and byte size.`
- `The remote recovery and package-sync branches were deleted only after reachability checks proved both tips are ancestors of new main; origin now exposes only main.`
- `Local snapshot 64783da1 and legacy Sol/Luna commit 6996ad8b are not reachable from main and remain preserved. The original dirty recovery checkout and its local branch also remain untouched.`

## Active Luna assignments

| Assignment | Worker journal | Allowed area | State |
|---|---|---|---|
| `None` | `N/A` | `N/A` | `No delegation; the release is sequential and this task did not request subagents.` |

## Verification record

| Check | Result | Evidence |
|---|---|---|
| `git status --porcelain in isolated worktree` | `pass` | `Clean at recovery tip 22541cbf before release edits.` |
| `remote branch and history audit` | `pass` | `Remote has main, recovery, and one older package-sync branch; source and package histories have no current merge base.` |
| `tools/update-world-template-manifest.ps1` | `pass` | `Updated stable version metadata for 75 release-owned world files.` |
| `tools/tests/test-public-config-hygiene.ps1` | `pass` | `Stable public version links and configuration hygiene passed.` |
| `tools/tests/test-yawp-startup-compatibility.ps1` | `pass` | `The stable source retains the reviewed global YAWP lock contract.` |
| `git diff --check` | `pass` | `No whitespace errors after maintained release edits.` |
| `tools/update-source-baseline.ps1` | `pass` | `Every source suite passed and the stable baseline was promoted for 3,110 owned files.` |
| `tools/build-public-package.ps1` | `pass` | `The complete publication gate passed and built Jay's Patch v1.9.0.zip with the exact hosted resource-pack SHA-1.` |
| `stable archive inspection` | `pass` | `73,285,230 bytes; SHA-256 afed592ce8c99777c0ac670d9e4871c59a9bacb08e27fa250f4a7c8122334747; 2,646 ZIP entries; manifest version 1.9.0 with 2,645 files; zero forbidden current beta/Djinn references.` |
| `stable source commit scope` | `pass` | `c1f96e8 contains only the nine reviewed release-owned source and documentation files.` |
| `history join` | `pass` | `The merge has parents c1f96e8 and origin/main 07ff1439; its tree exactly matches the stable source tree before the merge.` |
| `PR #11 merge and tree verification` | `pass` | `Remote main is 4d75780e and its tree exactly matches the reviewed stable source branch.` |
| `GitHub v1.9.0 release verification` | `pass` | `Tag and main both point to 4d75780e; release is not a draft or prerelease; its single 73,285,230-byte asset independently downloads with SHA-256 afed592ce8c99777c0ac670d9e4871c59a9bacb08e27fa250f4a7c8122334747 and the same GitHub API digest.` |
| `remote branch reachability and cleanup` | `pass` | `Recovery 22541cbf and package-sync dd5e5408 were ancestors of main before deletion; origin now has only main.` |
| `local branch preservation audit` | `pass` | `Two local-only tips are not reachable from main and were retained; the dirty original checkout was not switched, reset, staged, or cleaned.` |

## Current blocker

`None.`

## Exact next step

`None. Release and branch promotion are complete.`

## Final outcome

`Jay's Patch v1.9.0 is the verified current stable release. Main now contains the complete maintained source and both former histories. Only redundant remote branches were removed; unique local history and unrelated dirty work remain preserved.`
