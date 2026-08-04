scoreboard players set @s botc_fun_paint_count 0
kill @e[type=minecraft:marker,tag=botc_fun_paint_candidate]
function botc_patch:fun/paint_gun/projectile/kill_visual
execute positioned ~0.5 ~0.5 ~0.5 run playsound minecraft:item.ink_sac.use player @a[distance=..64] ~ ~ ~ 1.0 1.15 0.25
function botc_patch:fun/paint_gun/paint_here
function botc_patch:fun/paint_gun/candidates/create
function botc_patch:fun/paint_gun/candidates/mark_connected
function botc_patch:fun/paint_gun/candidates/pick_preferred
function botc_patch:fun/paint_gun/candidates/pick_fallback
kill @e[type=minecraft:marker,tag=botc_fun_paint_candidate]
kill @s
