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

alias ProjectLocation = tuple[loc projectFolderLocation,
							loc unitCoverageReportLocation];

ProjectLocation smallSQLLocation = <|file:///Users/ekletsko/Downloads/smallsql0.21_src|, |project://nothing|>;
ProjectLocation hSQLDBLocation = <|project://series-1/hsqldb|, |project://nothing|>;
ProjectLocation smallEncryptorLocation = <|project://series-1/simpleencryptor|,
 										|project://series-1/src/main/rsc/jacoco_simpleencryptor.csv|>;

void analyseSmallSQL() {
	analyseProject(smallSQLLocation, false);
}

void analyseHSQLDB() {
	analyseProject(hSQLDBLocation, false);
}

void analyseEncryptorProject() {
	analyseProject(smallEncryptorLocation, true);
}

void analyseProject(ProjectLocation projectLocation, bool testUnitCoverage) {
	println("+----------------------------------+");
	println("|         Setting up Project       |");
	println("+----------------------------------+");
	str benchmarkStartTime = startBenchmark("Overall Analyse Time");


	M3 model = createM3FromMavenProject(projectLocation.projectFolderLocation);
	volume = getVolumeMetric(model);
	listOfLocations = toList(methods(model));
	linesOfCode = volume["Actual Lines of Code"];

	list[Declaration] declarations = [ createAstFromFile(file, true) | file <- toList(files(model))]; 
	list[Declaration] methods = [];

	for(int i <- [0 .. size(declarations)]) {
		methods = methods + [dec | /Declaration dec := declarations[i],
								dec is method ||
								dec is constructor 
								|| dec is initializer];
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
	println("|         Volume Metric            |");
	println("+----------------------------------+");
	println("Overall Lines " + toString(volume["Overall lines"]));
	println("Blank Lines: " + toString(volume["Blank Lines"]));
	println("Comment Lines: " + toString(volume["Comment Lines of Code"]));
	println("Actual Lines of Code: " + toString(linesOfCode));
	println("Number of Methods: " + toString(size(listOfLocations)));
	manYearsRanking = getManYearsRanking(linesOfCode);
	println("Man Years Ranking: " + manYearsRanking.rankingType.name);
	println("+----------------------------------+");
	addToReport("Overall Lines of Code", "", toString(volume["Overall lines"]));
	addToReport("Blank Lines", "", toString(volume["Blank Lines"]));
	addToReport("Comment Lines", "", toString(volume["Comment Lines of Code"]));
	addToReport("Actual Lines of Code", "", toString(linesOfCode));
	addToReport("Number of Methods", "", toString(size(listOfLocations)));
	addToReport("Man Years", manYearsRanking.rankingType, "");

	println("+----------------------------------+");
	println("|         Unit Size                |");
	println("+----------------------------------+");
	map[str, UnitAmountPercentage] unitSizeRankingValues = calculateUnitSizeRankingValues(model, linesOfCode);
	str lowRiskUnitLinesString = toString(unitSizeRankingValues["low"].absoluteAmount)
								+ " (" + toString(unitSizeRankingValues["low"].relativeAmount)
								+ "%)";
	str moderateRiskUnitLinesString = toString(unitSizeRankingValues["moderate"].absoluteAmount) 
									+ " (" + toString(unitSizeRankingValues["moderate"].relativeAmount)
									+ "%)";
	str highRiskUnitLinesString = toString(unitSizeRankingValues["high"].absoluteAmount)
									+ " (" + toString(unitSizeRankingValues["high"].relativeAmount) 
									+ "%)";
	str veryHighUnitLinesString = toString(unitSizeRankingValues["veryHigh"].absoluteAmount)
									+ " (" + toString(unitSizeRankingValues["veryHigh"].relativeAmount)
									+ "%)";

	println("Low risk lines: " + lowRiskUnitLinesString);
    println("Moderate risk lines: " + moderateRiskUnitLinesString);
    println("High Risk unit lines: " + highRiskUnitLinesString);
    println("Very high risk lines: " + veryHighUnitLinesString);
	UnitSizeRankingValues unitSizeRanking = getUnitSizeRankings(unitSizeRankingValues);
	println("Overall Unit Size Ranking: " +unitSizeRanking.rankingType.name);
	println("+----------------------------------+");

	addToReport("Low risk lines in units", "", lowRiskUnitLinesString);
	addToReport("Moderate risk lines in units", "", moderateRiskUnitLinesString);
	addToReport("High risk lines in units", "", highRiskUnitLinesString);
	addToReport("Very high risk lines in units", "", veryHighUnitLinesString);
	addToReport("Unit Size Rating",
				unitSizeRanking.rankingType,
	 			toString(unitSizeRanking.moderateRisk)
				+ "%, " + toString(unitSizeRanking.highRisk)
				+ "%, " + toString(unitSizeRanking.veryHighRisk)
				+ "%");

	println("+----------------------------------+");
	println("|      Unit Complexity             |");
	println("+----------------------------------+");

	str lowRiskComplexityLinesString = toString(complexityTuple.low)
	 									+ " lines (" 
										+ toString(cyclomaticOverview["low"])
										+ " %)";
	str moderateComplexityUnitLinesString = toString(complexityTuple.moderate)
									 	+ " lines (" 
										+ toString(cyclomaticOverview["moderate"])
										+ " %)";
	str highRiskComplexityLinesString = toString(complexityTuple.high)
										+ " lines ("
										+ toString(cyclomaticOverview["high"])
										+ " %)";
	str veryHighComplexityLinesString = toString(complexityTuple.veryHigh)
										+ " lines ("
										+ toString(cyclomaticOverview["veryHigh"]) 
										+ " %)";

	getLinesAndPercentagesPrint("Low Risk Units:",
								complexityTuple.low,
								cyclomaticOverview["low"]);

	getLinesAndPercentagesPrint("Moderate Risk Units:",
								complexityTuple.moderate,
								cyclomaticOverview["moderate"]);
	getLinesAndPercentagesPrint("High Risk Units:",
								complexityTuple.high,
								cyclomaticOverview["high"]);
	getLinesAndPercentagesPrint("High Risk Units:",
								complexityTuple.veryHigh,
								cyclomaticOverview["veryHigh"]);
	println("Overall Complexity Ranking: " +cyclomaticRanking.rankingType.name);
	println("+----------------------------------+");

	addToReport("Low complexity lines in units",
	 			"",
				lowRiskComplexityLinesString);
	addToReport("Moderate complexity lines in units",
				"",
				moderateComplexityUnitLinesString);
	addToReport("High complexity lines in units",
	 			"",
				highRiskComplexityLinesString);
	addToReport("Very complexity risk lines in units",
				"",
				veryHighComplexityLinesString);
	addToReport("Unit Size Rating",
	 			cyclomaticRanking.rankingType,
				toString(cyclomaticRanking.moderateRisk) + "%,
				" + toString(cyclomaticRanking.highRisk) + "%,
				" + toString(cyclomaticRanking.veryHighRisk) + "%");


	println("+----------------------------------+");
	println("|      Unit Interfacing            |");
	println("+----------------------------------+");
	getLinesAndPercentagesPrint("Low Risk Units:",
								absoluteLinesOfCodePerCategorie["lowRisk"],
								relativeUnitAmounts["lowRisk"]);

	getLinesAndPercentagesPrint("Moderate Risk Units:",
								absoluteLinesOfCodePerCategorie["moderateRisk"],
								relativeUnitAmounts["moderateRisk"]);

	getLinesAndPercentagesPrint("High Risk Units:",
								absoluteLinesOfCodePerCategorie["highRisk"],
								relativeUnitAmounts["highRisk"]);

	getLinesAndPercentagesPrint("Very High Risk Units:",
								absoluteLinesOfCodePerCategorie["veryHighRisk"],
								relativeUnitAmounts["veryHighRisk"]);

	println(" Overall Interfacing Ranking "
	 		+ unitInterfaceRanking.rankingType.name);
	println("+----------------------------------+");

	addToReport("Low unit interface risk lines", "",
				toString(absoluteLinesOfCodePerCategorie["lowRisk"]));
	addToReport("Moderate unit interface risk lines", "",
				toString(absoluteLinesOfCodePerCategorie["moderateRisk"]));
	addToReport("High unit interface risk lines", "",
				toString(absoluteLinesOfCodePerCategorie["highRisk"]));
	addToReport("Very high unit interface risk lines", "",
	 			toString(absoluteLinesOfCodePerCategorie["veryHighRisk"]));

	addToReport("Unit Interfacing Percentages",
				"",
				toString(relativeUnitAmounts["lowRisk"]) + "%, " + 
				toString(relativeUnitAmounts["moderateRisk"]) + "%, " +
				toString(relativeUnitAmounts["highRisk"]) + "%, " +
				toString(relativeUnitAmounts["veryHighRisk"]) + "%");
	addToReport("Unit Interfacing Ranking", unitInterfaceRanking.rankingType);

	println("+----------------------------------+");
	println("|      Duplication                 |");
	println("+----------------------------------+");
	int duplicatedLines = getDuplicatedLines(model);
	println("Duplicated Lines: " + toString(duplicatedLines));
	real duplicationPercentage = getDuplicationPercentage(duplicatedLines, 
								volume["Actual Lines of Code"]);
	println("Duplication Percentage: " + toString(duplicationPercentage));
	duplicationRanking = getDuplicationRanking(duplicationPercentage);
	println("Duplication Ranking: " + duplicationRanking.rankingType.name);
	println("+----------------------------------+");

	addToReport("Duplication Lines", "", toString(duplicatedLines));
	addToReport("Duplication Percentage", "", toString(duplicationPercentage));
	addToReport("Duplication Ranking", duplicationRanking.rankingType);
	
	println("+----------------------------------+");
	println("|      Overall Ratings             |");
	println("+----------------------------------+");
	analyzabilityRating = getAnalyzabilityRating(manYearsRanking.rankingType,
												duplicationRanking.rankingType,
												unitSizeRanking.rankingType);
	println("Analyzability Ranking " + analyzabilityRating.name);
	addToReport("Analyzability Ranking", analyzabilityRating);

	changeabilityRating = getChangabilityRating(duplicationRanking.rankingType,
												cyclomaticRanking.rankingType);
	println("Changability Ranking: " + changeabilityRating.name);
	addToReport("Changeability Ranking", changeabilityRating);
	testabilityRating = getTestabilityRanking(unitSizeRanking.rankingType,
											cyclomaticRanking.rankingType);
	testClasses = getTestFilesOfProject(listOfLocations);
	moreTest = getTestClasses(testClasses);
	println("+----------------------------------+");
	println("Testability Ranking: " + testabilityRating.name);
	println("Overall Maintainability = (TestabilityRanking + ChangeabilityRanking + Analyzability Ranking) / 3");
	overallMaintainability = ((testabilityRating.val
							+ changeabilityRating.val
							+ analyzabilityRating.val) / 3);
	overallMaintainabilityRankingName = [finalRanking| finalRanking <- allRankings,
										finalRanking.val == overallMaintainability];
	println(overallMaintainabilityRankingName[0].name);


	assertions = 0;
	for (testClass <- moreTest) {
		assertions = assertions + getAssertionForMethod(testClass);
	}

	println("+----------------------------------+");
	println("|      Numbers for Test Quality    |");
	println("+----------------------------------+");
	println("Sum of Assertions");
	println(assertions);
	println("Amount of methods in project");
	println(size(listOfLocations));

	addToReport("Testability Ranking", testabilityRating);
	addToReport("Amount of Assertions", "", toString(assertions));
	addToReport("Amount of methods in the project", "", toString(size(listOfLocations)));
	addToReport("Overall Maintainability", overallMaintainabilityRankingName[0]);

	if(testUnitCoverage) {
		println("+----------------------------------+");
		println("|         Unit Coverage            |");
		println("+----------------------------------+");
		formatOverallStatistics(projectLocation.unitCoverageReportLocation);
		formatClassStatistics(projectLocation.unitCoverageReportLocation);
	}

	println("+----------------------------------+");
	println("|         End measuring time       |");
	println("+----------------------------------+");
	str benchmarkEndTime = stopBenchmark("Overall Analyse Time");

	addToReport("Benchmark start time", "", benchmarkStartTime);
	addToReport("Benchmark end time", "", benchmarkEndTime);

	writeCSVReport();
}