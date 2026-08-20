# Paint Gun

- Status: `live-retest-pending`
- Updated: `2026-08-04 16:40 CEST`
- Owner: Sol
- Workflow decision: `use Sol/Luna workflow`
- Workflow reason: `This player-facing toy crosses the command overlay, item-use routing, raycast behavior, reset cleanup, item registry, tests, and likely resource-pack assets; a reviewed plan is worth the small journal cost.`
- `/plan` state: `accepted`

## Outcome

Add a new Paint Gun toy under `/botc fun` with behavior agreed with Jay.

## Done when

- [x] `/botc fun paint_gun` gives a gun that shoots the player's assigned colour, while `/botc fun rainbow_paint_gun` gives a gun that randomly chooses from the agreed concrete palette per shot.
- [x] Paint shots temporarily cover only eligible full-cube blocks with concrete visuals and never change real world blocks.
- [x] Both guns produce coloured splash particles and spread cosmetic paint from the hit block to nearby eligible full blocks.
- [x] Paint cannot interfere with live-game assets such as voice-chat areas, the pyre, or seats.
- [x] Reload and game reset leave no tracked Paint Gun state or effects behind.
- [x] Focused source checks and the reviewed package/live deployment gate pass.
- [ ] In-game manual review confirms the final item visuals and shot feel.
- [ ] Both guns visibly launch a snowball and paint only when that projectile reaches an eligible block.
- [ ] Each Rainbow impact paints several different allowed colours across a random five-block splash instead of one colour in a fixed plus shape.
- [ ] A Paint Gun snowball that hits a player plays the supplied splat sound, surrounds them with the gun-matched burst, and paints up to ten eligible nearby blocks without damaging them.
- [x] A reviewed launcher restart deploys resource-pack settings before Minecraft starts, so the next client connection receives the current pack rather than the previous cached pack.

## Scope and boundaries

- In scope: `Jays-Patch` command overlay, `botc_patch:fun` functions, item/loot registration, required resource-pack assets, focused tests, and source documentation.
- Non-goals: Unrequested gameplay changes outside the complete current `Jays-Patch` source Jay explicitly authorized for deployment.
- Must preserve: Existing `/botc fun` toys, shared right-click routing, reset behavior, the current dirty worktree, live player/server data, and Sybillian-owned behavior.
- Safety constraints: Paint is cosmetic and temporary, uses only concrete block appearances, targets only eligible full blocks, excludes signs, and must not affect required live-game assets. Paint functions must not contain world-changing commands. Do not mutate the live server while planning.

## Evidence

