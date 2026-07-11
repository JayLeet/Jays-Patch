# FancyMenu Stability Test Matrix

Last updated: 2026-06-26

This is a source-only planning document. Do not run these live tests during the
current source-only goal.

## Evidence

- Prior live logs showed repeated FancyMenu packet errors before two `Kicked for
  spamming` disconnects:
  - `No codec for packet data found with identifier: spiffy_structures`
  - `No codec for packet data found with identifier:
    spiffy_marker_command_suggestions`
- The stack trace pointed at FancyMenu packet handling rather than Jay's Patch
  datapack tick functions.
- `tools/tests/audit-fancymenu-actions.ps1` found 166 Jay-owned FancyMenu command
  actions and no protected raw command roots.
- `tools/tests/audit-fancymenu-setupbag-bursts.ps1` found four known setup-bag
  multi-command burst sites:
  - `ct-bag_import.txt` Import
  - `ct-bag_layout.txt` Trouble Brewing
  - `ct-bag_layout.txt` Sects & Violets
  - `ct-bag_layout.txt` Bad Moon Rising
- The stable static Reveal Grimoire seat menu works as a non-op Storyteller and
  should remain the live fallback until a replacement is proven.

## Inference

The codec errors may be caused by a client/server mod-version mismatch, an
upstream FancyMenu/SpiffyHUD packet issue, or high-volume menu command bursts.
The current evidence does not prove which one is the root cause.

## Recommendation

When Jay starts a live testing goal, test this in narrow slices and compare logs
between each slice. Do not add broad cooldowns or replace the stable grimoire
menu until the cause is proven.

## Version Evidence To Collect

Collect these before changing code:

- server modpack version from the launcher/Modrinth install;
- server-side versions for FancyMenu, SpiffyHUD, Konkrete, Melody, Melius, and
  any related UI dependency;
- client-side versions for the same mods from the exact client Jay is using;
- whether the client is using Sybillian's unmodified 1.5.4 pack plus Jay's
  server resource pack only;
- latest server log lines around join, menu open, setup-bag click, grimoire
  open, and disconnect.

Use this read-only helper for the mod-file comparison:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\tests\live\compare-ui-client-mods.ps1 -ClientModsPath "<player-mods-folder>"
```

If server and client UI dependency versions differ, prefer version alignment
before adding Jay-owned workaround code.

## Live Test Matrix

Run one row at a time with one real non-op Storyteller, then stop and inspect
logs before moving on.

| Test | Jay Overlay State | Action | Expected Result | Evidence To Save |
| --- | --- | --- | --- | --- |
| Baseline join | current live | Join and wait 60 seconds | No codec errors, no spam kick | server log excerpt |
| Open setup bag | current live | Open setup bag, click no preset | No codec errors, no spam kick | server log excerpt |
| Preset burst | current live | Click one preset once | Either clean logs or exact packet/command error | server log excerpt and clicked preset |
| Import burst | current live | Click Import once | Either clean logs or exact packet/command error | server log excerpt |
| Grimoire open | current live | Open Sybillian grimoire UI | Either clean logs or exact packet/command error | server log excerpt |
| Stable reveal menu | current live | Open Reveal Grimoire item menu | Stable menu opens, no codec errors | server log excerpt |
| Overlay isolation | Jay-owned FancyMenu overlays disabled in a test copy only | Repeat failing action | Failure disappears or remains | before/after log excerpts |
| One-command setup bridge | dev-only bridge enabled in a test copy only | Click converted preset once | Client sends one command, setup output matches old flow | log excerpt and setup result |

## Decision Rules

- If the same codec errors happen with Jay-owned overlays disabled, treat the
  issue as upstream/client-version related until proven otherwise.
- If the errors only happen when Jay-owned overlays are active, inspect the exact
  changed layout/action file before changing datapack behavior.
- If errors cluster around setup-bag preset/import buttons, prioritize the
  one-command setup bridge plan over cooldowns.
- If errors cluster around every FancyMenu dialog, do not build the polished
  Reveal Grimoire menu on FancyMenu until version alignment is proven.
- If a player gets kicked for spamming after repeated menu clicks, reduce
  client-sent command bursts first; only add narrow debounce after the command
  burst has been removed.

## Source-Only Checks Before Live Testing

Run these before any live menu rollout:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\audit-fancymenu-actions.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools\audit-fancymenu-setupbag-bursts.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools\test-setupbag-burst-bridges.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tools\test-source-safety.ps1
```

