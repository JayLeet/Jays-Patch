# Route Buffet items and player-safe trigger actions only inside the owned mode.
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1.. as @a run scoreboard players enable @s botc_buffet_action
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1..2 as @a[tag=botc_buffet_roster] run function botc_patch:buffet/roster/validate_return

tag @a remove botc_buffet_action_used
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 as @a[tag=botc_buffet_roster,scores={botc_hand_use=1..},tag=!botc_buffet_action_used] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_buffet_choices:1b} run function botc_patch:buffet/greedy/open
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 as @a[tag=storyteller,scores={botc_hand_use=1..},tag=!botc_buffet_action_used] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_buffet_review:1b} run function botc_patch:buffet/greedy/review/open
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 as @a[tag=storyteller,scores={botc_hand_use=1..},tag=!botc_buffet_action_used] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_buffet_start:1b} run function botc_patch:buffet/greedy/start/try
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1 if score buffet_roster_locked botc_patch matches 0 as @a[tag=!storyteller,tag=!botc_buffet_roster,scores={botc_hand_use=1..},tag=!botc_buffet_action_used] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_buffet_take_seat:1b} run function botc_patch:buffet/roster/take_open_seat
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 as @a[tag=botc_buffet_draft_current,tag=!storyteller,scores={botc_hand_use=1..},tag=!botc_buffet_action_used] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_buffet_choices:1b} run function botc_patch:buffet/draft/open_current
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 as @a[tag=storyteller,scores={botc_hand_use=1..},tag=!botc_buffet_action_used] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_buffet_review:1b} run function botc_patch:buffet/draft/review/open
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 as @a[tag=storyteller,scores={botc_hand_use=1..},tag=!botc_buffet_action_used] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_buffet_start:1b} run function botc_patch:buffet/draft/start/try
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 2 as @a[tag=!storyteller,tag=!botc_buffet_roster,scores={botc_hand_use=1..},tag=!botc_buffet_action_used] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_buffet_take_seat:1b} run function botc_patch:buffet/draft/roster/take_open_seat
execute if score phase game_data matches 0 if score buffet_mode botc_patch matches 1..2 as @a[scores={botc_hand_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_data"{botc_buffet_tool:1b} run tag @s add botc_buffet_action_used
scoreboard players set @a[scores={botc_hand_use=1..},tag=botc_buffet_action_used] botc_hand_use 0
scoreboard players set @a[scores={botc_music_use=1..},tag=botc_buffet_action_used] botc_music_use 0
tag @a remove botc_buffet_action_used

execute as @a[scores={botc_buffet_action=1..}] run function botc_patch:buffet/handle_action
