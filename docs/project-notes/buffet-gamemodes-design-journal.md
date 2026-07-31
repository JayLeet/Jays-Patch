# Buffet Gamemodes Design Journal

Last updated: 2026-07-30

## Purpose

This is the human-readable source of truth for Greedy Whalebuffet and Draft
Buffet.

Read this file before changing either mode. Do not treat generated functions,
tests, or `Jays-Patch/buffet-rules.json` as the complete design on their own.
Those files implement parts of this plan, but this journal records the rules,
workflow, fine print, and reasons behind them.

When sources disagree:

1. Jay's latest confirmed decision in this journal wins.
2. `Jays-Patch/buffet-rules.json` owns machine-readable constants.
3. The generators own generated implementation.
4. Tests prove current behavior, but do not create new game rules.

## Status

- The design below is approved unless a section says **Open**.
- Source implementation is in progress.
- Nothing in this journal proves either mode is ready for deployment.
- Neither mode should enter a public package until static checks and live QA
  pass.

## Shared Entry Point

- Both modes are available only through Jay's Patch Setup Bag during setup.
- The Setup Bag includes an `Other Gamemodes` control.
- That control opens a private Storyteller dialog with:
  - `Greedy Whalebuffet`
  - `Draft Buffet`
- The modes stay server-controlled and usable by a non-op Storyteller.
- Sybillian remains the base game. Jay's Patch owns the special setup, then
  hands the finished game back to Sybillian's normal game flow.

## Shared Roster Rules

- Use the actual seated player count.
- Support the same 5 to 15 player range as the normal game.
- Do not count Storytellers or spectators as participating players.
- Give participating players seats and houses during the special setup.
- A disconnected player's seat, choices, and assignment stay reserved.
- The Storyteller may explicitly empty a reserved seat.
- A new participant may receive an unused open seat.
- Another player may take a reserved seat only after the Storyteller explicitly
  empties it.
- A returning former occupant must not reclaim a seat that was reassigned.
- Players without a seat are finalized as spectators only when the ordinary
  game starts.

The modes lock their rosters at different times:

- Greedy Whalebuffet stays open to latecomers until the Storyteller genuinely
  starts the ordinary game.
- Draft Buffet locks its roster when Draft begins because the private random
  order and remaining setup depend on a fixed player count.
- Both modes assign seats randomly. Seat order must not follow join order,
  submission order, Draft order, or any other predictable player ordering.
- Draft turn order is randomized separately from seating. A player's seat must
  not reveal when they will receive a Draft turn.

## Shared Privacy Rules

- Player choices are private.
- Storyteller review screens are private.
- Storyteller-only pauses and setup decisions must not give players a timing
  hint.
- Hidden actual roles must never leak through labels, icons, alignment colors,
  announcements, personal Grimoire state, or role items.
- Store actual character, shown character, actual alignment, and shown
  alignment separately whenever they differ.
- All dialogs, messages, warnings, and errors must follow Jay's writing guide:
  direct, short, specific, and easy to understand on the first read.

## Shared Hermit Rules

Both Greedy Whalebuffet and Draft Buffet use the same Buffet-specific Hermit
rule:

- Hermit has exactly 3 unique Outsider abilities.
- For a directly selected Hermit, the Storyteller freely chooses all 3.
- Drunk and Lunatic cannot be among a direct Hermit's 3 abilities.
- The direct Hermit is told their 3 abilities.
- A hidden Hermit-Drunk has Drunk locked as one ability.
- A hidden Hermit-Lunatic has Lunatic locked as one ability.
- The Storyteller freely chooses the remaining 2 unique abilities.
- A hidden Hermit is not told they are the Hermit or which abilities they have.

This shared Buffet rule replaces the normal "all Outsiders on the script"
interpretation in both modes. Assignment storage, Storyteller review, final
validation, player information, and Sybillian handoff must preserve the same
three abilities.

## Shared Legality And Jinx Model

Buffet setup must not treat every unusual character interaction as the same
kind of problem.

Use these four outcomes:

1. **Hard invalid**
   - The setup cannot start.
   - Examples include an impossible character distribution, no valid Demon
     state, an unresolved required character, illegal hidden-role placement,
     a forbidden duplicate, or a jinx that explicitly allows only one of the
     two characters to be in play.
2. **Legal with a Djinn rule**
   - Both characters may be in play when the official special rule is used.
   - Record the exact jinx and make it available to the Storyteller.
   - Do not retire either character merely because a jinx exists.
