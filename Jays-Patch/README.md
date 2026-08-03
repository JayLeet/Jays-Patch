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
- Jay's Patch owns five explicitly pinned compatibility paths in the upstream
  namespace. Night Chat owns:
  `datapack/data/ct/function/loop/player/join_vc.mcfunction`. It is generated
  from the exact SHA-pinned Sybillian 1.5.4 router by
  `tools/generate-night-chat.ps1`. Four parse-safe YAWP startup shims are pinned
  by `Jays-Patch/yawp-compatibility.json`. Do not hand-edit the Night Chat
  router or add uncontracted `ct:` source.
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

Night Chat and YAWP startup parsing are the two narrow exceptions to the normal
namespace rule. The generated Night Chat router preserves every pinned 1.5.4
command and adds only a guard to its 25 voice-group join/leave commands while a
player has the Jay Night Chat tag. The four YAWP shims preserve Sybillian's
exact command sequences but defer them to macro functions after YAWP config is
available. Tests fail closed if either pinned upstream surface changes.

Role metadata is read from Sybillian's installed `set_from_menu` and
`characters` functions through `tools/lib/sybillian-role-catalog.ps1`.
Jay-owned base-script membership lives in `Jays-Patch/base-scripts.json`.
Jay-owned backported role metadata lives in `Jays-Patch/role-extensions.json`.
Generators should consume those sources instead of rebuilding role IDs,
display names, categories, or alignments independently. The upstream contract
continues to validate Sybillian's 137-role catalog separately so a Jay-owned
extension cannot hide upstream drift.
Organ Grinder remains in that trusted metadata so old state can still be
identified, but Jay's Patch excludes it from setup, Buffet, and character
selection while the server targets Sybillian 1.5.4, where the role is
unsupported.

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

## Player-facing formatting

Keep normal feedback short and predictable:

- A failed action or hard blocker starts with a bold red `!`. The explanation
  is gray, with only the player, role, item, setting, or action that needs
  attention highlighted.
- An ordinary completed action starts with a bold green `✔`. The explanation
  is gray, with the changed value highlighted when that helps.
- Dialog titles are headings and may be bold. Ordinary buttons, navigation,
  category labels, item names, and supporting text are not bold by default.
- Long dialog instructions use short labeled lines with meaningful colors and
  line breaks. Do not hide several status meanings inside one gray paragraph.
- Color carries meaning: red for errors or destructive actions, green for
  completion, yellow for warnings or choices needing attention, and gray for
  supporting words.
- Cinematic titles, role announcements, winner reveals, voting sequences,
  exact jinx rules, and other formats that carry game meaning stay
  feature-owned. Do not force a generic prefix onto them.

Write from what the player sees. Say what happened and what they can do next;
avoid implementation terms such as storage, dispatch, validation, or internal
phase names in player-facing text.

Use BOTC's game language consistently in visible text: say `character` instead
of `role`, `actual character` and `shown character` instead of `perceived role`,
and `Final Three` instead of `Final 3` or `final-three`. Engineering comments,
score names, and source documentation may keep precise internal terms.

Current owned behavior:

- `/botc` non-setup Jay's Patch command bridge.
- Server-authority Sybillian-style Storyteller/setup brokers through Melius.
- Raise/lower hand item cleanup and seat lamps.
- Banshee activation through the Storyteller's pre-reveal controls, with
  Sybillian's announcement reused directly. The Storyteller may confirm the
  Demon-caused death while the Banshee is still alive in server state, before
  deaths are publicly applied at day. The active Banshee gets reusable dead
  votes and a nomination-phase item that toggles each YES vote between x1 and
  x2. The default is x1; the second-nomination allowance remains Storyteller
  managed because Sybillian 1.5.4 does not track the nominator server-side.
- Wraith backport as Jay-owned role `325`. During night, a living seated Wraith
  can keep their Sight Closed, Peek from their assigned house, or open their
  Eyes and follow a Storyteller into player houses. Peek privately identifies
  the visited player. Eyes Open hides the Wraith in spectator mode for a Good
  visit and makes them visible in adventure mode on an exact 7% discovery roll.
  The Good player who catches the Wraith receives a private, noticeable sound
  cue; Evil visits are always visible in adventure mode. Leaving the visited
  house deliberately returns the Wraith home in Peek mode. When the Storyteller
  leaves, the Wraith returns home while Eyes Open remains armed. Night Chat is
  suspended during an Eyes Open visit, and reset, reconnect, role loss, death,
  invalid seating, or night end clean up the state.
