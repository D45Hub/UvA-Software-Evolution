module Helper::CloneHelper
import Helper::ProjectHelper;
import Helper::NodeHelpers;
import Helper::Types;

import Set;
import String;
import IO;
import util::Math;
import List;

map[str fileLoc, str fileContent] fileContentMap = ();
map[node n, MethodLoc methodLoc] nodeMethodCache = ();

public list[DuplicationResult] getCloneClasses(list[DuplicationResult] duplicationResults) {
    list[DuplicationResult] cloneClasses = [];
    map[DuplicationLocation, list[tuple[int, int]]] locMap = getModifiedLocMap(duplicationResults);

    for(DuplicationLocation l <- locMap) {
        DuplicationResult r = [];

        for(tuple[int, int] t <- locMap[l]) {
            l.startLine = t<0>;
            l.endLine = t<1>;
            r += [l];
        }
        if(size(r) > 0) {
            cloneClasses += [r];
        }
    }

    list[DuplicationResult] finalCloneClasses = [];
    for (DuplicationResult result <- cloneClasses) {
        DuplicationResult res = [];
        for (DuplicationLocation l <- result) {
            str concatDuplLocValues = "<l.filePath><l.fileUri><l.methodName><l.methodLoc><l.startLine><l.endLine>";
            l.uuid = md5Hash(concatDuplLocValues);
            l.base64Content = getBase64FileFromDuplicationLocation(l);
            res += [l];
        }
        finalCloneClasses += [res];
    }

    return finalCloneClasses;
}

map[DuplicationLocation, list[tuple[int, int]]] getLocMap(list[DuplicationResult] duplicationResults) {
    map[DuplicationLocation, list[tuple[int, int]]] fileMethodMap = ();

    for (DuplicationResult dupResult <- duplicationResults) {
        for (DuplicationLocation location <- dupResult) {
            DuplicationLocation normalizedDuplLocKey = location;
            normalizedDuplLocKey.uuid = "test";
            normalizedDuplLocKey.startLine = 0;
            normalizedDuplLocKey.endLine = 0;
            tuple[int, int] val = <location.startLine, location.endLine>;

            if (normalizedDuplLocKey in fileMethodMap) {
                set[tuple[int, int]] keySet = toSet(fileMethodMap[normalizedDuplLocKey]);
                keySet += {val};
                fileMethodMap[normalizedDuplLocKey] = toList(keySet);
            } else {
                fileMethodMap[normalizedDuplLocKey] = [val];
            }
        }
    }
    return fileMethodMap;
}

map[DuplicationLocation, list[tuple[int, int]]] getModifiedLocMap(list[DuplicationResult] duplicationResults) {
    map[DuplicationLocation, list[tuple[int, int]]] rawLocMap = getLocMap(duplicationResults);
    map[DuplicationLocation, list[tuple[int, int]]] filteredLocMap = ();
    for(DuplicationLocation key <- rawLocMap) {
        list[tuple[int, int]] lineTuples = rawLocMap[key];
        list[tuple[int, int]] trimmedTransitiveTuples = getTrimmedTransitiveClosures(lineTuples);
        filteredLocMap[key] = trimmedTransitiveTuples;
    }

    return filteredLocMap;
}

list[tuple[int, int]] getTrimmedTransitiveClosures(list[tuple[int, int]] locLinesList) {
    list[tuple[int, int]] trLinesList = getLocTransitiveClosure(locLinesList);
    return trimTransitiveClosures(trLinesList);
}

list[tuple[int, int]] getLocTransitiveClosure(list[tuple[int, int]] locLinesList) {
    list[tuple[int, int]] transClosureList = locLinesList+;

    list[tuple[int, int]] sortedTransClosureList = sort(transClosureList, bool(tuple[int, int] a, tuple[int, int] b) { return (a<1> - a<0>) > (b<1> - b<0>);});
    return sortedTransClosureList;
}

list[tuple[int, int]] trimTransitiveClosures(list[tuple[int, int]] locLinesList) {
    set[tuple[int, int]] trimmedClosures = {};

    for (tuple[int, int] tClosure <- locLinesList) {
        bool fullyIncluded = false;

        for (tuple[int, int] iClosure <- locLinesList) {
            if (tClosure == iClosure) {
                continue;
            }

            if (iClosure<0> <= tClosure<0> && iClosure<1> >= tClosure<1>) {
                fullyIncluded = true;
                break;
            }

            if ((iClosure<0> <= tClosure<1> && iClosure<1> >= tClosure<0>) ||
                (iClosure<0> <= tClosure<0> && iClosure<1> >= tClosure<0> - 1)) {
                // Merge the intervals
                tClosure = <min(iClosure<0>, tClosure<0>), max(iClosure<1>, tClosure<1>)>;
            }
        }

        if (!fullyIncluded) {
            trimmedClosures += {tClosure};
        }
    }

    return toList(trimmedClosures);
}

