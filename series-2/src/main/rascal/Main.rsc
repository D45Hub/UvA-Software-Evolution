module Main

import Helper::Helper;
import Prelude;
import List;

ProjectLocation smallEncryptor = |project://series-2/src/main/rascal/simpleencryptor|;

void main() {
    encryptorAST = getASTs(smallEncryptor);
    encryptorNodes = getNodesFromAST(encryptorAST,5);
    println("size of encryptorNodes <size(encryptorNodes)>");
    hashedNodes = [];
    for (n <- encryptorNodes) {
        hashedNodes += hashSubtree(n, true);
    }

    hashedNodeSet = listToSet(hashedNodes);
    println("Clone groups: <size(hashedNodeSet)>");

    //println("hashed value of nodes in ast <hashedNodes>");
    println("size of hashedNodes <size(hashedNodes)>");
}

set[str] listToSet(list[str] myList) {
    return toSet(myList);
}