3. **Unusual but playable**
   - The setup is legal, but its distribution or modifier result deserves a
     clear Storyteller warning before the game starts.
4. **Unsupported or unproven**
   - Pause privately for the Storyteller.
   - Never guess how an unfamiliar interaction should work, silently remove a
     character, or allow the game to start with an unknown state.

### Jinx Catalog

- Use a versioned, trusted jinx catalog based on the official Script Tool or
  current official Wiki.
- Store role IDs, the exact public rule, its source version, and how Jay's
  Patch must treat it.
- Do not infer jinxes from similar ability text.
- Do not copy a one-time list into generated functions and let it become
  stale. The generator should read one curated source table.
- Updating the supported role catalog must require checking whether the jinx
  catalog also changed.

Classify every supported jinx by its effect:

- **in-play exclusion**: only one of the jinxed characters may actually be in
  play;
- **setup adjustment**: the pair changes counts, placement, alignment,
  abilities, or another setup decision;
- **information adjustment**: the pair changes what a player learns or sees;
- **runtime procedure**: the pair changes a later night, nomination, death,
  execution, or character-change interaction;
- **creation restriction**: a character cannot create, copy, or gain a
  specific jinxed character or ability;
- **Storyteller reminder only**: the setup is legal and requires no automatic
  solver change, but the Storyteller must know the special rule.

One jinx may belong to more than one class.

### Jinx Privacy

Official Djinn rules are normally announced from the public character sheet,
even when neither jinxed character is in play. Buffet modes do not yet have a
fixed public script, so announcing only the jinxes found in the secret final
setup would leak role information.

The approved Buffet privacy policy is:

- show applicable actual-role jinxes privately to the Storyteller;
- never generate public jinx announcements from secret in-play roles;
- block automatic `Start Game` if a required public Djinn announcement cannot
  be produced without leaking the setup;
- do not publish a generated public character sheet for either Buffet mode;
- keep the player-facing Script item's character lists and night orders empty;
- give every Buffet player the same fixed reminder-token catalogue generated
  from every legal Buffet character, never from the secret final setup;
- keep the authoritative exact setup only in server storage and private
  Storyteller surfaces.

Do not automatically add decoy roles to the public Script. Revisit that only
if a future product decision explicitly replaces the empty-sheet policy.

### Illegal Setup States

The final legality rebuild must detect at least:

- active seats, actual assignments, and shown assignments not matching;
- total character counts not matching the final roster;
- an impossible Townsfolk, Outsider, Minion, or Demon distribution;
- no Demon when the selected topology requires one;
- a Demon when an approved no-Demon topology forbids one;
- unresolved setup modifiers or Storyteller decisions;
- unresolved required-character relationships;
- hidden characters without a legal shown character;
- Marionette or another positional role without legal seat placement;
- actual or shown alignment missing or contradicting the selected role state;
- disallowed duplicate actual or shown characters;
- an in-play-exclusion jinx with both restricted characters assigned;
- a role selected after its setup window has closed;
- a setup-changing role whose effect cannot fit in the remaining seats;
- a selected, discarded, hidden, or required role incorrectly remaining in an
  eligible pool;
- a final setup that cannot be handed to Sybillian's normal start flow without
  losing role, alignment, seat, house, night-order, or script state.

Do not encode ordinary Storyteller judgment as a hard error. A setup can be
strange without being illegal.

### Validation Stages

Run legality checks at several boundaries:

1. **Catalog validation**
   - Confirm every supported character has category, alignment, setup,
     dependency, jinx, night-order, icon, and Sybillian mapping data where
     required.
2. **Offer simulation**
   - Before showing an option, simulate the resulting counts, dependencies,
     conflicts, and legal completion paths.
3. **Choice finalization**
   - Recheck the selected actual and shown result before retiring roles or
     advancing the draft.
4. **Incremental review**
   - Update the Storyteller's warnings and unresolved decisions after every
     choice, discard, assignment, override, seat replacement, or roster
     change.
5. **Pre-start rebuild**
   - Recalculate the complete setup from stored seat state instead of trusting
     only incrementally maintained counters.
6. **Sybillian handoff**
   - Verify the generated setup, script, role state, and required public
     notices can be applied before changing the ordinary game phase.

If any stage fails, keep the last valid state. An invalid action must not clear
an existing submission, assignment, offer, or Storyteller decision.

# Greedy Whalebuffet

## Setup Flow

1. The Storyteller selects `Greedy Whalebuffet`.
2. Current participating players receive seats and houses. The roster remains
   open during Greedy setup.
