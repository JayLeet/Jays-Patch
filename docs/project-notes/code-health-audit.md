# Code Health Audit

## Evidence

- `Jays-Patch` is the source of truth for custom BOTC behavior.
- The working tree is already in a large staged/modified migration state, so `git diff` mixes older feature work with current cleanup.
- The largest `Jays-Patch` files are mostly config or data-table style files:
  - FancyMenu text/config files.
  - resource-pack item model mappings.
  - role-score to role-icon mappings.
  - night music variant mappings.
- Historical: `launcher/startup-script.ps1` was a real code hotspot at roughly 900 lines and owned several responsibilities: startup, backups, Docker readiness, Playit setup, resource-pack deploy, console behavior, and history logging. It has since been retired in favor of the standalone `BOTC.exe` source at `launcher/exe/BotcLauncher.cs`.
- `give_raise_fallback.mcfunction`, `give_lower_fallback.mcfunction`, and `give_reveal_fallback.mcfunction` intentionally repeat inventory-slot checks because `.mcfunction` files cannot loop or parameterize item stacks like normal code.
- `hand/tick.mcfunction` and `grim/tick.mcfunction` contain the critical item-repair logic that protects Sybillian tools from being overwritten by Jay's Patch items.
- The dynamic seat generator and static checks now forbid phase-driven seat
  teleports. The live harness separately checks that Dawn leaves players where
  they are and that the guarded Storyteller Teleport Seats action still works.
- Generated documentation has a read-only freshness mode, generated source
  writes deterministic LF, Windows batch entrypoints retain CRLF, and source
  safety rejects adjacent duplicate `.mcfunction` commands.
- Public TAB config is neutral and checked for placeholder groups or player UUID
  entries. The Minecraft Docker image is pinned to the locally tested immutable
  digest rather than a floating tag.

## Inference

- The current highest-risk maintenance areas are not the largest files by line count, but files where hidden responsibilities or repeated logic can drift.
- The fallback item functions are acceptable as long files because they have one clear responsibility and Minecraft command syntax forces repetition.
- The standalone launcher source is still the startup hotspot to watch. Its
  data/config classes now live in `BotcLauncher.Models.cs`, and the build
  compiles all `launcher/exe/*.cs`; continue extracting only cohesive,
  independently testable responsibilities.
- Role metadata parsing is centralized in
  `tools/lib/sybillian-role-catalog.ps1`, while base-script membership is owned
  by `Jays-Patch/base-scripts.json`. Generator output was hash-compared before
  and after the refactor and remained identical.
- Public package drift is now blocked by a version source, source baseline,
  internal package hash manifest, reproducible ZIP creation, and post-build
  validation. The ignored binary world template now has a tracked release hash
  manifest as well.
- Code-library drift is now blocked by regenerating indexes into an isolated
  temporary directory and comparing them without mutating tracked docs.
- Active-game outsider cleanup is generation-gated instead of re-running its
  stale-role cleanup every tick for every spectator or mid-game joiner.
- Reset entrypoints now share `reset/game_state`, preventing winner, grimoire,
  nomination, and upstream reset behavior from drifting between wrappers.
- Resource-pack metadata is read from one canonical required-properties file;
  the launcher no longer duplicates the hosted URL or cache UUID.
- Removing or rewriting legacy command overlays such as `/st` and `/setupbag` may break Sybillian/FancyMenu compatibility unless tested with a non-op Storyteller client.

## Recommendation

- Keep the current comment-only datapack cleanup as the first safe slice.
- Before changing item repair logic again, read `hand/tick.mcfunction`, `grim/tick.mcfunction`, and the matching fallback function together.
- Before changing role icon behavior, treat `grim/reveal/spawn_from_score.mcfunction`, the grimoire seat snapshot functions, and the resource-pack item mappings as one system.
- Before changing music variety, treat `music/night.mcfunction`, `music/play_selected.mcfunction`, and `music/play_current_to_self.mcfunction` as generated-style tables. Keep random ranges aligned with their highest cases and keep default night music to real `minecraft:music.*` events unless Jay changes that rule.
- Treat future launcher refactors as a focused startup/recovery task with backup, update, Docker, Playit, resource-pack, and console smoke tests.
- Do not clean up Sybillian `ct:` internals directly. Wrap or call upstream behavior from `botc_patch`.

## Remaining Cleanup Candidates

- Continue splitting `launcher/exe/BotcLauncher.cs` only one cohesive area at a
  time; deployment/backup operations and console rendering are the next likely
  boundaries, but should not be mixed into gameplay work.
- Add a small generator or source table for repetitive inventory fallback functions if item variants keep growing.
- Add a small generator or source table for role icon mappings if role-score changes become frequent.
- Audit legacy Melius command overlays after `/botc` fully covers the Storyteller flow.
- Keep `Jays-Patch/dist` treated as disposable build output only, not source of truth.
- Run the revised 5-15 player live seat harness at the next intentional server
  start; static validation cannot prove rendered world geometry or RCON phase
  behavior.
- Review and commit the large existing source migration as an intentional Git
  snapshot, then configure an off-device/private remote. Do not hide unrelated
  historical changes inside a cleanup commit.
