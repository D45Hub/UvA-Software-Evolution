module Ratings::Changeability

import lang::java::m3::Core;
import lang::java::m3::AST;

import Duplication::Duplication;
import CyclomaticComplexity::CyclomaticComplexityRanking;
import Ranking::Ranking;
import UnitSize::UnitSize;

// Duplication, Unit Complexity 

// public Ranking getChangabilityRating(DuplicationRanking duplicationRanking,
//                                     ComplexityRanking complexityRanking) {

//     return getChangabilityRating(duplicationRanking, complexityRanking);
// }

public Ranking getChangabilityRating(DuplicationRanking duplicationRanking, ComplexityRanking complexityRanking) {
    list[Ranking] metricRankings = [duplicationRanking.rankingType, complexityRanking.rankingType];

    return averageRanking(metricRankings);
}