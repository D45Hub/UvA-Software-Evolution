module Helper::SubsequenceHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;
import Helper::Helper;
import Type;
import Boolean;
import Set;

//Type defaultType = lang::java::jdt::m3::AST::short();

map[tuple[list[node] zNode, list[node] i] zList, str subsetResult] zeroSubsetResults = ();
map[tuple[list[node] oNode, list[node] j] oList, str subsetResult] oneSubsetResults = ();

map[node uNode, int uniqueNodes] uniqueNodes = ();

// One sequence is a list of statements. 
// This represents the list structure in the paper
/* 
{x=0; if(d>1) ... } hashcodes = 675, 3004
so e.g. [[[x=0;, if(d>1);]],[[y=1;, z= 2;]]]
*/ 
list[list[node]] getListOfSequences(list[Declaration] ast, int minimumSequenceLengthThreshold) {
    list[list[node]] sequences = [];
    visit (ast) {
        /**
        * This block makes use of the https://www.rascal-mpl.org/docs/Rascal/Statements/Block/ 
        * statement in rascal which detects sequences, mostly separated by a ; 
        * 
        */ 
        case \block(list[Statement] statements): {
            /* You are putting the statements into a list of node -> Why temporal? */ 
            list[node] sequence = statements;
            if (size(statements) >= minimumSequenceLengthThreshold) {
                // Why are you using a list in here and not just adding the sequence which is already a list?
                
                sequences += [sequence]; // Sequences list.
            }
        }
    }
    return sequences;
}

map[str, list[list[node]]] createSequenceHashTable(list[Declaration] ast, int minimumSequenceLengthThreshold, int cloneType) {
    map[str, list[list[node]]] hashTable = ();
    list[list[node]] sequences = getListOfSequences(ast, minimumSequenceLengthThreshold);

    map[node, str] nodeHashMap = ();
    
    for (sequence <- sequences) {
        int sequenceSize = size(sequence);
        for (i <- [0..(sequenceSize + 1)], j <- [0..(sequenceSize + 1)]) {
            if ((j >= i + minimumSequenceLengthThreshold)) {
                list[node] subsequence = sequence[i..j];
                // hash every subsequence
                str subsequenceHash = "";
                for (n <- subsequence) {
                    /**
                    if (cloneType == 2) {
                        n = normalizeIdentifiers(n);
                    }
                    */

                    if(n in nodeHashMap) {
                        subsequenceHash += nodeHashMap[n];
                    } else {
                        str nodeHash = md5Hash(unsetRec(n));
                        nodeHashMap[n]?"" += nodeHash; 
                        subsequenceHash += nodeHash;
                    }
                    
                }
                str sequenceHash = md5Hash(subsequenceHash);
                // println("<subsequence> <i> <j> <subsequenceHash> <sequenceHash>\n");
                 //else if (cloneType == 3) {
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
    set[tuple[list[node], list[node]]] cloneSet = toSet(clones);
    set[tuple[list[node], list[node]]] sequencesToRemove = {[s, s2] | pair <- clones, s <- i, s2 <- j, (pair[0] == s && pair[1] == s2) || (pair[0] == s2 && pair[1] == s)};

    return toList(cloneSet - sequencesToRemove);
}

bool canAddSequence(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    return all(pair <- clones, !(checkSubset(pair[0], pair[1], i, j))); 
}

bool checkSubset(list[node] zeroNode, list[node] oneNode, list[node] i, list[node] j) {
    bool zeroValue = false;
    bool oneValue = false;

    if(<zeroNode,i> in zeroSubsetResults) {
        zeroValue = fromString(zeroSubsetResults[<zeroNode,i>]);
    } else {
        zeroValue = isSubset(zeroNode, i);
        str zeroValueString = toString(zeroValue);
        zeroSubsetResults[<zeroNode,i>]?"" += zeroValueString;
    }

    if(zeroValue) {
        return true;
    }

    if(<oneNode,j> in oneSubsetResults) {
        oneValue = fromString(oneSubsetResults[<oneNode,j>]);
    } else {
        oneValue = isSubset(oneNode, j);
        str oneValueString = toString(oneValue);
        oneSubsetResults[<oneNode,j>]?"" += oneValueString;
    }

    return oneValue;    
}

list[tuple[list[node], list[node]]] addSequenceClone(list[tuple[list[node], list[node]]] clones, list[node] i, list[node] j) {
    // if clones is empty, just add the pair
    if (size(clones) == 0) {
        clones = [<i, j>];
    } else {
        // check if the pair is already in clones, as is or as a subclone
        if (<j,i> in clones) {
            return clones;
        }
        clones = removeSequenceSubclones(clones, i, j);
        if (canAddSequence(clones, i, j)) {
            clones += <i, j>;
        }
    }

    return clones;
}

list[tuple[list[node], list[node]]] findSequenceClonePairs(map[str, list[list[node]]] hashTable, real similarityThreshold, int cloneType) {
    list[tuple[list[node], list[node]]] clones = [];
    map[str, real] similarityMap = ();

    // for each sequence i and j in the same bucket
	for (bucket <- hashTable) {	
        for (i <- hashTable[bucket], j <- hashTable[bucket] - [i]) {
            // ensure we are not comparing one thing with itself
                str iString = toString(i);
                str jString = toString(j);
                str listStr = iString + jString;
                str listStrRev = jString + iString;
                real comparison = 0.0;
                if(listStr in similarityMap) {
                    comparison = similarityMap[listStr];
                } else if (listStrRev in similarityMap) {
                    comparison = similarityMap[listStrRev];
                } else {
                    comparison = similarity(i, j);
                    similarityMap[listStr]?0.0 = comparison;
                }
                // check if are clones
                if (((cloneType == 1 && comparison == 1.0) || ((cloneType == 2 || cloneType == 3)) && (comparison >= similarityThreshold))) {
                    clones = addSequenceClone(clones, i, j);
                }
        }	
    }
    return clones;
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