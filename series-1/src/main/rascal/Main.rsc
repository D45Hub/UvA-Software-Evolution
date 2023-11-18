module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume::LOCVolumeMetric;
import Volume::ManYears;
import Helper::ProjectHelper;
import Helper::BenchmarkHelper;
import Helper::ReportHelper;
import UnitSize::UnitSize;
import UnitSize::UnitSizeRanking;
import UnitInterfacing::UnitInterfacing;
import UnitTestingQuality::UnitTestingQuality;
import CyclomaticComplexity::CyclomaticComplexityRanking;
import CyclomaticComplexity::CyclomaticComplexity;
import Duplication::Duplication;
import UnitCoverage::UnitCoverage;
import IO;
import List; 
import util::FileSystem;
import Set;
import util::Math;
import Ratings::Analyzability;
import Ratings::Changeability;
import Ratings::Testability;
import Ranking::Ranking;

alias ProjectLocation = tuple[loc projectFolderLocation, loc unitCoverageReportLocation];

ProjectLocation smallSQLLocation = <|project://series-1/smallsql|, |project://nothing|>;
ProjectLocation smallEncryptorLocation = <|project://series-1/simpleencryptor|, |project://series-1/src/main/rsc/jacoco_simpleencryptor.csv|>;

void analyseSmallSQL() {
	analyseProject(smallSQLLocation, false);
}

void analyseEncryptorProject() {
	analyseProject(smallEncryptorLocation, true);
}

