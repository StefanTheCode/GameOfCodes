# AGENTS.md - Flight Reliability (demo)

Portable context any agent reads (Claude Code reads CLAUDE.md; `ln -s AGENTS.md CLAUDE.md`, or keep both).

## Project
Flight Reliability - .NET 10. `src/FlightReliability.Domain` (logic), `src/FlightReliability.Api`
(Minimal API, in-memory sample data - no database needed), `src/FlightReliability.Mcp` (optional C# MCP),
`tests/FlightReliability.Tests` (xUnit).

## Commands
- Build: `dotnet build`
- Test: `dotnet test tests/FlightReliability.Tests`
- Run API: `dotnet run --project src/FlightReliability.Api`

## Conventions
- Minimal APIs, no MediatR. File-scoped namespaces. Nullable + ImplicitUsings on.
- "Done" means the tests pass (enforced by the Stop hook).
- Do not edit files under `tests/` - fix the code, not the test (enforced by a hook).
