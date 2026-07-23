# Recreate the private group on reload, then force active listeners to rejoin once.
persistentgroup remove "Night Chat"
persistentgroup add "Night Chat" open false ct
scoreboard players reset @a[tag=botc_patch_night_chat] botc_night_chat_seen
