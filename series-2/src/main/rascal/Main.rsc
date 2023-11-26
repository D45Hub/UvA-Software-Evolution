module Main

import Helper::Helper;
import Prelude;

ProjectLocation smallEncryptor = |project://series-2/src/main/rascal/simpleencryptor|;



void main() {
    encryptorAST = getASTs(smallEncryptor);
    encryptorNodes = getNodesFromAST(encryptorAST);
    test1 = hashSubtree(encryptorNodes[0], false);
}

