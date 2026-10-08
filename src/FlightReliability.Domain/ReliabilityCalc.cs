namespace FlightReliability.Domain;

public static class ReliabilityCalc
{
    // Implemented - used by the API and the MCP server.
    public static string ReliabilityBand(double onTimePct) => onTimePct switch
    {
        < 0 => "unknown",
        >= 80 => "good",
        >= 50 => "average",
        _ => "poor"
    };

    // ===== HOOKS DEMO TARGET =====
    // The agent implements THIS live. Goal on stage: "keep going until all tests pass".
    public static string DelayRisk(int avgDelayMinutes)
        => avgDelayMinutes switch
        {
            < 0 => "unknown",
            >= 60 => "high",
            >= 30 => "medium",
            _ => "low"
        };
}