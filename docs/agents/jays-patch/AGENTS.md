# Jay's Patch Shelf

Use this shelf for datapack functions, `/botc`, Melius command overlays,
Sybillian wrapping, and custom gameplay behavior.

## Source Routes

- Architecture summary: `Jays-Patch/README.md`
- Datapack source: `Jays-Patch/datapack`
- Command overlay source: `Jays-Patch/melius-commands`
- Code library: `docs/code-library/README.md`
- Runtime deployment output: `data/world/datapacks/jays_patch`,
  `data/config/melius-commands/commands`,
  `data/resources/resourcepack/required/Jays-Patch`
- Project notes: `docs/project-notes/`
- Retired setup-sign history: `docs/project-notes/command-block-notes.md`

## Rules

- Treat `Jays-Patch/` as source and the deployed copies under `data` as
  output.
- Prefer calling or wrapping Sybillian `ct:` behavior before duplicating it.
- Keep custom functions under namespace `botc_patch`.
- Keep Jay-owned non-setup features under `/botc`.
- Use Sybillian-style command roots such as `/st`, `/setupbag`, `/settings`,
  `/tpchurch`, and `/tpallhome` for Storyteller/setup broker paths when that
  better preserves upstream behavior.
- Keep `/character` player-facing and display-only during active games. Do not
  route Storyteller role mutations through it; use the guarded Change
  Characters editor.
- Classify UI/control work as server-side, client-side, or client-required
  before implementing. FancyMenu layout files are client-side; do not present
  them as reliable server-side controls unless every client will install the
  matching files.
- Do not edit Sybillian `ct:` files unless Jay explicitly approves it.
- Do not recreate retired setup-sign source, trigger objectives, or interaction
  entities. Players become Storyteller through the queue flow.
- Non-op Storytellers should receive only the permissions required to run a
  normal game. Players and spectators must not receive Storyteller-only powers
  unless they become Storyteller through an approved queue or admin path.
- When adding a new feature, identify the Sybillian scoreboards, tags, storage,
  entities, and functions it depends on before implementing.
- Before editing datapack functions, Melius overlays, or Sybillian wrapper calls,
  check the code library for related functions and command paths.
- Keep functions narrow and named by behavior.

## Verification

- Deploy source into the runtime folder before live testing.
- If a Jay-owned command overlay disappears after restart, check the exact-file
  exclusions in `launcher/compose.yml` and the launcher ownership manifest.
  Unrelated Sybillian Melius commands must remain upstream-owned and preserved.
- Run `/reload` after datapack changes.
- Check logs for parse errors, unknown functions, and command failures.
- Run `tools/tests/test-command-overlays.ps1` after Melius command-overlay changes.
- For player-facing behavior, test with fake players or an empty server first
  when practical.

