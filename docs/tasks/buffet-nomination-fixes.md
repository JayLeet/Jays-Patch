# Buffet And Nomination Fixes

- **Status:** Complete; corrected source, generated outputs, package, deployment, runtime parity, and clean reload are verified. Manual in-game interaction was not run.
- **Updated:** 2026-08-02 16:19:37 +02:00
- **Owner:** Sol
- **Outcome:** Fix the five reported Buffet and nomination issues without replacing Sybillian-owned behavior or weakening role and phase guards.
- **/Plan:** Accepted by Jay; implement the four bounded fix areas, keep Draft offer randomness deferred, then review, verify, deploy, and run live checks when available.
- **/Goal:** Finish the accepted BOTC Buffet, Hot Potato, and seat-guide fixes, prove the source and generated outputs pass the required gates, and verify the deployed server when available without changing Draft offer randomness.

> **Historical scope note (2026-08-03):** This completed task intentionally
> deferred Draft offer randomization. The later accepted
> [`draft-randomization-review.md`](draft-randomization-review.md) supersedes its
> weighted-type observations and resolved every Draft probability unknown below.

## Definition Of Done

- Draft Buffet character-offer randomness has a separate evidence-first plan; no offer behavior changes are included in this implementation pass without Jay accepting that plan.
- Greedy Whale tells the affected player exactly which unmet requirement is blocking a review and what must happen next.
- Hot Potato behavior around Townsquare is traced; a proven defect is fixed, or the intended limitation is documented without guessing.
- Nomination particles are visible during the intended nomination window.
- Buffet player houses show the correct player head and name.
- Source checks pass, deployment/reload needs are stated, and any unavailable live checks are recorded exactly.

## Scope And Boundaries

- **In scope for this implementation pass:** Jay-owned Greedy blocker explanations, Hot Potato throw behavior, day/nominations seat-guide particles, Buffet house player displays, and focused generators/tests/docs that own those behaviors.
- **Deferred pending its own accepted plan:** Draft Buffet character-offer randomness.
- **Non-goals:** Editing Sybillian `ct:` source, unrelated game systems, broad refactors, changing Storyteller permissions, or mutating the live world during investigation.
- **Safety:** Preserve player, spectator, Storyteller, operator, offline/rejoin, reset, and phase behavior outside the requested paths. Use source-first and read-only evidence before any live action.

## Evidence

