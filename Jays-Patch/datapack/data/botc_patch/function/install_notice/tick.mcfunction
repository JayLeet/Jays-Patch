scoreboard players enable @a botc_install_notice_disable
execute as @a[scores={botc_install_notice_disable=1..}] run function botc_patch:install_notice/disable
scoreboard players set @a[scores={botc_install_notice_disable=1..}] botc_install_notice_disable 0
execute unless score install_notice_disabled botc_patch matches 1 as @a[tag=!botc_patch_install_notice_seen] run function botc_patch:install_notice/show
execute unless score install_notice_disabled botc_patch matches 1 as @a[tag=!botc_patch_install_notice_seen] run scoreboard players operation @s botc_install_seen_leave = @s botc_leave_game
execute unless score install_notice_disabled botc_patch matches 1 run tag @a[tag=!botc_patch_install_notice_seen] add botc_patch_install_notice_seen
execute unless score install_notice_disabled botc_patch matches 1 as @a[tag=botc_patch_install_notice_seen] if score @s botc_leave_game > @s botc_install_seen_leave run function botc_patch:install_notice/show
execute unless score install_notice_disabled botc_patch matches 1 as @a[tag=botc_patch_install_notice_seen] if score @s botc_leave_game > @s botc_install_seen_leave run scoreboard players operation @s botc_install_seen_leave = @s botc_leave_game
