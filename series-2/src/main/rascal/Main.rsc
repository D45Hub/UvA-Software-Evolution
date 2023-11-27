module Main

import Helper::Helper;
import Helper::BenchmarkHelper;
import Prelude;
import List;
import TreeComparison::SubtreeComparator;

ProjectLocation smallEncryptor = |project://series-2/src/main/rascal/simpleencryptor|;

void main() {
    str startBenchmarkTime = startBenchmark("benchmark");
    println(startBenchmarkTime);

    encryptorAST = getASTs(smallEncryptor);
    encryptorNodes = getNodesFromAST(encryptorAST, 3);
    println(size(getSubtreeClonePairs(encryptorAST, 3, 1)));
    str stopBenchmarkTime = stopBenchmark("benchmark");

    println(stopBenchmarkTime);

    //println("hashed value of nodes in ast <hashedNodes>");
    //println("size of hashedNodes <size(hashedNodes)>");
}

set[str] listToSet(list[str] myList) {
    return toSet(myList);
}