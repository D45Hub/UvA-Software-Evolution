module Main

import Helper::Helper;
import Helper::BenchmarkHelper;
import Prelude;
import List;
import TreeComparison::SubtreeComparator;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::UUID;
import util::Math;
import Configuration;
import Helper::SubsequenceHelper;
import Helper::ProjectHelper;
import Helper::OutputHelper;
import Helper::Types;
import Helper::LOCHelper;

import IO;
import Set;
import Location;
import Map;

loc denisProject = |file:///C:/Users/denis/Documents/Software-Evolution/UvA-Software-Evolution/series-1/smallsql/|;
loc lisaProject = |file:///Users/ekletsko/Downloads/smallsql0.21_src|;
loc encryptorProject = |project://series-2/src/main/rascal/simpleencryptor|;

ProjectLocation project = denisProject;


void main() {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);
    
    list[Declaration] asts = getASTs(encryptorProject);

    list[node] projectNodes = prepareProjectForAnalysis(asts);

	printDebug("Adding node details");

    list[NodeHashLoc] nodes = prepareASTNodesForAnalysis(projectNodes, MASS_THRESHOLD);
    list[CloneTuple] results = getClonePairs(nodes, SIMILARTY_THRESHOLD);
    println("Amount of Clone Pairs <size(results)>");

    //map[str hash, list[list[node]] sequenceRoots] sequences = getSequences(asts, 15);
    //println("Sequences: <size(sequences)>");
    map[str, list[list[node]]] sequences2 = createSequenceHashTable(asts, MASS_THRESHOLD, 1);

    println("Sequences: <size(sequences2)>");
/**
    real sequenceThreshold = SIMILARTY_THRESHOLD;
    list[CloneTuple] sequenceClones = findSequenceClones(sequences, sequenceThreshold, results);
    */
    list[tuple[list[node], list[node]]] sequenceClones = findSequenceClonePairs(sequences2, 1.0, 1);
    println("Sequence Clones: <size(sequenceClones)>");

    int duplicatedLinesAmount = 0;
    list[DuplicationResult] duplicationResults = [];

    M3 model = createM3FromMavenProject(encryptorProject);
    methodObjects = methods(model);
    map[loc fileLoc, MethodLoc method] mapLocs = ();
    
    for(m <- methodObjects) {
        decl = getFirstFrom(model.declarations[m]);
        int beginDecl = decl.begin.line;
        int endDecl = decl.end.line;

        if(endDecl - beginDecl >= MASS_THRESHOLD) {
            int methodLoc = size(getLOC(readFile(m)));
            mapLocs += (decl: <m, methodLoc>);
        }   
    }

    for(c <- sequenceClones) {

        //set[tuple[int from, int to]] maxAmount = ();
        int maxFromLineA = -1;
        int maxToLineA = -1;
        int maxFromLineB = -1;
        int maxToLineB = -1;
        loc nodeALoc = |test://unknown|;
        loc nodeBLoc = |test://unknown|;

        for(nodeA <- c[0], nodeB <- c[1]) {
            nodeALoc = nodeFileLocation(nodeA);
            nodeBLoc = nodeFileLocation(nodeB);

            if(maxFromLineA == -1 && maxToLineA == -1) {
                maxFromLineA = nodeALoc.begin.line;
                maxToLineA = nodeALoc.end.line;
            }
            
            if(nodeALoc.begin.line < maxFromLineA) {
                maxFromLineA = nodeALoc.begin.line;
            }

            if(nodeALoc.end.line > maxToLineA) {
                maxFromLineA = nodeALoc.end.line;
            }

            


            if(maxFromLineB == -1 && maxToLineB == -1) {
                maxFromLineB = nodeBLoc.begin.line;
                maxToLineB = nodeBLoc.end.line;
            }
            
            if(nodeBLoc.begin.line < maxFromLineA) {
                maxFromLineB = nodeBLoc.begin.line;
            }

            if(nodeBLoc.end.line > maxToLineB) {
                maxFromLineB = nodeBLoc.end.line;
            }
        }

// TODO REFACTOR THIS RADIOACTIVE GLOWING SHIT... I DONT WANT ANYMORE... IT IS LATE...
        MethodLoc methodA = <noLocation, -1>;
        MethodLoc methodB = <noLocation, -1>;
        for(k <- mapLocs) {
            str nodeAFileName = split("///", nodeALoc.uri)[1];
            str nodeBFileName = split("///", nodeBLoc.uri)[1];
            str projectFileName = split("//", k.uri)[1];
            if(contains(projectFileName, nodeAFileName) && nodeALoc.begin.line >= k.begin.line && nodeALoc.end.line <= k.end.line) {
                methodA = mapLocs[k];

                if(methodB.methodLocation != noLocation && methodB.methodLoc != -1){
                    break;
                }
            }

            if(contains(projectFileName, nodeBFileName) && nodeBLoc.begin.line >= k.begin.line && nodeBLoc.end.line <= k.end.line) {
                methodB = mapLocs[k];
                if(methodA.methodLocation != noLocation && methodA.methodLoc != -1){
                    break;
                }
            }
        }

        str duplicationUUID = toString(uuidi());
        DuplicationLocation res1 = <duplicationUUID, nodeALoc.path, methodA<0>.path, methodA<1>, maxToLineA, maxFromLineA>;
        duplicationUUID = toString(uuidi());
        DuplicationLocation res2 = <duplicationUUID, nodeBLoc.path, methodB<0>.path, methodB<1>, maxToLineB, maxFromLineB>;
        DuplicationResult dRes = [res1, res2];

        duplicationResults += [dRes];
    }    
    
    list[DuplicationResult] classes = getCloneClasses(duplicationResults);

    for(cl <- classes) {
        duplicatedLinesAmount += cl[0].endLine - cl[0].startLine;
    }

    println("Clone clas: <size(classes)>");
    println("Duplicated Lines: <duplicatedLinesAmount>");
    println("Duplicate Results: <size(duplicationResults)>");

    

    int projectLoc = size(getLOC(getConcatenatedProjectFile(model)));
    writeJSONFile(|project://series-2/src/main/rsc/output/report.json|, classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
    str stopBenchmarkTime = stopBenchmark("benchmark");
    println(stopBenchmarkTime);
}


