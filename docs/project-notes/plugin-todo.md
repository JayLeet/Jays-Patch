# Jay's Patch Critical TODO

## Evidence

- Jay's current server-side add-on is `Jays-Patch`, with namespace
  `botc_patch`.
- The user-facing command surface is `/botc`.
- The current active world is the Docker-mounted server world at
  `../data/world` from this repo, which is `/data/world` inside the container.
- Sybillian's `ct` datapack should be treated as upstream-owned.
- Plugin or Fabric work is only a fallback if simpler server-side options stop
  being practical.

## Goal

Keep Jay's Patch as a server-side add-on that builds on Sybillian's BOTC pack
instead of replacing it. Prefer the simplest workable server-side layer in this
order:

1. Find another Sybillian-compatible workaround.
2. Use Jay's Patch datapack and command overlays.
3. Add a server plugin only when datapack behavior becomes too awkward.
4. Build a full Fabric mod only as the last option.

Recent critical stabilization covered:

- remove command-block-owned behavior from the world;
- remove retired setup-sign behavior from source, live world, and the shared
  world template;
- create a clean shareable world template;
- make reset return everyone to normal player state without restarting the
  server;
- verify non-op Storytellers can run normal games through `/botc` without extra
  powers.

This stabilization is considered complete when verified, or when the goal
statement itself clearly needs to be updated so work does not continue
indefinitely.

Queue, votekick, owner immunity, grimoire reveal, music selector, raise/lower
hand, winner reveal, and core non-op `/botc` commands are working feature code
and should be preserved during cleanup.

## Cleanup Reset: Retire Setup Signs

- [x] Keep existing working feature code instead of rewriting it.
- [x] Remove setup-sign source behavior from Jay's Patch.
- [x] Remove setup-sign trigger creation from load code.
- [x] Add source checks so setup-sign tick wiring and function files stay gone.
- [x] Remove setup-sign interaction entities and sign blocks from the live
  world after creating a backup.
- [x] Remove the stale `setup_sign` objective from the live scoreboard if it
  exists.
- [x] Copy the verified cleaned world to `Jays-Patch/world-template` during a
  safe copy window.
- [x] Verify queue remains the supported player route for becoming
  Storyteller.
- [x] Live-test kept systems after cleanup using
  `docs/project-notes/live-kept-systems-test-checklist.md`: grimoire reveal,
  winner reveal, music selector, raise/lower hand, votekick, owner immunity,
  reset, and core `/botc` commands.
  - [x] Completed by Jay on 2026-06-30. Jay reported that every requested test
    worked fine. Post-test runtime sync passed and the 60-minute FancyMenu/
    codec/spam-kick/disconnect scan found no matches.

## Completed Goal: Source-Only Stabilization

Completed on 2026-06-23. Remaining open work now needs live-player testing,
live deployment, or a new focused goal statement.

This goal is intentionally not a live-game rollout.

- [x] Work through TODO and code-health cleanup in source-only slices.
- [x] Do not deploy source into `../data`.
- [x] Do not edit `../data` runtime files, live world files, or runtime
  datapacks/configs.
- [x] Do not run `/reload`, restart the server, or use RCON to mutate state.
- [x] Do not replace stable live flows such as `/botc`, the current Reveal
  Grimoire seat menu, reset, winner reveal, music, queue, votekick, or hand
  systems.
- [x] Keep risky work as docs, audits, tests, generators, isolated prototypes,
  or disabled/dev-only source paths.
- [x] Stop or update the goal once remaining work needs live-player testing,
  live deployment, or a changed goal statement.

## Next Milestone: Command-Block-Free World

- [x] Locate all command blocks in the current live `../data/world`.
- [x] Remove all command blocks from the current live `../data/world`.
- [x] Scan the cleaned live `../data/world` and confirm zero command blocks.
- [x] Remove the old physical good/evil winner buttons or verify none remain in
  the documented area.
- [x] Create a valid actual-world post-cleanup backup after correcting the
  server data path.
- [x] Confirm the corrected launcher pre-start backup targets the actual Docker
  data directory on the next `Start.bat` run.
- [x] Verify the cleaned live world still has the intended builds.
- [x] Retire setup signs beside the grimoire; players should use queue instead.
- [x] Verify YAWP regions and required interaction permissions still work.
- [x] Verify `/botc` command flows still work.
- [x] Verify grimoire reveal still works.
- [x] Verify winner reveal still works through `/botc winner good|evil` or the
  Storyteller menu/dialog.
