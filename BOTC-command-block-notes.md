# BOTC Command Block Notes

Last updated: 2026-06-19

## Evidence

- Jay confirmed:
  - Button on light blue wool runs the good team head effect.
  - Button on red wool runs the evil team head effect.
  - Only the two current storyteller buttons should be usable by storytellers for now.
- Live server checks confirmed:
  - Hidden raise/lower hand command blocks are underground around `118 -60 68`, `118 -60 70`, and `112 -60 72`.
  - Storytellers are forced into adventure mode by a hidden command block at `118 -60 76`.
  - Global YAWP has `0 members` and `0 owners`, so storytellers do not have broad global bypass.
  - Winner-head timer command blocks are near `160 66 127`.
  - Winner-title helper functions are:
    - `ct:admin/winner/good`
    - `ct:admin/winner/evil`
  - Night phase music helper function is `ct:admin/music/night`.
  - `ct:start_game/setup` tells storytellers what the two town square winner buttons do when a valid 5-15 player game starts.
  - The two allowed storyteller button regions are:
    - `stb1287267` for button block `128 72 67`
    - `stb1257267` for button block `125 72 67`

## Visible Button Map

### Light Blue Wool Button

Purpose: good team winner heads.

Live command block column:

```text
128 70 67 -> impulse, needs button/redstone
128 69 67 -> chain, always active
128 68 67 -> chain, always active
128 67 67 -> chain, always active
128 66 67 -> chain, always active
128 65 67 -> chain, always active
```

Live commands, top to bottom:

```mcfunction
item replace entity @a[tag=winner,tag=!dead] armor.head with minecraft:air
tag @a remove winner
tag @a[tag=town] add winner
tag @a[tag=outsider] add winner
execute if entity @a[name=__nobody_should_match__] run say noop
function ct:admin/winner/good
```

The no-op block keeps the chain layout intact. Winner heads and the final
title are handled by `ct:admin/winner/good`. Cleanup is handled by the shared
`win_timer` blocks.

### Red Wool Button

Purpose: evil team winner heads.

Live command block column:

```text
125 70 67 -> impulse, needs button/redstone
125 69 67 -> chain, always active
125 68 67 -> chain, always active
125 67 67 -> chain, always active
125 66 67 -> chain, always active
125 65 67 -> chain, always active
```

Live commands, top to bottom:

```mcfunction
item replace entity @a[tag=winner,tag=!dead] armor.head with minecraft:air
tag @a remove winner
tag @a[tag=minion] add winner
tag @a[tag=demon] add winner
execute if entity @a[name=__nobody_should_match__] run say noop
function ct:admin/winner/evil
```

The no-op block keeps the chain layout intact. Winner heads and the final
title are handled by `ct:admin/winner/evil`. Cleanup is handled by the shared
`win_timer` blocks.

## Winner Screen Title

The final command block in each winner column calls a helper function instead
of setting the timer directly.

Good winner function:

```mcfunction
function ct:admin/winner/good
```

This function:

```mcfunction
scoreboard players set timer win_timer 1200
item replace entity @a[tag=winner] armor.head with minecraft:diamond_block
title @a times 10 80 20
title @a subtitle {"text":""}
title @a title [{"text":"Good has won!","color":"aqua","bold":true}]
```

Evil winner function:

```mcfunction
function ct:admin/winner/evil
```

This function:

```mcfunction
scoreboard players set timer win_timer 1200
item replace entity @a[tag=winner] armor.head with minecraft:piglin_head
title @a times 10 80 20
title @a subtitle {"text":""}
title @a title [{"text":"Evil has won!","color":"red","bold":true}]
```

The title uses 10 ticks fade-in, 80 ticks stay, and 20 ticks fade-out.

## Winner Head Timer

Objective:

```mcfunction
win_timer
```

Fake player used as the timer holder:

```mcfunction
timer
```

The good and evil winner buttons both set:

```mcfunction
scoreboard players set timer win_timer 1200
```

That is 1200 ticks, or about 60 seconds.

Live timer command blocks:

```text
160 66 127 -> chain, always active
161 66 127 -> chain, always active
162 66 127 -> repeating, always active
```

Live timer commands:

```mcfunction
execute if score timer win_timer matches 0 run item replace entity @a[tag=winner] armor.head with minecraft:air
execute if score timer win_timer matches 0 run tag @a[tag=winner] remove winner
execute if score timer win_timer matches 1.. run scoreboard players remove timer win_timer 1
```

Important caution:

- The start of each winner button clears only old living winner heads with
  `@a[tag=winner,tag=!dead]`, so dead-player skulls are not wiped during the
  button setup step.
- The winner functions can still replace dead winners' heads once the final
  result is shown.
- The timer cleanup clears only temporary winner-tagged heads, then removes the
  temporary `winner` tag.

## Night Music

Night starts through:

```mcfunction
function ct:phase/night
```

