# BOTC Minecraft Server

This folder starts a Blood on the Clocktower Minecraft server.

You do not need to code to use this. You mostly need to install Docker, edit one
small settings file, and double-click `BOTC.exe`.

## What The Files Are

- `BOTC.exe`: double-click this. If the server is offline, it starts it. If the
  server is already online, it opens the console only.
- `Start.bat`: compatibility wrapper for `BOTC.exe`.
- `Console.bat`: compatibility wrapper for `BOTC.exe`.
- `launcher/`: internal launcher source and config. You normally do not open this.
- `launcher/exe/BotcLauncher.cs`: source code used to build the standalone
  `BOTC.exe`.
- `launcher/compose.yml`: tells Docker what Minecraft server to create.
- `launcher/branding.txt`: editable server name, MOTD, and resource-pack prompt.
- `../data/server-icon.png`: the normal Minecraft server icon. The launcher
  also uses this file as the EXE icon source when rebuilt.
- `Jays-Patch`: Jay's server-side add-on. Custom BOTC behavior goes here.
- `launcher/local-settings.example.properties`: example settings file.
- `launcher/local-settings.properties`: your private settings file. You create this yourself.

## What You Need To Install

### Docker Desktop

Docker Desktop is the app that runs the Minecraft server in a container.

A container is just a boxed-off app. It lets this server run without you manually
installing Java, Fabric, and every server file yourself.

Install Docker Desktop:

1. Go to `https://www.docker.com/products/docker-desktop/`.
2. Download Docker Desktop for Windows.
3. Install it.
4. Open Docker Desktop once.
5. Wait until it says Docker is running.

After that first setup, `BOTC.exe` can open Docker Desktop for you if it is
installed but not running yet.

### playit.gg

playit.gg lets people outside your house join your server.

Without playit.gg, the server may only work for people on your own network.

Install playit.gg:

1. Go to `https://playit.gg/`.
2. Make an account.
3. Install the Windows app.
4. Follow playit.gg setup until your agent is connected.

You need two playit tunnels:

- Minecraft Java tunnel
  - local address: `127.0.0.1`
  - local port: `25565`
  - protocol: TCP
- Simple Voice Chat tunnel
  - local address: `127.0.0.1`
  - local port: `24454`
  - protocol: UDP

playit.gg will give you public addresses. The Simple Voice Chat address is the
one you put in `BOTC_VOICE_HOST`.

## First Setup

1. Open this folder.
2. Open the `launcher` folder.
3. Make a copy of `local-settings.example.properties`.
4. Rename the copy to `local-settings.properties`.
5. Open `local-settings.properties` in Notepad.
6. Fill in your settings.
7. Save the file.
8. Go back to the main folder.
9. Double-click `BOTC.exe`.

## Local Settings

Your `launcher/local-settings.properties` file should look like this:

```properties
BOTC_MANAGE_DOCKER=true
BOTC_DOCKER_START_TIMEOUT_SECONDS=180
BOTC_DOCKER_DESKTOP_EXE=
BOTC_MANAGE_PLAYIT=true
BOTC_PLAYIT_SERVICE=playitd
BOTC_VOICE_HOST=your-playit-voice-address-here
BOTC_VOICE_PORT=24454
BOTC_VOICE_BIND_ADDRESS=*
```

Use `BOTC_MANAGE_DOCKER=true` if you want `BOTC.exe` to open Docker Desktop
when Docker is installed but not running yet.

Leave `BOTC_DOCKER_DESKTOP_EXE` blank unless Docker Desktop is installed in an
unusual folder.

Use `BOTC_MANAGE_PLAYIT=true` if you installed playit.gg on Windows and want the
server launcher to start and stop it for you.

Use `BOTC_MANAGE_PLAYIT=false` if you do not use playit.gg, or if you want to
open playit.gg yourself.

`BOTC_VOICE_HOST` must be the public address for the playit.gg Simple Voice Chat
tunnel. It should look like a host and port, for example:

```properties
BOTC_VOICE_HOST=example.playit.gg:12345
```

Do not use someone else's value here. Everyone has their own playit address.

## Brand And Logo

Edit `launcher/branding.txt` in Notepad to change the visible server name,
server-list MOTD, and resource-pack prompt.

Edit `../data/server-icon.png` to change the logo. This is Minecraft's normal
server icon file. Use a square PNG, preferably 64x64.

If `../data/server-icon.png` is missing, Minecraft uses its default server icon.
If you rebuild `BOTC.exe` while that file is missing, Windows uses the default
application icon.

After changing the text or logo, restart the server for Minecraft clients to see
the updated server-list branding. Rebuild `BOTC.exe` only when you also want the
Windows EXE icon to update.

## Starting The Server

Double-click:

```text
BOTC.exe
```

A styled console window opens. That is the server console.

