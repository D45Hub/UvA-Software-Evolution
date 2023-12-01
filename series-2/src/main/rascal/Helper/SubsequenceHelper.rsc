module Helper::SubsequenceHelper

import lang::java::m3::Core;
import lang::java::m3::AST;

import Helper::HashingHelper;
import Helper::Helper;
import Helper::CloneHelper;

import Type;

import List;
import Map;
import IO;

private list[CloneTuple] _sequenceClones = [];

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
    println("Size sequences <size(sequences)>");
    int idx = 0;
    for (list[node] sequence <- sequences) {
        idx += 1;
        //println("Index: <idx>");
        for (i <- [0..(size(sequence) + 1)]) {
            for (j <- [0..(size(sequence) + 1)]) {
                //println("I: <i>");
                //println("J: <j>");
                //println("Thes: <i + sequenceThreshold>");
                if ((j >= i + sequenceThreshold)) {
                    list[node] subsequence = sequence[i..j];
                    
                    hash = hashSequence(subsequence, false);
                    //println("Subseq: <size(subsequence)>, I: <i>, J: <j>, Hash: <hash>");

                    if (hash notin subsequences) {
                        subsequences[hash] = [];
                    }

                    subsequences[hash] += [subsequence];
                    //println(size(subsequences[hash]));
                }
            }
        }
    }

    return subsequences;
}

// Function to find sequence clones
list[CloneTuple] findSequenceClones(map[str, list[list[node]]] sequences,
                        real similarityThreshold, list[CloneTuple] clonePairs, 
                        bool print=false,
                        bool type2=false) {

    int counter = 0;
    //int sizeS = size(sequences);

    for (hash <- sequences) {
        counter += 1;

        list[list[node]] subsequences = sequences[hash];
        //println("Subsequences amount: <typeOf(subsequences)>");

        for (i <- subsequences) {
            for (j <- subsequences) {
                //println("Size I: <size(i)>");
                //println("Size J: <size(j)>");
                //println(i != j);
                if (! type2 && i != j) {
                    //println("Pair: <<i, j>>");
                    println("ye");
                    CloneTuple sequenceTuple = <i[0], j[0]>;
                    addSequenceClone(sequenceTuple, clonePairs);
                }
                else if (i != j) {
                    if (nodeSimilarity(i, j) >= similarityThreshold) {
                        addSequenceClone(<i, j>, clonePairs);
                    }
                }
            }
        }
    }

    return _sequenceClones;
}

// TODO LOOK AT NEFELI FURTHER...

// Function to add sequence clones to our list of clone pairs. Also implements
// subsumption in a similar way as is the case in addClone().
// This function includes some optional print functionality for debugging purposes.
public void addSequenceClone(CloneTuple newPair, list[CloneTuple] clonePairs) {
    
    // Ignore the pair if one node is a subtree of another node
    if (isNodeSubset(newPair.nodeA, newPair.nodeB) || isNodeSubset(newPair.nodeB, newPair.nodeA)) {
        return;
    }



    // Check the sequence pairs
    for (oldPair <- _sequenceClones) {
        // Check if the pair already exists in flipped form
        if (oldPair == <newPair.nodeB, newPair.nodeA>) {
            return;
        }

        // Ignore the pair if it is a subset of an already existing pair
        if ((isNodeSubset(oldPair.nodeA, newPair.nodeA) && isNodeSubset(oldPair.nodeB, newPair.nodeB)) || (isNodeSubset(oldPair.nodeA, newPair.nodeB) && isNodeSubset(oldPair.nodeB, newPair.nodeA))) {
            return;
        }

        // If the current old pair is a subset of the current new pair. Remove
        // the old pair.
        if ((isNodeSubset(newPair.nodeA, oldPair.nodeA) && isNodeSubset(newPair.nodeB, oldPair.nodeB)) || (isNodeSubset(newPair.nodeA, oldPair.nodeB) && isNodeSubset(newPair.nodeB, oldPair.nodeA))) {
            _sequenceClones -= oldPair;
        }
    }

    // Check the atomic pairs.
    for (oldPair <- clonePairs) {
        // Check if the new pair already exists as atomic pair(normal and flipped) (only for sequence length 1)

        // Ignore the new sequence pair if it is a subset of an already existing atomic pair
        if ((isNodeSubset(oldPair.nodeA, newPair.nodeA) && isNodeSubset(oldPair.nodeB, newPair.nodeB)) || (isNodeSubset(oldPair.nodeA, newPair.nodeB) && isNodeSubset(oldPair.nodeB, newPair.nodeA))) {
            return;
        }

        // If the current atomic pair is a subset of the current new sequence pair. Remove it.
        if ((isNodeSubset(newPair.nodeA, oldPair.nodeA) && isNodeSubset(newPair.nodeB, oldPair.nodeB)) || (isNodeSubset(newPair.nodeA, oldPair.nodeB) && isNodeSubset(newPair.nodeB, oldPair.nodeA))) {
            clonePairs -= oldPair;
        }
    }

    _sequenceClones += newPair;

    return;
}