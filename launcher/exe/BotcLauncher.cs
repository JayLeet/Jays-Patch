using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Security.Cryptography;
using System.ServiceProcess;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;

internal static partial class BotcLauncher
{
    private static readonly object ConsoleLock = new object();
    private static readonly Dictionary<string, string> Settings = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    private static string RootDir;
    private static string LauncherDir;
    private static string ComposeFile;
    private static string ServerDataDir;
    private static string ServerIconFile;
    private static string BrandingFile;
    private static string ManagedServicesFile;
    private static BrandingConfig Branding = BrandingConfig.Default();
    private static string ContainerName = "botc-minecraft";
    private static string Buffer = "";
    private static bool Done;
    private static Process LogProcess;
    private static bool DashboardActive;
    private static int DashboardTop;
    private static int DashboardLines;
    private static int HeaderStatusTop = -1;
    private static int StartupLastPercent;
    private static string StartupLastStage = "";
    private static DateTime StartupStageStartedAt;
    private static readonly string[] DashboardPhaseOrder = { "CONFIG", "VOICE", "PATCH", "DOCKER", "PLAYIT", "MINECRAFT", "SYNC" };
    private static readonly Dictionary<string, string> DashboardPhaseStates = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    private static string DashboardActivePhase = "";
    private static string DashboardActiveDetail = "";
    private static readonly string[] ProtectedServerConfigFiles = new[]
    {
        Path.Combine("tab", "config.yml"),
        Path.Combine("tab", "groups.yml"),
        Path.Combine("tab", "animations.yml"),
        Path.Combine("tab", "messages.yml"),
        Path.Combine("tab", "users.yml"),
        "yawp-common.toml"
    };

    private static int Main(string[] args)
    {
        Console.OutputEncoding = new UTF8Encoding(false);
        Console.InputEncoding = new UTF8Encoding(false);

        RootDir = AppDomain.CurrentDomain.BaseDirectory.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
        LauncherDir = Path.Combine(RootDir, "launcher");
        ComposeFile = Path.Combine(LauncherDir, "compose.yml");
        ServerDataDir = Path.GetFullPath(Path.Combine(RootDir, "..", "data"));
        ServerIconFile = Path.Combine(ServerDataDir, "server-icon.png");
        BrandingFile = Path.Combine(LauncherDir, "branding.txt");
        ManagedServicesFile = Path.Combine(LauncherDir, ".botc-managed-services.state");
        Branding = BrandingConfig.Load(BrandingFile);

        LoadDefaultSettings();

        try
        {
            if (IsDockerContainerRunning(ContainerName))
            {
                return RunConsoleOnly();
            }

            return RunStartup();
        }
        catch (Exception ex)
        {
            WriteErrorBlock(Branding.ShortName + " launcher failed", ex.Message, new[] { "Fix the named issue, then open BOTC.exe again." });
            PauseOnError();
            return 1;
        }
    }

    private static int RunStartup()
    {
        WriteHeader("Starting");
        StartDashboard();

        try
        {
            Step("CONFIG", "Reading local launcher settings");
            ReadLocalSettings();

            Step("VOICE", "Checking voice chat server settings");
            EnsureVoiceChatConfig();
            Success("Voice chat settings are ready");

            DeployJaysPatch();

            EnsureDockerReady();

            Step("DOCKER", "Starting Minecraft server");
            CommandResult up = Run("docker", "compose --project-directory " + Quote(RootDir) + " -f " + Quote(ComposeFile) + " up -d", true);
            CommandOutput("DOCKER", up.OutputLines);
            if (up.ExitCode != 0)
            {
                throw new Exception("Docker compose startup failed with exit code " + up.ExitCode + ".");
            }

            EnsurePlayit();
            WaitForMinecraftReady();
            PostStartupSync();
        }
        catch (Exception ex)
        {
            string shortError = OneLine(ex.Message);
            if (shortError.Length > 58)
            {
                shortError = shortError.Substring(0, 55) + "...";
            }
            WriteHeaderStatus("ERROR: " + shortError, true);
            StopDashboard();
            WriteErrorBlock(
                "Startup stopped before the server was ready",
                ex.Message,
                new[]
                {
                    "Docker update/startup was not allowed to continue after this failure.",
                    "Fix the named issue, then open BOTC.exe again."
                });
            PauseOnError();
            return 1;
        }

        StopDashboard();

        if (!IsInteractiveConsole())
        {
            Header("Online");
            Console.WriteLine("Open BOTC.exe by double-clicking it to use the interactive command console.");
            return 0;
        }

        return RunInteractiveConsole("Online");
    }

    private static int RunConsoleOnly()
    {
        ReadLocalSettings();

        if (!IsDockerContainerRunning(ContainerName))
        {
            Header("Offline");
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("The Minecraft server is not running. Open BOTC.exe to start it.");
            Console.ResetColor();
            PauseOnError();
            return 1;
        }

        if (!IsInteractiveConsole())
        {
            Header("Needs window");
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("Open BOTC.exe by double-clicking it so the console has a real keyboard input window.");
            Console.ResetColor();
            PauseOnError();
            return 1;
        }

        return RunInteractiveConsole("Online");
    }

    private static int RunInteractiveConsole(string status)
    {
        Buffer = "";
        Done = false;
        StartLogProcess();

        try
        {
            Header(status);
            WritePrompt();

            while (!Done)
            {
                while (Console.KeyAvailable)
                {
                    ConsoleKeyInfo key = Console.ReadKey(true);
                    HandleKey(key);
                }

                Thread.Sleep(100);
            }
        }
        finally
        {
            StopLogProcess();
        }

        return 0;
    }

    private static void HandleKey(ConsoleKeyInfo key)
    {
        if (key.Key == ConsoleKey.Enter)
        {
            Console.WriteLine();
            string command = Buffer.Trim();
            Buffer = "";

            if (command.Length == 0)
            {
                WritePrompt();
                return;
            }

            if (EqualsIgnoreCase(command, "help"))
            {
                HelpMenu();
                WritePrompt();
                return;
            }

            if (EqualsIgnoreCase(command, "cls") || EqualsIgnoreCase(command, "clear"))
            {
                Header(IsDockerContainerRunning(ContainerName) ? "Online" : "Offline");
                WritePrompt();
                return;
            }

            if (EqualsIgnoreCase(command, "exit"))
            {
                Console.WriteLine("Closing console. The server is still running.");
                Done = true;
                return;
            }

            if (EqualsIgnoreCase(command, "stop"))
            {
                try
                {
                    if (ConfirmBackupBeforeStop())
                    {
                        StopManagedServer();
                        Done = true;
                    }
                    else
                    {
                        WritePrompt();
                    }
                }
                catch (Exception ex)
                {
                    Warning(ex.Message);
                    WritePrompt();
                }
                return;
            }

            CommandResult result = Run("docker", "exec -i " + ContainerName + " rcon-cli " + Quote(command), true);
            WriteRawOutput(result.OutputLines);
            WritePrompt();
            return;
        }

        if (key.Key == ConsoleKey.Backspace)
        {
            if (Buffer.Length > 0)
            {
                Buffer = Buffer.Substring(0, Buffer.Length - 1);
                Console.Write("\b \b");
            }
            return;
        }

        if (key.Key == ConsoleKey.Escape)
        {
            ClearLine();
            Buffer = "";
            WritePrompt();
            return;
        }

        if (!char.IsControl(key.KeyChar))
        {
            Buffer += key.KeyChar;
            Console.Write(key.KeyChar);
        }
    }

    private static bool ConfirmBackupBeforeStop()
    {
        Console.WriteLine();
        Notice("Create/update the standard backup before stopping? This replaces backups\\standard after the new backup is complete.");
        Console.Write("Type Y to back up and stop, N to stop without backup, or anything else to cancel: ");
        string answer = (Console.ReadLine() ?? "").Trim();

        if (EqualsIgnoreCase(answer, "Y") || EqualsIgnoreCase(answer, "YES"))
        {
            BackupStandardBeforeStop();
            return true;
        }

        if (EqualsIgnoreCase(answer, "N") || EqualsIgnoreCase(answer, "NO"))
        {
            Detail("Skipping backup before stop");
            return true;
        }

        Console.WriteLine("Stop cancelled. The server is still running.");
        return false;
    }

    private static void BackupStandardBeforeStop()
    {
        bool saveWasDisabled = false;
        Step("BACKUP", "Creating standard backup before stopping");

        try
        {
            if (IsDockerContainerRunning(ContainerName))
            {
                Detail("Flushing world saves before standard backup");
                CommandResult saveOff = Rcon("save-off");
                if (saveOff.ExitCode != 0)
                {
                    throw new Exception("Server is running, but RCON save-off failed.");
                }
                saveWasDisabled = true;

                CommandResult saveAll = Rcon("save-all flush");
                if (saveAll.ExitCode != 0)
                {
                    throw new Exception("Server is running, but RCON save-all flush failed.");
                }
            }

            BackupResult standard = WriteBackupSlot("standard", "manual standard backup approved before server stop");
            ShowBackupSlot("Standard", standard);
        }
        catch (Exception ex)
        {
            throw new Exception("Stop-time backup failed. Server was not stopped. " + ex.Message, ex);
        }
        finally
        {
            if (saveWasDisabled)
            {
                Rcon("save-on");
            }
        }
    }