- Spy and Widow true-Grimoire controls inside Grimoire Tools. At night, the
  Storyteller can refresh a living Spy's existing personal Grimoire with the
  real current roles. The same control is available to a living Widow only on
  the first night. This updates the player's private Sybillian Grimoire instead
  of giving them a second custom book.
- Delayed datapack startup repair for Sybillian/YAWP flags, reset, and regions
  on hosted servers that do not use `BOTC.exe`; this uses Jay-owned macro
  wrappers because Sybillian's direct `yawp ...` functions can fail to parse
  before YAWP's config has loaded. Four SHA-pinned `ct:` compatibility shims
  prevent those upstream startup functions from failing during initial datapack
  parsing while preserving their behavior after startup.
- First-install server-properties notice that points joining players to
  `world/datapacks/jays_patch/jays-patch-required-server-properties.txt` until
  the server owner disables it with the clickable setup-notice trigger.
- Storyteller queue promotion and handoff cleanup.
- Good/evil winner reveal, temporary heads, cleanup timer, and five distinct
  alignment-colored victory fireworks per winner. They use server-routed
  right-click-in-air launchers so Sybillian's global YAWP block-use protection
  remains intact. Marked fireworks survive normal game reset and are removed
  only when the next supported game begins; an epoch check also cleans an
  offline winner when they next join.
- Night music selection from vanilla music events, with a per-player selector
  item for all 21 Minecraft 1.21.10 jukebox discs, six retained ambient tracks,
  mute, random selection, and pitch preference. Each player starts every night
  muted exactly once, including late joins or late seat assignments, and may
  then opt in for the rest of that night. The menu uses the matching disc or
  environment icon for every track.
- Live-game Storyteller tools for reset, phase advance, role-icon player
  teleports, church-stair-separated evil-team teleports facing the Storyteller,
  chair/home teleports, and night invisibility that leaves the Storyteller
  visible inside player houses and the Church of Miku. Jay's Patch can use the
  established item-first hotbar or a dialog-first dashboard; the dashboard
  routes to the same guarded
  confirmations, player pickers, and action submenus. Dynamic chair teleporting
  occurs only after an explicit Storyteller Teleport Seats action; Dawn and
  other phase transitions never move players to their seats automatically.
- Cerenovus-only Madness Execution through the nomination-phase Storyteller
  Tools menu. The action requires a second confirmation, accepts any alive
  seated player, cancels transient vote machinery, and reuses Sybillian's
  mark, execute, and death functions exactly once. Because the target is
  already dead, the resulting post-execution controls omit the redundant Kill
  action.
- Nomination-phase ordinary Kill access for role-caused deaths such as a Golem
  punch or Witch kill. This route calls Sybillian's normal death function
  without changing the current nomination, vote, execution mark, or executed
  player.
- A server-authority `Start RPS` control inside Grimoire Tools. It remains
  available as a general game even without a Psychopath, lists only living
  seated players who already chose Rock, Paper, or Scissors, and then delegates
  the countdown, reveal, and cleanup to Sybillian's existing `ct:rps/*` flow.
- Before an executed Boomdandy commits, the initiating Storyteller chooses
  between Jay's unique pyre followed by Final Three and Sybillian's normal
  execution plus immediate death while the game continues. Closing the choice
  commits neither path; Storyteller tools reopen it and phase advance remains
  blocked until the choice is resolved. The separate pyre execution replaces
  Sybillian's lightning with
  twelve harmless TNT block displays that rain across the Town Square and
  visibly accelerate under gravity before exploding one by one over about five
  seconds. Every impact increases
  its smoke, flame, spark, and firework density; later impacts add bright flares and
  explosion emitters, and the twelfth falls into the exact center of the pyre
  before ending with the largest layered shockwave.
  The Boomdandy remains
  alive and the pyre remains lit until the twelfth impact; that last explosion
  extinguishes the pyre, then the Boomdandy dies through Sybillian's standard
  death function before the guarded Final Three flow opens. The rain cannot damage
  blocks, players, or entities; phase advance and Final Three stay locked until
  death resolves, and an offline Boomdandy is killed when they return rather
  than before the final impact. The Storyteller then selects and confirms
  exactly three living players. Every other
  chair disappears, non-finalists die one at a time with 1.5 seconds between
  deaths, and a typewriter warning explains the final vote before Sybillian's
  countdown starts. The three finalists vote by standing near a remaining
  player's seat, and the title card explicitly names the seat as the voting
  target; a strict majority kills that player, while a tie kills nobody. The
  selection blocks while a game-start player is offline and safely aborts if
  one of the confirmed finalists dies or disconnects.
