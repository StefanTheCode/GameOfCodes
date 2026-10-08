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