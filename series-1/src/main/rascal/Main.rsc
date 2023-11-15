module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import Volume::LOCVolumeMetric;
import Helper::ProjectHelper;
import UnitSize::UnitSize;

import IO;

void analyseSmallSQL() {
    //Create M3 model
	M3 model = createM3FromMavenProject(|file:///Users/ekletsko/Downloads/smallsql0.21_src|);
	println(getVolumeMetric(model));
	formatUnitSizeRanking(model);
}