execute if score fun_entrance_active botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"A dramatic entrance is already playing. Your King item was not used.","color":"gray","bold":false}]
execute at @s unless block ~ -64 ~ minecraft:warped_planks run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can only make your King claim in the Town Square.","color":"gray","bold":false}]
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_king"]}] 1
scoreboard players set fun_entrance_variant botc_patch 1
function botc_patch:fun/entrance/start