- [x] Verify raise/lower hand items still work during nominations only.
- [x] Verify resource-pack visuals still render correctly.
- [x] Preserve the cleaned verified world snapshot at
  `Jays-Patch/world-template`.
- [x] Initial `Jays-Patch/world-template` should be copied from the cleaned
  current `../data/world`.
- [x] Scan `Jays-Patch/world-template` and confirm zero command blocks.
- [x] Never copy the world while Minecraft is actively writing to it.
- [x] Deploy Jay's Patch runtime datapack into
  `../data/world/datapacks/jays_patch` so it loads as a world datapack.
- [x] Deploy Jay's Patch Melius command overlay into the real server data
  folder so `/botc` is available.
- [x] Deploy Jay's Patch resource-pack overlay into the real server data
  folder.
- [x] Sync Jay's Patch again after Minecraft is ready so startup-time pack or
  FancyMenu rewrites cannot leave stale command/menu runtime files active.

## Reset Player-State Cleanup

- [x] Treat reset as the end of the current storyteller turn.
- [x] Call Sybillian reset behavior through Jay's Patch.
- [x] Reset online users to normal player state during reset.
- [x] Remove temporary storyteller permissions from everyone during reset.
- [x] Keep normal reset in-place, without stopping or restarting the server.
- [x] Keep `reset_requested` at `0` during normal `/botc reset_game`.
- [x] Keep `Jays-Patch/world-template` as the clean shareable/manual recovery
  template, not the normal game-reset mechanism.
- [x] Test reset after a former Storyteller leaves before reset, then rejoins,
  to confirm no stale Storyteller-only state returns.
- [x] Remove any reset behavior that force-teleports players to world spawn;
  resets should clean game/player state while leaving each player where they are.

## Non-Op Storyteller Reliability

- [x] Keep `/botc` for Jay-owned non-setup features, and use Sybillian-style
  command roots for Storyteller/setup broker paths.
- [x] Confirm every exact command/action a non-op Storyteller needs to run a
  normal game.
- [x] Preserve Sybillian's existing Storyteller behavior by wrapping/calling it
  from Jay's Patch.
- [x] Use Melius as the server-authority broker for approved Storyteller
  commands instead of giving players OP.
- [x] Grant no arbitrary OP command passthrough.
- [x] Never grant Storyteller-only permissions to players or spectators unless
  they become Storyteller through an approved queue/admin path.
- [x] Treat Melius paths as the trusted server-authority broker for known BOTC
  Storyteller commands.
- [x] Replace grimoire FancyMenu raw house teleports with the guarded
  `/st tphouse <player>` bridge.
- [x] Restore `/request_chat` as a player-facing compatibility bridge because
  FancyMenu still uses it.
- [x] Confirm FancyMenu button actions contain no protected raw commands.
- [x] Confirm all non-`/request_chat` Melius executable commands are guarded by
  `tag=storyteller`.
- [x] Block Storytellers from banning players.
- [x] Block Storytellers from directly kicking players.
- [x] Confirm whether the current permission system can grant only the required
  Storyteller powers.
- [x] Decide whether datapack/Melius permissions are enough before considering a
  plugin, Fabric Permissions API, or a small custom command interceptor.
- [x] Confirm exact BOTC commands Storytellers currently rely on.
- [x] Keep creative/spectator mode available to Storytellers intentionally,
  because YAWP protection should still block unwanted block breaking, placing,
  and use-block interaction while letting Storytellers move and hide cleanly.
- [x] Retire setup-sign promotion/demotion entirely; queue is the supported
  player-facing Storyteller route.
- [x] Phase-guard setup-only `/setupbag ...` broker commands so they only mutate
  setup state during pre-game phase `0`.
- [x] Remove public `/botc setup...` command paths except the narrow
  stale-client `/botc setup preset <script>` compatibility bridge.
- [x] Convert setup-bag FancyMenu actions to `/setupbag ...` broker commands.
- [x] Keep built-in setup presets on direct Jay's Patch preset functions.
- [x] Re-enable custom `/setupbag import <script-json>` through Sybillian's full
  import sequence as compatibility plumbing for Jay's setup room/bag.
