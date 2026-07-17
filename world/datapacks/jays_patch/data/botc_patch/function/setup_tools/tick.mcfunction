# Route setup-phase queue and Storyteller utility item clicks.
tag @a remove botc_setup_tool_used
execute if score phase game_data matches 0 as @a[tag=storyteller,scores={botc_hand_use=1..},tag=!botc_setup_tool_used] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["setup_reset_game"]} run function botc_patch:setup_tools/reset_game
execute if score phase game_data matches 0 as @a[tag=storyteller,scores={botc_hand_use=1..},tag=!botc_setup_tool_used] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["setup_become_player"]} run function botc_patch:setup_tools/become_player
execute if score phase game_data matches 0 as @a[tag=!storyteller,tag=!spectator,scores={botc_hand_use=1..},tag=!botc_setup_tool_used] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["setup_become_storyteller"]} run function botc_patch:setup_tools/join_queue
execute if score phase game_data matches 0 as @a[tag=!storyteller,tag=!spectator,scores={botc_hand_use=1..},tag=!botc_setup_tool_used] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["setup_queue_status"]} run function botc_patch:setup_tools/queue_status
execute if score phase game_data matches 0 as @a[tag=!storyteller,tag=!spectator,scores={botc_hand_use=1..},tag=!botc_setup_tool_used] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["setup_leave_queue"]} run function botc_patch:setup_tools/leave_queue
scoreboard players set @a[tag=botc_setup_tool_used] botc_hand_use 0
scoreboard players set @a[tag=botc_setup_tool_used] botc_music_use 0
tag @a remove botc_setup_tool_used
