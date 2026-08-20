# Toggle duplicate actual-role assignments and make the policy visible.
execute if score buffet_duplicates botc_patch matches 0 run scoreboard players set buffet_duplicates botc_patch 2
execute if score buffet_duplicates botc_patch matches 1 run scoreboard players set buffet_duplicates botc_patch 0
execute if score buffet_duplicates botc_patch matches 2 run scoreboard players set buffet_duplicates botc_patch 1
execute if score buffet_duplicates botc_patch matches 0 run tellraw @a [{"text":"Assignments must now be unique.","color":"yellow"}]
execute if score buffet_duplicates botc_patch matches 1 run tellraw @a [{"text":"Assignments may now contain duplicates.","color":"yellow"}]
function botc_patch:buffet/greedy/review/open