- [x] Drop old Sybillian setup-bag UI live-test work from the active TODO.
  Jay's setup room/bag is now the supported setup path; legacy `/setupbag`
  commands stay only as guarded compatibility bridges.
- [x] Replace broad `scoreboard players reset * role_list` setup cleanup with a
  scoped role-list cleanup so setup actions do not repeatedly reset hundreds of
  scoreboard holders.
- [x] Add `function ct:admin/init/yawp_flags` to the post-start YAWP repair flow
  before `yawp_reset` and `yawp_regions`, then verify the launcher smoke tests.

## FancyMenu Stability / Spam-Kick Investigation

Evidence from `../data/logs/latest.log` on 2026-06-23:

- repeated FancyMenu packet errors appear before two `Kicked for spamming`
  disconnects:
  - `No codec for packet data found with identifier: spiffy_structures`
  - `No codec for packet data found with identifier:
    spiffy_marker_command_suggestions`
- the stack trace points at FancyMenu packet handling, not Jay's Patch datapack
  tick functions.
- Jay's Patch Melius command overlays passed the safety audit, and deployed
  command/FancyMenu overlay files matched source.
- Legacy setup-bag preset/import buttons now send one `/setupbag ...` broker
  command per click, but Jay's setup room/bag is the supported setup UI.
  Custom import still calls Sybillian's full import sequence server-side when
  used through the guarded bridge.

Tasks:

- [x] Reproduce the FancyMenu codec errors with one real non-op Storyteller
  while watching logs with
  `tools/tests/live/watch-fancymenu-errors.ps1`, then test whether the same
  errors happen with Jay-owned FancyMenu overlays temporarily disabled.
  - [x] Attempted during the 2026-06-30 live pass. The issue did not reproduce:
    the 60-minute post-test log scan found no FancyMenu codec, spam-kick,
    disconnect, or connection-reset matches. Overlay-disabling isolation is not
    needed unless the errors return.
- [x] Check whether the server/client FancyMenu, SpiffyHUD, Konkrete, and Melody
  versions are aligned with Sybillian's 1.5.4 client pack; if not, prefer version
  alignment before adding new code.
  - [x] Current server and Jay's current Modrinth client profile match by jar
    filename and file size for FancyMenu `3.8.2`, SpiffyHUD `3.1.0`, Konkrete
    `1.9.13`, Melody `1.0.14`, and Melius Commands `2.1.3`.
  - [x] If another player reports menu disconnects, compare that player's
    installed client UI dependency jars against the server with
    `tools/tests/live/compare-ui-client-mods.ps1 -ClientModsPath <their-mods-folder>`
    before blaming Jay's Patch datapack code.
    - [x] Added the read-only comparison helper and included it in live preflight
      reports. Jay's local client currently matches the server for FancyMenu,
      SpiffyHUD, Konkrete, Melody, and Melius Commands by jar name, size, and
      SHA1. Future player-specific reports still need their own comparison.
- [x] Consolidate setup-bag custom-import buttons into a server-authority bridge
  command per import, so the client sends one command and Jay's Patch runs
  Sybillian's setup steps server-side in the correct order.
- [x] Convert built-in script preset buttons to one-command `/setupbag
  preset_*` bridges that update setup-menu role scores server-side.
- [x] Document the source-only one-command setup-bag bridge plan and add a
  read-only FancyMenu setup-bag burst audit helper.
- [x] Add a read-only FancyMenu action audit helper that flags protected raw
  command roots such as `/function`, `/scoreboard`, `/execute`, and `/gamemode`
  before menu changes reach live testing.
- [x] Document the FancyMenu codec/spam-kick version evidence checklist and
  future live test matrix without changing the current live menu flow.
- [x] Add narrow cooldown/debounce protection for high-impact legacy menu
  bridges only after the setup-bag multi-command burst is consolidated. Do not
  add a broad cooldown that breaks legitimate multi-step Sybillian menu actions.
  Current implementation uses `botc_setup_bridge_cd` only on setup import,
  preset, clear, and apply bridge wrappers; ordinary role toggle clicks remain
  unthrottled.