str getBase64FileFromDuplicationLocation(DuplicationLocation duplicationLocation) {
    str locUri = duplicationLocation.fileUri;
    loc fileLocation = toLocation(locUri);
    str fileContent = "";

    if(locUri in fileContentMap) {
        fileContent = fileContentMap[locUri];
    } else {
        fileContent = readFile(fileLocation);
        fileContentMap[locUri]?"" = fileContent;
    } 

    list[str] rawMethodContent = split("\n", fileContent);
    list[str] rawLocationContent = rawMethodContent[(duplicationLocation.startLine - 1)..(duplicationLocation.endLine)];
    str joinedLocString = ("" | it + "\n" + s | s <- rawLocationContent);
    str base64NodeContent = toBase64(joinedLocString);

    return base64NodeContent;
}

list[DuplicationResult] getRawDuplicationResults(list[tuple[list[node], list[node]]] sequenceClones, list[tuple[node, node]] wholeClones, map[loc fileLoc, MethodLoc method] mapLocs, bool performanceMode) {
    list[DuplicationResult] duplicationResults = [];

    for(tuple[node, node] wholeClone <- wholeClones) {
        loc aLoc = nodeFileLocation(wholeClone<0>);
        loc bLoc = nodeFileLocation(wholeClone<1>);
        str nodeAFileName = aLoc.path;
        str nodeBFileName = bLoc.path;

        MethodLoc methodA = <noLocation, -1>;
        MethodLoc methodB = <noLocation, -1>;

        if(wholeClone<0> in nodeMethodCache) {
            methodA = nodeMethodCache[wholeClone<0>];
        }

        if(wholeClone<1> in nodeMethodCache) {
            methodB = nodeMethodCache[wholeClone<1>];
        }

        if(methodA == <noLocation, -1> || methodB == <noLocation, -1>) {
            for(k <- mapLocs) {
                str projectFileName = k.uri;
                
                int mapLocBeginLine = k.begin.line;
                int mapLocEndLine = k.end.line;
                bool areALinesInBounds = areCodeLinesInBounds(mapLocBeginLine, mapLocEndLine, aLoc.begin.line, aLoc.end.line);
                bool areBLinesInBounds = areCodeLinesInBounds(mapLocBeginLine, mapLocEndLine, bLoc.begin.line, bLoc.end.line);

                if(contains(projectFileName, nodeAFileName) && areALinesInBounds) {
                    methodA = mapLocs[k];
                    nodeMethodCache[wholeClone<0>] = methodA;

                    if(methodB.methodLocation != noLocation && methodB.methodLoc != -1){
                        break;
                    }
                }

                if(contains(projectFileName, nodeBFileName) && areBLinesInBounds) {
                    methodB = mapLocs[k];
                    nodeMethodCache[wholeClone<1>] = methodB;
                    if(methodA.methodLocation != noLocation && methodA.methodLoc != -1){
                        break;
                    }
                }
            }
        }

        DuplicationLocation l1 = generateDuplicationLocation(aLoc, methodA);
        DuplicationLocation l2 = generateDuplicationLocation(bLoc, methodB);
        duplicationResults += [[l1,l2]];
    }

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
                maxFromLineA = nodeALoc.end.line;
            }

            if(nodeBLoc.begin.line < maxFromLineA) {
                maxFromLineB = nodeBLoc.begin.line;
            }

            if(nodeBLoc.end.line > maxToLineB) {
                maxFromLineB = nodeBLoc.end.line;
            }
        }

        LocationLines nodeABounds = <maxFromLineA, maxToLineA>;
        LocationLines nodeBBounds = <maxFromLineB, maxToLineB>;
        DuplicationResult dRes = [];

        if(performanceMode) {
            DuplicationLocation res1 = generateDuplicationLocation(nodeALoc, <noLocation, -1>, nodeABounds);
            DuplicationLocation res2 = generateDuplicationLocation(nodeBLoc, <noLocation, -1>, nodeBBounds);
            dRes += [res1, res2];
        } else {
            dRes = getNewAddedDuplicationResults(nodeALoc, nodeBLoc, mapLocs, nodeABounds, nodeBBounds);
        }

        duplicationResults += [dRes];
    }  

    return duplicationResults;
}

DuplicationResult getLargestMemberDuplicationClass(list[DuplicationResult] cloneClasses) {
    if(size(cloneClasses) == 0) {
        return [];
    }

    DuplicationResult biggestDuplicationClass = cloneClasses[0];

    for(itClass <- cloneClasses) {
        if(size(itClass) > size(biggestDuplicationClass)) {
            biggestDuplicationClass = itClass;
        }
    }

    return biggestDuplicationClass;
}

