module Main

import Helper::Helper;
import Prelude;

ProjectLocation smallEncryptor = |project://series-2/src/main/rascal/simpleencryptor|;



void main() {
    encryptorAST = getASTs(smallEncryptor);
    encryptorNodes = getNodesFromAST(encryptorAST,5);
    test1 = hashSubtree(encryptorNodes, true);
    println("hashed value of nodes in ast <test1>");
}

