# Game Features Shelf

Use this shelf for nominations, raise/lower hand, grimoire reveal, winner
reveal, music, phase behavior, seats, vote markers, and fake-player testing.

## Source Routes

- Main add-on source: `Jays-Patch/datapack/data/botc_patch/function`
- Command-block history: `docs/project-notes/command-block-notes.md`
- Current add-on architecture: `Jays-Patch/README.md`

## Rules

- Use Sybillian's existing game state first: `phase`, `id`, `role`, team tags,
  `vote_marker`, house markers, and Storyteller tags.
- Do not rely on command blocks for reusable behavior. The live world and
  `Jays-Patch/world-template` should stay command-block-free.
- Use `/botc` and Storyteller menu/dialog entrypoints, including the Reveal
  Roles item, as the control surface for winner reveal and late-game actions.
- Only enable Raise/Lower Hand during nominations unless Jay changes that rule.
- Grimoire reveal is a late-game reveal flow and should clean up its own
  displays, temporary items, lights, sounds, and hidden vote-marker visuals.
- Winner reveal should remain suspenseful, clear temporary heads safely, and
  avoid destroying unrelated player state.
- Music should be low-volume, varied, and avoid spamming sounds every tick.

## Verification

- Test phase-specific behavior in at least the relevant active phase and one
  inactive phase.
- Test fake players where possible, then one real non-op player when permissions
  or UI interaction matter.
- After cleanup/reset flows, verify no stale Jay's Patch entities, lamps, items,
  tags, or score state remain.
