# Jay's Patch

Jay's Patch is my unofficial server-side add-on for
[Sybillian's Blood on the Clocktower modpack](https://modrinth.com/modpack/blood-on-the-clocktower/version/1.5.4).
It adds circular seating, end-game Grimoire reveals and a private setup room.
It also gives the Storyteller quicker access to Sybillian's tools and backports
Night Chat from Sybillian's newer beta.

I made it for **Sybillian's modpack 1.5.4** on
**Minecraft Java Edition 1.21.10**. It is not a standalone server pack.

**[Download Jay's Patch v1.9.0-beta.1](https://github.com/JayLeet/Jays-Patch/archive/refs/tags/v1.9.0-beta.1.zip)**

## What does it add?

### 1. 🪑 Circular seating

No more conga lines. Players are placed in a circle that adjusts to the number
of people in the game, from 1 to 15 players.

The layout updates while everyone is joining, then locks when the game starts.

### 2. 📖 End-game Grimoire reveal

The Storyteller can reveal each player's character and alignment one seat at a
time, including sounds, particles and a spotlight moving around the circle.

If something changed during the game, the Storyteller can update a player's
displayed character or alignment before starting the reveal.

The Storyteller can cancel an accidental reveal before anything is shown.

### 3. 🎭 Storyteller controls

These features already exist in Sybillian's modpack. My patch makes them
available through quicker hotbar items and server-side dialog menus.

- ⏭️ **Advance the phase**
- 💀 **Kill or revive players**
- 🔥 **Manage nominations**
- ⏱️ **Set a Timer**
- 🪑 **Return everyone to their seats**
- 🚪 **Teleport to players, houses, the evil team or the Storyteller den**
- 📖 **A new item called Storyteller Tools**

Storyteller's Passage lets the Storyteller move and teleport as a spectator,
then safely returns them when they enter or leave a private voice area.

You can use item mode, dialog mode or Sybillian's original setup bag. Pick the
option that feels best for you.

### 4. 🧰 A different way to set up games

My setup bag takes the Storyteller to a private setup room with a wall of
character icons.

- 📜 Pick **Trouble Brewing**, **Sects and Violets** or **Bad Moon Rising**.
- ✏️ Import a custom script when you want to play something different.
- 🖱️ Right-click characters on the wall to add or remove them from the setup.
- 🔔 Start the game or navigate around using the items in your hotbar.

### 5. 🎲 Beta game modes

The Setup Bag includes two different ways to choose characters before the
game begins.

- **Greedy Whalebuffet** lets everyone submit private character preferences at
  the same time. Players can also choose Dealer's Choice and leave the
  decision up to the Storyteller.
- **Draft Buffet** gives players turns in a random order. Each player
  chooses from a changing set of characters while the remaining setup
  adjusts around earlier choices.

### 6. 🎙️ Night Chat

This backports Sybillian's Night Chat from the 1.6.0 beta for servers using
modpack 1.5.4. During the night, seated players inside a house receive a
microphone in their second hotbar slot. Hold it to speak with anyone else
holding a Night Chat microphone.

### 7. 🎉 Winner reveals

Good and Evil each get a winner reveal with a short suspense sequence,
sounds, titles and fireworks. The winning players also receive matching heads
for the celebration.

### 8. 🏡 Setup room and world edits

I added a dedicated setup room, changes to the inn and several interior and
exterior touch-ups to the included world. These changes are why installation
replaces your existing world folder.

## More additions

- 🎵 **Personal night music** stays off by default and lets each player choose
  from every jukebox disc, ambient tracks, random playback and lower or normal
  pitch.
- 🙋 **Raise and lower your hand** with a simple hotbar item.
- 🧑‍⚖️ **Storyteller queue** so players can join, leave and check their place in line.
- 🗳️ **Votekicks** that show the current vote count and remove the player when the vote succeeds.
- 👻 **Banshee voting controls** for single or double votes after the Banshee dies.
- 🎭 **Character tools** for Fearmonger announcements, Banshee awakening,
  Al-Hadikhia targets, Cerenovus madness executions and Boomdandy finales.
- 👻 **Wraith support** with Closed, Peek and Eyes Open choices during the
  night, including private visits and a chance for good players to spot the
  Wraith.
- 📕 **Spy and Widow Grimoire views** let the Storyteller show the true characters
  in their personal Grimoire.
- 💥 **Boomdandy final three** removes every other chair, eliminates non-finalists one at a time and lets the survivors vote by standing near the player they want to die.
- ✊ **Rock Paper Scissors** lets the Storyteller start Sybillian's original
  two-player countdown from Grimoire Tools after both players make their choice.
- ❗ **Notification badges** show the Storyteller when an in-play character has a relevant action available.
- 🛠️ **Useful commands** for setup, game phases, teleporting, timers and player management.

## Installation

I've included a prepared world, config files, the datapack and a resource pack.
Do not install only the `jays_patch` datapack folder.

### Requirements

- [Sybillian's Blood on the Clocktower 1.5.4](https://modrinth.com/modpack/blood-on-the-clocktower/version/1.5.4)
- Minecraft Java Edition 1.21.10

### Back up your server

> [!WARNING]
> My datapack replaces your world folder. Back up your current `world` and
> `config` folders if they contain anything you want to keep.

### First-time install

1. Install Sybillian's Blood on the Clocktower **1.5.4** on your server.
2. Start the server once, then stop it completely.
3. Back up your current `world` and `config` folders.
4. [Download Jay's Patch v1.9.0-beta.1](https://github.com/JayLeet/Jays-Patch/archive/refs/tags/v1.9.0-beta.1.zip) and extract it.
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
resource-pack=https://download.mc-packs.net/pack/5f3b624c1e7f488c969adefa5e6673f8a724348b.zip
resource-pack-id=b3fed73e-fec2-4de2-b34b-236a7d1095fe
resource-pack-prompt={"text"\:"","extra"\:[{"text"\:"BOTC","color"\:"dark_red","bold"\:true},{"text"\:" | ","color"\:"dark_gray","bold"\:false},{"text"\:"Jay's Patch Resource Pack","color"\:"gold","bold"\:false},{"text"\:"\\nAccept this pack to see Jay's Patch's custom icons.","color"\:"gray","bold"\:false}]}
resource-pack-sha1=5f3b624c1e7f488c969adefa5e6673f8a724348b
```

If the hosted resource pack stops working, upload
[`resourcepack/Jays-Patch-resourcepack.zip`](resourcepack/Jays-Patch-resourcepack.zip)
to a Minecraft resource-pack host. Replace the resource-pack URL, SHA-1 and ID
with the values provided by the host.

The included [`HOW TO INSTALL.txt`](HOW%20TO%20INSTALL.txt) contains the same
installation steps in a plain text file.

## Useful commands

Run `/botc help` in game to see the full command list.



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