- One-time Storyteller role notifications for in-play Fearmonger, Banshee,
  Al-Hadikhia, Cerenovus madness execution, and Boomdandy actions. A pending
  action adds a red-circle/white-exclamation trail to Storyteller Tools,
  Grimoire Tools, and the relevant role icon. Opening each menu clears only
  that menu's badge; using the role action clears its role badge until the next
  game. Fearmonger, Banshee, and Al-Hadikhia are night-only, Cerenovus is
  nomination-only, and Boomdandy is post-execution-only.
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
  the current character prominent in its title and status, and also updates the
  acting Storyteller's Sybillian FancyMenu grimoire variable directly.
  During any night, every Storyteller can open the supported Demon selection
  path from Change Characters. The Storyteller chooses when to use it; the
  server does not automatically open a Summoner prompt on night three. The
  path changes the selected player's live role and evil alignment, and Lil'
  Monsta continues into its validated direct-Minion assignment.
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
  items disabled. The two non-Jay modes use the shared error format to explain
  that OP is required.
  Reset Game, Become a Player, the Setup Bag, and setup-room controls remain
  held during setup in both Jay modes. Storyteller's Passage, Storyteller
  Tools, and temporary nomination action items remain held during active games
  where that interaction is safer or clearer.
- Beta Greedy Whalebuffet and Draft Buffet setup modes under Jay's Setup Bag.
  Greedy supports parallel player preferences, late setup joins, Dealer's
  Choice, private Storyteller assignment, and final legality checks. Its review
  surfaces identify the exact pending submission, resubmission, missing
  assignment, or assignment/picks mismatch instead of collapsing them into a
  generic warning. Buffet rebuilds public player labels and complete head
  profiles from its stable roster after start and seat changes. Draft
  locks and randomizes the roster, chooses each player's turn privately and at
  random, and uses 3/2/1 offers. Each card chooses uniformly among the legal,
  nonempty character types; a type closes only when the target no longer accepts
  it. Characters then use the accepted equal-base and `4/2/1` archetype tickets,
  reset for every fresh hand. Normal Draft makes one 90/10 ordinary-versus-real-
  special roll, while Atheist Draft is chosen privately by the Storyteller.
  Hidden special-looking presentations use the same sequential one-card UI as
  real special starts. Discarded direct characters return only to fill an exact
  shortfall when a still-required type cannot supply the next complete hand;
  there is no general recycling mode. Legion may replace
  the Draft's baseline Outsider count when forming its majority, but preserves
  deliberate positive Storyteller Outsider additions as a minimum floor.
  Automatic Drafts remain strict. After a private final-character override,
  unsafe counts, required seating, dependencies, and setup restrictions become a clear
  Storyteller-only warning with an explicit `Start Anyway`; incomplete seats,
  offline players, active setup prompts, and disabled roles remain blocked.
  The overridden shown character stays private until game start. Both modes hand
  the validated result back to Sybillian's normal start flow. During either setup,
  the Storyteller's setup bag is replaced with Reset Game, which keeps the
  normal confirmation before clearing the Buffet. Their generators
  consume `buffet-rules.json` and the versioned official jinx snapshot instead
  of duplicating character data. Expanded live Draft QA covers thirty ordinary
  games, at least ten of each real special result, every Atheist Outsider target
  twice, and 2,000 natural route rolls. Public Djinn-sheet presentation remains
  a beta limitation.
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
  music, the `/botc fun` toybox, King and Vizier entrances, the `/botc slayer` practice shot,
  grimoire reveal, and winner reveal.
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
