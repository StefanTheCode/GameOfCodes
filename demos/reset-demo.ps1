# Reset the Tip 1 (hooks) demo to a clean baseline - restores CODE, TESTS and the HOOKS.
# RUN IN A PLAIN TERMINAL (not inside Claude Code). This replaces 'git checkout' for the demo.
$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
if (-not $here) { $here = Split-Path -Parent $MyInvocation.MyCommand.Path }
$proj = Split-Path -Parent $here
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Write-File($rel, $content) {
    $path = Join-Path $proj $rel
    $dir = Split-Path -Parent $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, $utf8)
}

$calc = @'
namespace FlightReliability.Domain;

public static class ReliabilityCalc
{
    // Implemented - used by the API and the MCP server.
    public static string ReliabilityBand(double onTimePct) => onTimePct switch
    {
        < 0    => "unknown",
        >= 80  => "good",
        >= 50  => "average",
        _      => "poor"
    };

    // ===== HOOKS DEMO TARGET =====
    // The agent implements THIS live. Goal on stage: "keep going until all tests pass".
    public static string DelayRisk(int avgDelayMinutes)
        => throw new NotImplementedException();
}
'@

$tests = @'
using FlightReliability.Domain;
using Xunit;

namespace FlightReliability.Tests;

public class ReliabilityCalcTests
{
    [Fact] public void Band_good()    => Assert.Equal("good",    ReliabilityCalc.ReliabilityBand(92));
    [Fact] public void Band_average() => Assert.Equal("average", ReliabilityCalc.ReliabilityBand(63));
    [Fact] public void Band_poor()    => Assert.Equal("poor",    ReliabilityCalc.ReliabilityBand(20));

    [Fact] public void Risk_high()    => Assert.Equal("high",    ReliabilityCalc.DelayRisk(75));
    [Fact] public void Risk_medium()  => Assert.Equal("medium",  ReliabilityCalc.DelayRisk(40));
    [Fact] public void Risk_low()     => Assert.Equal("low",     ReliabilityCalc.DelayRisk(10));

    [Fact] public void Risk_unknown_when_negative() => Assert.Equal("unknown", ReliabilityCalc.DelayRisk(-5));
}
'@

$formatHook = @'
$raw = [Console]::In.ReadToEnd()
try { $fp = ($raw | ConvertFrom-Json).tool_input.file_path } catch { $fp = $null }
function Write-HookEvent($hook, $title, $detail, $status) {
    try {
        $logFile = Join-Path (Join-Path $env:CLAUDE_PROJECT_DIR ".claude") "hook-events.jsonl"
        $obj = [ordered]@{ ts = (Get-Date).ToString("HH:mm:ss"); hook = $hook; title = $title; detail = $detail; status = $status }
        $line = ($obj | ConvertTo-Json -Compress) + "`n"
        [System.IO.File]::AppendAllText($logFile, $line, (New-Object System.Text.UTF8Encoding($false)))
    } catch { }
}
if ($fp -and $fp.ToString().EndsWith(".cs")) {
    $dir = Split-Path $fp -Parent
    $csproj = $null
    while ($dir) {
        $hit = Get-ChildItem -Path $dir -Filter *.csproj -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hit) { $csproj = $hit.FullName; break }
        $parent = Split-Path $dir -Parent
        if ($parent -eq $dir) { break }
        $dir = $parent
    }
    Push-Location $env:CLAUDE_PROJECT_DIR
    try {
        $rel = (Resolve-Path -Relative -LiteralPath $fp)
        if ($csproj) { dotnet format $csproj --include $rel *> $null } else { dotnet format --include $rel *> $null }
    } finally { Pop-Location }
    Write-HookEvent "PostToolUse" "Formatted $(Split-Path $fp -Leaf)" "dotnet format" "ok"
}
exit 0
'@

$protectHook = @'
$raw = [Console]::In.ReadToEnd()
try { $fp = ($raw | ConvertFrom-Json).tool_input.file_path } catch { $fp = $null }
function Write-HookEvent($hook, $title, $detail, $status) {
    try {
        $logFile = Join-Path (Join-Path $env:CLAUDE_PROJECT_DIR ".claude") "hook-events.jsonl"
        $obj = [ordered]@{ ts = (Get-Date).ToString("HH:mm:ss"); hook = $hook; title = $title; detail = $detail; status = $status }
        $line = ($obj | ConvertTo-Json -Compress) + "`n"
        [System.IO.File]::AppendAllText($logFile, $line, (New-Object System.Text.UTF8Encoding($false)))
    } catch { }
}
if ($fp -and ($fp -match '[\\/][Tt]ests[\\/]' -or $fp -match 'Tests\.cs$')) {
    Write-HookEvent "PreToolUse" "Blocked edit to a test file" (Split-Path $fp -Leaf) "blocked"
    $payload = @{ hookSpecificOutput = @{ hookEventName = "PreToolUse"; permissionDecision = "deny"; permissionDecisionReason = "Editing tests is blocked by repo policy. Tests change through a human and a PR, not the agent." } }
    Write-Output ($payload | ConvertTo-Json -Compress -Depth 5)
}
exit 0
'@

$gateHook = @'
function Write-HookEvent($hook, $title, $detail, $status) {
    try {
        $logFile = Join-Path (Join-Path $env:CLAUDE_PROJECT_DIR ".claude") "hook-events.jsonl"
        $obj = [ordered]@{ ts = (Get-Date).ToString("HH:mm:ss"); hook = $hook; title = $title; detail = $detail; status = $status }
        $line = ($obj | ConvertTo-Json -Compress) + "`n"
        [System.IO.File]::AppendAllText($logFile, $line, (New-Object System.Text.UTF8Encoding($false)))
    } catch { }
}
Write-HookEvent "Stop" "Running tests..." "dotnet test" "info"
$proj = Join-Path $env:CLAUDE_PROJECT_DIR "tests/FlightReliability.Tests"
$out = dotnet test "$proj" --nologo 2>&1 | Out-String
$summary = ""
if ($out -match 'Failed:\s*(\d+),\s*Passed:\s*(\d+)') { $summary = "Failed: $($Matches[1]), Passed: $($Matches[2])" }
if ($LASTEXITCODE -ne 0) {
    Write-HookEvent "Stop" "Tests failing - agent sent back" $summary "fail"
    [Console]::Error.WriteLine("Tests are failing. Fix the CODE before finishing:")
    [Console]::Error.WriteLine((($out -split "`n" | Select-Object -Last 25) -join "`n"))
    exit 2
}
Write-HookEvent "Stop" "All tests pass - agent may finish" $summary "ok"
exit 0
'@

Write-File "src/FlightReliability.Domain/ReliabilityCalc.cs" $calc
Write-File "tests/FlightReliability.Tests/ReliabilityCalcTests.cs" $tests
Write-File ".claude/hooks/format-cs.ps1" $formatHook
Write-File ".claude/hooks/protect-tests.ps1" $protectHook
Write-File ".claude/hooks/gate-tests.ps1" $gateHook
Write-File ".claude/hook-events.jsonl" ""

$agents = Join-Path $proj "AGENTS.md"
if (Test-Path $agents) {
    (Get-Content $agents) | Where-Object { $_ -notmatch 'Do not edit files under' } | Set-Content -Encoding utf8 $agents
}

Write-Host "Baseline restored: DelayRisk stub, tests, logging hooks, empty log." -ForegroundColor Green
Write-Host "Running tests (expect 3 passed / 4 failed)..." -ForegroundColor Cyan
Push-Location $proj
try { dotnet test tests/FlightReliability.Tests --nologo } finally { Pop-Location }
