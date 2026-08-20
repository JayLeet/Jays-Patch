using System;
using System.Collections.Generic;
using System.IO;

internal static partial class BotcLauncher
{
    private sealed class BrandingConfig
    {
        public string ShortName;
        public string ServerName;
        public string PatchName;
        public string MotdSubtitle;
        public string ResourcePackMessage;

        public static BrandingConfig Default()
        {
            return new BrandingConfig
            {
                ShortName = "BOTC",
                ServerName = "Jay's Clocktower",
                PatchName = "Jay's Patch",
                MotdSubtitle = "Come in, get comfy, and take a seat",
                ResourcePackMessage = "Jay's Patch resource pack"
            };
        }

        public static BrandingConfig Load(string path)
        {
            BrandingConfig config = Default();
            if (!File.Exists(path))
            {
                return config;
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
                if (EqualsIgnoreCase(key, "short"))
                {
                    config.ShortName = NonBlank(value, config.ShortName);
                }
                else if (EqualsIgnoreCase(key, "name"))
                {
                    config.ServerName = NonBlank(value, config.ServerName);
                }
                else if (EqualsIgnoreCase(key, "patch"))
                {
                    config.PatchName = NonBlank(value, config.PatchName);
                }
                else if (EqualsIgnoreCase(key, "motd.subtitle"))
                {
                    config.MotdSubtitle = NonBlank(value, config.MotdSubtitle);
                }
                else if (EqualsIgnoreCase(key, "resourcepack.message"))
                {
                    config.ResourcePackMessage = NonBlank(value, config.ResourcePackMessage);
                }
            }

            return config;
        }

        public string Motd()
        {
            return "\\u00A74\\u00A7l" + PropertyText(ShortName) +
                "\\u00A7r \\u00A78| \\u00A76" + PropertyText(ServerName) +
                "\\u00A7r\\n\\u00A77" + PropertyText(MotdSubtitle);
        }

        public string ResourcePackPrompt()
        {
            return "{\"text\":\"\",\"extra\":[" +
                "{\"text\":\"" + JsonText(ShortName) + "\",\"color\":\"dark_red\",\"bold\":true}," +
                "{\"text\":\" | \",\"color\":\"dark_gray\",\"bold\":false}," +
                "{\"text\":\"" + JsonText(PatchName) + "\",\"color\":\"gold\",\"bold\":false}," +
                "{\"text\":\"\\\\n" + JsonText(ResourcePackMessage) + "\",\"color\":\"gray\",\"bold\":false}" +
                "]}";
        }

        private static string PropertyText(string value)
        {
            return OneLine(value);
        }

        private static string JsonText(string value)
        {
            if (value == null)
            {
                return "";
            }

            return value
                .Replace("\\", "\\\\")
                .Replace("\"", "\\\"")
                .Replace("\r", "\\r")
                .Replace("\n", "\\n");
        }

        private static string NonBlank(string value, string fallback)
        {
            return string.IsNullOrWhiteSpace(value) ? fallback : value;
        }
    }

    private sealed class CommandResult
    {
        public readonly int ExitCode;
        public readonly string[] OutputLines;
        public readonly string Output;

        public CommandResult(int exitCode, string[] outputLines)
        {
            ExitCode = exitCode;
            OutputLines = outputLines ?? new string[0];
            Output = string.Join(Environment.NewLine, OutputLines);
        }
    }

    private sealed class BackupResult
    {
        public readonly string Path;
        public readonly List<string> Files;

        public BackupResult(string path, List<string> files)
        {
            Path = path;
            Files = files;
        }
    }

    private sealed class StartupProgress
    {
        public readonly int Percent;
        public readonly string Stage;
        public readonly string Detail;

        public StartupProgress(int percent, string stage, string detail)
        {
            Percent = percent;
            Stage = stage;
            Detail = detail;
        }
    }
}
