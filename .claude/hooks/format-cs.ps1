# PostToolUse (Edit|Write): format the C# file the agent just wrote.
$raw = [Console]::In.ReadToEnd()
try { $fp = ($raw | ConvertFrom-Json).tool_input.file_path } catch { $fp = $null }
if ($fp -and $fp.ToString().EndsWith(".cs")) {
    dotnet format "$env:CLAUDE_PROJECT_DIR" --include "$fp" *> $null
}
exit 0
