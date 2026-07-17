# Restore the server value captured before the first active Passage opened.
execute if score passage_chunks_previous botc_patch matches 0 run gamerule spectatorsGenerateChunks false
execute if score passage_chunks_previous botc_patch matches 1 run gamerule spectatorsGenerateChunks true
scoreboard players set passage_chunks_forced botc_patch 0
