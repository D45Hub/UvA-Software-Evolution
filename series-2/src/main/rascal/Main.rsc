module Main

import Helper::Helper;
import Prelude;
import List;
import TreeComparison::SubtreeComparator;

ProjectLocation smallEncryptor = |project://series-2/src/main/rascal/simpleencryptor|;

void main() {
    encryptorAST = getASTs(smallEncryptor);
    encryptorNodes = getNodesFromAST(encryptorAST,4);
    println(size(getSubtreeClonePairs(encryptorAST, 4, 0.34)));

    //println("hashed value of nodes in ast <hashedNodes>");
    //println("size of hashedNodes <size(hashedNodes)>");
}

set[str] listToSet(list[str] myList) {
    return toSet(myList);
}