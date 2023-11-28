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

loc denisProject = |file:///C:/Users/denis/Documents/Software-Evolution/UvA-Software-Evolution/series-1/smallsql/|;
loc lisaProject = |file:///Users/ekletsko/Downloads/smallsql0.21_src|;
loc encryptorProject = |project://series-2/src/main/rascal/simpleencryptor|;

ProjectLocation project = denisProject;


void main() {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);
    /**
    list[node] projectNodes = prepareProjectForAnalysis(encryptorProject);

	printDebug("Adding node details");

    list[NodeHashLoc] nodes = prepareASTNodesForAnalysis(projectNodes, MASS_THRESHOLD);
	println("Nodes Finished lel");
    list[CloneTuple] results = getClonePairs(nodes, SIMILARTY_THRESHOLD);
    println("Amount of Clone Pairs <size(results)>");
    */
    map[str hash, list[list[node]] sequenceRoots] sequences = getSequences(getASTs(encryptorProject), 6);
    real sequenceThreshold = 6.0;
    list[tuple[list[node], list[node]]] sequenceClones = findSequenceClones(sequences, sequenceThreshold);

    print(size(sequenceClones));

    str stopBenchmarkTime = stopBenchmark("benchmark");
    println(stopBenchmarkTime);

}