# Repair the Storyteller's Buffet reset tool in the former setup-bag slot.
clear @s minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_reset_game"]}]
item replace entity @s hotbar.6 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["setup_reset_game"]},minecraft:custom_data={botc_patch_tool:1b},custom_name=[{text:"Reset Game",color:"red",bold:false,italic:false},{text:" [Right-Click]",color:"gray",bold:false,italic:false}]]
