module Helper::NodeHelpers

import Node;
import Helper::HashingHelper;
import Helper::Types;
import List;

public loc noLocation = |unresolved:///|;

private list[CloneTuple] _clonePairs = [];

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
	
	if (Declaration d := n) 
		location = d.src;
	
	if (Expression e := n) 
		location = e.src;
	
	if (Statement s := n)
		location = s.src;
	
	//Unit that is not related to source-code
	if(location == |unknown:///|) {
		location = noLocation;
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

	if(nodeString1 ==  nodeString2) {
		return false;
	}

    return contains(nodeString1, nodeString2);
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