That phase function plays the normal clocktower bell, then calls:

```mcfunction
function ct:admin/music/night
```

The music helper stops any old record-channel music, then randomly chooses one
of 108 low-volume, low-pitch combinations. Those combinations are 18 scary
vanilla Minecraft tracks, each with 6 volume/pitch variants.

```mcfunction
music_disc.11
music_disc.13
music_disc.5
music_disc.ward
music_disc.mellohi
music_disc.stal
music_disc.pigstep
music_disc.relic
music_disc.creator_music_box
music_disc.tears
music.overworld.deep_dark
music.overworld.dripstone_caves
music.nether.basalt_deltas
music.nether.soul_sand_valley
music.nether.warped_forest
music.nether.nether_wastes
music.end
music.dragon
```

The selected track is played by:

```mcfunction
function ct:admin/music/play_at_houses
```

That helper plays the track to each non-spectator, non-storyteller player from
their matching `house` marker, using the player's `id` score and the marker's
`house_id` score. It does not follow the player around; the sound belongs to
their assigned house for the night.

All night tracks use the `record` category at low volume, so players can adjust
them with the Jukebox/Note Blocks volume slider.

These phase functions stop record-channel music:

```mcfunction
ct:phase/day
ct:phase/dawn
ct:phase/dusk
```

## Raise/Lower Hand System

Objective:

```mcfunction
scoreboard objectives add hand_click minecraft.used:minecraft.carrot_on_a_stick
```

Player item:

- Given only while `phase game_data` is `1..`.
- Goes into `hotbar.4`.
- Uses `minecraft:carrot_on_a_stick`.
- Name toggles between `Raise your hand` and `Lower your hand`.
- Uses custom model data strings:
  - `raise_hand`
  - `lower_hand`

State:

- Raised hand means the player has tag `raising_hand`.
- Lowered hand means that tag is removed.
- Existing `/hand raise` and `/hand lower` still work because they use the same tag.

Lamp behavior:

- The lamp line starts at `112 -60 72`.
- It clears redstone lamps at each `vote_marker` position using `~ ~-1 ~`.
- It places a lit redstone lamp at `~ ~-1 ~` below the matching seat marker when the player with that seat `id` has `raising_hand`.
- There are 15 chain blocks, one for each seat ID `1..15`.

## Storyteller Permissions

Current intended behavior:

- Storytellers are kept in adventure mode.
- Storytellers cannot break blocks through normal Minecraft mechanics.
- Storytellers cannot place blocks through normal Minecraft mechanics.
- Storytellers do not have global YAWP bypass.
- Storytellers can use only the two local YAWP button regions listed above.

Hidden command block:

```mcfunction
execute as @a[tag=storyteller,gamemode=!adventure] run gamemode adventure @s
```

Location:

```text
118 -60 76
```

YAWP local button regions:

```text
stb1287267 -> button at 128 72 67
stb1257267 -> button at 125 72 67
```

Each region:

- Covers exactly one button block.
- Has local `use-blocks` control.
- Adds team `99_storyteller` as local `members`.
- Is recreated by startup through `ct:admin/init/yawp_reset` and `ct:admin/init/yawp_regions`.

Important caution:

- Do not run `yawp global add team members 99_storyteller` for this setup.
- That gives storytellers broad global bypass and is more access than wanted.

## Useful Test Commands

Check Jay's storyteller state:

```mcfunction
tag Jayify420 list
team list 99_storyteller
data get entity Jayify420 playerGameType
execute if entity @a[name=Jayify420,tag=storyteller,team=99_storyteller,gamemode=adventure]
```

Check global YAWP is not granting broad access:

```mcfunction
yawp global info
```

Expected global groups:

```text
[0 members(s)] [0 owners(s)]
```

Check the two allowed button regions:

```mcfunction
yawp local minecraft:overworld stb1287267 info
yawp local minecraft:overworld stb1257267 info
```

Check the two button blocks exist:

```mcfunction
execute if block 128 72 67 minecraft:pale_oak_button
execute if block 125 72 67 minecraft:polished_blackstone_button
```

## Setup Signs

The two setup signs beside the grimoire are clickable only during setup. Their sign
click text uses the `setup_sign` trigger objective:

```text
123 73 93 -> become the Storyteller
123 73 95 -> sit down as a player
```

YAWP local sign regions:

```text
setupsignstory -> sign at 123 73 93
setupsignplayer -> sign at 123 73 95
```

Each region:

- Covers exactly one sign block.
- Has local `use-blocks` allowed so adventure-mode players can right-click it.
- Is recreated by startup through `ct:admin/init/yawp_reset` and `ct:admin/init/yawp_regions`.

## Recommendation

When changing this later, first decide whether the change is a visible button change, a hidden command-block change, or a YAWP region change. Avoid broad global YAWP grants unless the goal is intentionally to bypass protection everywhere.
