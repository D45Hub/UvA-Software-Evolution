module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume::LOCVolumeMetric;
import Helper::ProjectHelper;
import UnitSize::UnitSize;
import UnitSize::UnitSizeRanking;
import CyclomaticComplexity::CyclomaticComplexityRanking;
import CyclomaticComplexity::CyclomaticComplexity;
import Duplication::Duplication;
import IO;
import List; 
import util::FileSystem;
import Set;

void analyseSmallSQL() {
    //Create M3 model
		println("Getting files...");
	M3 model = createM3FromMavenProject(|file:///Users/ekletsko/Downloads/hsqldb-2.3.1|);
	volume = getVolumeMetric(model);
	formatUnitSizeRanking(model);

    	println("Getting locations...");

	listOfLocations = toList(methods(model));

	println("Extracting methods...");
	list[Declaration] declarations = [ createAstFromFile(file, true) | file <- toList(files(model))]; 
	list[Declaration] methods = [];
	for(int i <- [0 .. size(declarations)]) {
		methods = methods + [dec | /Declaration dec := declarations[i], dec is method || dec is constructor || dec is initializer];
	}

	println(size(listOfLocations));
	allUnitSizes = getAllUnitSizesOfProject(model);
	UnitSizeDistribution absoluteUnitSizes = getAbsoluteUnitSizeDistribution(allUnitSizes);
	UnitSizeDistribution relativeUnitSizes = getRelativeUnitSizeDistribution(absoluteUnitSizes, 24050);
	UnitSizeRankingValues unitSizeRanking = getUnitSizeRanking(relativeUnitSizes);
	println(absoluteUnitSizes);
	println(relativeUnitSizes);
	println(unitSizeRanking);

  	riskOverview = getCyclomaticRanking(getCyclomaticRiskOverview(methods), volume["Actual Lines of Code"]);
	println("cyclomaticComplexityRanking");
	println(riskOverview);
	// println("Extracting methods...");
	// list[Declaration] declarations = [ createAstFromFile(file, true) | file <- toList(files(model))]; 
	// list[Declaration] methods = [];
	// for(int i <- [0 .. size(declarations)]) {
	// 	methods = methods + [dec | /Declaration dec := declarations[i], dec is method || dec is constructor || dec is initializer];
	// }

	// println(size(listOfLocations));
	// allUnitSizes = getAllUnitSizesOfProject(model);
	// getUnitSizeDistribution(allUnitSizes,24050);

  	// riskOverview = getCyclomaticRanking(getCyclomaticRiskOverview(methods), volume["Actual Lines of Code"]);
	// println("cyclomaticComplexityRanking");
	// println(riskOverview);
	println("duplication");
	getDuplicationPercentage(model, volume["Actual Lines of Code"] );
	}

