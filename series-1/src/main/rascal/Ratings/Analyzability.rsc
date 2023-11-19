module Ratings::Analyzability

import Ranking::Ranking;

// Includes the Volume, Duplication, Unit Size
public Ranking getAnalyzabilityRating(Ranking manYearRanking,
                                    Ranking duplicationRanking,
                                    Ranking unitSizeRanking) {
    list[Ranking] metricRankings = [manYearRanking, duplicationRanking, unitSizeRanking];

    return averageRanking(metricRankings);
}