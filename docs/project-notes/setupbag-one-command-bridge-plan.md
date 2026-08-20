# Setup Bag Server-Authority Bridge

Last updated: 2026-06-30

## Evidence

- Sybillian's setup bag and FancyMenu flow use Sybillian-style setup commands.
- Prior menu flows could send setup bursts such as `initial_load`,
  `convert_to_ids`, `reminder_tokens`, `characters`, and `night_order`.
- Jay's setup room/bag is now the supported setup UI.
- `Jays-Patch/melius-commands/commands/setupbag.json` remains a guarded
  compatibility command surface because Jay's setup room/bag and older
  Sybillian/FancyMenu paths still route some setup mutations through
  `/setupbag`.
- Local Melius bytecode shows `as_console` raises the command authority while
  preserving the original command entity, so `@s[tag=storyteller]` still checks
  the player who clicked or ran the command.
- `/botc setup...` has been removed as the official setup path and remains
  forbidden in Jay-owned setup-bag menu actions.
- Live testing proved a client can still hold older FancyMenu actions that send
  `/botc setup preset <script>`, `/botc setup clear`, `/botc setup set_from_menu`,
  and `/botc setup role_on|role_off <character>`, so `botc.json` keeps narrow
  stale-client compatibility bridges for those exact setup bag shapes. Preset
  payloads still route through `botc_patch:setup/preset_compat`, which recognizes
  built-in scripts first and otherwise falls back to the safe custom import
  wrapper. High-impact setup bridges now pass through a narrow
  `botc_setup_bridge_cd` cooldown so repeated preset/import/apply/clear clicks
  cannot stack heavy server-side work.
- Prior live logs proved Sybillian's recursive custom script parser can hit
  Minecraft's 65,536-command execution limit.

## Recommendation

Use Jay's setup room/bag as the primary setup flow. Keep `/setupbag` as guarded
compatibility plumbing, not as the active UI goal. Melius runs privileged setup
actions with server authority only after the caller is confirmed as
`tag=storyteller` and the game is still in phase `0`.

Supported compatibility command shapes:

```text
/setupbag role_on <character>
/setupbag role_off <character>
/setupbag role <character> <0|1>
/setupbag clear
/setupbag set_from_menu
/setupbag preset_trouble_brewing
/setupbag preset_sects_and_violets
/setupbag preset_bad_moon_rising
/setupbag import <script-json>
```

Built-in presets still use Jay's direct preset functions internally because
they are known and cheap to run. Public/menu preset, import, clear, and apply
commands enter through `botc_patch:setup/bridge/*` wrappers first, which apply
a short per-Storyteller debounce. Role toggles intentionally stay unthrottled
because rapid checkbox-style clicks are legitimate setup behavior.

Custom imports intentionally call Sybillian's full import sequence. If the
65,536-command limit returns, treat custom import as blocked and move that
specific problem to a dedicated parser or plugin plan.

## Static Audit Contract

- `tools/tests/test-command-overlays.ps1` allows only the narrow
  `/botc setup preset` compatibility bridge under `/botc setup`.
- `tools/tests/test-command-overlays.ps1` verifies privileged Storyteller actions are
  `tag=storyteller` guarded and run as server-authority commands.
- The former Jay-owned FancyMenu source audits were retired with the server-side
  FancyMenu copies. Installed Sybillian layouts remain client-owned and may be
  inspected read-only with `tools/tests/live/audit-runtime-fancymenu-buttons.ps1`.

## Compatibility Check

If legacy Sybillian/FancyMenu setup-bag support becomes relevant again, verify:

- a real non-op Storyteller can toggle roles from the setup bag;
- built-in presets update the setup bag correctly after reopening it;
- custom script import works or fails with clear evidence;
- setup commands do nothing during a live game;
- logs show no unknown command, permission, command-limit, or spam-kick errors.


