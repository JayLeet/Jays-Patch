using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;

internal static partial class BotcLauncher
{
    private static CommandResult Rcon(string command)
    {
        return Run("docker", "exec -i " + ContainerName + " rcon-cli " + Quote(command), true);
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
        ProcessStartInfo info = new ProcessStartInfo();
        info.FileName = fileName;
        info.Arguments = arguments;
        info.WorkingDirectory = RootDir;
        info.UseShellExecute = false;
        info.RedirectStandardOutput = capture;
        info.RedirectStandardError = capture;
        info.CreateNoWindow = true;

        List<string> lines = new List<string>();
        using (Process process = new Process())
        {
            process.StartInfo = info;
            process.Start();

            if (capture)
            {
                string output = process.StandardOutput.ReadToEnd();
                string error = process.StandardError.ReadToEnd();
                AddLines(lines, output);
                AddLines(lines, error);
            }

            process.WaitForExit();
            return new CommandResult(process.ExitCode, lines.ToArray());
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
