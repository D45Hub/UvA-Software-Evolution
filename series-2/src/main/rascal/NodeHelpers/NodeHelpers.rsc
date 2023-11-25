module NodeHelpers::NodeHelpers

import Node;
import HashingHelper::HashingHelper;

/* A module to have some helpers for node ttypes*/

alias NodeHash = tuple[str nodeHash, node n];

/* Determining the size of a subtree, needed for the mass threshold */ 
public int nodeSize(node subtree) {
	return arity(subtree) + 1;
}

public list[node] getSubNodesList(node rootNode) {
	list[node] subNodeList = getChildren(rootNode);
	subNodeList += [rootNode];
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