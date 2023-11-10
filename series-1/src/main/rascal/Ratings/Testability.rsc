module Ratings::Testability

import lang::java::m3::Core;
import lang::java::m3::AST;

import UnitInterfacing::UnitInterfacingHelper;
import Ranking::Ranking;

// Unit Size, Unit Complexity

public Ranking getTestabilityRanking(M3 projectModel, list[Declaration] methodUnits) {

    UnitSizeRanking unitSizeRanking = calculateUnitSizeRanking(projectModel);
    ComplexityRanking complexityRanking = calculateComplexityRanking(declMethods);

    list[Ranking] metricRankings = [unitSizeRanking.rankingType, complexityRanking.rankingType];

    return averageRanking(metricRankings);
}