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

void main() {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);
    
    M3 model = createM3FromMavenProject(encryptorProject);
    list[Declaration] asts = [createAstFromFile(f, true) | f <- files(model.containment), isCompilationUnit(f)];

    map[str, list[list[node]]] sequences2 = createSequenceHashTable(asts, MASS_THRESHOLD, CLONE_TYPE);
    list[tuple[list[node], list[node]]] sequenceClones = findSequenceClonePairs(sequences2, SIMILARTY_THRESHOLD, CLONE_TYPE);

    int duplicatedLinesAmount = 0;

    map[loc fileLoc, MethodLoc method] mapLocs = getMethodLocs(model);
    list[DuplicationResult] duplicationResults = getRawDuplicationResults(sequenceClones, mapLocs);
    list[DuplicationResult] classes = getCloneClasses(duplicationResults);

    TransitiveCloneConnections allCloneConnections = getCloneConnections(extractIDPairs(duplicationResults));
    map[str, list[str]] cloneConnectionMap = generateCloneConnectionMap(allCloneConnections);
    classes = getFilteredDuplicationResultList(classes, cloneConnectionMap);

    allCloneConnections = getCloneConnections(extractIDPairs(classes));
    cloneConnectionMap = generateCloneConnectionMap(allCloneConnections);
    list[DuplicationResult] classes2 = getFilteredDuplicationResultList(classes, cloneConnectionMap);
    list[DuplicationResult] overlap = (classes2 - classes);
    classes = classes2 + (classes - classes2) - overlap;

    DuplicationResult biggestLinesDuplicationClass = getLargestLinesDuplicationClass(classes);
    DuplicationResult biggestMemberDuplicationClass = getLargestMemberDuplicationClass(classes);

    for(cl <- classes) {
        duplicatedLinesAmount += cl[0].endLine - cl[0].startLine;
    }

    int projectLoc = size(getLOC(getConcatenatedProjectFile(model)));
    writeJSONFile(|project://series-2/src/main/rsc/output/report.json|, classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, size(classes), biggestLinesDuplicationClass, biggestMemberDuplicationClass, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
    writeMarkdownResult(|project://series-2/src/main/rsc/output/report.md|, classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, size(classes), biggestLinesDuplicationClass, biggestMemberDuplicationClass, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
    printCloneDetectionResults(classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, size(classes), biggestLinesDuplicationClass, biggestMemberDuplicationClass, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
    
    str stopBenchmarkTime = stopBenchmark("benchmark");
    println(stopBenchmarkTime);

    resetFileContentMap();
}