# Integration Map

Use this map before changing commands, Sybillian wrappers, or menu actions.
For exact generated command references, use `generated/command-index.md`.

## Public Command Surfaces

| Surface | Status | Source | Purpose |
| --- | --- | --- | --- |
| `/botc` | Jay's Patch custom/manual surface, plus compatibility fallbacks. | `melius-commands/commands/botc.json` | Queue, votekick, music, grimoire reveal, winner reveal, setup-only Jay's Patch toggles, and other Jay-owned custom features. Sybillian-style FancyMenu game/setup actions should prefer `/st`, `/setupbag`, `/settings`, `/tpchurch`, `/tpallhome`, and `/request_chat`. Setup exceptions are limited to stale-client setup bag compatibility aliases: `/botc setup preset <script>`, `/botc setup clear`, `/botc setup set_from_menu`, `/botc setup role_on <character>`, and `/botc setup role_off <character>`. |
| `/st` | Primary Sybillian-style Storyteller broker. | `melius-commands/commands/st.json` | Storyteller game-management actions run with server authority after `tag=storyteller` checks. |
| `/setupbag` | Primary setup-game broker. | `melius-commands/commands/setupbag.json` | Setup bag role toggles, presets, apply, and custom import. Setup actions require Storyteller state and phase `0`; high-impact preset/import/apply/clear paths route through narrow `botc_patch:setup/bridge/*` cooldown wrappers. |
| `/settings` | Sybillian-style Storyteller broker. | `melius-commands/commands/settings.json` | Clock speed setting with server authority after `tag=storyteller` checks. |
| `/tpchurch` | Sybillian-style Storyteller broker. | `melius-commands/commands/tpchurch.json` | Teleports Storyteller to church with server authority after `tag=storyteller` checks. |
| `/tpallhome` | Sybillian-style Storyteller broker. | `melius-commands/commands/tpallhome.json` | Teleports players home with server authority after `tag=storyteller` checks. |
| `/request_chat` | Player-facing compatibility surface. | `melius-commands/commands/request_chat.json` | Lets regular players toggle Sybillian Storyteller chat requests from FancyMenu. |
| `/character` | Player-facing Sybillian compatibility surface. | `melius-commands/commands/character.json` | During an active game, lets the standard and Traveler personal-grimoire role pickers update only the caller's FancyMenu display through `ct:cmd/character`. It does not mutate server role scores, alignment, teams, or Jay's reveal snapshot. |
| `/botc grimoire confirm`, `change_characters`, `edit_seat`, `set_character`, `set_good`, `set_evil`, `announce_alhadikhia`, `announce_alhadikhia_seat`, `rescind_confirm`, `rescind` | Pre-reveal Storyteller editor, contextual announcements, and accidental-start rollback. | `melius-commands/commands/botc.json`, `botc_patch:grim/confirm`, `botc_patch:grim/editor/*`, `botc_patch:grim/alhadikhia/*`, `botc_patch:grim/rescind*` | Uses Sybillian's stored seat names and current script through guarded server-side dialogs. Role changes update cached reveal state and the acting Storyteller display; alignment overrides remain reveal-only. When Al-Hadikhia role `128` is in play, the target picker passes a selected game-start player name to upstream `ct:cmd/alhadikhia/announce`. Reveal Grimoire may be rescinded only before a role or winner is publicly revealed; rollback restores the captured phase, daytime, daylight-cycle state, and vote-marker visibility without resetting the game or cached character edits. Every edit and contextual announcement path locks when the Storyteller confirms and starts Reveal Grimoire. |
| `/botc vote-kick`, `/botc vote-remove` | Public Jay's Patch surface. | `melius-commands/commands/botc.json`, `botc_patch:vote/*` | Starts/casts/removes a votekick vote. The actual `kick` happens inside the datapack after strict majority succeeds. |
| `/botc patch_toggle <mode>` | Setup-only Storyteller Jay's Patch surface. | `melius-commands/commands/botc.json`, `botc_patch:patch_toggle/*` | Lets the Storyteller switch between Jay's setup bag, Sybillian's setup bag, or minimal Jay-held items. Every branch is phase `0` and `tag=storyteller` guarded before server-authority execution. |

