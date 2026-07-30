# A former occupant cannot reclaim a seat after the Storyteller reassigned it.
tag @s remove botc_buffet_roster
team leave @s
scoreboard players reset @s id
scoreboard players reset @s botc_buffet_seat_gen
clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_tool:1b}]
tellraw @s [{"text":"Your previous seat was reassigned while you were away.","color":"yellow"}]
function botc_patch:buffet/item_checks