3. The Storyteller returns to the Storyteller den.
4. The world changes to night.
5. The normal game-start jingle plays.
6. Players see these instructions instead of a character reveal:
   - `Choose characters or Dealer's Choice.`
   - `The Storyteller might ask you to make different choices.`
7. Each player receives a selection item that opens their private character
   dialog.
8. Players submit choices.
9. The Storyteller reviews each submission and assigns every player a final
   character.
10. Latecomers may join the selection setup, receive a seat and house, and
    submit choices while space remains.
11. The Storyteller manually starts the ordinary game after all current
    participating seats are ready.
12. Pressing `Start Game` locks the final roster before any roles are applied.

## Live Greedy Roster

- Greedy selection happens in parallel. Every participating player may choose
  or edit characters at the same time.
- Recheck eligible joined players during Greedy setup instead of relying only
  on the players who were online when the mode was selected.
- A latecomer receives the next available seat, a house, and the Greedy
  selection item.
- The Storyteller review updates when a latecomer receives a seat.
- A latecomer becomes part of start validation and must receive a final
  character.
- Never exceed 15 participating seats.
- When all 15 seats are occupied, additional players remain unseated and
  become spectators when the ordinary game starts unless the Storyteller
  empties a seat first.
- Disconnecting does not silently remove a Greedy participant. Their reserved
  seat follows the shared disconnect rules.
- The final roster becomes immutable only when `Start Game` succeeds.
- A player joining after that lock does not enter the running game.

## Player Selection Rules

- The selection catalog contains every supported official non-Traveler
  character.
- Drunk, Lunatic, and Marionette do not appear as direct player choices.
- A valid submission contains:
  - at least 8 total characters;
  - at least 2 Townsfolk;
  - at least 2 Outsiders;
  - at least 2 Minions;
  - at least 2 Demons.
- `Dealer's Choice` is an alternative valid submission by itself.
- A player who selects `Dealer's Choice` lets the Storyteller assign any
  supported character.
- That player may still select normal characters as optional preferences.
- More than 8 choices are allowed.
- Players may edit and resubmit their choices at any time before the game
  starts.
- Changing `Dealer's Choice` or any character preference clears the old
  submission status until the player submits again.
- A valid submission does not become permanently locked.
- If a player removes their assigned character from a later submission, keep
  the assignment visible but mark it as needing attention. The Storyteller
  must confirm it as an override or choose another character before starting.

## Storyteller Review

The Storyteller receives a private `Buffet Review` control.

The first screen shows:

- every current participating seat;
- the player's name;
- whether they are still choosing, submitted, assigned, or need attention;
- the assigned role icon when one exists;
- overall assignment progress.

Selecting a player shows:

- their submitted characters first;
- whether they selected `Dealer's Choice`;
- characters grouped by Townsfolk, Outsider, Minion, and Demon;
- their current assignment;
- a `Show All Characters` override;
- controls to clear the assignment or request different choices.

The Storyteller may assign:

- one of the submitted characters; or
- any supported character through the explicit override.

If the Storyteller assigns Drunk, Lunatic, Marionette, or another hidden
character, the review flow must also record the character shown to that player.

## Duplicate Assignment Toggle

- Duplicate final assignments are off by default.
- The Storyteller may enable duplicate assignments.
- The current policy must be shown clearly to everyone during setup.
- This toggle changes final assignments, not whether two players may submit the
  same character as a preference.

## Start Validation

Starting is blocked when:

- a participating seat has no final assignment;
- a hard character dependency is unresolved;
- there is no legal Demon state;
- a hidden character cannot be placed legally;
- actual and shown character state is incomplete;
- an in-play-exclusion jinx would be violated;
- a setup-changing pair has an unresolved decision;
- the final legality rebuild finds a hard-invalid state.

The Storyteller receives a warning, but may confirm, when:

- the Townsfolk, Outsider, Minion, and Demon distribution is unusual but still
  playable;
- an Outsider modifier makes the setup nonstandard without making it illegal;
- the Storyteller deliberately used a valid override.

The warning must state what is unusual. It must not claim a legal setup is
invalid.

# Draft Buffet

## Setup Flow

1. The Storyteller selects `Draft Buffet`.
2. The roster locks using the actual seated player count.
3. Every supported official non-Traveler character becomes eligible.
4. There is no manually built 25-character pool.
5. There is no persistent character rotation between games.
6. Draft order is randomized and private.
7. One player drafts at a time.
8. The engine recalculates the remaining legal setup after every choice,
   discard, hidden assignment, dependency, and Storyteller modifier decision.
