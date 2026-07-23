tag @s remove botc_patch_night_chat
scoreboard players reset @s botc_night_chat_seen
voicechat leave
scoreboard players set @s vc 0
function ct:loop/player/join_vc