    private static BackupResult WriteBackupSlot(string slotName, string reason)
    {
        string backupRoot = Path.Combine(RootDir, "backups");
        Directory.CreateDirectory(backupRoot);

        string slotPath = BackupSlotPath(slotName);
        string staging = Path.Combine(backupRoot, slotName + "-staging");
        string worldPath = Path.Combine(ServerDataDir, "world");
        string stagingWorld = Path.Combine(staging, "world");
        string worldZip = Path.Combine(staging, "BOTC-world.zip");
        string customZip = Path.Combine(staging, "BOTC-custom-files.zip");
        string bundle = Path.Combine(staging, "BOTC-customizations.gitbundle");
        string manifest = Path.Combine(staging, "BOTC-backup.json");
        List<string> created = new List<string>();

        RemoveDirectoryInsideBackups(staging);
        Directory.CreateDirectory(staging);

        try
        {
            if (Directory.Exists(worldPath))
            {
                Directory.CreateDirectory(stagingWorld);
                foreach (FileSystemInfo child in new DirectoryInfo(worldPath).GetFileSystemInfos())
                {
                    if (EqualsIgnoreCase(child.Name, "session.lock"))
                    {
                        continue;
                    }

                    string destination = Path.Combine(stagingWorld, child.Name);
                    if ((child.Attributes & FileAttributes.Directory) == FileAttributes.Directory)
                    {
                        CopyDirectory(child.FullName, destination);
                    }
                    else
                    {
                        CopyFileWithRetry(child.FullName, destination);
                    }
                }

                ZipPaths(new[] { stagingWorld }, worldZip);
                Directory.Delete(stagingWorld, true);
                created.Add("BOTC-world.zip");
            }

            List<string> customPaths = GetCustomBackupPaths();
            if (customPaths.Count > 0)
            {
                ZipPaths(customPaths.ToArray(), customZip);
                created.Add("BOTC-custom-files.zip");
            }

            if (Directory.Exists(Path.Combine(RootDir, ".git")))
            {
                CommandResult git = Run("git", "bundle create " + Quote(bundle) + " --all", true);
                if (git.ExitCode == 0 && File.Exists(bundle))
                {
                    created.Add("BOTC-customizations.gitbundle");
                }
                else
                {
                    Notice("Git backup bundle could not be created. The custom file zip was still created.");
                }
            }

            File.WriteAllText(manifest, BuildManifest(slotName, reason, created), Encoding.ASCII);
            created.Add("BOTC-backup.json");

            RemoveDirectoryInsideBackups(slotPath);
            Directory.Move(staging, slotPath);

            return new BackupResult(slotPath, created);
        }
        catch
        {
            RemoveDirectoryInsideBackups(staging);
            throw;
        }
    }

    private static void ShowBackupSlot(string label, BackupResult backup)
    {
        Success(label + " backup created: " + backup.Path);
        foreach (string file in backup.Files)
        {
            string path = Path.Combine(backup.Path, file);
            if (File.Exists(path))
            {
                double mb = Math.Round(new FileInfo(path).Length / 1024.0 / 1024.0, 2);
                Detail(file + " (" + mb + " MB)");
            }
        }
    }

    private static void DeployJaysPatch(string dashboardPhase = "PATCH", bool markDone = true)
    {
        string phase = NormalizeDeployPhase(dashboardPhase);
        string deployText = phase == "SYNC"
            ? "Synchronizing custom patch source after Minecraft startup"
            : "Deploying custom patch source to the server folder";
        Step(phase, deployText);

        string patchRoot = Path.Combine(RootDir, "Jays-Patch");
        string datapackSource = Path.Combine(patchRoot, "datapack");
        string commandsSource = Path.Combine(patchRoot, "melius-commands", "commands");
        string resourcepackSource = Path.Combine(patchRoot, "resourcepack");
        string fancymenuSource = Path.Combine(patchRoot, "fancymenu", "customization");
        string serverConfigSource = Path.Combine(patchRoot, "server-config");

        if (!Directory.Exists(datapackSource))
        {
            throw new Exception("Custom patch datapack source is missing: " + datapackSource);
        }
        if (!Directory.Exists(commandsSource))
        {
            throw new Exception("Custom patch command source is missing: " + commandsSource);
        }

        string datapackDest = Path.Combine(ServerDataDir, "world", "datapacks", "jays_patch");
        string oldDatapackDest = Path.Combine(ServerDataDir, "resources", "datapack", "required", "Jays-Patch");
        string oldLowerDatapackDest = Path.Combine(ServerDataDir, "resources", "datapack", "required", "jays_patch");
        string commandsDest = Path.Combine(ServerDataDir, "config", "melius-commands", "commands");
        string resourcepackDest = Path.Combine(ServerDataDir, "resources", "resourcepack", "required", "Jays-Patch");
        string fancymenuDest = Path.Combine(ServerDataDir, "config", "fancymenu", "customization");
        string serverConfigDest = Path.Combine(ServerDataDir, "config");

        RemovePathInsideData(oldDatapackDest);
        RemovePathInsideData(oldLowerDatapackDest);
        RemovePathInsideData(datapackDest);
        CopyDirectory(datapackSource, datapackDest);

        Directory.CreateDirectory(commandsDest);
        HashSet<string> sourceCommandNames = new HashSet<string>(Directory.GetFiles(commandsSource, "*.json").Select(Path.GetFileName), StringComparer.OrdinalIgnoreCase);
        foreach (string existing in Directory.GetFiles(commandsDest, "*.json"))
        {
            if (!sourceCommandNames.Contains(Path.GetFileName(existing)))
            {
                Detail("Removed stale command overlay: " + Path.GetFileName(existing));
                File.Delete(existing);
            }
        }
        foreach (string source in Directory.GetFiles(commandsSource, "*.json"))
        {
            File.Copy(source, Path.Combine(commandsDest, Path.GetFileName(source)), true);
        }

        if (Directory.Exists(resourcepackSource))
        {
            RemovePathInsideData(resourcepackDest);
            CopyDirectory(resourcepackSource, resourcepackDest);
            BuildJaysPatchResourcePack(resourcepackSource, phase);
        }

        if (Directory.Exists(fancymenuSource))
        {
            Directory.CreateDirectory(fancymenuDest);
            foreach (string menuFile in Directory.GetFiles(fancymenuSource, "*.txt"))
            {
                File.Copy(menuFile, Path.Combine(fancymenuDest, Path.GetFileName(menuFile)), true);
            }
        }

        if (Directory.Exists(serverConfigSource))
        {
            DeployProtectedServerConfigFiles(serverConfigSource, serverConfigDest);
        }

        DeployServerBranding();
        if (markDone)
        {
            Success(phase, "Custom patch deployed");
        }
        else
        {
            Detail("Custom patch source synchronized");
        }
    }

    private static string NormalizeDeployPhase(string dashboardPhase)
    {
        string phase = NormalizeDashboardPhase(dashboardPhase);
        return string.IsNullOrWhiteSpace(phase) ? "PATCH" : phase;
    }

    private static void DeployServerBranding()
    {
        Dictionary<string, string> values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        values["motd"] = Branding.Motd();
        values["function-permission-level"] = "3";
        values["spawn-protection"] = "0";
        SetPropertiesFileValues(Path.Combine(ServerDataDir, "server.properties"), values);

        if (!File.Exists(ServerIconFile))
        {
            Notice("No ../data/server-icon.png found; Minecraft will use its default server icon");
        }
    }

    private static void BuildJaysPatchResourcePack(string resourcepackSource, string dashboardPhase)
    {
        string distDir = Path.Combine(RootDir, "Jays-Patch", "dist");
        string zipPath = Path.Combine(distDir, "Jays-Patch-resourcepack.zip");
        string stagingDir = Path.Combine(distDir, "resourcepack-staging");
        Directory.CreateDirectory(distDir);

        if (File.Exists(zipPath))
        {
            File.Delete(zipPath);
        }
        if (Directory.Exists(stagingDir))
        {
            Directory.Delete(stagingDir, true);
        }

        CopyDirectory(resourcepackSource, stagingDir);

        string sybillianRoleTextures = Path.Combine(ServerDataDir, "resources", "resourcepack", "required", "Blood on the Clocktower", "assets", "ct", "textures", "role");
        if (Directory.Exists(sybillianRoleTextures))
        {
            string stagedRoleTextures = Path.Combine(stagingDir, "assets", "ct", "textures", "item", "role");
            Directory.CreateDirectory(stagedRoleTextures);
            foreach (string png in Directory.GetFiles(sybillianRoleTextures, "*.png"))
            {
                File.Copy(png, Path.Combine(stagedRoleTextures, Path.GetFileName(png)), true);
            }
        }
        else
        {
            Warning("Sybillian role textures were not found; role reveal icons may render as missing textures");
        }

        ZipDirectoryContents(stagingDir, zipPath);
        Directory.Delete(stagingDir, true);

        string sha1 = FileSha1(zipPath).ToLowerInvariant();
        Detail("Custom resource pack built: " + zipPath);

        string resourcePackUrl = GetSetting("BOTC_RESOURCE_PACK_URL", "");
        if (string.IsNullOrWhiteSpace(resourcePackUrl))
        {
            Warning("Resource-pack URL not configured; players need the custom resource pack installed locally to see role icons");
            return;
        }

        string serverResourcePackSha1 = sha1;
        Match urlSha = Regex.Match(resourcePackUrl, @"/pack/([0-9a-fA-F]{40})\.zip");
        if (urlSha.Success)
        {
            serverResourcePackSha1 = urlSha.Groups[1].Value.ToLowerInvariant();
            if (serverResourcePackSha1 != sha1)
            {
                Warning("Local custom resource pack zip SHA differs from the hosted MCPacks URL SHA");
                Detail("Local zip SHA1: " + sha1);
                Detail("Hosted URL SHA1: " + serverResourcePackSha1);
                Detail("Using the hosted URL SHA1 in server.properties because clients download that zip");
            }
        }

        string prompt = Branding.ResourcePackPrompt();
        Dictionary<string, string> values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        values["resource-pack"] = resourcePackUrl;
        values["resource-pack-sha1"] = serverResourcePackSha1;
        values["resource-pack-id"] = "67f91471-3342-49d4-9d1d-7e1d040ab095";
        values["require-resource-pack"] = "false";
        values["resource-pack-prompt"] = prompt;
        SetPropertiesFileValues(Path.Combine(ServerDataDir, "server.properties"), values);
        Detail("Custom resource pack URL configured for clients");
    }