- `/botc fun` currently contains `sillyjuice`, `boomdandy`, `hot_potato`, and `dice_roll`, each dispatched from `Jays-Patch/melius-commands/commands/botc.json`.
- `fun/tick.mcfunction` routes most toy right-clicks through `botc_fun_item_use`; Slayer has an independent use statistic.
- Existing Slayer and Hot Potato code provides quarter-block raycasts that stop at solid blocks and safely identify players.
- `fun/load.mcfunction`, `fun/reset.mcfunction`, `tool-items.json`, resource models, loot tables, and `tools/tests/test-fun-toybox.ps1` are established integration points.
- Sybillian voice groups read real marker blocks 64 blocks below each player; a cosmetic display cannot alter those markers.
- The custom Boomdandy pyre uses separately tagged `block_display` entities, so Paint Gun cleanup can remain isolated to a Paint Gun-specific tag.
- Seat and house visuals are entity-based; a block-only Paint Gun raycast does not need to target or modify them.
- The server assigns seated players to 15 fixed colour teams: Red, Orange, Yellow, Lime, Green, Mint, Cyan, Blue, Navy, Purple, Magenta, Lavender, White, Gray, and Black.
- Vanilla concrete has 16 different dye colours and has no exact Mint, Navy, or Lavender blocks; it instead includes Light Blue, Light Gray, Pink, and Brown.
- A read-only scan of all 11,447 chunks in the tracked world template found 487 actual block types, including partial blocks, signs, foliage, fluids, containers, and structural full cubes.
- Pixel-art research supports a strong small-scale silhouette, limited palette, deliberate pixel clusters, and avoiding noisy detail, banding, and pillow shading.
- Original transparent Paint Gun and Rainbow Paint Gun concept images now exist outside the source tree for Jay's review. Both use one chunky sprayer silhouette; the normal version uses cyan paint accents and the Rainbow version uses the agreed bright palette.
- A direct 18x18 nearest-neighbour reduction of the high-resolution concepts failed visually: it produced muddy colour clusters and a weak silhouette. Jay rejected those previews, and they must not be used as pack assets.
- The relevant existing 18x18 pack items use hard transparent edges, a strong dark outline, flat colour clusters, and only a few highlights. Revised 18x18 previews were drawn natively on the pixel grid using those constraints.
- Jay supplied a refined normal Paint Gun sprite with a simpler solid cyan tank. Its 18x18 logical pixels were recovered exactly from the enlarged preview, with the checkerboard converted back to transparency.
- A revised Rainbow preview now preserves that supplied sprite's exact silhouette, body, handle, highlights, and tank shape. Only the cyan paint pixels are replaced by deliberate rainbow clusters.
- Jay then supplied his preferred Rainbow Paint Gun as a 360x360 nearest-neighbour preview of an 18x18 grid. The logical pixels were recovered 1:1 into a transparent 18x18 PNG; regenerating the checkerboard preview produced zero differing pixels across all 129,600 source pixels.
- Before source integration, Jay supplied a final native 18x18 Rainbow PNG with one visible pixel changed at `(9,10)`: yellow `#F9D22F` became the outline colour `#1E161F`. Transparent-pixel RGB differences are visually irrelevant. This latest native PNG supersedes the recovered preview version.
- The worktree already contains unrelated Greedy ability and dialog changes that must be preserved.
- The user-provided MC-Packs upload downloads byte-for-byte as the reviewed source resource pack: SHA-1 `6fd474cfe30b187069f40e062b49dabd175fd2d1`, 199,274 bytes.
- The reviewed launcher completed a clean server-only restart, post-startup source sync, datapack reload, YAWP initialization, and startup flag update.
- The client download log proves the 2026-08-04 14:39 CEST connection was still served resource-pack ID `e7db518a-f75f-40d9-9829-a6928575f647` with SHA-1 `a2252495a735233c64b00d500ffdad7a092edfb3`; no cache entry exists for the configured `74b65f51-ea02-4bd3-a49c-e1b4290024d0` pack.
- `RestartMinecraftServerOnly()` currently stops and starts Minecraft before calling `PostStartupSync()`. `BuildJaysPatchResourcePack()` writes the resource-pack URL, SHA-1, and UUID during that post-startup sync, after Minecraft has already read `server.properties`.
- The old cached `a225…` resource pack contains zero Paint Gun assets. The two source PNGs themselves decode correctly, use the same 18x18 RGBA PNG format as a working fun-item texture, and their model/texture paths are structurally valid.
- Jay supplied `ralsei-splat.mp3`; it is a 0.736-second, 44.1 kHz stereo MP3. The source integration converts it to a 44.1 kHz mono Vorbis Ogg for Minecraft.
- Jay confirmed he created the supplied splat sound and permits its redistribution through the hosted server resource pack.
- The new hosted pack downloads byte-for-byte as the reviewed upload ZIP: 211,041 bytes, SHA-1 `4c20eb69b74e8138d55d1ddeb29dc79722335d8d`, resource-pack UUID `d469daa3-17aa-4f4f-8e61-e4dcde432776`.

## Inference

- A non-destructive paint effect can probably reuse the current raycast pattern and colored particles or short-lived display entities.
- A temporary `block_display` can provide a concrete-block appearance without collision, redstone, block updates, or world mutation.
- A custom paintable-block tag is safer than treating every non-replaceable block as a full cube, because stairs, slabs, walls, containers, doors, and other partial blocks are also non-replaceable.
- Building the paintable tag from the tracked world template's structural full-cube palette gives a reviewable boundary and excludes signs and interactive gameplay blocks by default.
- The player's exact team colour can drive matching splash particles, but a vanilla concrete overlay needs an agreed approximation for Mint, Navy, and Lavender.

## Unknowns

- None.

## Recommendations

