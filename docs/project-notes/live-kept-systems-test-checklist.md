# Live Kept Systems Test Checklist

Last updated: 2026-06-30

## Evidence

- Source safety currently passes.
- Runtime sync currently passes for Jay's Patch datapack, Melius command
  overlays, and owned FancyMenu files.
- Jay completed the live kept-systems pass on 2026-06-30 and reported that
  everything worked fine.
- Post-test runtime sync passed.
- Post-test FancyMenu/codec/spam-kick/disconnect log scan found no matches in
  the last 60 minutes.

## Inference

The kept systems are likely stable because Jay has already tested most of them
successfully after the recent fixes. The TODO should stay open until the result
is recorded against each system in one focused pass.

## Recommendation

This checklist is complete for the current stabilization goal. If a future live
bug appears, stop the pass, record the exact button/command, current phase,
player state, and log excerpt, then fix that one issue before continuing.

## Preflight

- [x] Confirm the server is running and healthy.
- [x] Confirm the tester is not OP.
- [x] Confirm Jay's Patch runtime files match source:
  `tools/tests/live/test-runtime-sync.ps1`.
- [x] Confirm source safety passes:
  `tools/tests/test-source-safety.ps1`.
- [x] Start a bounded log scan before and after testing:
  `tools/tests/live/watch-fancymenu-errors.ps1 -SinceMinutes 10`.
- [x] Optional shortcut: create a dated preflight report with
  `tools/tests/live/new-kept-systems-test-report.ps1`.

## Queue And Core Commands

- [x] During setup, use the queue item or `/botc queue`.
  Expected: the player becomes or queues for Storyteller through the queue flow.
- [x] Run `/botc`.
  Expected: help text appears, not an unknown/incomplete command.
- [x] Run `/botc queue status`.
  Expected: queue status appears.
- [x] Use Become a Player during setup.
  Expected: Storyteller state is removed only by that item.

## Setup Room And Setup Bag

- [x] Open the replacement Setup Bag.
  Expected: Storyteller teleports to the setup room and receives the setup-room
  controls.
- [x] Select TB, SNV, BMR, and Custom Script in separate quick checks.
  Expected: wall updates, roles start disabled, and previous hotbar states are
  cleaned.
- [x] Toggle at least one good role and one evil role on the wall.
  Expected: selected roles are visually clear and reflected in setup state.
- [x] Use Clear Setup, Use This Bag, and Start in a controlled test.
  Expected: Sybillian setup behavior is called through Jay's Patch, no stale
  roles from a previous setup remain, and start moves into the intended game
  flow.

## Grimoire Reveal

- [x] Start Reveal Grimoire and confirm the reveal.
  Expected: sweep runs once before the first reveal.
- [x] Open the Reveal Grimoire dialog.
  Expected: one page with Good Wins, Evil Wins, and `Reveal Seat <n>` buttons
  for the active seat count; no grouped seat ranges.
- [x] Reveal one good and one evil test player.
  Expected: correct role icon, text, color, particles, light, and sound family.
- [x] Click an already revealed seat.
  Expected: clear already-revealed feedback, no broken menu behavior.
- [x] Use Good Wins and Evil Wins from the reveal menu in separate reset-safe
  tests.
  Expected: title/sound/head flow works and cleans up.

## Storyteller Live Tools

- [x] Day phase: test Advance Phase, Teleport Seats, Storyteller's Passage,
  Kill, Revive, and Timer.
  Expected: each item appears only in the intended phase and cleans up after use.
- [x] Night phase: test Reset Game, Advance Phase, Teleport Home, Teleport Evil
  Team, and Teleport to Player.
  Expected: night-only tools appear only at night, teleport messages are short,
  and sounds play where intended.
- [x] Nomination phase: test Nominate, Start Vote, Mark, Pyre, Execute, Timer,
  and post-execution Kill/Next Phase.
  Expected: nomination tools do not leak into other phases and execute/kill run
  once.

## Raise/Lower Hand

- [x] Outside nomination phase, confirm no Raise/Lower Hand item remains.
- [x] During nomination phase, raise and lower hand.
  Expected: item toggles, lamp appears and clears, no dropped/duplicated copy
  survives.

## Music

- [x] During night, confirm automatic music plays for a non-Storyteller player.
- [x] Use Music Selector: stop, random, choose a track, resume, and Toggle
  Pitch.
  Expected: selected sounds follow the client and do not leave old tracks stuck.

## Votekick And Owner Immunity

- [x] Start a votekick against a normal test target.
  Expected: votes count, expire after two minutes, and only kick on success.
- [x] Attempt a votekick against an owner.
  Expected: owner immunity blocks the target.
- [x] If a Storyteller is votekicked in a controlled test, confirm Storyteller
  state is removed before the kick.

## Reset

- [x] Reset during setup.
  Expected: setup state clears and current Storyteller remains Storyteller unless
  they use Become a Player.
- [x] Reset during a live game.
  Expected: players return to player state, temporary Storyteller powers are
  removed, nomination/vote state clears, and players are not force-teleported to
  spawn.
- [x] Reset after a Storyteller leaves mid-game, then have them rejoin.
  Expected: stale Storyteller-only state does not return.

## FancyMenu Codec/Spam-Kick Evidence

Use `docs/project-notes/fancymenu-stability-test-matrix.md` for the detailed
matrix. Minimum evidence for this pass:

- [x] Join and wait 60 seconds as the test client.
- [x] Open Sybillian setup/grimoire-related FancyMenu surfaces that are still
  present.
- [x] Click a few known safe buttons once each.
- [x] Run `tools/tests/live/watch-fancymenu-errors.ps1 -SinceMinutes 15`.
  Expected: either no matching codec/spam-kick lines, or exact log lines are
  saved for the next fix.
- [x] If a specific player reports disconnects, compare their client UI jars:
  `tools/tests/live/compare-ui-client-mods.ps1 -ClientModsPath <their-mods-folder>`.
  Expected: FancyMenu, SpiffyHUD, Konkrete, Melody, and Melius Commands match
  the server by jar name, size, and SHA1 before blaming Jay's Patch datapack
  behavior.

## Completion Rule

Only check off the parent TODO when every relevant kept system above has either:

- passed with one real non-op Storyteller; or
- been intentionally scoped out with Jay's approval and a reason.
