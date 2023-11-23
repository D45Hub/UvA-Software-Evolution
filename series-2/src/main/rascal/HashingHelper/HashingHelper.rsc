module HashingHelper::HashingHelper

import Node;
import String;
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
a "weak" hashing function in order to put similar nodes into a bucket 

*/ 
public str hashSubtree(node subtree) {
    stringifiedSubTree = toString(subtree);
    return genStringHashCode(stringifiedSubTree);
}