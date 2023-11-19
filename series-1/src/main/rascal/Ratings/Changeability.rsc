module Ratings::Changeability

import lang::java::m3::Core;
import lang::java::m3::AST;

import Ranking::Ranking;
import UnitSize::UnitSize;

// Duplication, Unit Complexity 
public Ranking getChangabilityRating(Ranking duplicationRanking, Ranking complexityRanking) {
    list[Ranking] metricRankings = [duplicationRanking, complexityRanking];

    return averageRanking(metricRankings);
}