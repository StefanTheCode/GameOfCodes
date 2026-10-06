namespace FlightReliability.Domain;

public static class ReliabilityCalc
{
    // Implemented - used by the API and the MCP server.
    public static string ReliabilityBand(double onTimePct) => onTimePct switch
    {
        < 0    => "unknown",
        >= 80  => "good",
        >= 50  => "average",
        _      => "poor"
    };

    // ===== HOOKS DEMO TARGET =====
    // The agent implements THIS live. The spec you give it on stage omits the negative case,
    // so its first pass fails the "negative -> unknown" test and the Stop hook bounces it.
    // Spec to give the agent:  ">= 60 => high, >= 30 => medium, otherwise low".
    public static string DelayRisk(int avgDelayMinutes)
        => throw new NotImplementedException();
}
