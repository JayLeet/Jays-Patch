# Player impacts are deliberately louder and larger than a block splash.
scoreboard players set @s botc_fun_paint_count 0
kill @e[type=minecraft:marker,tag=botc_fun_paint_candidate]
function botc_patch:fun/paint_gun/projectile/kill_visual
execute store result score @s botc_fun_paint_existing run random value 1..5
execute positioned ~0.5 ~1 ~0.5 run function botc_patch:fun/paint_gun/play_splat
execute if entity @s[tag=botc_fun_paint_rainbow] positioned ~0.5 ~1 ~0.5 run function botc_patch:fun/paint_gun/player_splash_rainbow
execute unless entity @s[tag=botc_fun_paint_rainbow] positioned ~0.5 ~1 ~0.5 run function botc_patch:fun/paint_gun/player_splash_normal
function botc_patch:fun/paint_gun/candidates/create_player
execute unless entity @e[type=minecraft:marker,tag=botc_fun_paint_candidate,tag=botc_fun_paint_connected,limit=1] run tag @e[type=minecraft:marker,tag=botc_fun_paint_candidate,tag=botc_fun_paint_preferred,sort=nearest,limit=1] add botc_fun_paint_connected
execute unless entity @e[type=minecraft:marker,tag=botc_fun_paint_candidate,tag=botc_fun_paint_connected,limit=1] run tag @e[type=minecraft:marker,tag=botc_fun_paint_candidate,tag=botc_fun_paint_fallback,sort=nearest,limit=1] add botc_fun_paint_connected
function botc_patch:fun/paint_gun/candidates/pick_player_preferred
function botc_patch:fun/paint_gun/candidates/pick_player_fallback
kill @e[type=minecraft:marker,tag=botc_fun_paint_candidate]
kill @s
