module Ratings::Testability



import UnitInterfacing::UnitInterfacing;
import Ranking::Ranking;
import CyclomaticComplexity::CyclomaticComplexity;
import CyclomaticComplexity::CyclomaticComplexityRanking;
import UnitSize::UnitSize;
import IO;
// Unit Size, Unit Complexity, Unit Testing


public Ranking getTestabilityRanking(UnitSizeRiskRanking unitSizeRanking, ComplexityRanking complexityRanking) {
    println("Im here");
    list[Ranking] metricRankings = [unitSizeRanking.rankingType, complexityRanking.rankingType];

    println("before averging");
    return averageRanking(metricRankings);
}