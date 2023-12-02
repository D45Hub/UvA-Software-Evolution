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
loc encryptorProject = denisProject;//|project://series-2/src/main/rascal/simpleencryptor|;

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

    DuplicationResult biggestDuplicationClass = classes[0];
    DuplicationLocation biggestDuplicationLoc = biggestDuplicationClass[0];
    int biggestDuplLines = biggestDuplicationLoc.endLine - biggestDuplicationLoc.startLine;

    for(itClass <- classes) {
        DuplicationLocation itDuplicationLoc = itClass[0];
        int itDuplicationLines = (itDuplicationLoc.endLine - itDuplicationLoc.startLine);
        if(biggestDuplLines < itDuplicationLines) {
            biggestDuplLines = itDuplicationLines;
            biggestDuplicationLoc = itDuplicationLoc;
            biggestDuplicationClass = itClass;
        }
    }

    println("Clone clas: <size(classes)>");
    println("Duplicated Lines: <duplicatedLinesAmount>");
    println("Duplicate Results: <size(duplicationResults)>");

    int projectLoc = size(getLOC(getConcatenatedProjectFile(model)));
    writeJSONFile(|project://series-2/src/main/rsc/output/report.json|, classes, encryptorProject.uri, projectLoc, duplicatedLinesAmount, size(classes), biggestDuplicationClass, MASS_THRESHOLD, SIMILARTY_THRESHOLD);
    str stopBenchmarkTime = stopBenchmark("benchmark");
    println(stopBenchmarkTime);
}