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
import Helper::SubsequenceHelper;
import Helper::ProjectHelper;
import Helper::OutputHelper;

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
    list[CloneTuple] results = getClonePairs(nodes, SIMILARTY_THRESHOLD);
    println("Amount of Clone Pairs <size(results)>");

    //map[str hash, list[list[node]] sequenceRoots] sequences = getSequences(asts, 15);
    //println("Sequences: <size(sequences)>");
    map[str, list[list[node]]] sequences2 = createSequenceHashTable(asts, 5, 1);
    println("Sequences: <size(sequences2)>");
/**
    real sequenceThreshold = SIMILARTY_THRESHOLD;
    list[CloneTuple] sequenceClones = findSequenceClones(sequences, sequenceThreshold, results);
    */
    list[tuple[list[node], list[node]]] sequenceClones = findSequenceClonePairs(sequences2, 1.0, 1);
    println("Sequence Clones: <size(sequenceClones)>");

    int duplicatedLinesAmount = 0;
    list[DuplicationResult] duplicationResults = [];

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

        DuplicationLocation res1 = <nodeALoc.uri, "test", maxToLineA, maxFromLineA, "Type 1">;
        DuplicationLocation res2 = <nodeBLoc.uri, "test", maxToLineB, maxFromLineB, "Type 1">;

        duplicationResults += [<res1, res2>];

        duplicatedLinesAmount += maxFromLineA - maxToLineA;

    }
    println("Duplicated Lines: <duplicatedLinesAmount>");
    println("Duplicate Results: <size(duplicationResults)>");
    writeJSONFile(|project://series-2/src/main/rsc/output/report.json|, duplicationResults);
    str stopBenchmarkTime = stopBenchmark("benchmark");
    println(stopBenchmarkTime);
}