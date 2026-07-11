# Lessons Learned

Use this note after large fixes, repeated bugs, or confusing investigations.
Keep entries short, evidence-based, and useful for future Codex sessions.

## Entry Template

- **Date:**
- **Area:** Jay's Patch, resource pack, server ops, world, docs, or tooling.
- **What happened:**
- **Evidence:**
- **Root cause or best inference:**
- **Fix:**
- **Verification:**
- **Future rule:**

## Rules

- Record proven facts separately from guesses.
- Prefer one useful lesson over a long diary entry.
- Link the source file, command, or log clue when it matters.
- Do not include private values, player UUID details, secrets, or full logs.

## Entries

- **Date:** 2026-07-01
- **Area:** Resource pack / Minecraft 1.21.10 selector rollback
- **What happened:** Jay-owned custom tool textures worked before the Toggle
  Jay's Patch work, then later builds degraded into vanilla
  `carrot_on_a_stick` or purple/black missing models.
- **Evidence:** The old working hosted pack from the first texture pass
  contained
  `assets/minecraft/items/carrot_on_a_stick.json` and
  `assets/minecraft/items/paper.json` selector files using
  `property: minecraft:component`, `component: minecraft:custom_model_data`,
  and object `when.strings` cases. Later debugging incorrectly tried direct
  `property: minecraft:custom_model_data` cases and then
  `minecraft:item_model=...` components.
- **Root cause or best inference:** Toggle Jay's Patch was not the root cause.
  The regression was switching Jay-owned visuals from the known-good
  custom-model-data selector path to the newer `minecraft:item_model` component
  path and then packaging builds without the root selector files.
- **Fix:** Restore the root `carrot_on_a_stick.json` and `paper.json`
  selectors to the first working shape, remove `minecraft:item_model` from
  Jay-owned datapack item stacks, remove generated `assets/botc_patch/items`
  item-definition files, and make tests fail if datapack functions reintroduce
  `minecraft:item_model` or if selectors drift away from `when.strings`.
- **Verification:** `tools/tests/test-resourcepack-mappings.ps1` verifies 249
  carrot strings, 138 paper strings, and 138 role icons are covered by the
  selector files. `tools/tests/test-tool-item-registry.ps1` rejects Jay-owned
  item replacements that still emit `minecraft:item_model`. Jay then tested the
  rebuilt local pack in-game and confirmed the custom textures render correctly
  instead of falling back to vanilla `carrot_on_a_stick`.
- **Future rule:** For Jay-owned carrot/paper visuals, use
  `minecraft:custom_model_data` strings plus root selector files in the June 21
  shape: `property: minecraft:component`,
  `component: minecraft:custom_model_data`, and `when.strings`. Do not switch
  to direct selector cases, `minecraft:item_model`, or Simple Resource Loader
  unless fresh evidence proves this recovered path cannot work.

- **Date:** 2026-07-01
- **Area:** Resource pack / Minecraft 1.21.10 Simple Resource Loader
- **Status:** Superseded by the selector rollback lesson above.
- **What happened:** Jay-owned custom tool textures kept failing as vanilla
  `carrot_on_a_stick` or purple/black missing models even though the live item
  data, PNG files, model files, and selected/server resource-pack zips looked
  correct.
- **Evidence:** `minecraft:item_model="minecraft:diamond"` rendered as a
  diamond, proving the item component worked. A minimal selected zip containing
  `assets/minecraft/items/botc_diag.json` pointing to vanilla diamond still
  rendered purple/black. The exact same `botc_diag` item definition worked when
  installed through Simple Resource Loader at
  `resources/resourcepack/required/Jays-Patch-Diagnostic-ItemModel`. Copying
  the real `Jays-Patch/resourcepack` folder into the client profile's
  `resources/resourcepack/required/Jays-Patch` made all Jay-owned item textures
  render correctly.
- **Root cause or best inference:** In this Minecraft 1.21.10 Modrinth/SRL
  client setup, normal selected or server-advertised resource-pack zips do not
  reliably contribute the new `assets/*/items/*.json` item definitions used by
  `minecraft:item_model`. Simple Resource Loader required packs do.
