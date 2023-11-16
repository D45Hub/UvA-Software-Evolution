module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume::LOCVolumeMetric;
import Helper::ProjectHelper;
import Helper::BenchmarkHelper;
import UnitSize::UnitSize;
import UnitSize::UnitSizeRanking;
import CyclomaticComplexity::CyclomaticComplexityRanking;
import CyclomaticComplexity::CyclomaticComplexity;
import Duplication::Duplication;
import IO;
import List; 
import util::FileSystem;
import Set;
import util::Math;


void analyseSmallSQL() {
	
	println("+----------------------------------+");
	println("|         Setting up Project       |");
	println("+----------------------------------+");

	M3 model = createM3FromMavenProject(|file:///Users/ekletsko/Downloads/smallsql0.21_src|);
	volume = getVolumeMetric(model);
	listOfLocations = toList(methods(model));
	linesOfCode = volume["Actual Lines of Code"];


	list[Declaration] declarations = [ createAstFromFile(file, true) | file <- toList(files(model))]; 
	list[Declaration] methods = [];

	for(int i <- [0 .. size(declarations)]) {
		methods = methods + [dec | /Declaration dec := declarations[i], dec is method || dec is constructor || dec is initializer];
	}

	allUnitSizes = getAllUnitSizesOfProject(model);
	UnitSizeDistribution absoluteUnitSizes = getAbsoluteUnitSizeDistribution(allUnitSizes);
	UnitSizeDistribution relativeUnitSizes = getRelativeUnitSizeDistribution(absoluteUnitSizes, volume["Actual Lines of Code"]);
	UnitSizeRankingValues unitSizeRanking = getUnitSizeRanking(relativeUnitSizes);

	
    complexityTuple = getCyclomaticRiskOverview(methods);  
	cyclomaticOverview = getCyclomaticRiskRating(linesOfCode, complexityTuple );
  	cyclomaticRanking = getCyclomaticRanking(complexityTuple, linesOfCode);

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

	println("+----------------------------------+");
	println("|         Unit Size                |");
	println("+----------------------------------+");
	println("|      Low  Risk Unit Size         |");
	println("|      Moderate  Risk Unit Size    |");
	println("| " + toString(absoluteUnitSizes.moderateRisk) + " lines (" + toString(relativeUnitSizes.moderateRisk) + " %) |");
	println("|      High  Risk Unit Size        |");
	println("| " + toString(absoluteUnitSizes.highRisk) + " lines (" + toString(relativeUnitSizes.highRisk) + " %) |");
	println("|      Very High Risk Unit Size    |");
	println("| " + toString(absoluteUnitSizes.veryHighRisk) + " lines (" + toString(relativeUnitSizes.veryHighRisk) + " %) |");
	println("|      Overall Ranking             |");
	println(unitSizeRanking.rankingType.name);

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
	println("|      Duplication                 |");
	println("+----------------------------------+");
	println("• Duplicated Lines ");
	int duplicatedLines = getDuplicatedLines(model);
	println(duplicatedLines);
	println("• Duplication Percentage ");
	real duplicationPercentage = getDuplicationPercentage(duplicatedLines, volume["Actual Lines of Code"]);
	println(duplicationPercentage);
	println("• Duplication Ranking ");
	ranking = getDuplicationRanking(duplicationPercentage);
	println(ranking.rankingType.name);

	}

