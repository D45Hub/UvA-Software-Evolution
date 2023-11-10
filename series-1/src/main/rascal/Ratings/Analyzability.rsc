module Ratings::Analyzability

import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume::ManYears;
import MetricsHelper::DuplicationHelper;
import UnitSize::UnitSize;
import Ranking::Ranking;

// Includes the Volume, Duplication, Unit Size


public Ranking getAnalyzabilityRating(M3 projectModel) {

    // TODO OPTIMISE LOC... PUT THIS EITHER IN MAIN METHOD OR IN FACTORY...
    int linesOfCodeAmount = getLinesOfCodeAmount(projectModel);
    MYRanking manYearRanking = getManYearsRanking(linesOfCodeAmount);
    DuplicationRanking duplicationRanking = getDuplicationRanking(projectModel, linesOfCodeAmount);
    UnitSizeRanking unitSizeRanking = calculateUnitSizeRanking(projectModel);

    // TODO THINK ABOUT HOW TO HANDLE UNIT TESTING...

    list[Ranking] metricRankings = [manYearRanking.rankingType, duplicationRanking.rankingType, unitSizeRanking.rankingType];

    return averageRanking(metricRankings);
}