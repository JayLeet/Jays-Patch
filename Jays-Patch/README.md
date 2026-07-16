# Jay's Patch

Jay's Patch is the server-side add-on for this BOTC server.

## Evidence

- The Minecraft namespace is `botc_patch`.
- `/botc` remains the Jay's Patch namespace for non-setup custom features.
- Sybillian-style command roots such as `/st`, `/setupbag`, `/settings`,
  `/tpchurch`, and `/tpallhome` are the Storyteller/setup broker surfaces.
- `/character` is the active-game player-facing personal-grimoire display
  bridge. Storyteller role edits use Jay's guarded Change Characters flow.
- The datapack source is `Jays-Patch/datapack`.
- The Melius command overlay source is `Jays-Patch/melius-commands`.
- The resource-pack overlay source is `Jays-Patch/resourcepack`.
- Server-list branding assets live in `Jays-Patch/server-root`.
- Startup can build `Jays-Patch/dist/Jays-Patch-resourcepack.zip` from that
  overlay for local checks. Public package builds must bundle the exact hosted
  resource-pack archive from the configured `resource-pack` URL.
- `Jays-Patch/dist` is disposable build output.
- The cleaned shareable world template lives at `Jays-Patch/world-template`.
- `Jays-Patch/world-template-manifest.json` binds that ignored binary world to
  the source release with file hashes; refresh it intentionally after verified
  map changes.
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
truth. The datapack deploys to `data/world/datapacks/jays_patch`, while
Melius commands and resource-pack files deploy into their matching `data`
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
finished archive. The package keeps the ordered installation guide separate
from the raw server-properties snippet and includes prominent upstream credits
plus Sybillian's exact MIT license. It also verifies the tracked world-template
manifest before copying the world. Refresh the source baseline with
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

Hosted pack URL, SHA1, cache UUID, optional/required state, and installation
prompt are owned by
`Jays-Patch/server-config/jays-patch-required-server-properties.txt`.
BOTC.exe reads that file instead of carrying another hardcoded URL or UUID. Its
local diagnostic ZIP is separate from the exact hosted fallback and pack drift
is decided by extracted file contents, not ZIP metadata.

Current owned behavior:

- `/botc` non-setup Jay's Patch command bridge.
- Server-authority Sybillian-style Storyteller/setup brokers through Melius.
- Raise/lower hand item cleanup and seat lamps.
- Banshee activation through the Storyteller's pre-reveal controls, with
  Sybillian's announcement reused directly, reusable dead votes, and a
  nomination-phase Banshee item that toggles each YES vote between x1 and x2.
  The default is x1; the second-nomination allowance remains Storyteller
  managed because Sybillian 1.5.4 does not track the nominator server-side.
- Delayed datapack startup repair for Sybillian/YAWP flags, reset, and regions
  on hosted servers that do not use `BOTC.exe`; this uses Jay-owned macro
  wrappers because Sybillian's direct `yawp ...` functions can fail to parse
  before YAWP's config has loaded.
- First-install server-properties notice that points joining players to
  `world/datapacks/jays_patch/jays-patch-required-server-properties.txt` until
  the server owner disables it with the clickable setup-notice trigger.
- Storyteller queue promotion and handoff cleanup.
- Good/evil winner reveal, temporary heads, cleanup timer, and five distinct
  alignment-colored victory fireworks per winner. Marked fireworks survive
  normal game reset and are removed only when the next supported game begins;
  an epoch check also cleans an offline winner when they next join.
- Night music selection from vanilla music events, with a per-player selector
  item for all 21 Minecraft 1.21.10 jukebox discs, six retained ambient tracks,
  mute, random selection, and pitch preference. Each player starts every night
  muted exactly once, including late joins or late seat assignments, and may
  then opt in for the rest of that night. The menu uses the matching disc or
  environment icon for every track.
- Live-game Storyteller tools for reset, phase advance, role-icon player
  teleports, church-stair-separated evil-team teleports facing the Storyteller,
  chair/home teleports, and night invisibility that follows
  Sybillian house detection. Jay's Patch can use the established item-first
  hotbar or a dialog-first dashboard; the dashboard routes to the same guarded
  confirmations, player pickers, and action submenus. Dynamic chair teleporting
  occurs only after an explicit Storyteller Teleport Seats action; Dawn and
  other phase transitions never move players to their seats automatically.
- Server-side grimoire reveal mode with role icons from Sybillian's textures
  and a seat snapshot so disconnects do not block already-started reveals. The
  pre-reveal confirmation offers a server-side character editor during active
  games, plus contextual upstream announcements for in-play roles. Al-Hadikhia
  target announcements use Sybillian's public sound, HUD, and chat sequence
  without pretending to implement the character's unresolved gameplay state.
  The active reveal menu also offers a confirmed rescind path before the first
  role or winner is shown. It restores the captured phase, time, daylight
  cycle, and vote-marker visibility without resetting the game or cached edits.
  Cancel Reveal is an explicit button; pressing Esc only closes the menu and
  leaves the reveal flow active. Dialog mode keeps a held Reset Game safety
  item in visual slot 1 while a reveal is active.
  Character changes preserve the seat's remembered reveal alignment; only the
  explicit Set Good and Set Evil controls change alignment. The editor makes
  the current role prominent in its title and status, and also updates the
  acting Storyteller's Sybillian FancyMenu grimoire variable directly.
  Player-dialog names use white for readability, while each `(Role)` suffix is
  blue or red from the seat's effective alignment rather than its character
  category. Role buttons and Player `(Role)` buttons also include generated
  bitmap-font role icons. General controls and music tracks use the separate
  generated `botc_patch:ui_icons` font. Both glyph mappings are deterministic,
  while the role mapping remains keyed by Sybillian role
  score so resource-pack and datapack generators cannot reorder existing icons.
  Confirming Reveal Grimoire applies those edits to the final snapshot, locks
  further editing, and labels each reveal button as `Player (Role)` with a white
  player name and alignment-colored role suffix before the
  cinematic reveal begins.
- Setup-only Toggle Jay's Patch item with four explicit states: Jay's item-first
  mode, Jay's dialog-first mode, Sybillian's original setup bag, and Jay-held
  items disabled. The two non-Jay modes warn in bold red that OP is required.
  Reset Game, Become a Player, the Setup Bag, and setup-room controls remain
  held during setup in both Jay modes. Storyteller's Passage, Storyteller
  Tools, and temporary nomination action items remain held during active games
  where that interaction is safer or clearer.
- A versioned one-time configuration migration that establishes the documented
  fresh-install toggle state without overwriting later user choices on reload.
- In-place reset and online player-state cleanup. A supported 5-15 player game
  start fully clears active non-Storyteller, non-spectator inventories before
  Sybillian rebuilds their new-game inventory; Storyteller and spectator
  inventories are not broadly cleared.

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
- The launcher excludes only Jay-owned Melius command filenames from Modrinth
  overwrite handling. It records those filenames in an ownership manifest,
  removes only previously Jay-owned files that were retired, and preserves every
  unrelated Sybillian command. Jay's Patch no longer deploys server-side
  FancyMenu customization files because those layouts are client-owned.
- Generated text source and generated indexes use deterministic LF on every
  operating system; Windows `.bat` and `.cmd` entrypoints remain CRLF.
