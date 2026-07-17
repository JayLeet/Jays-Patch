$execute if score $(character) role_list matches 1 run return run function botc_patch:setup_wall/disable {character:"$(character)",name:"$(name)"}
$function botc_patch:setup_wall/enable {character:"$(character)",name:"$(name)"}
