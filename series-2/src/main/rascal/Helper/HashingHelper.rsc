module Helper::HashingHelper

import Prelude;
import util::Math;

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

    return toString(hashCode);
}

/* 
Hashing the subtree in order to put it into respective buckets for clonePairs
detection. The literature proposes to use a "bad" or in more profesionnal terms
a "weak" hashing function in order to put similar nodes into a bucket.

The parameter "ignoreLeaves" is added in order to be able to distinguish between
type 1 (exact clones) and type 2 (near miss clones). Leaves are considered to be
identifiers according to the Baxter Paper. 

TODO: Momentan gibt er nur einen Hashwert für die ganze Liste aus, das ist vlt etwas dumm.
*/ 
public str hashSubtree(list[node] subtree, bool ignoreLeaves) {
    elementsToHash = [];
    for (element <- subtree) {
        if(ignoreLeaves == false) {
            elementsToHash += element;
        }
        if ((ignoreLeaves && size(getChildren(element)) > 0)) {
            elementsToHash += element;
        } 
    }
    return genStringHashCode(toString(elementsToHash));
}
