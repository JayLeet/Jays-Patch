# Jay's Patch Code Library

This library maps the custom code in `Jays-Patch` so Codex can inspect related
functions, commands, and resource-pack mappings without doing a file-by-file
audit from scratch each time.

## How To Use This Library

Before changing Jay's Patch behavior:

1. Read the closest curated map for the feature area.
2. Check the generated index for exact function, command, or model references.
3. Follow references back to Sybillian `ct:` code when Jay's Patch wraps or
   calls upstream behavior.
4. Refresh generated indexes after structure changes with:

```powershell
powershell -ExecutionPolicy Bypass -File tools/update-code-library.ps1
```

## Maps

- `feature-map.md`: ownership and responsibilities by feature.
- `integration-map.md`: `/botc`, legacy command overlays, and Sybillian calls.
- `resourcepack-map.md`: custom model data, textures, and item model ownership.
- `../../Jays-Patch/tool-items.json`: source-only registry for Jay-owned
  right-click tool items, slots, phases, and model-data ownership.
- `../../Jays-Patch/base-scripts.json`: TB/SNV/BMR role membership used by the
  setup-wall generator.
- `../../Jays-Patch/source-baseline.json`: generated known-good hashes for
  owned source and build inputs.
- `generated/function-index.md`: generated function list and call map.
- `generated/command-index.md`: generated Melius command overlay index.
- `generated/resourcepack-index.md`: generated item/model mapping index.

## Source-Only Checks

- `tools/tests/test-source-safety.ps1`: broad non-live gate for startup scripts,
  command overlays, resource-pack mappings, source ownership, JSON parsing, and
  generated index presence.
- `tools/tests/test-game-state-invariants.ps1`: cross-feature checks for reset
  ordering, queue persistence/promotion, menu phase ownership, grimoire edit
  locking, the three Jay's Patch toggle states, and one-time default-state
  migration ordering.
- `tools/tests/test-upstream-contract.ps1`: verifies the supported
  Sybillian/Minecraft versions, normalized role catalog, required objectives,
  storage/tag/marker tokens, data files, and every direct Jay-owned `ct:` call.
- `tools/update-source-baseline.ps1`: runs the non-live gate and refreshes the
  known-good source manifest; `-Check` verifies without writing.
- `tools/tests/test-public-package-resourcepack.ps1`: verifies existing public
  package output uses the same resource-pack URL, SHA, optional/required flag,
  and exact fallback zip as the configured hosted pack.
- `tools/build-resourcepack-from-source.ps1`: builds
  `Jays-Patch/dist/Jays-Patch-resourcepack-upload.zip` from resource-pack source
  for Jay to upload, after running the carrot/item mapping checks.
- `tools/build-public-package.ps1`: runs source checks, reads
  `Jays-Patch/version.txt`, downloads the configured hosted resource pack,
  writes a package hash manifest, creates a reproducible public ZIP, and checks
  the finished archive.
- `tools/lib/sybillian-role-catalog.ps1`: the shared parser for upstream role
  score, name, category, alignment, and dialog-color metadata used by Jay's
  generators.
- `tools/tests/test-tool-item-registry.ps1`: validates
  `Jays-Patch/tool-items.json`, catches unregistered Jay-owned tool model
  strings, checks fixed replacement items keep the `botc_patch_tool` marker,
  and validates player-menu, submenu, setup-room bag, and post-execution tool
  metadata.
- `tools/tests/test-custom-script-import-json.ps1`: verifies custom script
  imports keep `/setupbag import <script-json>` as a greedy structured payload,
  preserve pretty JSON with whitespace, and strip `_meta` metadata rows before
  Sybillian setup conversion.
- `tools/lib/tool-registry.ps1`: shared read-only helper for generators that
  build tool stacks or resource-pack cases from `Jays-Patch/tool-items.json`.
- `tools/generate-tool-items.ps1`: generates setup-phase, setup-room, and live
  Storyteller fixed tool hotbar/cleanup/repair functions, plus the
  post-execution follow-up row, from `Jays-Patch/tool-items.json`; source
  safety runs it in `-Check` mode to catch stale generated output.
- `tools/generate-storyteller-player-menu.ps1`: generates the Teleport-to-Player
  dialog. It reuses the grimoire editor's server-side player-label preparation
  so every button shows `Player (Role)` in the role category color, then closes
  the dialog before dispatching the selected seat teleport.
- `tools/generate-storyteller-kill-menu.ps1`,
  `tools/generate-storyteller-revive-menu.ps1`, and
  `tools/generate-storyteller-nomination-menu.ps1`: generate filtered vanilla
  player dialogs using the shared `Player (Role)` labels. Kill lists only alive
  players, Revive lists only dead players, and Nominate lists all active seated
  players. Selecting a nominee opens Back / Start Vote controls. Mark appears
  only after Sybillian records the completed vote, then toggles in place between
  Mark and Clear Mark until the Storyteller presses Back. Start Vote remains
  available; repeated use cancels transient vote schedules, rebuilds the
  selected Sybillian nomination, and starts a clean replacement vote.
- `tools/lib/player-dialog-generator.ps1`: shared bounded dialog generator for
  sparse player sets. It compacts eligible seats into at most 15 entries and
  dispatches one of 16 fixed count variants, avoiding unbounded mask generation.
- `tools/tests/test-storyteller-action-dialogs.ps1`: locks the Kill, Revive, and
  Nominate eligibility filters, guarded command routes, terminal dialog actions,
  nomination rescind cleanup, vote-completion gating, and in-place mark toggling.
- `tools/tests/audit-fancymenu-actions.ps1`: scans Jay-owned FancyMenu button actions
  for protected raw commands.
- `tools/tests/audit-fancymenu-setupbag-bursts.ps1`: lists setup-bag buttons that
  still send several client commands from one click.
- `tools/tests/test-setupbag-burst-bridges.ps1`: enforces the one-command bridge
  migration for setup-bag menu actions and blocks unsupported legacy burst
  patterns.
- `tools/tests/live/test-runtime-sync.ps1`: read-only live-runtime check that
  confirms deployed Jay's Patch datapack files, Melius command overlays, and
  Jay-owned FancyMenu files match the source tree after a deploy or reload.
- `tools/tests/live/new-kept-systems-test-report.ps1`: read-only live preflight
  helper that runs runtime sync, runtime FancyMenu command coverage, recent log
  scanning, player-list evidence, client/server UI dependency comparison, and
  source safety, then writes a dated Markdown report under
  `docs/project-notes/live-test-reports/`.
- `tools/tests/live/compare-ui-client-mods.ps1`: read-only comparison of the
  server's FancyMenu, SpiffyHUD, Konkrete, Melody, and Melius Commands jars
  against a client `mods` folder by filename, size, and SHA1.
- `tools/tests/live/watch-fancymenu-errors.ps1`: bounded read-only Docker log
  scan for FancyMenu codec errors, spam-kick lines, disconnects, and connection
  resets during live menu testing. It does not follow logs indefinitely and does
  not mutate server state.

## Rule

Sybillian's `ct:` namespace stays upstream-owned. Jay's Patch should call,
wrap, or read Sybillian behavior from `botc_patch` instead of editing `ct:`
files directly.