- [x] Keep menu-root migration tracking aligned across doc and static audit:
  - [x] Allow Sybillian-style roots `/st`, `/setupbag`, `/request_chat`,
    `/character`, `/settings`, `/tpchurch`, and `/tpallhome`.
  - [x] Fail Jay-owned setup-bag menu actions that emit `/botc setup...`.
  - [x] Confirm setup-bag actions emit `/setupbag` roots in `ct-bag_import` and
    `ct-bag_layout`.
  - [x] Keep `tools/tests/audit-fancymenu-actions.ps1`,
    `tools/tests/audit-fancymenu-setupbag-bursts.ps1`, and
    `tools/tests/test-setupbag-burst-bridges.ps1` in the non-blocking CI-like
    source-check path.

## Verification

- [x] Test fake-player flows where practical.
- [x] Test one real non-op Storyteller flow.
- [x] Verify resource-pack loading and rendered custom items.
- [x] Confirm the hosted Jay's Patch resource-pack URL and local zip have the
  same extracted contents, even though their archive SHA1 values differ.
- [x] Configure `server.properties` with the hosted resource-pack URL SHA because
  clients download the hosted zip.
- [x] Verify grimoire reveal role icons and spotlight behavior.
- [x] Verify winner reveal title/head/cleanup behavior.
- [x] Verify raise/lower hand item repair, duplicate cleanup, and dropped-item
  cleanup.
- [x] Verify night music behavior for non-Storyteller players.
- [x] Verify in-place reset keeps the server running and leaves
  `reset_requested` at `0`.
- [x] Test in-place reset with at least one real online player to confirm the
  player returns in normal player state.
- [x] Test reset after a former Storyteller leaves before reset, then rejoins,
  to confirm no stale Storyteller-only state returns.
- [x] Update docs and code-library files if implementation structure changes.

## Code Health / Maintainability

### Architecture Stabilization 2026-07-11

- [x] Add a generated known-good source manifest covering owned source and
  build inputs while excluding live/private/runtime output.
- [x] Centralize public package semantic versioning in
  `Jays-Patch/version.txt`.
- [x] Make public-package builds run source checks, write an internal SHA-256
  manifest, produce reproducible ZIP output, and validate the finished archive.
- [x] Add cross-feature state-invariant checks for reset ordering, persistent
  queue behavior, phase-owned menus, grimoire edit locking, and patch-toggle
  states.
- [x] Centralize Sybillian role metadata parsing and base-script membership
  without changing generated Minecraft behavior.
- [x] Begin the launcher split with a behavior-preserving models/config
  extraction and compile every `launcher/exe/*.cs` source.
- [x] Extract external process and RCON execution into
  `launcher/exe/BotcLauncher.Process.cs`, with the launcher compile/smoke gate
  still passing.
- [x] Harden redirected/non-interactive offline startup so cursor-based
  dashboard rendering is skipped when no real console handle exists, then
  verify the rebuilt launcher reaches live Final Sync and healthy state.
- [ ] Continue launcher extraction only in separately verified slices when a
  cohesive boundary materially improves debugging; do not split by line count.
- [x] Add a pinned upstream compatibility contract for Sybillian 1.5.4 and
  Minecraft 1.21.10, including role-catalog identity, required state/data, and
  complete direct `ct:` call resolution.
- [x] Install the exact `v1.1.0` public artifact into an isolated clean
  Sybillian server and verify datapack loading, delayed YAWP repair, setup-phase
  tools, and the replacement Setup Bag without mutating the live world.
- [x] Add a versioned one-time default-state migration so a distributed world
  cannot make a fresh install inherit a stale Jay's Patch toggle state, while
  deliberate later toggles still survive reloads.
- [x] Create a clean code-only Git rollback baseline on
  `codex/release-v1.1.0` and tag it `jays-patch-v1.1.0`; keep live/private
  state, generated packages, `BOTC.exe`, and the world template outside the
  source commit.

- [x] Replace runtime launcher PowerShell scripts with the standalone
  `BOTC.exe` launcher source after startup smoke tests were defined.
- [x] Add a source table or generator for repeated inventory fallback functions
  if more item variants are added.
- [x] Add a source table or generator for role icon mappings if role-score
  changes become frequent.
- [x] Audit legacy Melius command overlays after `/botc` fully covers the
  Storyteller flow.
- [x] Treat `Jays-Patch/dist` as disposable build output, not source of truth.
- [x] Add a source-only safety check for launcher ownership, command-overlay
  guards, JSON parsing, generated index presence, and resource-pack mapping
  sanity.
- [x] Add a non-live resource-pack mapping test so datapack custom model data
  strings, item override JSON, and Jay-owned model files cannot silently drift.
