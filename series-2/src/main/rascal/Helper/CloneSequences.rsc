module Helper::CloneSequences

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;
import Helper::Helper;
import Type;


// map[node, list[node]] findSequenceCloneClasses(list[tuple[list[node], list[node]]] clonePairs) {
//     map[node, list[node]] cloneMap = (); 
//     for(pair <- clonePairs) { 
//         if (pair[0] in cloneMap) {
//             if (pair[1] notin cloneMap[pair[0]]) {
//                 cloneMap[pair[0]] += pair[1];
//             }
//         } else if (pair[1] in cloneMap) {
//             if (pair[0] notin cloneMap[pair[1]]) {
//                 cloneMap[pair[1]] += pair[0];
//             }
//         } else {
//             bool added = false;
//             for (key <- cloneMap) {
//                 if (pair[0] in cloneMap[key] && pair[1] notin cloneMap[key]) {
//                     cloneMap[key] += pair[1];
//                     added = true;
//                     break;
//                 } else if (pair[0] in cloneMap[key] && pair[1] in cloneMap[key]) {
//                     added = true;
//                 }
//             }
//             if (added == false) {
//                 for (key <- cloneMap) {
//                     if (pair[1] in cloneMap[key] && pair[0] notin cloneMap[key]) {
//                         cloneMap[key] += pair[0];
//                         added = true;
//                         break;
//                     }
//                 } 
//             }
//             if (added == false) {
//                 cloneMap[pair[0]] = [pair[1]];
//             }
//         }
//     }
//     return cloneMap;
// }

// tuple[node, int] findBiggestSequenceClone(list[tuple[list[node], list[node]]] clonePairs) {
//     int maxLines = 0;
//     node maxNode = clonePairs[0][0];
//     for(pair <- clonePairs) {
//         int numberOfLines = UnitLOC((pair[0]).src);
//         if (numberOfLines > maxLines) {
//             maxLines = numberOfLines;
//             maxNode = pair[0];
//         }
//     }
//     return <maxNode, maxLines>;
// }

// void getSequenceStatistics(list[tuple[list[node], list[node]]] clonePairs, loc projectLocation) {
//     println(clonePairs);
//     int numberOfClones = size(clonePairs);
//     println(numberOfClones);
//     node biggestClone = clonePairs[0][0];
//     int lines = 0;
//     <biggestClone, lines> = findBiggestSequenceClone(clonePairs);
//     map[node, list[node]] cloneClasses =  findSequenceCloneClasses(clonePairs);
//     int numberOfCloneClasses = 0;
//     int biggestCloneClass = 0;
//     int duplicatedLines = 0;
//     for (class <- cloneClasses) {
//         numberOfCloneClasses += 1;
//         int classSize = size(cloneClasses[class]);
//         duplicatedLines += (size(cloneClasses[class]) + 1) * UnitLOC(class.src);
//         if (classSize > biggestCloneClass) {
//             biggestCloneClass = classSize;
//         }
//     }
//     println(numberOfCloneClasses);
//     biggestCloneClass += 1;
//     int percentageOfDuplicatedLines = round(duplicatedLines * 100.0 / toReal(LOC(projectLocation))); 
// }

list[tuple[list[node], list[node]]] findSequenceClones(loc projectLocation, int cloneType) {
    list[Declaration] ast = getASTs(projectLocation);
    real similarityThreshold = 1.0;
    int minimumSequenceLengthThreshold = 3;
    if (cloneType == 2) {
        real similarityThreshold = 1.0;
    } if (cloneType == 3) {
        real similarityThreshold = 1.0;
    }
    map[str, list[list[node]]] hashTable = createSequenceHashTable(ast, minimumSequenceLengthThreshold, cloneType);
    // for (bucket <- hashTable) {
    //     println("<bucket>: <hashTable[bucket]> <size(hashTable[bucket])>\n");
    // }
    list[tuple[list[node], list[node]]] clonePairs = findSequenceClonePairs(hashTable, similarityThreshold, cloneType);
    // // println(clonePairs);
    // // for(pair <- clonePairs) {
    // //     println("pair = <pair[0]> <pair[1]> !!!!\n");
    // // }
    // getSequenceStatistics(clonePairs, projectLocation);
    return clonePairs;
}


map[str, list[list[node]]] createSequenceHashTable(list[Declaration] ast, int minimumSequenceLengthThreshold, int cloneType) {
    map[str, list[list[node]]] hashTable = ();
    list[list[node]] sequences = [];
    visit (ast) {
        case \block(statements): {
            list[node] sequence = statements;
            if (size(sequence) >= minimumSequenceLengthThreshold) {
                sequences += [sequence];
            }
        }
    }
    for (sequence <- sequences) {
        for (i <- [0..(size(sequence) + 1)], j <- [0..(size(sequence) + 1)]) {
            if ((j >= i + minimumSequenceLengthThreshold)) {
                list[node] subsequence = sequence[i..j];
                // hash every subsequence
                str subsequenceHash = "";
                for (n <- subsequence) {
                    subsequenceHash += md5Hash(unsetRec(n));
                }
                // println("<subsequence> <i> <j> <subsequenceHash>\n");
                str sequenceHash = md5Hash(subsequenceHash);
                // println("<subsequence> <i> <j> <subsequenceHash> <sequenceHash>\n");
                // if (cloneType == 2) {
                //     n = normalizeIdentifiers(n);
                // } else if (cloneType == 3) {
                //     n = normalizeIdentifiers(n);
                // }
                if (sequenceHash in hashTable) {
                    hashTable[sequenceHash] += [subsequence];
                } else {
                    hashTable[sequenceHash] = [subsequence];
                }
            }
        }
    }
    return hashTable;
}


