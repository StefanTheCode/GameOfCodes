namespace FlightReliability.Mcp;

public record FlightRow(string FlightNumber, string Origin, string Destination, double OnTimePercentage, int AvgDelayMinutes);

public static class FlightData
{
    public static readonly FlightRow[] Sample =
    [
        new("JU512",  "BEG", "ZRH", 62.4, 41),
        new("LH1411", "BEG", "MUC", 71.0, 28),
        new("OU441",  "BEG", "ZAG", 58.9, 52),
        new("W64311", "BEG", "LTN", 46.2, 73),
        new("TK1082", "BEG", "IST", 83.5, 14),
        new("AF1537", "BEG", "CDG", 77.1, 22),
        new("SU2093", "BEG", "SVO", 51.3, 61),
        new("EW8762", "BEG", "STR", 68.8, 33),
    ];
}
