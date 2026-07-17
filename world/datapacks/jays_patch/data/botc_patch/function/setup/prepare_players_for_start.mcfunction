# Clear stale role state before Sybillian assigns a new script.
execute as @a[tag=!storyteller,tag=!spectator] run function ct:util/reset_player
