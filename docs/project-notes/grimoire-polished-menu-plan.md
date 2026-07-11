# Grimoire Polished Menu Plan

Last updated: 2026-07-11

## Evidence

- The current Reveal Grimoire source remains a one-page vanilla dialog based on
  active seat count, but now resolves literal `Player (Role)` labels from the
  immutable game-start/reveal snapshot.
- Static seat buttons have opened reliably and clicked correctly as a non-op
  Storyteller.
- Clicking an already revealed seat gives direct feedback instead of silently
  clearing the dialog.
- Real-client testing showed gray no-action vanilla dialog entries still behave
  like pressable buttons, so they are not true disabled buttons.
- A grouped seat-range menu removed revealed buttons reliably, but Jay rejected
  that UX because it changed the one-page Reveal Grimoire behavior.
- A flat generated bitmask menu could remove revealed seats without grouping,
  but it produced 32,768 generated functions. Reloading that version hung long
  enough for the server watchdog to stop the container, so that path is rejected
  for live use.
- Selector and dynamic-NBT text remain unsupported for these button labels.
  Literal macro labels are generated from trusted `ct:players` and role catalog
  storage, and Jay verified the production-sized implementation in the real
  client.
- Sybillian already has a FancyMenu grimoire surface, but changing that visual
  shell would require client-side files and is not a server-side-only solution.

## Inference

The exact combination "one-page vanilla dialog, remove arbitrary revealed
buttons, server-side only, and no large generated state matrix" is not currently
proven feasible in datapack form.

The safest behavior remains the lightweight one-page seat-count dialog plus
clear already-revealed feedback. Literal snapshot-backed player and role labels
can improve that same design without grouped menus or a large state matrix.

## Recommendation

Keep the stable one-page count-based dialog live:

- no grouped seat ranges;
- no 32,768-function flat bitmask menu;
- no grey pressable fake-disabled buttons;
- literal `Player (Role)` labels from the confirmed reveal snapshot;
- Townsfolk, Outsider, Minion, and Demon category colors;
- Good Wins and Evil Wins alone on the first row;
- already-revealed seats remain visible for now and report that they were
  already revealed.

Only revisit removed revealed-seat buttons if a new server-side UI path is
proven with a small test that does not require a huge generated state matrix.

## Stable Baseline

Do not break or remove these while games depend on them:

- `botc_patch:grim/dialog`
- `botc_patch:grim/dialog/count_0` through
  `botc_patch:grim/dialog/count_15`
- `/botc grimoire reveal_seat_1` through `/botc grimoire reveal_seat_15`
- grimoire start confirmation and one-time sweep
- role snapshot capture on grimoire start
- offline-safe reveal from snapshot
- current role icon, role text, spotlight, particles, and reveal jingles
- Good Wins and Evil Wins buttons inside the Reveal Grimoire dialog

## Rejected Routes

- Grey no-action dialog buttons: visually grey but still pressable.
- Grouped seat ranges: technically worked, but changed the UX Jay wanted.
- Flat 32,768-mask generated menu: preserves UX and removes buttons, but caused
  reload/watchdog instability and painful deploy/runtime-sync cost.
- FancyMenu replacement: not server-side-only because every client would need
  matching layout files.

## Future Polish Target

Future polish can still explore role icons or real disabled states, but only
behind a dev-only proof until the UI path is proven reliable.

Any future attempt must prove:

- it stays one-page unless Jay explicitly approves grouping;
- it does not require client-side files;
- it works for a real non-op Storyteller;
- it does not trigger reload instability, command spam, or watchdog crashes;
- it keeps Good Wins and Evil Wins available.
