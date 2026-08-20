# BOTC Command Block Notes

Last updated: 2026-06-21

## Evidence

- The cleaned live world at `data/world` and the copied
  `Jays-Patch/world-template` both scanned with zero command blocks.
- All reusable winner logic already lives in Jay's Patch:
  - `function botc_patch:winner/good`
  - `function botc_patch:winner/evil`
- The old hidden command-block systems for hand items, lamps, winner timers, and
  force-storyteller-adventure are removed from the live world.
- The old physical good/evil winner buttons were already absent from the
  documented area during cleanup.
- The server-side command path is now `/botc`, backed by
  `Jays-Patch/melius-commands/commands/botc.json`.
- The Storyteller receives the Reveal Grimoire item during active games, which can
  be used as a menu/control entrypoint.

## Inference

Command blocks were migration debt. The current command-block-free world should
stay that way, with reusable behavior owned by `/botc` commands plus
Storyteller menu/dialog actions from Jay's Patch.

## Recommendation

Do not add new command blocks. If a future map edit needs automation, add it to
Jay's Patch and keep `Jays-Patch/world-template` command-block-free.

## Deprecated Winner Button Command Blocks

These were cleanup targets, not the future control surface. Winner reveal should
be triggered through:

```text
/botc winner good
/botc winner evil
```

The Storyteller Reveal Grimoire item/menu may also expose these actions later.

### Good Winner Button

Button location:

```text
128 72 67
```

Command block column:

```text
128 70 67 -> impulse, button-powered
128 69 67 -> chain, no-op
128 68 67 -> chain, no-op
128 67 67 -> chain, no-op
128 66 67 -> chain, no-op
128 65 67 -> chain, no-op
```

Current top command:

```mcfunction
function botc_patch:winner/good
```

Current direction:

- Keep the behavior in `botc_patch:winner/good`.
- Trigger the behavior through `/botc winner good` or a Storyteller menu/dialog
  action.

### Evil Winner Button

Button location:

```text
125 72 67
```

Command block column:

```text
125 70 67 -> impulse, button-powered
125 69 67 -> chain, no-op
125 68 67 -> chain, no-op
125 67 67 -> chain, no-op
125 66 67 -> chain, no-op
125 65 67 -> chain, no-op
```

Current top command:

```mcfunction
function botc_patch:winner/evil
```

Current direction:

- Keep the behavior in `botc_patch:winner/evil`.
- Trigger the behavior through `/botc winner evil` or a Storyteller menu/dialog
  action.

## Deprecated Hidden Command-Block Systems

These command-block systems are historical references only. Jay's Patch now owns
the behavior:

```text
118..126 -60 68 -> old hand item line
118..126 -60 70 -> old hand toggle line
112..126 -60 72 -> old hand lamp line
118 -60 76      -> old force-storyteller-adventure block
160..162 66 127 -> old winner timer line
```

They should not be recreated.

## Jay's Patch Runtime Functions

Source files:

```text
Jays-Patch/datapack/data/botc_patch/function
```

Important functions:

```mcfunction
botc_patch:hand/tick
botc_patch:hand/lamps
botc_patch:winner/good
botc_patch:winner/evil
botc_patch:winner/tick
botc_patch:music/tick
```

The deployed runtime copy is generated at startup:

```text
data/world/datapacks/jays_patch
```

Do not edit the runtime copy as the source of truth.

## Raise/Lower Hand System

Player item:

- Uses `minecraft:carrot_on_a_stick`.
- Goes into `hotbar.4`.
- Name toggles between `Raise your hand` and `Lower your hand`.
- Uses custom model data strings:
  - `raise_hand`
  - `lower_hand`

Protection:

- Any copied hand item outside `hotbar.4` is cleared.
- Any dropped hand item entity is killed.
- The correct single item is restored while `phase game_data` is `3`
  (nominations).

Lamp behavior:

- A raised hand means the player has tag `raising_hand`.
- Lamps are placed at `~ ~-1 ~` below matching `vote_marker` item displays.
- Lamps are cleared from all vote markers every tick before raised hands are
  redrawn.

## Retired Setup Signs

The two setup signs beside the grimoire were removed during the cleanup reset.
Players should use the Storyteller queue instead of sign clicks.

```text
123 73 93 -> become the Storyteller
123 73 95 -> sit down as a player
```

Do not recreate the `setup_sign` trigger objective, setup-sign interaction
entities, or `botc_patch:setup_sign/*` functions. Queue and `/botc` commands are
the supported server-side control surfaces.

## Storyteller Command Path

Main command:

```text
/botc
```

Command overlay source:

```text
Jays-Patch/melius-commands/commands/botc.json
```

Key commands:

```text
/botc help
/setupbag role <character> <0|1>
/setupbag clear
/setupbag set_from_menu
/botc start
/botc reveal_roles
/botc phase next
/botc timer <minutes> <seconds>
/botc winner good
/botc winner evil
```

Most privileged actions are guarded by `tag=storyteller` and then run with the
temporary server permission needed by Melius.

## Night Music

Night music is handled by `botc_patch:music/tick`, not by editing
`ct:phase/night`.

Behavior:

- Detects when `phase game_data` changes.
- If the new phase is night, randomly chooses one of the low-volume,
  low-pitch scary vanilla `minecraft:music.*` tracks.
- Plays through Minecraft's `music` mixer so the sound follows the player
  instead of staying at a house marker.
- Gives seated non-Storyteller players a Night Music selector item during
  night. The selector can turn music off, pick a random/manual track, or toggle
  low pitch versus normal pitch for that player.

Manual selector choices keep the extra disc-style tracks available, but the
automatic night playlist uses real Minecraft music events by default.

## YAWP Regions

The server still runs these startup commands:

```mcfunction
function ct:admin/init/yawp_flags
function ct:admin/init/yawp_reset
function ct:admin/init/yawp_regions
```

These are still Sybillian's region setup functions. Keep them unless a later
patch replaces region setup server-side.

Important caution:

- Do not grant Storytellers broad global YAWP access.
- The intended setup is local use access for the specific map controls that need
  to be clickable.
