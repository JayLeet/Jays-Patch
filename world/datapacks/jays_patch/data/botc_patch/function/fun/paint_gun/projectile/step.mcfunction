# Inspect one quarter-block of the real snowball's final movement segment.
# Paint the first eligible full cube; any other solid safely absorbs the shot.
scoreboard players operation fun_paint_current_owner botc_patch = @s botc_fun_paint_owner
tag @a remove botc_fun_paint_hit_player
execute positioned ^ ^ ^0.25 if block ~ ~ ~ #minecraft:replaceable positioned ~-0.45 ~-1.8 ~-0.45 run tag @a[gamemode=!spectator,dx=0.9,dy=2.0,dz=0.9] add botc_fun_paint_hit_player
execute as @a[tag=botc_fun_paint_hit_player] if score @s botc_fun_paint_owner = fun_paint_current_owner botc_patch run tag @s remove botc_fun_paint_hit_player
execute if entity @a[tag=botc_fun_paint_hit_player] at @a[tag=botc_fun_paint_hit_player,limit=1,sort=nearest] align xyz run function botc_patch:fun/paint_gun/player_impact
tag @a remove botc_fun_paint_hit_player
execute unless entity @s[tag=botc_fun_paint_projectile] run kill @s
execute if entity @s[tag=botc_fun_paint_projectile] positioned ^ ^ ^0.25 if block ~ ~ ~ #botc_patch:paintable_full_cube align xyz run function botc_patch:fun/paint_gun/impact
execute if entity @s[tag=botc_fun_paint_projectile] positioned ^ ^ ^0.25 unless block ~ ~ ~ #minecraft:replaceable run function botc_patch:fun/paint_gun/projectile/stop
execute if entity @s[tag=botc_fun_paint_projectile] positioned ^ ^ ^0.25 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
