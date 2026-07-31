using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

internal static partial class BotcLauncher
{
    private static void BuildJaysPatchResourcePack(string resourcepackSource, string dashboardPhase)
    {
        string distDir = Path.Combine(RootDir, "Jays-Patch", "dist");
        string localZipPath = Path.Combine(distDir, "Jays-Patch-resourcepack-local.zip");
        string hostedZipPath = Path.Combine(distDir, "Jays-Patch-resourcepack.zip");
        string stagingDir = Path.Combine(distDir, "resourcepack-staging");
        Directory.CreateDirectory(distDir);

        if (File.Exists(localZipPath))
        {
            File.Delete(localZipPath);
        }
        if (Directory.Exists(stagingDir))
        {
            Directory.Delete(stagingDir, true);
        }

        CopyDirectory(resourcepackSource, stagingDir);
        try
        {
            ZipDirectoryContents(stagingDir, localZipPath);

            Dictionary<string, string> configured = ReadRequiredServerProperties();
            string configuredUrl = RequiredProperty(configured, "resource-pack");
            string configuredSha1 = RequiredProperty(configured, "resource-pack-sha1").ToLowerInvariant();
            string configuredId = RequiredProperty(configured, "resource-pack-id");

            if (!Regex.IsMatch(configuredSha1, "^[0-9a-f]{40}$"))
            {
                throw new Exception("Invalid resource-pack-sha1 in " + RequiredServerPropertiesFile);
            }
            Guid ignoredId;
            if (!Guid.TryParse(configuredId, out ignoredId))
            {
                throw new Exception("Invalid resource-pack-id in " + RequiredServerPropertiesFile);
            }
            string resourcePackUrl = GetSetting("BOTC_RESOURCE_PACK_URL", configuredUrl).Trim();
            string serverResourcePackSha1 = configuredSha1;
            string serverResourcePackId = configuredId;
            bool usesCanonicalUrl = string.Equals(resourcePackUrl, configuredUrl, StringComparison.OrdinalIgnoreCase);

            Match urlSha = Regex.Match(resourcePackUrl, @"/pack/([0-9a-fA-F]{40})\.zip");
            if (usesCanonicalUrl)
            {
                if (urlSha.Success && !string.Equals(urlSha.Groups[1].Value, configuredSha1, StringComparison.OrdinalIgnoreCase))
                {
                    throw new Exception("Configured resource-pack URL and resource-pack-sha1 disagree in " + RequiredServerPropertiesFile);
                }
            }
            else
            {
                if (!urlSha.Success)
                {
                    throw new Exception("BOTC_RESOURCE_PACK_URL overrides must use an MC-Packs URL containing the 40-character SHA1.");
                }
                serverResourcePackSha1 = urlSha.Groups[1].Value.ToLowerInvariant();
                serverResourcePackId = ResourcePackIdFromSha1(serverResourcePackSha1);
                Notice("Using a local resource-pack URL override; its cache ID was derived from the hosted SHA1");
            }

            VerifyHostedResourcePack(hostedZipPath, stagingDir, configuredSha1, usesCanonicalUrl);

            Dictionary<string, string> values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            values["resource-pack"] = resourcePackUrl;
            values["resource-pack-sha1"] = serverResourcePackSha1;
            values["resource-pack-id"] = serverResourcePackId;
            values["resource-pack-prompt"] = Branding.ResourcePackPrompt();
            SetPropertiesFileValuesInOrder(
                Path.Combine(ServerDataDir, "server.properties"),
                values,
                new[]
                {
                    "resource-pack",
                    "resource-pack-id",
                    "resource-pack-prompt",
                    "resource-pack-sha1"
                },
                new[] { "require-resource-pack" });

            Detail("Local custom resource pack built: " + localZipPath);
            Detail("Custom resource pack URL configured from " + RequiredServerPropertiesFile);
        }
        finally
        {
            if (Directory.Exists(stagingDir))
            {
                Directory.Delete(stagingDir, true);
            }
        }
    }