9. The Storyteller reviews the completed draft.
10. The ordinary game starts only after the Storyteller presses `Start Game`.

Players should know that the full supported non-Traveler catalog is eligible.
They do not need an enormous public list every game.

## Offer And Discard Flow

Each player receives up to three rounds:

1. Round one shows 3 new, unique characters.
2. The player chooses one or discards all 3.
3. Round two shows 2 new, unique characters that player has not seen.
4. The player chooses one or discards both.
5. Round three shows 1 new, unique character.
6. The final character must be accepted. There is no third discard.

Rules:

- A player never sees the same character twice.
- Selected characters retire from the normal pool.
- Discarded characters normally retire from the game.
- The same discard and legality rules apply to rounds one, two, and three.
- An offer may mix character types.
- Choosing a Townsfolk or Outsider normally makes the player Good.
- Choosing a Minion or Demon normally makes the player Evil.
- Every possible choice shown in a constrained offer must still allow a legal
  completion.

## Private Turn Lifecycle

- Choose each next drafter randomly from the online unresolved seats.
- Never use seat order, join order, name order, or the previous game's order.
- Do not announce the current drafter to other players through chat, titles,
  actionbar text, sounds, items, particles, or timing messages.
- The Storyteller's private review may show who is choosing because they must
  manage disconnects and inspect the completed draft. That identity must never
  appear in a player-facing view.
- A reserved dependency role may belong to one randomly selected future seat,
  but that reservation must not create a public clue about when that seat's
  turn occurs.
- When a turn begins, play a clear positive jingle only for that player.
- Immediately open that player's current private choice dialog.
- Give every locked player the same `Choose your characters!` item in their
  offhand for the entire draft. Repair it there if they move or drop it so the
  visible item never identifies whose turn is active.
- Right-clicking while waiting gives only that player a short not-your-turn
  message. Right-clicking after choosing privately reopens only the character
  they were shown, never their hidden actual character.
- If they close the dialog without choosing or discarding:
  - keep the same generated offers;
  - keep their turn active;
  - keep their reopen item;
  - send one private chat reminder that the item reopens the same choices.
- Reopening the dialog must never reroll, replace, retire, or duplicate the
  unresolved offers.
- A disconnected current drafter keeps the same turn and offers when they
  return.

## Recycling

- `Allow Recycling` is off by default.
- Selected characters never recycle.
- With recycling off, discarded actual and shown characters remain unavailable.
- If recycling is enabled, discarded characters may return only when the engine
  cannot otherwise complete a legal draft.
- Players are told before drafting that discarded characters are usually, but
  not guaranteed to be, gone.
- The game never confirms whether recycling happened.
- Players may share, hide, or lie about what they discarded. The system never
  confirms those claims publicly.
- Enabling recycling or pausing for a repair stays private to the Storyteller.

## Duplicate Rules

- Final characters do not duplicate by default.
- Village Idiot is the only approved duplicate exception.
- A Village Idiot fallback may create 1, 2, or 3 total Village Idiots.
- Each total has equal odds.
- If the fallback creates more than one Village Idiot, ordinary Village Idiot
  rules still decide which extra copy is drunk.

## Hybrid Draft Generator

This is the approved direction for future Draft generation.

The generator uses two layers instead of pre-rolling a complete script.

### Layer One: Setup-Defining Characters

Characters that fundamentally reshape the setup are eligible only before
ordinary finalized choices make their setup impossible.

The initial group is:

- Kazali
- Atheist
- Legion
- Riot
- Lord of Typhon

Only the first private offer may introduce one of these setup-defining paths.
Do not repeatedly offer the same setup-defining character to several players.

Every supported character must still have a fair route into the game. A
setup-defining character is not guaranteed to appear, but it must not be
silently excluded merely because its rules are more complicated.

Kazali rules:

- Only one player receives Kazali as an option.
- Nobody else drafts while that offer is unresolved.
- If Kazali is chosen, remove normal Minion draft slots and recalculate the
  rest of the setup.
- If Kazali is declined or discarded, retire Kazali for that game.
- Another legal Demon remains possible after Kazali is retired.

### Layer Two: Dynamic Ordinary Draft

After the opening topology is settled:

- calculate which character types the setup still needs;
- weight those needed types;
- give every eligible character inside the selected type equal odds;
- simulate every option before showing it;
- recalculate after every choice, discard, and modifier.

This keeps ordinary Draft flexible. Do not pre-roll a complete hidden script,
because later modifiers and discards need room to change the remaining setup.

### Character Probability

