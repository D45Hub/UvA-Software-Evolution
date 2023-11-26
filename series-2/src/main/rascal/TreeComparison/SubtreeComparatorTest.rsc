module TreeComparison::SubtreeComparatorTest

import Helper::Helper;
import Prelude;
import TreeComparison::SubtreeComparator;

test bool checkIsCloneSubset(){
    testNode = "YlgJ"("M"("abc"(1)));
    testSubTree = "abc"(1);
    testFunc =  isSubClone(testSubTree, testNode);
    
    return (testFunc == true);
}

test bool checkIsCloneSubset(){
    testNode = "YlgJ"("M"("abc"(1)));
    testSubTree = "abc"(1);
    testFunc =  isSubClone(testNode,testSubTree );
    
    return (testFunc == false);
}