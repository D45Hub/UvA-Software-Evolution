module Ratings::Analyzability

import Ranking::Ranking;

// Includes the Volume, Duplication, Unit Size

// public Ranking getAnalyzabilityRating(
//                                     MYRanking manYearRanking,
//                                     DuplicationRanking duplicationRanking,
//                                     UnitSizeRankingValues unitSizeRanking) {

//     // TODO Include Unit Testing somehow (count asserts whatever)
//     return getAnalyzabilityRating(manYearRanking, duplicationRanking, unitSizeRanking);
// }

public Ranking getAnalyzabilityRating(Ranking manYearRanking, Ranking duplicationRanking, Ranking unitSizeRanking) {
    list[Ranking] metricRankings = [manYearRanking, duplicationRanking, unitSizeRanking];

    return averageRanking(metricRankings);
}