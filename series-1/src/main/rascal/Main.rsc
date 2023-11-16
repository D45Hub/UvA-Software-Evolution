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
	println("Getting the volume ranking for the project");
	formatUnitSizeRanking(model);

	println("+----------------------------------+");
	println("|         Volume Metrics           |");
	println("+----------------------------------+");
	println("Overall Lines");
	println(volume["Overall lines"]);
	println("Blank Lines");
	println(volume["Blank Lines"]);
	


	listOfLocations = toList(methods(model));
	linesOfCode = volume["Actual Lines of Code"];

	list[Declaration] declarations = [ createAstFromFile(file, true) | file <- toList(files(model))]; 
	list[Declaration] methods = [];

	for(int i <- [0 .. size(declarations)]) {
		methods = methods + [dec | /Declaration dec := declarations[i], dec is method || dec is constructor || dec is initializer];
	}

	// println("+----------------------------------+");
	// println("|         Unit Size                |");
	// println("+----------------------------------+");

	// allUnitSizes = getAllUnitSizesOfProject(model);
	// UnitSizeDistribution absoluteUnitSizes = getAbsoluteUnitSizeDistribution(allUnitSizes);
	// UnitSizeDistribution relativeUnitSizes = getRelativeUnitSizeDistribution(absoluteUnitSizes, volume["Actual Lines of Code"]);
	// UnitSizeRankingValues unitSizeRanking = getUnitSizeRanking(relativeUnitSizes);
	// println("Absolute Unit size distribution");
	// println(absoluteUnitSizes);
	// println("Relative Unit size distribution");
	// println(relativeUnitSizes);
	// 	println("Ranking Unit size distribution");
	// println(unitSizeRanking);




	println("+----------------------------------+");
	println("|      Unit Complexity             |");
	println("+----------------------------------+");

    complexityTuple = getCyclomaticRiskOverview(methods);  
	cyclomaticOverview = getCyclomaticRiskRating(linesOfCode, complexityTuple );
  	cyclomaticRanking = getCyclomaticRanking(complexityTuple, linesOfCode);
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

