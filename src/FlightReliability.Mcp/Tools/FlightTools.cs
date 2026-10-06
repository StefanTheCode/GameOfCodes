using System.ComponentModel;
using System.Text.Json;
using FlightReliability.Domain;
using ModelContextProtocol.Server;

namespace FlightReliability.Mcp.Tools;

[McpServerToolType]
public static class FlightTools
{
    [McpServerTool, Description("Returns the least reliable flights (lowest on-time %), worst first, with a reliability band.")]
    public static string GetFlightsByReliability(
        [Description("How many flights to return.")] int limit = 10)
    {
        var rows = FlightData.Sample
            .OrderBy(f => f.OnTimePercentage)
            .Take(limit)
            .Select(f => new
            {
                f.FlightNumber,
                f.Origin,
                f.Destination,
                f.OnTimePercentage,
                f.AvgDelayMinutes,
                Band = ReliabilityCalc.ReliabilityBand(f.OnTimePercentage)
            });
        return JsonSerializer.Serialize(rows);
    }
}
