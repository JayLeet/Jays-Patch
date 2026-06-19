# BOTC Update Preservation

Last updated: 2026-06-19

## Evidence

- This server uses the Modrinth BOTC pack in `compose.yml`.
- `MODRINTH_FORCE_SYNCHRONIZE` is currently `false`, which reduces update
  overwrite risk but does not make custom edits permanent.
- The custom code lives mostly inside the pack-owned datapack path:
  `data/resources/datapack/required/ct`.
- Command blocks, signs, YAWP live state, and map edits live inside
  `data/world`, not in the datapack files.

## Inference

A modpack update can overwrite pack-owned files if the updater replaces the
datapack or config folders. Git protects the code/config edits, but Git does
not protect the live world because the world is private and too large to track
normally.

## Recommendation

Before any modpack update:

1. Save the server.
2. Make a world backup from `data/world`.
3. Commit or copy all custom code/config files.
4. Update the Modrinth version in `compose.yml`.
5. Start the server and check whether custom files were overwritten.
6. If needed, restore custom files from Git or from the backup.
7. Run `reload`.
8. Run:

```mcfunction
function ct:admin/init/yawp_reset
function ct:admin/init/yawp_regions
```

## Custom File Areas

These areas contain custom work and must be preserved across updates:

```text
compose.yml
startup-script.ps1
BOTC-command-block-notes.md
BOTC-update-preservation.md
data/resources/datapack/required/ct/data/ct/function/admin/init/
data/resources/datapack/required/ct/data/ct/function/admin/music/
data/resources/datapack/required/ct/data/ct/function/admin/winner/
data/resources/datapack/required/ct/data/ct/function/setup_sign/
data/resources/datapack/required/ct/data/ct/function/loop/root.mcfunction
data/resources/datapack/required/ct/data/ct/function/admin/init/root.mcfunction
data/resources/datapack/required/ct/data/ct/function/start_game/setup.mcfunction
data/resources/datapack/required/ct/data/ct/function/phase/
data/resources/datapack/required/ct/data/ct/function/util/send_tutorial.mcfunction
```

## World-Only Custom Work

These are not protected by Git. They are preserved only by backing up
`data/world`.

- Town square good/evil winner button command blocks.
- Winner timer command blocks.
- Setup signs beside the grimoire.
- Command blocks for raise/lower hand and storyteller button access.
- Built/decorated map changes.

## Important Caution

Do not set `MODRINTH_FORCE_SYNCHRONIZE` to `true` unless a fresh world backup
and Git commit already exist. Forced sync is much more likely to remove local
pack edits.
