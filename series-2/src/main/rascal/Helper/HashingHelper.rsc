module Helper::HashingHelper

import Prelude;
import util::Math;
import Node;
import Helper::NodeHelpers;
import Helper::Types;

/* 
Helper Function to generate a bad hash. But not too bad, because then we would 
have _everything_ in one bucket.
*/ 
str genStringHashCode(str input) {
    int hashCode = 7;
    list[int] inputCharacters = chars(input);

    for(character <- inputCharacters) {
        hashCode = hashCode*31 + character;
    }

    return toString(hashCode)[1..15];
}

/* 
Hashing the subtree in order to put it into respective buckets for clonePairs
detection. The literature proposes to use a "bad" or in more profesionnal terms
a "weak" hashing function in order to put similar nodes into a bucket.

The parameter "ignoreLeaves" is added in order to be able to distinguish between
type 1 (exact clones) and type 2 (near miss clones). Leaves are considered to be
identifiers according to the Baxter Paper. 
*/ 
public str hashSubtree(node subtree, bool ignoreLeaves) {
    elementsToHash = [];
    for (node element <- subtree) {
        if(ignoreLeaves == false) {
            elementsToHash += element;
        }
        if (ignoreLeaves && !isLeaf(element)) {
            elementsToHash += element;
        } 
    }
    return genStringHashCode(toString(elementsToHash));
}

public map[str, list[NodeLoc]] placingSubTreesInBuckets(list[NodeHashLoc] nodeHashList) {
        set[str] nodeHashes = toSet([nodeHash.nHash.nodeHash | nodeHash <- nodeHashList, true]);
        map[str, list[NodeLoc]] hashBuckets = ();

        for(hash <- nodeHashes) {
            list[NodeHashLoc] nodesHashesWithSameHashes = [h | h <- nodeHashList, h.nHash.nodeHash == hash];
            list[NodeLoc] nodesWithSameHashes = [<i.nHash.hashedNode, i.nodeLoc> | i <- nodesHashesWithSameHashes, true];
            hashBuckets = hashBuckets + (hash: nodesWithSameHashes);
        }
        return hashBuckets;
}