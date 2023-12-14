module Helper::NodeHelpers

import Node;
import Helper::Types;
import List;

public loc noLocation = |unresolved:///|;

public bool isLeaf(node subtree) {
	return size(getChildren(subtree)) > 0;
}  

public loc nodeFileLocation(node n) {
	loc location = noLocation;

    bool hasSrcParam = ("src" in getKeywordParameters(n));

    if(hasSrcParam) {
        location = n.src;
    }
	
	return location;
}


/* Is tree2 contained in tree1 –> Is tree2 a subnode of tree1 */ 
public bool isNodeSubset(node tree1, node tree2) {
	nodeString1 = toString(tree1);
	nodeString2 = toString(tree2);

	if(nodeString1 == nodeString2) {
		return false;
	}

    return contains(nodeString1, nodeString2);
}

bool isSubset(list[node] rootSequence, list[node] subSequence) {
    // If the root sequence entails the sub-sequence, it is a subset.
    // We check that by comparing the node locations and if they are subsumed by another element.
    if (isSubsequence(rootSequence, subSequence)) {
        return true;
    }

    list[loc] rootSequenceLocs = [nodeFileLocation(n) | n <- rootSequence];
    list[loc] subSequenceLocs = [nodeFileLocation(n) | n <- subSequence];

    return any(loc rootSeqLoc <- rootSequenceLocs, nodeLocContainedInNodeLocList(rootSeqLoc, subSequenceLocs));
}

bool nodeLocContainedInNodeLocList(loc testedNodeLoc, list[loc] sequenceValueLocs) {
    return any(loc seqValueLoc <- sequenceValueLocs, nodeLocContainsInOtherLoc(testedNodeLoc, seqValueLoc));
}

bool nodeLocContainsInOtherLoc(loc testedLoc, loc encapsulatedLoc) {
    if((testedLoc.path == encapsulatedLoc.path) && (testedLoc.begin.line < encapsulatedLoc.begin.line) && (testedLoc.end.line > encapsulatedLoc.end.line)) {
        return true;
    }

    return false;
}

bool isSubsequence(list[value] mainList, list[value] subList) {
    int sizeSubList = size(subList);
    int sizeMainList = size(mainList);
    for (i <- [0..sizeMainList]) {
        int j = i + sizeSubList;
        if (mainList[i..j] == subList) {
            return true;
        }
    }
    return false;
}