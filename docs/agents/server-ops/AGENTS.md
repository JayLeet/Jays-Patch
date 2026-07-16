# Server Ops Shelf

Use this shelf for the standalone launcher, Docker, backups, RCON, server properties,
resource-pack enforcement, reloads, restarts, logs, and operational safety.

## Source Routes

- User-facing setup: `README.md`
- Launcher entrypoint/source: `launcher/exe/BotcLauncher.cs` and focused
  companion sources under `launcher/exe/*.cs`
- Launcher smoke check: `tools/tests/test-startup-scripts.ps1`
- Source-only safety gate: `tools/tests/test-source-safety.ps1`
- Source ownership check: `tools/tests/test-source-ownership.ps1`
- Live data-root guard: `tools/tests/test-data-root.ps1`
- Runtime sync check: `tools/tests/live/test-runtime-sync.ps1`
- Docker config: `launcher/compose.yml`
- Editable launcher/server branding: `launcher/branding.txt`
- Minecraft server icon and EXE icon source: `data/server-icon.png`
- Backup/update notes: `docs/project-notes/update-preservation.md`
- Private local settings example: `launcher/local-settings.example.properties`

## Rules

- The live server data folder is `data` inside the repo root, mounted as
  `/data` inside the Docker container. Never create or use a sibling
  `../data` folder.
- `BOTC.exe` deploys Jay's Patch before startup and syncs it again after
  Minecraft is ready. This second sync restores Jay-owned command files without
  deleting unrelated Sybillian Melius commands. Jay's Patch does not deploy
  server-side FancyMenu customization files.
- Keep the Minecraft server image in `launcher/compose.yml` pinned to a tested
  immutable SHA-256 digest. Update that digest deliberately, then rerun Compose
  parsing, launcher smoke tests, and the clean-install/release checks; do not
  drift back to a floating `latest` tag.
- Preserve `data/world`, `Jays-Patch`, docs, the standalone launcher source,
  `data/server-icon.png`, ops/ban/whitelist files, resource-pack settings,
  and voice config through updates.
- After command-block cleanup, preserve `Jays-Patch/world-template` as the
  shareable clean world source.
- Keep `Jays-Patch/world-template-manifest.json` current through
  `tools/update-world-template-manifest.ps1`; public builds must refuse an
  unreviewed world-template change.
- After verified live map changes, refresh `Jays-Patch/world-template` from a
  stopped, isolated clone of `data/world`. Reset that clone to pre-game state,
  remove private player/runtime data and development artifacts, then update the
  manifest. Never package the actively written live folder or assume an older
  template contains the newest map.
- Treat `Jays-Patch/dist` as disposable build output.
- Treat `Jays-Patch/version.txt` as the only public-package version source.
- Refresh `Jays-Patch/source-baseline.json` only through
  `tools/update-source-baseline.ps1`, after its non-live checks pass.
- Build public packages only through `tools/build-public-package.ps1`; the
  finished ZIP must contain and pass its SHA-256 `PACKAGE-MANIFEST.json`.
  Public builds must also use the reviewed guide and credits under
  `Jays-Patch/public-package`, including Sybillian's preserved MIT license.
- `backups/standard` is updated only after Jay confirms the stop-time backup
  prompt or explicitly types `backup` in BOTC.exe. Both paths must flush saves,
  restore `save-on`, and use rollback-safe staging promotion. Do not reintroduce
  the retired `backups/latest` promotion flow.
- `restart` restarts only Minecraft Compose service `mc`, keeps Playit and
  Docker Desktop running, waits for readiness, and runs BOTC Final Sync.
- Do not stop, restart, reload, or mutate live server state unless the task
  requires it or Jay asks.
- Use RCON for targeted checks when needed, but avoid broad world mutations.
- Never expose private values from `launcher/local-settings.properties`, server secrets,
  player UUID files, logs, or backups.

## Verification

- Launcher changes should be checked with `tools/tests/test-startup-scripts.ps1` and
  reviewed for expected control flow.
- Backup-path changes should include every custom source path that must survive
  Modrinth updates.
- If startup behavior changes, state whether Jay needs to restart the server.
- After manual deploys or suspected runtime drift, run
  `tools/tests/live/test-runtime-sync.ps1`; it is read-only but requires the
  live `data` server folder.
