module Ratings::Analyzability


import Volume::ManYears;
import Duplication::Duplication;
import UnitSize::UnitSize;
import Ranking::Ranking;

// Includes the Volume, Duplication, Unit Size

// public Ranking getAnalyzabilityRating(
//                                     MYRanking manYearRanking,
//                                     DuplicationRanking duplicationRanking,
//                                     UnitSizeRankingValues unitSizeRanking) {

//     // TODO Include Unit Testing somehow (count asserts whatever)
//     return getAnalyzabilityRating(manYearRanking, duplicationRanking, unitSizeRanking);
// }

public Ranking getAnalyzabilityRating(MYRanking manYearRanking, DuplicationRanking duplicationRanking, UnitSizeRanking unitSizeRanking) {
    list[Ranking] metricRankings = [manYearRanking.rankingType, duplicationRanking.rankingType, unitSizeRanking.rankingType];

    return averageRanking(metricRankings);
}