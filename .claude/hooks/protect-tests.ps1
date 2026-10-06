# PreToolUse (Edit|Write): block edits to test files so the agent can't "fix"
# a failing test by weakening it. It has to fix the real code.
$raw = [Console]::In.ReadToEnd()
try { $fp = ($raw | ConvertFrom-Json).tool_input.file_path } catch { $fp = $null }

if ($fp -and ($fp -match '[\\/][Tt]ests[\\/]' -or $fp -match 'Tests\.cs$')) {
    $payload = @{
        hookSpecificOutput = @{
            hookEventName            = "PreToolUse"
            permissionDecision       = "deny"
            permissionDecisionReason = "Editing tests is blocked by repo policy. Make the failing test pass by fixing the CODE, not the test."
        }
    }
    Write-Output ($payload | ConvertTo-Json -Compress -Depth 5)
}
exit 0