- Jay reported five player-facing problems: non-random Draft, unclear Greedy Whale review blocking, possibly faulty Hot Potato Townsquare behavior, missing nomination particles, and wrong Buffet house head/name displays.
- The root instructions route these changes through the Jay's Patch and game-feature shelves and require the Sol/Luna workflow for meaningful behavior changes.
- The working tree was clean at investigation start (`git status --short --branch` returned only `## main`).
- Current `main` has no tracked Buffet source. The runtime contains 841 Buffet files, and `tools/tests/live/test-runtime-sync.ps1` fails because it sees those files as stale runtime extras.
- The complete Buffet source, generators, focused tests, and related fun-tool code exist on `codex/jays-patch-1.9-beta-recovery` at `0641e30d`.
- `main` and the recovery branch diverged after `d3b0c1d5`: local `main` has one workflow commit, while the recovery branch has thirteen feature/recovery commits. Neither branch is an ancestor of the other.
- Historical evidence at the time said Draft randomized seating and drafter order while weighting offers by still-needed categories. The later randomization review replaced that offer algorithm with equal odds among legal nonempty types and proved the live RNG defect described below.
- Greedy status `3` means the assigned role is no longer one of the player's submitted choices and no explicit override has been confirmed. The start report only says the assignment "needs review," and the dashboard does not visually distinguish this state from a valid submitted player.
- Hot Potato's raycast deliberately makes every Storyteller block the trace while never being a valid recipient. The start command can still make its Storyteller caller the holder, so Storyteller use is permitted by one part of the feature but treated specially by the pass logic.
- Sybillian's nomination start/vote loop contains no continuous nomination particle effect. The only nomination-adjacent particle found is a one-shot `soul_fire_flame` when a dead player's ghost vote is consumed.
- The stopped world's saved five-player Buffet roster is `Test2`, `Test1`, `test3`, `Jayify420`, and `test4` in seats 1-5. All five visible `house_head` profiles and all five visible `home_label` texts match those names and seats exactly. The reported house-identity fault is therefore not reproduced in the current saved state.
- The source refreshes house identity after initial assignment, Greedy late claims, Greedy seat emptying, and Greedy seat compaction. Those transitions still depend on resolved sign components plus Sybillian's live `id` selector labels, so the transition that produced Jay's observation matters.
- Docker Desktop is not running, so no live server/RCON state exists to inspect. The world, scoreboard, storage, and entity evidence above was read directly from the stopped save without mutation.
- A concrete stale-house transition is proven in both modes. Greedy `review/empty_seat_apply` removes the former head profile but never refreshes Sybillian's `home_label`; Draft `review/empty_apply` refreshes neither the old head nor the old label. Because opening a seat preserves the roster size, those houses remain visible with the former occupant's identity until a later claim or broader refresh.
- Existing Buffet tests assert Greedy head clearing, but they do not assert public label clearing and do not assert either head or label clearing for Draft. This explains why the stale-house regression passed source checks.
- Archived July 31 logs prove several real Draft sessions ran, but they do not log the selected random ordinal, full private offer sets, or complete drafter order. They cannot prove or disprove Jay's reported non-random pattern.
- The `nominee` tag is applied at nomination creation and removed on vote completion, rescind, reset, spectator conversion, or player reset. It is the narrow authoritative lifetime for a nomination particle effect and avoids modifying Sybillian-owned functions.
- Jay clarified that Draft's reported non-random result is the character offers. Jay asked for a separate plan before changing that behavior and directed this pass to continue with the other issues.
- Historical correction (2026-08-03): Draft's offer generator attempted `/random value 0..2147483647`, but live Minecraft 1.21.10 testing later proved that range is rejected and caused the first eligible ticket to win deterministically. The randomization review replaced this old composition-weighted implementation and corrected its random source to the legal `0..2147483646` range.
- Jay clarified that Hot Potato shows exactly one throw particle when used by a Storyteller. `shoot.mcfunction` starts the ray 0.5 blocks from the holder's eyes. The first raycast sample treats any Storyteller as a blocking collision, including the current `botc_fun_hot_holder`, and immediately zeros the range. This proves the holder is colliding with their own trace.
- Hot Potato currently starts with range score `80`; each recursive step advances 0.25 blocks, so the maximum throw reach is 20 blocks.
- Jay clarified that the seat-finder particle ring, rather than a particle around the nominee, must replay when phase 3 nominations begins. Both the night-to-day ring and nomination ring must last five seconds.
- The current seat guide is acknowledgement-based, not time-based: during phases 1 through 3 it renders every five ticks until a player first stands over the Town Square warped-planks marker that day. Once acknowledged during daytime it cannot replay at nominations. `tools/tests/test-seat-layouts.ps1` explicitly asserts this old contract and must be updated with the implementation.
- Jay clarified that the house failure occurs immediately after starting: the label shows the correct player but the head shows another active player.
- The initial house mismatch is proven in the start sequence. Buffet first snapshots the correct randomized roster. `botc_patch:cmd/start` then invokes Sybillian reset/start logic, which removes the Buffet teams, assigns temporary random upstream IDs, and builds head profiles from that temporary order. Buffet subsequently restores its stable IDs/teams and re-syncs names, but does not rebuild the head profiles. That yields the exact reported state: correct label/name with a different active player's head.
- Greedy recount status is assignment-oriented rather than submission-oriented: role `0` yields status `0` when unsubmitted and `1` when submitted; any nonzero role yields status `2` when selected/overridden or `3` when absent from choices without an override, regardless of `submitted`. Exact UI precedence must therefore inspect `submitted` first: unsubmitted plus role `0` is a first submission, unsubmitted plus role `>0` is resubmitting, and status `2/3` is interpreted only after a new submission exists.
- Greedy's current dashboard reduces those states to open/red/green, so a submitted status-3 assignment can appear green. The selected-seat dialog and blocked-start report use generic wording instead of stating whether this is a first submission, resubmission, unassigned submitted player, or exact assignment/pick mismatch.
- A worker challenge proved the earlier journal mapping `status 0 + role > 0 = resubmitting` was unreachable. The source state machine remains correct for assignment validity and does not need to change; presentation will derive resubmission from `{submitted:0b,role:1..}` before consulting status.
- Isolated recovery-branch baselines passed: `test-buffet-gamemodes.ps1`, `test-fun-toybox.ps1`, and `test-boomdandy-and-nomination-kills.ps1`. The first Buffet attempt lacked the ignored runtime Sybillian role table in the isolated worktree; linking that read-only dependency and rerunning proved the test itself passes.
- A trial merge of `main` and `codex/jays-patch-1.9-beta-recovery` found only two documentation conflicts: root `AGENTS.md`, and `docs/agents/tooling-docs/AGENTS.md` (modified on `main`, deleted on recovery). Gameplay/source paths do not overlap.
- Jay accepted the Greedy exact-blocker and authoritative Buffet house-profile fixes.
- Jay set Hot Potato's target reach to five blocks and added a countdown requirement: the holder heartbeat must become progressively faster and higher-pitched as detonation approaches.
- Jay refined the seat-guide contract: the ring remains visible until that player enters Townsquare, continues for exactly five seconds after entry, then disappears. Daybreak and nominations each start a fresh per-player guide window.
- Jay chose the existing `codex/jays-patch-1.9-beta-recovery` branch for this work instead of merging it into a new branch from `main`. The workspace is now on that branch; the earlier trial-merge conflicts are irrelevant to this implementation pass.