public list[DuplicationResult] getCloneClasses(list[DuplicationResult] duplicationResults) {
    list[DuplicationResult] cloneClasses = [];
    
    for(DuplicationResult d <- duplicationResults) {
        DuplicationLocation maxSizedDuplicationLoc1 = d[0];
        DuplicationLocation maxSizedDuplicationLoc2 = d[1];        

        for(DuplicationResult r <- duplicationResults) {
            for(DuplicationLocation l <- r){
                if((l.filePath == maxSizedDuplicationLoc1.filePath) && (l.methodName == maxSizedDuplicationLoc1.methodName)) {
                    if(l.startLine < maxSizedDuplicationLoc1.startLine) {
                        maxSizedDuplicationLoc1.startLine = l.startLine;
                    }

                    if(l.endLine > maxSizedDuplicationLoc1.endLine) {
                        maxSizedDuplicationLoc1.endLine = l.endLine;
                    }
                }

                if((l.filePath == maxSizedDuplicationLoc2.filePath) && (l.methodName == maxSizedDuplicationLoc2.methodName)) {
                    if(l.startLine < maxSizedDuplicationLoc2.startLine) {
                        maxSizedDuplicationLoc2.startLine = l.startLine;
                    }

                    if(l.endLine > maxSizedDuplicationLoc2.endLine) {
                        maxSizedDuplicationLoc2.endLine = l.endLine;
                    }
                }
            } 
        }

        DuplicationResult newDuplRes = [maxSizedDuplicationLoc1, maxSizedDuplicationLoc2];

        if(!containsDuplicationResult(cloneClasses, newDuplRes)) {
            cloneClasses += [newDuplRes];
        }
    }

    //println(cloneClasses);

    return cloneClasses;
}

bool containsDuplicationResult(list[DuplicationResult] results, DuplicationResult result) {
    bool containsResult = false;

    DuplicationLocation resultLoc1 = result[0];
    DuplicationLocation resultLoc2 = result[1];
    
    for(r <- results) {
        DuplicationLocation l1 = r[0];
        DuplicationLocation l2 = r[1];

        bool containsInL1 = (l1.filePath == resultLoc1.filePath) && (l1.methodName == resultLoc1.methodName) && (l1.startLine == resultLoc1.startLine) && (l1.endLine == resultLoc1.endLine);
        bool containsInL2 = (l2.filePath == resultLoc2.filePath) && (l2.methodName == resultLoc2.methodName) && (l2.startLine == resultLoc2.startLine) && (l2.endLine == resultLoc2.endLine);

        bool reverseContainsInL1 = (l1.filePath == resultLoc2.filePath) && (l1.methodName == resultLoc2.methodName) && (l1.startLine == resultLoc2.startLine) && (l1.endLine == resultLoc2.endLine);
        bool reverseContainsInL2 = (l2.filePath == resultLoc1.filePath) && (l2.methodName == resultLoc1.methodName) && (l2.startLine == resultLoc1.startLine) && (l2.endLine == resultLoc1.endLine);


        if((containsInL1 && containsInL2) || (reverseContainsInL1 && reverseContainsInL2)) {
            containsResult = true;
        }
    }
    return containsResult;
} 