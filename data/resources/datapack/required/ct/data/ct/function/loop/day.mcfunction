execute as @a[tag=!storyteller,tag=!spectator,tag=beets] run scoreboard players add beets vc 1
execute as @a[tag=!storyteller,tag=!spectator,tag=wheat] run scoreboard players add wheat vc 1
execute as @a[tag=!storyteller,tag=!spectator,tag=church] run scoreboard players add church vc 1
execute as @a[tag=!storyteller,tag=!spectator,tag=graveyard] run scoreboard players add graveyard vc 1
execute as @a[tag=!storyteller,tag=!spectator,tag=inn] run scoreboard players add inn vc 1
execute as @a[tag=!storyteller,tag=!spectator,tag=greenhouse] run scoreboard players add greenhouse vc 1
execute as @a[tag=!storyteller,tag=!spectator,tag=bakery] run scoreboard players add bakery vc 1
execute as @a[tag=!spectator,tag=den] run scoreboard players add den vc 1

execute if score beets vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 98 77 75
execute if score beets vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 92 77 66
execute if score wheat vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 93 75 55
execute if score church vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 116 80 102
execute if score church vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 117 80 102
execute if score graveyard vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 101 81 103
execute if score inn vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 144 73 72
execute if score greenhouse vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 144 73 44
execute if score bakery vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 110 73 54
execute if score den vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 120 73 91
execute if score den vc matches 2.. run particle minecraft:block_marker{"block_state":"minecraft:barrier"} 121 73 91

scoreboard players set beets vc 0
scoreboard players set wheat vc 0
scoreboard players set church vc 0
scoreboard players set graveyard vc 0
scoreboard players set inn vc 0
scoreboard players set greenhouse vc 0
scoreboard players set bakery vc 0
scoreboard players set den vc 0