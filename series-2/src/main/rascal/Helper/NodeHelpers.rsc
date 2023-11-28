module Helper::NodeHelpers

import Node;
import Helper::HashingHelper;
import Helper::Types;
import List;

public loc noLocation = |unresolved:///|;

alias NodeLoc = tuple[node nodeLocNode, loc l];

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