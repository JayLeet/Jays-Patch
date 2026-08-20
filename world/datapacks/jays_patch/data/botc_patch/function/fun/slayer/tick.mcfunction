# Route only right-clicks made while the Slayer's Bow is selected.
execute as @a[scores={botc_fun_slayer_use=1..}] if data entity @s SelectedItem.components."minecraft:custom_model_data"{strings:["botc_fun_slayer"]} run function botc_patch:fun/slayer/shoot
scoreboard players set @a[scores={botc_fun_slayer_use=1..}] botc_fun_slayer_use 0