- **Fix:** This was the wrong long-term fix. The later rollback restored the
  original selector-based path instead of depending on client-side Simple
  Resource Loader installation.
- **Verification:** After copying the real pack into the client's SRL required
  folder and pressing F3+T, Jay confirmed every custom item texture worked.
- **Future rule:** Do not conclude SRL is required while the root
  `carrot_on_a_stick.json` / `paper.json` selector path is missing, stale, or
  untested.

- **Date:** 2026-07-01
- **Area:** Resource pack / Minecraft 1.21.10 item rendering
- **Status:** Superseded by the selector rollback lesson above.
- **What happened:** Jay still saw vanilla `carrot_on_a_stick` for every
  Jay-owned tool after the server offered the new pack, the client downloaded
  it, and RCON proved live items had the expected `custom_model_data` strings.
- **Evidence:** The exact downloaded pack contained Jay's models/textures, and
  live items carried strings such as `setup_reset_game` and `setup_wall_bag`.
  The remaining failed surface was the visual selector path, not item delivery
  or item stack routing.
- **Root cause or best inference:** This inference was wrong. The failed state
  came from missing/stale selector files and later migration attempts, not from
  selector overrides being inherently unusable.
- **Fix:** This direction was wrong for Jay's Patch. The later rollback restored
  the selector files and removed `minecraft:item_model` from datapack item
  stacks.
- **Verification:** Current resource-pack tests must prove the selector files
  exist and cover the emitted `custom_model_data` strings.
- **Future rule:** Do not use this entry as guidance for Jay-owned carrot/paper
  tools. Use the June 21 selector rollback entry instead.

- **Date:** 2026-07-01
- **Area:** Resource pack / custom model data selectors
- **Status:** Superseded by the selector rollback lesson above.
- **What happened:** Jay still saw vanilla `carrot_on_a_stick` for every
  Jay-owned tool even after the correct hosted resource pack was downloaded.
- **Evidence:** RCON showed the live items had correct
  `minecraft:custom_model_data` string components, the client log showed the
  expected server pack SHA/id loaded, and the cached pack contained the intended
  model and texture files. The item definitions used
  `"property": "minecraft:component"` with object `when.strings` cases.
- **Root cause or best inference:** This inference was wrong. The old
  `minecraft:component` selector shape was not bad; it was the first proven
  working shape.
- **Fix:** Superseded. Use `"property": "minecraft:component"`,
  `"component": "minecraft:custom_model_data"`, and
  `"when": { "strings": ["..."] }` cases in
  `assets/minecraft/items/carrot_on_a_stick.json` and
  `assets/minecraft/items/paper.json`.
- **Verification:** Resource-pack mapping tests must prove the corrected
  selector shape, all datapack strings have mappings, and generated/upload zips
  contain the corrected item definitions before asking Jay to upload a new pack.
- **Future rule:** When every custom carrot item renders as vanilla, first prove
  both sides: the item has the expected `custom_model_data` string, and the
  downloaded pack's item definition uses the June 21 component selector shape
  with a `when.strings` case for that string.

- **Date:** 2026-07-01
- **Area:** Resource pack / public package build
- **What happened:** After Jay provided a hosted MCPacks URL/SHA, Codex rebuilt
  `Jays-Patch/dist/Jays-Patch-resourcepack.zip` from local source and bundled
  that locally recompressed archive in the public package fallback folder.
- **Evidence:** The hosted pack SHA was
  `75ebf9f608f8467d6ed4a426d08b97423e2f4fc7`, while the locally rebuilt
  fallback zip had a different SHA. The zip root was valid, so the failure was
  archive identity/drift, not folder nesting.
- **Root cause or best inference:** The public package fallback resourcepack was
  treated as a build artifact instead of the exact hosted archive clients are
  told to download. Codex also failed to start from the direct symptom:
  `carrot_on_a_stick` means check `assets/minecraft/items/carrot_on_a_stick.json`
  before chasing package-level details.