list[tuple[list[node], list[node]]] removeSequenceSubclones(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    for(pair <- clones) {
        for(s <- i, s2 <- j){
                        if (pair[0] == s && pair[1] == s2) {
                            clones -= <s, s2>;
                        } else if (pair[0] == s2 && pair[1] == s) {
                            clones -= <s2, s>;
                        }
        }
    }
    return clones;   
}

bool canAddSequence(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    for(pair <- clones) {
        //for(member1 <- pair[0], member2 <- pair[1]) {
            //println(typeOf(member1));
            if(isSubset(pair[0], i) || isSubset(pair[1], j)){
                return false;
            }
        //}
    }
    return true;
}

bool isSubset(list[node] rootSequence, list[node] subSequence) {
    // If the root sequence entails the sub-sequence, it is a subset.
    if (isSubsequence(rootSequence, subSequence)) {
        return true;
    }

    // For every sequence node in the root, visit the subtree. If this subtree
    // has a sequence which entails our subsequence, it is a subset.
    for (node n <- rootSequence) {
        visit(n) {
            // subsequence is contained in sequence of the current node.
            case \block(statements): {
                list[node] sequence = statements;
                if (isSubsequence(statements, subSequence)) {
                    return true;
                }
            }
            // subsequence is contained in the current node
            case node n: {
                if (size(subSequence) == 1 && subSequence[0] == n) {
                    return true;
                }
            }
        }
    }
    return false;
}

bool isSubsequence(list[value] List, list[value] subList) {
    for (i <- [0..size(List)]) {
        int j = i + size(subList);
        if (List[i..j] == subList) {
            return true;
        }
    }
    return false;
}

list[tuple[list[node], list[node]]] addSequenceClone(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    // if clones is empty, just add the pair
    if (size(clones) == 0) {
        clones = [<i, j>];
        return clones;
    } else {
        // check if the pair is already in clones, as is or as a subclone
        if (<j,i> in clones) {
            return clones;
        }
        clones = removeSequenceSubclones(clones, i, j);
        if (canAddSequence(clones, i, j)) {
            // println("can add \n");
            clones += <i, j>;
        }
        return clones;
    }
}

list[tuple[list[node], list[node]]] findSequenceClonePairs(map[str, list[list[node]]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[list[node], list[node]]] clones = [];
    // for each sequence i and j in the same bucket
    int buckedIdx = 0;
	for (bucket <- hashTable) {	
        buckedIdx += 1;
        for (i <- hashTable[bucket], j <- hashTable[bucket]) {
            // ensure we are not comparing one thing with itself
            if (i != j) {
                // println("<i> <j>\n");
                real comparison = similarity(i, j);
                //println("Comparison: <comparison>");
                // check if are clones
                if (((cloneType == 1 && comparison == 1.0) || ((cloneType == 2 || cloneType == 3)) && (comparison >= similarityThreshold))) {
                    //println("<i> <j>\n");
                    //println("Comparison: <comparison>, Idx: <buckedIdx>");
                    clones = addSequenceClone(clones, i, j);
                }
            }
        }	
    }
    // println(size(clones));
    return clones;
}

int compareSequences(list[node] nodelist1, list[node] nodelist2) {
	list[node] nodelist1Nodes = [];
	list[node] nodelist2Nodes = [];

    for (nodeInList <- nodelist1) {
        visit (nodeInList) {
            case node n : {
                visit (n) {
                    case node nodeDeeper : {
                        nodelist1Nodes += [unsetRec(nodeDeeper)];
                    }
                }
            }
        }
    }

    for (nodeInList <- nodelist2) {
        visit (nodeInList) {
            case node n : {
                visit (n) {
                    case node nodeDeeper : {
                        nodelist2Nodes += [unsetRec(nodeDeeper)];
                    }
                }
            }
        }
    }

	int sharedNodes = size(nodelist1Nodes & nodelist2Nodes);
    int nodelist1NodesNumber = size(nodelist1Nodes - nodelist2Nodes);
    int nodelist2NodesNumber = size(nodelist2Nodes - nodelist1Nodes);
	return 2 * sharedNodes / (2 * sharedNodes + nodelist1NodesNumber + nodelist2NodesNumber);
} 

real similarity(list[node] subtrees1, list[node] subtrees2) {
    list[real] SLR = [0.0, 0.0, 0.0];
    for (i <- [0..size(subtrees1)]) {
        tuple[int S, int L, int R] currentSLR = sharedUniqueNodes(subtrees1[i], subtrees2[i]);
        SLR[0] += toReal(currentSLR[0]);
        SLR[1] += toReal(currentSLR[1]);
        SLR[2] += toReal(currentSLR[2]);
    }

    real similarity = 2.0 * SLR[0] / (2.0 * SLR[0] + SLR[1] + SLR[2]);
    return similarity;
}

tuple[int S, int L, int R] sharedUniqueNodes(node subtree1, node subtree2) {
    map[node, int] nodeCounter = ();
    int shared = 0;
    int unique = 0;

    visit(subtree1) {
        case node n: nodeCounter[unsetRec(n)]?0 += 1;
    }
    visit(subtree2) {
        case node n: {
            int a = nodeCounter[unsetRec(n)]?0;
            if (a > 0) {
                shared += 2;
                nodeCounter[unsetRec(n)] -= 1;
            } else {
                unique += 1;
            }
        }
    }

    return <shared, unique, 0>;
}