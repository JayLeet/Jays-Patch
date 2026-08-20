# Bind this seated player to the active phase window and clear prior entry/tail state.
scoreboard players operation @s botc_seat_guide_window = seat_guide_window botc_patch
scoreboard players set @s botc_seat_guide_entered 0
scoreboard players set @s botc_seat_guide_tail 0