- [x] Add a source-only tool item registry for Jay-owned right-click tools,
  model-data ownership, intended phase, and preferred slot.
- [x] Add a source-only tool item registry test so new tool model strings,
  missing `botc_patch_tool` markers, and accidental shared model data are caught
  before live deployment.
- [x] Gradually migrate fixed hotbar item definitions to the tool item registry,
  one stable subsystem at a time, once the registry has proven useful as an
  audit source.
  - [x] Migrate setup-phase queue/Storyteller utility hotbar and cleanup
    functions to `tools/generate-tool-items.ps1`.
  - [x] Migrate setup-room control/action hotbar functions.
  - [x] Migrate live Storyteller fixed hotbar functions.
  - [x] Migrate Teleport-to-Player Back/Next submenu control rows.
  - [x] Migrate Kill, Revive, and Nomination submenu control rows where the
    generator already owns the page.
  - [x] Migrate the post-execution follow-up row.
- [x] Centralize the remaining hotbar cleanup/repair rules around the registry
  so future tool changes do not require searching several unrelated functions.
  - [x] Generate setup-phase item checks from `tool-items.json`.
  - [x] Generate setup-room bag/control cleanup from `tool-items.json`.
  - [x] Generate live Storyteller item checks from `tool-items.json`.
- [x] Add a non-live source-ownership test so Jay's Patch does not accidentally
  grow upstream-owned `ct` datapack namespaces or copied Sybillian assets.

## Grimoire Reveal Polish

- [x] Add reveal sound progression: each newly revealed good player should use
  a slightly higher-pitched reveal sound than the previous good reveal, while
  each newly revealed evil player should use a different evil sound family with
  a slightly lower pitch than the previous evil reveal.
- [x] Sync serverbound `/character <seat> <character>` edits into Jay's Patch
  reveal data so the role/alignment snapshot follows commands that actually
  reach the server.
- [ ] Capture character edits made in Sybillian's standard Storyteller
  `ct-grimoire` role picker. **Blocked for server-only delivery:** that layout
  uses FancyMenu's client-local `set_variable` action, while only the separate
  `ct-player_grim` layout sends `/character`. An unchanged server cannot read
  those local `p1_role..p15_role` values. Revisit only if client-side delivery
  is accepted or the Storyteller uses a server-authoritative editing surface.
- [x] Prove that Sybillian's game-start `ct:players` storage can supply actual
  player names and seat colors to a server-created vanilla dialog without any
  client file changes.
- [x] Complete live verification of the server-authoritative Reveal Grimoire
  editor.
  - [x] On 2026-07-11, Jay verified the pre-reveal confirmation, literal player
    names, player selection, current-script role dialog, role selection, and
    final category-colored visual layout.
  - [x] Verify `Set Good`/`Set Evil`, the final reveal snapshot handoff, and the
    edit lock after Reveal Grimoire is confirmed.
  - [x] Verify that a character edit directly refreshes the acting
    Storyteller's Sybillian FancyMenu grimoire and that the active reveal dialog
    renders `Player (Role)` labels in the expected category colors.
- [x] Record the polished Reveal Grimoire menu idea separately in
  `docs/project-notes/grimoire-polished-menu-plan.md` so the stable live reveal
  flow can stay untouched during normal games.
- [x] Rebuild the Reveal Grimoire menu polish in smaller proven slices where
  the current vanilla dialog path is safe:
  - [x] Improve the current stable seat-button slice so clicking an already
    revealed seat reports that it has already been revealed instead of silently
    clearing the dialog.
  - [x] Add `/botc grimoire disabled_button_test` as a dev-only proof dialog
    for checking whether gray no-action buttons look and behave like disabled
    Reveal Grimoire entries in the real client.
  - [x] Add `/botc grimoire disabled_state_test` as a dev-only state proof
    that branches on seat 1's real reveal state and shows either an active
    entry or a gray no-action revealed entry, without replacing the stable menu.
  - [x] Test the gray no-action route in-client. It looks gray, but still
    behaves like a pressable button, so it is rejected for the final
    unpressable revealed-seat UI.
  - [x] Restore the stable one-page count-based dialog after testing two
    rejected routes: grouped seat ranges changed the UX, and the flat 32,768
    mask menu caused reload/watchdog instability.
