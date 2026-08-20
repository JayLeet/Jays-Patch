using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;

internal static partial class BotcLauncher
{
    private static CommandResult Rcon(string command)
    {
        return Rcon(command, 0);
    }

    private static CommandResult Rcon(string command, int timeoutMilliseconds)
    {
        return Run("docker", "exec -i " + ContainerName + " rcon-cli " + Quote(command), true, timeoutMilliseconds);
    }

    private static bool IsDockerContainerRunning(string name)
    {
        CommandResult result;
        if (!TryRun("docker", "inspect -f \"{{.State.Running}}\" " + name, true, out result))
        {
            return false;
        }

        return result.ExitCode == 0 && result.Output.Trim() == "true";
    }

    private static bool TryRun(string fileName, string arguments, bool capture, out CommandResult result)
    {
        try
        {
            result = Run(fileName, arguments, capture);
            return true;
        }
        catch (Exception ex)
        {
            result = new CommandResult(1, new[] { ex.Message });
            return false;
        }
    }

    private static CommandResult Run(string fileName, string arguments, bool capture)
    {
        return Run(fileName, arguments, capture, 0);
    }

    private static CommandResult Run(string fileName, string arguments, bool capture, int timeoutMilliseconds)
    {
        ProcessStartInfo info = new ProcessStartInfo();
        info.FileName = fileName;
        info.Arguments = arguments;
        info.WorkingDirectory = RootDir;
        info.UseShellExecute = false;
        info.RedirectStandardOutput = capture;
        info.RedirectStandardError = capture;
        info.CreateNoWindow = true;

        List<string> lines = new List<string>();
        object outputLock = new object();
        using (Process process = new Process())
        {
            process.StartInfo = info;
            if (capture)
            {
                process.OutputDataReceived += delegate(object sender, DataReceivedEventArgs args)
                {
                    if (args.Data != null)
                    {
                        lock (outputLock)
                        {
                            lines.Add(args.Data);
                        }
                    }
                };
                process.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs args)
                {
                    if (args.Data != null)
                    {
                        lock (outputLock)
                        {
                            lines.Add(args.Data);
                        }
                    }
                };
            }
            process.Start();

            if (capture)
            {
                process.BeginOutputReadLine();
                process.BeginErrorReadLine();
            }

            bool exited;
            if (timeoutMilliseconds > 0)
            {
                exited = process.WaitForExit(timeoutMilliseconds);
            }
            else
            {
                process.WaitForExit();
                exited = true;
            }

            if (!exited)
            {
                try
                {
                    process.Kill();
                }
                catch
                {
                }
                throw new Exception("Command timed out after " + Math.Ceiling(timeoutMilliseconds / 1000.0) + " seconds: " + fileName + " " + arguments);
            }

            if (capture)
            {
                process.WaitForExit();
            }
            lock (outputLock)
            {
                return new CommandResult(process.ExitCode, lines.ToArray());
            }
        }
    }

    private static void AddLines(List<string> lines, string text)
    {
        if (string.IsNullOrEmpty(text))
        {
            return;
        }

        using (StringReader reader = new StringReader(text))
        {
            string line;
            while ((line = reader.ReadLine()) != null)
            {
                lines.Add(line);
            }
        }
    }
}