- **Fix:** Add `tools/build-resourcepack-from-source.ps1` for upload zips and
  `tools/build-public-package.ps1` for hosted/public packages. Add
  `tools/tests/test-public-package-resourcepack.ps1` to fail if an existing
  fallback zip or package instruction file drifts from the configured
  URL/SHA/required flag. Strengthen `tools/tests/test-resourcepack-mappings.ps1`
  so Jay's `carrot_on_a_stick` item definition must include the required base
  and Jay-owned custom-model strings.
- **Verification:** The hosted archive downloaded with the expected SHA, the
  public package resource-pack safety test passed, and the carrot item mapping
  test now covers the actual item-definition file.
- **Future rule:** Never put a locally recompressed resourcepack into the public
  fallback folder when `server.properties` points at a hosted pack. The fallback
  zip must be byte-for-byte the hosted archive named by `resource-pack-sha1`.

- **Date:** 2026-07-01
- **Area:** Resource pack / launcher deployment
- **What happened:** Jay still saw vanilla `carrot_on_a_stick` after a corrected
  resourcepack was uploaded and the source settings were changed.
- **Evidence:** Live `../data/server.properties` had been rewritten to the stale
  hosted pack `202689e28a25a47c20be40cc619c5ca127701869` with pack id
  `f775da9c-828d-4aae-ada2-bf206c83eea9`. The client cache did not contain the
  new `a7ee2e2c89e5023af24c6a78a3271921adc68fcf` pack under the new id. Client
  logs showed the loaded server pack was still `server/.../f775...`.
- **Root cause or best inference:** `launcher/exe/BotcLauncher.cs` had been
  updated, but `BOTC.exe` was not rebuilt. The older built launcher still owned
  server-property startup sync and rewrote the old resource-pack URL/SHA/id back
  into live `server.properties`.
- **Fix:** Rebuild `BOTC.exe` after changing launcher-owned resource-pack
  defaults, then correct live `server.properties` again. Verify the client
  downloads the new pack id and that the exact downloaded pack has the June 21
  selector shape: `property: minecraft:component`,
  `component: minecraft:custom_model_data`, and `when.strings` cases.
- **Future rule:** Treat `BOTC.exe` as deployed runtime, not source. Any
  launcher-owned server-property change is incomplete until the EXE has been
  rebuilt and live `server.properties` is rechecked after the next startup.

- **Date:** 2026-06-30
- **Area:** Jay's Patch / datapack UI generation
- **What happened:** We tried to remove revealed seats from the Reveal Grimoire
  dialog without grouping seats.
- **Evidence:** The grouped range menu worked, but Jay rejected the UX because
  it changed the one-page menu. The flat no-group generated-mask version
  produced 32,768 dialog functions and the server watchdog stopped the
  container during reload. The stable count-based menu uses only 16 generated
  functions and restarted cleanly.
- **Root cause or best inference:** Vanilla dialog does not provide a proven
  cheap server-side way to conditionally remove arbitrary buttons from one
  menu. Generating every possible seat-reveal state is operationally too heavy
  for this datapack/server.
- **Fix:** Restore the lightweight one-page count-based Reveal Grimoire dialog.
  Already revealed seats stay visible and report clear feedback for now.
- **Verification:** Source safety passed, runtime sync passed, the server
  restarted healthy, and recent logs showed no relevant errors.
- **Future rule:** Do not accept a generated datapack solution only because it
  is logically correct. Check generated file count, reload cost, runtime sync
  cost, and watchdog risk before deploying it.

- **Date:** 2026-06-28
- **Area:** Jay's Patch / client-server boundaries
- **What happened:** We spent too much time trying to make non-op Storyteller
  FancyMenu setup-bag buttons work server-side.
- **Evidence:** `/setupbag clear` worked for a real non-op Storyteller, proving
  the Melius server-side broker path worked. The same player's FancyMenu buttons
  still failed because their local client-side FancyMenu layout sent Sybillian
  raw commands such as `/function` and `/scoreboard`.
- **Root cause or best inference:** Client-side FancyMenu button files decide
  which command is sent. Server-side aliases only help when the client sends
  the alias; they cannot intercept a blocked raw command before Minecraft's
  permission system rejects it.
