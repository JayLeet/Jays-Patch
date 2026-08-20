using System;

internal static partial class BotcLauncher
{
    private static void WriteProgressRows(
        string line1,
        string detail,
        string stats,
        bool finish,
        string fallbackLabel,
        ref int topLine,
        ref int lineLength,
        ref int detailLineLength,
        ref int statsLineLength)
    {
        int width = Math.Max(1, ConsoleWidth() - 1);
        string cleanLine1 = ShortText(line1, width);
        string cleanLine2 = string.IsNullOrWhiteSpace(detail) ? "" : ShortText("Details: " + detail, width);
        string cleanLine3 = string.IsNullOrWhiteSpace(stats) ? "" : ShortText("Stats: " + stats, width);
        bool updated = true;

        if (topLine < 0)
        {
            topLine = ReserveProgressRows(3);
        }

        try
        {
            Console.SetCursorPosition(0, topLine);
            Console.Write(cleanLine1.PadRight(width));
            Console.SetCursorPosition(0, topLine + 1);
            Console.Write(cleanLine2.PadRight(width));
            Console.SetCursorPosition(0, topLine + 2);
            Console.Write(cleanLine3.PadRight(width));
            lineLength = Math.Max(1, Math.Min(width, cleanLine1.Length));
            detailLineLength = Math.Max(1, Math.Min(width, cleanLine2.Length));
            statsLineLength = Math.Max(1, Math.Min(width, cleanLine3.Length));
            Console.SetCursorPosition(0, topLine + 3);
        }
        catch
        {
            updated = false;
            StatusLine(fallbackLabel, line1, ConsoleColor.DarkGray, ConsoleColor.DarkGray);
            if (!string.IsNullOrWhiteSpace(detail))
            {
                StatusLine(fallbackLabel, "Details: " + detail, ConsoleColor.DarkGray, ConsoleColor.DarkGray);
            }
            if (!string.IsNullOrWhiteSpace(stats))
            {
                StatusLine(fallbackLabel, "Stats: " + stats, ConsoleColor.DarkGray, ConsoleColor.DarkGray);
            }
            topLine = -1;
            lineLength = 0;
            detailLineLength = 0;
            statsLineLength = 0;
        }

        if (finish && updated)
        {
            lineLength = 0;
            detailLineLength = 0;
            statsLineLength = 0;
            topLine = -1;
            Console.WriteLine();
        }
    }

    private static int ReserveProgressRows(int rowCount)
    {
        int safeRows = Math.Max(1, rowCount);
        for (int row = 0; row <= safeRows; row++)
        {
            Console.WriteLine();
        }
        return Math.Max(0, Console.CursorTop - safeRows);
    }

    private static int ProgressBarWidthForPrefix(string prefix)
    {
        int prefixLength = OneLine(prefix).Length;
        int available = Math.Max(1, ConsoleWidth() - 1 - prefixLength - 2);
        return Math.Min(StartupProgressBarWidth, Math.Max(10, available));
    }
}
