# Wrap Sybillian's role display edit, then mirror it into Jay's reveal state.
$function ct:cmd/character {id:$(id),character:$(character)}
$execute as @a[scores={id=$(id)},limit=1] run fmvariable set role false $(character)
data remove storage botc_patch:character request
$data modify storage botc_patch:character request set value {id:$(id),character:"$(character)"}
scoreboard players set character_matched botc_patch 0
$function botc_patch:cmd/character/sync_role {id:$(id),character:$(character)}
$execute unless score character_matched botc_patch matches 1 run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Jay's Patch could not sync that character into reveal data: ","color":"gray","bold":false},{"text":"$(character)","color":"yellow"}]
data remove storage botc_patch:character request
