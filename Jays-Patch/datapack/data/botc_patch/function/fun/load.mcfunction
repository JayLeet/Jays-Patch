# Reloads fail closed: restore an interrupted entrance, then discard transient toy state.
execute if score fun_entrance_active botc_patch matches 1 run function botc_patch:fun/entrance/finish
function botc_patch:fun/entrance/cleanup_light
scoreboard players set fun_hot_active botc_patch 0
scoreboard players set fun_hot_timer botc_patch 0
scoreboard players set fun_dice_active botc_patch 0
scoreboard players set fun_dice_timer botc_patch 0
tag @a remove botc_fun_hot_holder
tag @a remove botc_fun_hot_target
tag @a remove botc_fun_dice_roller
tag @a remove botc_fun_boomdandy_active
scoreboard players set @a botc_fun_boom_timer 0
execute as @a if items entity @s armor.head minecraft:redstone_block[minecraft:custom_data={botc_fun_hot_head:1b}] at @s run function botc_patch:fun/hot_potato/remove_head
kill @e[type=minecraft:armor_stand,tag=botc_fun_hot_head_restore]
scoreboard players set @a botc_fun_hot_pass_cd 0
scoreboard players set @a botc_fun_hot_immunity 0
clear @a minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}]
execute as @e[type=minecraft:item] if items entity @s contents minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["botc_fun_hot_potato"]}] run kill @s
tag @e[type=minecraft:item] remove botc_fun_hot_drop
kill @e[type=minecraft:block_display,tag=botc_fun_paint]
kill @e[type=minecraft:snowball,tag=botc_fun_paint_projectile]
kill @e[type=minecraft:snowball,tag=botc_fun_paint_visual]
kill @e[type=minecraft:marker,tag=botc_fun_paint_projectile]
kill @e[type=minecraft:marker,tag=botc_fun_paint_candidate]
kill @e[type=minecraft:marker,tag=botc_fun_paint_aim]
tag @a remove botc_fun_paint_rainbow_shooter
tag @a remove botc_fun_paint_hit_player
scoreboard players set @a botc_fun_paint_cooldown 0
scoreboard players set @a botc_fun_paint_range 0
scoreboard players set @a botc_fun_paint_count 0
scoreboard players set fun_paint_displays botc_patch 0
scoreboard players set fun_paint_oldest botc_patch -1
scoreboard players set fun_paint_palette botc_patch 11
scoreboard players set fun_paint_next_id botc_patch 0
execute unless score fun_paint_next_owner botc_patch matches -2147483648..2147483647 run scoreboard players set fun_paint_next_owner botc_patch 0
