# Do not restore out of spectator mode while the Storyteller is inside a wall.
execute if block ~ ~ ~ #botc_patch:safe_body_space if block ~ ~1 ~ #botc_patch:safe_body_space run function botc_patch:storyteller_tools/passage/finish
execute unless block ~ ~ ~ #botc_patch:safe_body_space run title @s actionbar [{"text":"Move into open space to return.","color":"yellow"}]
execute if block ~ ~ ~ #botc_patch:safe_body_space unless block ~ ~1 ~ #botc_patch:safe_body_space run title @s actionbar [{"text":"Move into open space to return.","color":"yellow"}]
