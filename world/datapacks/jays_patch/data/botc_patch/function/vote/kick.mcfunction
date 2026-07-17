# Start or cast a votekick for one online target.
execute if score @s botc_vote_cd matches 1.. run return run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":"Wait a moment before voting again.","color":"gray","bold":false}]
tag @a remove botc_vote_selected
$tag $(target) add botc_vote_selected
execute unless entity @a[tag=botc_vote_selected] run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"That player is not online.","color":"gray","bold":false}]
execute if entity @s[tag=botc_vote_selected] run tag @s add botc_vote_self
execute if entity @s[tag=botc_vote_self] run return run function botc_patch:vote/self_target
execute if entity @a[tag=botc_vote_selected,tag=botc_owner] run return run function botc_patch:vote/target_immune
execute if entity @a[tag=botc_vote_selected,tag=botc_vote_target] run return run function botc_patch:vote/cast_current
execute if entity @a[tag=botc_vote_target] run return run function botc_patch:vote/other_active
function botc_patch:vote/start
function botc_patch:vote/cast
