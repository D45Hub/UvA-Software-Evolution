module Main

import Helper::Helper;
import Prelude;

ProjectLocation smallEncryptor = |project://series-2/src/main/rascal/simpleencryptor|;



void main() {
    encryptorAST = getASTs(smallEncryptor);
    encryptorNodes = getNodesFromAST(encryptorAST,5);
    println("size of encryptorNodes <size(encryptorNodes)>");
    hashedNodes = [];
    for (n <- encryptorNodes) {
        hashedNodes += hashSubtree(encryptorNodes, true);
    }
     println("hashed value of nodes in ast <hashedNodes>");
     println("size of hashedNodes <size(hashedNodes)>");
}

