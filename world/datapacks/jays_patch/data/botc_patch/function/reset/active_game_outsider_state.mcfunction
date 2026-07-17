# Strip stale previous-game role state from players who are not in the active game.
scoreboard players reset @s id
scoreboard players reset @s role
tag @s remove has_role
tag @s remove nominee
tag @s remove voting_no
tag @s remove voting_yes
tag @s remove expended_ghost
tag @s remove will_die
tag @s remove dead
tag @s remove marked_for_execution
tag @s remove playing_rps
tag @s remove requesting_chat
tag @s remove raising_hand
tag @s remove active_banshee
tag @s remove botc_banshee_double_vote
tag @s remove botc_banshee_toggle_used
clear @s minecraft:carrot_on_a_stick[minecraft:custom_data={botc_banshee_vote_toggle:1b}]
tag @s remove town
tag @s remove townsfolk
tag @s remove outsider
tag @s remove minion
tag @s remove demon
tag @s remove good
tag @s remove evil
scoreboard players operation @s botc_outsider_seen = active_game game_id
