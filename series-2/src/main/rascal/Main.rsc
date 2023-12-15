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

import Location;

loc encryptorProject = |project://series-2/src/main/rascal/simpleencryptor|;
public list[DuplicationResult] classes = [];

void main(bool performanceMode=false) {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);
    
    M3 model = createM3FromMavenProject(encryptorProject);
    list[Declaration] asts = [createAstFromFile(f, true) | f <- files(model.containment), isCompilationUnit(f)];

    BlocksMap bMap = getSubtrees(asts, MASS_THRESHOLD, MASS_THRESHOLD, CLONE_TYPE);
    list[tuple[node, node]] wholeClones = findClones(bMap);
    println("nbrr");

    map[str, list[list[node]]] sequences2 = createSequenceHashTable(asts, wholeClones, MASS_THRESHOLD, CLONE_TYPE);
    list[tuple[list[node], list[node]]] sequenceClones = findSequenceClonePairs(sequences2, SIMILARTY_THRESHOLD, CLONE_TYPE);
    println("nejfhsjdf");

    map[loc fileLoc, MethodLoc method] mapLocs = (performanceMode)?():getMethodLocs(model);
    list[DuplicationResult] duplicationResults = getRawDuplicationResults(sequenceClones, wholeClones, mapLocs, performanceMode);
    classes = getCloneClasses(duplicationResults);

    TransitiveCloneConnections allCloneConnections = getCloneConnections(extractIDPairs(duplicationResults));
    map[str, list[str]] cloneConnectionMap = generateCloneConnectionMap(allCloneConnections);
    classes = getFilteredDuplicationResultList(classes, cloneConnectionMap);

    allCloneConnections = getCloneConnections(extractIDPairs(classes));
    cloneConnectionMap = generateCloneConnectionMap(allCloneConnections);
    list[DuplicationResult] classes2 = getFilteredDuplicationResultList(classes, cloneConnectionMap);
    list[DuplicationResult] overlap = (classes2 - classes);
    classes = classes2 + (classes - classes2) - overlap;

    if(!performanceMode){
        DuplicationResult biggestLinesDuplicationClass = getLargestLinesDuplicationClass(classes);
        DuplicationResult biggestMemberDuplicationClass = getLargestMemberDuplicationClass(classes);

        int duplicatedLinesAmount = 0;

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