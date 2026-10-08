# Hook Activity dashboard

A tiny .NET Minimal API that shows, in a clean panel, what the Claude Code hooks are
actually doing - so on stage you point at this instead of squinting at the CLI.

It is **real**: the `.claude/hooks/*.ps1` scripts append one line to
`.claude/hook-events.jsonl` every time they fire, and this page reads that file live.
Nothing is scripted or faked.

## Run it (two terminals)

Terminal 1 - the dashboard (from the FlightDemo root):

    dotnet run --project dashboard/HookDashboard

Then open http://localhost:5250  (put it on a second screen, next to your terminal).

Terminal 2 - your normal Claude Code demo in the FlightDemo folder. As the agent works,
events stream into the panel.

Port is 5250, so it does not clash with Performance Lab (5100/5200/5300).

## What shows up

- **Format C#** (PostToolUse) - "Formatted ReliabilityCalc.cs" when the agent writes a .cs file.
- **Test gate** (Stop) - "Running tests..." then either "Tests failing - agent sent back"
  (with Failed/Passed counts) or "All tests pass - agent may finish".
- **Protect tests** (PreToolUse) - "Blocked edit to a test file" when the agent tries to touch a test.

The top banner reflects the latest state (green = done, red = blocked, amber = working),
and each rule card glows when its hook just fired.

## Between takes

Click **Clear** on the page to empty the feed. (It calls `POST /clear`.) The log file is
git-ignored, so `git checkout -- .` for your code reset won't touch it.

## Notes

- Standalone on purpose: it is **not** in `FlightDemo.slnx`, so it never affects your main
  build or `dotnet test`.
- This is tip 1 (hooks) for now, built so we can add the other demos' events later.