DuplicationResult getLargestLinesDuplicationClass(list[DuplicationResult] cloneClasses) {
    if(size(cloneClasses) == 0) {
        return [];
    }

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

DuplicationLocation generateDuplicationLocation(loc nodeLocation, MethodLoc nodeMethodLocation) {
    str nodeLocationPath = nodeLocation.path;
    str nodeLocationUri = nodeLocation.uri;
    str methodPath = nodeMethodLocation<0>.path;
    int methodLOC = nodeMethodLocation<1>;
    int minLine = nodeLocation.begin.line;
    int maxLine = nodeLocation.end.line;

    str concatDuplLocValues = "<nodeLocationPath><nodeLocationUri><methodPath><methodLOC><minLine><maxLine>";
    str duplicationUUID = md5Hash(concatDuplLocValues);

    DuplicationLocation result = <duplicationUUID, nodeLocationPath, nodeLocationUri, methodPath, methodLOC, minLine, maxLine, "">;
    return result;
}

DuplicationLocation generateDuplicationLocation(loc nodeLocation, MethodLoc nodeMethodLocation, LocationLines nodeMaxBounds) {
    str nodeLocationPath = nodeLocation.path;
    str nodeLocationUri = nodeLocation.uri;
    str methodPath = nodeMethodLocation<0>.path;
    int methodLOC = nodeMethodLocation<1>;
    int minLine = nodeMaxBounds.lineTo;
    int maxLine = nodeMaxBounds.lineFrom;

    str concatDuplLocValues = "<nodeLocationPath><nodeLocationUri><methodPath><methodLOC><minLine><maxLine>";
    str duplicationUUID = md5Hash(concatDuplLocValues);

    DuplicationLocation result = <duplicationUUID, nodeLocationPath, nodeLocationUri, methodPath, methodLOC, minLine, maxLine, "">;
    return result;
}

map[str, list[str]] generateCloneConnectionMap(TransitiveCloneConnections connections) {
    map[str, list[str]] cloneConnectionMap = ();
    
    for(conn <- connections) {
        list[str] connValues = [];
        str connID = conn<0>;

        for(c <- connections) {
            if(c<0> == connID) {
                connValues += c<1>;
            }
        }

        cloneConnectionMap[connID]?[] += connValues;
    } 

    return cloneConnectionMap;
}

DuplicationLocation getDuplicationLocationFromID(list[DuplicationResult] results, str id) {
    for(DuplicationResult duplicationResult <- results) {
        for(DuplicationLocation duplicationLocation <- duplicationResult) {
            if(duplicationLocation.uuid == id) {
                return duplicationLocation;
            }
        }
    }

    return <"", "", "", "", 0, 0, 0, "">;
}

list[DuplicationResult] getFilteredDuplicationResultList(list[DuplicationResult] results, map[str, list[str]] connections) {
    set[DuplicationResult] filteredResults = {};
    for(connectionKey <- connections) {
        list[str] mappedConnections = connections[connectionKey];
        mappedConnections += [connectionKey];
        DuplicationResult duplicationResult = toList(toSet([getDuplicationLocationFromID(results, conn) | conn <- mappedConnections]));
        duplicationResult = [r | r <- duplicationResult, r != <"", "", "", "", 0, 0, 0, "">];
        
        if(size(duplicationResult) > 1 && !isSubset(duplicationResult, filteredResults)) {
            filteredResults += {duplicationResult};
        }
    }
    return (toList(filteredResults));
}

list[DuplicationResult] filterDuplicates(list[DuplicationResult] results) {
    set[str] seenUUIDs = {};
    list[DuplicationResult] filteredResults = [];

    for (DuplicationResult result <- results) {
        str uuid = result[0][0]; // Assuming the UUID is the first element in the first DuplicationLocation

        if (!(uuid in seenUUIDs)) {
            seenUUIDs += {uuid};

            // Find the largest DuplicationResult with the same UUID
            DuplicationResult largestResult = result;
            for (DuplicationResult otherResult <- results) {
                if (otherResult[0][0] == uuid && size(otherResult) > size(largestResult)) {
                    largestResult = otherResult;
                }
            }

            filteredResults += [largestResult];
        }
    }

    return filteredResults;
}

// Function to check if one DuplicationResult is a subset of another
bool isSubset(DuplicationResult result1, set[DuplicationResult] result2) {
    return any(r2 <- result2, all(loc1 <- result1, loc1 in r2));
}

/** Returns transitive closure of nodes*/ 
public TransitiveCloneConnections getCloneConnections (CloneConnections idPairs) {
    return idPairs+;
}

public CloneConnections extractIDPairs (list[DuplicationResult] duplicationResults) {
    return [<duplicationResult[0].uuid, duplicationResult[1].uuid> | duplicationResult <- duplicationResults];
}

void resetFileContentMap() {
    fileContentMap = ();
}