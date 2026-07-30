# Keep the Greedy instructions readable after the first title fades.
execute if score buffet_mode botc_patch matches 1 if score phase game_data matches 0 run title @a[tag=botc_buffet_roster] times 5 50 15
execute if score buffet_mode botc_patch matches 1 if score phase game_data matches 0 run title @a[tag=botc_buffet_roster] subtitle {"text":"You may edit and resubmit until the Storyteller starts the game.","color":"gray"}
execute if score buffet_mode botc_patch matches 1 if score phase game_data matches 0 run title @a[tag=botc_buffet_roster] title {"text":"Choose your characters!","color":"aqua","bold":true}
