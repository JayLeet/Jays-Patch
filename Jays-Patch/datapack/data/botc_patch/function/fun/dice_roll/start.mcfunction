execute if score @s botc_fun_dice_cooldown matches 1.. run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can only roll the die once per minute.","color":"gray","bold":false}]
execute if score fun_dice_active botc_patch matches 1 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"The die is already rolling.","color":"gray","bold":false}]
function botc_patch:fun/dice_roll/begin
