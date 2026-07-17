# Remove stale Storyteller state from someone who rejoined after another Storyteller was promoted.
tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"Your previous Storyteller turn has ended.","color":"gray","bold":false}]
function botc_patch:reset/player_state
