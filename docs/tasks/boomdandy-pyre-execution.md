# Boomdandy Pyre Execution

- Status: Done
- Updated: 2026-08-03 19:00:00 +02:00
- Owner: Sol
- `/plan` state: complete

## Outcome

Before execution commits, let the Storyteller choose between the separate TNT-pyre execution followed by Final Three and Sybillian's normal execute-and-die path where the game continues.

## Done when

- [x] Only an executed in-play Boomdandy replaces the ordinary pyre lightning presentation with the accepted TNT-rain sequence.
- [x] The executed Boomdandy remains alive throughout the TNT rain, dies exactly once when the last TNT explodes, and is dead before the Storyteller is required to act on Final Three.
- [x] The TNT effect cannot damage the map, players, displays, markers, or unrelated entities unless Jay explicitly accepts real TNT damage.
- [x] Ordinary executions, Boomdandy Final Three selection/voting, reset, disconnect, repeated-trigger, and phase guards remain correct at the source/regression level.
- [x] The initiating Storyteller can choose `Unique Execution` or `Normal Execution`, close with `Decide Later`, and reopen the same private choice before anything commits.
- [x] Focused source checks and the complete required gate pass; deployment, reload, logs, and any real in-game observation are reported separately.

## Scope and boundaries

- In scope: Jay-owned execution adapters, Boomdandy trigger/death timing, a bounded pyre effect state machine, owned initialization/reset, focused tests, generated indexes/baseline/package, and live verification when safe.
- Non-goals: changing Boomdandy's Final Three rules, changing ordinary death or execution mechanics, editing Sybillian `ct:` source, changing Draft Buffet randomization, or modifying unrelated pending work.
- Must preserve: the current uncommitted Buffet, Hot Potato, seat-guide, documentation, Draft planning, source-baseline, and package work; existing nomination/vote cleanup and Boomdandy Final Three guards.
- Safety constraints: `Jays-Patch` remains source of truth; investigation is read-only until the plan is accepted; do not use destructive TNT or live-world mutation without an explicit accepted safety contract; do not deploy or reload around connected players.

## Evidence

- Jay reports that the current pyre execution strikes the executed player with lightning and immediately forces the Storyteller into Boomdandy Final Three while the Boomdandy has not yet been killed.
- Jay wants the TNT-rain presentation to be a separate Boomdandy execution mechanic rather than part of Final Three.
- Git remains on `codex/jays-patch-1.9-beta-recovery` with the previously verified uncommitted Buffet/nomination corrections and active Draft-planning documents present.
- Sybillian's `ct:kill/execute/light_pyre` only lights the campfires, moves the marked player to the pyre, adds `being_executed`, and plays the pyre sound. It is safe to retain for Boomdandy.
- Sybillian's `ct:kill/execute/execute` extinguishes the pyre, announces the execution, summons four lightning bolts, and clears the execution tags. It does not call `ct:kill/die`.
- Sybillian's separate `ct:kill/die` function announces death, installs the skull, adds `dead`, updates the team suffix, and refreshes shrouds.
- Jay's generated nomination `execute` wrapper records `botc_st_last_executed`, calls only `ct:kill/execute/execute`, and then opens the post-execution tools. That proves why an ordinary pyre execution does not itself kill the player.
- Both `storyteller_tools/dashboard/open` and `grim/confirm` automatically route a last-executed role 107 into `storyteller_tools/boomdandy/start` before exposing other post-execution actions. That proves why the Storyteller cannot reach the existing manual Kill action first.
- The current Final Three state machine is already independent: `boomdandy/start` owns selection, its tick owns staged eliminations/countdown, and its cleanup explicitly avoids normal death state.
- No Jay-owned or Sybillian-owned source currently uses real primed TNT. Existing Boomdandy explosions are harmless `minecraft:explosion` particles plus `minecraft:entity.generic.explode` sound.
- The supported target is Minecraft Java 1.21.10. Display entities and the existing per-tick Jay state machinery are available for a non-destructive falling-TNT simulation.

## Inference

