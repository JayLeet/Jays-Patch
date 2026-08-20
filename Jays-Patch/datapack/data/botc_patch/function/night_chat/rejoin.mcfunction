execute unless score @s botc_leave_game matches -2147483648..2147483647 run scoreboard players set @s botc_leave_game 0
scoreboard players operation @s botc_night_chat_seen = @s botc_leave_game
voicechat join "Night Chat" ct
