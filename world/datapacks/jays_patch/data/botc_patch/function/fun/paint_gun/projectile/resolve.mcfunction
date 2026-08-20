# The marker holds the last sampled real snowball position. At 2.5x speed the
# final movement segment stays below three blocks, so sweep that full distance.
scoreboard players set @s botc_fun_paint_count 12
function botc_patch:fun/paint_gun/projectile/step_loop
