function botc_patch:grim/settle_current
$summon minecraft:item_display ~ ~0.1 ~ {Tags:["botc_grim_reveal","botc_grim_current"],billboard:"center",view_range:80f,item_display:"gui",item:{id:"minecraft:paper",count:1,components:{"minecraft:custom_model_data":{strings:["botc_role_$(role)"]},"minecraft:custom_name":{translate:"clocktower.role.$(role).name",italic:0b}}},transformation:{translation:[0f,0f,0f],left_rotation:[0f,0f,0f,1f],scale:[1.35f,1.35f,1.35f],right_rotation:[0f,0f,0f,1f]}}
$execute if score grim_reveal_alignment botc_patch matches 1 run function botc_patch:grim/reveal/text_good {role:"$(role)"}
$execute if score grim_reveal_alignment botc_patch matches 2 run function botc_patch:grim/reveal/text_evil {role:"$(role)"}
execute if score grim_reveal_alignment botc_patch matches 1 run function botc_patch:grim/reveal/particles_good
execute if score grim_reveal_alignment botc_patch matches 2 run function botc_patch:grim/reveal/particles_evil
execute if block ~ ~1 ~ minecraft:air run setblock ~ ~1 ~ minecraft:light[level=14] replace
execute if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:light[level=14] replace
scoreboard players set grim_spotlight botc_patch 80
