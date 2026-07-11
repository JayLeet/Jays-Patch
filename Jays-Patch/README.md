# Jay's Patch

Jay's Patch is the server-side add-on for this BOTC server.

## Evidence

- The Minecraft namespace is `botc_patch`.
- `/botc` remains the Jay's Patch namespace for non-setup custom features.
- Sybillian-style command roots such as `/st`, `/setupbag`, `/settings`,
  `/tpchurch`, `/tpallhome`, and `/character` are the Storyteller/setup broker
  surfaces.
- The datapack source is `Jays-Patch/datapack`.
- The Melius command overlay source is `Jays-Patch/melius-commands`.
- The resource-pack overlay source is `Jays-Patch/resourcepack`.
- Server-list branding assets live in `Jays-Patch/server-root`.
- Startup can build `Jays-Patch/dist/Jays-Patch-resourcepack.zip` from that
  overlay for local checks. Public package builds must bundle the exact hosted
  resource-pack archive from the configured `resource-pack` URL.
- `Jays-Patch/dist` is disposable build output.
- The cleaned shareable world template lives at `Jays-Patch/world-template`.
- `Jays-Patch/version.txt` is the single semantic-version source for public
  package naming and manifests.
- `Jays-Patch/source-baseline.json` is the generated known-good hash manifest
  for owned source and build inputs. It intentionally excludes the live world,
  private settings, binaries, `world-template`, and `dist`.
- `Jays-Patch/upstream-contract.json` pins the supported Sybillian/Minecraft
  versions, role catalog, required objectives/data files, and upstream tokens
  that Jay's Patch depends on.

## Inference

This folder contains Jay-owned custom behavior plus the shareable world template.
The world template is based on Sybillian's original world, so Jay owns only
Jay's edits to that world, not the underlying Sybillian world. Sybillian's
Modrinth pack can update independently, and startup deploys this folder back
into the runtime `data` folder before the server starts.

## Recommendation

Edit this folder when adding or changing custom server behavior. Do not edit
runtime copies under the Docker-mounted server data folder as the source of
truth. The datapack deploys to `../data/world/datapacks/jays_patch`, while
Melius commands and resource-pack files deploy into their matching `../data`
runtime folders. Server-list branding deploys into the server data root.

## Guiding Rule

Sybillian's BOTC pack is the base system. Jay's Patch should borrow from it,
wrap it, and extend it instead of replacing it.

Escalate implementation complexity only when there is evidence it is needed:

1. Find another Sybillian-compatible workaround.
2. Use datapack and command overlays.
3. Add a server plugin only when datapack behavior becomes too awkward.
4. Build a full Fabric mod only as the last option.

When adding a feature, first look for the Sybillian `ct:` function, scoreboard,
tag, storage value, item, or entity that already represents the behavior. Call
or read that existing behavior from `botc_patch`, then add only the custom logic
Jay's Patch needs.

Good changes usually look like this:

- Run Sybillian code through a safe Jay's Patch command or function.
- Add custom cleanup, permissions, visuals, music, or timers afterward.
- Store Jay-owned behavior in the `botc_patch` namespace.
- Keep Sybillian-owned assets and logic referenced, not copied, when possible.
- Let non-op Storytellers run normal games without granting Storyteller-only
  permissions to players or spectators.

Avoid duplicating Sybillian systems unless there is no usable hook. Avoid editing
upstream `ct:` files directly. If an upstream edit is temporarily unavoidable,
document why it was needed and move it back into Jay's Patch as soon as there is
a clean path.

Role metadata is read from Sybillian's installed `set_from_menu` and
`characters` functions through `tools/lib/sybillian-role-catalog.ps1`.
Jay-owned base-script membership lives in `Jays-Patch/base-scripts.json`.
Generators should consume those sources instead of rebuilding role IDs,
display names, categories, or alignments independently.

