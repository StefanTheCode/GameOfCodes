using FlightReliability.Domain;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// In-memory sample data - no database needed for the demos.
var flights = Flights.Sample;

// The endpoint used for the REWIND demo ("add caching to this endpoint...").
app.MapGet("/flights/reliability", (int take = 20) =>
    flights.OrderBy(f => f.OnTimePercentage)
           .Take(take)
           .Select(f => new
           {
               f.FlightNumber,
               f.Origin,
               f.Destination,
               f.OnTimePercentage,
               f.AvgDelayMinutes,
               Band = ReliabilityCalc.ReliabilityBand(f.OnTimePercentage)
           }));

app.MapGet("/flights/{flightNumber}", (string flightNumber) =>
    flights.FirstOrDefault(f => f.FlightNumber == flightNumber) is { } f
        ? Results.Ok(f)
        : Results.NotFound());

app.Run();

public record Flight(
    string FlightNumber, string Origin, string Destination,
    double OnTimePercentage, int AvgDelayMinutes, int CancellationsLast30Days);

public static class Flights
{
    public static readonly List<Flight> Sample =
    [
        new("JU512",  "BEG", "ZRH", 62.4, 41, 3),
        new("LH1411", "BEG", "MUC", 71.0, 28, 1),
        new("OU441",  "BEG", "ZAG", 58.9, 52, 5),
        new("W64311", "BEG", "LTN", 46.2, 73, 8),
        new("TK1082", "BEG", "IST", 83.5, 14, 0),
        new("AF1537", "BEG", "CDG", 77.1, 22, 2),
        new("SU2093", "BEG", "SVO", 51.3, 61, 6),
        new("EW8762", "BEG", "STR", 68.8, 33, 2),
    ];
}