- Use temporary concrete `block_display` entities rather than block replacement. This keeps the paint cosmetic and makes reset cleanup explicit.
- Reuse the shared right-click objective and let the visible tagged snowball own the complete flight. Keep a paired invisible marker at the snowball's last real position and use quarter-block steps only to inspect the final short segment after impact.
- Use a reviewed `botc_patch` block tag for eligible full-cube targets instead of an unsafe broad `unless #minecraft:replaceable` assumption.
- Treat `rainbow_paint_gun` as the corrected command spelling unless Jay says the typed `rianbow_paint_gun` spelling was intentional.
- Never attempt to restore blocks because that would require world writes and could undo legitimate changes by another system. Instead, forbid `setblock`, `fill`, and `clone`, and remove the cosmetic display if its underlying block changes or becomes ineligible.
- Keep each player's splash particles in their exact BOTC team colour, while mapping the three unavailable concrete names to the nearest accepted concrete appearance.
- Paint the impact block plus up to four randomly selected touching eligible blocks. Refresh an existing paint display on the same block instead of stacking displays.
- Keep paint visible for 20 seconds after its latest hit; reset or reload removes all paint immediately.
- Refuse `/botc fun paint_gun` when the caller has no assigned BOTC player colour and direct them to `/botc fun rainbow_paint_gun`; Rainbow remains available without a seat colour.
- Limit Rainbow random shots to Red, Orange, Yellow, Lime, Green, Cyan, Light Blue, Blue, Purple, Magenta, and Pink concrete. White, Light Gray, Gray, Black, and Brown are excluded only from Rainbow.
- Give Paint Gun and Rainbow Paint Gun distinct original custom resource-pack icons. Use the same chunky sprayer silhouette; the normal icon has a neutral body/canister treatment, while Rainbow has a visibly multicolour canister.
- Mirror the final item sprites so their barrels point left/inward when the item is held in the player's right hand.
- Use a 50-block shot range and a five-tick firing cooldown, allowing up to four shots per second.
- Bound worst-case cosmetic entity load with a 512-display global safety cap. This accommodates one player's theoretical 20-second maximum of 400 distinct painted blocks; only sustained multi-player spam can cause the oldest paint to be removed early.
- Guarantee the impact block, choose the strongest eligible surface plane around it, then grow through face-adjacent candidates from the current shot in a surface-aligned 5x5 footprint. Use the two direct neighbours perpendicular to that plane only as fallbacks. Paint from previous shots must not influence the growth frontier.
- Choose a new non-repeating allowed Rainbow colour for every painted block and emit the matching particles at each selected block.
- Deploy Jay's Patch before starting Minecraft in the launcher restart path, then retain the post-startup sync/reload as the final parity check.
- Detect player collisions only for tagged Paint Gun snowballs and only while the next projectile sample is replaceable, so a wall still absorbs the shot before a player behind it can be hit.
- On a player hit, grow through up to ten connected eligible blocks from the 5x5 ground layer beneath them and use nearby wall blocks only as fallbacks. Normal shots paint and burst in the shooter's BOTC colour; Rainbow shots paint in varied colours and use the full Rainbow burst.

## Project-owner decisions

