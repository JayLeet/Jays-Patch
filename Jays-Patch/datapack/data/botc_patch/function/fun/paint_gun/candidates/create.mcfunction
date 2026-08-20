# Score the four face-neighbours in each possible surface plane. A broad floor
# wins XZ, a north/south wall wins XY, and an east/west wall wins ZY.
scoreboard players set fun_paint_plane_xz botc_patch 0
scoreboard players set fun_paint_plane_xy botc_patch 0
scoreboard players set fun_paint_plane_zy botc_patch 0
execute positioned ~1 ~ ~ if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_xz botc_patch 1
execute positioned ~1 ~ ~ if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_xy botc_patch 1
execute positioned ~-1 ~ ~ if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_xz botc_patch 1
execute positioned ~-1 ~ ~ if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_xy botc_patch 1
execute positioned ~ ~1 ~ if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_xy botc_patch 1
execute positioned ~ ~1 ~ if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_zy botc_patch 1
execute positioned ~ ~-1 ~ if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_xy botc_patch 1
execute positioned ~ ~-1 ~ if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_zy botc_patch 1
execute positioned ~ ~ ~1 if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_xz botc_patch 1
execute positioned ~ ~ ~1 if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_zy botc_patch 1
execute positioned ~ ~ ~-1 if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_xz botc_patch 1
execute positioned ~ ~ ~-1 if block ~ ~ ~ #botc_patch:paintable_full_cube run scoreboard players add fun_paint_plane_zy botc_patch 1

# Start with XZ for ties, then replace it only when a vertical plane has more
# eligible neighbours. This keeps flat ground stable while adapting to walls.
tag @s remove botc_fun_paint_plane_xz
tag @s remove botc_fun_paint_plane_xy
tag @s remove botc_fun_paint_plane_zy
tag @s add botc_fun_paint_plane_xz
scoreboard players operation fun_paint_plane_best botc_patch = fun_paint_plane_xz botc_patch
execute if score fun_paint_plane_xy botc_patch > fun_paint_plane_best botc_patch run tag @s add botc_fun_paint_plane_xy
execute if entity @s[tag=botc_fun_paint_plane_xy] run tag @s remove botc_fun_paint_plane_xz
execute if entity @s[tag=botc_fun_paint_plane_xy] run scoreboard players operation fun_paint_plane_best botc_patch = fun_paint_plane_xy botc_patch
execute if score fun_paint_plane_zy botc_patch > fun_paint_plane_best botc_patch run tag @s add botc_fun_paint_plane_zy
execute if entity @s[tag=botc_fun_paint_plane_zy] run tag @s remove botc_fun_paint_plane_xz
execute if entity @s[tag=botc_fun_paint_plane_zy] run tag @s remove botc_fun_paint_plane_xy

execute if entity @s[tag=botc_fun_paint_plane_xz] run function botc_patch:fun/paint_gun/candidates/create_xz
execute if entity @s[tag=botc_fun_paint_plane_xy] run function botc_patch:fun/paint_gun/candidates/create_xy
execute if entity @s[tag=botc_fun_paint_plane_zy] run function botc_patch:fun/paint_gun/candidates/create_zy
