# FlightDemo - one project, all five demos

Your talk thread in one .NET 10 solution. **No database** - the API uses in-memory sample data, so setup is fast.
Windows / PowerShell hooks (no bash/jq). We test each tip on THIS project.

```
src/FlightReliability.Domain   ReliabilityCalc (ReliabilityBand used by API/MCP; DelayRisk = hooks target)
src/FlightReliability.Api      Minimal API, in-memory flights, /flights/reliability (rewind demo target)
src/FlightReliability.Mcp      optional C# MCP (sample data). For the TALK, use Performance Lab instead.
tests/FlightReliability.Tests  xUnit. DelayRisk tests fail until the agent implements it (that's the hooks demo)
.claude/                       hooks: format-cs / gate-tests / protect-tests (PowerShell)
demos/headless|worktrees|rewind  scripts + prompts
```

## STEP 0 - verify it builds (do this first, paste me the result)
```powershell
cd FlightDemo
dotnet build
dotnet test tests/FlightReliability.Tests
```
Expected: **build succeeds**; tests show **3 passed (Band_*) and 4 failed (Risk_*)**. The Risk_* failures are
INTENTIONAL - that's the starting point for the hooks demo. If the BUILD fails, paste the error (likely a
package version - the MCP project is the only risky one; if so, remove it from `FlightDemo.slnx` for now and rebuild).

---

## TIP 1 - Hooks
1. Open Claude Code in `FlightDemo`. `/hooks` → you should see 3 hooks.
2. **Format:** "Add a public static method `double Half(double x)` to ReliabilityCalc with messy spacing." → it reformats instantly.
3. **Stop-gate + no-cheat (money shot):** paste the spec that OMITS the negative case:
   > "Implement DelayRisk in ReliabilityCalc: if avgDelayMinutes >= 60 return 'high', if >= 30 return 'medium', otherwise 'low'."
   → it implements 3 branches, says done → **Stop hook runs tests** → `Risk_unknown_when_negative` fails → bounced →
   if it tries to edit the test, **protect-tests blocks it** → it fixes the code (negative → "unknown") → green.
4. Reset: `git checkout -- .`

## TIP 2 - MCP  (recommended: Performance Lab)
Your Performance Lab is the stronger MCP demo (perf diagnosis). See the setup guide for connecting it to
Copilot (VS Code) and Claude Code. If you want it on THIS project instead: `/mcp` connects `flight-reliability`
(via `.mcp.json`); ask *"Which routes are least reliable?"* → it calls `GetFlightsByReliability`.

## TIP 3 - Rewind
`demos/rewind/PROMPTS.md` - run the sprawl prompt on `/flights/reliability`, then `/rewind`.

## TIP 4 - Headless
```powershell
# stage a change with a planted "secret" then:
./demos/headless/review-diff.ps1     # → JSON verdict; exits 1 on a blocker
```
Set `ANTHROPIC_API_KEY`. Azure DevOps step + git pre-push are in `demos/headless/`.

## TIP 5 - Agent teams
Enable in `.claude/settings.json`: add `"env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }`.
Then: *"Spawn a team of 3 to add three small independent endpoints - one each; one lead coordinates."*
Manual version: `demos/worktrees/setup-worktrees.ps1` + `TASKS.md`. Visual: `agent-office-dashboard.html`.

---

We'll go tip by tip. Start with STEP 0 and Tip 1, paste me what happens.
