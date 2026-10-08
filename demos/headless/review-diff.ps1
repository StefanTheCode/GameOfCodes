# Tip 4 - reviews the STAGED diff and FAILS on a blocker. Requires: claude CLI.
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$diff = git diff --cached | Out-String
if ([string]::IsNullOrWhiteSpace($diff)) { Write-Host "No staged changes."; exit 0 }

$prompt = @"
You are a strict code reviewer. Review this DIFF for leaked secrets or credentials
(API keys, tokens, passwords, connection strings) and for serious bugs.
You may explain briefly. But you MUST end your reply with a final line that is EXACTLY one
of these two tokens and nothing else on that line:
VERDICT_BLOCK
VERDICT_PASS
Use VERDICT_BLOCK if you find ANY hardcoded secret/credential or a serious bug; otherwise VERDICT_PASS.
Diff:
$diff
"@

$out = (claude -p $prompt | Out-String).Trim()
Write-Host "Review: $out"

if ($out -match 'VERDICT_BLOCK') { Write-Host "Blocker found - failing the build."; exit 1 }
if ($out -match 'VERDICT_PASS')  { Write-Host "No blockers."; exit 0 }
Write-Host "No clear verdict - blocking to be safe."; exit 1   # fail CLOSED
