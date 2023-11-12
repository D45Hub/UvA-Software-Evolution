module Ratings::Changeability

import lang::java::m3::Core;
import lang::java::m3::AST;

import MetricsHelper::DuplicationHelper;
import CyclomaticComplexity::ComplexityHelper;
import Ranking::Ranking;
import UnitSize::UnitSize;
import MetricsHelper::LOCHelper;

// Duplication, Unit Complexity 

public Ranking getChangabilityRating(M3 projectModel, list[Declaration] declMethods) {

    int linesOfCodeAmount = getLinesOfCodeAmount(projectModel);
    DuplicationRanking duplicationRanking = getDuplicationRanking(projectModel, linesOfCodeAmount);
    ComplexityRanking complexityRanking = calculateComplexityRanking(declMethods);

    list[Ranking] metricRankings = [duplicationRanking.rankingType, complexityRanking.rankingType];

    return averageRanking(metricRankings);
}