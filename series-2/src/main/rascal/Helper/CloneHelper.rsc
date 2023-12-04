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

        maxSizedDuplicationLoc1.base64Content = getBase64FileFromDuplicationLocation(maxSizedDuplicationLoc1);
        maxSizedDuplicationLoc2.base64Content = getBase64FileFromDuplicationLocation(maxSizedDuplicationLoc2);

        DuplicationResult newDuplRes = [maxSizedDuplicationLoc1, maxSizedDuplicationLoc2];

        if(!containsDuplicationResult(cloneClasses, newDuplRes)) {
            cloneClasses += [newDuplRes];
        }
    }

    return cloneClasses;
}

str getBase64FileFromDuplicationLocation(DuplicationLocation maxSizedDuplicationLocation) {
    list[str] rawMethodContent = split("\n", readFile(toLocation(maxSizedDuplicationLocation.fileUri)));
    list[str] rawLocationContent = rawMethodContent[(maxSizedDuplicationLocation.startLine)..(maxSizedDuplicationLocation.endLine)];
    str joinedLocString = ("" | it + "\n" + s | s <- rawLocationContent);
    str base64NodeContent = toBase64(joinedLocString);

    return base64NodeContent;
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

    return any(DuplicationResult res <- results, areLocationsContainedInResultLocations(res[0], res[1], resultLoc1, resultLoc2));
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

        loc nodeALoc = nodeFileLocation((c[0])[0]);
        loc nodeBLoc = nodeFileLocation((c[1])[0]);
        int maxFromLineA = nodeALoc.begin.line;
        int maxToLineA = nodeALoc.end.line;
        int maxFromLineB = nodeBLoc.begin.line;
        int maxToLineB = nodeBLoc.end.line;

        for(nodeA <- c[0], nodeB <- c[1]) {
            nodeALoc = nodeFileLocation(nodeA);
            nodeBLoc = nodeFileLocation(nodeB);
            
            if(nodeALoc.begin.line < maxFromLineA) {
                maxFromLineA = nodeALoc.begin.line;
            }

            if(nodeALoc.end.line > maxToLineA) {
                // WHY NOT MAXTOLINEA? THIS DOES NOT WORK OTHERWISE...
                maxFromLineA = nodeALoc.end.line;
            }

            
            if(nodeBLoc.begin.line < maxFromLineA) {
                maxFromLineB = nodeBLoc.begin.line;
            }

            if(nodeBLoc.end.line > maxToLineB) {
                // WHY NOT MAXTOLINEB? THIS DOES NOT WORK OTHERWISE...
                maxFromLineB = nodeBLoc.end.line;
            }
        }

        LocationLines nodeABounds = <maxFromLineA, maxToLineA>;
        LocationLines nodeBBounds = <maxFromLineB, maxToLineB>;
        DuplicationResult dRes = getNewAddedDuplicationResults(nodeALoc, nodeBLoc, mapLocs, nodeABounds, nodeBBounds);

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

bool areCodeLinesInBounds(int minBound, int maxBound, int minTestedValue, int maxTestedValues) {
    return (minTestedValue >= minBound && maxTestedValues <= maxBound);
}

DuplicationResult getNewAddedDuplicationResults(loc nodeALoc, loc nodeBLoc, map[loc fileLoc, MethodLoc method] mapLocs, LocationLines nodeABounds, LocationLines nodeBBounds) {
    MethodLoc methodA = <noLocation, -1>;
    MethodLoc methodB = <noLocation, -1>;
    for(k <- mapLocs) {
        str nodeAFileName = nodeALoc.path;
        str nodeBFileName = nodeBLoc.path;
        str projectFileName = k.uri;

        int mapLocBeginLine = k.begin.line;
        int mapLocEndLine = k.end.line;

        bool areALinesInBounds = areCodeLinesInBounds(mapLocBeginLine, mapLocEndLine, nodeALoc.begin.line, nodeALoc.end.line);
        bool areBLinesInBounds = areCodeLinesInBounds(mapLocBeginLine, mapLocEndLine, nodeBLoc.begin.line, nodeBLoc.end.line);

        if(contains(projectFileName, nodeAFileName) && areALinesInBounds) {
            methodA = mapLocs[k];

            if(methodB.methodLocation != noLocation && methodB.methodLoc != -1){
                break;
            }
        }

        if(contains(projectFileName, nodeBFileName) && areBLinesInBounds) {
            methodB = mapLocs[k];
            if(methodA.methodLocation != noLocation && methodA.methodLoc != -1){
                break;
            }
        }
    }   

    DuplicationLocation res1 = generateDuplicationLocation(nodeALoc, methodA, nodeABounds);
    DuplicationLocation res2 = generateDuplicationLocation(nodeBLoc, methodB, nodeBBounds);

    return [res1, res2];
}

DuplicationLocation generateDuplicationLocation(loc nodeLocation, MethodLoc nodeMethodLocation, LocationLines nodeMaxBounds) {
    str duplicationUUID = toString(uuidi());

    str nodeLocationPath = nodeLocation.path;
    str nodeLocationUri = nodeLocation.uri;
    str methodPath = nodeMethodLocation<0>.path;
    int methodLOC = nodeMethodLocation<1>;
    int minLine = nodeMaxBounds.lineTo;
    int maxLine = nodeMaxBounds.lineFrom;

    DuplicationLocation result = <duplicationUUID, nodeLocationPath, nodeLocationUri, methodPath, methodLOC, minLine, maxLine, "">;
    return result;
}