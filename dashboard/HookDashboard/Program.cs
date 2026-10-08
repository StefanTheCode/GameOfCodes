// Hook Activity dashboard - a tiny Minimal API that serves a live panel and reads
// the real hook event log that the .claude/hooks/*.ps1 scripts append to.
// Run from the FlightDemo root:  dotnet run --project dashboard/HookDashboard
// Then open http://localhost:5250

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var logPath = ResolveLogPath(args);

app.UseDefaultFiles();   // serves wwwroot/index.html at "/"
app.UseStaticFiles();

// All hook events, newest last, as a JSON array. Each log line is validated so a
// BOM (Windows PowerShell) or a half-written line can never break the whole feed.
app.MapGet("/events", () =>
{
    if (!File.Exists(logPath)) return Results.Content("[]", "application/json");
    var valid = new List<string>();
    foreach (var raw in SafeReadLines(logPath))
    {
        var line = raw.Trim().TrimStart('﻿');
        if (line.Length == 0) continue;
        try { using var _ = System.Text.Json.JsonDocument.Parse(line); valid.Add(line); }
        catch { /* skip a partial line still being written */ }
    }
    return Results.Content("[" + string.Join(",", valid) + "]", "application/json");
});

// Clear the feed between takes (the dashboard's "Clear" button calls this).
app.MapPost("/clear", () =>
{
    try { if (File.Exists(logPath)) File.WriteAllText(logPath, ""); } catch { }
    return Results.Ok(new { cleared = true });
});

app.MapGet("/health", () => Results.Ok(new { ok = true, logPath }));

Console.WriteLine($"Hook dashboard on http://localhost:5250  (reading {logPath})");
app.Run("http://localhost:5250");

// Read with shared access so the PowerShell hooks can keep appending while we read.
static IEnumerable<string> SafeReadLines(string path)
{
    using var fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
    using var sr = new StreamReader(fs);
    string? line;
    while ((line = sr.ReadLine()) != null) yield return line;
}

// Find .claude/hook-events.jsonl: explicit arg, else walk up from the current dir.
static string ResolveLogPath(string[] args)
{
    if (args.Length > 0 && Directory.Exists(args[0]))
        return Path.Combine(args[0], ".claude", "hook-events.jsonl");

    var dir = new DirectoryInfo(Directory.GetCurrentDirectory());
    while (dir != null)
    {
        var candidate = Path.Combine(dir.FullName, ".claude");
        if (Directory.Exists(candidate))
            return Path.Combine(candidate, "hook-events.jsonl");
        dir = dir.Parent;
    }
    return Path.Combine(Directory.GetCurrentDirectory(), ".claude", "hook-events.jsonl");
}
