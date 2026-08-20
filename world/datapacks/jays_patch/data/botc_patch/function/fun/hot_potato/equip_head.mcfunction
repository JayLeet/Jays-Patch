# Save this round's exact original head stack before equipping the marked block.
execute store result storage botc_patch:fun hot_potato.current_generation int 1 run scoreboard players get @s botc_fun_hot_generation
function botc_patch:fun/hot_potato/save_head with storage botc_patch:fun hot_potato
item replace entity @s armor.head with minecraft:redstone_block[minecraft:enchantments={'minecraft:binding_curse':1},minecraft:enchantment_glint_override=false,minecraft:custom_data={botc_fun_hot_head:1b}]
data remove storage botc_patch:fun hot_potato.current_generation
