module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume::LOCVolumeMetric;
import Helper::ProjectHelper;
import UnitSize::UnitSize;
import CyclomaticComplexity::CyclomaticComplexityRanking;
import CyclomaticComplexity::CyclomaticComplexity;

import IO;
import List; 
import util::FileSystem;
import Set;

void analyseSmallSQL() {
    //Create M3 model
	M3 model = createM3FromMavenProject(|file:///Users/ekletsko/Downloads/smallsql0.21_src|);
	volume = getVolumeMetric(model);
	formatUnitSizeRanking(model);

	println("Getting files...");
    
	listOfLocations = toList(methods(model));

	println("Extracting methods...");
	list[Declaration] declarations = [ createAstFromFile(file, true) | file <- toList(files(model))]; 
	list[Declaration] methods = [];
	for(int i <- [0 .. size(declarations)]) {
		methods = methods + [dec | /Declaration dec := declarations[i], dec is method || dec is constructor || dec is initializer];
	}

	println(size(listOfLocations));
	allUnitSizes = getAllUnitSizesOfProject(model);
	getUnitSizeDistribution(allUnitSizes,24050);

  	riskOverview = getCyclomaticRanking(getCyclomaticRiskOverview(methods), volume["Actual Lines of Code"]);
	println("cyclomaticComplexityRanking");
	println(riskOverview);
	}