| Decision | Reason | Date |
|---|---|---|
| Create a new `/botc fun` Paint Gun feature | Requested by Jay | 2026-08-04 |
| Paint is cosmetic and temporary | Preserve the map and live gameplay | 2026-08-04 |
| Paint only eligible full blocks and uses concrete colors | Requested visual and targeting rule | 2026-08-04 |
| Protect voice-chat areas, the pyre, seats, and other necessary live-game assets | Paint must not interfere with BOTC gameplay | 2026-08-04 |
| `paint_gun` shoots the player's own colour | Requested by Jay | 2026-08-04 |
| `rainbow_paint_gun` chooses a random colour per shot | Requested by Jay; corrected presumed typo remains to be confirmed | 2026-08-04 |
| Both Paint Guns have a splash effect | Requested by Jay | 2026-08-04 |
| Signs are not paintable | Requested by Jay and consistent with full-block targeting | 2026-08-04 |
| Map Mint to Light Blue concrete, Navy to Blue concrete, and Lavender to Pink concrete | Accepted approximation for BOTC colours without exact vanilla concrete blocks | 2026-08-04 |
| A shot paints its impact block, emits coloured splash particles, and spreads to nearby eligible full blocks | Jay requested both visual and spreading splash behavior | 2026-08-04 |
| Limit each shot to five painted blocks | Jay returned to the original five-block maximum | 2026-08-04 |
| Keep paint visible for 20 seconds and refresh it when repainted | Accepted temporary lifetime | 2026-08-04 |
| Own-colour Paint Gun requires an assigned BOTC colour; unassigned callers are directed to Rainbow Paint Gun | Avoid inventing an `own` colour while keeping the toy available | 2026-08-04 |
| Remove White, Light Gray, Gray, Black, and Brown from Rainbow Paint Gun | Requested by Jay; leaves 11 random concrete colours | 2026-08-04 |
| Create distinct custom icons and research pixel-art references online | Requested by Jay | 2026-08-04 |
| Keep the approved icon designs but mirror their final sprites for right-hand use | Jay liked the concepts and identified the held-item orientation | 2026-08-04 |
| Use a 20-block range and a five-tick cooldown | Jay accepted the recommended final gameplay choice | 2026-08-04 |
| Reject the direct high-resolution-to-18x18 reductions | Jay correctly identified that the reduced icons looked bad; they did not follow native pixel-art construction | 2026-08-04 |
| Use Jay's supplied simplified normal Paint Gun sprite as the visual base | Requested by Jay | 2026-08-04 |
| Use Jay's supplied Rainbow Paint Gun image rather than the derived Rainbow arrangement | Requested by Jay | 2026-08-04 |
| Accept the complete implementation plan and both recovered 18x18 sprites | Approved by Jay with “go and work on it” | 2026-08-04 |
| Use Jay's latest one-pixel Rainbow revision as the final asset source | Requested before resource-pack integration | 2026-08-04 |
| Deploy the complete current `Jays-Patch` source, not only Paint Guns | Explicitly authorized by Jay | 2026-08-04 |
| Launch a visible snowball and paint only on projectile impact | Requested after the first live review | 2026-08-04 |
| Replace the fixed adjacent plus with up to five random blocks from a 5x5 splash, preferring the impact Y level | Requested after the first live review | 2026-08-04 |
| Give each Rainbow impact several different colours instead of one random colour per shot | Requested after the first live review | 2026-08-04 |
| Fix and regression-test the launcher restart order | The first deployment wrote the new resource-pack settings only after Minecraft started, so the client received the previous pack | 2026-08-04 |
| Paint ten eligible nearby blocks and play the supplied sound when a Paint Gun snowball hits a player | Requested by Jay; block and burst colours follow the gun-specific rule recorded below | 2026-08-04 |
| Use the shooter's BOTC colour for normal-gun player-hit particles; reserve the multi-colour burst for Rainbow Paint Gun | Clarified by Jay | 2026-08-04 |
| Randomize the player-hit splat sound pitch on every impact | Requested by Jay; five nearby pitch levels keep the supplied sound recognizable | 2026-08-04 |
| Make each paint display copy the local light touching its covered block rather than forcing full brightness | Requested by Jay after the full-bright live review | 2026-08-04 |
| Make the real snowball authoritative for the complete flight and use the marker only to inspect its final movement segment | Removes the proven long-range disagreement between the visible projectile and the independent tracker | 2026-08-04 |
| Extend both Paint Guns to a 50-block flight | Requested by Jay after the corrected impact sweep passed live review | 2026-08-04 |
| Prefer face-connected blocks within each individual splash, without connecting to paint from previous shots | Jay's screenshots showed the desired compact pattern and the overly scattered previous selection | 2026-08-04 |
| Align block-impact splashes to floors, ceilings, and both wall orientations | Jay's wall screenshot proved the fixed XZ footprint collapsed vertical impacts into horizontal stripes | 2026-08-04 |
| Play `minecraft:item.ink_sac.use` once on block impact at volume `0.55` and pitch `1.15` | Jay accepted the reviewed short, varied wet sound; player hits retain only the custom splat | 2026-08-04 |
| Raise block-impact volume to `1.0`, target 64 blocks, and use minimum volume `0.25` while retaining pitch `1.15` | Live review found the first mix barely audible and its 24-block audience shorter than the new 50-block shot | 2026-08-04 |
| Launch snowballs at a constant 2.5x speed instead of accelerating them over the flight | Jay replaced the progressive-acceleration request before that design was tested or deployed | 2026-08-04 |

## Accepted `/plan`

