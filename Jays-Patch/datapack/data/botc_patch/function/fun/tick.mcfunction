# Keep the Slayer on its independent use statistic, and route all other fun tools here.
scoreboard players add @a botc_fun_hot_immunity 0
scoreboard players remove @a[scores={botc_fun_hot_immunity=1..}] botc_fun_hot_immunity 1
function botc_patch:fun/slayer/tick
execute as @a[scores={botc_fun_silly_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["botc_fun_drunk_empty"]} run function botc_patch:fun/sillyjuice/consumed
scoreboard players set @a[scores={botc_fun_silly_use=1..}] botc_fun_silly_use 0
execute as @a[tag=!botc_fun_boomdandy_active,scores={botc_fun_item_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["botc_fun_boomdandy"]} run function botc_patch:fun/boomdandy/use
execute as @a[tag=botc_fun_hot_holder,scores={botc_fun_item_use=1..,botc_fun_hot_pass_cd=..0}] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["botc_fun_hot_potato"]} run function botc_patch:fun/hot_potato/shoot
execute as @a[scores={botc_fun_item_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["botc_fun_king"]} run function botc_patch:fun/entrance/king/use
scoreboard players set @a[scores={botc_fun_item_use=1..}] botc_fun_item_use 0

function botc_patch:fun/boomdandy/tick
function botc_patch:fun/sillyjuice/tick
function botc_patch:fun/hot_potato/tick
function botc_patch:fun/dice_roll/tick
function botc_patch:fun/entrance/tick
function botc_patch:fun/entrance/king/auto_tick
