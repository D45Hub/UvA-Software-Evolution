module Ratings::Testability

import Ranking::Ranking;

// Unit Size, Unit Complexity, Unit Testing
public Ranking getTestabilityRanking(Ranking unitSizeRanking, Ranking complexityRanking) {
    list[Ranking] metricRankings = [unitSizeRanking, complexityRanking];

    return averageRanking(metricRankings);
}