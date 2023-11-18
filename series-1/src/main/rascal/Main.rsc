module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume::LOCVolumeMetric;
import Volume::ManYears;
import Helper::ProjectHelper;
import Helper::BenchmarkHelper;
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
import Ranking::Ranking;

public Ranking getTestabilityRanking(UnitSizeRiskRanking unitSizeRanking, ComplexityRanking complexityRanking) {
    println("Im here");
    list[Ranking] metricRankings = [unitSizeRanking.rankingType, complexityRanking.rankingType];

    println("before averging");
    return averageRanking(metricRankings);
}

alias ProjectLocation = tuple[loc projectFolderLocation, loc unitCoverageReportLocation];

ProjectLocation smallSQLLocation = <|file:///Users/ekletsko/Downloads/smallsql0.21_src|, |project://nothing|>;
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



	println("+----------------------------------+");
	println("|         Unit Size                |");
	println("+----------------------------------+");
	map[str, UnitAmountPercentage] unitSizeRankingValues = calculateUnitSizeRankingValues(model, linesOfCode);
	println("Low risk lines: " + toString(unitSizeRankingValues["low"].absoluteAmount) + " (" + toString(unitSizeRankingValues["low"].relativeAmount) + "%)");
    println("Moderate risk lines: " + toString(unitSizeRankingValues["moderate"].absoluteAmount) + " (" + toString(unitSizeRankingValues["moderate"].relativeAmount) + "%)");
    println("High risk lines: " + toString(unitSizeRankingValues["high"].absoluteAmount) + " (" + toString(unitSizeRankingValues["high"].relativeAmount) + "%)");
    println("Very high risk lines: " + toString(unitSizeRankingValues["veryHigh"].absoluteAmount) + " (" + toString(unitSizeRankingValues["veryHigh"].relativeAmount) + "%)");
	UnitSizeRankingValues unitSizeRanking = getUnitSizeRankings(unitSizeRankingValues);
	println(unitSizeRanking);

	println("+----------------------------------+");
	println("|      Unit Complexity             |");
	println("+----------------------------------+");

	println("|      Low  Risk Units             |");
	println(toString(complexityTuple.low) + " lines (" + toString(cyclomaticOverview["low"]) + " %)");
	println("|      Moderate  Risk Units        |");
	println(toString(complexityTuple.moderate) + " lines (" + toString(cyclomaticOverview["moderate"]) + " %)");
	println("|      High  Risk Units            |");
	println(toString(complexityTuple.high) + " lines (" + toString(cyclomaticOverview["high"]) + " %)");
	println("|      Very High Risk Units        |");
	println("| " + toString(complexityTuple.veryHigh) + " lines (" + toString(cyclomaticOverview["veryHigh"]) + " %) |");
	println("|      Overall Ranking             |");
	println(cyclomaticRanking.rankingType.name);

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
	// TODO Don't know, fix the type issue.
	//println(getAnalyzabilityRating(manYearsRanking,duplicationRanking,unitSizeRanking));


	changeabilityRating = getChangabilityRating(duplicationRanking, cyclomaticRanking);
	println("+----------------------------------+");
	println("|      Changeability               |");
	println("+----------------------------------+");
	println(changeabilityRating.name);

	println("+----------------------------------+");
	println("|      Testability                 |");
	println("+----------------------------------+");
	// TODO Fix the code, cause the call is somehow failing...
	//testabilityRating = getTestabilityRanking(unitSizeRanking,cyclomaticRanking);
	testClasses = getTestFilesOfProject(listOfLocations);
	moreTest = getTestClasses(testClasses);
	println("testability ranking");
	println(testabilityRating.name);
	assertions = 0;
	for (testClass <- moreTest) {
		assertions = assertions + getAssertionForMethod(testClass);
	}

	println("sum assertions");
	println(assertions);
	println("amount of methods in project");
	println(size(listOfLocations));

	if(testUnitCoverage) {
		println("+----------------------------------+");
		println("|         Unit Coverage            |");
		println("+----------------------------------+");
		formatOverallStatistics(projectLocation.unitCoverageReportLocation);
		formatClassStatistics(projectLocation.unitCoverageReportLocation);
	}
}