void analyseProject(ProjectLocation projectLocation, bool testUnitCoverage) {
	println("+----------------------------------+");
	println("|         Setting up Project       |");
	println("+----------------------------------+");

	M3 model = createM3FromMavenProject(projectLocation.projectFolderLocation);
	volume = getVolumeMetric(model);
	listOfLocations = toList(methods(model));
	linesOfCode = volume["Actual Lines of Code"];

	list[Declaration] declarations = [ createAstFromFile(file, true) | file <- toList(files(model))]; 
	list[Declaration] methods = [];

	for(int i <- [0 .. size(declarations)]) {
		methods = methods + [dec | /Declaration dec := declarations[i], dec is method || dec is constructor || dec is initializer];
	}
	
    complexityTuple = getCyclomaticRiskOverview(methods);  
	cyclomaticOverview = getCyclomaticRiskRating(linesOfCode, complexityTuple );
  	cyclomaticRanking = getCyclomaticRanking(complexityTuple, linesOfCode);

	// Unit Interfacing
	// Get all parameters
	allParamtersOfUnits = getUnitInterfacingValues(methods);
	// absolute lines of Code for Each category
	absoluteParameterCategories = getAbsolutRiskValues(allParamtersOfUnits);
	absoluteLinesOfCodePerCategorie = calculateAbsoluteRiskAmount(absoluteParameterCategories);
	relativeUnitAmounts = calculateRelativeRiskAmount(absoluteLinesOfCodePerCategorie);
	unitInterfaceRanking = getUnitInterfacingRanking(relativeUnitAmounts);

	println("+----------------------------------+");
	println("|         Volume Metrics           |");
	println("+----------------------------------+");
	println("Overall Lines");
	println(volume["Overall lines"]);
	println("Blank Lines");
	println(volume["Blank Lines"]);
	println("Comment Lines");
	println(volume["Comment Lines of Code"]);
	println("Actual Lines of Code");
	println(linesOfCode);
	println("Number of Methods");
	println(size(listOfLocations));
	println("|      Ranking With Man Years      |");
	manYearsRanking = getManYearsRanking(linesOfCode);
	println(manYearsRanking.rankingType.name);

	addToReport("Overall Lines of Code", " ", toString(volume["Overall lines"]));
	addToReport("Blank Lines", " ", toString(volume["Blank Lines"]));
	addToReport("Comment Lines", " ", toString(volume["Comment Lines of Code"]));
	addToReport("Actual Lines of Code", " ", toString(linesOfCode));
	addToReport("Number of Methods", " ", toString(size(listOfLocations)));
	addToReport("Man Years", manYearsRanking.rankingType, " ");

	println("+----------------------------------+");
	println("|         Unit Size                |");
	println("+----------------------------------+");
	map[str, UnitAmountPercentage] unitSizeRankingValues = calculateUnitSizeRankingValues(model, linesOfCode);
	str lowRiskUnitLinesString = toString(unitSizeRankingValues["low"].absoluteAmount) + " (" + toString(unitSizeRankingValues["low"].relativeAmount) + "%)";
	str moderateRiskUnitLinesString = toString(unitSizeRankingValues["moderate"].absoluteAmount) + " (" + toString(unitSizeRankingValues["moderate"].relativeAmount) + "%)";
	str highRiskUnitLinesString = toString(unitSizeRankingValues["high"].absoluteAmount) + " (" + toString(unitSizeRankingValues["high"].relativeAmount) + "%)";
	str veryHighUnitLinesString = toString(unitSizeRankingValues["veryHigh"].absoluteAmount) + " (" + toString(unitSizeRankingValues["veryHigh"].relativeAmount) + "%)";
	println("Low risk lines: " + lowRiskUnitLinesString);
    println("Moderate risk lines: " + moderateRiskUnitLinesString);
    println("High risk lines: " + highRiskUnitLinesString);
    println("Very high risk lines: " + veryHighUnitLinesString);
	UnitSizeRankingValues unitSizeRanking = getUnitSizeRankings(unitSizeRankingValues);
	println(unitSizeRanking);

	addToReport("Low risk lines in units", " ", lowRiskUnitLinesString);
	addToReport("Moderate risk lines in units", " ", moderateRiskUnitLinesString);
	addToReport("High risk lines", " ", highRiskUnitLinesString);
	addToReport("Very high risk lines", " ", veryHighUnitLinesString);
	addToReport("Unit Size Rating", unitSizeRanking.rankingType, toString(unitSizeRanking.moderateRisk) + "%, " + toString(unitSizeRanking.highRisk) + "%, " + toString(unitSizeRanking.veryHighRisk) + "%");

	println("+----------------------------------+");
	println("|      Unit Complexity             |");
	println("+----------------------------------+");

	str lowRiskComplexityLinesString = toString(complexityTuple.low) + " lines (" + toString(cyclomaticOverview["low"]) + " %)";
	str moderateComplexityUnitLinesString = toString(complexityTuple.moderate) + " lines (" + toString(cyclomaticOverview["moderate"]) + " %)";
	str highRiskComplexityLinesString = toString(complexityTuple.high) + " lines (" + toString(cyclomaticOverview["high"]) + " %)";
	str veryHighComplexityLinesString = toString(complexityTuple.veryHigh) + " lines (" + toString(cyclomaticOverview["veryHigh"]) + " %)";

	println("|      Low  Risk Units             |");
	println(lowRiskComplexityLinesString);
	println("|      Moderate  Risk Units        |");
	println(moderateComplexityUnitLinesString);
	println("|      High  Risk Units            |");
	println(highRiskComplexityLinesString);
	println("|      Very High Risk Units        |");
	println("| " + veryHighComplexityLinesString + " |");
	println("|      Overall Ranking             |");
	println(cyclomaticRanking.rankingType.name);

	addToReport("Low risk lines in units", " ", lowRiskComplexityLinesString);
	addToReport("Moderate risk lines in units", " ", moderateComplexityUnitLinesString);
	addToReport("High risk lines", " ", highRiskComplexityLinesString);
	addToReport("Very high risk lines", " ", veryHighComplexityLinesString);
	addToReport("Unit Size Rating", cyclomaticRanking.rankingType, toString(cyclomaticRanking.moderateRisk) + "%, " + toString(cyclomaticRanking.highRisk) + "%, " + toString(cyclomaticRanking.veryHighRisk) + "%");


	println("+----------------------------------+");
	println("|      Unit Interfacing            |");
	println("+----------------------------------+");
	println("|      Low  Risk Units             |");
	println("|      Moderate  Risk Units        |");
	println("|      High  Risk Units            |");
	println("|      Very High  Risk Units       |");
	println("+----------------------------------+");
	println("Overall Interfacing");
	println(unitInterfaceRanking);
	println("Relative Amount");
	println(absoluteLinesOfCodePerCategorie);
	println(relativeUnitAmounts);


	println("+----------------------------------+");
	println("|      Duplication                 |");
	println("+----------------------------------+");
	println("• Duplicated Lines ");
	int duplicatedLines = getDuplicatedLines(model);
	println(duplicatedLines);
	println("• Duplication Percentage ");
	real duplicationPercentage = getDuplicationPercentage(duplicatedLines, volume["Actual Lines of Code"]);
	println(duplicationPercentage);
	println("• Duplication Ranking ");
	duplicationRanking = getDuplicationRanking(duplicationPercentage);
	println(duplicationRanking.rankingType.name);
	
	println("+----------------------------------+");
	println("|      Analyzability               |");
	println("+----------------------------------+");
	analyzabilityRating = getAnalyzabilityRating(manYearsRanking.rankingType, duplicationRanking.rankingType, unitSizeRanking.rankingType);
	println(analyzabilityRating);


	changeabilityRating = getChangabilityRating(duplicationRanking.rankingType, cyclomaticRanking.rankingType);
	println("+----------------------------------+");
	println("|      Changeability               |");
	println("+----------------------------------+");
	println(changeabilityRating.name);

	println("+----------------------------------+");
	println("|      Testability                 |");
	println("+----------------------------------+");
	testabilityRating = getTestabilityRanking(unitSizeRanking.rankingType, cyclomaticRanking.rankingType);
	testClasses = getTestFilesOfProject(listOfLocations);
	moreTest = getTestClasses(testClasses);
	println("testability ranking");
	println(testabilityRating.name);
	assertions = 0;
	for (testClass <- moreTest) {
		assertions = assertions + getAssertionForMethod(testClass);
	}

	println("Sum of Assertions");
	println(assertions);
	println("Amount of methods in project");
	println(size(listOfLocations));


	println("+----------------------------------+");
	println("|      Overall Maintainability     |");
	println("+----------------------------------+");
	println("TestabilityRanking + ChangeabilityRanking + Analyzability Ranking / 3");
	overallMaintainability = ((testabilityRating.val
							+ changeabilityRating.val
							+ analyzabilityRating.val) / 3);
	overallMaintainabilityRankingName = [finalRanking| finalRanking <- allRankings, finalRanking.val == overallMaintainability];
	println(overallMaintainabilityRankingName[0].name);

	if(testUnitCoverage) {
		println("+----------------------------------+");
		println("|         Unit Coverage            |");
		println("+----------------------------------+");
		formatOverallStatistics(projectLocation.unitCoverageReportLocation);
		formatClassStatistics(projectLocation.unitCoverageReportLocation);
	}

	writeCSVReport();
}