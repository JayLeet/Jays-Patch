# Spectator players do not load destination chunks when this gamerule is false.
execute unless score passage_chunks_forced botc_patch matches 1 store result score passage_chunks_previous botc_patch run gamerule spectatorsGenerateChunks
execute unless score passage_chunks_forced botc_patch matches 1 run scoreboard players set passage_chunks_forced botc_patch 1
gamerule spectatorsGenerateChunks true
