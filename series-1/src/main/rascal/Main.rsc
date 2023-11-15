module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume::LOCVolumeMetric;
import Helper::ProjectHelper;
import UnitSize::UnitSize;
import CyclomaticComplexity::CyclomaticComplexityRanking;

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
	println(size(listOfLocations));
	listOfDeclarations = [ createAstFromFile(location, true)| location <- listOfLocations ];
  	riskOverview = getCyclomaticRiskRating(listOfLocations, (409 + 2340 + 250 + 196));
	println("risk overview");
	println(riskOverview);
	riskRanking = getCyclomaticRanking(riskOverview);
	println("Risk Ranking");
	println(riskRanking);
	}

