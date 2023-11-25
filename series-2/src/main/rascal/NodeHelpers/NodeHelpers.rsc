module NodeHelpers::NodeHelpers

import Node;
import HashingHelper::HashingHelper;
import List;

/* A module to have some helpers for node ttypes*/

alias NodeHash = tuple[str nodeHash, node n];

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

public list[NodeHash] getNSizedHashedSubtrees(node rootNode, int minSubtreeSize) {
	list[NodeHash] subNodeList = [];

	bottom-up visit (rootNode) {
        case node n: {
            if(nodeSize(n) >= minSubtreeSize) {
				subNodeList += [<hashSubtree(n), n>];
			}
        }
    }
    return subNodeList;
}