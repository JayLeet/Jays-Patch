# Restore only when the marked Hot Potato head is still equipped.
execute unless items entity @s armor.head minecraft:redstone_block[minecraft:custom_data={botc_fun_hot_head:1b}] run return 0
execute store result storage botc_patch:fun hot_potato.current_generation int 1 run scoreboard players get @s botc_fun_hot_generation
function botc_patch:fun/hot_potato/restore_head with storage botc_patch:fun hot_potato
data remove storage botc_patch:fun hot_potato.current_generation
