# BOTC Storyteller Plugin TODO

## Evidence

- The BOTC reset function exists at `data/resources/datapack/required/ct/data/ct/function/admin/reset_game.mcfunction`.
- The FancyMenu reset confirmation sends `/function ct:admin/reset_game`.
- The current active world is `data/saves/world`.

## Goal

Build a server-side Fabric plugin that manages storyteller turns, protects players from storyteller abuse, and restores the BOTC world after each completed/reset game.

## Core Flow

- [ ] Detect when `/function ct:admin/reset_game` is run.
- [ ] Treat that as the end of the current storyteller turn.
- [ ] Remove temporary storyteller permissions from everyone.
- [ ] Save required queue/state data before shutdown.
- [ ] Stop the server cleanly.
- [ ] Restore `data/saves/world` from a preserved clean world snapshot.
- [ ] Restart the server.
- [ ] Keep the storyteller queue after restart.

## World Restore

- [ ] Preserve the clean world snapshot at `world-template`.
- [ ] Initial snapshot should be copied from the current `data/saves/world`.
- [ ] Never copy the world while Minecraft is actively writing to it.
- [ ] Restore by replacing `data/saves/world` with `world-template`.
- [ ] Let Jay manually update `world-template` later when the desired clean world changes.
- [ ] If restore fails, stop startup and write a clear recovery error instead of loading a broken world.

## Storyteller Queue

- [ ] Let players join the storyteller queue.
- [ ] Let players leave the storyteller queue.
- [ ] Let players check the queue/status.
- [ ] Save the queue to disk so it survives restarts.
- [ ] Prioritize whoever has waited longest.
- [ ] If an active storyteller is online, keep the queue waiting.
- [ ] If the active storyteller goes offline, remove their temporary permissions.
- [ ] Notify online queued players that a storyteller slot is available.
- [ ] Promote the longest-waiting online queued player.
- [ ] After a storyteller finishes a turn, return them to normal player state.

## Storyteller Permissions

- [ ] Use custom permissions instead of full OP.
- [ ] Allow storyteller to make themselves invisible.
- [ ] Allow storyteller to use any gamemode.
- [ ] Allow storyteller to build.
- [ ] Allow storyteller to teleport to any player.
- [ ] Preserve the BOTC permissions storytellers already have today.
- [ ] Block storyteller from banning players.
- [ ] Block storyteller from directly kicking players.
- [ ] Keep Jayify420 owner-immune from queue and votekick restrictions.

## Voting

- [ ] Add player votekick.
- [ ] Add storyteller votekick.
- [ ] Majority means more than 50% of online players, excluding the target.
- [ ] Add vote timeouts so unfinished votes expire.
- [ ] Add vote cooldowns so players cannot spam vote attempts.
- [ ] Only run the kick after the vote succeeds.

## Commands

- [ ] `/storyteller queue`
- [ ] `/storyteller leave`
- [ ] `/storyteller status`
- [ ] `/storyteller vote-kick <player>`
- [ ] `/storyteller vote-remove`
- [ ] `/storyteller help`

## Logging

- [ ] Log reset detection.
- [ ] Log storyteller assignment/removal.
- [ ] Log queue joins/leaves.
- [ ] Log successful and failed votes.
- [ ] Log permission grants/removals.
- [ ] Log shutdown/restart requests.
- [ ] Log world restore success/failure.

## Implementation Notes

- This should be a server-side Fabric plugin, not just a datapack.
- The plugin should not require giving players full OP.
- A small external restart helper may be needed, because a Minecraft mod can stop the server but cannot reliably restart its own Java process after it exits.
- The existing `startup-script.ps1`/Docker launcher is the likely place to run that restart helper.
- Recovery mode should be fail-safe: if the world restore cannot be completed, keep the server stopped and show a clear message in logs/console.

## Open Checks Before Coding

- [ ] Confirm whether the current permission system can grant only the required storyteller powers.
- [ ] Decide whether to use LuckPerms-style permissions, Fabric Permissions API, or a small custom command interceptor.
- [ ] Confirm exact BOTC commands storytellers currently rely on.
- [ ] Confirm the safest restart handoff between the Fabric plugin, Docker, and `startup-script.ps1`.
