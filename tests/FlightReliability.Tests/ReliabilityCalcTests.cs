using FlightReliability.Domain;
using Xunit;

namespace FlightReliability.Tests;

public class ReliabilityCalcTests
{
    [Fact] public void Band_good()    => Assert.Equal("good",    ReliabilityCalc.ReliabilityBand(92));
    [Fact] public void Band_average() => Assert.Equal("average", ReliabilityCalc.ReliabilityBand(63));
    [Fact] public void Band_poor()    => Assert.Equal("poor",    ReliabilityCalc.ReliabilityBand(20));

    [Fact] public void Risk_high()    => Assert.Equal("high",    ReliabilityCalc.DelayRisk(75));
    [Fact] public void Risk_medium()  => Assert.Equal("medium",  ReliabilityCalc.DelayRisk(40));
    [Fact] public void Risk_low()     => Assert.Equal("low",     ReliabilityCalc.DelayRisk(10));

    [Fact] public void Risk_unknown_when_negative() => Assert.Equal("unknown", ReliabilityCalc.DelayRisk(-5));
}