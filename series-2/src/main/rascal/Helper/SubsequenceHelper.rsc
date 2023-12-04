module Helper::SubsequenceHelper

import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Node;
import List;
import util::Math;
import Helper::Helper;
import Type;


// One sequence is a list of statements. 
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
    
    for (sequence <- sequences) {
        for (i <- [0..(size(sequence) + 1)], j <- [0..(size(sequence) + 1)]) {
            if ((j >= i + minimumSequenceLengthThreshold)) {
                list[node] subsequence = sequence[i..j];
                // hash every subsequence
                str subsequenceHash = "";
                for (n <- subsequence) {
                    subsequenceHash += md5Hash(unsetRec(n));
                }
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
        if(isSubset(pair[0], i) || isSubset(pair[1], j)){
            return false;
        }
    }
    return true;
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
    // for each sequence i and j in the same bucket
	for (bucket <- hashTable) {	
        for (i <- hashTable[bucket], j <- hashTable[bucket]) {
            // ensure we are not comparing one thing with itself
            if (i != j) {
                real comparison = similarity(i, j);
                // check if are clones
                if (((cloneType == 1 && comparison == 1.0) || ((cloneType == 2 || cloneType == 3)) && (comparison >= similarityThreshold))) {
                    clones = addSequenceClone(clones, i, j);
                }
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