## Sybillian Behavior Jay's Patch Wraps

| Behavior | Sybillian function family | Jay's Patch entrypoint |
| --- | --- | --- |
| Start game | `ct:start_game/*` | `/st start`, `/st reveal_roles`, manual `/botc` compatibility fallbacks |
| Setup apply/import | `ct:admin/setup/*` | `/setupbag`, `botc_patch:setup/bridge/*`, `botc_patch:setup/*` |
| Advance phase | `ct:item/advance_phase` | `/st advance_phase`, manual `/botc` compatibility fallback |
| Timer | `ct:loop/timer/start` | `/st timer`, manual `/botc` compatibility fallback |
| Reset game | `ct:admin/reset_game` | `botc_patch:cmd/reset_game`, `botc_patch:reset/player_state` |
| Nominations/executions | `ct:admin/nomination`, `ct:kill/*` | `/st`, manual `/botc` compatibility fallbacks |
| Teleports | `ct:cmd/tpchurch`, `ct:cmd/tpallhome`, Sybillian house markers | `/st tphouse`, `/tpchurch`, `/tpallhome`, and Jay's night-only Evil Team selector. The Evil Team item offers Demon Only, Minions Only, or Demon + Minions. Selected evil players are placed in seat order on distinct jungle-stair seats, alternating across the church aisle and supporting up to 15 players for Legion-style games. Every assigned player faces the acting Storyteller at the dedicated church-door vantage point. Teleport Home preserves Sybillian's `tag=!in_house` rule, so it skips a player inside any recognized house zone, not only that player's assigned house. |
| Chat requests | `ct:cmd/request_chat/*` | `/request_chat`, FancyMenu chat buttons |
| Storyteller state | `ct:cmd/storyteller/*` | `botc_patch:storyteller/*` |
| Role display toggles | FancyMenu `p<seat>_role` variables and `ct:cmd/character` | Player personal-grimoire layouts call active-game `/character`, which remains display-only. The Storyteller's upstream picker is client-local and does not call `/character`; Jay's guarded Change Characters editor owns server-authoritative reveal edits and refreshes only the acting Storyteller's matching FancyMenu variable. |

## Rule

For setup-game behavior, prefer Sybillian-style `/setupbag` commands. For
Storyteller game-management behavior, prefer Sybillian-style `/st`, `/settings`,
`/tpchurch`, and `/tpallhome` broker commands. Keep `/request_chat` and
`/character` as explicit player-facing compatibility surfaces.
Keep `/botc` for Jay-owned custom features and manual compatibility fallbacks,
not as the default FancyMenu route for Sybillian actions.

Run `tools/tests/test-command-overlays.ps1` after command-overlay edits. It verifies
that privileged Storyteller commands keep the `tag=storyteller` guard and run
as server-authority commands while leaving public help/music/queue/vote and
request-chat commands available.

Jay's Patch does not own or deploy FancyMenu layout files. Those layouts are
client-side Sybillian content and cannot be made reliable for unchanged clients
by copying them into the server configuration. Keep server-bound compatibility
at the guarded Melius command roots above. Use
`tools/tests/live/audit-runtime-fancymenu-buttons.ps1` only as a read-only
diagnostic of the currently installed upstream layouts.

Use `docs/project-notes/fancymenu-stability-test-matrix.md` before any live
FancyMenu stability testing. It records the version evidence to collect and the
order of isolation tests, so codec/spam-kick fixes are based on evidence.

Votekick requires `function-permission-level=3` in `server.properties`; the
launcher deploy step enforces it. Do not raise this to level 4 unless a proven
feature needs level-4-only commands.