    private static void EnsureVoiceChatConfig()
    {
        Dictionary<string, string> values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        values["port"] = GetSetting("BOTC_VOICE_PORT", "24454");
        values["bind_address"] = GetSetting("BOTC_VOICE_BIND_ADDRESS", "*");
        values["voice_host"] = GetSetting("BOTC_VOICE_HOST", "");

        SetPropertiesFileValues(Path.Combine(ServerDataDir, "config", "voicechat", "voicechat-server.properties"), values);
        SetPropertiesFileValues(Path.Combine(ServerDataDir, "server", "config", "voicechat", "voicechat-server.properties"), values);
    }

    private static void EnsurePlayit()
    {
        if (!SettingEnabled("BOTC_MANAGE_PLAYIT", "true"))
        {
            SetDashboardPhase("PLAYIT", "Skipped", "");
            return;
        }

        string serviceName = GetSetting("BOTC_PLAYIT_SERVICE", "playitd");
        Step("PLAYIT", "Checking Playit tunnel");
        ServiceController service;
        try
        {
            service = new ServiceController(serviceName);
            ServiceControllerStatus status = service.Status;
            if (status == ServiceControllerStatus.Running)
            {
                SetManagedServiceFlag("playit", false);
                Success("Playit tunnel is running");
                return;
            }
        }
        catch
        {
            Warning("Playit service '" + serviceName + "' was not found");
            Detail("Install or open Playit manually before players connect from outside your network");
            return;
        }

        Step("PLAYIT", "Starting Playit tunnel");
        try
        {
            service.Start();
            service.WaitForStatus(ServiceControllerStatus.Running, TimeSpan.FromSeconds(15));
            SetManagedServiceFlag("playit", true);
            Success("Playit tunnel is running");
        }
        catch (Exception ex)
        {
            Warning("Could not start Playit automatically");
            Detail("Open Playit manually, or run this window as administrator if Windows blocks service startup");
            Detail(ex.Message);
        }
    }

    private static void EnsureDockerReady()
    {
        Step("DOCKER", "Checking Docker Desktop");

        if (DockerEngineReady())
        {
            SetManagedServiceFlag("dockerDesktop", false);
            Detail("Docker engine is ready");
            return;
        }

        if (!SettingEnabled("BOTC_MANAGE_DOCKER", "true"))
        {
            throw new Exception("Docker is not running. Start Docker Desktop manually, or set BOTC_MANAGE_DOCKER=true.");
        }

        string dockerDesktop = FindDockerDesktopExe();
        if (string.IsNullOrWhiteSpace(dockerDesktop))
        {
            CommandResult version;
            bool dockerCommandExists = TryRun("docker", "--version", true, out version);
            string extra = dockerCommandExists
                ? "The docker command exists, but the Docker Desktop app was not found in the standard install paths."
                : "The docker command was not found either.";
            throw new Exception("Docker is not running and Docker Desktop could not be started automatically. " + extra + " Install Docker Desktop or open it manually.");
        }

        Detail("Docker is not running; opening Docker Desktop");
        StartDockerDesktop(dockerDesktop);

        int timeoutSeconds = GetIntSetting("BOTC_DOCKER_START_TIMEOUT_SECONDS", 180, 30, 600);
        DateTime deadline = DateTime.Now.AddSeconds(timeoutSeconds);
        while (DateTime.Now < deadline)
        {
            if (DockerEngineReady())
            {
                SetManagedServiceFlag("dockerDesktop", true);
                Detail("Docker engine is ready");
                return;
            }

            int remaining = Math.Max(0, (int)Math.Ceiling((deadline - DateTime.Now).TotalSeconds));
            Detail("Waiting for Docker Desktop to finish starting (" + remaining + "s)");
            Thread.Sleep(2000);
        }

        throw new Exception("Docker Desktop was opened, but Docker was not ready within " + timeoutSeconds + " seconds. Wait for Docker Desktop to finish starting, then open BOTC.exe again.");
    }

    private static bool DockerEngineReady()
    {
        CommandResult result;
        if (!TryRun("docker", "info", true, out result))
        {
            return false;
        }

        return result.ExitCode == 0;
    }

    private static string FindDockerDesktopExe()
    {
        string configured = GetSetting("BOTC_DOCKER_DESKTOP_EXE", "");
        if (!string.IsNullOrWhiteSpace(configured) && File.Exists(configured))
        {
            return configured;
        }

        string programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
        string programFilesX86 = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
        string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        string[] candidates =
        {
            Path.Combine(programFiles, "Docker", "Docker", "Docker Desktop.exe"),
            Path.Combine(programFilesX86, "Docker", "Docker", "Docker Desktop.exe"),
            Path.Combine(localAppData, "Docker", "Docker Desktop.exe")
        };

        foreach (string candidate in candidates)
        {
            if (File.Exists(candidate))
            {
                return candidate;
            }
        }

        return "";
    }

    private static void StartDockerDesktop(string dockerDesktop)
    {
        ProcessStartInfo info = new ProcessStartInfo();
        info.FileName = dockerDesktop;
        info.WorkingDirectory = Path.GetDirectoryName(dockerDesktop);
        info.UseShellExecute = true;
        info.WindowStyle = ProcessWindowStyle.Minimized;
        Process.Start(info);
    }

    private static void StopPlayit()
    {
        if (!SettingEnabled("BOTC_MANAGE_PLAYIT", "true"))
        {
            return;
        }

        if (!GetManagedServiceFlag("playit"))
        {
            Detail("Playit tunnel was not started by BOTC; leaving it running");
            return;
        }

        string serviceName = GetSetting("BOTC_PLAYIT_SERVICE", "playitd");
        ServiceController service;
        try
        {
            service = new ServiceController(serviceName);
            if (service.Status != ServiceControllerStatus.Running)
            {
                SetManagedServiceFlag("playit", false);
                Detail("Playit tunnel is already stopped");
                return;
            }
        }
        catch
        {
            SetManagedServiceFlag("playit", false);
            Warning("Playit service '" + serviceName + "' was not found");
            return;
        }

        Step("PLAYIT", "Stopping Playit tunnel");
        try
        {
            service.Stop();
            service.WaitForStatus(ServiceControllerStatus.Stopped, TimeSpan.FromSeconds(15));
            SetManagedServiceFlag("playit", false);
            Success("Playit tunnel stopped");
        }
        catch (Exception ex)
        {
            Warning("Could not stop Playit automatically");
            Detail("Stop Playit manually, or run this window as administrator if Windows blocks service control");
            Detail(ex.Message);
        }
    }

    private static void StopDockerDesktopIfManaged()
    {
        if (!SettingEnabled("BOTC_MANAGE_DOCKER", "true"))
        {
            return;
        }

        if (!GetManagedServiceFlag("dockerDesktop"))
        {
            Detail("Docker Desktop was not started by BOTC; leaving it running");
            return;
        }

        if (AnyDockerContainersRunning())
        {
            Detail("Docker Desktop has other running containers; leaving it running");
            SetManagedServiceFlag("dockerDesktop", false);
            return;
        }

        Step("DOCKER", "Stopping Docker Desktop");
        CommandResult result;
        if (TryRun("docker", "desktop stop", true, out result) && result.ExitCode == 0)
        {
            SetManagedServiceFlag("dockerDesktop", false);
            Success("Docker Desktop stopped");
            return;
        }

        try
        {
            Process[] processes = Process.GetProcessesByName("Docker Desktop");
            if (processes.Length == 0)
            {
                SetManagedServiceFlag("dockerDesktop", false);
                Detail("Docker Desktop is already closed");
                return;
            }

            bool closeRequested = false;
            foreach (Process process in processes)
            {
                try
                {
                    closeRequested = process.CloseMainWindow() || closeRequested;
                }
                catch
                {
                }
            }

            if (!closeRequested)
            {
                Warning("Docker Desktop did not expose a closeable window");
                Detail("Close Docker Desktop manually if you want it fully stopped");
                return;
            }

            DateTime deadline = DateTime.Now.AddSeconds(15);
            while (DateTime.Now < deadline)
            {
                if (Process.GetProcessesByName("Docker Desktop").Length == 0)
                {
                    SetManagedServiceFlag("dockerDesktop", false);
                    Success("Docker Desktop stopped");
                    return;
                }

                Thread.Sleep(500);
            }

            Warning("Docker Desktop did not close within 15 seconds");
            Detail("Close Docker Desktop manually if you want it fully stopped");
        }
        catch (Exception ex)
        {
            Warning("Could not stop Docker Desktop automatically");
            Detail(ex.Message);
        }
    }

    private static bool AnyDockerContainersRunning()
    {
        CommandResult result;
        if (!TryRun("docker", "ps -q", true, out result))
        {
            return false;
        }

        return result.ExitCode == 0 && !string.IsNullOrWhiteSpace(result.Output);
    }

