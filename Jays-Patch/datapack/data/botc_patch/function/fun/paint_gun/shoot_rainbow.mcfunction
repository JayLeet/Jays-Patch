# Seed an eleven-colour cycle. Each painted block advances by a random non-zero
# amount, so a Rainbow splash is varied without repeating adjacent selections.
execute store result score @s botc_fun_paint_roll run random value 0..10
tag @s add botc_fun_paint_rainbow_shooter
function botc_patch:fun/paint_gun/shoot
tag @s remove botc_fun_paint_rainbow_shooter
