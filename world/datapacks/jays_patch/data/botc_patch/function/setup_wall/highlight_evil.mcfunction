# Highlight one enabled evil setup-wall role icon.
team leave @s
data modify entity @s Glowing set value 0b
data modify entity @s brightness set value {block:15,sky:15}
data modify entity @s transformation.translation set value [0f,0.12f,0.08f]
data modify entity @s transformation.scale set value [1.38f,1.38f,1.38f]
execute at @s run function botc_patch:setup_wall/selected_evil