## Inference

- The reports do not have one shared root cause: the house mismatch is an upstream-start ordering defect, Hot Potato is a self-collision selector defect, and Greedy is missing state-specific UI/reporting.
- The live runtime appears to have been deployed from the recovery branch, but the exact deployment provenance has not yet been proven.
- These weighted-offer hypotheses were reasonable during this earlier task but
  are now superseded. Live testing later proved an invalid random range was
  deterministically selecting the first ticket, and the accepted replacement
  uses equal legal-type odds plus `4/2/1` archetype tickets.
- Replacing the complete house-head `minecraft:profile` component from the authoritative Buffet roster after identity restoration should be more reliable than mutating only `.name`, because it prevents resolved texture data from a prior occupant surviving a name-only update.

## Recommendation

- Historical recommendation, completed later: leave Draft unchanged in this
  bounded pass, then resolve its probability contract through the separate
  randomization review.
- Fix Hot Potato by excluding the current `botc_fun_hot_holder` from the Storyteller blocking selector while retaining other Storytellers as blockers and invalid recipients. Set the nominal ray reach to five blocks (20 quarter-block ray steps). Replace the fixed last-ten-seconds heartbeat with monotonic countdown bands whose interval decreases and pitch increases toward detonation; keep the sound audience and holder-centered origin unchanged.
- Replace day-only acknowledgement with per-guide-window state: phase 1 starts the daybreak window, phase 3 starts a fresh nominations window, and the existing private ring renders every five ticks until the player enters Townsquare plus a 100-tick/five-second tail. The guide ends on leaving active day/nomination phases and remains private to the correct active seated player.
- Add a generated Jay-owned house-head refresh from authoritative `botc_patch:buffet roster.p1..p15` after `restore_started_identity`; replace the full profile component and clear inactive seats. Also repair the proven Draft/Greedy empty-seat label/head paths without changing Sybillian source.
- Make Greedy's dashboard, selected-player dialog, and blocked-start report distinguish every hard-blocking seat state. Name the assigned character for a status-3 mismatch and state that it is absent from the current picks with no override. Retain the existing exact offline, Hermit, Demon, jinx, Choirboy/King, and Huntsman/Damsel blockers.
- Add focused source-level regression checks for each fix, then run generator checks, Buffet/fun/seat-layout suites, source-wide validation, runtime sync, reload/log validation when the server is available, and targeted in-game checks.

