module Tests::Volume::TestLinesOfCode

import Volume::LOCVolumeMetric;
import Volume::LOCVolume;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Helper::ProjectHelper;
import IO;
import List;
import String;
import List;

test bool commentsOnlyLocTest(){
	loc file = |file:///Users/ekletsko/Documents/Master/SoftwareEvolution/UvA-Software-Evolution/series-1/src/main/test-code/volume/CommentsOnlyFile.java|;
	list[str] codeLines = getLOC(readFile(file));
	return size(codeLines) == 0;
}