1. [x] Resolve the visible Paint Gun behavior, colour selection, persistence, command ownership, shot feel, and icon direction with Jay.
2. [x] Add `/botc fun paint_gun` and `/botc fun rainbow_paint_gun`, two marked tool items, loot tables, registry entries, models, and the accepted left-facing textures.
3. [x] Route both items through the established fun-item use objective. Give the normal gun the caller's assigned BOTC colour, refuse it cleanly when no colour is assigned, and choose one of the eleven accepted colours independently for each Rainbow shot.
4. [x] Implement a 50-block physics-driven snowball flight with a bounded final-segment impact sweep. Paint only a reviewed `botc_patch` full-cube allowlist and stop without painting when the shot reaches a non-paintable solid such as a sign, slab, stair, container, or game asset.
5. [x] On impact, paint at most five eligible blocks with temporary concrete `block_display` overlays, emit matching splash particles, refresh an existing overlay instead of stacking it, expire it after 400 ticks, and enforce an isolated 512-display safety cap.
6. [x] Add feature-specific cleanup to reset/reload and source checks that reject world-writing commands, unapproved Rainbow colours, signs in the paintable tag, stale registry/resource mappings, and missing command/item routing.
7. [x] Update the source README and run only the focused Paint Gun, fun-toybox, tool-registry, and resource-pack checks. Prepare the result for manual in-game review without deploying or rebuilding the public package.
8. [x] Replace the instant raycast with a visible, tagged snowball projectile that carries its own normal colour or Rainbow state and paints only at an eligible block impact.
9. [x] Replace the six-neighbour spread orders with face-connected random growth from the current impact through a surface-aligned 5x5 candidate footprint plus perpendicular direct-neighbour fallbacks, keeping the five-block cap and ignoring previous-shot paint.
10. [x] Make Rainbow choose a different accepted colour per painted block and spread matching particles across the selected blocks.
11. [x] Move the launcher restart deployment before Minecraft startup and add focused checks for restart order plus model-to-texture resolution.
12. [x] Run the targeted Paint Gun, resource-pack, launcher, registry, and reference checks before any new deployment gate.
13. [x] Add the supplied player-hit sound, Rainbow player burst, and connected ten-block 5x5 ground-priority splash; confirm redistribution permission before uploading the resulting public resource pack.

## Delivery tracking

- Decision: `use the accepted plan and master journal; do not create a separate /goal`
- Reason: `The accepted seven-step checklist and journal already keep the outcome, safety boundaries, verification state, and exact next action durable. A second tracking layer would duplicate them, and goal creation was not explicitly requested.`

### Active `/goal` (only when used)

Not used; the accepted plan and master journal are sufficient.

## Current progress

