# Place a safe temporary level-1 light for the grimoire reveal sweep.
execute if block ~ ~1 ~ minecraft:air run setblock ~ ~1 ~ minecraft:light[level=1] replace
execute if block ~ ~1 ~ minecraft:light run setblock ~ ~1 ~ minecraft:light[level=1] replace
