# Resource Pack Map

Use this map before changing item textures, selector model values, custom model
data strings, or role icon behavior. For exact generated mappings, use
`generated/resourcepack-index.md`.

## Jay-Owned Selector Models

Minecraft 1.21.10 Jay-owned carrot/paper visuals use
`minecraft:custom_model_data` string components through the root selector files
`assets/minecraft/items/carrot_on_a_stick.json` and
`assets/minecraft/items/paper.json`.

The selector files must use the June 21 working shape:

- `property: minecraft:component`
- `component: minecraft:custom_model_data`
- `when: { strings: ["..."] }`

Do not migrate these Jay-owned tools to datapack `minecraft:item_model`
components or direct `property: minecraft:custom_model_data` selector cases
without new in-game evidence. The model column below is the selector target
model.

## Dialog Role Icon Font

`assets/botc_patch/font/role_icons.json` exposes all 138 role textures as
16-pixel bitmap-font glyphs for vanilla dialog button labels. Score `0` (`None`)
uses U+E000; Sybillian role score `N` uses U+E000 + `N`. The shared mapping is
owned by `tools/lib/role-icon-glyphs.ps1` and generated alongside role models
and textures by `tools/generate-role-icons.ps1`.

Dialog labels keep normal text in `minecraft:default` and use
`botc_patch:role_icons` only for the leading role glyph. Player names use white
for readability, while `(Role)` suffixes use the effective Good/Evil alignment
color. Do not assign glyphs by alphabetical list position; inserting a role
would shift every later icon for clients with an older pack.

## Dialog UI Icon Font

`assets/botc_patch/font/ui_icons.json` is generated from
`Jays-Patch/dialog-icons.json` and `Jays-Patch/music-tracks.json`. It uses
explicit U+E100-series code points so adding a later icon cannot shift existing
glyphs. General controls reuse Jay-owned item textures or vanilla Minecraft
item/block textures. Night Music contains all 21 verified Minecraft 1.21.10
jukebox discs with their matching disc textures, plus six ambient tracks with
matching environment textures. Update the registries and rerun
`tools/generate-dialog-icons.ps1` and `tools/generate-music.ps1`; do not
hand-edit the font or generated music command tables.

