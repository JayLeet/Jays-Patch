# Jay's Patch

Jay's Patch is my unofficial server-side add-on for
[Sybillian's Blood on the Clocktower modpack](https://modrinth.com/modpack/blood-on-the-clocktower/version/1.5.4).
It adds circular seating, end-game Grimoire reveals, quicker access to
Storyteller tools, a different way to set up games and several smaller changes
that make games easier to run.

I made it for **Sybillian's modpack 1.5.4** on
**Minecraft Java Edition 1.21.10**. It is not a standalone server pack.

**[Download Jay's Patch v1.5.2](https://github.com/JayLeet/Jays-Patch/archive/refs/tags/v1.5.2.zip)**

## What does it add?

### 1. 🪑 Circular seating

No more conga lines. Players are placed in a circle that adjusts to the number
of people in the game, from 1 to 15 players.

The layout updates while everyone is joining, then locks when the game starts.
The Storyteller can also send everyone back to their seats when needed.

### 2. 📖 End-game Grimoire reveal

The Storyteller can reveal each player's character and alignment one seat at a
time, including sounds, particles and a spotlight moving around the circle.

If something changed during the game, the Storyteller can update a player's
displayed character or alignment before starting the reveal.

### 3. 🎭 Storyteller tools in your hotbar

These features already exist in Sybillian's modpack. My patch adds them as
items in your hotbar for quicker and easier access.

- ⏭️ **Advance the phase**
- 💀 **Kill or revive players**
- 🔥 **Manage nominations**
- ⏱️ **Open the timer**
- 🪑 **Return everyone to their seats**
- 🚪 **Teleport to players, houses, the evil team or the Storyteller den**
- 📖 **Open the Grimoire tools**

You can use hotbar items, dialog menus or Sybillian's original setup bag. Pick
the option that feels best for your server.

### 4. 🧰 A different way to set up games

My setup bag takes the Storyteller to a private setup room with a wall of
character icons.

- 📜 Pick **Trouble Brewing**, **Sects and Violets** or **Bad Moon Rising**.
- ✏️ Import a custom script when you want to play something different.
- 🖱️ Right-click characters on the wall to add or remove them from the setup.
- 🔔 Start the game from the room and reveal each player's character only to that player.

### 5. 🎉 A better ending

Good and Evil each get a winner reveal with a short suspense sequence,
sounds, titles and fireworks. The winning players also receive matching heads
for the celebration.

### 6. 🏡 World changes

I added a dedicated setup room, changes to the inn and several interior and
exterior touch-ups to the included world. These changes are why installation
replaces your existing world folder.

## More additions

- 🎵 **Personal night music** with random tracks, a music selector, pitch control and an off switch.
- 🙋 **Raise and lower your hand** with a simple hotbar item.
- 🧑‍⚖️ **Storyteller queue** so players can join, leave and check their place in line.
- 🗳️ **Votekicks** that show the current vote count and remove the player when the vote succeeds.
- 👻 **Banshee voting controls** for single or double votes after the Banshee dies.
- 🛠️ **Useful commands** for setup, game phases, teleporting, timers and player management.

## Installation

I've included a prepared world, config files, the datapack and a resource pack.
Do not install only the `jays_patch` datapack folder.

### Requirements

- [Sybillian's Blood on the Clocktower 1.5.4](https://modrinth.com/modpack/blood-on-the-clocktower/version/1.5.4)
- Minecraft Java Edition 1.21.10

### Back up your server

> [!WARNING]
> Jay's Patch replaces your world folder. Back up your current `world` and
> `config` folders if they contain anything you want to keep.

### First-time install

1. Install Sybillian's Blood on the Clocktower **1.5.4** on your server.
2. Start the server once, then stop it completely.
3. Back up your current `world` and `config` folders.
4. [Download Jay's Patch v1.5.2](https://github.com/JayLeet/Jays-Patch/archive/refs/tags/v1.5.2.zip) and extract it.
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
resource-pack=https://download.mc-packs.net/pack/d73d89620b05d15ee38db51a3073f66a3308d4a7.zip
resource-pack-sha1=d73d89620b05d15ee38db51a3073f66a3308d4a7
resource-pack-id=438930c8-37ac-42cc-8504-0d8b605bba74
resource-pack-prompt={"text"\:"","extra"\:[{"text"\:"BOTC","color"\:"dark_red","bold"\:true},{"text"\:" | ","color"\:"dark_gray","bold"\:false},{"text"\:"Jay's Patch Resourcepack","color"\:"gold","bold"\:false},{"text"\:"\\nIt is recommended to use this resourcepack","color"\:"gray","bold"\:false}]}
```

If the hosted resource pack stops working, upload
[`resourcepack/Jays-Patch-resourcepack.zip`](resourcepack/Jays-Patch-resourcepack.zip)
to a Minecraft resource-pack host. Replace the resource-pack URL, SHA-1 and ID
with the values provided by the host.

The included [`HOW TO INSTALL.txt`](HOW%20TO%20INSTALL.txt) contains the same
installation steps in a plain text file.

## Useful commands

Run `/botc help` in game to see the full command list.

| Command | What it does |
| --- | --- |
| `/st start` | Starts the game after setup. |
| `/st advance_phase` | Moves the game to the next phase. |
| `/st timer <minutes> <seconds>` | Starts the conversation timer. |
| `/setupbag preset trouble_brewing` | Loads a base script preset. |
| `/setupbag import <script-json>` | Imports a custom script. |
| `/botc grimoire start` | Starts the end-game Grimoire reveal. |
| `/botc music toggle` | Turns your personal night music on or off. |
| `/botc queue` | Joins the Storyteller queue. |

## Found a problem?

If something isn't working, [open an issue](https://github.com/JayLeet/Jays-Patch/issues)
and explain what happened. Include your Jay's Patch version and the steps that
caused it if you can.

## Credits

I built Jay's Patch on top of Sybillian's Blood on the Clocktower modpack. It
includes a modified copy of Sybillian's world, datapack and resource-pack
assets. Sybillian gave me permission to release this add-on publicly as long as
I link back to the original project and name the supported version.

- [Sybillian's Blood on the Clocktower 1.5.4](https://modrinth.com/modpack/blood-on-the-clocktower/version/1.5.4)
- [Sybillian's source code](https://github.com/Sybillian/minecraft-botc)
- [Blood on the Clocktower](https://bloodontheclocktower.com/)

Read [`CREDITS.md`](Licenses/CREDITS.md) for the full list of credits. License
and ownership details are in [`LICENSE`](LICENSE),
[`ASSET_LICENSE.md`](Licenses/ASSET_LICENSE.md),
[`BRANDING.md`](Licenses/BRANDING.md) and
[`THIRD-PARTY-LICENSES`](Licenses/THIRD-PARTY-LICENSES/).

Jay's Patch is free and unofficial. It is not endorsed by Sybillian, The
Pandemonium Institute, Mojang Studios or Microsoft.
