# Process dialog-first Storyteller controls through a guarded trigger objective.
execute if score patch_dialog_mode botc_patch matches 1 if score phase game_data matches 1..4 run scoreboard players enable @a[tag=storyteller] botc_st_dialog
execute as @a[scores={botc_st_dialog=1..}] run function botc_patch:storyteller_tools/dashboard/route
scoreboard players set @a[scores={botc_st_dialog=1..}] botc_st_dialog 0
