# Jay's Patch

Jay's Patch is my unofficial server-side add-on for
[Sybillian's Blood on the Clocktower modpack](https://modrinth.com/modpack/blood-on-the-clocktower/version/1.5.4).
It adds new ways to build games, quicker Storyteller controls, character-specific
moments and more things to mess around with between games. Players also sit in a
proper circle, and Night Chat lets people speak privately during the night.

I made it for **Sybillian's modpack 1.5.4** on
**Minecraft Java Edition 1.21.10**. It is not a standalone server pack.

**[Download Jay's Patch v1.9.0](https://github.com/JayLeet/Jays-Patch/releases/download/v1.9.0/Jay.s.Patch.v1.9.0.zip)**

## AI disclosure

Jay's Patch is an AI-assisted project. AI has been used for code,
documentation, testing, and repository and release maintenance. This project
should not be presented as AI-free.

## What does it add?

### 🪑 A Town Square that fits the game

No more conga lines. From 1 to 15 players are seated in a circle that adjusts
while everyone joins and locks when the game starts.

### 🎲 More ways to build a game

The private setup room gives the Storyteller a wall of character icons for
**Trouble Brewing**, **Sects and Violets**, **Bad Moon Rising** or an imported
custom script. Right-click characters to change the setup, then start the game
from the items in your hotbar.

- **Greedy Whalebuffet** lets everyone privately submit their favourite
  characters at the same time or choose Dealer's Choice. Greedy's adjusted
  character abilities appear in role displays and Grimoire dialogs.
- **Draft Buffet** gives each player a private turn to choose from 3, then 2,
  then 1 character while the game changes around earlier picks.

### 🎭 Quicker Storyteller controls

Use hotbar items or server-side dialog menus to advance the phase, set timers,
kill or revive players, manage nominations, return everyone to their seats and
teleport around the game. **Storyteller Tools** keeps the most useful controls
together in one item.

Storyteller's Passage lets the Storyteller move and teleport as a spectator,
then returns them safely when they enter or re-enter a private voice area.

Use item mode, dialog mode or Sybillian's original setup bag. Pick the option
that feels best for you.

### 📖 Grimoire Reveal

Reveal every player's character and alignment one seat at a time, with sounds,
particles and a spotlight moving around the circle. The Storyteller can correct
a displayed character or alignment before the reveal starts and cancel an
accidental reveal before anything is shown.

Good and Evil each get their own winner reveal with a short suspense sequence,
titles, fireworks and matching heads for the winners.

### 🎙️ Talk privately at night

Night Chat backports Sybillian's 1.6.0 beta feature for servers using modpack
1.5.4. During the night, seated players inside a house receive a microphone in
their second hotbar slot. Hold it to speak with anyone else holding one.

### 👻 Character changes and the addition of Wraith

- **Wraith** players can keep their eyes closed, peek from home or sneak out
  with the Storyteller at night.
- **Spy and Widow** players can privately see the true Grimoire.
- Character tools help the Storyteller handle Fearmonger announcements,
  Banshee votes, Al-Hadikhia targets, Cerenovus executions and Boomdandy
  finales.
- A Boomdandy execution can lead into a unique Final Three or use Sybillian's
  normal execution so the game continues.
- Rock Paper Scissors starts Sybillian's original two-player countdown after
  both players choose, and notification badges tell the Storyteller when an
  in-play character has an action available.

### 🎉 More to do around the game

- Choose personal night music from the Minecraft music catalog, including
  random playback and lower-pitched versions. It stays off by default.
- Raise or lower your hand, join the Storyteller queue and start a votekick.
- Fire colourful Paint Guns, starpass the Imp in Hot Potato, drink Silly Juice, or
  roll a d20.
- Use `/botc help` whenever you need the full command list.

### 🏡 A world built for the patch

The included world has a dedicated setup room, changes to the inn and several
interior and exterior touch-ups. These changes are why installation replaces
your existing world folder.

## Installation

I've included a prepared world, config files, the datapack and a resource pack.
Do not install only the `jays_patch` datapack folder.

### Requirements

- [Sybillian's Blood on the Clocktower 1.5.4](https://modrinth.com/modpack/blood-on-the-clocktower/version/1.5.4)
- Minecraft Java Edition 1.21.10

Organ Grinder is disabled because Sybillian 1.5.4 does not support it.

### Back up your server

> [!WARNING]
> My datapack replaces your world folder. Back up your current `world` and
> `config` folders if they contain anything you want to keep.

### First-time install

1. Install Sybillian's Blood on the Clocktower **1.5.4** on your server.
2. Start the server once, then stop it completely.
3. Back up your current `world` and `config` folders.
4. [Download Jay's Patch v1.9.0](https://github.com/JayLeet/Jays-Patch/releases/download/v1.9.0/Jay.s.Patch.v1.9.0.zip) and extract it.
5. Replace your server's `world` folder with the included `world` folder.
6. Copy the included `config` folder into your server folder. Merge it with the
   existing `config` folder and replace files when asked.
7. Open your existing `server.properties` file and change only the values shown below.
8. Start the server and wait for it to finish loading.
9. Join the server and accept the Jay's Patch resource pack when asked.

### Required `server.properties` values

```properties
function-permission-level=3
spawn-protection=0
resource-pack=https://download.mc-packs.net/pack/4c20eb69b74e8138d55d1ddeb29dc79722335d8d.zip
resource-pack-id=d469daa3-17aa-4f4f-8e61-e4dcde432776
resource-pack-prompt={"text"\:"","extra"\:[{"text"\:"BOTC","color"\:"dark_red","bold"\:true},{"text"\:" | ","color"\:"dark_gray","bold"\:false},{"text"\:"Jay's Patch Resource Pack","color"\:"gold","bold"\:false},{"text"\:"\\nAccept this pack to see Jay's Patch's custom icons.","color"\:"gray","bold"\:false}]}
resource-pack-sha1=4c20eb69b74e8138d55d1ddeb29dc79722335d8d
```

If the hosted resource pack stops working, upload
[`resourcepack/Jays-Patch-resourcepack.zip`](resourcepack/Jays-Patch-resourcepack.zip)
to a Minecraft resource-pack host. Replace the resource-pack URL, SHA-1 and ID
with the values provided by the host.

The included [`HOW TO INSTALL.txt`](HOW%20TO%20INSTALL.txt) contains the same
installation steps in a plain text file.

## Useful commands

Run `/botc help` in game to see the full command list.

### Fun commands

| Command | What it does |
| --- | --- |
| `/botc fun sillyjuice` | Gives you Silly Juice, which adds Slowness I and two minutes of strange personal sounds and particles. |
| `/botc fun boomdandy` | Gives you a single-use party popper with a short countdown and fireworks. |
| `/botc fun hot_potato` | Starts hot potato with the Imp. Right-click another player to pass it before it pops. |
| `/botc fun dice_roll` | Publicly rolls a 20-sided die. You can use it once per minute. |
| `/botc fun paint_gun` | Gives you a temporary Paint Gun that fires your seat colour. |
| `/botc fun rainbow_paint_gun` | Gives you a temporary Paint Gun that splashes connected blocks with bright random colours. |
| `/botc slayer [player]` | Gives you a Slayer's Bow. Only the Storyteller can give one to another player. |
| `/botc king` | Gives you a King entrance item. Use it in the Town Square to make your claim. |
| `/botc vizier <player>` | Lets the Storyteller reveal the selected player's Vizier entrance. |

## Found a problem?

If something isn't working, [open an issue](https://github.com/JayLeet/Jays-Patch/issues)
and explain what happened. Include your Jay's Patch version and the steps that
caused it if you can.

## Credits

I built my datapack on top of Sybillian's Blood on the Clocktower modpack. It
includes a modified copy of Sybillian's world, datapack and resource-pack
assets. Sybillian gave me permission to release this add-on publicly as long as
I link back to the original project and name the supported version.

- [Sybillian's Blood on the Clocktower 1.5.4](https://modrinth.com/modpack/blood-on-the-clocktower/version/1.5.4)
- [Sybillian's source code](https://github.com/Sybillian/minecraft-botc)
- [Blood on the Clocktower](https://bloodontheclocktower.com/)

Read [`CREDITS.md`](Legal/CREDITS.md) for the full list of credits. License
and ownership details are in [`LICENSE`](LICENSE),
[`ASSET_LICENSE.md`](Legal/ASSET_LICENSE.md),
[`BRANDING.md`](Legal/BRANDING.md) and
[`THIRD-PARTY-LICENSES`](Legal/THIRD-PARTY-LICENSES/).

My datapack is free and unofficial. It is not endorsed by Sybillian, The
Pandemonium Institute, Mojang Studios or Microsoft.
