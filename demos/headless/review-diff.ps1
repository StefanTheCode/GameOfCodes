# Tip 4 - the agent as a scriptable CI step (PowerShell).
# Reviews the staged diff and FAILS on a blocker. Requires: claude CLI.
$diff = git diff --cached | Out-String
if ([string]::IsNullOrWhiteSpace($diff)) { Write-Host "No staged changes."; exit 0 }

$prompt = @"
You are a strict code reviewer. Review this diff for real bugs and leaked secrets.
Respond with ONLY compact JSON: {"blocker": true|false, "notes": "one line"}.
Diff:
$diff
"@

# claude -p --output-format json returns an envelope; the model's text is in .result,
# and that text is itself the JSON we asked for -> parse twice.
$envelope = claude -p $prompt --output-format json | Out-String
$answer   = ($envelope | ConvertFrom-Json).result | ConvertFrom-Json

Write-Host "Review: $($answer.notes)"
if ($answer.blocker) { Write-Host "Blocker found - failing the build."; exit 1 }
Write-Host "No blockers."; exit 0