- Boomdandy must use a narrow Jay-owned execution adapter because calling Sybillian's ordinary execute function would always summon lightning. The adapter should mirror every non-lightning command and be regression-checked against the pinned upstream function so future upstream drift cannot silently change the contract.
- Real primed TNT is unnecessary and unsafe for this presentation. TNT block displays can visibly fall while controlled particles and sounds create the impacts without world damage, player damage, entity knockback, fire, or item drops.
- Jay explicitly requires the Boomdandy to remain alive until the last TNT explodes. Therefore the final impact, not the execution announcement, must own the death transition.
- A roughly five-second effect is long enough to read as a spectacle without making the table wait. Twelve TNT displays, staggered every six ticks from about fifteen blocks above the Townsquare, produce visibly separate impacts while keeping the entity count bounded.

## Unknowns

- None. Jay accepted the final live presentation; source and telemetry own the remaining exact-coordinate and safety claims.

## 2026-08-03 Amendment

Jay later made the Storyteller authoritative before a Boomdandy execution
commits. `Unique Execution` runs the accepted TNT pyre, kills the Boomdandy on
the last impact, and opens Final Three. `Normal Execution` uses Sybillian's
ordinary execution and death path, then lets the game continue. Closing the
dialog chooses neither path; the private choice reopens from Storyteller tools.

This amendment supersedes the original automatic Boomdandy-to-pyre-to-Final
Three handoff described in the historical investigation and implementation
plan below. It does not change the accepted unique pyre or Final Three rules.

## Historical Recommendations

- Keep the TNT cosmetic and non-destructive: twelve TNT block displays, spawned one every six ticks at random safe points across the Townsquare, falling from approximately Y=88 to the existing flat pyre/Townsquare impact plane. Each display should be removed on impact and produce one explosion particle burst and one explosion sound.
- On Boomdandy execute, run the normal non-lightning pyre close/announcement/tag cleanup and start the independent rain while leaving the Boomdandy alive.
- While rain is active, suppress Final Three auto-routing, its post-execution action, and normal phase advancement. The final TNT impact must call `ct:kill/die` exactly once, mark the post-execution kill resolved, refresh the Storyteller tools, and automatically open Final Three for the Storyteller who initiated the execution.
- If the Boomdandy disconnects before the final impact, finish the visual rain but pause at the death boundary. Apply death when the same last-executed Boomdandy returns, then open Final Three. If the initiating Storyteller disconnected, leave the existing dashboard/Grimoire recovery route available to any replacement Storyteller.
- Keep the rain in its own `boomdandy_pyre` functions, state, tick, and cleanup rather than adding a stage to the Final Three state machine.
- Abort and remove every falling display if nominations end, a reset/new game occurs, or the state becomes invalid. Reload should resume a valid active sequence, while duplicate execute attempts should be rejected.
- Preserve ordinary executions byte-for-behavior by routing only a marked role 107 through the new adapter.

## Project-owner decisions

| Decision | Reason | Date |
|---|---|---|
| Give Boomdandy a separate TNT-rain pyre execution | The current lightning presentation does not fit Boomdandy, and the spectacle must remain separate from Final Three. | 2026-08-02 |
| Automatically kill the executed Boomdandy | The Storyteller is immediately occupied by Final Three and cannot apply the missing death manually. | 2026-08-02 |
| Kill the Boomdandy only when the last TNT explodes | The Boomdandy must remain alive throughout their complete execution spectacle. | 2026-08-02 |
| Keep the pyre lit until the final TNT explosion | The fire should support the complete execution spectacle instead of disappearing before the TNT rain begins. | 2026-08-02 |
| Escalate every TNT impact and make impact twelve the largest | Repeating one small particle puff did not give the rain enough increasing dramatic weight. | 2026-08-02 |
| Name the player's seat in the Final Three instruction | Voting is measured against the surviving seat marker, not the moving player body. | 2026-08-02 |
| Let the Storyteller choose the Boomdandy execution path before it commits | The Storyteller may want the unique pyre and Final Three, or Sybillian's normal execution so the game continues. Closing the choice must commit neither path. | 2026-08-03 |
| Make every falling TNT visibly accelerate | The first live presentation used a constant `0.5`-block-per-tick descent, so the TNT did not read as falling under gravity. | 2026-08-02 |
| Keep impacts 1–11 random but center TNT 12 over the pyre | The largest final explosion should resolve on the executed Boomdandy rather than at another random Town Square point. | 2026-08-02 |

