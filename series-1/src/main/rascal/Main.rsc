module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import GeneralHelper::ProjectHelper;
import MetricsHelper::DuplicationHelper;
import CyclomaticComplexity::ComplexityHelper;
import UnitInterfacing::UnitInterfacingHelper;
import GeneralHelper::ReportHelper;
import Volume::ManYears;
import UnitSize::UnitSize;
import Ratings::Analyzability;
import Ratings::Changeability;
import Ratings::Stability;
import Ratings::Testability;
import MetricsHelper::LOCHelper;
import Ranking::Ranking;
import Ranking::RiskRanges;
import IO;
import String;

void main() {

    M3 model = createM3FromMavenProject(|file:///test|);
    list[Declaration] unitDeclarations = getProjectUnits(model);
    int linesOfCodeAmount = getLinesOfCodeAmount(model);

    MYRanking manYearRanking = getManYearsRanking(linesOfCodeAmount);
    DuplicationRanking duplicationRanking = getDuplicationRanking(model, linesOfCodeAmount);
    UnitSizeRanking unitSizeRanking = calculateUnitSizeRanking(model);
    ComplexityRanking complexityRanking = calculateComplexityRanking(unitDeclarations);
    RiskThreshold unitInterfacingRisk = generateRiskThreshold(unitDeclarations);

    Ranking analyzabilityRanking = getAnalyzabilityRating(manYearRanking, duplicationRanking, unitSizeRanking);
    Ranking changabilityRanking = getChangabilityRating(duplicationRanking, complexityRanking);
    Ranking stabilityRanking = getStabilityRanking(unitInterfacingRisk); 
    Ranking testabilityRanking = getTestabilityRanking(unitSizeRanking, complexityRanking);

    // TODO ADD OTHER METRICS TO THE REPORT WITH VALUES???

    // TODO ADD MAYBE MORE DETAILED NUMBERS BY EXPANDING THE RANKING OBJECTS...
    addToReport("Analyzability", analyzabilityRanking);
    addToReport("Changability", changabilityRanking);
    addToReport("Stability", stabilityRanking);
    addToReport("Testability", testabilityRanking);
    addToReport("Man Years", manYearRanking.rankingType);
    addToReport("Duplication", duplicationRanking.rankingType);
    addToReport("Unit Size", unitSizeRanking.rankingType);
    addToReport("Complexity", complexityRanking.rankingType);
    addToReport("Unit Interfacing", unitInterfacingRisk.rankLevel);
    addToReport("Lines of Code", toString(linesOfCodeAmount));
    addToReport("Number of Methods", toString(size(unitDeclarations)));

    writeCSVReport();
}
