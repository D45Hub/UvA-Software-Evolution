module Main

import Helper::Helper;
import Helper::BenchmarkHelper;
import Prelude;
import TreeComparison::SubtreeComparator;
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

loc denisProject = |file:///C:/Users/denis/Documents/Software-Evolution/UvA-Software-Evolution/series-1/smallsql/|;
loc lisaProject = |file:///Users/ekletsko/Downloads/smallsql0.21_src|;
loc encryptorProject = |project://series-2/src/main/rascal/simpleencryptor|;

ProjectLocation project = denisProject;


/** Returns transitive closure of nodes*/ 
public TransitiveCloneConnections getCloneConnections (CloneConnections idPairs) {
    return idPairs+;
}

public  CloneConnections extractIDPairs (list[DuplicationResult] duplicationResults) {
    return [<duplicationResult[0].uuid, duplicationResult[1].uuid> | duplicationResult <- duplicationResults];
}

void main() {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);
    
    M3 model = createM3FromMavenProject(encryptorProject);
    list[Declaration] asts = [createAstFromFile(f, true) | f <- files(model.containment), isCompilationUnit(f)];

    map[str, list[list[node]]] sequences2 = createSequenceHashTable(asts, MASS_THRESHOLD, CLONE_TYPE);
    println("Sequences: <size(sequences2)>");

    list[tuple[list[node], list[node]]] sequenceClones = findSequenceClonePairs(sequences2, SIMILARTY_THRESHOLD, CLONE_TYPE);
    println("Sequence Clones: <size(sequenceClones)>");

    int duplicatedLinesAmount = 0;

    map[loc fileLoc, MethodLoc method] mapLocs = getMethodLocs(model);
 
    list[DuplicationResult] duplicationResults = getRawDuplicationResults(sequenceClones, mapLocs);

    list[DuplicationResult] classes = getCloneClasses(duplicationResults);

    for(cl <- classes) {
        duplicatedLinesAmount += cl[0].endLine - cl[0].startLine;
    }

    DuplicationResult biggestDuplicationClass = getLargestDuplicationClass(classes);
    TransitiveCloneConnections allCloneConnections = getCloneConnections(extractIDPairs(duplicationResults));

    map[str, list[str]] cloneConnectionMap = generateCloneConnectionMap(allCloneConnections);
    classes = getFilteredDuplicationResultList(classes, cloneConnectionMap);
    println("Clone classes: <size(classes)>");

    println("Duplicated Lines: <duplicatedLinesAmount>");
    println("Duplicate Results: <size(duplicationResults)>");

    // TODO MORE FUNNY CONSOLE LOGS FOR ALL OF THE STATS... JUST PRINT OUTPUT HELPER...
    // AND ALSO INCLUDE TXT FILE OUTPUT...

    int projectLoc = size(getLOC(getConcatenatedProjectFile(model)));
    writeJSONFile(|project://series-2/src/main/rsc/output/report.json|, classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, size(classes), biggestDuplicationClass, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
    writeMarkdownResult(|project://series-2/src/main/rsc/output/report.md|, classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, size(classes), biggestDuplicationClass, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
    str stopBenchmarkTime = stopBenchmark("benchmark");
    println(stopBenchmarkTime);
}