## Accepted `/plan`

1. [x] Trace the current execution, death, notification, and Final Three state machines plus their tests and reset paths.
2. [x] Accept the harmless twelve-TNT/five-second visual contract and execution -> rain -> final-impact death -> Final Three ordering.
3. [x] Accept the implementation, verification, deployment, and manual-QA plan recorded below.
4. [x] Start implementation only after the complete plan is accepted.

### Proposed implementation plan

1. Extend the nomination generator so only a last-executed role 107 uses a Jay-owned non-lightning execution adapter; keep the ordinary `ct:kill/execute/execute` route unchanged for every other role.
2. Generate a separate `storyteller_tools/boomdandy_pyre` state machine that owns the bounded TNT-display rain, tracks the initiating Storyteller, and applies `ct:kill/die` exactly once at the final impact or when a disconnected target returns after that impact.
3. Gate the dashboard, Grimoire, notification, and item-mode Final Three routes while the pyre effect is active. At completion, refresh tools and open the existing `storyteller_tools/boomdandy/start` without changing its stages or rules.
4. Add focused regression checks for exact-once death, no lightning on the Boomdandy branch, unchanged ordinary execution, harmless display/particle/sound effects, bounded timing/entity count, prompt gating/recovery, upstream adapter drift, and reset/phase cleanup.
5. Regenerate only the owning outputs, inspect the complete combined diff, run the Boomdandy/nomination, Storyteller action/notification, invariant, upstream-contract, and generator checks, then run the complete source-only gate.
6. Only after safety checks pass, update generated code-library indexes and the source baseline, rebuild the package, verify source/package parity, and deploy from `Jays-Patch` if the server is empty.
7. Run `/reload`, parser/log/runtime-sync checks, and live command-state checks. Observe the actual TNT animation only with a connected real player; otherwise report the visual result as not in-game verified.

## Active `/goal`

Implementation is complete. The original automatic sequence is preserved only
inside `Unique Execution`; the 2026-08-03 amendment owns the preceding private
Storyteller choice.

## Current progress

