# Store a hidden actual role, then require an explicit perceived character.
$scoreboard players set buffet_hidden_actual botc_patch $(role)
$scoreboard players set buffet_hidden_alignment botc_patch $(alignment)
execute if score buffet_hidden_actual botc_patch matches 84 run function botc_patch:buffet/greedy/review/perceived_demon
execute unless score buffet_hidden_actual botc_patch matches 84 run function botc_patch:buffet/greedy/review/perceived_town
