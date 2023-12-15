module Main

import Helper::Helper;
import Helper::BenchmarkHelper;
import Prelude;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import Configuration;
import Helper::SubsequenceHelper;
import Helper::ProjectHelper;
import Helper::OutputHelper;
import Helper::Types;
import Helper::LOCHelper;
import Helper::CloneHelper;

import Location;

loc encryptorProject = |file:///C:/Users/denis/Documents/Software-Evolution/UvA-Software-Evolution/series-1/smallsql|;
public list[DuplicationResult] classes = [];

void main(bool performanceMode=false) {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);
    
    M3 model = createM3FromMavenProject(encryptorProject);
    list[Declaration] asts = [createAstFromFile(f, true) | f <- files(model.containment), isCompilationUnit(f)];

    BlocksMap bMap = getSubtrees(asts, MASS_THRESHOLD, LINE_THRESHOLD, CLONE_TYPE);
    list[tuple[node, node]] wholeClones = findClones(bMap);

    map[str, list[list[node]]] sequences2 = createSequenceHashTable(asts, wholeClones, MASS_THRESHOLD, CLONE_TYPE);
    list[tuple[list[node], list[node]]] sequenceClones = findSequenceClonePairs(sequences2, SIMILARTY_THRESHOLD, CLONE_TYPE);

    map[loc fileLoc, MethodLoc method] mapLocs = (performanceMode)?():getMethodLocs(model);
    list[DuplicationResult] duplicationResults = getRawDuplicationResults(sequenceClones, wholeClones, mapLocs, performanceMode);
    classes = getCloneClasses(duplicationResults);

    TransitiveCloneConnections allCloneConnections = getCloneConnections(extractIDPairs(duplicationResults));
    map[str, list[str]] cloneConnectionMap = generateCloneConnectionMap(allCloneConnections);
    classes = getFilteredDuplicationResultList(classes, cloneConnectionMap);
    println(typeOf(classes));

    if(!performanceMode){
        DuplicationResult biggestLinesDuplicationClass = getLargestLinesDuplicationClass(classes);
        DuplicationResult biggestMemberDuplicationClass = getLargestMemberDuplicationClass(classes);

        int duplicatedLinesAmount = 0;

        classes = filterDuplicates(classes);
    
        for(cl <- classes) {
            for(l <- cl){
                duplicatedLinesAmount += l.endLine - l.startLine;
            }
        }

        int projectLoc = size(getLOC(getConcatenatedProjectFile(model)));
        writeJSONFile(|project://series-2/src/main/rsc/output/report.json|, classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, size(classes), biggestLinesDuplicationClass, biggestMemberDuplicationClass, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
        writeMarkdownResult(|project://series-2/src/main/rsc/output/report.md|, classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, size(classes), biggestLinesDuplicationClass, biggestMemberDuplicationClass, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
        printCloneDetectionResults(classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, size(classes), biggestLinesDuplicationClass, biggestMemberDuplicationClass, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
        
    } else {
        println("Clone Detection finished!");
    }
    str stopBenchmarkTime = stopBenchmark("benchmark");
    println(stopBenchmarkTime);

    resetFileContentMap();
}