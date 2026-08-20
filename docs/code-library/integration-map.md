# Integration Map

Use this map before changing commands, Sybillian wrappers, or menu actions.
For exact generated command references, use `generated/command-index.md`.

## Public Command Surfaces

| Surface | Status | Source | Purpose |
| --- | --- | --- | --- |
| `/botc` | Jay's Patch custom/manual surface, plus compatibility fallbacks. | `melius-commands/commands/botc.json` | Queue, votekick, music, the Drunk fun item, the Slayer practice shot, grimoire reveal, winner reveal, setup-only Jay's Patch toggles, and other Jay-owned custom features. Sybillian-style FancyMenu game/setup actions should prefer `/st`, `/setupbag`, `/settings`, `/tpchurch`, `/tpallhome`, and `/request_chat`. Setup exceptions are limited to stale-client setup bag compatibility aliases: `/botc setup preset <script>`, `/botc setup clear`, `/botc setup set_from_menu`, `/botc setup role_on <character>`, and `/botc setup role_off <character>`. |
| `/st` | Primary Sybillian-style Storyteller broker. | `melius-commands/commands/st.json` | Storyteller game-management actions run with server authority after `tag=storyteller` checks. |
| `/setupbag` | Primary setup-game broker. | `melius-commands/commands/setupbag.json` | Setup bag role toggles, presets, apply, and custom import. Setup actions require Storyteller state and phase `0`; high-impact preset/import/apply/clear paths route through narrow `botc_patch:setup/bridge/*` cooldown wrappers. |
| `/settings` | Sybillian-style Storyteller broker. | `melius-commands/commands/settings.json` | Clock speed setting with server authority after `tag=storyteller` checks. |
| `/tpchurch` | Sybillian-style Storyteller broker. | `melius-commands/commands/tpchurch.json` | Teleports Storyteller to church with server authority after `tag=storyteller` checks. |
| `/tpallhome` | Sybillian-style Storyteller broker. | `melius-commands/commands/tpallhome.json` | Teleports players home with server authority after `tag=storyteller` checks. |
| `/request_chat` | Player-facing compatibility surface. | `melius-commands/commands/request_chat.json` | Lets regular players toggle Sybillian Storyteller chat requests from FancyMenu. |
| `/character` | Player-facing Sybillian compatibility surface. | `melius-commands/commands/character.json` | During an active game, lets the standard and Traveler personal-grimoire role pickers update only the caller's FancyMenu display through `ct:cmd/character`. It does not mutate server role scores, alignment, teams, or Jay's reveal snapshot. |
| `/botc grimoire confirm`, `change_characters`, `edit_seat`, `set_character`, `set_good`, `set_evil`, `announce_alhadikhia`, `announce_alhadikhia_seat`, `madness_execute*`, `rescind_confirm`, `rescind` | Pre-reveal Storyteller editor, contextual role actions, and accidental-start rollback. | `melius-commands/commands/botc.json`, `botc_patch:grim/confirm`, `botc_patch:grim/editor/*`, `botc_patch:grim/alhadikhia/*`, `botc_patch:storyteller_tools/madness_execution/*`, `botc_patch:grim/rescind*` | Uses Sybillian's stored seat names and current script through guarded server-side dialogs. Role changes update cached reveal state and the acting Storyteller display; alignment overrides remain reveal-only. When Al-Hadikhia role `128` is in play, the target picker passes a selected game-start player name to upstream `ct:cmd/alhadikhia/announce`. During nomination phase, an in-play Cerenovus role `100` exposes a separately confirmed alive-player execution route; it cancels transient voting and calls Sybillian mark, execute, and death behavior without requiring an existing execution mark. Reveal Grimoire may be rescinded only before a role or winner is publicly revealed; rollback restores the captured phase, daytime, daylight-cycle state, and vote-marker visibility without resetting the game or cached character edits. Every edit and contextual announcement path locks when the Storyteller confirms and starts Reveal Grimoire. |
| `/botc kill`, `/botc kill_player <seat>` | Guarded ordinary-death picker. | `melius-commands/commands/botc.json`, `botc_patch:storyteller_tools/kill_menu/*` | Available during day and nomination phases. It filters already-dead players and calls `ct:kill/die` exactly once without nominating, voting, marking, or executing the target. This is the Storyteller route for Golem, Witch, and similar role-caused deaths. |
| `/botc rps start`, `first <seat>`, `second <seat>` | Guarded two-player RPS picker. | `melius-commands/commands/botc.json`, `botc_patch:storyteller_tools/rps/*` | Grimoire Tools opens two private player pickers that only include living seated players with an existing Rock, Paper, or Scissors choice. After two distinct players are selected, Jay's Patch tags those participants and calls Sybillian's `ct:rps/start` exactly once. |
| `/botc boomdandy select <seat>`, `restart`, `confirm` | Guarded Boomdandy final-three flow. | `melius-commands/commands/botc.json`, `botc_patch:storyteller_tools/boomdandy/*` | Available only during nominations after the last executed player is proven to have role `107`. The Storyteller selects exactly three living players, confirms the destructive action, and only then starts Sybillian's Boomdandy countdown. Unresolved state is global so a replacement Storyteller can resume it. |
| `/trigger botc_buffet_action` | Private Greedy/Draft dialog action surface. | `botc_patch:buffet/handle_action`, `botc_patch:buffet/greedy/*`, `botc_patch:buffet/draft/*` | Server-owned action IDs route only after mode, setup-phase, roster, current-drafter, or Storyteller guards. Players never submit role IDs or seat authority directly. Greedy accepts normal preferences or Dealer's Choice; Draft preserves private 3/2/1 offers and Storyteller-only modifier/review actions. Successful starts build exact role storage, call Jay's guarded Sybillian start wrapper, and then apply the validated assignments. |
| `/botc vote-kick`, `/botc vote-remove` | Public Jay's Patch surface. | `melius-commands/commands/botc.json`, `botc_patch:vote/*` | Starts/casts/removes a votekick vote. The actual `kick` happens inside the datapack after strict majority succeeds. |
| `/botc fun <toy>`, `/botc king`, `/botc vizier <player>` | Cosmetic toybox and serialized dramatic entrances. | `melius-commands/commands/botc.json`, `botc_patch:fun/*`, `resourcepack/assets/minecraft/items/*.json` | Silly Juice adds two minutes of personal randomized moments alongside Slowness I: 24 particle variants persist for 40 ticks at one of 20 forward-view locations, paired with one of 24 personal sounds. Hot Potato rate-limits right-click attempts to once per second, gives each new holder Slowness I and Blindness I for two seconds, and uses a cursed redstone-block holder head that temporarily replaces and then exactly restores Sybillian death skulls, winner heads, or any other prior stack through generation-keyed storage. A successful passer receives Speed II and is excluded from receiving the Imp again for two seconds. Dice Roll is limited to once per player per minute. King gives a bluffable one-use item, is auto-awarded once to the real King on day one, and can only be activated while standing over Sybillian's warped-plank Town Square marker; rejected attempts keep the item. Vizier is Storyteller-only and itemless. Both entrances reveal their themed title card on the same tick as the final jingle and keep a tracked level-15 light at the claimant's head for their full four-second duration. The light follows every tick and is removed on finish, reload, or reset without replacing ordinary blocks. Temporary-night entrances restore exact time only if the game phase has not changed. |
| `/botc slayer`, `/botc slayer <player>` | Public Slayer practice shot with a guarded Storyteller handoff. | `melius-commands/commands/botc.json`, `botc_patch:fun/slayer/*`, `loot_table/fun/slayer.json`, `resourcepack/assets/minecraft/items/carrot_on_a_stick.json` | The no-argument form gives the caller a reusable-until-hit Slayer's Bow. The player argument uses the established online-player parser but runs only after `tag=storyteller`; it executes the same give function as the selected target. Each shot opens PvP for two seconds and replaces the pending reset. Misses and Storyteller contacts are silent and retain the bow; confirmed non-Storyteller hits attempt arrow damage, announce shooter and target publicly, consume one bow, and leave PvP to the scheduled fail-closed reset. |
| `/botc patch_toggle <mode>` | Setup-only Storyteller Jay's Patch surface. | `melius-commands/commands/botc.json`, `botc_patch:patch_toggle/*` | Lets the Storyteller switch between Jay's setup bag, Sybillian's setup bag, or minimal Jay-held items. Every branch is phase `0` and `tag=storyteller` guarded before server-authority execution. |

## Sybillian Behavior Jay's Patch Wraps

| Behavior | Sybillian function family | Jay's Patch entrypoint |
| --- | --- | --- |
| Start game | `ct:start_game/*` | `/st start`, `/st reveal_roles`, manual `/botc` compatibility fallbacks |
| Setup apply/import | `ct:admin/setup/*` | `/setupbag`, `botc_patch:setup/bridge/*`, `botc_patch:setup/*` |
| Buffet final handoff | `ct:script` storage, `ct:admin/setup/set_from_menu`, `ct:start_game/*` | `botc_patch:buffet/greedy/start/*`, `botc_patch:buffet/draft/start/*`, `botc_patch:buffet/script/redact_player`, `botc_patch:cmd/start` |
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