- **Fix:** Restore Jay's local Modrinth FancyMenu files to the default client
  state and keep server-side commands as the reliable non-op path.
- **Verification:** The restored client files matched the default backup, and
  the non-op `/setupbag clear` command remained proven server-side.
- **Future rule:** Before relying on a feature, classify it as server-side,
  client-side, or client-required. If Jay asks for server-side behavior that
  depends on client-side files, stop and call out that it will not work for
  every client unless those clients install matching files.

- **Date:** 2026-06-23
- **Area:** Server ops / permissions
- **What happened:** A non-op player could not use the bakery door even though
  Sybillian's YAWP startup suite had run.
- **Evidence:** YAWP showed `bakery` had local `use-blocks Allowed`, while
  `server.properties` still had vanilla `spawn-protection=16` and the world
  spawn was close enough to cover the bakery door.
- **Root cause or best inference:** Vanilla spawn protection blocked the
  non-op interaction before YAWP could be the useful source of truth.
- **Fix:** Jay's Patch launcher ownership now keeps `spawn-protection=0` so
  YAWP handles block-use protection.
- **Verification:** Live config was updated, startup smoke checks passed, and
  the temporary YAWP region workaround was removed.
- **Future rule:** When non-op block interaction fails near spawn, check
  vanilla `spawn-protection` before widening YAWP regions.
- **Date:** 2026-07-11
- **Area:** Jay's Patch / Storyteller's Passage
- **What happened:** Passage appeared to remain in spectator mode until the
  Storyteller right-clicked a block after entering a destination voice zone.
- **Evidence:** A stuck live capture showed the Passage active and ready in the
  Storyteller Den, but both block safety predicates failed. Seconds later,
  Carpet's block query reported air at the same coordinates and Passage closed
  without a right-click. Server profiling was healthy at `4.779 ms` average
  tick time. The decisive setting was `spectatorsGenerateChunks=false`.
- **Root cause:** Spectator players did not keep destination chunks active.
  Passage depends on blocks at Y=-64 for Sybillian voice-zone detection and on
  the Storyteller's body blocks for safe restoration. Those block predicates
  can fail in an inactive chunk. A block interaction or diagnostic block query
  accesses the chunk, making the next tick succeed and falsely suggesting the
  click itself closed Passage.
- **Fix:** Passage now snapshots the existing `spectatorsGenerateChunks`
  gamerule, temporarily enables it while any Passage is active, and restores
  the exact previous value after the last Passage closes. Tick-level cleanup
  also restores it after tag loss, reset, reload, or interrupted state.
- **Verification:** Controlled fake-player checks proved both lifecycle paths:
  previous `false` restored to `false`, and previous `true` restored to `true`.
- **Future rule:** Any spectator-mode feature that reads blocks or marker layers
  must explicitly account for spectator chunk loading. Check
  `spectatorsGenerateChunks` before blaming an interaction event or weakening a
  block-safety predicate.

- **Date:** 2026-07-11
- **Area:** Jay's Patch / FancyMenu grimoire boundary
- **What happened:** We expected the Storyteller's visible FancyMenu character
  edits to pass through the existing server-side `/character` bridge and become
  available to Reveal Grimoire.
- **Evidence:** A real non-op Storyteller changed seat 2 to Scarlet Woman, but
  the server bridge counter, role score, reveal score, and alignment score did
  not change. Sybillian's `ct-role_toggler.txt`, which is opened by the
  Storyteller `ct-grimoire` screen, uses only FancyMenu `set_variable` actions.
  The separate `ct-role_toggler_player.txt` uses `/character`, but it belongs to
  the `ct-player_grim` screen. FancyMenu 3.8.2 contains server-to-client variable
  command packets but no client-to-server packet that returns local variables.
- **Root cause:** `p1_role..p15_role` in the Storyteller grimoire are local
  client memory. A datapack, Melius command overlay, or server-only mod cannot
  observe a local variable change when the client sends no command or packet.