| String | Item | Selector model | Texture | Used by |
| --- | --- | --- | --- | --- |
| `raise_hand` | `minecraft:carrot_on_a_stick` | `botc_patch:item/raise_hand` | `assets/botc_patch/textures/item/raise_hand.png` | `hand/tick`, generated hand fallback functions |
| `lower_hand` | `minecraft:carrot_on_a_stick` | `botc_patch:item/lower_hand` | `assets/botc_patch/textures/item/lower_hand.png` | `hand/tick`, generated hand fallback functions |
| `grim_reveal_menu` | `minecraft:carrot_on_a_stick` | `botc_patch:item/reveal_roles` | `assets/botc_patch/textures/item/reveal_roles.png` | `grim/tick`, generated grimoire fallback function |
| `music_selector` | `minecraft:carrot_on_a_stick` | `botc_patch:item/music_selector` | `assets/botc_patch/textures/item/music_selector.png` | `music/item`, generated night music selector fallback function |
| `winner_firework` | `minecraft:carrot_on_a_stick` | `minecraft:item/firework_rocket` | Vanilla Firework Rocket texture | YAWP-safe Good/Evil winner launchers in `winner/give_*_fireworks`; right-clicking the sky routes through `winner/firework_tick` |
| `mic` | `minecraft:carrot_on_a_stick` | `minecraft:item/microphone` | Sybillian required pack: `assets/ct/textures/item/microphone.png` | `night_chat/item_checks` |
| `botc_role_wraith` | `minecraft:carrot_on_a_stick`, `minecraft:paper` | `botc_patch:item/role/wraith` | generated copy of Sybillian's available `ct:role/wraith` texture | Wraith Sight, setup wall, grimoire editor, and reveal displays |
| `storyteller_reset_game` | `minecraft:carrot_on_a_stick` | `botc_patch:item/reset_game` | `assets/botc_patch/textures/item/reset_game.png` | `storyteller_tools/reset_game`, `storyteller_tools/item_checks` |
| `setup_reset_game` | `minecraft:carrot_on_a_stick` | `botc_patch:item/reset_game` | `assets/botc_patch/textures/item/reset_game.png` | `setup_tools/reset_game`, `setup_tools/item_checks` |
| `setup_become_player` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_become_player` | `assets/botc_patch/textures/item/setup_become_player.png` | `setup_tools/become_player`, `setup_tools/item_checks` |
| `setup_become_storyteller` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_become_storyteller` | `assets/botc_patch/textures/item/setup_become_storyteller.png` | `setup_tools/join_queue`, `setup_tools/item_checks` |
| `setup_queue_status` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_queue_status` | `assets/botc_patch/textures/item/setup_queue_status.png` | `setup_tools/queue_status`, `setup_tools/item_checks` |
| `setup_leave_queue` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_leave_queue` | `assets/botc_patch/textures/item/setup_leave_queue.png` | `setup_tools/leave_queue`, `setup_tools/item_checks` |
| `patch_toggle_enabled` | `minecraft:carrot_on_a_stick` | `minecraft:lime_candle` | Vanilla Lime Candle texture | `patch_toggle/item_checks`, `patch_toggle/tick`, `patch_toggle/cycle`, `/botc patch_toggle <mode>` |
| `patch_toggle_sybillian_setup_bag` | `minecraft:carrot_on_a_stick` | `minecraft:orange_candle` | Vanilla Orange Candle texture | `patch_toggle/item_checks`, `patch_toggle/tick`, `patch_toggle/cycle`, `/botc patch_toggle <mode>` |
| `patch_toggle_items_disabled` | `minecraft:carrot_on_a_stick` | `minecraft:red_candle` | Vanilla Red Candle texture | `patch_toggle/item_checks`, `patch_toggle/tick`, `patch_toggle/cycle`, `/botc patch_toggle <mode>` |
| `patch_toggle` | `minecraft:carrot_on_a_stick` | `minecraft:comparator` | Retired cleanup string for old Toggle items | `patch_toggle/item_checks` |
| `storyteller_advance_phase` | `minecraft:carrot_on_a_stick` | `minecraft:clock` | Vanilla clock item model | `storyteller_tools/advance_phase`, `storyteller_tools/item_checks` |
| `setup_queue_status` + `botc_storyteller_timer` custom data | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_queue_status` | `assets/botc_patch/textures/item/setup_queue_status.png` | Day-only Storyteller timer dialog in `storyteller_tools/timer/open`, guarded by `/botc day_timer <1-10>` |
| `storyteller_tp_evil` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_tp_evil` | `assets/botc_patch/textures/item/storyteller_tp_evil.png` | `storyteller_tools/teleport_evil`, `storyteller_tools/item_checks` |
| `storyteller_tp_seats` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_tp_seats` | `assets/botc_patch/textures/item/storyteller_tp_seats.png` | `storyteller_tools/teleport_seats`, `storyteller_tools/item_checks` |
| `storyteller_tp_home` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_tp_home` | `assets/botc_patch/textures/item/storyteller_tp_home.png` | `storyteller_tools/teleport_home`, `storyteller_tools/item_checks` |
| `storyteller_passage` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_passage` | Jay-owned passage texture | Day Storyteller's Passage item plus night-house visual slot 6 item in `storyteller_tools/replace_items`; runs `storyteller_tools/passage/start` |
| `storyteller_tp_player_menu` | `minecraft:carrot_on_a_stick` | `minecraft:ender_pearl` | Vanilla Ender Pearl texture | Night-only Storyteller player teleport menu in `storyteller_tools/player_menu/open`, `storyteller_tools/item_checks` |
| `storyteller_tp_back` | `minecraft:carrot_on_a_stick` | `botc_patch:item/back` | `assets/botc_patch/textures/item/back.png` | `storyteller_tools/player_menu/back`, `storyteller_tools/item_checks` |
| `storyteller_tp_next` | `minecraft:carrot_on_a_stick` | `botc_patch:item/next` | `assets/botc_patch/textures/item/next.png` | `storyteller_tools/player_menu/page_2`, `storyteller_tools/item_checks` |
| `storyteller_tp_<seat-color>` | `minecraft:carrot_on_a_stick` | `botc_patch:item/nomination/<seat-color>` | Jay-owned 16x16 solid-color square textures | Legacy/cleanup-compatible daytime teleport color token. Current generated day Teleport-to-Player buttons emit `storyteller_nom_<seat-color>` so every day player picker uses the same colored-pane path. |
| `storyteller_revive` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_revive` | `assets/botc_patch/textures/item/storyteller_revive.png` | `storyteller_tools/revive_menu/open`, `storyteller_tools/item_checks` |
| `storyteller_revive_back` | `minecraft:carrot_on_a_stick` | `botc_patch:item/back` | `assets/botc_patch/textures/item/back.png` | Retired hotbar-picker cleanup compatibility only |
| `storyteller_revive_next` | `minecraft:carrot_on_a_stick` | `botc_patch:item/next` | `assets/botc_patch/textures/item/next.png` | Retired hotbar-picker cleanup compatibility only |
| `storyteller_revive_<seat-color>` | `minecraft:carrot_on_a_stick` | `botc_patch:item/nomination/<seat-color>` | Jay-owned 16x16 solid-color square textures | Retired hotbar-picker cleanup compatibility only; the live Revive selector is a vanilla dialog. |
| `storyteller_nominate` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_nominate` | `assets/botc_patch/textures/item/storyteller_nominate.png` | `storyteller_tools/nomination_menu/open`, generated nomination item checks |
| `storyteller_nom_back` | `minecraft:carrot_on_a_stick` | `botc_patch:item/back` | `assets/botc_patch/textures/item/back.png` | `storyteller_tools/nomination_menu/back`, generated nomination menus |
| `storyteller_nom_next` | `minecraft:carrot_on_a_stick` | `botc_patch:item/next` | `assets/botc_patch/textures/item/next.png` | Retired hotbar-picker cleanup compatibility only |
| `storyteller_nom_start_vote` | `minecraft:carrot_on_a_stick` | `botc_patch:item/start_vote` | `assets/botc_patch/textures/item/start_vote.png`, copied from Sybillian `ct:item/start_vote` | `storyteller_tools/nomination_menu/start_vote` |
| `storyteller_nom_mark` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_nom_mark` | `assets/botc_patch/textures/item/storyteller_nom_mark.png` | `storyteller_tools/nomination_menu/mark` |
| `storyteller_nom_pyre` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_nom_pyre` | `assets/botc_patch/textures/item/storyteller_nom_pyre.png` | `storyteller_tools/nomination_menu/pyre` |
| `storyteller_nom_execute` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_nom_execute` | `assets/botc_patch/textures/item/storyteller_nom_execute.png` | `storyteller_tools/nomination_menu/execute` |
| `storyteller_post_kill` | `minecraft:carrot_on_a_stick` | `botc_patch:item/storyteller_post_kill` | `assets/botc_patch/textures/item/storyteller_post_kill.png` | `storyteller_tools/kill_menu/open`, `storyteller_tools/post_execution/kill` |
| `storyteller_kill_back` | `minecraft:carrot_on_a_stick` | `botc_patch:item/back` | `assets/botc_patch/textures/item/back.png` | Retired hotbar-picker cleanup compatibility only |
| `storyteller_kill_next` | `minecraft:carrot_on_a_stick` | `botc_patch:item/next` | `assets/botc_patch/textures/item/next.png` | Retired hotbar-picker cleanup compatibility only |
| `storyteller_kill_<seat-color>` | `minecraft:carrot_on_a_stick` | `botc_patch:item/nomination/<seat-color>` | Jay-owned 16x16 solid-color square textures | Retired hotbar-picker cleanup compatibility only; the live Kill selector is a vanilla dialog. |
| `storyteller_nom_<seat-color>` | `minecraft:carrot_on_a_stick` | `botc_patch:item/nomination/<seat-color>` | Jay-owned 16x16 solid-color square textures | Retired player-picker compatibility mapping. Nominate now uses a vanilla dialog; Back and Start Vote appear first, then Mark/Clear Mark appears only after the vote finishes. |
| `setup_wall_bag` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_bag` | `assets/botc_patch/textures/item/setup_bag.png`, copied from Sybillian `ct:item/ct_bag` | `setup_room/item_checks`, `setup_room/tick` |
| `setup_wall_back` | `minecraft:carrot_on_a_stick` | `botc_patch:item/back` | `assets/botc_patch/textures/item/back.png` | `setup_room/back`, `setup_room/tick` |
| `setup_wall_custom` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_wall_custom` | generated copy of Sybillian `ct:role/atheist` | `setup_room/custom_script`, `setup_room/tick` |
| `setup_wall_tb` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_wall_tb` | generated copy of Sybillian `ct:role/imp` | `setup_room/select_tb`, `setup_room/tick` |
| `setup_wall_snv` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_wall_snv` | generated copy of Sybillian `ct:role/vortox` | `setup_room/select_snv`, `setup_room/tick` |
| `setup_wall_bmr` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_wall_bmr` | generated copy of Sybillian `ct:role/pukka` | `setup_room/select_bmr`, `setup_room/tick` |
| `setup_wall_clear` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_wall_clear` | `assets/botc_patch/textures/item/setup_wall_clear.png` | `setup_room/clear_setup`, `setup_room/tick` |
| `setup_wall_use_bag` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_wall_use_bag` | `assets/botc_patch/textures/item/setup_wall_use_bag.png` | `setup_room/use_bag`, `setup_room/tick` |
| `setup_wall_start` | `minecraft:carrot_on_a_stick` | `botc_patch:item/setup_wall_start` | `assets/botc_patch/textures/item/setup_wall_start.png` | `setup_room/start_game`, `setup_room/tick` |
| `botc_role_<role>` | `minecraft:paper`, `minecraft:carrot_on_a_stick` | `botc_patch:item/role/<role>` | generated copy of Sybillian `ct:role/<role>` under `assets/botc_patch/textures/item/role/<role>.png` | `grim/reveal/spawn`, setup room displays, script selector items, Custom Script item, night-only Storyteller teleport-to-player menu |

## Protected Sybillian Tool Strings

Jay's Patch item repair checks avoid overwriting Sybillian gameplay tools with
these custom model data strings:

- `ct_bag`
- `grimoire`
- `script`
- `advance_phase`

Jay's Patch intentionally does not reuse `ct_bag` for the custom setup room bag.
It uses `setup_wall_bag` so Sybillian's client-side setup-bag GUI handler does
not fire when the Storyteller right-clicks the replacement item.

## Rule

Keep Jay-owned item art under `assets/botc_patch/textures`. Role item art is
generated from Sybillian's installed `ct:role/...` textures into
`assets/botc_patch/textures/item/role` because direct `ct:role/...` references
rendered as missing textures in item models.

Jay-owned right-click tool items are registered in `Jays-Patch/tool-items.json`.
Setup-phase, setup-room, live Storyteller fixed tool hotbar/cleanup/repair
functions, plus the post-execution follow-up row, are generated from that
registry by `tools/generate-tool-items.ps1`. Update the registry when adding,
renaming, moving, or sharing a tool item model string, fixed tool slot, displayed
tool name, generated cleanup/repair ownership, or generated tool resource-model
mapping.

Night Chat deliberately reuses Sybillian's `mic` custom-model string and
`minecraft:item/microphone` model. The verified microphone texture is identical
in the local 1.5.4 resource pack and Sybillian's 1.6.0 beta source, so this
feature requires no copied texture, Jay model, or new resource-pack upload.

Item fallback functions are generated from `Jays-Patch/item-fallbacks.json` by
`tools/generate-item-fallbacks.ps1`. Update that table instead of hand-editing
`give_*_fallback.mcfunction` files.

Role icon model files, copied role PNGs, and the dialog bitmap font are generated
from `Jays-Patch/role-icons.json` by `tools/generate-role-icons.ps1`. Supported
Jay-owned backported roles are defined in `Jays-Patch/role-extensions.json` and
merged with the pinned Sybillian catalog by the generator. Update those source
tables and generators instead of hand-editing generated role files.

One-time Storyteller notification variants are generated from the normal item
and role textures by `tools/generate-notification-icons.ps1`, using
`Jays-Patch/notification-icons.json`. The generator owns the badged PNGs, their
models, and `botc_patch:role_icons_notification`; do not hand-edit those files.

Jay-owned visual mappings for carrot/paper tools belong in
`assets/minecraft/items/paper.json` and
`assets/minecraft/items/carrot_on_a_stick.json`. Do not add
`minecraft:item_model` components to Jay-owned datapack item stacks unless Jay
explicitly approves a new rendering migration with fresh evidence.

Teleport-to-player dialogs are generated by
`tools/generate-storyteller-player-menu.ps1`. Kill and Revive filtered player
dialogs are generated by `tools/generate-storyteller-kill-menu.ps1` and
`tools/generate-storyteller-revive-menu.ps1`. Nomination player selection is a
dialog generated by `tools/generate-storyteller-nomination-menu.ps1`, while its
post-selection Back and Start Vote controls remain hotbar items read from
`Jays-Patch/tool-items.json`; Mark/Clear Mark uses the same registered Mark model
and appears only after vote completion. Kill, Revive, and Nominate share
`tools/lib/player-dialog-generator.ps1` for bounded sparse-seat compaction.
Their retired Back/Next and seat-color model mappings remain only so cleanup can
remove items left by older deployments. Update the generators instead of
hand-editing generated player or nomination functions. Run the generators
sequentially because they write related function and resource output.

Run `tools/tests/test-resourcepack-mappings.ps1` after item, role-icon, or custom
model data changes. It verifies that datapack item stacks, root selector files,
model files, and textures still agree before anything is deployed.
Run `tools/tests/test-storyteller-role-notifications.ps1` after changing the
badge, notification roles, or their per-game acknowledgement behavior.

Hosted URL, SHA1, cache UUID, optional/required state, and installation prompt
are owned by
`Jays-Patch/server-config/jays-patch-required-server-properties.txt`.
`launcher/exe/BotcLauncher.ResourcePack.cs` and the public-package builder read
that source. `server.properties` must use the SHA1 from the hosted URL; the
launcher compares extracted contents with the exact cached hosted fallback
instead of treating different ZIP metadata as changed pack content.
