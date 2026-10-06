# Three independent tasks (one per worktree - no shared files)

**Task 1 - fr-feat-1 (feat/healthcheck)**
> Add a `/health` endpoint to FlightReliability.Api that returns 200 with `{status:"ok"}`. Add a test.

**Task 2 - fr-feat-2 (feat/delay-stats)**
> Add `GET /flights/delays/summary` returning avg/max AvgDelayMinutes across all flights. LINQ, no new entity.

**Task 3 - fr-feat-3 (feat/openapi)**
> Add Swagger/OpenAPI to FlightReliability.Api and tag the endpoints. Don't change existing routing logic.

Different files → three agents can run at once without stepping on each other.