Probability is calculated inside the character's type:

- If a category has `N` eligible characters, each eligible character in that
  category has a `1 / N` chance when the generator fills an option from that
  category.
- Example: if 20 Townsfolk remain eligible, each one has a 5% chance after the
  generator decides that the option must be a Townsfolk.
- Recalculate `N` after selected roles, discarded roles, dependencies, hidden
  paths, setup modifiers, and illegal options are removed.
- Do not calculate equal odds from the full catalog and then repeatedly reroll
  illegal characters. That can bias the remaining result and waste commands.
- Hidden characters still receive a legal probability path through actual and
  shown role generation. They do not appear under their real names when that
  would reveal hidden information.

Category selection remains weighted by what the unfinished setup still needs.
Equal character odds apply after that category is selected.

### Mutually Exclusive Characters

Resolve proven character conflicts privately before generating the affected
offer:

- Use this only when the official rule says both characters cannot be in play,
  or when two approved setup topologies genuinely cannot coexist.
- Do not treat an ordinary jinx as mutual exclusion. Most jinxes exist so both
  characters can work together under a special rule.
- If either of 2 characters would prevent the other from being in play, use a
  50/50 coin flip to decide which one remains eligible for this draft.
- The losing character is retired from this draft before player-facing offers
  are generated.
- If more than 2 characters form one mutually exclusive group, choose one with
  equal `1 / N` odds. Do not use chained coin flips because their order could
  bias the result.
- Continue the generator only after the conflict state is settled.
- Never show both incompatible outcomes and repair the conflict after a player
  chooses.
- The conflict roll remains internal. Players receive no message or timing
  clue.

Summoner and Lil' Monsta are required conflict and setup-order audit cases.
Their exact relationship to every other setup-changing character must be
proven from supported rules before encoding the incompatibility table.

## Dynamic Distribution

- Start from the ordinary distribution for the locked player count.
- Track required Townsfolk, Outsiders, Minions, and Demons.
- Track actual assignments separately from shown choices.
- An option is eligible only when selecting it leaves at least one legal path
  for every remaining seat.
- Later offers may become more restricted as the setup fills.
- Never generate an illegal menu and hope the Storyteller repairs it later.
- If no legal offer exists, pause privately for the Storyteller.

The Storyteller may then:

- enable recycling;
- undo or empty the relevant seat;
- apply a guarded manual assignment.

Other players must not receive a message or timing clue about this pause.

## Setup Modifiers

Setup-changing characters must update the remaining target immediately.

The supported rules catalog includes:

- Atheist
- Balloonist
- Baron
- Bounty Hunter
- Fang Gu
- Godfather
- Hermit
- Kazali
- Legion
- Lil' Monsta
- Lord of Typhon
- Marionette
- Riot
- Summoner
- Vigormortis
- Xaan

Examples:

- Baron replaces two remaining Townsfolk spaces with Outsiders.
- Godfather privately asks the Storyteller for its legal Outsider adjustment.
- Fang Gu, Balloonist, Vigormortis, and Xaan update the Outsider target.
- Bounty Hunter creates and preserves a legal evil Townsfolk target.
- Marionette requires a legal seat next to a character that can register as the
  Demon for this setup check.
- An actual Demon is always a legal Marionette anchor.
- A neighboring Recluse is also a legal candidate because the Recluse may
  register as the Demon. Using that exception does not change the Recluse's
  actual character, good alignment, or Outsider category.
- If the generator relies on the Recluse exception, show that privately in the
  Storyteller review and revalidate it before the game starts.
- If no remaining neighboring seat is legal, Marionette becomes unavailable.

Storyteller choices happen privately. The next player should be chosen through
the normal random flow after the decision. Modifier dialogs show only choices
that still fit completed assignments. When exactly one result remains legal,
the engine applies it without asking the Storyteller to choose a fake option.

## Hidden Character Rules

Hidden roles use separate actual and shown state:

- Drunk: actual Drunk, shown as a Townsfolk.
- Lunatic: actual Lunatic, shown as a Demon.
- Marionette: actual Marionette, shown as a Townsfolk, placed next to an actual
  Demon or a Recluse that is explicitly being allowed to register as the Demon
  for Marionette setup.
- Hermit-Drunk: actual Hermit with Drunk, shown as a Townsfolk.
- Hermit-Lunatic: actual Hermit with Lunatic, shown as a Demon.

Hidden options should preserve a real feeling of choice.

Example when one Outsider result is needed:

- Fortune Teller, secretly the Drunk.
- Butler, actually the Butler.
- Saint, actually the Saint.