The console is the control window for the server. You can type server commands
there.

If the server is offline, the launcher will:

1. Deploy `Jays-Patch` into the server runtime folder.
2. Open Docker Desktop if Docker is installed but not running.
3. Start the Docker Minecraft server.
4. Start playit.gg if enabled.
5. Wait until Minecraft is ready.
6. Sync `Jays-Patch` again, then reload required commands and regions.
7. Show the `BOTC >` command prompt.

If the server is already online, `BOTC.exe` skips startup and opens the console
without restarting or updating the server.

The normal backup point is now when you stop the server. Type:

```text
stop
```

The launcher asks whether to create/update `backups/standard` before stopping.
If you answer `Y`, Minecraft saves are flushed, `backups/standard` is replaced
atomically after the new backup is complete, and then the server stops. If you
answer `N`, the server stops without changing backups.

After Minecraft stops, the launcher also stops helper services that it recorded
starting itself. That means it stops the playit.gg service only if BOTC started
it, and it closes Docker Desktop only if BOTC opened it and no other Docker
containers are still running.

When you see this, the server is ready:

```text
BOTC >
```

## Console Commands

Type commands without the `/`.
Type `help` to see the console-only commands.

Examples:

```text
op YourMinecraftName
say Hello everyone
reload
```

Special launcher commands:

- `help`: show help.
- `cls`: clear the window.
- `botc help`: show Jay's Patch BOTC commands in Minecraft.
- `exit`: close the console window but leave the Minecraft server running.
- `stop`: ask whether to update `backups/standard`, stop the Minecraft server,
  stop launcher-started helper services, then close the console window.

## Resetting The Game

Use the normal Storyteller reset flow through `/botc reset_game` or the
Storyteller menu.

Jay's Patch does this in-place:

1. Run Sybillian's normal game reset behavior.
2. Clear Jay's Patch grimoire reveal visuals.
3. Return every online user to normal player state.
4. Keep the server running so another player can become Storyteller next.

`Jays-Patch/world-template` is still the clean world template for sharing the
patch or for manual recovery if the live world gets damaged. Normal game resets
do not restore that template, stop the server, or restart Docker.

## License

Jay-owned source code in this project is licensed under the MIT License.

Jay-owned handmade resource-pack art is licensed under CC BY 4.0.

The included world template is a modified version of Sybillian's Blood on the
Clocktower world. Jay's Patch does not claim ownership of Sybillian's original
world, datapack, resource-pack assets, role icons, menus, or modpack content.
The world template is included so the server package works, but it is not
licensed as a separate Jay-owned reusable asset.

The Jay's Patch name, logo, and branding are reserved by Jay. Forks and
modified versions should not present themselves as the official Jay's Patch.

See `LICENSE`, `ASSET_LICENSE.md`, `NOTICE.md`, and `BRANDING.md` for the
package-facing license and credit details.

## Giving Yourself Admin

After the server starts, type this in the console:

```text
op YourMinecraftName
```

Replace `YourMinecraftName` with your real Minecraft name.

This gives you server admin powers.

## Stopping The Server

Type this in the console:

```text
stop
```

Do not just close Docker Desktop while the server is running. Use `stop` first
so Minecraft can save properly.

## What Not To Share

Do not share these files or folders from a live server. The live server data
folder is `../data` from this folder.

- `launcher/local-settings.properties`
- `backups`
- `../data/logs`
- `../data/world`
- `../data/ops.json`
- `../data/usercache.json`
- `../data/server.properties`
- `../data/.rcon-cli.env`
- `../data/.rcon-cli.yaml`
- files ending in `.bak-*`
- private planning notes

These can contain private IP addresses, player names, player UUIDs, chat logs,
server passwords, OP lists, or world data.

## If Something Does Not Work

If `BOTC.exe` closes instantly:

1. Read the error shown in the launcher window.
2. If it says Docker Desktop was not found, install Docker Desktop or fill in
   `BOTC_DOCKER_DESKTOP_EXE`.
3. If it says Docker did not become ready in time, wait until Docker Desktop is
   fully started, then double-click `BOTC.exe` again.

If stopping says the standard backup could not read a locked file:

1. Close any editor, sync app, or tool that may be using the named file.
2. Try `stop` again.

The server is not stopped when the approved backup fails, so you can fix the
named issue and try again.

If friends can join Minecraft but voice chat does not work:

1. Check your playit.gg Simple Voice Chat tunnel.
2. Make sure it points to local UDP port `24454`.
3. Copy that tunnel's public address into `BOTC_VOICE_HOST`.
4. Save `launcher/local-settings.properties`.
5. Type `stop` in the server console.
6. Start the server again.

If you are not admin:

1. Open the server console.
2. Type `op YourMinecraftName`.
3. Press Enter.
