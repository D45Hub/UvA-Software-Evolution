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
import List;
import util::Math;
import GeneralHelper::TimeHelper;
import Map;


void mandatoryMetric() {
    startMeasure("Overall");

    M3 model = createM3FromMavenProject(|file:///Users/ekletsko/Downloads/smallsql0.21_src|);

    println("Starting measure the mandatory stuff");
    println("Volume");

    startMeasure("unitDeclarations");
    list[Declaration] unitDeclarations = getProjectUnits(model);
    stopMeasure("unitDeclarations");
    startMeasure("linesOfCode");
    list[str] linesOfCode = getLinesOfCode(model);

    
    stopMeasure("linesOfCode");

    println("V O L U M E");
    map[str, int] volumeMetric = getVolumeMetric(model);
    println(volumeMetric);
    addToReport("Volume Metric", toString(volumeMetric));

    println("U N I T D E C L A R A T I O N S");
    println(size(unitDeclarations));

    addToReport("Number of Methods", toString(size(unitDeclarations)));

    println("Man Years");
    startMeasure("ManYears");
    MYRanking manYearRanking = getManYearsRanking(volumeMetric["Actual Lines of Code"]);
    stopMeasure("ManYears");
    addToReport("Man Years", manYearRanking.rankingType);
    println(manYearRanking);

    println("Unit Size");
    startMeasure("unitSize");
    UnitSizeValue unitSizeRankingValue = calculateUnitSizeRankingValues(model);
    startMeasure("stopMeasure");
    UnitSizeRanking unitSizeRanking = unitSizeRankingValue.unitSizeRanking;
    addToReport("Unit Size", unitSizeRanking.rankingType.name, toString(unitSizeRankingValue.averageUnitSizeLOC));
    println(unitSizeRankingValue);

    println("Duplication");
    startMeasure("duplication");
    DuplicationValue duplicationRankingValue = getDuplicationRankingValue(model, volumeMetric["Actual Lines of Code"]);
    stopMeasure("duplication");
    DuplicationRanking duplicationRanking = duplicationRankingValue.duplicationRanking;
    println(duplicationRankingValue);
    addToReport("Duplication", duplicationRanking.rankingType.name, toString(duplicationRankingValue.duplicationPercentage));

    println("Unit Complexity");
    startMeasure("complexity");
    ComplexityValue complexityRankingValue = calculateComplexityRanking(unitDeclarations);
    stopMeasure("complexity");
    ComplexityRanking complexityRanking = complexityRankingValue.complexityRanking;
    addToReport("Complexity", complexityRanking.rankingType.name, stringifyRiskOverview(complexityRankingValue.complexityPercentages));
    println(complexityRankingValue);


    Ranking analyzabilityRanking = getAnalyzabilityRating(manYearRanking, duplicationRanking, unitSizeRanking);
    Ranking changabilityRanking = getChangabilityRating(duplicationRanking, complexityRanking);
    //Ranking stabilityRanking = getStabilityRanking(unitInterfacingRisk); 
    Ranking testabilityRanking = getTestabilityRanking(unitSizeRanking, complexityRanking);
    overallMaintainability = ((analyzabilityRanking.val + changabilityRanking.val + testabilityRanking.val ) / 4);
    addToReport("Overall Maintainability", toString(overallMaintainability));

    writeCSVReport();
    stopMeasure("Overall");

}
void main() {
    // TODO ADD OTHER METRICS TO THE REPORT WITH VALUES???


    // MYRanking manYearRanking = getManYearsRanking(linesOfCodeAmount);
    // println(manYearRanking);
    // DuplicationRanking duplicationRanking = getDuplicationRanking(model, linesOfCodeAmount);
    // println(duplicationRanking);

    // UnitSizeRanking unitSizeRanking = calculateUnitSizeRanking(model);
    // println(unitSizeRanking);

    // TODO really slow, maybe some optimization?
    // ComplexityRanking complexityRanking = calculateComplexityRanking(unitDeclarations);
    // println(complexityRanking);

    // RiskThreshold unitInterfacingRisk = generateRiskThreshold(unitDeclarations);
    // println(unitInterfacingRisk);

    // Ranking analyzabilityRanking = getAnalyzabilityRating(manYearRanking, duplicationRanking, unitSizeRanking);
    // Ranking changabilityRanking = getChangabilityRating(duplicationRanking, complexityRanking);
    // Ranking stabilityRanking = getStabilityRanking(unitInterfacingRisk); 
    // Ranking testabilityRanking = getTestabilityRanking(unitSizeRanking, complexityRanking);

    // TODO ADD MAYBE MORE DETAILED NUMBERS BY EXPANDING THE RANKING OBJECTS...
    // addToReport("Lines of Code", toString(linesOfCodeAmount));
    // addToReport("Number of Methods", toString(size(unitDeclarations)));
    // addToReport("Analyzability", analyzabilityRanking);
    // addToReport("Changeability", changabilityRanking);
    // addToReport("Stability", stabilityRanking);
    // addToReport("Testability", testabilityRanking);
    // addToReport("Man Years", manYearRanking.rankingType);
    // addToReport("Duplication", duplicationRanking.rankingType);
    // addToReport("Unit Size", unitSizeRanking.rankingType);
    // addToReport("Complexity", complexityRanking.rankingType);
    // addToReport("Unit Interfacing", unitInterfacingRisk.rankLevel);


    writeCSVReport();
}