Any combination is allowed if every actual outcome fills the same required
setup space. Avoid making all visible options secretly the same hidden role
when a mixed legal offer is possible.

Use at most one hidden substitution in an ordinary offer round unless no legal
mixed offer exists. If that last legal path still cannot be generated, pause
privately for the Storyteller instead of exposing the constraint.

When several hidden-role paths are equally legal, give those paths equal odds.

Drunk, Lunatic, and Marionette are not offered by their real names.

## Required Character Relationships

Choirboy and Huntsman should first resolve naturally:

- Choirboy creates a future King requirement.
- Huntsman creates a future Damsel requirement.
- Reserve that required character for only one randomly chosen future drafter
  at a time.
- Do not show King or Damsel repeatedly to every remaining player.
- Keep the required character inside a believable offer when possible.
- If it is discarded, move the unresolved requirement to one other eligible
  future drafter.

If the dependency cannot be completed:

1. Change the player whose selected character created the dependency.
2. Do not replace an unrelated player's valid choice.
3. Prefer changing the source into Drunk or Hermit-Drunk while keeping the
   original character as their shown role.
4. If that is not legal, use Village Idiot as the final legal fallback.
5. A player changed to Village Idiot is told their real character after the
   game starts.
6. Once the source is no longer the real Choirboy or Huntsman, the related
   requirement disappears.

Every dependency repair must finish before the Storyteller confirms
`Start Game`.

## Storyteller Review

The Storyteller receives a private Draft review screen.

It shows:

- the randomized draft order;
- the current player;
- every offer shown to each player;
- every discard;
- each final shown character;
- each final actual character;
- actual and shown alignment;
- remaining Townsfolk, Outsider, Minion, and Demon requirements;
- unresolved dependencies;
- setup modifier decisions;
- hidden substitutions;
- active jinxes and their exact Storyteller rules;
- hard-invalid states, unusual warnings, and unsupported interactions kept in
  separate sections;
- whether a safe public Djinn announcement can be produced;
- whether recycling is enabled;
- whether the setup is ready to start.

The Storyteller can return to this screen at any time.

The screen must make hidden state obvious to the Storyteller without turning
the player-facing flow into a wall of text.

After every locked seat has completed its turn, each completed-seat review
also becomes a final-character editor:

- `Change Character` opens the full supported non-Traveler catalogue by type.
- `Secret Character` assigns Drunk, Lunatic, Marionette, Hermit-Drunk, or
  Hermit-Lunatic and then requires the Storyteller to choose the character the
  player believes they are.
- A direct or hidden Hermit still requires exactly three unique Outsider
  abilities.
- The private 3/2/1 Draft history remains unchanged. The edit changes only the
  final actual character, shown character, alignment, and associated hidden
  state.
- The edited player's offhand book immediately shows their new perceived
  character and never exposes the actual hidden character.
- Final actual, perceived, and locked Hermit-ability characters remain unique
  unless Draft recycling is explicitly enabled. Village Idiot, Legion, and
  Riot retain their official duplicate exceptions.

The first final edit makes the resulting seats Storyteller-authoritative, as
in Greedy Whalebuffet's manual override. Recount the final type distribution,
normalize the remaining Draft targets to those seats, rebuild role retirement
and dependency state, and warn only the Storyteller inside their private Start
Game dialog that they must verify the edited distribution and setup effects.
Players are never told that the composition was edited. This deliberately
supports moving a Drunk, Lunatic, or Marionette between players without
rewriting what anyone originally drafted. At least one actual Demon, legal
Marionette placement, and hard jinx exclusions still block an invalid start.

## Disconnects And Empty Seats

- If the current drafter disconnects, pause their turn.
- Wait for them to return unless the Storyteller empties their seat.
- Do not move them to the end automatically.
- The pause is visible only to the Storyteller.
- An unseated player or spectator may claim the emptied seat.
- A replacement starts from the seat's clean state, not the former player's
  private offer history.

## Starting The Ordinary Game

The Storyteller must manually confirm `Start Game`.

Before starting, validate:

- every locked seat has a final actual and shown character;
- the final distribution is legal;
- setup modifiers are resolved;
- dependencies are resolved or legally repaired;
- hidden-role placement is valid;
- no disallowed duplicate exists;
- actual and shown alignment are complete;
- no in-play-exclusion jinx is violated;
- every setup-changing jinx is resolved;
- every runtime jinx has a Storyteller reminder;
- a required public Djinn announcement can be produced without revealing the
  secret setup;
