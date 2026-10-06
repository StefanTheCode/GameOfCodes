# Stop hook: don't let the agent finish while tests are red.
$proj = Join-Path $env:CLAUDE_PROJECT_DIR "tests/FlightReliability.Tests"
$out  = dotnet test "$proj" --nologo 2>&1 | Out-String

if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("Tests are failing. Fix the CODE before finishing:")
    $tail = ($out -split "`n" | Select-Object -Last 25) -join "`n"
    [Console]::Error.WriteLine($tail)
    exit 2   # refuses the stop; the failure goes back to the agent
}
exit 0
