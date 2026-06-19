# BOTC Minecraft Server

This folder starts a Blood on the Clocktower Minecraft server.

You do not need to code to use this. You mostly need to install Docker, edit one
small settings file, and double-click `Start.bat`.

## What The Files Are

- `Start.bat`: double-click this to start the server window.
- `startup-script.ps1`: the helper script used by `Start.bat`. Do not double-click this directly.
- `compose.yml`: tells Docker what Minecraft server to create.
- `local-settings.example.properties`: example settings file.
- `local-settings.properties`: your private settings file. You create this yourself.

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

If Docker Desktop is closed, the Minecraft server will not start.

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
2. Make a copy of `local-settings.example.properties`.
3. Rename the copy to `local-settings.properties`.
4. Open `local-settings.properties` in Notepad.
5. Fill in your settings.
6. Save the file.
7. Double-click `Start.bat`.

## Local Settings

Your `local-settings.properties` file should look like this:

```properties
BOTC_MANAGE_PLAYIT=true
BOTC_PLAYIT_SERVICE=playitd
BOTC_VOICE_HOST=your-playit-voice-address-here
BOTC_VOICE_PORT=24454
BOTC_VOICE_BIND_ADDRESS=*
```

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

## Starting The Server

Double-click:

```text
Start.bat
```

A black window opens. That is the server console.

The console is the control window for the server. You can type server commands
there.

The launcher will:

1. Create or update the pre-start backups in `backups`.
2. Start the Docker Minecraft server.
3. Start playit.gg if enabled.
4. Wait until Minecraft is ready.
5. Show a Minecraft command prompt.

The pre-start backup happens before Docker checks or downloads modpack files.
It includes the world, the custom BOTC files, and a Git restore bundle.
If that backup fails, startup stops before Docker can check for updates.

There are two backup slots:

- `backups/latest`: overwritten every time `Start.bat` starts.
- `backups/standard`: kept unchanged until you approve replacing it.

After you test that the current server state is good, type this in the launcher
console to make `latest` become the new `standard`:

```text
promote-backup
```

The launcher will ask you to type `YES` before it replaces `standard`.

When you see this, the server is ready:

```text
Minecraft command >
```

## Console Commands

Type commands without the `/`.

Examples:

```text
op YourMinecraftName
say Hello everyone
reload
```

Special launcher commands:

- `help`: show help.
- `cls`: clear the window.
- `promote-backup`: ask before replacing the standard backup with the latest backup.
- `exit`: close the console window but leave the Minecraft server running.
- `stop`: stop the Minecraft server and close playit.gg if the launcher manages it.

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

Do not share these files or folders from a live server:

- `local-settings.properties`
- `backups`
- `data/logs`
- `data/saves`
- `data/world`
- `data/ops.json`
- `data/usercache.json`
- `data/server.properties`
- `data/.rcon-cli.env`
- `data/.rcon-cli.yaml`
- files ending in `.bak-*`
- private planning notes

These can contain private IP addresses, player names, player UUIDs, chat logs,
server passwords, OP lists, or world data.

## If Something Does Not Work

If `Start.bat` closes instantly:

1. Open Docker Desktop.
2. Wait until Docker says it is running.
3. Double-click `Start.bat` again.

If friends can join Minecraft but voice chat does not work:

1. Check your playit.gg Simple Voice Chat tunnel.
2. Make sure it points to local UDP port `24454`.
3. Copy that tunnel's public address into `BOTC_VOICE_HOST`.
4. Save `local-settings.properties`.
5. Type `stop` in the server console.
6. Start the server again.

If you are not admin:

1. Open the server console.
2. Type `op YourMinecraftName`.
3. Press Enter.
