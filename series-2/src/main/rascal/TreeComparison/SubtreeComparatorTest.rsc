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

test bool returnsListWithLessElements() {
    testNode = "YlgJ"("M"("abc"(1)));
    testSubTree = "abc"(1);
    exampleClonePair = <<"exampleHash", testNode>,<"exampleHash3", testSubTree>>;
    exampleClonePairs = [<<"exampleHash", testNode>, <"exampleHash2", testSubTree>>];
    cloneList = removeClonePair(exampleClonePair,exampleClonePairs);
    return (size(cloneList) == 0);
}