- [x] Replace failed selector/NBT player labels with the proven literal macro
  path backed by Sybillian's `ct:players` game-start snapshot. Keep generated
  variants bounded by seat count and role count; do not connect player labels
  to the rejected flat reveal-state mask design.
- [x] Find a maintainable server-side UI route for preventing accidental clicks
  on already revealed seats. Current evidence says the stable route is clear
  already-revealed feedback, not grey pressable buttons, grouped ranges, or a
  32,768-function flat mask menu. Vanilla dialog labels cannot resolve selector
  or dynamic NBT text in this UI path; literal macro-inserted labels worked in
  small tests but made the generated real menu unreliable.
- [x] Investigate reusing Sybillian's working FancyMenu `ct-grimoire` layout as
  the polished Reveal Grimoire visual shell, while keeping every authoritative
  action routed through Jay's Patch `/botc grimoire ...` commands. The audit is
  recorded in `docs/project-notes/grimoire-polished-menu-plan.md`: the layout is
  a good dev-only visual shell candidate, but the live static reveal menu should
  stay until a real non-op Storyteller proves the FancyMenu path safely.
- [x] Do not use the FancyMenu grimoire route for the live Reveal Grimoire menu
  right now. It remains a client-required visual-shell idea only, and would need
  a fresh proof that it does not worsen FancyMenu codec/spam-kick issues before
  replacing the stable static seat dialog.

## Winner Reveal Polish

- [x] Prevent players from removing temporary winner-reveal head items, such as
  good-team diamond blocks or evil-team piglin heads, until the reveal timer
  clears them.

## Implementation Notes

- Do not jump straight to a Fabric plugin or full Fabric mod. Use the escalation
  order in the Goal section.
- Any plugin or mod path must still follow the Lego rule: call, wrap, or read
  Sybillian behavior first, then add Jay-owned behavior.
- No implementation path should require giving players full OP.
- Manual recovery may still restore `../data/world` from
  `Jays-Patch/world-template`, but normal `/botc reset_game` should not stop or
  restart the server.
- Recovery mode should be fail-safe: if a manual world restore cannot be
  completed, keep the server stopped and show a clear message in logs/console.
- During the current source-only goal, use
  `tools/tests/test-source-safety.ps1` for non-live verification. Do not deploy,
  reload, restart, use RCON mutations, edit `../data`, or change the live world
  unless Jay starts a separate live rollout/testing goal.

## Later Backlog

These items are intentionally outside the active stabilization goal.

### Storyteller Queue

- [x] Let players join the storyteller queue.
- [x] Let spectators join the storyteller queue.
- [x] Let players leave the storyteller queue.
- [x] Let players check the queue/status.
- [x] Save the queue to disk so it survives restarts.
- [x] Preserve the queue across game resets.
- [x] Prioritize whoever has waited longest.
- [x] If an active Storyteller is online, keep the queue waiting.
- [x] During setup, if no active Storyteller is online, promote the
  longest-waiting online queued user.
- [x] During a live game, let normal players join the queue but do not promote
  them automatically.
- [x] During a live game, if no Storyteller is online, allow the
  longest-waiting online queued spectator to become an additional emergency
  Storyteller without replacing the original Storyteller.
- [x] If the active Storyteller goes offline and a normal setup handoff happens,
  remove their stale temporary permissions if they return after being replaced.
- [x] Notify online queued players that a Storyteller slot is available.
- [x] Promote the longest-waiting online queued player.
- [x] After a Storyteller finishes a turn, return them to normal player state.

### Voting

- [x] Add player votekick.
- [x] Add Storyteller votekick.
- [x] Majority means more than 50% of online players, excluding the target.
- [x] Add vote timeouts so unfinished votes expire.
- [x] Set votekick expiration to two minutes.
- [x] Add vote cooldowns so players cannot spam vote attempts.
- [x] If a votekick passes against a Storyteller, remove their Storyteller state
  before kicking them so those powers do not persist when they rejoin.
- [x] Only run the kick after the vote succeeds.

### Future Commands

- [x] `/botc queue`
- [x] `/botc queue leave`
- [x] `/botc queue status`
- [x] `/botc vote-kick <player>`
- [x] `/botc vote-remove`
- [x] `/botc queue help`

### Owner Immunity

- [x] Store owner immunity in config instead of hard-coding owner names.
- [x] Keep configured owners immune from queue and votekick restrictions.

