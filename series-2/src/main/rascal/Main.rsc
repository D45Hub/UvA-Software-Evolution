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

loc denisProject = |file:///C:/Users/denis/Documents/Software-Evolution/UvA-Software-Evolution/series-1/smallsql/|;
loc lisaProject = |file:///Users/ekletsko/Downloads/smallsql0.21_src|;
loc encryptorProject = |project://series-2/src/main/rascal/simpleencryptor|;

ProjectLocation project = denisProject;


void main() {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);
    
    list[node] projectNodes = prepareProjectForAnalysis(encryptorProject);

	printDebug("Adding node details");

    list[NodeHashLoc] nodes = prepareASTNodesForAnalysis(projectNodes, MASS_THRESHOLD);
	println("Nodes Finished lel");
    list[CloneTuple] results = getClonePairs(nodes, SIMILARTY_THRESHOLD);
    println("Amount of Clone Pairs <size(results)>");

    list[Declaration] asts = getASTs(encryptorProject);
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

    str stopBenchmarkTime = stopBenchmark("benchmark");
    println(stopBenchmarkTime);
}