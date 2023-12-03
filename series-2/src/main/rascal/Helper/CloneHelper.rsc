module Helper::CloneHelper
import Helper::ProjectHelper;
import Helper::Types;

import util::UUID;
import String;
import IO;

public list[CloneTuple] getClonePairs(list[NodeHashLoc] hashedSubtrees, num similarityThreshold) {
    map[str, list[NodeLoc]] hashBuckets = placingSubTreesInBuckets(hashedSubtrees);
	list[CloneTuple] clonePairs = findClones(hashBuckets, similarityThreshold);

    return clonePairs;
}

list[CloneTuple] findClones(map[str, list[NodeLoc]] subtrees, real similarityThreshold bool type2=false) {
    list[CloneTuple] clonePairs = [];
    for (hash <- subtrees) {
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

        list[str] rawAMethodContent = split("\n", readFile(toLocation(maxSizedDuplicationLoc1.fileUri)));
        list[str] rawALocationContent = rawAMethodContent[(maxSizedDuplicationLoc1.startLine)..(maxSizedDuplicationLoc1.endLine)];
        str joinedALocString = ("" | it + "\n" + s | s <- rawALocationContent);
        str base64NodeAContent = toBase64(joinedALocString);

        list[str] rawBMethodContent = split("\n", readFile(toLocation(maxSizedDuplicationLoc2.fileUri)));
        list[str] rawBLocationContent = rawBMethodContent[(maxSizedDuplicationLoc2.startLine)..(maxSizedDuplicationLoc2.endLine)];
        str joinedBLocString = ("" | it + "\n" + s | s <- rawBLocationContent);
        str base64NodeBContent = toBase64(joinedBLocString);

        maxSizedDuplicationLoc1.base64Content = base64NodeAContent;
        maxSizedDuplicationLoc2.base64Content = base64NodeBContent;

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

list[DuplicationResult] getRawDuplicationResults(list[tuple[list[node], list[node]]] sequenceClones, map[loc fileLoc, MethodLoc method] mapLocs) {
    list[DuplicationResult] duplicationResults = [];
    for(c <- sequenceClones) {

        //set[tuple[int from, int to]] maxAmount = ();
        int maxFromLineA = -1;
        int maxToLineA = -1;
        int maxFromLineB = -1;
        int maxToLineB = -1;
        loc nodeALoc = noLocation;
        loc nodeBLoc = noLocation;

        for(nodeA <- c[0], nodeB <- c[1]) {
            nodeALoc = nodeFileLocation(nodeA);
            nodeBLoc = nodeFileLocation(nodeB);

            if(maxFromLineA == -1 && maxToLineA == -1) {
                maxFromLineA = nodeALoc.begin.line;
                maxToLineA = nodeALoc.end.line;
            }
            
            if(nodeALoc.begin.line < maxFromLineA) {
                maxFromLineA = nodeALoc.begin.line;
            }

            if(nodeALoc.end.line > maxToLineA) {
                // WHY NOT MAXTOLINEB? THIS DOES NOT WORK OTHERWISE...
                maxFromLineA = nodeALoc.end.line;
            }

            


            if(maxFromLineB == -1 && maxToLineB == -1) {
                maxFromLineB = nodeBLoc.begin.line;
                maxToLineB = nodeBLoc.end.line;
            }
            
            if(nodeBLoc.begin.line < maxFromLineA) {
                maxFromLineB = nodeBLoc.begin.line;
            }

            if(nodeBLoc.end.line > maxToLineB) {
                // WHY NOT MAXTOLINEB? THIS DOES NOT WORK OTHERWISE...
                maxFromLineB = nodeBLoc.end.line;
            }
        }

// TODO REFACTOR THIS RADIOACTIVE GLOWING SHIT... I DONT WANT ANYMORE... IT IS LATE...
        MethodLoc methodA = <noLocation, -1>;
        MethodLoc methodB = <noLocation, -1>;
        for(k <- mapLocs) {
            str nodeAFileName = nodeALoc.path;
            str nodeBFileName = nodeBLoc.path;
            str projectFileName = k.uri;
            if(contains(projectFileName, nodeAFileName) && nodeALoc.begin.line >= k.begin.line && nodeALoc.end.line <= k.end.line) {
                methodA = mapLocs[k];

                if(methodB.methodLocation != noLocation && methodB.methodLoc != -1){
                    break;
                }
            }

            if(contains(projectFileName, nodeBFileName) && nodeBLoc.begin.line >= k.begin.line && nodeBLoc.end.line <= k.end.line) {
                methodB = mapLocs[k];
                if(methodA.methodLocation != noLocation && methodA.methodLoc != -1){
                    break;
                }
            }
        }

        

        str duplicationUUID = toString(uuidi());
        DuplicationLocation res1 = <duplicationUUID, nodeALoc.path, nodeALoc.uri, methodA<0>.path, methodA<1>, maxToLineA, maxFromLineA, "">;
        duplicationUUID = toString(uuidi());
        DuplicationLocation res2 = <duplicationUUID, nodeBLoc.path, nodeBLoc.uri, methodB<0>.path, methodB<1>, maxToLineB, maxFromLineB, "">;
        DuplicationResult dRes = [res1, res2];

        duplicationResults += [dRes];
    }  

    return duplicationResults;
}

DuplicationResult getLargestDuplicationClass(list[DuplicationResult] cloneClasses) {
    DuplicationResult biggestDuplicationClass = cloneClasses[0];
    DuplicationLocation biggestDuplicationLoc = biggestDuplicationClass[0];
    int biggestDuplLines = biggestDuplicationLoc.endLine - biggestDuplicationLoc.startLine;

    for(itClass <- cloneClasses) {
        DuplicationLocation itDuplicationLoc = itClass[0];
        int itDuplicationLines = (itDuplicationLoc.endLine - itDuplicationLoc.startLine);
        if(biggestDuplLines < itDuplicationLines) {
            biggestDuplLines = itDuplicationLines;
            biggestDuplicationLoc = itDuplicationLoc;
            biggestDuplicationClass = itClass;
        }
    }

    return biggestDuplicationClass;
} 