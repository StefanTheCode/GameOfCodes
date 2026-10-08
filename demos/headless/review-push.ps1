# Tip 4 - reviews the commits being PUSHED and fails on a blocker. Requires: claude CLI.
$up = git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null
if ($LASTEXITCODE -eq 0 -and $up) { $range = '@{u}..HEAD' } else { $range = 'HEAD~1..HEAD' }
$diff = git diff $range | Out-String
if ([string]::IsNullOrWhiteSpace($diff)) { Write-Host "Nothing to review."; exit 0 }

$prompt = @"
You are a strict code reviewer. Review this diff for real bugs and leaked secrets.
Respond with ONLY compact JSON: {"blocker": true|false, "notes": "one line"}.
Diff:
$diff
"@

$envelope = claude -p $prompt --output-format json | Out-String
$answer   = ($envelope | ConvertFrom-Json).result | ConvertFrom-Json

Write-Host "Review: $($answer.notes)"
if ($answer.blocker) { Write-Host "Blocker found - push aborted."; exit 1 }
Write-Host "No blockers."; exit 0