- Re-read the current project workflow, personal writing guide, Git state, and master-journal template.
- Created this task journal before gameplay investigation and recorded the requested boundaries without changing source.
- Proved the missing-death cause, the forced Final Three route, and the exact Sybillian/Jay ownership boundary.
- Audited the existing Final Three tick/cleanup path and the currently available safe explosion presentation primitives.
- Prepared and received acceptance for the complete plan with final-impact death timing.
- Generated the Boomdandy-only non-lightning execution adapter and independent `boomdandy_pyre` rain, impact, offline wait, death, completion, and cleanup functions.
- Kept ordinary execution on the unchanged Sybillian call and regression-checked the generated adapter against the exact upstream execute body with only its four lightning commands removed.
- Added state guards to nomination execute, Final Three entry, post-execution Kill, phase advance, Storyteller dashboard/Grimoire routing, notification routing, and generated Storyteller items.
- Added focused coverage proving twelve cosmetic TNT block displays, no live TNT, no early death, exact final-impact death, offline wait, phase/reset cleanup, and Final Three handoff.
- Updated the README and feature map without replacing their existing Buffet drafts, refreshed generated code-library indexes, updated the known-good baseline for 2,650 owned files, and built the reviewed public package.
- The full unskipped source-only gate passes. Live deployment is paused because RCON reports one connected player, `Jayify420`.
- After Jay explicitly authorized a dev-server restart, `save-all flush` succeeded, Minecraft stopped cleanly, and BOTC.exe deployed the reviewed `Jays-Patch` source before starting the container.
- BOTC.exe hit the known redirected-console error `De ingang is ongeldig` after container startup, so its exact Final Sync sequence was completed explicitly rather than claiming the launcher readiness loop passed.
- Minecraft became healthy with `0/25` players. Runtime/source parity passed before and after reload; all five Boomdandy pyre scores initialized to `0`; the 72-line reload window contained no parser, missing/unknown-function, exception, or error matches.
- Jay reconnected for a controlled one-player pyre test. The first fixture attempt did not start because the player had no current `game_id`; Sybillian correctly cleared the temporary seat/role before execution, so that attempt is neither a pass nor a mechanic failure.
- After assigning the current active-game generation, seat `4` and role `107` remained stable. The deployed pyre adapter entered state `1`; mid-rain it reported twelve spawned, nine impacted, and no `dead` tag. At tick `96` it reported state `0`, twelve spawned, twelve impacted, waiting `0`, and the `dead` tag. That proves live death occurred only after impact twelve.
- The player was revived and the test fixture was removed: setup phase `0`, ID `4`, role unset, game generation unset, pyre state/counters `0`, and the pre-test persistent tags remain. The ordinary location voice tag may be maintained by the live location loop.
- Jay's live observation identified that the pyre itself extinguished when execution began because the Boomdandy adapter still ran Sybillian's two ordinary pyre-close commands before starting the rain. Jay requested that it remain lit through the rain and extinguish at the final explosion.
- Jay requested that every TNT impact gain more visual weight than the previous one, with the twelfth producing the largest particle explosion. The generated effect now increases density on every impact and adds spark, firework, end-rod, bright-flare, explosion-emitter, and final shockwave layers progressively.
- Jay requested that the Final Three title card explicitly identify the selected player's seat as the proximity-vote target. Its completed subtitle is now: `Stand near a player's seat to vote for their death.`
- The first refinement reload correctly rejected `minecraft:flash` in impacts 9..12 because Minecraft 1.21.10 requires options for that particle. No visual retest was attempted against the invalid load. Direct live RCON syntax checks then proved `minecraft:totem_of_undying`, `minecraft:explosion_emitter`, and `minecraft:sonic_boom` are accepted; the generator now uses the compatible bright totem flare and explicitly rejects `flash` in regression coverage.
- Jay reported that the refined presentation worked, then requested an external view using a Carpet fake player. The corrected atomic dummy pass proved `Test1` alive with the pyre lit at impact `2`, then dead with the pyre extinguished at impact `12`; the timer ended at tick `96` with all twelve displays spawned. The fixture was revived, cleared, and removed afterward.
- Jay's external observation found one remaining presentation defect: every TNT descended at the same `0.5` blocks per tick. The first six-stage correction was visibly better but still too gentle. The deployed fall now progresses through ten three-tick speed stages from `0.05` to `0.95` blocks per tick; their total remains exactly fifteen blocks over thirty ticks, preserving every impact and death boundary.
- Jay confirmed that the largest final explosion reads clearly and requested that it land on the pyre. The generated spawn contract keeps impacts 1–11 on the existing 49-position random grid and fixes TNT 12 above the exact 4×4 pyre center at `(127, 88, 64)`, producing its impact at `(127, 73, 64)`.
- The first frozen deployed-coordinate probe proved Minecraft centers integer `execute positioned` X/Z arguments, placing the display at `127.5, 64.5`. A harmless explicit-decimal summon proved `127.0, 64.0` remains exact. The generator and focused regression now require explicit `127.0 88 64.0`, eliminating the half-block offset.
- Jay reported that the final live result looked good. That is the user acceptance evidence for the stronger acceleration and complete presentation; the no-lightning claim remains independently proven by generated source/regression rather than attributed to a more specific visual statement Jay did not make.
- The accepted explicit-decimal source passed the closing full gate, 2,650-file baseline promotion, package build, and final unskipped gate. It was deployed after `save-all flush`; explicit Final Sync and runtime parity passed before and after reload after BOTC.exe's known redirected-console limitation.
- A frozen real-tick probe started from timer `66`/spawn count `11`, advanced exactly one tick, and found TNT 12 at `[127.0, 87.95, 64.0]` with timer `67` and spawn count `12`. The `0.05` Y change is the first acceleration stage, while exact X/Z prove the final TNT uses the pyre center in the deployed gameplay path. Cleanup left zero displays, state `0`, phase `0`, and removed the dummy completely.
- The final reload window contains no datapack/function-load/parser errors. It does contain one unrelated `malformed response from pronoundb` line from a background external integration; no touched source references PronounDB, so this is reported separately rather than treated as Boomdandy verification evidence or hidden behind an error-free-log claim.
- The acceleration regression, generated index checks, pre-baseline gate, 2,650-file baseline promotion, public-package build, and final unskipped source gate all pass. The acceleration build was deployed after `save-all flush`; BOTC.exe again hit only its known redirected-console error after deployment/start, and explicit Final Sync completed successfully.
- The acceleration runtime matches source before and after reload. Its 74-line reload window contains no datapack/function/parser errors, and the generated pyre tick function executes live. Jay had not yet reconnected for the final visual comparison when this entry was recorded.

## Active Luna assignments

| Assignment | Worker journal | Allowed area | State |
|---|---|---|---|
| None | N/A | Multi-agent delegation is not enabled for this task; implementation remains with Sol | N/A |

## Verification record

| Check | Result | Evidence |
|---|---|---|
| `git status --short --branch` | pass | Correct branch; prior uncommitted work remains present and must be preserved. |
| Owning generators | pass | Boomdandy, nomination, Grimoire confirmation, and tool-item generators completed; `generate-tool-items.ps1 -Check` is current. |
| Focused Boomdandy regression | pass | `tools/tests/test-boomdandy-and-nomination-kills.ps1` proves the separate no-lightning branch, twelve harmless impacts, no early death, exact-once death, and delayed Final Three handoff. |
| Related focused regressions | pass | Tool registry, game-state invariants, Storyteller notifications/actions, madness execution, message style, upstream caller/contract, and command-budget checks passed. |
| Generated code library | pass | `tools/update-code-library.ps1 -Check` reports the generated indexes current. |
| Pre-baseline source gate | pass | Complete source-only safety suite passed with only stale baseline/package checks intentionally skipped. |
| Source baseline | pass | Updated after the clean prerequisite gate; 2,650 owned files. |
| Public package | pass | Built `Jays-Patch/dist/Jay's Patch v1.9.0-beta.1.zip`; bundled hosted resource-pack SHA1 is `923113b3d4ef3dd6487d038c1e956e2b06b9397b`. |
| Final source gate | pass | Complete unskipped `tools/tests/test-source-safety.ps1` passed, including baseline and public-package validation. |
| Live preflight | blocked safely | `botc-minecraft` is healthy, but RCON reports `1/25` players: `Jayify420`. No deploy or reload was attempted around the connected player. |
| Pre-deployment runtime sync | expected stale | The read-only live sync check reports the nine new `storyteller_tools/boomdandy_pyre/*` functions missing from runtime, proving the connected server has not received this change yet. |
| Player coordination | delivered | RCON delivered a private message asking `Jayify420` to disconnect briefly for deployment/reload and reconnect for the visual test; the next player-list check still reported `1/25`. |
| Repeated blocker audit | blocked | Three consecutive goal turns found healthy runtime but `Jayify420` still connected. The accepted safety boundary forbids deploy/reload around connected players, so the active goal is formally paused pending disconnect. |
| Restart authorization | accepted | Jay explicitly authorized restarting this development server and forcefully disconnecting their player if needed, superseding the earlier no-reload-around-connected-players boundary for this deployment. |
| Safe save and restart | pass | `save-all flush` succeeded, Minecraft stopped cleanly, BOTC.exe deployed from `Jays-Patch`, and `botc-minecraft` returned healthy with `0/25` players. |
| Launcher completion | partial, known issue | BOTC.exe deployed and started the service, then its redirected dashboard hit the known Windows console-only `De ingang is ongeldig` error before readiness/Final Sync. No full launcher-success claim is made. |
| Runtime parity before reload | pass | `tools/tests/live/test-runtime-sync.ps1` matched the deployed Jay datapack and owned Melius command files to source. |
| Final Sync | pass | `reload`, `function botc_patch:startup/yawp_init`, `scoreboard players set yawp_startup_done botc_patch 1`, and `gamerule logAdminCommands true` all returned success. |
| Runtime parity after reload | pass | The live sync check passed again after `/reload`. |
| Reload log window | pass | 72 lines since `2026-08-02T15:04:23Z`; no function-load/parser, unknown-function, command-syntax, exception, or error matches. The only warning was one expected reload-time `Can't keep up` message. |
| Live initial state | pass | `boomdandy_pyre_state`, timer, spawned, impacted, and waiting all report `0` after reload. |
| Real-player observation availability | blocked | Three consecutive resumed goal turns found the healthy server at `0/25`. The controlled visual/death-timing test was not started without Jay's client present, and no in-game visual claim is made. |
| First live fixture attempt | invalid fixture | Changing phase before assigning the active `game_id` caused Sybillian to clear the temporary seat/role. Pyre state remained `0`; no effect ran, so this attempt is not counted. |
| Live final-impact timing | pass | With active game identity stable, immediate state was active with `0` impacts and no `dead`; mid-rain state was active at `9/12` impacts with no `dead`; completion occurred at tick `96` with `12/12` impacts, state `0`, waiting `0`, and `dead` present. |
| Live fixture cleanup | pass | `ct:kill/revive` ran, pyre cleanup reset state/counters, test tags were removed, and phase/ID/role/game-generation values were restored to the captured setup values. |
| Visual presentation | pass | Jay viewed the stronger ten-stage dummy sequence externally and reported that the live result looked good; earlier feedback also confirmed the largest final explosion was clear. |
| No-lightning contract | pass | The generated Boomdandy adapter exactly excludes the four upstream lightning commands, the focused regression enforces that contract, and ordinary execution remains unchanged. |
| Dummy final-impact telemetry | pass | In one atomic live check, `Test1` was alive and the campfires were lit while the counter was `2/12`; at `12/12`, the dummy was dead, the campfires were extinguished, all twelve displays had spawned, and the timer was `96`. |
| Accelerating-fall regression | pass | Ten strictly increasing three-tick speeds replace the constant descent and sum to the same exact fifteen-block/30-tick fall. The focused test rejects the old `0.5`-block path. |
| Centered final-impact regression | pass | All 49 random spawn commands exclude spawn index 12; the unique twelfth-spawn command uses `(127, 88, 64)`, the geometric center of the pyre. |
| Deployed centered final-spawn tick | pass | From timer `66` and spawn count `11`, one frozen server tick produced the sole display at `[127.0, 87.95, 64.0]`, timer `67`, and spawn count `12`; cleanup returned state/phase to `0` and removed the dummy/display. |
| Closing trusted artifacts | pass | The final explicit-decimal source passed baseline promotion for 2,650 files, package build, and the complete unskipped source-only gate. |
| Final exact-center deployment | pass | Runtime parity passed before and after reload, all four explicit Final Sync commands succeeded, and the reload window contained no datapack/function/parser errors. One unrelated background PronounDB malformed-response line remains separately noted. |
| Acceleration deployment and Final Sync | pass | Runtime parity passed before and after reload; all four explicit Final Sync commands succeeded after the known BOTC.exe redirected-console failure. |
| Acceleration reload log window | pass | 74 lines since `2026-08-02T15:58:53Z`; no datapack/function-load/parser errors, and the generated pyre tick function executed successfully through RCON. |

## Current blocker

None. Final Three selection itself requires three eligible living players and was not fully exercised with one client; its handoff is proven by source/regression coverage rather than claimed as live multiplayer verification.

## Exact next step

No implementation step remains. Keep the three-player Final Three handoff claim limited to automated/source evidence unless three eligible clients are available in a future QA session.

## Final outcome

Jay accepted the final live presentation. The exact-center source is generated, regression-checked, included in the trusted baseline/package, deployed, reloaded, runtime-matched, and proven at its real timer-67 spawn point. The server is left clean at phase/state `0` with no test dummy or transient display.
