# A block display located inside an opaque cube reads darkness. Sample every
# touching cell and keep the brightest visible level exposed by the real block.
scoreboard players set @s botc_fun_paint_light 0
execute positioned ~1 ~ ~ run function botc_patch:fun/paint_gun/sample_light_at
execute positioned ~-1 ~ ~ run function botc_patch:fun/paint_gun/sample_light_at
execute positioned ~ ~1 ~ run function botc_patch:fun/paint_gun/sample_light_at
execute positioned ~ ~-1 ~ run function botc_patch:fun/paint_gun/sample_light_at
execute positioned ~ ~ ~1 run function botc_patch:fun/paint_gun/sample_light_at
execute positioned ~ ~ ~-1 run function botc_patch:fun/paint_gun/sample_light_at
