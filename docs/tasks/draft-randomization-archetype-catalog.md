# Draft Buffet Archetype Catalog

- Status: design accepted; implementation complete and source verified
- Updated: 2026-08-03
- Scope: all 138 characters in the trusted Sybillian/Buffet catalog

Compatibility note: Organ Grinder keeps its catalog type and archetype so catalog validation remains complete, but it is not Draft-eligible or selectable while the project targets Sybillian 1.5.4 because that modpack version does not support it. The active Draft lottery therefore has 137 compatibility-eligible characters.

## Probability contract

- Every character has exactly one primary Draft archetype.
- Each card first chooses uniformly among trusted actual character types that still have an unmet need and at least one legal actual candidate. Remaining slot counts do not give an open type extra weight.
- Every card makes this type roll independently. Cards already displayed in the same hand do not consume or reduce a type, so every legal combination and order remains possible, including three cards of the same type.
- The rolled type and subsequent character draw determine trusted actual state. A legal Drunk, Lunatic, Hermit-Drunk, Hermit-Lunatic, or Marionette then receives its required shown character, which may have a different visible type; hidden presentation never changes another card's independent actual-type roll.
- A fulfilled type leaves the lottery. If a later finalized setup modifier creates a new need for that type, it returns with the same probability as every other open type.
- The actual character's primary archetype participates in offer weighting and soft diversity only after the actual-type roll. Archetype weighting never changes the accepted equal probabilities of the open actual character types.
- After the actual-type roll, every eligible actual character in that type starts with one equal base ticket. Archetype buckets do not receive equal total weight; primary archetype only adjusts repeat weight for soft diversity inside the current hand.
- For the weighted draw, scale those equal base tickets to four. A candidate keeps four tickets with no matching actual primary archetype already in the hand, drops to two after one match, and drops to one after two. Reset for every fresh three-card, two-card, or one-card hand.
- Hidden modes do not create extra character tickets. With all 23 Outsiders eligible in a fresh hand, each actual Outsider starts at `1 / 23` before soft diversity: Lunatic owns Lunatic's ticket, and Hermit-Drunk or Hermit-Lunatic uses Hermit's single ticket rather than becoming a twenty-fourth character. The five Outsider archetypes therefore carry aggregate base mass `5 / 23`, `5 / 23`, `5 / 23`, `4 / 23`, and `4 / 23`, not five equal `1 / 5` shares.
- Archetype names and route classes are internal generator metadata. Players see character cards, not the category labels that produced them.
- A character may have other mechanical traits, but those secondary traits do not grant extra lottery tickets.
- Character type, archetype, route class, hidden identity, setup modifiers, jinxes, retirement, and final-composition legality remain separate fields.
- Direct discards normally retire globally. Before each fresh hand, however, every still-required actual type recovers only its exact legal direct-card shortfall when fewer than `3`, `2`, or `1` direct candidates remain for that hand. Selected roles, hidden-mask discards, blocked roles, and roles already seen by the current player never re-enter through this completion rule.
- The category names describe the character's dominant player-facing mechanic, not every interaction in its ability.
- Special-route and controlled-topology guards override archetype selection. An archetype never makes an otherwise illegal character eligible.
- Hidden Lunatic or Hermit-Lunatic diversion is legal only on the first internally generated card of the player's first three-card hand, before any ordinary cards are shown. Once an ordinary hand appears, that player's later discard hands exclude both diversion modes so a delayed special flow cannot prove itself fake.
- Legion may replace the route's baseline Outsider target while preserving deliberate positive Storyteller additions as its minimum Outsider floor. This topology rule does not change character or archetype lottery weight.

## Route classes

