kill @e[type=minecraft:armor_stand,tag=botc_fun_hot_head_restore]
$execute if data storage botc_patch:fun hot_potato.saved_heads.g$(current_generation) run summon minecraft:armor_stand ~ ~ ~ {Tags:["botc_fun_hot_head_restore"],Invisible:1b,Marker:1b,NoGravity:1b}
$execute if data storage botc_patch:fun hot_potato.saved_heads.g$(current_generation) run data modify entity @e[type=minecraft:armor_stand,tag=botc_fun_hot_head_restore,limit=1] equipment.mainhand set from storage botc_patch:fun hot_potato.saved_heads.g$(current_generation)
$execute if data storage botc_patch:fun hot_potato.saved_heads.g$(current_generation) run item replace entity @s armor.head from entity @e[type=minecraft:armor_stand,tag=botc_fun_hot_head_restore,limit=1] weapon.mainhand
$execute unless data storage botc_patch:fun hot_potato.saved_heads.g$(current_generation) run item replace entity @s armor.head with minecraft:air
kill @e[type=minecraft:armor_stand,tag=botc_fun_hot_head_restore]
$data remove storage botc_patch:fun hot_potato.saved_heads.g$(current_generation)
