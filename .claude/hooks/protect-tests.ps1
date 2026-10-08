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