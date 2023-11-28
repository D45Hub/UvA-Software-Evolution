module Main

import Helper::Helper;
import Helper::BenchmarkHelper;
import Prelude;
import List;
import TreeComparison::SubtreeComparator;

ProjectLocation smallEncryptor = |file:///C:/Users/denis/Documents/Software-Evolution/UvA-Software-Evolution/series-1/smallsql/|;

void main() {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);

    encryptorAST = getASTs(smallEncryptor);
    list[node] encryptorNodes = getNodesFromAST(encryptorAST, 6);
    println(size(getSubtreeClonePairs(encryptorAST, 6, 1)));
    str stopBenchmarkTime = stopBenchmark("benchmark");

    println(stopBenchmarkTime);

    //println("hashed value of nodes in ast <hashedNodes>");
    //println("size of hashedNodes <size(hashedNodes)>");
}

set[str] listToSet(list[str] myList) {
    return toSet(myList);
}