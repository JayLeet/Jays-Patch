Jay's Patch 1.9.0 Beta 4 is the current cumulative 1.9 beta. It includes the
features introduced in the first 1.9 beta plus every later beta addition and
fix listed below. Features that were already available in 1.8.0 are not
repeated here.

## Introduced in the first 1.9 beta

- **Greedy Whalebuffet** lets every player submit private character preferences
  in parallel, including Dealer's Choice, before the Storyteller reviews and
  starts the final setup.
- **Draft Buffet** privately gives players turns in a random order with changing
  legal character offers while the unfinished setup adjusts around earlier
  choices.
- **Wraith support** gives the Storyteller Closed, Peek and Eyes Open choices
  during the night, with private visits and a chance for good players to spot
  the Wraith.
- **Spy and Widow personal Grimoires** let the Storyteller show the correct true
  character information to those players at the appropriate time.
- **Expanded Boomdandy Final Three** removes the other chairs, eliminates
  non-finalists one at a time and lets the three survivors vote by standing
  near their chosen player.

## Added and fixed in later 1.9 betas

- Greedy and Draft now use stricter legality checks, clearer Storyteller review
  messages, safer setup/reset handling and complete personal Grimoire support.
- Draft's private 3/2/1 offers, hidden special starts, setup modifiers and final
  override warnings were finished and hardened through expanded randomized QA.
- Buffet player labels and head profiles rebuild from a stable roster after
  starts and seat changes.
- Dialog navigation, Back-button placement, character wording and dense setup
  messages were cleaned up and kept consistent.
- Greedy's 20 adjusted character abilities now appear in the existing role HUD
  and character tooltips inside Grimoire dialogs without changing the normal
  text in other game modes.
- Personal Grimoire dialogs use normal character names while keeping character
  abilities in their tooltips.
- Greedy setup links players to the adjusted-character reference page.
- The Wraith now uses the official ability text globally.
- **Paint Guns** fire visible snowballs and place temporary, non-destructive
  concrete displays. The normal gun uses the shooter's seat colour; the Rainbow
  Paint Gun creates connected multicolour splashes.
- Paint Gun shots can splat players with gun-matched particles and a custom
  pitch-varied sound. Paint copies nearby light, follows the hit surface,
  travels up to 50 blocks at a constant 2.5x speed and disappears after 20
  seconds without replacing world blocks.
- Both Paint Guns have custom resource-pack icons, and the public package uses
  the latest hosted resource pack containing those assets.

## Requirements

- Sybillian's Blood on the Clocktower modpack 1.5.4
- Minecraft Java Edition 1.21.10

Back up your existing `world` and `config` folders before installing. This is
an unofficial server-side add-on and is not a standalone server pack.