Before a public build, `tools/build-public-package.ps1` runs the non-live source
gate, reads the version file, bundles the exact hosted resource pack, writes an
internal SHA-256 package manifest, creates a reproducible ZIP, and validates the
finished archive. Refresh the source baseline with
`tools/update-source-baseline.ps1` only after its prerequisite checks pass.
`tools/tests/test-upstream-contract.ps1` also verifies every direct `ct:`
function call still resolves against the installed Sybillian pack. Run an
isolated clean-install smoke test before publishing when the world template,
startup contract, upstream version, or package layout changes.

Keep `Jays-Patch/resourcepack` as a Jay-owned visual overlay. For Minecraft
1.21.10, Jay-owned carrot/paper visuals use `minecraft:custom_model_data`
strings through the root selector files
`assets/minecraft/items/carrot_on_a_stick.json` and
`assets/minecraft/items/paper.json`. Role art is generated from Sybillian's
installed `ct:role/...` textures into `assets/botc_patch/textures/item/role`
because direct `ct:` item-model references rendered as missing textures in the
client.

Players should load the Jay's Patch resource pack to see custom tool icons and
world-space grimoire/setup-room role icons. The server-side items keep
`custom_model_data` for both routing and visual selection. Startup serves the
public Jay's Patch pack URL through `BOTC_RESOURCE_PACK_URL`; the pack is
optional unless Jay explicitly changes `require-resource-pack`.

Current owned behavior:

- `/botc` non-setup Jay's Patch command bridge.
- Server-authority Sybillian-style Storyteller/setup brokers through Melius.
- Raise/lower hand item cleanup and seat lamps.
- Delayed datapack startup repair for Sybillian/YAWP flags, reset, and regions
  on hosted servers that do not use `BOTC.exe`; this uses Jay-owned macro
  wrappers because Sybillian's direct `yawp ...` functions can fail to parse
  before YAWP's config has loaded.
- First-install server-properties notice that points joining players to
  `world/datapacks/jays_patch/jays-patch-required-server-properties.txt` until
  the server owner disables it with the clickable setup-notice trigger.
- Storyteller queue promotion and handoff cleanup.
- Good/evil winner reveal, temporary heads, and cleanup timer.
- Night music selection from vanilla music events, with a per-player selector
  item for manual tracks, mute, and pitch preference.
- Live-game Storyteller tools for reset, phase advance, role-icon player
  teleports, evil-team/chair/home teleports, and night invisibility that follows
  Sybillian house detection.
- Server-side grimoire reveal mode with role icons from Sybillian's textures
  and a seat snapshot so disconnects do not block already-started reveals. The
  pre-reveal confirmation offers a server-side character editor during active
  games. Character changes also update the acting Storyteller's Sybillian
  FancyMenu grimoire variable directly. Confirming Reveal Grimoire applies
  those edits to the final snapshot, locks further editing, and labels each
  reveal button as `Player (Role)` before the cinematic reveal begins.
- Setup-only Toggle Jay's Patch item that can use Sybillian's original setup
  bag, disable Jay-held items except Toggle Jay's Patch and Reveal Grimoire, or
  re-enable all Jay-held items.
- A versioned one-time configuration migration that establishes the documented
  fresh-install toggle state without overwriting later user choices on reload.
- In-place reset and online player-state cleanup.

Current migration state:

- Command blocks have been removed from the live world and from
  `Jays-Patch/world-template`.
- Use Sybillian-style Storyteller commands for normal game management and
  setup. Keep `/botc` for Jay-owned non-setup features such as queue, votekick,
  music, grimoire reveal, and winner reveal.
- Use `Jays-Patch/world-template` as the shareable clean world and manual
  recovery source.
- Normal `/botc reset_game` does not stop or restart the server. It calls
  Sybillian reset behavior and returns online users to normal player state so
  another player can become Storyteller next.
- The launcher excludes the deployed command and FancyMenu customization folders
  from Modrinth overwrite handling; otherwise a plain restart can restore
  Sybillian's stock config over Jay's Patch.