- Read the project instructions, source-of-truth README, workflow guide, current Git state, `/botc fun` command family, shared fun tick/load/reset paths, item registry, focused fun test, and representative Slayer/Hot Potato raycasts.
- Confirmed that no source or live-server Paint Gun implementation exists yet.
- Scanned the tracked world template's block palette and researched original small-scale pixel-art design guidance and paint-sprayer silhouettes.
- Generated and inspected two original transparent concept images. Jay approved the broad designs and requested that the final Minecraft-scale sprites be horizontally mirrored for right-hand use.
- Rejected the first direct 18x18 reductions after Jay's review, inspected representative native 18x18 pack assets, and created simpler grid-native replacements with no antialiasing or loose splash pixels.
- Reconstructed Jay's supplied normal icon as a transparent 18x18 sprite and derived a Rainbow variant by changing only its paint-colour clusters.
- Recovered Jay's preferred Rainbow design directly into an 18x18 transparent sprite without resampling or interpolation.
- Integrated both approved 18x18 textures, including Jay's final one-pixel Rainbow revision; the source Rainbow PNG has the same SHA-256 hash as the supplied PNG.
- Added both public `/botc fun` commands, loot items, models, selector mappings, registry entries, and shared right-click routing.
- Implemented own-team and eleven-colour Rainbow selection, a 50-block shot, a reviewed full-cube allowlist, five-block cosmetic splash coverage, 20-second refreshable displays, and a 512-display safety cap.
- Added reload/reset cleanup, focused Paint Gun source assertions, source documentation, and targeted resource/registry checks without deploying or rebuilding a package.
- Added both Paint Gun public give functions to the reviewed command-overlay policy after the deploy gate correctly rejected their omission.
- Updated the canonical server properties, public installation copies, generated code-library indexes, and known-good source baseline after the reviewed gates identified each stale derived artifact.
- Rebuilt the public package through `tools/build-public-package.ps1`; the resulting `Jay's Patch v1.9.0-beta.3.zip` is 73,254,830 bytes with SHA-256 `cd0e8194467bd4b23a8284cd0d37da65f8e8b39ff157335c62c6807e62d8f2eb`.
- Deployed the complete current `Jays-Patch` source through the interactive `BOTC.exe` restart workflow. The new live container start is healthy and the launcher reported both post-startup sync and restart completion.
- Proved live datapack and owned Melius parity, exact resource-pack parity for 419 files, and the configured hosted URL/SHA-1/UUID. Current-boot logs confirm reload and YAWP initialization with no deploy-relevant load failures.
- Preserved `tools/capture-botc-client-heap.ps1` byte-for-byte outside release inventory scans, following the established project precedent; it remains untracked and was not packaged or deployed.
- First live review failed: Jay saw missing-texture boxes, a single-colour Rainbow shot, and a fixed plus-shaped splash. Investigation proved the client was served the previous resource pack because the restart path deploys resource-pack settings after startup.
- Replaced the instant trace in source with tagged, command-stepped snowballs; added random 5x5 block-impact selection, per-block non-repeating Rainbow colours, and player-impact detection.
- Added the supplied splat sound as a Minecraft-compatible Vorbis Ogg plus a ten-block ground-priority player splash and eleven-colour particle burst.
- Moved server-only launcher deployment before Minecraft startup and added focused regression coverage for that ordering.
- The second live review failed the projectile acceptance check: Jay observed the visible snowball stuttering and no paint appearing at impact. Source inspection proved the snowball itself was command-teleported through four quarter-block steps per tick.
- Source inspection also proved block impacts played `minecraft:block.slime_block.place`; the supplied custom splat remained player-only, but the extra block sound still read as a splat and was not requested.
- Jay's screenshots prove block-display paint rendered much darker than a real concrete block at the same outdoor location. The display had no brightness override and sampled light from inside the covered full cube.
- The previous live correction separated a physics-driven visible snowball from an independently moving marker, paired them with a unique score ID, excluded the matching shooter ID, removed all block-impact audio, and rendered new paint displays at block/sky brightness 15 without placing light blocks.
- A live, isolated passenger experiment disproved the proposed vehicle design: Minecraft detached the marker immediately instead of carrying it with the moving snowball.
- The current source therefore makes the real snowball authoritative for its whole flight. The paired marker copies the snowball's actual position each tick and performs only a bounded two-block sweep after the snowball disappears, eliminating the independent guessed trace.
- The `minecraft:light` blocker hypothesis was disproved: Minecraft 1.21.10 includes `minecraft:light` in its own `#minecraft:replaceable` block tag.
- Paint display brightness now samples the six cells touching the covered block, keeps the brightest visible light level, and applies that value to the display instead of forcing block/sky brightness 15.
- Added the explicit `AGENTS.md` rule that every check must be justified against the current change or delivery boundary before it is run.
- The deployment boundary refreshed the generated code indexes and promoted a 3,104-file known-good source baseline after the reviewed source checks passed.
- The first final package-parity check correctly rejected the stale public ZIP because it lacked the new resolver, light-sampling functions, and 15 light predicates. The reviewed builder then produced a current package and passed its fresh source, baseline, world-manifest, hosted-pack, and package-parity checks.
- The live server saved and stopped cleanly with two connected players, deployed from `Jays-Patch`, and restarted at `2026-08-04T14:36:24.861795542Z`. The launcher hit its known redirected-console UI error only after deployment and container startup, so the four Final Sync commands were completed directly.
- Jay's first post-deployment retest exposed intermittent block impacts. Source review proved the recursive final-segment sweep moved the marker but inherited the previous command position, so all eight quarter-block iterations inspected the same first 0.25 block instead of advancing across two blocks.
- The recursion now re-anchors every iteration `at @s`, and the focused Paint Gun regression check requires that execution context before accepting the final-segment loop.
- Hot-synced only the corrected `step_loop.mcfunction` into the live `jays_patch` datapack and ran `/reload`; source/runtime SHA-256 matched, the container remained healthy, delayed YAWP initialization completed, and the reload logged no Paint Gun parser failures.
- Extended the source projectile lifetime from 21 to 61 sampled ticks, which covers just over 50 blocks after normal snowball drag, and changed both block and player splashes to grow a face-connected current-shot frontier. Existing paint displays are not queried and cannot influence a later shot.
- Replaced the hard-coded horizontal block-impact footprint with local surface scoring. The strongest of XZ, XY, and ZY selects a complete 5x5 floor, ceiling, or wall plane before the same current-shot connected growth runs.
- Added the approved ink-sac sound once at each block impact. It does not run from `paint_here`, so a five-block splash still produces one sound, and the separate player-impact route keeps only the custom Ralsei splat.
- Hot-synced the 12 changed Paint Gun functions for 50-block range, current-shot connected growth, surface-aligned block splashes, and the approved block sound. Every live file hash matched source before `/reload`; the server remained healthy, YAWP initialization completed, and no Paint Gun parser errors appeared.
- After Jay found the first block sound too quiet, raised it from `0.55` to `1.0`, expanded its target selector from 24 to 64 blocks, and added `0.25` minimum volume for distant impacts. Hot-synced only `impact.mcfunction` and reloaded cleanly.
- Jay replaced the untested progressive-acceleration idea with a constant 2.5x launch speed. Removed all origin-marker/acceleration work before deployment, changed Motion scaling from `0.00011` to `0.000275`, reduced the drag-aware lifetime from 61 to 21 samples for roughly 50 blocks, and widened the final sweep from two to three blocks.
- Hot-synced only `shoot.mcfunction` and `projectile/resolve.mcfunction`; both live hashes match source and `/reload` completed with healthy YAWP and parser state.

