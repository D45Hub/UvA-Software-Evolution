module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import GeneralHelper::ProjectHelper;
import MetricsHelper::DuplicationHelper;
import CyclomaticComplexity::ComplexityHelper;
import UnitInterfacing::UnitInterfacingHelper;
import GeneralHelper::ReportHelper;
import Ratings::Analyzability;
import Ratings::Changeability;
import Ratings::Stability;
import Ratings::Testability;
import Ranking::Ranking;
import IO;

void main() {

    M3 model = createM3FromMavenProject(|file:///some/project|);
    list[Declaration] unitDeclarations = getProjectUnits(model);

    Ranking analyzabilityRanking = getAnalyzabilityRating(model);
    Ranking changabilityRanking = getChangabilityRating(model, unitDeclarations);
    Ranking stabilityRanking = getStabilityRanking(model, unitDeclarations); 
    Ranking testabilityRanking = getTestabilityRanking(model, unitDeclarations);

    // TODO ADD OTHER METRICS TO THE REPORT WITH VALUES???
    // THINK HOW ESPECIALLY... WE DONT WANT TO DUPLICATE CALCULATION.

    addToReport("Analyzability", analyzabilityRanking);
    addToReport("Changability", changabilityRanking);
    addToReport("Stability", stabilityRanking);
    addToReport("Testability", testabilityRanking);

    writeCSVReport();
}