    private static Dictionary<string, string> ReadRequiredServerProperties()
    {
        if (!File.Exists(RequiredServerPropertiesFile))
        {
            throw new Exception("Missing canonical Jay's Patch server properties: " + RequiredServerPropertiesFile);
        }

        Dictionary<string, string> values = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        foreach (string rawLine in File.ReadAllLines(RequiredServerPropertiesFile))
        {
            string line = rawLine.Trim();
            if (line.Length == 0 || line.StartsWith("#", StringComparison.Ordinal))
            {
                continue;
            }

            int separator = line.IndexOf('=');
            if (separator > 0)
            {
                values[line.Substring(0, separator).Trim()] = line.Substring(separator + 1);
            }
        }
        return values;
    }

    private static string RequiredProperty(Dictionary<string, string> properties, string key)
    {
        string value;
        if (!properties.TryGetValue(key, out value) || string.IsNullOrWhiteSpace(value))
        {
            throw new Exception("Missing " + key + " in " + RequiredServerPropertiesFile);
        }
        return value;
    }

    private static void VerifyHostedResourcePack(string hostedZipPath, string stagingDir, string configuredSha1, bool usesCanonicalUrl)
    {
        if (!usesCanonicalUrl)
        {
            return;
        }
        if (!File.Exists(hostedZipPath))
        {
            Notice("Hosted resource-pack fallback is not cached locally; source-content comparison was skipped");
            return;
        }

        string hostedSha1 = FileSha1(hostedZipPath).ToLowerInvariant();
        if (!string.Equals(hostedSha1, configuredSha1, StringComparison.OrdinalIgnoreCase))
        {
            Warning("Cached hosted resource-pack fallback is stale; rebuild the public package to refresh it");
            return;
        }

        string mismatch;
        if (!ZipContentsMatchDirectory(hostedZipPath, stagingDir, out mismatch))
        {
            Warning("Jay's Patch resource-pack source differs from the configured hosted pack: " + mismatch);
            return;
        }
        Detail("Hosted resource-pack contents match Jay's Patch source");
    }

    private static bool ZipContentsMatchDirectory(string zipPath, string directory, out string mismatch)
    {
        Dictionary<string, string> expected = Directory.GetFiles(directory, "*", SearchOption.AllDirectories)
            .ToDictionary(
                path => RelativePath(directory, path).Replace('\\', '/'),
                path => FileSha256(path),
                StringComparer.OrdinalIgnoreCase);

        using (FileStream stream = File.OpenRead(zipPath))
        using (ZipArchive archive = new ZipArchive(stream, ZipArchiveMode.Read))
        {
            ZipArchiveEntry[] files = archive.Entries.Where(entry => !string.IsNullOrEmpty(entry.Name)).ToArray();
            if (files.Length != expected.Count)
            {
                mismatch = "file count differs (source " + expected.Count + ", hosted " + files.Length + ")";
                return false;
            }

            foreach (ZipArchiveEntry entry in files)
            {
                string expectedHash;
                if (!expected.TryGetValue(entry.FullName.Replace('\\', '/'), out expectedHash))
                {
                    mismatch = "hosted-only file " + entry.FullName;
                    return false;
                }

                using (Stream entryStream = entry.Open())
                {
                    string actualHash = StreamSha256(entryStream);
                    if (!string.Equals(actualHash, expectedHash, StringComparison.OrdinalIgnoreCase))
                    {
                        mismatch = "changed file " + entry.FullName;
                        return false;
                    }
                }
            }
        }

        mismatch = "";
        return true;
    }

    private static string StreamSha256(Stream stream)
    {
        using (SHA256 sha = SHA256.Create())
        {
            return BitConverter.ToString(sha.ComputeHash(stream)).Replace("-", "");
        }
    }

    private static string ResourcePackIdFromSha1(string sha1)
    {
        string hex = sha1.Substring(0, 32).ToLowerInvariant();
        return hex.Substring(0, 8) + "-" + hex.Substring(8, 4) + "-5" + hex.Substring(13, 3) + "-a" + hex.Substring(17, 3) + "-" + hex.Substring(20, 12);
    }
}