## Active Luna assignments

| Assignment | Worker journal | Allowed area | State |
|---|---|---|---|
| None | N/A | N/A | No delegation requested or needed |

## Verification record

| Check | Result | Evidence |
|---|---|---|
| Read-only feature investigation | pass | Current files and Git state inspected on 2026-08-04 |
| Concept chroma extraction | pass | Both 1254x1254 PNGs have transparent corners and bounded opaque subjects |
| Concept visual inspection | pass | Normal and Rainbow designs are distinct and retain the same recognizable silhouette |
| Direct 18x18 concept reduction | fail/rejected | Muddy clusters and weak silhouette; not eligible for the resource pack |
| Final 18x18 source textures | pass | Both source PNGs are 18x18; the Rainbow source asset is byte-for-byte identical to Jay's latest supplied PNG, SHA-256 `F319A0E1B3B5BCCA221D70AE9FCAA7F4D2CD86FC69B3896406721EB8626A2404` |
| Paint Gun and fun-toybox focused check | pass | `tools/tests/test-fun-toybox.ps1` passed after the final test update |
| Tool registry focused check | pass | `tools/tests/test-tool-item-registry.ps1` passed for 66 registered items, 5 generated families, and 268 model strings |
| Resource-pack mapping focused check | pass | `tools/tests/test-resourcepack-mappings.ps1` passed for 267 carrot selectors, 139 paper selectors, 2 fun-drink selectors, 139 role icons, and 139 dialog glyphs |
| New JSON and Paint Gun function-reference checks | pass | All edited/new integration JSON parsed and every Paint Gun function reference resolved |
| Hosted resource-pack verification | pass | MC-Packs download is 199,274 bytes and matches source SHA-1 `6fd474cfe30b187069f40e062b49dabd175fd2d1` |
| Reviewed public package builder | pass | Complete non-live source gate, source baseline, world manifest, package parity, and exact hosted-pack checks passed; package SHA-256 `cd0e8194467bd4b23a8284cd0d37da65f8e8b39ff157335c62c6807e62d8f2eb` |
| Reviewed live launcher restart | pass | New container start `2026-08-04T12:26:53.017874654Z` is healthy; launcher reported post-startup sync and Minecraft restart completion |
| Live runtime sync | pass | `tools/tests/live/test-runtime-sync.ps1` passed for the Jay's Patch datapack and owned Melius files |
| Live resource-pack and properties parity | pass | Runtime resource-pack tree matches all 419 source files; live URL, SHA-1, and UUID match the verified hosted pack |
| Current-boot reload evidence | pass | Minecraft ready, RCON reload, `botc_patch:startup/yawp_init`, and `yawp_startup_done=1` are present; no function, tag, parse, unknown-function, or Melius load failures found |
| In-game manual review | not run | Live deployment is ready for Jay to test both Paint Guns |
| Projectile, player-impact, and launcher focused checks | pass | `test-fun-toybox.ps1`, `test-startup-scripts.ps1`, and the Paint Gun function-reference check passed after the rework |
| Smooth-projectile/audio/brightness/owner focused check | pass | `tools/tests/test-fun-toybox.ps1` passed after adding the physics-driven visual, paired invisible tracker, shooter exclusion, player-only splat, silent block impact, and full-bright display assertions |
| Corrective full source gate | pass | All source-only checks passed and `tools/update-source-baseline.ps1` refreshed the known-good baseline for 3,085 owned files |
| Corrective live deployment | pass | Source deployed before container start `2026-08-04T13:54:50.103280439Z`; after the known redirected-console UI error, Minecraft became healthy and all four Final Sync commands passed directly |
| Corrective runtime and parsing verification | pass | Runtime datapack/Melius parity passed; `botc_fun_paint_id` and `botc_fun_paint_owner` exist, palette is 11, and the current boot has zero relevant Paint Gun/function load or parse failures |
| Current Paint Gun focused source check | pass | `tools/tests/test-fun-toybox.ps1` passed with real-position tracking, final-segment resolution, local-light predicates, and hard-coded full-bright rejection assertions |
| Disposable Minecraft 1.21.10 datapack load | pass | Mojang's official server jar loaded the Paint Gun function slice, loot tables, and all 15 light predicates without function, predicate, or command parse errors |
| Final deployment source and package gate | pass | The reviewed checks passed against the 3,104-file baseline; the rebuilt `Jay's Patch v1.9.0-beta.3.zip` is 73,281,098 bytes with SHA-256 `28141b10bdd991d2c9d697e89a9252d215d75af4637ad95c88af1f361147fd6e` |
| Final live deployment | pass with known launcher UI issue | `save-all flush` and `stop` succeeded; source deployed before container start `2026-08-04T14:36:24.861795542Z`. BOTC.exe then hit the known redirected-console `De ingang is ongeldig` error after startup, without invalidating the completed deploy |
| Final Sync and runtime parity | pass | `reload`, `botc_patch:startup/yawp_init`, the startup flag, and admin logging all succeeded; runtime datapack/Melius parity passed before and after reload |
| Final resource-pack and parsing verification | pass | All 421 live resource-pack files match source, URL/SHA-1/UUID match after Java-properties unescaping, all 15 light predicates are present, the server is healthy, and the current boot/reload contain zero relevant function, predicate, or command-parser errors |
| Advancing final-segment sweep regression | pass | `tools/tests/test-fun-toybox.ps1` passed after requiring every recursive quarter-block step to re-anchor at the moved tracker |
| Advancing sweep live hot-sync | pass | Live file SHA-256 `8feac01386496440088e52816f52e267cfd3f95455f2cb3f9cc0fe33caacb6f3` matches source after `/reload`; container healthy, `yawp_startup_done=1`, and zero Paint Gun reload/parser errors |
| Fifty-block and connected-splash focused check | pass | `tools/tests/test-fun-toybox.ps1` passed with 61-tick drag-aware range, impact/player connectivity seeding, face-adjacent frontier growth, and previous-shot display rejection |
| Surface-aligned splash focused check | pass | `tools/tests/test-fun-toybox.ps1` passed with neighbour-based XZ/XY/ZY routing and complete 24-candidate plus two-fallback coverage for every plane |
| Block-impact sound focused check | pass | `tools/tests/test-fun-toybox.ps1` passed with exactly one `item.ink_sac.use` at volume `0.55`/pitch `1.15` in the block route and none in the player route |
| Range/connectivity/surface/sound live hot-sync | pass | All 12 changed live Paint Gun functions matched source hashes; `/reload` completed with a healthy container, `yawp_startup_done=1`, and zero relevant parser errors |
| Louder impact-sound live hot-sync | pass | Live `impact.mcfunction` SHA-256 `258462964fa56a07c88aa3735a04bebf50b7a6f7249c388b0374f9668b424218` matches source; focused test, `/reload`, YAWP initialization, parser logs, and container health pass |
| Constant 2.5x projectile-speed focused check | pass | `tools/tests/test-fun-toybox.ps1` passed with `0.000275` Motion scaling, 21-sample approximate 50-block lifetime, three-block final sweep, and no retained progressive-acceleration/origin references |
| Constant 2.5x projectile-speed live hot-sync | pass | Live `shoot.mcfunction` and `projectile/resolve.mcfunction` hashes match source; `/reload`, YAWP initialization, parser logs, and container health pass |

## Current blocker

No technical blocker. The constant 2.5x projectile speed and the earlier Paint Gun changes are live and await in-game acceptance.

## Exact next step

Have Jay test the faster shot at nearby and roughly 50-block targets, including floors and walls, and confirm that every visible collision still paints.

## Final outcome

The latest public package remains unchanged, while the complete current Paint Gun datapack update is live through targeted hot-syncs and `/reload`. Snowballs launch at a constant 2.5x speed and travel about 50 blocks, impacts grow a compact face-connected pattern within the hit floor/ceiling/wall plane without consulting earlier paint, and block hits play one ink-sac sound at volume `1.0`, pitch `1.15`, and minimum distant volume `0.25`. Source/live hashes, the focused regression check, parser logs, YAWP initialization, and container health all pass; only in-game acceptance remains.
