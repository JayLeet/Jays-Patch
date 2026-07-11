# Kept Systems Live Pass

Date: 2026-06-30

## Evidence

- Jay completed the requested live kept-systems test pass and reported:
  "I finished, and everything works fine."
- The tested scope was the checklist requested by Codex in chat:
  - non-op Storyteller state and `/botc`;
  - custom Setup Bag/setup room/setup controls;
  - live day tools;
  - nomination tools;
  - night tools;
  - Reveal Grimoire;
  - music selector;
  - reset-safe winner/check flows where applicable.
- Runtime sync passed after the test:
  `tools/tests/live/test-runtime-sync.ps1`.
- A post-test log scan found no FancyMenu codec, spam-kick, disconnect, or
  connection-reset matches in the last 60 minutes:
  `tools/tests/live/watch-fancymenu-errors.ps1 -SinceMinutes 60`.
- RCON `list` showed six players online during evidence collection:
  `Jayify420`, `Test1`, `Test2`, `test3`, `test4`, and `test5`.

## Inference

The remaining cleanup-reset live checks are satisfied for the current build
because Jay exercised the systems as a real live user and no matching server log
errors appeared afterward.

The previous FancyMenu codec/spam-kick issue was not reproduced during this
pass. Jay-owned overlays do not need to be disabled for isolation unless the
codec/spam-kick errors return.

## Recommendation

Treat the current TODO list as complete for this stabilization goal. If future
players report menu disconnects, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\tests\live\compare-ui-client-mods.ps1 -ClientModsPath "<their-mods-folder>"
```

Then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\tests\live\watch-fancymenu-errors.ps1 -SinceMinutes 15
```
