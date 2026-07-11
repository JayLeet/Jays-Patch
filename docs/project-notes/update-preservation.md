# BOTC Update Preservation

Last updated: 2026-06-21

## Evidence

- `launcher/compose.yml` targets Sybillian's Modrinth BOTC pack version `1.5.4`.
- Jay's custom server code now lives in `Jays-Patch`, not inside Sybillian's
  `ct` datapack or FancyMenu files.
- `BOTC.exe` backs up the world and custom source before
  Docker checks the Modrinth pack, deploys `Jays-Patch` into the actual
  Docker-mounted server data folder, then syncs Jay's Patch again after
  Minecraft is ready.
- `.gitignore` ignores `data/`, so runtime pack files are not treated as custom
  source code anymore.
- The current live world is `../data/world` from the repo root, mounted as
  `/data/world` inside the container.
- The live world has been cleaned of command blocks and copied to
  `Jays-Patch/world-template`.

## Inference

The clean split is now:

- Sybillian owns the Modrinth pack files under the runtime server data folder,
  including the base world that Jay's world template builds on.
- Jay owns `Jays-Patch`, the standalone launcher source, docs, handmade assets,
  and Jay's edits to the current world. After command-block cleanup, the
  shareable world source should be `Jays-Patch/world-template`.
- Docker may update or rewrite pack-owned files, but the startup deploy step
  restores Jay's Patch before the server starts. The
  launcher also excludes Jay-owned command and FancyMenu runtime folders from
  Modrinth overwrite handling so plain pack refreshes do not silently restore
  stock Sybillian config over Jay's Patch.

That means future pack updates should be much easier to reason about. The main
remaining risk is live world state drifting from `Jays-Patch/world-template`
before a manual template promotion or recovery copy.

## Recommendation

Use `BOTC.exe` for normal startup and console access. If the server is already
online, it opens the console only. If the server is offline, it does the
important safety steps in this order:

1. Deploy `Jays-Patch` into the runtime server folder.
2. Start the Minecraft server.
3. Sync `Jays-Patch` again after Minecraft is ready, then reload and run the
   required YAWP region init functions.

After testing a good server state, type this in the launcher console:

```text
stop
```

The launcher asks whether to replace `backups/standard` before stopping. If Jay
answers `Y`, the launcher flushes Minecraft saves, writes the new backup through
a staging folder, atomically replaces `backups/standard`, and then stops the
server. If the backup fails, the server is not stopped. After Minecraft stops,
the launcher stops only helper services it recorded starting itself: Playit when
BOTC started the service, and Docker Desktop when BOTC opened it and no other
Docker containers are still running.

## Source Of Truth

Custom code should be edited here:

```text
Jays-Patch/datapack
Jays-Patch/melius-commands
Jays-Patch/resourcepack
Jays-Patch/world-template
BOTC.exe
launcher/compose.yml
launcher/exe
launcher/branding.txt
launcher/local-settings.example.properties
../data/server-icon.png
README.md
Start.bat
Console.bat
AGENTS.md
docs/
```

Runtime output is deployed under `../data` from the repo root, which is `/data`
inside the container. These files should not be hand-edited as the source of
truth:

```text
../data/world/datapacks/jays_patch
../data/config/melius-commands/commands/*.json
../data/config/fancymenu/customization/*.txt
../data/config/tab/*
../data/resources/resourcepack/required/Jays-Patch
../data/server-icon.png
../data/server.properties
```

Disposable build output may be regenerated and should not be preserved as
source:

```text
Jays-Patch/dist
```

Pack-owned upstream files should stay clean:

```text
../data/resources/datapack/required/ct
```

## Backup Slot

The launcher keeps one approved backup slot:

```text
backups/standard
```

`backups/standard` is the known-good baseline and is only replaced after Jay
confirms the stop-time backup prompt.

The slot contains:

```text
BOTC-world.zip
BOTC-custom-files.zip
BOTC-customizations.gitbundle
BOTC-backup.json
```

## World-Only Custom Work

These are preserved through `Jays-Patch/world-template` after cleanup and through
backups of `../data/world` during live operation:

- Built/decorated map changes.
- YAWP regions and live permission state.

The old setup signs beside the grimoire are retired and should not be preserved
in future world-template copies.

Known command blocks have been removed from the live world and the cleaned world
has been copied to `Jays-Patch/world-template`. Keep that template as the
shareable clean world and manual recovery source instead of preserving
command-block-era world state.

## Reset Flow

`/botc reset_game` calls Sybillian reset behavior, then Jay's Patch resets
online users back to normal player state. Normal reset is in-place: it does not
stop the server, restart Docker, or restore `../data/world` from
`Jays-Patch/world-template`.

`Jays-Patch/world-template` remains the clean world source for sharing the patch
or for manual recovery if the live world needs to be restored outside normal
game flow. Manual recovery should still be fail-safe: if a world restore cannot
be completed, leave the server stopped and surface a clear error instead of
continuing with a half-restored world.

## Update Rule

Sybillian's BOTC pack is the base system. Jay's Patch is an add-on layer that
borrows from Sybillian code, calls it, and extends it through Jay-owned code.

For new features, prefer this order:

1. Find the existing Sybillian `ct:` function, scoreboard, tag, storage value,
   item, entity, or resource-pack asset that already represents the behavior.
2. Look for a simple server-side workaround that preserves Sybillian behavior.
3. Call or read that existing behavior from `botc_patch`.
4. Add Jay's custom cleanup, permissions, visuals, music, timers, or menus in
   `Jays-Patch`.
5. Use a plugin only if datapack/command-overlay behavior becomes too awkward.
6. Use a full Fabric mod only as the last option.
7. Deploy the result through `BOTC.exe`.

Do not add custom code back into Sybillian's `ct` datapack or upstream
FancyMenu files as the source of truth. If an upstream edit is temporarily
unavoidable, document why it was needed and move it back into `Jays-Patch` as
soon as there is a clean path.

Run `tools/tests/test-source-ownership.ps1` during source-only stabilization or before
pack-update work. It verifies that Jay-owned datapack code stays in the
`botc_patch` namespace, that Sybillian `ct` assets are referenced rather than
copied, and that launcher overwrite exclusions still preserve Jay-owned runtime
overlays.

After deploying or when command/menu drift is suspected, run
`tools/tests/live/test-runtime-sync.ps1`. It is read-only and confirms the
deployed Jay's Patch datapack, Melius command overlays, and Jay-owned FancyMenu
files match source.

The launcher must keep these runtime folders protected from Modrinth overwrite
handling because Jay's Patch owns their deployed contents:

```text
config/fancymenu/customization
config/melius-commands/commands
```

For the Jay's Patch resource pack, `server.properties` should use the SHA1 of
the hosted zip URL, not necessarily the local rebuilt zip. Zip metadata can make
the local archive hash differ even when the extracted pack contents match.

Jay's Patch also owns these `server.properties` values:

- `function-permission-level=3`: lets the datapack run the successful votekick
  `kick` command without raising functions to full level 4.
- `spawn-protection=0`: leaves block-use protection to YAWP instead of vanilla
  spawn protection. This prevents non-op players from being blocked from valid
  YAWP-allowed doors or controls near the world spawn.

