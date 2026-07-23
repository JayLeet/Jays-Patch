# Open the dialog-first dashboard that matches the current game phase.
execute unless entity @s[tag=storyteller] run return 0
execute unless score patch_items_enabled botc_patch matches 1 run return 0
execute unless score patch_dialog_mode botc_patch matches 1 run return 0
execute if score phase game_data matches 3 unless score boomdandy_stage botc_patch matches 2 if entity @a[tag=botc_st_last_executed,scores={id=1..15,role=107},limit=1] run return run function botc_patch:storyteller_tools/boomdandy/start
function botc_patch:grim/notifications/prepare_dashboard
function botc_patch:grim/notifications/acknowledge_outer
data modify storage botc_patch:grim notifications.boomdandy_font set value "botc_patch:role_icons"
execute if score grim_notice_boomdandy_done botc_patch matches 0 run data modify storage botc_patch:grim notifications.boomdandy_font set value "botc_patch:role_icons_notification"
execute if score phase game_data matches 1..2 run function botc_patch:storyteller_tools/dashboard/day with storage botc_patch:grim notifications
execute if score phase game_data matches 3 if entity @s[tag=botc_st_post_execution,tag=botc_st_post_kill_resolved] if entity @a[tag=botc_st_last_executed,scores={id=1..15,role=107}] run function botc_patch:storyteller_tools/dashboard/post_execution_resolved_boomdandy with storage botc_patch:grim notifications
execute if score phase game_data matches 3 if entity @s[tag=botc_st_post_execution,tag=botc_st_post_kill_resolved] unless entity @a[tag=botc_st_last_executed,scores={id=1..15,role=107}] run function botc_patch:storyteller_tools/dashboard/post_execution_resolved with storage botc_patch:grim notifications
execute if score phase game_data matches 3 if entity @s[tag=botc_st_post_execution,tag=!botc_st_post_kill_resolved] if entity @a[tag=botc_st_last_executed,scores={id=1..15,role=107}] run function botc_patch:storyteller_tools/dashboard/post_execution_boomdandy with storage botc_patch:grim notifications
execute if score phase game_data matches 3 if entity @s[tag=botc_st_post_execution,tag=!botc_st_post_kill_resolved] unless entity @a[tag=botc_st_last_executed,scores={id=1..15,role=107}] run function botc_patch:storyteller_tools/dashboard/post_execution with storage botc_patch:grim notifications
execute if score phase game_data matches 3 unless entity @s[tag=botc_st_post_execution] run function botc_patch:storyteller_tools/dashboard/nomination with storage botc_patch:grim notifications
execute if score phase game_data matches 4 run function botc_patch:storyteller_tools/dashboard/night with storage botc_patch:grim notifications
execute unless score phase game_data matches 1..4 run tellraw @s {text:"Storyteller Tools aren't available in this phase.",color:"red"}