- the generated script, first-night order, other-night order, jinxes, and
  Demon bluffs can be handed to the ordinary game.

After confirmation:

- apply the final actual roles and alignments;
- show each player only their shown character and alignment;
- hand control to Sybillian's normal game;
- stop all Draft-only selection behavior;
- assign spectator state to anyone who does not own a locked seat.

# Player-Facing Writing Rules

The writing guide applies to both gamemodes, not only this journal.

Use it for:

- item names and lore;
- dialog titles and button labels;
- setup instructions;
- validation errors;
- Storyteller warnings;
- player submission feedback;
- discard explanations;
- private pause messages;
- start confirmation;
- role and alignment announcements.

Messages should:

- state what happened;
- say what the player or Storyteller needs to do next;
- avoid explaining internal scoreboards, tags, generators, or solver state;
- avoid confirming hidden roles, recycling, dependencies, or forced choices;
- fit inside their buttons and dialog fields.

When a Buffet blocker needs chat to explain what went wrong, close the
affected player's or Storyteller's dialog first, play the established private
bass blocker alert, and leave the dialog closed. The message must say how to
reopen the relevant screen and continue. Do not play the blocker alert for
ordinary informational feedback, and do not close a dialog when the blocker is
already fully presented inside that visible dialog.

# Implementation Checkpoint

Current source work exists in:

- `Jays-Patch/buffet-rules.json`
- `tools/generate-buffet-gamemodes.ps1`
- `tools/generate-draft-buffet.ps1`
- `tools/tests/test-buffet-gamemodes.ps1`
- `Jays-Patch/datapack/data/botc_patch/function/buffet/`

Implemented source already covers much of:

- shared locked-roster state;
- Greedy player selection, Dealer's Choice, live latecomer seating, and
  Storyteller review;
- randomized seating in both modes, separate from randomized Draft turn order;
- the shared three-ability Hermit flow in both modes;
- Draft 3, 2, 1 offer rounds;
- the one-time hybrid Draft opening for setup-defining characters;
- private pre-offer conflict resolution for mutually exclusive role branches;
- equal random role selection inside the currently required category;
- opt-in Draft recycling that cannot resurrect chosen, conflict-blocked, or
  opening-only characters;
- actual and shown role state;
- hidden role paths;
- Storyteller modifier prompts;
- dependency and fallback functions;
- review and manual start paths;
- a versioned snapshot of supported official jinx rules;
- Draft eligibility and final validation for official in-play exclusions;
- Greedy eligibility and final validation for official in-play exclusions;
- integrated private Start Game warnings for active Greedy and Draft jinxes;
- regenerated code-library indexes and a passing non-live source gate, apart
  from the intentionally pending source-baseline and public-package refresh.

Live QA completed for Greedy Whalebuffet on 2026-07-30:

- player dialogs, submission review, and choice-change requests;
- late joins, seat replacement, and real disconnect/return;
- duplicate policy, hidden roles, the Hermit editor, jinxes, dependencies, and
  nonstandard-distribution warnings;
- final Sybillian handoff, stable player-seat identity, roster locking, role
  reveal, and setup-tool cleanup.

The first final handoff exposed Sybillian's shared-ID randomization. A
controlled ID/team rotation and a second real start passed after Buffet-owned
seat identity became the assignment key. The redundant Buffet bell replay was
then removed after client QA heard both it and Sybillian's upstream bell.

Still required before both beta modes can be called fully live-tested:

1. Perform Draft Buffet live QA for every discard round, hidden-role
   presentation, modifier pauses, Storyteller review, and the final Sybillian
   handoff.
2. Treat any unsupported or newly changed upstream jinx as a fail-closed
   compatibility issue rather than guessing its setup behavior.

Greedy Whalebuffet may now be marked live-tested. Both modes remain beta until
Draft's live QA and the public jinx-presentation decision are complete.

# Change Log

## 2026-07-31

- Reused the proven Greedy Storyteller presentation in Draft where the two
  modes share meaning: numbered player rows, submission-state dots, compact
  type-colored assignments with role icons, selected-role checkmarks, shared
  control icons, and a separate bottom Back action.
- Removed Draft's separate Jinx Review action. Start Game now presents active
  jinxes and legal unusual-setup warnings in its private confirmation, while
  invalid starts close the dialog and report every blocker in chat.
- Kept Draft's locked-seat replacement semantics instead of copying Greedy's
  roster-compaction behavior. An emptied Draft seat remains in the locked
  roster and its submenu explains that a replacement receives a fresh turn.
