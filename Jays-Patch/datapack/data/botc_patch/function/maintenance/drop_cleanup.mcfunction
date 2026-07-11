# Remove dropped Jay-owned tool items through the shared custom_data marker.
execute as @e[type=minecraft:item] if data entity @s Item.components."minecraft:custom_data"{botc_patch_tool:1b} run kill @s
