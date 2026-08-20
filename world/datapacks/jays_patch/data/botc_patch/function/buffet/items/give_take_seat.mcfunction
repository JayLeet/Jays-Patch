# Offer only explicitly emptied Buffet seats to unseated players and spectators.
clear @s minecraft:carrot_on_a_stick[minecraft:custom_data~{botc_buffet_take_seat:1b}]
item replace entity @s hotbar.0 with minecraft:carrot_on_a_stick[minecraft:custom_model_data={strings:["buffet_take_seat"]},minecraft:custom_data={botc_patch_tool:1b,botc_buffet_tool:1b,botc_buffet_take_seat:1b},custom_name=[{text:"Take Open Seat",color:"green",bold:false,italic:false},{text:" [Right-Click]",color:"gray",bold:false,italic:false}]]
