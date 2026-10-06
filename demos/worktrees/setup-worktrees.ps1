# Tip 5 (manual version) - N isolated copies, one per agent, each on its own branch.
$root = git rev-parse --show-toplevel
Set-Location $root

git worktree add ..\fr-feat-1 -b feat/healthcheck
git worktree add ..\fr-feat-2 -b feat/delay-stats
git worktree add ..\fr-feat-3 -b feat/openapi

Write-Host ""
Write-Host "3 worktrees created next to this repo. Open one agent per folder (separate terminals):"
Write-Host "  cd ..\fr-feat-1 ; claude    # paste task 1 from TASKS.md"
Write-Host "  cd ..\fr-feat-2 ; claude    # paste task 2"
Write-Host "  cd ..\fr-feat-3 ; claude    # paste task 3"
Write-Host ""
Write-Host "Merge later:  git merge feat/healthcheck feat/delay-stats feat/openapi"
Write-Host "Clean up:     git worktree remove ..\fr-feat-1  (repeat) ; git branch -D feat/healthcheck"