## Unresolved Questions

- None remain from this task. The later randomization review accepted the
  probability contract and completed deterministic plus expanded live QA.

## Plan And Progress

1. **Complete:** Inventory and trace all five flows through Jay-owned source, upstream calls, tests, docs, and relevant logs/runtime state.
2. **Complete:** Jay accepted the four-fix plan, selected a five-block Hot Potato reach, refined the particle tail, added escalating heartbeat behavior, and selected the existing beta recovery branch.
3. **Complete:** The updated on-disk workflow and all three journals were re-read, the branch and protected drafts were verified, and both Luna XHigh slices completed reviewed handoffs.
4. **Complete:** Sol integrated and reviewed the combined diff, ran both generator checks, the focused suites, the pre-index safety checks, refreshed the generated code-library indexes and source baseline, rebuilt the stale public package through the reviewed packaging tool, and passed the complete source-only gate.
5. **Complete:** Saved and restarted the zero-player Minecraft container, deployed from `Jays-Patch` through BOTC.exe, proved runtime/source parity, ran the four exact Final Sync RCON commands including `/reload`, and found no function-load, parser, unknown-function, exception, or server-error lines in the resulting reload window. Manual in-game behavior remains untested and is not claimed.

## Affected Capability Matrix

| Role | Must remain allowed | Must remain blocked/protected |
| --- | --- | --- |
| Player | Use the intended Buffet choices/review flow and see correct public nomination/house visuals | Storyteller-only mutation or setup controls |
| Spectator | Keep existing spectator visibility and inventory behavior | Active-player Buffet choices unless already supported |
| Storyteller | Run and observe supported Buffet/nomination controls | Accidental treatment as a normal active player where unsupported |
| Operator/owner | Keep existing administrative recovery and diagnostic access | No new dependency on OP for normal non-op play |
| Offline/rejoining player | Restore or rebuild identity/state only where the current feature owns it | Stale player identity leaking into another seat/house |

## Active Luna Assignments

- `greedy_house_identity_resume`: corrected handoff accepted after Sol verified mutually exclusive selected-player states, explicit nonzero-role status precedence, assigned-character naming during resubmission, authoritative full-profile refresh, and both empty-seat cleanup paths. Worker journal: `docs/tasks/buffet-nomination-fixes/workers/greedy-house-identity.md`.
- `hot_potato_seat_guide_resume`: handed off for Sol review after implementing Hot Potato holder/range/heartbeat fixes plus daybreak and nominations seat-guide windows. Worker journal: `docs/tasks/buffet-nomination-fixes/workers/hot-potato-seat-guide.md`.

## Checks Run

