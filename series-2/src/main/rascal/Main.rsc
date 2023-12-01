module Main

import Helper::Helper;
import Helper::BenchmarkHelper;
import Prelude;
import List;
import TreeComparison::SubtreeComparator;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import Configuration;
import Helper::CloneSequences;
import Helper::SubsequenceHelper;
import Helper::ProjectHelper;

loc denisProject = |file:///C:/Users/denis/Documents/Software-Evolution/UvA-Software-Evolution/series-1/hsqldb/|;
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
	println("Nodes Finished lel");
    list[CloneTuple] results = getClonePairs(nodes, SIMILARTY_THRESHOLD);
    println("Amount of Clone Pairs <size(results)>");

    //map[str hash, list[list[node]] sequenceRoots] sequences = getSequences(asts, 15);
    //println("Sequences: <size(sequences)>");
    map[str, list[list[node]]] sequences2 = createSequenceHashTable(asts, 6, 1);
    println("Sequences2: <size(sequences2)>");
/**
    real sequenceThreshold = SIMILARTY_THRESHOLD;
    list[CloneTuple] sequenceClones = findSequenceClones(sequences, sequenceThreshold, results);
    */
    list[tuple[list[node], list[node]]] sequenceClones = findSequenceClonePairs(sequences2, 1.0, 1);
    println("Sequence Clones: <size(sequenceClones)>");

    int duplicatedLinesAmount = 0;

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

            /**
            //if(nodeALoc.end.line - nodeALoc.begin.line > 1 && nodeBLoc.end.line - nodeBLoc.begin.line > 1) {
            println("--------------");
            println("NodeA Lines: <nodeALoc.begin.line> until <nodeALoc.end.line> in <nodeALoc.uri>");
            println("NodeB Lines: <nodeBLoc.begin.line> until <nodeBLoc.end.line> in <nodeBLoc.uri>");
            println("--------------");
            //}
            */
        }
        println("From: <maxFromLineA>, To: <maxToLineA>, File: <nodeALoc.uri>");
        println("From: <maxFromLineB>, To: <maxToLineB>, File: <nodeBLoc.uri>");
        duplicatedLinesAmount += maxFromLineA - maxToLineA;

    }
    println(duplicatedLinesAmount);
    str stopBenchmarkTime = stopBenchmark("benchmark");
    println(stopBenchmarkTime);
}