    private static void WaitForMinecraftReady()
    {
        DateTime start = DateTime.Now;
        DateTime deadline = start.AddMinutes(10);
        StartupLastPercent = 0;
        StartupLastStage = "";
        StartupStageStartedAt = start;
        bool observedStartup = false;

        while (true)
        {
            CommandResult inspectResult = Run("docker", "inspect -f \"{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{else}}no-health{{end}}\" " + ContainerName, true);
            string inspect = inspectResult.Output.Trim();

            if (string.IsNullOrWhiteSpace(inspect))
            {
                observedStartup = true;
                WriteStartupStatus(1, "waiting for Docker", start, "");
                Thread.Sleep(1000);
                continue;
            }

            string[] parts = inspect.Split('|');
            string state = parts.Length > 0 ? parts[0] : "unknown";
            string health = parts.Length > 1 ? parts[1] : "unknown";

            if (state == "exited" || state == "dead")
            {
                throw new Exception("Minecraft container stopped during startup. Check Docker logs for details.");
            }

            if (health == "healthy")
            {
                if (observedStartup)
                {
                    CompleteStartupStatus(start);
                }
                WriteStartupStatus(100, "ready", start, "Minecraft health check passed");
                SaveStartupDuration(start);
                return;
            }

            observedStartup = true;
            StartupProgress progress = GetStartupProgress(state, health, start);
            WriteStartupStatus(progress.Percent, progress.Stage, start, progress.Detail);

            if (DateTime.Now > deadline)
            {
                throw new Exception("Minecraft did not become healthy within 10 minutes. Last status: container=" + state + " health=" + health);
            }

            Thread.Sleep(1000);
        }
    }

    private static StartupProgress GetStartupProgress(string state, string health, DateTime start)
    {
        string[] lines = DockerLogsTail(180);
        string joined = string.Join("\n", lines);
        string detail = StartupLogSummary(lines);
        string stage = "waiting";
        int floor = 1;

        if (health == "starting")
        {
            stage = "starting";
            floor = 8;
        }
        if (Regex.IsMatch(joined, "Downloading modpack", RegexOptions.IgnoreCase))
        {
            stage = "downloading modpack";
            floor = 16;
        }
        if (Regex.IsMatch(joined, "Processing modpack files", RegexOptions.IgnoreCase))
        {
            stage = "processing modpack";
            floor = 34;
        }
        if (Regex.IsMatch(joined, "Starting minecraft server version", RegexOptions.IgnoreCase))
        {
            stage = "starting Minecraft";
            floor = 58;
        }
        if (Regex.IsMatch(joined, "Starting Minecraft server on", RegexOptions.IgnoreCase))
        {
            stage = "opening server port";
            floor = 70;
        }

        foreach (string line in lines.Reverse())
        {
            Match spawn = Regex.Match(line, @"(?i)(Preparing spawn area|Preparing start region|Preparing level).*?([0-9]{1,3})%");
            if (spawn.Success)
            {
                int value = Math.Max(0, Math.Min(100, int.Parse(spawn.Groups[2].Value)));
                floor = 78 + (int)Math.Floor(value * 0.20);
                stage = "preparing spawn";
                break;
            }
        }

        if (Regex.IsMatch(joined, @"Done \(", RegexOptions.IgnoreCase))
        {
            stage = "final checks";
            floor = 96;
        }
        if (health != "starting" && health != "healthy")
        {
            stage = "health " + health;
        }

        int ceiling = StageCeiling(stage, floor);
        int stagePercent = StageTimedPercent(stage, floor, ceiling);
        double expectedSeconds = GetExpectedStartupSeconds();
        double elapsedSeconds = Math.Max(0, (DateTime.Now - start).TotalSeconds);
        int timePercent = (int)Math.Floor((elapsedSeconds / expectedSeconds) * 96);
        if (elapsedSeconds > expectedSeconds)
        {
            timePercent = 96 + (int)Math.Floor((elapsedSeconds - expectedSeconds) / 15);
        }

        int percent = Math.Max(stagePercent, Math.Min(timePercent, ceiling));
        percent = Math.Max(1, Math.Min(99, percent));
        if (StartupLastPercent > 0 && percent < StartupLastPercent)
        {
            percent = StartupLastPercent;
        }
        if (StartupLastPercent > 0 && percent > StartupLastPercent + 7)
        {
            percent = StartupLastPercent + 7;
        }
        StartupLastPercent = percent;
        return new StartupProgress(percent, stage, detail);
    }

    private static int StageTimedPercent(string stage, int floor, int ceiling)
    {
        if (!EqualsIgnoreCase(stage, StartupLastStage))
        {
            StartupLastStage = stage;
            StartupStageStartedAt = DateTime.Now;
        }

        if (ceiling <= floor)
        {
            return floor;
        }

        double seconds = Math.Max(1.0, StageExpectedSeconds(stage));
        double elapsed = Math.Max(0, (DateTime.Now - StartupStageStartedAt).TotalSeconds);
        int extra = (int)Math.Floor((elapsed / seconds) * (ceiling - floor));
        return Math.Max(floor, Math.Min(ceiling, floor + extra));
    }

    private static int StageCeiling(string stage, int floor)
    {
        if (stage == "starting") return 15;
        if (stage == "downloading modpack") return 33;
        if (stage == "processing modpack") return 57;
        if (stage == "starting Minecraft") return 69;
        if (stage == "opening server port") return 77;
        if (stage == "preparing spawn") return 95;
        if (stage == "final checks") return 98;
        return Math.Max(floor, 95);
    }

    private static double StageExpectedSeconds(string stage)
    {
        if (stage == "starting") return 15;
        if (stage == "downloading modpack") return 45;
        if (stage == "processing modpack") return 90;
        if (stage == "starting Minecraft") return 45;
        if (stage == "opening server port") return 30;
        if (stage == "preparing spawn") return 60;
        if (stage == "final checks") return 15;
        return 90;
    }

    private static void CompleteStartupStatus(DateTime start)
    {
        int current = Math.Max(StartupLastPercent, 1);
        while (current < 99)
        {
            current = Math.Min(99, current + (current < 88 ? 4 : 1));
            StartupLastPercent = current;
            WriteStartupStatus(current, "final checks", start, "Minecraft health check passed");
            Thread.Sleep(current < 88 ? 120 : 90);
        }
    }

    private static void WriteStartupStatus(int percent, string stage, DateTime start, string detail)
    {
        string percentText = percent.ToString("00") + "%";
        string bar = ProgressBar(percent, 22);
        string progress = percentText + " [" + bar + "] " + stage + " " + FormatElapsed(start);

        if (DashboardActive)
        {
            SetDashboardPhase("MINECRAFT", percent >= 100 ? "Done" : "In progress", progress);
        }
        else
        {
            StatusLine("MINECRAFT", progress, ConsoleColor.Cyan, ConsoleColor.Gray);
        }
        WriteHeaderStatus(percent >= 100 ? "Online" : "Starting server...", true);
    }

    private static void PostStartupSync()
    {
        Step("SYNC", "Synchronizing custom patch after Minecraft startup");
        DeployJaysPatch("SYNC", false);

        string[] commands =
        {
            "reload",
            "function botc_patch:startup/yawp_init",
            "scoreboard players set yawp_startup_done botc_patch 1",
            "gamerule logAdminCommands true"
        };

        foreach (string command in commands)
        {
            Detail("Running " + command);
            CommandResult result = Rcon(command);
            if (result.ExitCode != 0)
            {
                throw new Exception("Post-startup RCON command failed: " + command);
            }
        }

        Success("SYNC", "Post-startup sync finished");
    }

    private static void StopManagedServer()
    {
        Step("DOCKER", "Stopping Minecraft server");
        CommandResult result = Run("docker", "compose --project-directory " + Quote(RootDir) + " -f " + Quote(ComposeFile) + " down", true);
        CommandOutput("DOCKER", result.OutputLines);
        if (result.ExitCode != 0)
        {
            throw new Exception("Docker could not stop the Minecraft server cleanly. Exit code: " + result.ExitCode);
        }

        Success("Server stopped");
        StopPlayit();
        StopDockerDesktopIfManaged();
    }