- `git status --short --branch`: passed; clean `main` working tree before journal creation.
- `tools/tests/live/test-runtime-sync.ps1`: failed as expected on `main`; Buffet and other recovery-branch files appear as stale runtime extras because `main` does not own their source.
- Offline NBT inspection of `data/world` entity, scoreboard, and command-storage data: current five visible house names and heads match the saved Buffet roster.
- `docker ps`: unavailable because Docker Desktop's Linux engine is not running; no live checks were attempted.
- Source transition audit: proved stale public identity after Greedy and Draft seat-empty actions and identified missing regression assertions.
- Archived log audit: found real Draft runs but no retained random-roll/order trace strong enough to evaluate distribution.
- Hot Potato ray audit: proved the Storyteller holder intersects the first sample of their own trace; current reach is 20 blocks.
- Start-order audit: proved Sybillian writes heads from a temporary random ID order and Buffet restores names/IDs without rebuilding heads.
- Seat-guide audit and `test-seat-layouts.ps1` inspection: proved the current acknowledgement contract cannot replay the ring at nominations and is not bounded to five seconds.
- Greedy state/UI/report audit: enumerated all local hard blockers and proved status 3 is hidden behind generic/green presentation.
- Recovery-branch baseline tests: Buffet, fun toybox, and Boomdandy/nomination-kill suites passed in isolation with the required read-only role-table dependency available.
- `git merge-tree --write-tree main codex/jays-patch-1.9-beta-recovery`: found two documentation conflicts and no gameplay-path conflicts.
- New-task handoff Git audit on `codex/jays-patch-1.9-beta-recovery`: only Sol's draft `Jays-Patch/README.md` and `docs/code-library/feature-map.md` updates plus the untracked master/worker journals are present. No gameplay source or test file has changed.
- Fresh Luna Hot Potato/seat-guide handoff: `test-fun-toybox.ps1` and `test-seat-layouts.ps1` passed for the worker and again independently for Sol. Sol's source/diff review confirmed the holder-only collision exclusion, 20-step reach, four valid ascending heartbeat ranges, phase-window serial, active-player guards, private ring dispatch, and 100-tick tail structure.
- Live startup synchronized a superseded mid-edit Hot Potato file and rejected descending score ranges. The source now uses valid ascending ranges with regression coverage, but a clean final deployment and successful `/reload` are still required before any live-pass claim.
- Fresh Luna Greedy/house-identity handoff: both Buffet generators passed `-Check`, and `test-buffet-gamemodes.ps1` passed with all 131 supported jinx pairs. Sol review confirmed Draft offer generation was untouched and the authoritative full-profile/empty-seat paths are generator-owned, but found that selected offline seats could also show a submission state, status `2/3` presentation did not explicitly exclude `role:0`, and resubmission text did not name the reserved character. The slice is back with Luna for this bounded acceptance correction.
- Corrected Greedy handoff: Luna fixed all three Sol findings in the generator and focused tests; both generator checks and all three focused integration suites passed again. Sol's combined diff and whitespace review passed.
- Pre-index safety checks passed: source ownership, command budget, player-facing message style, upstream compatibility (137 roles and 37 direct calls), game-state invariants, and Boomdandy/nomination kills. Generated code-library indexes were then refreshed and passed `-Check`.
- `tools/update-source-baseline.ps1` ran its full non-live safety suite successfully and refreshed the known-good baseline for 2,624 owned files.
- The first final `tools/tests/run-all.ps1` attempt passed every test through resource-pack selectors, then failed because the existing July 31 public package ZIP did not contain the six new function files. This is stale disposable package output, not a source or Git-tracking failure. Preserve the old ZIP outside `dist`, rebuild only through `tools/build-public-package.ps1`, then rerun the complete gate.
- The pre-rebuild public package was preserved at `backups/release-tests/pre-buffet-nomination-fixes-20260802-011659-Jays-Patch-v1.9.0-beta.1.zip` with SHA-256 `C8D665EAB130F5ED1195C0CDAB3D04454F21550B706F6DFF66BD082107A66C6D`.
- `tools/build-public-package.ps1` passed its embedded safety checks and rebuilt `Jays-Patch/dist/Jay's Patch v1.9.0-beta.1.zip`; its bundled hosted resource-pack SHA-1 is `923113b3d4ef3dd6487d038c1e956e2b06b9397b`.
- The subsequent complete `tools/tests/run-all.ps1` passed, including public-package parity and the 2,624-file source baseline.
- Live pre-deployment check: `botc-minecraft` is healthy with `0/25` players. `tools/tests/live/test-runtime-sync.ps1` correctly fails against the superseded mid-edit runtime because it lacks `buffet/greedy/start/report_assignment_mismatch`, `buffet/greedy/start/report_resubmission`, and `buffet/roster/refresh_started_house_profiles`. A launcher-owned deploy/reload is still required.
- Final deployment: RCON reported `0/25` players, `save-all flush` succeeded, and Minecraft stopped cleanly at `2026-08-02 01:24:35 +02:00`. BOTC.exe completed its first reviewed `Jays-Patch` deployment and started the Minecraft service; its redirected dashboard then hit the Windows console-only error `De ingang is ongeldig` before its readiness loop, so Final Sync was completed explicitly rather than treating the launcher run as a full pass.
- Minecraft became healthy and RCON-ready at `2026-08-02 01:26:12 +02:00`. `tools/tests/live/test-runtime-sync.ps1` passed before reload and again afterward, proving the deployed datapack and Jay-owned Melius commands match source.
- The exact BOTC.exe Final Sync commands all succeeded: `reload`, `function botc_patch:startup/yawp_init`, `scoreboard players set yawp_startup_done botc_patch 1`, and `gamerule logAdminCommands true`.
- The clean reload log window beginning `2026-08-02 01:26:44 +02:00` loaded 18 custom commands, one command modifier, 1,461 recipes, and 1,574 advancements. It contains no matched function-load, command-parser, descending-range, unknown-function, exception, or server-error lines. The only notable line is a one-time `Can't keep up` warning while reload took about 12.6 seconds.
- Final live state: `botc-minecraft` is healthy with `0/25` players. No human entered the game, so dashboard text, private particles, Hot Potato passing/audio, and public head appearance were not observed in-game.
- A fresh combined-diff review found one generator defect missed by the passing focused tests: Greedy's newly generator-owned `empty_seat_apply` omitted the required `1` from its seat-generation increment. The expanded macro command therefore fails when used, leaving an offline former occupant's saved generation eligible to pass reconnect validation after the seat is opened.
- Review correction: restored `scoreboard players add buffet_seat_$(seat)_generation botc_patch 1` in the generator, regenerated `greedy/review/empty_seat_apply.mcfunction`, and added an exact regression assertion for offline-generation invalidation.
- Both Buffet generators passed `-Check`; the Buffet, fun toybox, seat-layout, and Boomdandy/nomination-kill focused suites passed after the correction.
- The complete source-safety gate passed before baseline refresh. `tools/update-source-baseline.ps1` then passed its embedded gate and refreshed the known-good baseline for 2,625 owned files; generated code-library indexes remained current.
- `tools/build-public-package.ps1` passed and rebuilt `Jays-Patch/dist/Jay's Patch v1.9.0-beta.1.zip` with hosted resource-pack SHA-1 `923113b3d4ef3dd6487d038c1e956e2b06b9397b`. The subsequent `tools/tests/run-all.ps1` passed, including package parity and the 2,625-file source baseline.
- Final correction deployment was unavailable: `docker ps` could not connect to `dockerDesktopLinuxEngine`, Windows reported `com.docker.service` stopped, and no BOTC process was running. No deploy, `/reload`, RCON, log-window, or new in-game verification was claimed for the corrected source.
- Jay restarted Docker Desktop. With no running containers or possible connected players, BOTC.exe deployed the corrected `Jays-Patch` source and started `botc-minecraft`. Its redirected dashboard again exited after the known Windows console-only `De ingang is ongeldig` error, but only after deployment and container startup had succeeded.
- The corrected container became healthy and RCON reported `0/25` players. `tools/tests/live/test-runtime-sync.ps1` passed before `/reload` and again afterward, proving the deployed Jay-owned datapack and Melius commands match the corrected source.
- The correction Final Sync commands all returned success: `reload`, `function botc_patch:startup/yawp_init`, `scoreboard players set yawp_startup_done botc_patch 1`, and `gamerule logAdminCommands true`.
- The correction reload window beginning `2026-08-02 16:18:38 +02:00` loaded 18 custom commands, one command modifier, 1,461 recipes, and 1,574 advancements. It contains no matched function-load, parser, incomplete-command, unknown-function, exception, or server-thread error. One `Can't keep up` warning reported an 8.895-second reload delay.
- Final corrected live state: `botc-minecraft` is healthy with `0/25` players. No human entered the game, so the Greedy offline-seat transition and the other player-visible interactions remain unobserved in-game.

## Current Blocker And Next Step

- **Blocker:** None for the accepted source, package, deployment, or automated live-verification scope.
- **Next step:** Treat manual multiplayer/in-game observation for this task's
  non-Draft interactions as optional follow-up evidence. Draft randomization's
  separate accepted plan and expanded live QA are complete.
