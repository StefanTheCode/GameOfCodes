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