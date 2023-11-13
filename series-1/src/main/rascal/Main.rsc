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



void mandatoryMetric() {
    startMeasure("Overall");

    M3 model = createM3FromMavenProject(|file:///Users/ekletsko/Downloads/hsqldb-2.3.1|);

    println("Starting measure the mandatory stuff");
    println("Volume");

    startMeasure("unitDeclarations");
    list[Declaration] unitDeclarations = getProjectUnits(model);
    stopMeasure("unitDeclarations");
    startMeasure("linesOfCode");
    int linesOfCodeAmount = getLinesOfCodeAmount(model);
    stopMeasure("linesOfCode");

    println(linesOfCodeAmount);
    println(size(unitDeclarations));

    addToReport("Lines of Code", toString(linesOfCodeAmount));
    addToReport("Number of Methods", toString(size(unitDeclarations)));

    println("Duplication");
    startMeasure("duplication");
    DuplicationRanking duplicationRanking = getDuplicationRanking(model, linesOfCodeAmount);
    stopMeasure("duplication");
    println(duplicationRanking);


    println("Man Years");
    startMeasure("ManYears");
    MYRanking manYearRanking = getManYearsRanking(linesOfCodeAmount);
    stopMeasure("ManYears");
    addToReport("Man Years", manYearRanking.rankingType);
    println(manYearRanking);


    println("Unit Size");
    startMeasure("unitSize");
    UnitSizeRanking unitSizeRanking = calculateUnitSizeRanking(model);
    startMeasure("stopMeasure");
    addToReport("Unit Size", unitSizeRanking.rankingType);
    println(unitSizeRanking);



    println("Unit Complexity");
    startMeasure("complexity");
    ComplexityRanking complexityRanking = calculateComplexityRanking(unitDeclarations);
    stopMeasure("complexity");
    addToReport("Complexity", complexityRanking.rankingType);
    println(complexityRanking);



    Ranking analyzabilityRanking = getAnalyzabilityRating(manYearRanking, duplicationRanking, unitSizeRanking);
    Ranking changabilityRanking = getChangabilityRating(duplicationRanking, complexityRanking);
    //Ranking stabilityRanking = getStabilityRanking(unitInterfacingRisk); 
    Ranking testabilityRanking = getTestabilityRanking(unitSizeRanking, complexityRanking);

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