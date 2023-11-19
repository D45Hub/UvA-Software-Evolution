module Tests::Duplication::TestDuplication

import Map;
import Volume::LOCVolume;
import Volume::LOCVolumeMetric;
import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Helper::ProjectHelper;
import Duplication::Duplication;
import lang::java::m3::Core;
import lang::java::m3::AST;

test bool shouldBeNoDuplicationInMap(){
	loc file = |project://series-1/src/main/test-code/Duplication/UniqueLines.java|;
	list[str] codeLines = getLOC(readFile(file));
    duplicatedLines = getDuplicatesOfProgram(codeLines);
	return size((duplicate : duplicatedLines[duplicate] | duplicate <- duplicatedLines, duplicatedLines[duplicate] > 1)) == 0;
}

/* This is not working */ 
test bool duplicationPercentageShouldBe100(){
	loc file = |project://series-1/src/main/test-code/Duplication/FullDuplication.java|;
    M3 model = createM3FromFile(file);
    sourceOfModel = getDuplicatedLines(model);
    println(sourceOfModel);
	return false;
}
