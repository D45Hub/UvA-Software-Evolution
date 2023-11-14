module Tests::Volume::TestLinesOfCode

import MetricsHelper::LOCHelper;

import IO;
import List;
import String;
import List;
test bool commentsOnlyLocTest(){
	loc file = |file:///Users/ekletsko/Documents/Master/SoftwareEvolution/UvA-Software-Evolution/series-1/src/main/test-code/volume/CommentsOnlyFile.java|;
	
	str source = readFile(file);
    splittedLines =split("\n",source);
    trimmedLines = [trim(line) | line <- splittedLines];
	list[str] codeLines = getLinesOfComments(trimmedLines);
    println(codeLines);
    println( size(trimmedLines));
	return size(trimmedLines) == 7;
}

test bool removeAllCommentsTest() {
    loc file = |file:///Users/ekletsko/Documents/Master/SoftwareEvolution/UvA-Software-Evolution/series-1/src/main/test-code/volume/CommentsOnlyFile.java|;
	
	str source = readFile(file);
    
    codeLeftOvers = removeMultiLineComments(source);
    println(codeLeftOvers);
    return isEmpty(codeLeftOvers);
}

test bool correctVolumeMetric() {
    loc file = |file:///Users/ekletsko/Documents/Master/SoftwareEvolution/UvA-Software-Evolution/series-1/src/main/test-code/volume/SampleJavaClass.java|;
	
	str source = readFile(file);
    
    volumeMetric = getVolumeMetric(source);
    println(volumeMetric);
    return volumeMetric["Actual Lines of Code"] == 0;
}