module Tests::Volume::TestLinesOfCode

import Volume::LOCVolumeMetric;
import Volume::LOCVolume;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Helper::ProjectHelper;
import IO;
import List;
import String;

test bool commentsOnlyLocTest(){
	loc file = |project://series-1/src/main/test-code/Volume/CommentsOnlyFile.java|;
	list[str] codeLines = getLOC(readFile(file));
	return size(codeLines) == 0;
}


/* 
22, because we are counting curly braces and method declaration part.
*/ 
test bool usualJavaMethod(){
	loc file = |project://series-1/src/main/test-code/Volume/TestMethod.java|;
	list[str] codeLines = getLOC(readFile(file));
	return size(codeLines) == 22;
}

/* 
19, because we don't count unique curly brace lines.
*/ 
test bool usualJavaMethodNoCurlyBraces(){
	loc file = |project://series-1/src/main/test-code/Volume/TestMethod.java|;
	list[str] codeLines = getLOC(readFile(file), false);
	return size(codeLines) == 19;
}