| Route class | Characters | Draft meaning |
|---|---|---|
| Storyteller-selected Atheist | Atheist | A real Atheist is guaranteed only when the Storyteller privately chooses `Atheist Draft`. Normal or Demon-special starts with a remaining legal Outsider slot may give the identical forced-Atheist presentation to an actual Drunk or Hermit-Drunk, so the player cannot infer which start mode occurred. |
| Random Demon-special | Kazali, Legion, Lord of Typhon | `Normal Draft` rolls this guaranteed-real route once per game at a fixed 10% across 5-15 players. Any eligible player may receive its one-at-a-time three-character pool, discard twice, and be forced into the third unique result. An eligible ordinary route may show the identical flow when its ordinary Outsider character lottery selects Lunatic or Hermit-Lunatic while a legal Outsider slot remains. |
| Controlled topology | Lil' Monsta, Summoner | Excluded from unguarded generation and offered only through their accepted topology-aware paths. |
| Normal exception | Riot | Remains a normal Demon even though its archetype is format/setup changing; the Storyteller resolves Minions becoming Riot during live play. |
| Normal | Every other supported character | Uses normal type-plus-archetype generation, subject to existing legality and setup-modifier guards. |

## Townsfolk

| Primary archetype | Definition | Characters | Count |
|---|---|---|---:|
| First-night information | Receives its defining information when the game starts or when first created. | Chef, Clockmaker, Grandmother, Investigator, Knight, Librarian, Noble, Shugenja, Steward, Washerwoman | 10 |
| Ongoing information | Repeatedly receives information or builds an information sequence across the game. | Balloonist, Bounty Hunter, Chambermaid, Dreamer, Empath, Flowergirl, Fortune Teller, Gambler, General, High Priestess, King, Mathematician, Oracle, Savant, Town Crier, Undertaker, Village Idiot | 17 |
| Limited investigation | Creates a bounded or once-per-game piece of evidence. | Artist, Fisherman, Juggler, Seamstress | 4 |
| Protection and survival | Prevents, redirects, survives, or tightly controls deaths. | Fool, Innkeeper, Lycanthrope, Monk, Pacifist, Sailor, Soldier, Tea Lady | 8 |
| Death and inheritance | Gains value from dying, another player's death, resurrection, or passing an ability onward. | Acrobat, Banshee, Cannibal, Choirboy, Farmer, Pixie, Professor, Ravenkeeper, Sage | 9 |
| Public action, confirmation, and alternate victory | Uses public guesses, nominations, voting, explicit confirmation, or a public alternate victory route to create leverage. | Alsaahir, Atheist, Cult Leader, Gossip, Mayor, Nightwatchman, Princess, Slayer, Virgin | 9 |
| Suppression and interference | Disables, intoxicates, blocks, or interferes with abilities or evil-team coordination. | Courtier, Exorcist, Magician, Minstrel, Poppy Grower, Preacher | 6 |
| Character and setup manipulation | Gains, creates, replaces, or changes character abilities or setup pieces. | Alchemist, Amnesiac, Engineer, Huntsman, Philosopher, Snake Charmer | 6 |

Townsfolk total: **69**

## Outsiders

| Primary archetype | Definition | Characters | Count |
|---|---|---|---:|
| Hidden identity, ability, and registration | Obscures the player's real ability, combines uncertain abilities, produces unreliable information, or registers misleadingly. | Drunk, Hermit, Lunatic, Puzzlemaster, Recluse | 5 |
| Voting and nomination constraint | Makes ordinary nominations, voting, execution, or public claims dangerous or restricted. | Butler, Golem, Mutant, Saint, Zealot | 5 |
| Death consequence | Creates a harmful or destabilizing consequence when the Outsider dies or may die. | Barber, Klutz, Moonchild, Sweetheart, Tinker | 5 |
| Evil empowerment | Gives the evil team information, leverage, abilities, or character-change opportunities. | Damsel, Hatter, Plague Doctor, Snitch | 4 |
| Alignment and victory volatility | Changes alignment, attaches the player to another alignment, or reverses normal victory incentives. | Goon, Heretic, Ogre, Politician | 4 |