- **Fix:** Keep the `/character` bridge for paths that genuinely reach the
  server, but do not claim it captures standard Storyteller grimoire edits.
  Reveal Grimoire continues to snapshot server-authoritative role data.
- **Verification:** The unchanged-client Scarlet Woman click produced no bridge
  invocation and left seat 2 at its existing server role. Directly invoking the
  registered `/character` root as the Storyteller context did update the same
  role and reveal scores, proving the bridge itself is healthy.
- **Future rule:** Inspect the exact active FancyMenu layout and action type
  before designing a server bridge. `set_variable` is client-only;
  `sendmessage = /command ...` is serverbound. If the required state exists only
  behind `set_variable`, stop unless client-side delivery is explicitly accepted.

- **Date:** 2026-07-11
- **Area:** PowerShell build orchestration
- **What happened:** The public package builder appeared to finish after source
  checks, but nested validation scripts used `exit 0`, which can terminate the
  parent PowerShell process before packaging continues.
- **Evidence:** The build emitted only source-gate output. Direct parent-process
  probes proved execution stopped at nested baseline/FancyMenu checks.
- **Root cause:** Standalone test scripts treated process termination as normal
  success instead of returning control to their caller.
- **Fix:** Successful reusable scripts now `return`; only the outer process owns
  its exit code. The package builder subsequently produced and validated the
  current archive.
- **Future rule:** Any PowerShell script called by another project script must
  return or throw. Do not call `exit` from reusable generators, audits, or test
  helpers.

- **Date:** 2026-07-11
- **Area:** Public release / persistent world-template state
- **What happened:** The exact `v1.1.0` package loaded successfully in an
  isolated clean Sybillian server, but its first Storyteller received
  Sybillian's Setup Bag instead of Jay's replacement bag.
- **Evidence:** The package world already stored
  `patch_setup_bag_enabled=0`. `botc_patch:load` only supplied a default when
  that score was missing, so the persisted value remained valid and survived
  every reload.
- **Root cause:** A world template is not stateless installation media;
  scoreboard values, tags, storage, and entity state travel with it. Missing-
  value initialization cannot establish a new release default when an older
  value already exists.
- **Fix:** Add `patch_config_version` and a one-time migration that writes both
  documented toggle defaults before recording migration completion. A static
  invariant locks that order. The public install instructions now require
  replacing an existing world folder rather than merging one world into
  another.
- **Verification:** In the isolated server, both toggle scores became `1`, the
  green `Everything enabled` item and Jay Setup Bag appeared, the real bag
  teleported the fake Storyteller to the setup room, a deliberate later toggle
  survived `/reload`, delayed YAWP repair completed, and no Jay function errors
  appeared.
- **Future rule:** Treat distributed worlds as persisted databases. Whenever a
  release changes a default or state schema, use an idempotent versioned
  migration and test the exact public artifact against a clean upstream install.

- **Date:** 2026-07-11
- **Area:** Standalone launcher / non-interactive startup
- **What happened:** The rebuilt launcher passed its online redirected smoke
  test but failed immediately when asked to start an offline server from the
  same non-interactive terminal, reporting Windows `invalid handle`.
- **Evidence:** The header rendered successfully and no startup phase line was
  emitted. The next call was `StartDashboard()`, which read
  `Console.CursorTop` without checking whether output had a real console handle.
- **Root cause:** The first redirected-output fix covered the header cursor but
  not the separate startup dashboard cursor. The test exercised only the
  already-online branch, so the offline branch remained uncovered.
- **Fix:** Dashboard initialization now starts disabled, skips cursor rendering
  when output is redirected, and falls back safely if cursor access still
  fails. A startup source check locks that guard in place.
- **Verification:** The rebuilt `BOTC.exe` completed deploy, Docker/Playit
  startup, Minecraft readiness, reload, YAWP Final Sync, and healthy live state
  through redirected output. Interactive double-click startup retains the
  dashboard path.
- **Future rule:** Launcher acceptance must cover both major branches: server
  already online and server offline. Every cursor/window API belongs behind a
  proven interactive-console guard.
