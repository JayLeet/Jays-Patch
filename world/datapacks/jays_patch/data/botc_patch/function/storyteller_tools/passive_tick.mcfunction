# Maintain non-item Storyteller state even when Jay-owned held tools are disabled.
function botc_patch:storyteller_tools/night
function botc_patch:storyteller_tools/passage/tick
execute unless score phase game_data matches 1..2 as @a[tag=storyteller,tag=botc_st_revive_menu] run function botc_patch:storyteller_tools/revive_menu/close
execute unless score phase game_data matches 1..2 as @a[tag=storyteller,tag=botc_st_kill_menu] run function botc_patch:storyteller_tools/kill_menu/close
execute unless score phase game_data matches 3 as @a[tag=storyteller,tag=botc_st_nom_menu] run function botc_patch:storyteller_tools/nomination_menu/close
execute unless score phase game_data matches 3 run tag @a remove botc_st_post_execution