- Fixed Draft's first-turn and downstream macro contracts. Every macro call now
  supplies explicit storage or inline arguments, every placeholder-bearing
  command uses Minecraft's macro prefix, and ordinary offers carry a zero
  sentinel for the optional hidden-Hermit ability.
- Added regression audits for context-free macro calls and unexpanded
  placeholders. Live proof confirmed a five-player roster, a current drafter,
  exactly three first-round offers, and an exact three-offer history snapshot.
- Extended player Script redaction through Buffet setup phase `0`; stale
  previous-game scripts are now replaced before they can reveal selected
  characters or night order during either Buffet selection flow. The redacted
  Script now carries one setup-independent all-legal reminder catalogue so the
  normal Sybillian player Grimoire can still add reminder tokens.
- Made every Draft player keep the same `Choose your characters!` item in their
  offhand. Waiting clicks stay private, active clicks reopen the current offer,
  and completed clicks show only the character the player was shown.
- Limited setup-modifier prompts to results that still fit completed choices,
  with automatic resolution when only one legal result remains.
- Added a Storyteller-only final-character editor after every Draft turn is
  complete. It covers the full role catalogue, hidden perceived-role paths,
  and Hermit abilities; preserves the private Draft history; immediately
  updates the player's perceived-role book; rebuilds final bookkeeping; and
  clearly warns when the final setup became a manual override.
- Standardized Buffet chat blockers across both modes. They now close the
  affected dialog, play Greedy's established private bass alert, explain how
  to continue, and stay closed so a reopened menu cannot hide the message.
- Replaced only the Buffet players' upstream Grimoire item with a private
  Jay-owned notes dialog. Its overview has an explicit bottom Close button.
  Players can privately set a character or choose any of the 142 legal
  reminders for one of Sybillian's six reminder spaces. The paged reminder
  picker includes the source character in each label so repeated token text
  such as `Dead` remains clear.
- The Sybillian-view button synchronizes `player_1` through `player_15` and
  `p1_role` through `p15_role`, then clears the server dialog before opening
  `ct-player_grim`. This prevents `Nobody!` labels and the unfinished
  `Waiting for Server` screen. Opening either view never clears
  `pN_r1..r6_text/icon`; the Jay picker changes only the selected text/icon
  pair, so existing reminders survive closing and reopening for that client
  session. They remain subject to Sybillian's client-local persistence limits
  across reconnects or client resets.

## 2026-07-30

- Consolidated the complete approved Greedy Whalebuffet and Draft Buffet design
  from chat history, source rules, generators, and tests.
- Added the approved hybrid Draft generator direction.
- Set character odds to equal `1 / N` odds within the currently eligible
  category.
- Added private conflict resolution for mutually exclusive characters.
- Split roster behavior: Greedy remains open to latecomers until Start Game,
  while Draft locks before its randomized private order begins.
- Added the shared legality model, jinx classifications, staged validation,
  and the unresolved public-sheet privacy requirement.
- Made the three-ability Hermit rule shared by Greedy Whalebuffet and Draft
  Buffet.
- Added the Recluse registration exception for Marionette placement and final
  validation.
- Added Dealer's Choice as a complete Greedy submission while preserving
  optional player preferences.
- Added Greedy jinx review and official in-play-exclusion validation.
- Implemented the private hybrid opening and pre-offer conflict coin flips.
- Hardened Draft recycling so the default-off setting is respected and
  permanent opening/conflict decisions cannot be recycled.
- Hardened Greedy roster refreshes so an unresolved seat sign preserves the
  reserved player's remembered name instead of replacing it with `Seat N`.
  Empty seats clear the former house-head profile, and snapshots update a
  profile only after resolving a real player name.
- Fixed Request Different Choices so its selected-seat macro receives the
  captured review data and reliably moves an assigned player to Needs
  Attention before notifying them.
- Fixed real-player reconnects by preserving a Buffet-owned seat identity
  across disconnects, restoring Sybillian's shared seat ID and color team
  from it, and retaining generation checks for seats genuinely reassigned
  while their former occupant was offline.
- Fixed final start handoff identity by restoring every locked player's shared
  Sybillian ID and color team from the Buffet-owned seat immediately after the
  upstream start randomizes them. Greedy and Draft then apply exact assignments
  through the private Buffet seat key, so roles remain attached to the reviewed
  player rather than whichever player inherited that shared ID.
- Removed the redundant Buffet start-bell replay. Sybillian's night transition
  already plays the start bell; the separate replay remains only in the remote
  setup-room workflow where its player-local positioning is required.