    private static void StartLogProcess()
    {
        ProcessStartInfo info = new ProcessStartInfo();
        info.FileName = "docker";
        info.Arguments = "logs --follow --tail 0 " + ContainerName;
        info.UseShellExecute = false;
        info.RedirectStandardOutput = true;
        info.RedirectStandardError = true;
        info.CreateNoWindow = true;

        LogProcess = new Process();
        LogProcess.StartInfo = info;
        LogProcess.OutputDataReceived += delegate(object sender, DataReceivedEventArgs args) { HandleLogLine(args.Data); };
        LogProcess.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs args) { HandleLogLine(args.Data); };
        LogProcess.Start();
        LogProcess.BeginOutputReadLine();
        LogProcess.BeginErrorReadLine();
    }

    private static void StopLogProcess()
    {
        if (LogProcess == null)
        {
            return;
        }

        try
        {
            if (!LogProcess.HasExited)
            {
                LogProcess.Kill();
            }
        }
        catch
        {
        }
        finally
        {
            LogProcess.Dispose();
            LogProcess = null;
        }
    }

    private static void HandleLogLine(string line)
    {
        string filtered = FilterLogLine(line);
        if (string.IsNullOrWhiteSpace(filtered))
        {
            return;
        }

        lock (ConsoleLock)
        {
            ClearLine();
            WriteLogLine(filtered);
            WritePrompt();
        }
    }

    private static string FilterLogLine(string line)
    {
        if (line == null)
        {
            return null;
        }

        bool isChat = Regex.IsMatch(line, @"<[^>]{1,32}>\s+.+") ||
                      line.Contains("[CHAT]") ||
                      Regex.IsMatch(line, @"\[Not Secure\].*<[^>]+>") ||
                      Regex.IsMatch(line, @"(?i)\[(?:SocialSpy|Spy)\]") ||
                      Regex.IsMatch(line, @"\[[^\]]+\s+(?:->|â†’)\s+[^\]]+\]\s+.+");

        bool isCommand = Regex.IsMatch(line, @"(?i)\b(?:issued|ran|executed)\s+(?:server\s+)?command\b") ||
                         Regex.IsMatch(line, @"(?i)\[[^\]]+:\s+Running\s+(?:function|command)\s+.+\]");

        if (!isChat && !isCommand)
        {
            return null;
        }

        return line;
    }

    private static void LoadDefaultSettings()
    {
        Settings["BOTC_MANAGE_PLAYIT"] = "true";
        Settings["BOTC_PLAYIT_SERVICE"] = "playitd";
        Settings["BOTC_VOICE_HOST"] = "";
        Settings["BOTC_VOICE_PORT"] = "24454";
        Settings["BOTC_VOICE_BIND_ADDRESS"] = "*";
        Settings["BOTC_RESOURCE_PACK_URL"] = "https://download.mc-packs.net/pack/8b79575eeabb9e6dbb7dbd4554b4d36331ca99de.zip";
        Settings["BOTC_MANAGE_DOCKER"] = "true";
        Settings["BOTC_DOCKER_DESKTOP_EXE"] = "";
        Settings["BOTC_DOCKER_START_TIMEOUT_SECONDS"] = "180";
    }

    private static void ReadLocalSettings()
    {
        string path = Path.Combine(LauncherDir, "local-settings.properties");
        if (!File.Exists(path))
        {
            return;
        }

        foreach (string line in File.ReadAllLines(path))
        {
            string trimmed = line.Trim();
            if (trimmed.Length == 0 || trimmed.StartsWith("#"))
            {
                continue;
            }

            int separator = trimmed.IndexOf('=');
            if (separator < 1)
            {
                continue;
            }

            string key = trimmed.Substring(0, separator).Trim();
            string value = trimmed.Substring(separator + 1).Trim();
            if (Settings.ContainsKey(key))
            {
                Settings[key] = value;
            }
        }
    }

    private static string GetSetting(string name, string defaultValue)
    {
        string value;
        if (Settings.TryGetValue(name, out value) && !string.IsNullOrWhiteSpace(value))
        {
            return value;
        }

        return defaultValue;
    }

    private static bool SettingEnabled(string name, string defaultValue)
    {
        return Regex.IsMatch(GetSetting(name, defaultValue), @"^(?i:true|yes|1|on)$");
    }

    private static bool GetManagedServiceFlag(string name)
    {
        Dictionary<string, string> state = ReadManagedServiceState();
        string value;
        return state.TryGetValue(name, out value) && Regex.IsMatch(value, @"^(?i:true|yes|1|on)$");
    }

    private static void SetManagedServiceFlag(string name, bool enabled)
    {
        try
        {
            Dictionary<string, string> state = ReadManagedServiceState();
            if (enabled)
            {
                state[name] = "true";
            }
            else
            {
                state.Remove(name);
            }

            WriteManagedServiceState(state);
        }
        catch (Exception ex)
        {
            Warning("Could not update managed service state");
            Detail(ex.Message);
        }
    }

    private static Dictionary<string, string> ReadManagedServiceState()
    {
        Dictionary<string, string> state = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (string.IsNullOrWhiteSpace(ManagedServicesFile) || !File.Exists(ManagedServicesFile))
        {
            return state;
        }

        foreach (string line in File.ReadAllLines(ManagedServicesFile))
        {
            string trimmed = line.Trim();
            if (trimmed.Length == 0 || trimmed.StartsWith("#"))
            {
                continue;
            }

            int separator = trimmed.IndexOf('=');
            if (separator < 1)
            {
                continue;
            }

            string key = trimmed.Substring(0, separator).Trim();
            string value = trimmed.Substring(separator + 1).Trim();
            if (key.Length > 0)
            {
                state[key] = value;
            }
        }

        return state;
    }

    private static void WriteManagedServiceState(Dictionary<string, string> state)
    {
        if (string.IsNullOrWhiteSpace(ManagedServicesFile))
        {
            return;
        }

        string dir = Path.GetDirectoryName(ManagedServicesFile);
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        if (state.Count == 0)
        {
            if (File.Exists(ManagedServicesFile))
            {
                File.Delete(ManagedServicesFile);
            }
            return;
        }

        List<string> lines = new List<string>();
        foreach (KeyValuePair<string, string> entry in state.OrderBy(entry => entry.Key, StringComparer.OrdinalIgnoreCase))
        {
            lines.Add(entry.Key + "=" + entry.Value);
        }

        File.WriteAllLines(ManagedServicesFile, lines.ToArray(), new UTF8Encoding(false));
    }

    private static int GetIntSetting(string name, int defaultValue, int minimum, int maximum)
    {
        int parsed;
        if (!int.TryParse(GetSetting(name, defaultValue.ToString()), out parsed))
        {
            return defaultValue;
        }

        return Math.Max(minimum, Math.Min(maximum, parsed));
    }

    private static void SetPropertiesFileValues(string path, Dictionary<string, string> values)
    {
        string dir = Path.GetDirectoryName(path);
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        List<string> lines = File.Exists(path) ? File.ReadAllLines(path).ToList() : new List<string>();
        foreach (KeyValuePair<string, string> entry in values)
        {
            string pattern = @"^\s*" + Regex.Escape(entry.Key) + @"\s*=";
            bool found = false;
            for (int i = 0; i < lines.Count; i++)
            {
                if (Regex.IsMatch(lines[i], pattern))
                {
                    lines[i] = entry.Key + "=" + entry.Value;
                    found = true;
                    break;
                }
            }

            if (!found)
            {
                lines.Add(entry.Key + "=" + entry.Value);
            }
        }

        File.WriteAllLines(path, lines.ToArray(), new UTF8Encoding(false));
    }

    private static List<string> GetCustomBackupPaths()
    {
        string[] candidates =
        {
            Path.Combine(RootDir, ".gitignore"),
            Path.Combine(RootDir, "README.md"),
            Path.Combine(RootDir, "BOTC.exe"),
            Path.Combine(RootDir, "Start.bat"),
            Path.Combine(RootDir, "Console.bat"),
            ServerIconFile,
            ComposeFile,
            Path.Combine(LauncherDir, "exe"),
            Path.Combine(LauncherDir, "local-settings.example.properties"),
            Path.Combine(RootDir, "AGENTS.md"),
            Path.Combine(RootDir, "docs"),
            Path.Combine(RootDir, "tools"),
            Path.Combine(RootDir, "Jays-Patch")
        };

        return candidates.Where(path => File.Exists(path) || Directory.Exists(path)).ToList();
    }

    private static string BackupSlotPath(string slotName)
    {
        return Path.Combine(RootDir, "backups", slotName);
    }

    private static void RemoveDirectoryInsideBackups(string path)
    {
        string backupRoot = Path.GetFullPath(Path.Combine(RootDir, "backups")).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
        string target = Path.GetFullPath(path);
        if (target.StartsWith(backupRoot, StringComparison.OrdinalIgnoreCase) && Directory.Exists(target))
        {
            Directory.Delete(target, true);
        }
    }

    private static void RemovePathInsideData(string path)
    {
        string dataRoot = Path.GetFullPath(ServerDataDir).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
        string target = Path.GetFullPath(path);
        if (target.StartsWith(dataRoot, StringComparison.OrdinalIgnoreCase))
        {
            if (Directory.Exists(target))
            {
                Directory.Delete(target, true);
            }
            else if (File.Exists(target))
            {
                File.Delete(target);
            }
        }
    }

    private static string AssertPathInsideData(string path)
    {
        string dataRoot = Path.GetFullPath(ServerDataDir).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
        string target = Path.GetFullPath(path);
        if (!target.StartsWith(dataRoot, StringComparison.OrdinalIgnoreCase))
        {
            throw new Exception("Refusing to use path outside server data: " + target);
        }

        return target;
    }

    private static void CopyDirectoryContents(string source, string destination)
    {
        Directory.CreateDirectory(destination);
        foreach (FileSystemInfo child in new DirectoryInfo(source).GetFileSystemInfos())
        {
            string target = Path.Combine(destination, child.Name);
            if ((child.Attributes & FileAttributes.Directory) == FileAttributes.Directory)
            {
                CopyDirectory(child.FullName, target);
            }
            else
            {
                File.Copy(child.FullName, target, true);
            }
        }
    }

    private static void DeployProtectedServerConfigFiles(string source, string destination)
    {
        foreach (string relativePath in ProtectedServerConfigFiles)
        {
            string sourcePath = Path.Combine(source, relativePath);
            if (!File.Exists(sourcePath))
            {
                continue;
            }

            string destinationPath = Path.Combine(destination, relativePath);
            string destinationDir = Path.GetDirectoryName(destinationPath);
            if (!string.IsNullOrEmpty(destinationDir))
            {
                Directory.CreateDirectory(destinationDir);
            }

            if (File.Exists(destinationPath))
            {
                Detail("Preserving runtime server config file (not overwritten): " + relativePath);
                continue;
            }

            CopyFileWithRetry(sourcePath, destinationPath);
        }
    }

    private static void CopyDirectory(string source, string destination)
    {
        Directory.CreateDirectory(destination);
        foreach (string dir in Directory.GetDirectories(source, "*", SearchOption.AllDirectories))
        {
            Directory.CreateDirectory(Path.Combine(destination, RelativePath(source, dir)));
        }
        foreach (string file in Directory.GetFiles(source, "*", SearchOption.AllDirectories))
        {
            string target = Path.Combine(destination, RelativePath(source, file));
            Directory.CreateDirectory(Path.GetDirectoryName(target));
            CopyFileWithRetry(file, target);
        }
    }

    private static void CopyFileWithRetry(string source, string destination)
    {
        Exception last = null;
        for (int attempt = 1; attempt <= 5; attempt++)
        {
            try
            {
                using (FileStream input = OpenBackupFileForRead(source))
                using (FileStream output = new FileStream(destination, FileMode.Create, FileAccess.Write, FileShare.None))
                {
                    input.CopyTo(output);
                }
                return;
            }
            catch (Exception ex)
            {
                last = ex;
                Thread.Sleep(200 * attempt);
            }
        }

        throw new Exception("Could not copy file: " + source + ". Windows said: " + (last == null ? "unknown error" : last.Message));
    }

    private static FileStream OpenBackupFileForRead(string path)
    {
        Exception last = null;
        for (int attempt = 1; attempt <= 5; attempt++)
        {
            try
            {
                return new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            }
            catch (Exception ex)
            {
                last = ex;
                Thread.Sleep(200 * attempt);
            }
        }

        throw new Exception("Backup could not read a locked file: " + path + ". Close editors, sync tools, or anything else using that file, then start BOTC.exe again. Windows said: " + (last == null ? "unknown error" : last.Message));
    }

    private static void ZipPaths(string[] paths, string destinationPath)
    {
        if (File.Exists(destinationPath))
        {
            File.Delete(destinationPath);
        }

        using (FileStream zipStream = new FileStream(destinationPath, FileMode.CreateNew))
        using (ZipArchive archive = new ZipArchive(zipStream, ZipArchiveMode.Create))
        {
            foreach (string path in paths)
            {
                if (Directory.Exists(path))
                {
                    string entryRoot = Path.GetFileName(path.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar));
                    foreach (string file in Directory.GetFiles(path, "*", SearchOption.AllDirectories))
                    {
                        string entry = (entryRoot + "/" + RelativePath(path, file)).Replace('\\', '/');
                        AddFileToZip(archive, file, entry);
                    }
                }
                else if (File.Exists(path))
                {
                    AddFileToZip(archive, path, Path.GetFileName(path));
                }
            }
        }
    }

    private static void ZipDirectoryContents(string sourceDir, string destinationPath)
    {
        if (File.Exists(destinationPath))
        {
            File.Delete(destinationPath);
        }

        using (FileStream zipStream = new FileStream(destinationPath, FileMode.CreateNew))
        using (ZipArchive archive = new ZipArchive(zipStream, ZipArchiveMode.Create))
        {
            foreach (string file in Directory.GetFiles(sourceDir, "*", SearchOption.AllDirectories))
            {
                AddFileToZip(archive, file, RelativePath(sourceDir, file).Replace('\\', '/'));
            }
        }
    }

    private static void AddFileToZip(ZipArchive archive, string filePath, string entryName)
    {
        ZipArchiveEntry entry = archive.CreateEntry(entryName, CompressionLevel.Optimal);
        using (Stream entryStream = entry.Open())
        using (FileStream fileStream = OpenBackupFileForRead(filePath))
        {
            fileStream.CopyTo(entryStream);
        }
    }

    private static string RelativePath(string root, string path)
    {
        Uri rootUri = new Uri(Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar);
        Uri pathUri = new Uri(Path.GetFullPath(path));
        return Uri.UnescapeDataString(rootUri.MakeRelativeUri(pathUri).ToString()).Replace('/', Path.DirectorySeparatorChar);
    }

    private static string BuildManifest(string slotName, string reason, List<string> files)
    {
        StringBuilder sb = new StringBuilder();
        sb.AppendLine("{");
        sb.AppendLine("  \"createdAt\": \"" + JsonEscape(DateTime.Now.ToString("s")) + "\",");
        sb.AppendLine("  \"slot\": \"" + JsonEscape(slotName) + "\",");
        sb.AppendLine("  \"reason\": \"" + JsonEscape(reason) + "\",");
        sb.AppendLine("  \"modpack\": \"Modrinth BOTC\",");
        sb.AppendLine("  \"composeSha256\": \"" + JsonEscape(FileSha256(ComposeFile)) + "\",");
        sb.AppendLine("  \"launcherSha256\": \"" + JsonEscape(FileSha256(Path.Combine(RootDir, "BOTC.exe"))) + "\",");
        sb.AppendLine("  \"files\": [");
        for (int i = 0; i < files.Count; i++)
        {
            sb.Append("    \"" + JsonEscape(files[i]) + "\"");
            if (i < files.Count - 1)
            {
                sb.Append(",");
            }
            sb.AppendLine();
        }
        sb.AppendLine("  ]");
        sb.AppendLine("}");
        return sb.ToString();
    }

    private static string JsonEscape(string value)
    {
        if (value == null)
        {
            return "";
        }
        return value.Replace("\\", "\\\\").Replace("\"", "\\\"");
    }

    private static string FileSha256(string path)
    {
        if (!File.Exists(path))
        {
            return null;
        }
        using (SHA256 sha = SHA256.Create())
        using (FileStream stream = File.OpenRead(path))
        {
            return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", "");
        }
    }

    private static string FileSha1(string path)
    {
        using (SHA1 sha = SHA1.Create())
        using (FileStream stream = File.OpenRead(path))
        {
            return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", "");
        }
    }

    private static string[] DockerLogsTail(int count)
    {
        CommandResult result = Run("docker", "logs --tail " + count + " " + ContainerName, true);
        return result.OutputLines;
    }

    private static string StartupLogSummary(string[] lines)
    {
        for (int i = lines.Length - 1; i >= 0; i--)
        {
            string line = OneLine(lines[i]);
            if (line.Length == 0 ||
                Regex.IsMatch(line, @"(?i)^\s+at\s+") ||
                Regex.IsMatch(line, @"(?i)exception|failed|error"))
            {
                continue;
            }

            return ShortText(line, 84);
        }

        return "";
    }

    private static double GetExpectedStartupSeconds()
    {
        string path = Path.Combine(LauncherDir, ".botc-startup-history.json");
        if (!File.Exists(path))
        {
            return 90.0;
        }

        Match match = Regex.Match(File.ReadAllText(path), @"""averageSeconds""\s*:\s*([0-9.]+)");
        if (match.Success)
        {
            double value;
            if (double.TryParse(match.Groups[1].Value, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out value) && value >= 20)
            {
                return value;
            }
        }

        return 90.0;
    }

    private static void SaveStartupDuration(DateTime start)
    {
        string path = Path.Combine(LauncherDir, ".botc-startup-history.json");
        double seconds = Math.Max(1, Math.Round((DateTime.Now - start).TotalSeconds, 1));
        string json = "{\n  \"averageSeconds\": " + seconds.ToString(System.Globalization.CultureInfo.InvariantCulture) + ",\n  \"lastSeconds\": " + seconds.ToString(System.Globalization.CultureInfo.InvariantCulture) + ",\n  \"count\": 1,\n  \"updatedAt\": \"" + DateTime.Now.ToString("s") + "\"\n}";
        File.WriteAllText(path, json, Encoding.ASCII);
    }

    private static string FormatElapsed(DateTime start)
    {
        TimeSpan elapsed = DateTime.Now - start;
        return elapsed.ToString(@"mm\:ss");
    }

    private static void Header(string status)
    {
        WriteHeader(status);
        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write("Type ");
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.Write("help");
        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.WriteLine(" for commands. Type Minecraft commands without the slash.");
        Console.ResetColor();
        Console.WriteLine();
    }

    private static void WriteHeader(string status)
    {
        if (!Console.IsOutputRedirected)
        {
            try
            {
                Console.Clear();
            }
            catch
            {
            }
        }
        Console.WriteLine();
        WriteRule("");
        WriteBrandLine();
        try
        {
            HeaderStatusTop = Console.IsOutputRedirected ? -1 : Console.CursorTop;
        }
        catch
        {
            HeaderStatusTop = -1;
        }
        WriteHeaderStatus(status, false);
        WriteRule("");
        Console.WriteLine();
    }

    private static void WriteBrandLine()
    {
        int width = FrameWidth();
        int inner = width - 4;
        string shortName = ShortText(Branding.ShortName, Math.Max(1, inner));
        int serverSpace = Math.Max(0, inner - shortName.Length - 3);
        string serverName = serverSpace > 0 ? ShortText(Branding.ServerName, serverSpace) : "";
        string separator = serverName.Length > 0 ? " | " : "";
        int brandLength = shortName.Length + separator.Length + serverName.Length;
        int spaces = Math.Max(0, inner - brandLength);
        Console.ForegroundColor = ConsoleColor.DarkRed;
        Console.Write("| ");
        Console.Write(shortName);
        if (separator.Length > 0)
        {
            Console.ForegroundColor = ConsoleColor.DarkGray;
            Console.Write(separator);
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.Write(serverName);
        }
        Console.Write(new string(' ', spaces));
        Console.ForegroundColor = ConsoleColor.DarkRed;
        Console.WriteLine(" |");
        Console.ResetColor();
    }

    private static void WriteHeaderStatus(string status, bool preserveCursor)
    {
        string text = "Status: " + status;
        ConsoleColor color = StatusColor(status);
        if (HeaderStatusTop >= 0)
        {
            int left = Console.CursorLeft;
            int top = Console.CursorTop;
            try
            {
                Console.SetCursorPosition(0, HeaderStatusTop);
                Console.Write(new string(' ', Math.Max(1, ConsoleWidth() - 1)));
                Console.SetCursorPosition(0, HeaderStatusTop);
                WriteFrameLine(text, color);
                if (preserveCursor)
                {
                    Console.SetCursorPosition(left, top);
                }
                return;
            }
            catch
            {
            }
        }

        WriteFrameLine(text, color);
    }

    private static ConsoleColor StatusColor(string status)
    {
        if (Regex.IsMatch(status ?? "", "^(?i)online$"))
        {
            return ConsoleColor.Green;
        }
        if (Regex.IsMatch(status ?? "", "^(?i)offline$"))
        {
            return ConsoleColor.DarkGray;
        }
        if (Regex.IsMatch(status ?? "", "^(?i)error"))
        {
            return ConsoleColor.Red;
        }
        return ConsoleColor.Yellow;
    }

    private static void WriteRule(string title)
    {
        int width = FrameWidth();
        Console.ForegroundColor = ConsoleColor.DarkRed;
        if (string.IsNullOrWhiteSpace(title))
        {
            Console.WriteLine("+" + new string('-', width - 2) + "+");
        }
        else
        {
            string clean = " " + ShortText(title, Math.Max(1, width - 6)) + " ";
            int right = Math.Max(0, width - clean.Length - 2);
            Console.WriteLine("+-" + clean + new string('-', right) + "+");
        }
        Console.ResetColor();
    }

    private static void WriteFrameLine(string text, ConsoleColor color)
    {
        int width = FrameWidth();
        int inner = width - 4;
        string clean = OneLine(text);
        if (clean.Length > inner)
        {
            clean = clean.Substring(0, Math.Max(0, inner - 3)) + "...";
        }

        Console.ForegroundColor = ConsoleColor.DarkRed;
        Console.Write("| ");
        Console.ForegroundColor = color;
        Console.Write(clean.PadRight(inner));
        Console.ForegroundColor = ConsoleColor.DarkRed;
        Console.WriteLine(" |");
        Console.ResetColor();
    }

    private static void WriteErrorBlock(string title, string message, string[] details)
    {
        Console.WriteLine();
        WriteRule("ERROR");
        WriteWrappedFrameText(title, ConsoleColor.Red);
        if (!string.IsNullOrWhiteSpace(message))
        {
            WriteWrappedFrameText(message, ConsoleColor.Gray);
        }
        foreach (string detail in details)
        {
            WriteWrappedFrameText(detail, ConsoleColor.DarkGray);
        }
        WriteRule("");
        Console.WriteLine();
    }

    private static void WriteWrappedFrameText(string text, ConsoleColor color)
    {
        int inner = FrameWidth() - 4;
        string remaining = OneLine(text);
        if (string.IsNullOrWhiteSpace(remaining))
        {
            WriteFrameLine("", color);
            return;
        }

        while (remaining.Length > inner)
        {
            int cut = remaining.LastIndexOf(' ', Math.Min(inner, remaining.Length - 1));
            if (cut < 12)
            {
                cut = inner;
            }
            WriteFrameLine(remaining.Substring(0, cut).Trim(), color);
            remaining = remaining.Substring(cut).Trim();
        }

        if (remaining.Length > 0)
        {
            WriteFrameLine(remaining, color);
        }
    }

    private static void StartDashboard()
    {
        DashboardActive = false;
        DashboardLines = 0;
        DashboardTop = -1;
        if (Console.IsOutputRedirected)
        {
            return;
        }
        try
        {
            DashboardTop = Console.CursorTop;
        }
        catch
        {
            return;
        }

        DashboardActive = true;
        DashboardLines = DashboardPhaseOrder.Length + 1;
        DashboardPhaseStates.Clear();
        foreach (string phase in DashboardPhaseOrder)
        {
            DashboardPhaseStates[phase] = "Waiting";
        }
        DashboardActivePhase = "";
        DashboardActiveDetail = "";
        for (int i = 0; i < DashboardLines; i++)
        {
            Console.WriteLine();
        }
        RenderDashboard();
    }

    private static void StopDashboard()
    {
        if (!DashboardActive)
        {
            return;
        }
        try
        {
            Console.SetCursorPosition(0, DashboardTop + DashboardLines);
            Console.WriteLine();
        }
        catch
        {
        }
        DashboardActive = false;
    }

    private static void Step(string label, string text)
    {
        if (SetDashboardPhase(label, "In progress", text))
        {
            return;
        }
        StatusLine(label, text, ConsoleColor.Cyan, ConsoleColor.Gray);
    }

    private static void Success(string text)
    {
        if (DashboardActive)
        {
            SetDashboardPhase(GuessDashboardPhaseFromText(text), "Done", "");
            return;
        }
        StatusLine("OK", text, ConsoleColor.Green, ConsoleColor.Gray);
    }

    private static void Success(string phase, string text)
    {
        if (DashboardActive)
        {
            SetDashboardPhase(phase, "Done", "");
            return;
        }
        StatusLine("OK", text, ConsoleColor.Green, ConsoleColor.Gray);
    }

    private static void Warning(string text)
    {
        if (SetDashboardPhase("WARN", "Warning", text))
        {
            return;
        }
        StatusLine("WARN", text, ConsoleColor.Yellow, ConsoleColor.Gray);
    }

    private static void Notice(string text)
    {
        if (SetDashboardDetail("Notice: " + text))
        {
            return;
        }
        StatusLine("NOTE", text, ConsoleColor.Cyan, ConsoleColor.Gray);
    }

    private static void Detail(string text)
    {
        if (SetDashboardDetail(text))
        {
            return;
        }
        StatusLine("INFO", text, ConsoleColor.DarkGray, ConsoleColor.DarkGray);
    }

    private static void CommandOutput(string source, string[] lines)
    {
        foreach (string line in lines)
        {
            string clean = OneLine(line);
            if (string.IsNullOrWhiteSpace(clean))
            {
                continue;
            }
            if (DashboardActive)
            {
                SetDashboardDetail(clean);
            }
            else
            {
                StatusLine(source, clean, ConsoleColor.DarkGray, ConsoleColor.DarkGray);
            }
        }
    }

    private static bool SetDashboardPhase(string label, string state, string detail)
    {
        if (!DashboardActive)
        {
            return false;
        }

        string phase = NormalizeDashboardPhase(label);
        if (string.IsNullOrWhiteSpace(phase))
        {
            phase = DashboardActivePhase;
        }
        if (string.IsNullOrWhiteSpace(phase))
        {
            phase = "CONFIG";
        }

        if (state == "In progress")
        {
            MarkEarlierActivePhasesDone(phase);
            DashboardActivePhase = phase;
            DashboardActiveDetail = detail;
            DashboardPhaseStates[phase] = "In progress";
        }
        else if (state == "Done" || state == "Skipped")
        {
            DashboardPhaseStates[phase] = state;
            if (EqualsIgnoreCase(DashboardActivePhase, phase))
            {
                DashboardActiveDetail = "";
            }
        }
        else if (state == "Warning")
        {
            DashboardPhaseStates[phase] = "Warning";
            DashboardActivePhase = phase;
            DashboardActiveDetail = detail;
        }

        WriteHeaderStatus(StartupStatusText(phase, detail), true);
        RenderDashboard();
        return true;
    }

    private static bool SetDashboardDetail(string detail)
    {
        if (!DashboardActive)
        {
            return false;
        }
        if (string.IsNullOrWhiteSpace(DashboardActivePhase))
        {
            return true;
        }

        string state = DashboardPhaseStates.ContainsKey(DashboardActivePhase) ? DashboardPhaseStates[DashboardActivePhase] : "Waiting";
        if (state == "Done" || state == "Skipped")
        {
            return true;
        }

        DashboardActiveDetail = detail;
        RenderDashboard();
        return true;
    }

    private static void MarkEarlierActivePhasesDone(string phase)
    {
        int phaseIndex = DashboardPhaseIndex(phase);
        for (int i = 0; i < DashboardPhaseOrder.Length; i++)
        {
            string candidate = DashboardPhaseOrder[i];
            string state = DashboardPhaseStates.ContainsKey(candidate) ? DashboardPhaseStates[candidate] : "Waiting";
            if (state == "In progress" && (phaseIndex < 0 || i < phaseIndex || !EqualsIgnoreCase(candidate, phase)))
            {
                DashboardPhaseStates[candidate] = "Done";
            }
        }
    }

    private static void RenderDashboard()
    {
        int row = 0;
        foreach (string phase in DashboardPhaseOrder)
        {
            string state = DashboardPhaseStates.ContainsKey(phase) ? DashboardPhaseStates[phase] : "Waiting";
            FixedDashboardPhaseLine(row, PhaseTitle(phase), state, PhaseColor(state), StateColor(state));
            row++;

            if (EqualsIgnoreCase(phase, DashboardActivePhase) && !string.IsNullOrWhiteSpace(DashboardActiveDetail) && row < DashboardLines)
            {
                FixedDashboardDetailLine(row, DashboardActiveDetail);
                row++;
            }
        }

        while (row < DashboardLines)
        {
            ClearDashboardLine(row);
            row++;
        }
    }

    private static string StartupStatusText(string label, string text)
    {
        if (label == "CONFIG") return "Loading settings...";
        if (label == "VOICE") return "Checking voice chat...";
        if (label == "BACKUP") return "Making backup...";
        if (label == "PATCH" || label == "RESOURCE") return "Deploying custom patch...";
        if (label == "DOCKER") return "Starting server...";
        if (label == "PLAYIT") return "Checking playit.gg...";
        if (label == "MINECRAFT") return text.StartsWith("100%") ? "Online" : "Starting server...";
        if (label == "SYNC") return "Synchronizing custom patch...";
        if (label == "WARN") return "Warning: check details";
        return "Working...";
    }

    private static string NormalizeDashboardPhase(string label)
    {
        if (string.IsNullOrWhiteSpace(label))
        {
            return "";
        }

        string clean = label.ToUpperInvariant();
        if (clean == "RESOURCE") return "PATCH";
        if (clean == "DETAIL" || clean == "WARN") return DashboardActivePhase;
        foreach (string phase in DashboardPhaseOrder)
        {
            if (phase == clean)
            {
                return phase;
            }
        }
        return "";
    }

    private static string GuessDashboardPhaseFromText(string text)
    {
        if (Regex.IsMatch(text, "voice", RegexOptions.IgnoreCase)) return "VOICE";
        if (Regex.IsMatch(text, "backup", RegexOptions.IgnoreCase)) return "BACKUP";
        if (Regex.IsMatch(text, "patch|resource", RegexOptions.IgnoreCase)) return "PATCH";
        if (Regex.IsMatch(text, "playit", RegexOptions.IgnoreCase)) return "PLAYIT";
        if (Regex.IsMatch(text, "sync", RegexOptions.IgnoreCase)) return "SYNC";
        if (Regex.IsMatch(text, "minecraft|server|docker", RegexOptions.IgnoreCase)) return "DOCKER";
        if (!string.IsNullOrWhiteSpace(DashboardActivePhase)) return DashboardActivePhase;
        return "CONFIG";
    }

    private static int DashboardPhaseIndex(string phase)
    {
        for (int i = 0; i < DashboardPhaseOrder.Length; i++)
        {
            if (EqualsIgnoreCase(DashboardPhaseOrder[i], phase))
            {
                return i;
            }
        }
        return -1;
    }

    private static string PhaseTitle(string phase)
    {
        if (phase == "CONFIG") return "Settings";
        if (phase == "VOICE") return "Voice Chat";
        if (phase == "BACKUP") return "Backup";
        if (phase == "PATCH") return "Patch";
        if (phase == "DOCKER") return "Docker";
        if (phase == "PLAYIT") return "Playit";
        if (phase == "MINECRAFT") return "Minecraft";
        if (phase == "SYNC") return "Final Sync";
        return phase;
    }

    private static ConsoleColor PhaseColor(string state)
    {
        if (state == "Done") return ConsoleColor.Green;
        if (state == "In progress") return ConsoleColor.Cyan;
        if (state == "Warning") return ConsoleColor.Yellow;
        return ConsoleColor.DarkGray;
    }

    private static ConsoleColor StateColor(string state)
    {
        if (state == "Done") return ConsoleColor.Green;
        if (state == "In progress") return ConsoleColor.Cyan;
        if (state == "Warning") return ConsoleColor.Yellow;
        return ConsoleColor.DarkGray;
    }

    private static void FixedDashboardPhaseLine(int row, string label, string text, ConsoleColor labelColor, ConsoleColor textColor)
    {
        FixedDashboardLine(row, "  ", label + ": ", text, labelColor, textColor);
    }

    private static void FixedDashboardDetailLine(int row, string text)
    {
        FixedDashboardLine(row, "  ", "Details: ", text, ConsoleColor.DarkGray, ConsoleColor.Gray);
    }

    private static void FixedDashboardLine(int row, string indent, string label, string text, ConsoleColor labelColor, ConsoleColor textColor)
    {
        int max = Math.Max(1, ConsoleWidth() - 1);
        string clean = OneLine(text);
        string labelText = indent + label;
        int space = Math.Max(0, max - labelText.Length);
        if (clean.Length > space)
        {
            clean = space <= 3 ? clean.Substring(0, Math.Max(0, space)) : clean.Substring(0, space - 3) + "...";
        }

        try
        {
            int top = DashboardTop + row;
            Console.SetCursorPosition(0, top);
            Console.Write(new string(' ', max));
            Console.SetCursorPosition(0, top);
            Console.ForegroundColor = labelColor;
            Console.Write(labelText);
            Console.ForegroundColor = textColor;
            Console.Write(clean);
            Console.ResetColor();
            Console.SetCursorPosition(0, DashboardTop + DashboardLines);
        }
        catch
        {
            StatusLine(label.TrimEnd(':', ' '), text, labelColor, textColor);
        }
    }

    private static void ClearDashboardLine(int row)
    {
        int max = Math.Max(1, ConsoleWidth() - 1);
        try
        {
            int top = DashboardTop + row;
            Console.SetCursorPosition(0, top);
            Console.Write(new string(' ', max));
            Console.SetCursorPosition(0, DashboardTop + DashboardLines);
        }
        catch
        {
        }
    }

    private static void StatusLine(string label, string text, ConsoleColor labelColor, ConsoleColor textColor)
    {
        Console.Write("  ");
        Console.ForegroundColor = labelColor;
        Console.Write(label.PadRight(7));
        Console.ForegroundColor = textColor;
        Console.WriteLine(OneLine(text));
        Console.ResetColor();
    }

    private static void HelpMenu()
    {
        Console.WriteLine();
        WriteRule("HELP");
        Console.WriteLine("  Type Minecraft server commands without the slash.");
        Console.WriteLine("  Minecraft commands are sent directly to the server.");
        Console.WriteLine();
        Console.ForegroundColor = ConsoleColor.Cyan;
        Console.WriteLine("  Console Commands");
        Console.ResetColor();
        CommandTable(new[,]
        {
            { "help", "Show this help panel" },
            { "cls", "Clear the window" },
            { "exit", "Close this window, keep server online" },
            { "stop", "Ask for backup, then stop server and launcher-started services" }
        });
        WriteRule("");
        Console.WriteLine();
    }

    private static void CommandTable(string[,] rows)
    {
        int width = 18;
        for (int i = 0; i < rows.GetLength(0); i++)
        {
            width = Math.Max(width, Math.Min(38, rows[i, 0].Length + 2));
        }

        for (int i = 0; i < rows.GetLength(0); i++)
        {
            Console.Write("  ");
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.Write(ShortText(rows[i, 0], width - 2).PadRight(width));
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.WriteLine(rows[i, 1]);
            Console.ResetColor();
        }
    }

    private static void WritePrompt()
    {
        Console.ForegroundColor = ConsoleColor.DarkRed;
        Console.Write(Branding.ShortName);
        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write(" > ");
        Console.ResetColor();
        Console.Write(Buffer);
    }

    private static void WriteLogLine(string text)
    {
        string kind = LogKind(text);
        string label = kind == "chat" ? "CHAT" : kind == "command" ? "CMD " : "LOG ";
        ConsoleColor color = kind == "chat" ? ConsoleColor.Cyan : kind == "command" ? ConsoleColor.Yellow : ConsoleColor.DarkGray;
        Console.ForegroundColor = ConsoleColor.DarkGray;
        Console.Write("[" + DateTime.Now.ToString("HH:mm:ss") + "] ");
        Console.ForegroundColor = color;
        Console.Write(label);
        Console.ResetColor();
        Console.Write("  ");
        Console.ForegroundColor = ConsoleColor.Gray;
        Console.WriteLine(OneLine(text));
        Console.ResetColor();
    }

    private static string LogKind(string text)
    {
        if (Regex.IsMatch(text, @"(?i)\b(?:issued|ran|executed)\s+(?:server\s+)?command\b") ||
            Regex.IsMatch(text, @"(?i)\[[^\]]+:\s+Running\s+(?:function|command)\s+.+\]"))
        {
            return "command";
        }
        if (Regex.IsMatch(text, @"<[^>]{1,32}>\s+.+") ||
            text.Contains("[CHAT]") ||
            Regex.IsMatch(text, @"\[Not Secure\].*<[^>]+>") ||
            Regex.IsMatch(text, @"(?i)\[(?:SocialSpy|Spy)\]") ||
            Regex.IsMatch(text, @"\[[^\]]+\s+(?:->|â†’)\s+[^\]]+\]\s+.+"))
        {
            return "chat";
        }
        return "log";
    }

    private static void WriteRawOutput(string[] lines)
    {
        foreach (string line in lines)
        {
            if (!string.IsNullOrWhiteSpace(line))
            {
                Console.WriteLine(line);
            }
        }
    }

    private static void ClearLine()
    {
        int max = Math.Max(1, ConsoleWidth() - 1);
        Console.Write("\r" + new string(' ', max) + "\r");
    }

    private static int ConsoleWidth()
    {
        try
        {
            return Console.WindowWidth < 20 ? 120 : Console.WindowWidth;
        }
        catch
        {
            return 120;
        }
    }

    private static int FrameWidth()
    {
        return Math.Max(54, Math.Min(92, ConsoleWidth() - 2));
    }

    private static string ProgressBar(int percent, int width)
    {
        int safe = Math.Max(0, Math.Min(100, percent));
        int filled = (int)Math.Floor((safe / 100.0) * width);
        return new string('#', filled) + new string('-', width - filled);
    }

    private static string ShortText(string text, int maxLength)
    {
        if (maxLength <= 0)
        {
            return "";
        }

        string clean = OneLine(text);
        if (clean.Length <= maxLength)
        {
            return clean;
        }
        return clean.Substring(0, Math.Max(0, maxLength - 3)) + "...";
    }

    private static string OneLine(string text)
    {
        if (text == null)
        {
            return "";
        }
        return Regex.Replace(text.Replace("\r", " ").Replace("\n", " "), @"\s+", " ").Trim();
    }

    private static bool EqualsIgnoreCase(string a, string b)
    {
        return string.Equals(a, b, StringComparison.OrdinalIgnoreCase);
    }

    private static string Quote(string value)
    {
        return "\"" + value.Replace("\"", "\\\"") + "\"";
    }

    private static bool IsInteractiveConsole()
    {
        try
        {
            if (Console.IsInputRedirected)
            {
                return false;
            }
            bool ignored = Console.KeyAvailable;
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static void PauseOnError()
    {
        if (!IsInteractiveConsole())
        {
            return;
        }
        Console.WriteLine();
        Console.WriteLine("Press any key to close.");
        Console.ReadKey(true);
    }

}
