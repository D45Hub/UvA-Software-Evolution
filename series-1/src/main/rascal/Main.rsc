module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume::LOCVolumeMetric;
import Helper::ProjectHelper;
import CyclomaticComplexity::CyclomaticComplexityRanking;

import IO;
import List; 
import util::FileSystem;
import Set;

void analyseSmallSQL() {
    //Create M3 model
	M3 model = createM3FromMavenProject(|file:///Users/ekletsko/Downloads/smallsql0.21_src|);
	println(getVolumeMetric(model));
	println("Getting files...");
    
	listOfLocations = toList(methods(model));
	println("amount of methods");
	println(size(listOfLocations));
	listOfDeclarations = [ createAstFromFile(location, true)| location <- listOfLocations ];
  	riskOverview = getCyclomaticRiskRating(listOfLocations);
	riskRanking = getCyclomaticRanking(riskOverview);
	println("Risk Ranking");
	println(riskRanking);
	}

