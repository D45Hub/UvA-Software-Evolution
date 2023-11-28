module Helper::SubsequenceHelper

import lang::java::m3::Core;
import lang::java::m3::AST;

import Helper::HashingHelper;
import Helper::Helper;

import List;
import Map;

private list[tuple[list[node], list[node]]] _sequenceClones = [];

map[str hash, list[list[node]] sequenceRoots] getSequences(list[Declaration] ASTs, int sequenceThreshold) {
    list[list[node]] sequences = [];
    visit(ASTs) {
        case \block(statements): {
            list[node] sequence = statements;

            if (size(sequence) >= sequenceThreshold) {
                sequences += [sequence];
            }
        }
    }

    // map[node, str] hashes = ();
    map[str, list[list[node]]] subsequences = ();
    for (list[node] sequence <- sequences) {
        
        for (i <- [0..(size(sequence) + 1)]) {
            for (j <- [0..(size(sequence) + 1)]) {

                if ((j >= i + sequenceThreshold)) {
                    list[node] subsequence = sequence[i..j];
                    
                    hash = hashSequence(subsequence, false);

                    subsequences[hash]?[] += [subsequence];
                }
            }
        }
    }

    return subsequences;
}

// Function to find sequence clones
list[tuple[list[node], list[node]]] findSequenceClones(map[str, list[list[node]]] sequences,
                        real similarityThreshold, bool print=false,
                        bool type2=false) {

    
    int counter = 0;
    int sizeS = size(sequences);

    for (hash <- sequences) {
        counter += 1;
        if (print) {
            println("Hash <counter> / <sizeS>. <hash>");
        }

        list[list[node]] subsequences = sequences[hash];

        for (i <- subsequences) {
            for (j <- subsequences) {
                if (! type2 && i != j) {
                    addSequenceClone(<i, j>, print=print);
                }
                else if (i != j) {
                    if (similarity(i, j) >= similarityThreshold) {
                        addSequenceClone(<i, j>, print=print);
                    } else if (print) {
                        println("SIMILARITY TOO LOW");
                    }
                }
            }
        }
    }

    return _sequenceClones;
}

// Function to add sequence clones to our list of clone pairs. Also implements
// subsumption in a similar way as is the case in addClone().
// This function includes some optional print functionality for debugging purposes.
public void addSequenceClone(tuple[list[node], list[node]] newPair, bool print=false) {
    if (print) {
        println("\n AddSequenceClone:");
        println("seq1:");
        printNodes(newPair[0]);
        println("seq2:");
        printNodes(newPair[1]);
    }

    // Ignore the pair if one node is a subtree of another node
    if (isNodeSubset(newPair[0], newPair[1]) || isNodeSubset(newPair[1], newPair[0])) {
        if (print) {
            println("one sequence is subset of other sequence");
        }
        return;
    }

    // Check the sequence pairs
    for (oldPair <- _sequenceClones) {
        // Check if the pair already exists in flipped form
        if (oldPair == <newPair[1], newPair[0]>) {
            if (print) {
                println("sequence pair already exists");
            }
            return;
        }

        // Ignore the pair if it is a subset of an already existing pair
        if ((isNodeSubset(oldPair[0], newPair[0]) && isNodeSubset(oldPair[1], newPair[1])) || (isNodeSubset(oldPair[0], newPair[1]) && isNodeSubset(oldPair[1], newPair[0]))) {
            if (print) {
                println("new pair is subset of existing pair");
            }
            return;
        }

        // If the current old pair is a subset of the current new pair. Remove
        // the old pair.
        if ((isNodeSubset(newPair[0], oldPair[0]) && isNodeSubset(newPair[1], oldPair[1])) || (isNodeSubset(newPair[0], oldPair[1]) && isNodeSubset(newPair[1], oldPair[0]))) {
            _sequenceClones -= oldPair;

            if (print) {
                println("REMOVED SEQUENCE CLONE");
                println("Sequence1: ");
                for (node n <- oldPair[0]) {
                    println(n.src);
                }
                println("Sequence2: ");
                for (node n <- oldPair[1]) {
                    println(n.src);
                }
            }
        }
    }

    // Check the atomic pairs.
    for (oldPair <- _clonePairs) {
        // Check if the new pair already exists as atomic pair(normal and flipped) (only for sequence length 1)

        // Ignore the new sequence pair if it is a subset of an already existing atomic pair
        if ((isNodeSubset([oldPair[0]], newPair[0]) && isNodeSubset([oldPair[1]], newPair[1])) || (isNodeSubset([oldPair[0]], newPair[1]) && isNodeSubset([oldPair[1]], newPair[0]))) {
            if (print) {
                println("New pair is subset of atomic pair: <oldPair[0].src> <oldPair[1].src>");
            }
            return;
        }

        // If the current atomic pair is a subset of the current new sequence pair. Remove it.
        if ((isNodeSubset(newPair[0], [oldPair[0]]) && isNodeSubset(newPair[1], [oldPair[1]])) || (isNodeSubset(newPair[0], [oldPair[1]]) && isNodeSubset(newPair[1], [oldPair[0]]))) {
            _clonePairs -= oldPair;

            if (print) {
                println("Removed atomic pair");
                println(" clone1: <oldPair[0].src> \n clone2: <oldPair[1].src>");
            }
        }
    }

    _sequenceClones += newPair;

    if (print) {
        println("ADDED SEQUENCE CLONE");
        println("Sequence1: ");
        for (node n <- newPair[0]) {
            println(n.src);
        }
        println("Sequence2: ");
        for (node n <- newPair[1]) {
            println(n.src);
        }
    }

    return;
}