Outsider total: **23**

## Minions

| Primary archetype | Definition | Characters | Count |
|---|---|---|---:|
| Lethal pressure | Kills players directly or turns a public choice, madness break, nomination, or death into a lethal threat. | Assassin, Boomdandy, Godfather, Harpy, Psychopath, Witch | 6 |
| Misinformation and surveillance | Poisons information, hides inside the good team, sees private state, observes night activity, or creates a mass-information failure. | Marionette, Poisoner, Spy, Widow, Wraith, Xaan | 6 |
| Public coercion and vote control | Manipulates madness, nominations, voting, execution choices, or public win threats. | Cerenovus, Fearmonger, Goblin, Organ Grinder, Vizier | 5 |
| Execution and Demon continuity | Protects an evil player from execution consequences or keeps the evil game alive after the Demon falls. | Devil's Advocate, Evil Twin, Mastermind, Scarlet Woman | 4 |
| Character and setup manipulation | Changes characters, alignments, abilities, the Demon state, or the starting composition. | Baron, Boffin, Mezepheles, Pit-Hag, Summoner, Wizard | 6 |

Minion total: **27**

## Demons

| Primary archetype | Definition | Characters | Count |
|---|---|---|---:|
| Corruption and misinformation | Combines Demon killing with poisoning, false information, or broad information degradation. | No Dashii, Pukka, Vigormortis, Vortox | 4 |
| Variable killing and target control | Produces extra deaths, variable death counts, delayed choices, or unusual control over who dies. | Al-Hadikhia, Ojo, Po, Shabaloth, Yaggababble | 5 |
| Survival and transfer | Survives through a host, transfers Demonhood, replaces its player identity, or hides whether the Demon remains alive. | Fang Gu, Imp, Lil' Monsta, Lleech, Zombuul | 5 |
| Format and setup changing | Rebuilds the evil team, changes the normal execution clock, creates a swarm, or otherwise changes the game's ordinary structure. | Kazali, Legion, Leviathan, Lord of Typhon, Riot | 5 |

Demon total: **19**

## Catalog audit

| Check | Expected | Result |
|---|---:|---:|
| Townsfolk | 69 | 69 |
| Outsiders | 23 | 23 |
| Minions | 27 | 27 |
| Demons | 19 | 19 |
| Total | 138 | 138 |

## Review notes

- Categories are intentionally broad enough to support several legal characters per lottery bucket. Atheist is not a singleton archetype: its guarded route is separate metadata, while its primary player-facing category is Public action, confirmation, and alternate victory.
- Characters with hybrid abilities use their dominant Draft experience. For example, the Princess is under public action because the nomination-and-execution requirement defines how the player uses the role, even though the result prevents a Demon kill.
- For hybrid abilities, the main player-facing benefit outranks a cost or side effect. The Innkeeper is therefore Protection and survival; making one protected target drunk is secondary metadata, not its primary category.
- The hybrid audit also moved Pixie to Death and inheritance, Gambler to Ongoing information, Juggler to Limited investigation, Mayor to Public action/alternate victory, and Xaan to Misinformation. Their setup, timing, and legality traits remain separate metadata.
- Setup modifiers such as Balloonist, Godfather, and Xaan retain their separate setup metadata. Their archetype does not replace or weaken modifier validation.
- Full supported-Demon reassignment is a trusted Grimoire tool available to every Storyteller during any night. It is not another Draft route and does not add Demon lottery tickets; Summoner and Alchemist-Summoner still begin under their accepted no-Demon topology.
- Hidden actual characters remain governed by the accepted hidden-identity rules. Categorizing the Drunk or Lunatic does not globally retire that hidden actual merely because it was offered and rejected.
- Jay accepted these individual assignments and the complete probability contract. Schema 2 now stores them as machine-readable generator input, and generation fails unless every Draft-eligible character has exactly one trusted type and archetype assignment.
