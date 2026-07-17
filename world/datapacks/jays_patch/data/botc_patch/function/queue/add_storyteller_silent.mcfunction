# Apply Sybillian Storyteller state without Sybillian's chat messages.
execute unless entity @s[tag=storyteller] run team join 99_storyteller @s
execute unless entity @s[tag=storyteller] run fmvariable set storyteller false true
tag @s add storyteller
function ct:admin/give_script
