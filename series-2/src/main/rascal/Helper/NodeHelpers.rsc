module Helper::NodeHelpers

import Node;
import Helper::HashingHelper;
import Helper::Types;
import List;

public loc noLocation = |unresolved:///|;

/* Determining the size of a subtree, needed for the mass threshold */ 
public int nodeSize(node subtree) {
	return arity(subtree) + 1;
}

public bool isLeaf(node subtree) {
	return size(getChildren(subtree)) > 0;
}  

public list[value] getSubNodesList(node rootNode) {
	/* A list of mixed-type values: [3, "a", 4]. Its type is list[value]. */ 
	list[value] subNodeList = [n | n <- getChildren(rootNode)] + [rootNode];
	return subNodeList;
}

public list[NodeHash] getNSizedHashedSubtrees(list[node] rootNode, int minSubtreeSize) {
	list[NodeHash] subNodeList = [];
	list[NodeLoc] rootNodeWithoutKeywords = [<unsetRec(n), nodeFileLocation(n)> | n <- rootNode, true];

	for(NodeLoc rNode <- rootNodeWithoutKeywords) {
		
		loc rootNodeLoc = rNode.l;
		if((rootNodeLoc.end.line - rootNodeLoc.begin.line + 1) >= minSubtreeSize) {
			subNodeList += [<hashSubtree(rNode.nodeLocNode, false), rNode.nodeLocNode>];
		}
	}

    return subNodeList;
}

public loc nodeFileLocation(node n) {
	loc location = noLocation;

    bool hasSrcParam = ("src" in getKeywordParameters(n));

    if(hasSrcParam) {
        location = n.src;
    }
	
	return location;
}


/**
This function determines the Hash of node / subtree and its location.
It returns a tuple of nodeContent  (without any keywords) – location – hash
*/ 

public list[NodeHashLoc] prepareASTNodesForAnalysis(list[node] projectNodes, int massThreshold) {
    list[NodeHashLoc] nodeHashLocations = [];

    for(projectNode <- projectNodes) {
        loc projectNodeLocation = nodeFileLocation(projectNode);

        if(projectNodeLocation != noLocation) {
            node unsetRecNode = unsetRec(projectNode);
            str hashedProjectNode = hashSubtree(unsetRecNode, false);

            int nodeLineDifference = projectNodeLocation.end.line - projectNodeLocation.begin.line + 1;

            // TODO Find out if this is relevant or not...
            bool areNodeLinesInThreshold = nodeLineDifference >= massThreshold;
            bool isNodeSizeInThreshold = nodeSize(projectNode) >= massThreshold;
            
            if(areNodeLinesInThreshold && isNodeSizeInThreshold) {
                nodeHashLocations += <<hashedProjectNode, unsetRecNode>, projectNodeLocation>;
            }
        }
    }

    return nodeHashLocations;
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