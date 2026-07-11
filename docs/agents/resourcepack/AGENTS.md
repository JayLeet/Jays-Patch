# Resource Pack Shelf

Use this shelf for custom textures, item models, role icons, model data,
resource-pack URL/SHA/id, and client rendering checks.

## Source Routes

- Resource-pack source: `Jays-Patch/resourcepack`
- Resource-pack code map: `docs/code-library/resourcepack-map.md`
- Resource-pack mapping check: `tools/tests/test-resourcepack-mappings.ps1`
- Startup resource-pack build/deploy: `launcher/exe/BotcLauncher.cs`
- Server resource-pack settings: `launcher/local-settings.example.properties` and
  `data/server.properties`

## Rules

- Keep `Jays-Patch/resourcepack` as a wiring overlay when possible.
- Role icon source art still comes from Sybillian, but item models should use
  generated copies under `assets/botc_patch/textures/item/role`. Direct
  `ct:role/...` item-model references rendered as missing textures in the
  Minecraft client.
- Jay-owned textures, such as custom hand/reveal items, belong under
  `assets/botc_patch/textures`.
- Update model mappings and generated pack metadata together.
- Check `docs/code-library/resourcepack-map.md` before changing model data,
  item models, or textures.
- If the public pack URL changes, update URL, SHA1, and resource-pack id
  consistently.
- If the URL, SHA1, or resource-pack id changes in `launcher/exe/BotcLauncher.cs`,
  rebuild `BOTC.exe` with `tools/build-botc-exe.ps1` before restarting the
  server. An older built launcher can rewrite `server.properties` back to stale
  resource-pack values even when the source file is correct.
- `server.properties` must use the SHA1 of the hosted zip URL because clients
  download that zip. Do not block configuration only because a locally rebuilt
  zip has a different archive hash; compare extracted contents when in doubt.
- Public packages must bundle the exact hosted resource-pack archive, not a
  newly compressed local rebuild. Use `tools/build-public-package.ps1`, which
  downloads the configured `resource-pack` URL, verifies `resource-pack-sha1`,
  and copies that exact zip into the fallback resourcepack folder.
- When resource-pack source changes, first run
  `tools/build-resourcepack-from-source.ps1` and upload the produced
  `Jays-Patch-resourcepack-upload.zip`. Only after Jay provides the new hosted
  URL/SHA/id should server settings and the public package be updated.
- Minecraft 1.21.10 Jay-owned carrot/paper visuals must use
  `minecraft:custom_model_data` strings and the root selector files:
  `assets/minecraft/items/carrot_on_a_stick.json` and
  `assets/minecraft/items/paper.json`. Those selector files must use
  `property: minecraft:component`, `component: minecraft:custom_model_data`,
  and `when.strings` cases, matching the first working June 21 texture
  implementation.
- Do not add `minecraft:item_model` to Jay-owned datapack item stacks unless Jay
  explicitly approves a new rendering migration after fresh evidence. That path
  caused the repeated carrot/purple-black regression.
- If players see vanilla `carrot_on_a_stick`, prove three things in order:
  the live item has the expected `minecraft:custom_model_data` string, the
  downloaded pack contains the root selector file, and that selector has a
  `when.strings` case for the same custom-model-data string.

## Verification

- Run `tools/tests/test-resourcepack-mappings.ps1` after item, role-icon, or custom
  model data changes.
- Run `tools/build-resourcepack-from-source.ps1` before giving Jay a zip to
  upload.
- Run `tools/tests/test-public-package-resourcepack.ps1` after changing the
  public pack URL, SHA1, pack id, or public package zip.
- Confirm the pack builds successfully.
- Verify the server advertises the intended URL/SHA/id.
- In game, verify custom items render as textures, not purple/black missing
  models or plain fallback items.
- Restart may be needed for server resource-pack config changes.

