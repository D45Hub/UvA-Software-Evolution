module Helper::CloneHelper
import Helper::ProjectHelper;
import Helper::Types;

public list[CloneTuple] getClonePairs(list[NodeHashLoc] hashedSubtrees, num similarityThreshold) {
    map[str, list[NodeLoc]] hashBuckets = placingSubTreesInBuckets(hashedSubtrees);
	list[CloneTuple] clonePairs = findClones(hashBuckets, similarityThreshold);

    return clonePairs;
}

list[CloneTuple] findClones(map[str, list[NodeLoc]] subtrees, real similarityThreshold bool type2=false) {
    list[CloneTuple] clonePairs = [];
    int counter = 0;
    int sizeS = size(subtrees);
    for (hash <- subtrees) {
        counter += 1;
        list[NodeLoc] nodes = subtrees[hash];
        for (i <- nodes, j <- nodes) {
                if (!type2 && i.l != j.l) {
                    clonePairs = addClone(clonePairs, <i.nodeLocNode, j.nodeLocNode>);
                }
                else if (i.l != j.l && toReal(nodeSimilarity(i.nodeLocNode, j.nodeLocNode)) >= similarityThreshold) {
                    clonePairs = addClone(clonePairs, <i.nodeLocNode, j.nodeLocNode>);
                }
        }
    }
    return clonePairs;
}

public list[CloneTuple] addClone(list[CloneTuple] clonePairs, CloneTuple newPair) {

    // Ignore the pair if one node is a subtree of another node
    bool isNewNodeABSubset = isNodeSubset(newPair.nodeA, newPair.nodeB);
    bool isNewNodeBASubset = isNodeSubset(newPair.nodeB, newPair.nodeA);

    if (isNewNodeABSubset || isNewNodeBASubset) {
        return clonePairs;
    }

    for (CloneTuple oldPair <- clonePairs) {
        // Check if the pair already exists in flipped form
        if (oldPair == <newPair.nodeB, newPair.nodeA> || oldPair == newPair) {
            return clonePairs;
        }

        // Ignore the pair if it is a subset of an already existing pair
        bool nodePairsIgnorable = areNodePairsIgnorable(oldPair, newPair);
        if (nodePairsIgnorable) {
            return clonePairs;
        }

        clonePairs = removePotentialOldSubsetPair(clonePairs, oldPair, newPair);
    }

    clonePairs += newPair;

    return clonePairs;
}

bool areNodePairsIgnorable(CloneTuple oldPair, CloneTuple newPair) {
    bool isOldSubsetCombo1 = isNodeSubset(oldPair.nodeA, newPair.nodeA);
    bool isOldSubsetCombo2 = isNodeSubset(oldPair.nodeB, newPair.nodeB);
    bool isOldSubsetCombo3 = isNodeSubset(oldPair.nodeA, newPair.nodeB);
    bool isOldSubsetCombo4 = isNodeSubset(oldPair.nodeB, newPair.nodeA);

    return (isOldSubsetCombo1 && isOldSubsetCombo2) || (isOldSubsetCombo3 && isOldSubsetCombo4);
}

list[CloneTuple] removePotentialOldSubsetPair(list[CloneTuple] clonePairs, CloneTuple oldPair, CloneTuple newPair) {
    bool isNewSubsetCombo1 = isNodeSubset(newPair.nodeA, oldPair.nodeA);
    bool isNewSubsetCombo2 = isNodeSubset(newPair.nodeB, oldPair.nodeB);
    bool isNewSubsetCombo3 = isNodeSubset(newPair.nodeA, oldPair.nodeB);
    bool isNewSubsetCombo4 = isNodeSubset(newPair.nodeB, oldPair.nodeA);

    // If the current old pair is a subset of the current new pair. Remove it.
    if ((isNewSubsetCombo1 && isNewSubsetCombo2) || (isNewSubsetCombo3 && isNewSubsetCombo4)) {
        clonePairs = clonePairs - [oldPair];
    }

    return clonePairs;
}

public list[DuplicationResult] getCloneClasses(list[DuplicationResult] duplicationResults) {
    list[DuplicationResult] cloneClasses = [];
    
    for(DuplicationResult resultTupleList <- duplicationResults) {
        DuplicationLocation maxSizedDuplicationLoc1 = resultTupleList[0];
        DuplicationLocation maxSizedDuplicationLoc2 = resultTupleList[1];        

        for(DuplicationResult duplicationResult <- duplicationResults) {
            for(DuplicationLocation itDuplicationResult <- duplicationResult){
                maxSizedDuplicationLoc1 = modifyPotentialMaxLoc(itDuplicationResult, maxSizedDuplicationLoc1);
                maxSizedDuplicationLoc2 = modifyPotentialMaxLoc(itDuplicationResult, maxSizedDuplicationLoc2);
            } 
        }

        DuplicationResult newDuplRes = [maxSizedDuplicationLoc1, maxSizedDuplicationLoc2];

        if(!containsDuplicationResult(cloneClasses, newDuplRes)) {
            cloneClasses += [newDuplRes];
        }
    }

    return cloneClasses;
}

DuplicationLocation modifyPotentialMaxLoc(DuplicationLocation duplLoc, DuplicationLocation maxDuplicationLoc) {
    if((duplLoc.filePath == maxDuplicationLoc.filePath) && (duplLoc.methodName == maxDuplicationLoc.methodName)) {
        if(duplLoc.startLine < maxDuplicationLoc.startLine) {
            maxDuplicationLoc.startLine = duplLoc.startLine;
        }

        if(duplLoc.endLine > maxDuplicationLoc.endLine) {
            maxDuplicationLoc.endLine = duplLoc.endLine;
        }
    }

    return maxDuplicationLoc;
}

bool containsDuplicationResult(list[DuplicationResult] results, DuplicationResult result) {
    bool containsResult = false;

    DuplicationLocation resultLoc1 = result[0];
    DuplicationLocation resultLoc2 = result[1];
    
    for(r <- results) {
        DuplicationLocation l1 = r[0];
        DuplicationLocation l2 = r[1];

        bool areLocsInDuplicationResult = areLocationsContainedInResultLocations(l1, l2, resultLoc1, resultLoc2);

        if(areLocsInDuplicationResult) {
            containsResult = true;
        }
    }
    return containsResult;
} 

bool areLocationsContainedInResultLocations(DuplicationLocation l1, DuplicationLocation l2, DuplicationLocation resultLoc1, DuplicationLocation resultLoc2) {
    bool containsInL1 = isLocContainedInResultLoc(l1, resultLoc1);
    bool containsInL2 = isLocContainedInResultLoc(l2, resultLoc2);

    bool reverseContainsInL1 = isLocContainedInResultLoc(l1, resultLoc2);
    bool reverseContainsInL2 = isLocContainedInResultLoc(l2, resultLoc1);

    return (containsInL1 && containsInL2) || (reverseContainsInL1 && reverseContainsInL2);
}

bool isLocContainedInResultLoc(DuplicationLocation duplLoc1, DuplicationLocation duplLoc2) {
    bool areD1D2FilePathsEqual = (duplLoc1.filePath == duplLoc2.filePath);
    bool areD1D2MethodNamesEqual = (duplLoc1.methodName == duplLoc2.methodName);
    bool areD1D2StartLinesEqual = (duplLoc1.startLine == duplLoc2.startLine);
    bool areD1D2EndLinesEqual = (duplLoc1.endLine == duplLoc2.endLine);

    return areD1D2FilePathsEqual && areD1D2MethodNamesEqual && areD1D2StartLinesEqual && areD1D2EndLinesEqual;
}