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
	loc file = |project://series-1/src/main/test-code/Volume/CommentsOnlyFile.java|;
	list[str] codeLines = getLOC(readFile(file));
	return size(codeLines) == 0;
}
